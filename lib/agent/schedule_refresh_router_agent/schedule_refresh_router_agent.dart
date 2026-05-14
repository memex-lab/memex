import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:intl/intl.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/schedule_refresh_router_agent/prompt.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('ScheduleRefreshRouterAgent');

enum ScheduleRefreshRouteAction {
  skipped,
  markedDirty,
  requestedRefresh,
}

class ScheduleRefreshRouteResult {
  const ScheduleRefreshRouteResult({
    required this.action,
    required this.reason,
    this.cardIds = const [],
    this.confidence,
  });

  final ScheduleRefreshRouteAction action;
  final String reason;
  final List<String> cardIds;
  final double? confidence;
}

class ScheduleRefreshRouterAgent {
  static Future<ScheduleRefreshRouteResult> route({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    required String combinedText,
    required CardData cardData,
    required Map<String, dynamic> recentScheduleContext,
    required Map<String, dynamic> refreshState,
  }) async {
    ScheduleRefreshRouteResult? toolDecision;

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final sessionId =
        'schedule_refresh_router_${userId}_${_safeSessionPart(factId)}';
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'scene': 'schedule_refresh_router',
      'sceneId': factId,
    });

    final tools = [
      _buildSkipTool((decision) => toolDecision = decision),
      _buildMarkDirtyTool(
        userId: userId,
        defaultFactId: factId,
        onDecision: (decision) => toolDecision = decision,
      ),
      _buildRequestRefreshTool(
        userId: userId,
        defaultFactId: factId,
        onDecision: (decision) => toolDecision = decision,
      ),
    ];

    final agent = StatefulAgent(
      name: 'schedule_refresh_router_agent',
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
      systemPrompts: [scheduleRefreshRouterSystemPrompt],
      disableSubAgents: true,
      controller: controller,
      withGeneralPrinciples: true,
      planMode: PlanMode.none,
      systemCallback: createSystemCallback(userId),
      autoSaveStateFunc: (state) async {
        await saveAgentState(state);
      },
    );

    final context = buildScheduleRefreshRouterContext(
      factId: factId,
      combinedText: combinedText,
      cardData: cardData,
      recentScheduleContext: recentScheduleContext,
      refreshState: refreshState,
    );

    final messages = [
      UserMessage([
        TextPart(
          '<system-reminder>current time is ${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())}.</system-reminder>',
        ),
        TextPart(
          'Decide the schedule refresh action for this new card. '
          'Call exactly one action tool.\n\n${jsonEncode(context)}',
        ),
      ]),
    ];

    await agent.run(messages);

    final decision = toolDecision;
    if (decision != null) {
      return ensureScheduleRelevantDecision(
        userId: userId,
        factId: factId,
        cardData: cardData,
        decision: decision,
      );
    }

    _logger.warning(
      'Router agent did not call an action tool for $factId; using fallback',
    );
    return fallbackScheduleRefreshDecision(
      userId: userId,
      factId: factId,
      cardData: cardData,
    );
  }
}

Future<ScheduleRefreshRouteResult> ensureScheduleRelevantDecision({
  required String userId,
  required String factId,
  required CardData? cardData,
  required ScheduleRefreshRouteResult decision,
}) async {
  if (decision.action != ScheduleRefreshRouteAction.skipped ||
      !hasScheduleRelevantTemplates(cardData)) {
    return decision;
  }

  _logger.info(
    'Schedule refresh skip overridden for temporal card $factId',
  );
  return fallbackScheduleRefreshDecision(
    userId: userId,
    factId: factId,
    cardData: cardData,
  );
}

Future<ScheduleRefreshRouteResult> fallbackScheduleRefreshDecision({
  required String userId,
  required String factId,
  required CardData? cardData,
}) async {
  if (!hasScheduleRelevantTemplates(cardData)) {
    return const ScheduleRefreshRouteResult(
      action: ScheduleRefreshRouteAction.skipped,
      reason: 'No schedule-related templates found.',
    );
  }

  final reason = UserStorage.l10n.scheduleAggregationDirtyReason;
  await ScheduleRefreshStateService.instance.markDirty(
    userId: userId,
    reason: reason,
    cardIds: [factId],
  );
  return ScheduleRefreshRouteResult(
    action: ScheduleRefreshRouteAction.markedDirty,
    reason: reason,
  );
}

bool hasScheduleRelevantTemplates(CardData? cardData) {
  if (cardData == null) return false;
  return cardData.uiConfigs.any(
    (config) => scheduleTemporalTemplateIds.contains(config.templateId),
  );
}

Map<String, dynamic> buildScheduleRefreshRouterContext({
  required String factId,
  required String combinedText,
  required CardData cardData,
  required Map<String, dynamic> recentScheduleContext,
  required Map<String, dynamic> refreshState,
}) {
  return {
    'new_input': {
      'fact_id': factId,
      'combined_text': _truncate(combinedText, 2000),
    },
    'new_card': {
      'fact_id': cardData.factId,
      'title': cardData.title,
      'timestamp': cardData.timestamp,
      'status': cardData.status,
      'tags': cardData.tags,
      'ui_configs': cardData.uiConfigs
          .map((config) => {
                'template_id': config.templateId,
                'data': _compactValue(config.data),
              })
          .toList(),
    },
    'recent_schedule_context': recentScheduleContext,
    'schedule_refresh_state': refreshState,
  };
}

