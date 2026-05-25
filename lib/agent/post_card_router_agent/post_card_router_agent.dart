import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:intl/intl.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/post_card_router_agent/prompt.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/logger.dart';

final _logger = getLogger('PostCardRouterAgent');

/// Names of the downstream agents the router can activate.
class PostCardRouterTargets {
  static const String scheduleAggregator = 'schedule_aggregator';
  static const String taskCompletion = 'task_completion';
  static const String systemAction = 'system_action';
  static const String askClarification = 'ask_clarification';

  static const Set<String> all = {
    scheduleAggregator,
    taskCompletion,
    systemAction,
    askClarification,
  };
}

class PostCardRouteResult {
  const PostCardRouteResult({
    required this.activatedAgents,
    required this.reason,
    this.confidence,
  });

  final List<String> activatedAgents;
  final String reason;
  final double? confidence;
}

/// Lightweight selector agent. Decides which downstream agents should run
/// for a newly submitted user input, then enqueues their tasks.
class PostCardRouterAgent {
  static Future<PostCardRouteResult> route({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    required String combinedText,
    required Map<String, dynamic> recentScheduleContext,
    required Map<String, dynamic> refreshState,
  }) async {
    PostCardRouteResult? toolDecision;

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final sessionId = 'post_card_router_${userId}_${_safeSessionPart(factId)}';
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'factId': factId,
      'scene': 'post_card_router',
      'sceneId': factId,
      'agentName': 'post_card_router_agent',
    });

    final tools = [
      _buildActivateTool(
        userId: userId,
        factId: factId,
        combinedText: combinedText,
        recentScheduleContext: recentScheduleContext,
        onDecision: (decision) => toolDecision = decision,
      ),
    ];

    final agent = StatefulAgent(
      name: 'post_card_router_agent',
      client: client,
      modelConfig: modelConfig,
      state: state,
      compressor: LLMBasedContextCompressor(
        client: client,
        modelConfig: modelConfig,
        totalTokenThreshold: 12000,
        keepRecentMessageSize: 4,
      ),
      tools: tools,
      systemPrompts: [postCardRouterSystemPrompt],
      disableSubAgents: true,
      controller: controller,
      withGeneralPrinciples: true,
      planMode: PlanMode.none,
      systemCallback: createSystemCallback(userId),
      autoSaveStateFunc: (state) async {
        await saveAgentState(state);
      },
    );

    final context = buildPostCardRouterContext(
      factId: factId,
      combinedText: combinedText,
      recentScheduleContext: recentScheduleContext,
      refreshState: refreshState,
    );

    final messages = [
      UserMessage([
        TextPart(
          '<system-reminder>current time is '
          '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.'
          '</system-reminder>',
        ),
        TextPart(
          'Decide which downstream agents to activate for this new input. '
          'Call the `activate` tool exactly once. Use an empty list if no '
          'downstream agent is needed.\n\n${jsonEncode(context)}',
        ),
      ]),
    ];

    try {
      await agent.run(messages, useStream: false);
    } finally {
      try {
        await deleteAgentState(userId, sessionId);
      } catch (_) {
        // best effort
      }
    }

    final decision = toolDecision;
    if (decision != null) {
      _logger.info(
        'Router decision for $factId: agents=${decision.activatedAgents}, '
        'reason="${decision.reason}", confidence=${decision.confidence}',
      );
      return decision;
    }

    _logger.warning(
      'Router did not call activate for $factId; treating as no-op.',
    );
    return const PostCardRouteResult(
      activatedAgents: [],
      reason: 'router_no_decision',
    );
  }
}

/// Build the structured context that the router LLM receives.
Map<String, dynamic> buildPostCardRouterContext({
  required String factId,
  required String combinedText,
  required Map<String, dynamic> recentScheduleContext,
  required Map<String, dynamic> refreshState,
}) {
  return {
    'new_input': {
      'fact_id': factId,
      'combined_text': _truncate(combinedText, 4000),
    },
    'recent_schedule_context': recentScheduleContext,
    'schedule_refresh_state': refreshState,
  };
}

