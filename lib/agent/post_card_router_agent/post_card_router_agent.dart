import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/agent_utils.dart';
import 'package:memex/agent/post_card_router_agent/prompt.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/schedule_state_service.dart';
import 'package:memex/domain/models/schedule_state.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';

final _logger = getLogger('PostCardRouterAgent');

/// Names of the downstream agents the router can activate.
class PostCardRouterTargets {
  static const String scheduleAggregator = 'schedule_aggregator';
  static const String askClarification = 'ask_clarification';

  static const Set<String> all = {
    scheduleAggregator,
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
    required String inputMarkdown,
    required Map<String, dynamic> scheduleStateContext,
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
        inputMarkdown: inputMarkdown,
        scheduleStateContext: scheduleStateContext,
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

    final context = buildPostCardRouterContextMarkdown(
      factId: factId,
      inputMarkdown: inputMarkdown,
      scheduleStateContext: scheduleStateContext,
    );

    final messages = [
      UserMessage([
        TextPart(buildCurrentTimeReminder(DateTime.now())),
        TextPart(
          'Decide which downstream agents to activate for this new input. '
          'Call the `select_downstream_agents` tool exactly once. Use an '
          'empty list if no downstream agent is needed.\n\n'
          '$context',
        ),
      ]),
    ];

    if (state.isRunning) {
      _logger.info('Post-card router resume, sessionId:$sessionId');
      await agent.resume(useStream: false);
    } else {
      _logger.info('Post-card router run, sessionId:$sessionId');
      await agent.run(messages, useStream: false);
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
      'Router did not call select_downstream_agents for $factId; treating '
      'as no-op.',
    );
    return const PostCardRouteResult(
      activatedAgents: [],
      reason: 'router_no_decision',
    );
  }
}

/// Build the structured context that the router LLM receives.
String buildPostCardRouterContextMarkdown({
  required String factId,
  required String inputMarkdown,
  required Map<String, dynamic> scheduleStateContext,
}) {
  return '''# Post-Card Routing Context

## Current Input
$inputMarkdown

## Schedule State Context
```json
${const JsonEncoder.withIndent('  ').convert(scheduleStateContext)}
```
''';
}

Tool _buildActivateTool({
  required String userId,
  required String factId,
  required String combinedText,
  required String inputMarkdown,
  required Map<String, dynamic> scheduleStateContext,
  required void Function(PostCardRouteResult decision) onDecision,
}) {
  return Tool(
    name: 'select_downstream_agents',
    description:
        'Select which downstream agents to activate for this input. Pass '
        'an empty list when nothing needs to run. Allowed agent names: '
        'schedule_aggregator, ask_clarification. This tool finishes the '
        'routing decision; do not call any other tool afterwards.',
    parameters: {
      'type': 'object',
      'properties': {
        'agents': {
          'type': 'array',
          'items': {
            'type': 'string',
            'enum': [
              PostCardRouterTargets.scheduleAggregator,
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
            inputMarkdown: inputMarkdown,
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

      final summary = normalized.isEmpty
          ? 'No downstream agent activated: $reason'
          : 'Activated downstream agents: ${normalized.join(', ')}. $reason';

      // The routing decision is final once this tool returns. Stop the
      // agent immediately so the model does not produce a follow-up turn.
      return AgentToolResult(
        content: TextPart(summary),
        stopFlag: true,
      );
    },
  );
}

Future<void> _enqueueDownstream({
  required String agentName,
  required String userId,
  required String factId,
  required String combinedText,
  required String inputMarkdown,
  required String reason,
}) async {
  final basePayload = <String, dynamic>{
    'fact_id': factId,
    'combined_text': combinedText,
    'input_markdown': inputMarkdown,
    'router_reason': reason,
  };

  switch (agentName) {
    case PostCardRouterTargets.scheduleAggregator:
      // Reuse the existing scheduleAggregationRequested event so the
      // aggregator queue collapses repeated requests across inputs.
      await GlobalEventBus.instance.publish(
        userId: userId,
        event: SystemEvent(
          type: SystemEventTypes.scheduleAggregationRequested,
          source: 'post_card_router_agent',
          payload: {
            'reason': reason,
            'card_ids': [factId],
            'fact_id': factId,
            'combined_text': combinedText,
            'input_markdown': inputMarkdown,
          },
        ),
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

/// Run the router using the configured LLM resources and current schedule
/// state context.
Future<PostCardRouteResult> runPostCardRouter({
  required String userId,
  required String factId,
  required String combinedText,
  List<Map<String, dynamic>>? assetAnalyses,
  DateTime? inputDateTime,
  String? locationContextReminder,
  required LLMClient client,
  required ModelConfig modelConfig,
}) async {
  final scheduleState = await ScheduleStateService.instance.ensureInitialized(
    userId,
  );
  final scheduleStateContext = _compactScheduleStateForRouter(scheduleState);
  final inputMarkdown = buildPostCardRouterInputMarkdown(
    factId: factId,
    combinedText: combinedText,
    assetAnalyses: assetAnalyses,
    inputDateTime: inputDateTime,
    locationContextReminder: locationContextReminder,
  );
  return PostCardRouterAgent.route(
    client: client,
    modelConfig: modelConfig,
    userId: userId,
    factId: factId,
    combinedText: combinedText,
    inputMarkdown: inputMarkdown,
    scheduleStateContext: scheduleStateContext,
  );
}

String buildPostCardRouterInputMarkdown({
  required String factId,
  required String combinedText,
  List<Map<String, dynamic>>? assetAnalyses,
  DateTime? inputDateTime,
  String? locationContextReminder,
}) {
  final buffer = StringBuffer();
  buffer.writeln('- Raw Input ID (fact_id): $factId');
  if (inputDateTime != null) {
    buffer.writeln(
      '- Published time: ${formatLocalDateTimeWithZone(inputDateTime)}',
    );
  }
  final locationReminder = locationContextReminder?.trim();
  if (locationReminder != null && locationReminder.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('<system-reminder>');
    buffer.writeln(locationReminder);
    buffer.writeln('</system-reminder>');
  }
  buffer.writeln();
  buffer.writeln('### Raw Input Content');
  final trimmed = combinedText.trim();
  buffer.writeln(
      trimmed.isEmpty ? '(No text content.)' : _truncate(trimmed, 4000));
  buffer.write(formatAssetAnalysis(assetAnalyses, includeExif: true));
  return buffer.toString().trimRight();
}

Map<String, dynamic> _compactScheduleStateForRouter(ScheduleState state) {
  final pending = state.pending.take(30).map((item) {
    return {
      'id': item.id,
      'kind': item.kind,
      'title': item.title,
      if (item.startTime != null)
        'start_time': item.startTime!.toIso8601String(),
      if (item.endTime != null) 'end_time': item.endTime!.toIso8601String(),
      if (item.dueAt != null) 'due_at': item.dueAt!.toIso8601String(),
      if (item.sourceFactIds.isNotEmpty) 'source_fact_ids': item.sourceFactIds,
    };
  }).toList();
  return {
    'pending': pending,
    'pending_truncated': state.pending.length > pending.length,
  };
}

String _safeSessionPart(String value) {
  return value.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
}

String _truncate(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength)}...';
}