Tool _buildSkipTool(
  void Function(ScheduleRefreshRouteResult decision) onDecision,
) {
  return Tool(
    name: 'skip_schedule_refresh',
    description: 'Use when the new card does not affect schedule aggregation.',
    parameters: {
      'type': 'object',
      'properties': {
        'reason': {
          'type': 'string',
          'description': 'Short reason for skipping.',
        },
        'confidence': {
          'type': 'number',
          'description': 'Confidence from 0 to 1.',
        },
      },
      'required': ['reason'],
    },
    executable: (String reason, num? confidence) async {
      final decision = ScheduleRefreshRouteResult(
        action: ScheduleRefreshRouteAction.skipped,
        reason: reason,
        confidence: confidence?.toDouble(),
      );
      onDecision(decision);
      return 'Skipped schedule refresh: $reason';
    },
  );
}

Tool _buildMarkDirtyTool({
  required String userId,
  required String defaultFactId,
  required void Function(ScheduleRefreshRouteResult decision) onDecision,
}) {
  return Tool(
    name: 'mark_schedule_dirty',
    description:
        'Mark schedule aggregation as stale without running the full aggregator.',
    parameters: {
      'type': 'object',
      'properties': {
        'reason': {
          'type': 'string',
          'description': 'Short user-facing stale reason.',
        },
        'card_ids': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'Related card IDs.',
        },
        'confidence': {
          'type': 'number',
          'description': 'Confidence from 0 to 1.',
        },
      },
      'required': ['reason'],
    },
    executable: (
      String reason,
      List<dynamic>? cardIds,
      num? confidence,
    ) async {
      final ids = _normalizeCardIds(cardIds, defaultFactId);
      await ScheduleRefreshStateService.instance.markDirty(
        userId: userId,
        reason: reason,
        cardIds: ids,
      );
      final decision = ScheduleRefreshRouteResult(
        action: ScheduleRefreshRouteAction.markedDirty,
        reason: reason,
        cardIds: ids,
        confidence: confidence?.toDouble(),
      );
      onDecision(decision);
      return 'Schedule marked dirty: $reason';
    },
  );
}

Tool _buildRequestRefreshTool({
  required String userId,
  required String defaultFactId,
  required void Function(ScheduleRefreshRouteResult decision) onDecision,
}) {
  return Tool(
    name: 'request_schedule_refresh',
    description: 'Request a full schedule aggregation refresh. Use sparingly.',
    parameters: {
      'type': 'object',
      'properties': {
        'reason': {
          'type': 'string',
          'description': 'Short reason for immediate refresh.',
        },
        'card_ids': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'Related card IDs.',
        },
        'confidence': {
          'type': 'number',
          'description': 'Confidence from 0 to 1.',
        },
      },
      'required': ['reason'],
    },
    executable: (
      String reason,
      List<dynamic>? cardIds,
      num? confidence,
    ) async {
      final ids = _normalizeCardIds(cardIds, defaultFactId);
      await ScheduleRefreshStateService.instance.markDirty(
        userId: userId,
        reason: reason,
        cardIds: ids,
        refreshRequested: true,
      );
      await GlobalEventBus.instance.publish(
        userId: userId,
        event: SystemEvent(
          type: SystemEventTypes.scheduleAggregationRequested,
          source: 'schedule_refresh_router_agent',
          payload: {
            'reason': reason,
            'card_ids': ids,
          },
        ),
      );
      final decision = ScheduleRefreshRouteResult(
        action: ScheduleRefreshRouteAction.requestedRefresh,
        reason: reason,
        cardIds: ids,
        confidence: confidence?.toDouble(),
      );
      onDecision(decision);
      return 'Schedule refresh requested: $reason';
    },
  );
}

List<String> _normalizeCardIds(List<dynamic>? cardIds, String defaultFactId) {
  final ids = <String>{
    defaultFactId,
    ...?cardIds?.map((e) => e.toString()).where((id) => id.isNotEmpty),
  };
  return ids.toList();
}

String _safeSessionPart(String value) {
  return value.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
}

dynamic _compactValue(dynamic value, {int depth = 0}) {
  if (depth > 3) return value.toString();
  if (value is String) return _truncate(value, 500);
  if (value is Map) {
    final entries = value.entries.take(24);
    return {
      for (final entry in entries)
        entry.key.toString(): _compactValue(entry.value, depth: depth + 1),
    };
  }
  if (value is List) {
    return value
        .take(12)
        .map((e) => _compactValue(e, depth: depth + 1))
        .toList();
  }
  return value;
}

String _truncate(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength)}...';
}