Tool _buildActivateTool({
  required String userId,
  required String factId,
  required String combinedText,
  required Map<String, dynamic> recentScheduleContext,
  required void Function(PostCardRouteResult decision) onDecision,
}) {
  return Tool(
    name: 'activate',
    description:
        'Activate the chosen downstream agents for this input. Pass an '
        'empty list when nothing needs to run. Allowed agent names: '
        'schedule_aggregator, task_completion, system_action, '
        'ask_clarification.',
    parameters: {
      'type': 'object',
      'properties': {
        'agents': {
          'type': 'array',
          'items': {
            'type': 'string',
            'enum': [
              PostCardRouterTargets.scheduleAggregator,
              PostCardRouterTargets.taskCompletion,
              PostCardRouterTargets.systemAction,
              PostCardRouterTargets.askClarification,
            ],
          },
          'description': 'Downstream agents to activate; may be empty.',
        },
        'reason': {
          'type': 'string',
          'description':
              'Short, user-facing rationale for the chosen activation set.',
        },
        'confidence': {
          'type': 'number',
          'description': 'Confidence from 0 to 1.',
        },
      },
      'required': ['agents', 'reason'],
    },
    executable: (
      List<dynamic>? agents,
      String reason,
      num? confidence,
    ) async {
      final normalized = _normalizeAgents(agents);

      // Enqueue the corresponding downstream tasks. Best-effort: a failure
      // to enqueue one branch should not stop the others.
      for (final agentName in normalized) {
        try {
          await _enqueueDownstream(
            agentName: agentName,
            userId: userId,
            factId: factId,
            combinedText: combinedText,
            recentScheduleContext: recentScheduleContext,
            reason: reason,
          );
        } catch (e, st) {
          _logger.severe(
            'Failed to activate downstream agent "$agentName" for $factId',
            e,
            st,
          );
        }
      }

      onDecision(
        PostCardRouteResult(
          activatedAgents: normalized,
          reason: reason,
          confidence: confidence?.toDouble(),
        ),
      );

      if (normalized.isEmpty) {
        return 'No downstream agent activated: $reason';
      }
      return 'Activated downstream agents: ${normalized.join(', ')}. $reason';
    },
  );
}

Future<void> _enqueueDownstream({
  required String agentName,
  required String userId,
  required String factId,
  required String combinedText,
  required Map<String, dynamic> recentScheduleContext,
  required String reason,
}) async {
  final basePayload = <String, dynamic>{
    'fact_id': factId,
    'combined_text': combinedText,
    'router_reason': reason,
  };

  switch (agentName) {
    case PostCardRouterTargets.scheduleAggregator:
      // Mark schedule view dirty before triggering the aggregator so the
      // schedule UI knows it is currently stale.
      await ScheduleRefreshStateService.instance.markDirty(
        userId: userId,
        reason: reason,
        cardIds: [factId],
        refreshRequested: true,
      );
      // Reuse the existing scheduleAggregationRequested event so the
      // aggregator queue collapses repeated requests across inputs.
      await GlobalEventBus.instance.publish(
        userId: userId,
        event: SystemEvent(
          type: SystemEventTypes.scheduleAggregationRequested,
          source: 'post_card_router_agent',
          payload: {
            'reason': reason,
            'card_ids': [factId]
          },
        ),
      );
      return;
    case PostCardRouterTargets.taskCompletion:
      await LocalTaskExecutor.instance.enqueueTask(
        userId: userId,
        taskType: 'task_completion_task',
        payload: {
          ...basePayload,
          'recent_schedule_context': recentScheduleContext,
        },
      );
      return;
    case PostCardRouterTargets.systemAction:
      await LocalTaskExecutor.instance.enqueueTask(
        userId: userId,
        taskType: 'system_action_task',
        payload: basePayload,
      );
      return;
    case PostCardRouterTargets.askClarification:
      await LocalTaskExecutor.instance.enqueueTask(
        userId: userId,
        taskType: 'ask_clarification_task',
        payload: basePayload,
      );
      return;
  }
}

List<String> _normalizeAgents(List<dynamic>? raw) {
  final seen = <String>{};
  final ordered = <String>[];
  if (raw == null) return ordered;
  for (final item in raw) {
    final value = item?.toString().trim();
    if (value == null || value.isEmpty) continue;
    if (!PostCardRouterTargets.all.contains(value)) continue;
    if (seen.add(value)) ordered.add(value);
  }
  return ordered;
}

/// Run the router using the configured LLM resources, building the same
/// schedule-context snapshot the downstream agents rely on.
Future<PostCardRouteResult> runPostCardRouter({
  required String userId,
  required String factId,
  required String combinedText,
  required LLMClient client,
  required ModelConfig modelConfig,
}) async {
  final now = DateTime.now();
  final recentScheduleContext = await queryScheduleCardsForRange(
    userId: userId,
    from: now.subtract(const Duration(days: 3)),
    to: now.add(const Duration(days: 7)),
    limit: 40,
  );
  final refreshState =
      (await ScheduleRefreshStateService.instance.read(userId)).toJson();

  return PostCardRouterAgent.route(
    client: client,
    modelConfig: modelConfig,
    userId: userId,
    factId: factId,
    combinedText: combinedText,
    recentScheduleContext: recentScheduleContext,
    refreshState: refreshState,
  );
}

/// Pure-rule fallback used when no LLM is configured. Empty activation set
/// means nothing downstream will run.
PostCardRouteResult fallbackPostCardRoute({
  required String factId,
  required String combinedText,
}) {
  // Without LLM context we cannot reliably classify the input. Instead of
  // guessing, leave activation empty and let the user trigger downstream
  // refresh manually if needed.
  _logger.info(
    'Post-card router fallback (no LLM) for $factId; activating nothing.',
  );
  return const PostCardRouteResult(
    activatedAgents: [],
    reason: 'no_llm_configured',
  );
}

String _safeSessionPart(String value) {
  return value.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
}

String _truncate(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength)}...';
}
