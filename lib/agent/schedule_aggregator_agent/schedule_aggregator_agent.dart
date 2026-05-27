import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/schedule_aggregator_agent/prompt.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_state_service.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/schedule_state.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('ScheduleAggregatorAgent');

class ScheduleAggregatorAgent {
  static Future<StatefulAgent> _createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required AgentState state,
  }) async {
    final sessionId = state.sessionId;

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final skills = [
      ScheduleAggregationSkill(
        forceActivate: true,
        stopAfterSetPresentation: true,
      ),
    ];

    final agent = StatefulAgent(
      name: 'schedule_aggregator_agent',
      client: client,
      modelConfig: modelConfig,
      state: state,
      compressor: LLMBasedContextCompressor(
        client: client,
        modelConfig: modelConfig,
        totalTokenThreshold: 32000,
        keepRecentMessageSize: 10,
      ),
      tools: const [],
      skills: skills,
      systemPrompts: [scheduleAggregatorSystemPrompt],
      disableSubAgents: true,
      controller: controller,
      withGeneralPrinciples: true,
      planMode: PlanMode.none,
      systemCallback: createSystemCallback(userId),
      autoSaveStateFunc: (state) async {
        await saveAgentState(state);
      },
    );

    _logger.info(
      'ScheduleAggregatorAgent created, userId: $userId, sessionId: $sessionId',
    );
    return agent;
  }

  static Future<bool> updateScheduleAggregation({
    String? userId,
    String? runId,
    Map<String, dynamic>? routerHint,
  }) async {
    final effectiveUserId = userId ?? await UserStorage.getUserId();
    if (effectiveUserId == null) {
      throw Exception(
        'User not logged in, cannot refresh schedule aggregation',
      );
    }

    final now = DateTime.now();
    final normalizedRunId = runId?.trim();
    final effectiveRunId = normalizedRunId == null || normalizedRunId.isEmpty
        ? 'manual_${now.microsecondsSinceEpoch}'
        : normalizedRunId;
    final fileSystem = FileSystemService.instance;
    final runIdSafe = fileSystem.makeFactIdSafe(effectiveRunId);
    final sessionId = 'schedule_aggregator_$runIdSafe';

    final scheduleState = await ScheduleStateService.instance.ensureInitialized(
      effectiveUserId,
      now: now,
    );
    final isManualRefresh = routerHint == null || routerHint.isEmpty;
    final manualInputMarkdown = isManualRefresh
        ? await _buildRecentScheduleInputMarkdown(
            userId: effectiveUserId,
            scheduleState: scheduleState,
            now: now,
          )
        : null;
    if (!_hasScheduleData(scheduleState) &&
        isManualRefresh &&
        (manualInputMarkdown == null || manualInputMarkdown.isEmpty)) {
      await _completeNoOpScheduleAggregation(
        sessionId: sessionId,
      );
      return true;
    }

    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.scheduleAggregatorAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final client = resources.client;
    final modelConfig = resources.modelConfig;

    final state = await loadOrCreateAgentState(sessionId, {
      'userId': effectiveUserId,
      'scene': 'schedule_aggregation',
      'sceneId': effectiveRunId,
      'run_id': effectiveRunId,
    });
    state.metadata['userId'] = effectiveUserId;
    state.metadata['scene'] = 'schedule_aggregation';
    state.metadata['sceneId'] = effectiveRunId;
    state.metadata['run_id'] = effectiveRunId;
    state.metadata['run_started_at'] ??= now.toIso8601String();

    final agent = await _createAgent(
      client: client,
      modelConfig: modelConfig,
      userId: effectiveUserId,
      state: state,
    );

    List<LLMMessage> result = [];
    try {
      if (state.isRunning) {
        _logger.info(
          "ScheduleAggregatorAgent resume, sessionId:${state.sessionId}",
        );
        result = await agent.resume();
      } else {
        _logger.info(
          "ScheduleAggregatorAgent run, sessionId:${state.sessionId}",
        );

        const inputMessage = 'Please handle the current task.';
        final runContext = _buildScheduleRunContext(
          runId: effectiveRunId,
          generatedAt: now,
          scheduleState: scheduleState,
          routerHint: routerHint,
          manualInputMarkdown: manualInputMarkdown,
        );

        final messages = [
          UserMessage([
            TextPart(buildCurrentTimeReminder(now)),
            TextPart(runContext),
            TextPart(inputMessage),
          ]),
        ];
        _logger.info("ScheduleAggregatorAgent start");

        // Log agent execution event
        try {
          final fileSystem = FileSystemService.instance;
          await fileSystem.eventLogService.logEvent(
            userId: effectiveUserId,
            eventType: 'agent_execution',
            description: 'Schedule Aggregator Agent started',
            metadata: {
              'agent_name': 'schedule_aggregator_agent',
              'session_id': sessionId,
              'run_id': effectiveRunId,
              'input': inputMessage,
            },
          );
        } catch (e) {
          // Event logging failure should not break agent execution
        }

        result = await agent.run(messages);
      }

      // Post-processing: emit UI refresh event for both fresh runs and resume.
      EventBusService.instance.emitEvent(
        ScheduleAggregationUpdatedMessage(aggregationId: 'schedule_state'),
      );
    } on AgentException catch (e) {
      if (e.code == AgentExceptionCode.loopDetection) {
        _logger.info(
          "ScheduleAggregatorAgent loop detection, sessionId:${state.sessionId}",
        );
      }
      rethrow;
    }

    _logger.info(
      "ScheduleAggregatorAgent done, sessionId:${state.sessionId}, result messages length:${result.length}",
    );
    return true;
  }

  static Future<void> _completeNoOpScheduleAggregation({
    required String sessionId,
  }) async {
    EventBusService.instance.emitEvent(
      ScheduleAggregationUpdatedMessage(aggregationId: 'schedule_state'),
    );
    _logger.info(
      'ScheduleAggregatorAgent no-op completed, sessionId:$sessionId',
    );
  }
}

bool _hasScheduleData(ScheduleState state) {
  return state.pending.isNotEmpty ||
      state.completed.isNotEmpty ||
      state.presentation != null;
}

String _buildScheduleRunContext({
  required String runId,
  required DateTime generatedAt,
  required ScheduleState scheduleState,
  Map<String, dynamic>? routerHint,
  String? manualInputMarkdown,
}) {
  final inputMarkdown = _currentInputMarkdown(
    routerHint,
    manualInputMarkdown: manualInputMarkdown,
  );
  final metadata = {
    'run_id': runId,
    'generated_at': generatedAt.toIso8601String(),
    if (routerHint != null && routerHint['reason'] != null)
      'router_reason': routerHint['reason'],
  };

  return '''# Schedule Aggregation Run Context

## Run Metadata
```json
${const JsonEncoder.withIndent('  ').convert(metadata)}
```

## Current Input
$inputMarkdown

## Schedule State
```json
${const JsonEncoder.withIndent('  ').convert(_compactScheduleState(scheduleState, generatedAt: generatedAt))}
```

## Execution Policy
- Use schedule_state as the source of truth for pending schedule items, recent completed items, and presentation.
- Use only the current input and schedule_state.
- Apply needed schedule changes with the schedule tools.
- Use set_presentation only when refreshing the presentation.
- If neither schedule_state nor presentation should change, do not call tools.
''';
}

String _currentInputMarkdown(
  Map<String, dynamic>? routerHint, {
  String? manualInputMarkdown,
}) {
  if (routerHint == null || routerHint.isEmpty) {
    final manualInput = manualInputMarkdown?.trim();
    if (manualInput != null && manualInput.isNotEmpty) {
      return manualInput;
    }
    return '(No current input; refresh the presentation from schedule_state.)';
  }
  final markdown = routerHint['input_markdown'];
  if (markdown is String && markdown.trim().isNotEmpty) {
    return markdown;
  }

  final factId = routerHint['fact_id']?.toString();
  final combinedText = routerHint['combined_text']?.toString().trim() ?? '';
  final buffer = StringBuffer();
  if (factId != null && factId.isNotEmpty) {
    buffer.writeln('- Raw Input ID (fact_id): $factId');
    buffer.writeln();
  }
  buffer.writeln('### Raw Input Content');
  buffer.writeln(
    combinedText.isEmpty ? '(No text content.)' : _truncate(combinedText, 4000),
  );
  return buffer.toString().trimRight();
}

Map<String, dynamic> _compactScheduleState(
  ScheduleState state, {
  required DateTime generatedAt,
}) {
  final json = state.toJson();
  json['completed'] = _recentCompletedScheduleItems(
    state,
    now: generatedAt,
  ).map((item) => item.toJson()).toList();
  return json;
}

List<ScheduleCompletedItem> _recentCompletedScheduleItems(
  ScheduleState state, {
  required DateTime now,
}) {
  // Completed items belong to the window by their schedule semantic time:
  // for completed state, that is the time the schedule item was closed.
  final since = now.subtract(const Duration(days: 7));
  return state.completed
      .where((item) => !item.closedAt.isBefore(since))
      .toList();
}

String _truncate(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength)}...';
}

Future<String?> _buildRecentScheduleInputMarkdown({
  required String userId,
  required ScheduleState scheduleState,
  required DateTime now,
}) async {
  final fileSystem = FileSystemService.instance;
  final sourceFactIds = _scheduleSourceFactIds(scheduleState);
  final cardPaths = await fileSystem.listAllCardFiles(userId);
  if (cardPaths.isEmpty && sourceFactIds.isEmpty) return null;

  final entries = <_ScheduleCandidateInput>[];
  final seenFactIds = <String>{};

  for (final cardPath in cardPaths) {
    if (entries.length >= 60) break;
    final factId = fileSystem.factIdFromCardPath(cardPath);
    if (factId == null || !seenFactIds.add(factId)) continue;

    final card = await fileSystem.readCardFile(userId, factId);
    if (card == null || card.deleted == true) continue;
    if (!_isScheduleCard(card) && !sourceFactIds.contains(factId)) continue;

    final fact = await fileSystem.extractFactContentFromFile(userId, factId);
    if (fact == null) continue;
    entries.add(_ScheduleCandidateInput(factId: factId, fact: fact));
  }

  for (final factId in sourceFactIds) {
    if (entries.length >= 60) break;
    if (!seenFactIds.add(factId)) continue;
    final fact = await fileSystem.extractFactContentFromFile(userId, factId);
    if (fact == null) continue;
    entries.add(_ScheduleCandidateInput(factId: factId, fact: fact));
  }

  if (entries.isEmpty) return null;

  final buffer = StringBuffer();
  buffer.writeln(
    '### Recent Schedule/Todo-Related Raw Inputs',
  );
  buffer.writeln();
  buffer.writeln(
    'These are recent raw inputs that may affect schedule_state. Use them as evidence together with the current schedule_state.',
  );

  for (final entry in entries) {
    buffer.writeln();
    buffer.writeln(
      '#### ${entry.factId} (${formatLocalDateTimeWithZone(entry.fact.datetime)})',
    );
    buffer.writeln();
    buffer.writeln(_truncate(entry.fact.content.trim(), 3000));
    _appendAssetContext(buffer, entry.fact.assetAnalyses, 'Asset Analysis');
    _appendAssetContext(buffer, entry.fact.assetOcrTexts, 'Asset OCR');
  }

  return buffer.toString().trimRight();
}

bool _isScheduleCard(CardData card) {
  return card.uiConfigs.any((config) {
    return config.templateId == 'event' ||
        config.templateId == 'task' ||
        config.templateId == 'system_task';
  });
}

Set<String> _scheduleSourceFactIds(ScheduleState state) {
  final ids = <String>{};
  for (final item in state.pending) {
    ids.addAll(item.sourceFactIds.where(_isFactId));
  }
  for (final item in state.completed) {
    ids.addAll(item.sourceFactIds.where(_isFactId));
  }
  return ids;
}

bool _isFactId(String value) {
  return RegExp(r'^\d{4}/\d{2}/\d{2}\.md#ts_\d+$').hasMatch(value);
}

void _appendAssetContext(
  StringBuffer buffer,
  List<Map<String, dynamic>> entries,
  String title,
) {
  if (entries.isEmpty) return;

  buffer.writeln();
  buffer.writeln('##### $title');
  for (final entry in entries) {
    final name = entry['name']?.toString();
    final text =
        (entry['analysis'] ?? entry['ocr_text'] ?? entry['text'])?.toString();
    if (text == null || text.trim().isEmpty) continue;
    final label = name == null || name.isEmpty ? '' : ' ($name)';
    buffer.writeln();
    buffer.writeln('-$label ${_truncate(text.trim(), 1200)}');
  }
}

class _ScheduleCandidateInput {
  const _ScheduleCandidateInput({
    required this.factId,
    required this.fact,
  });

  final String factId;
  final FactContentResult fact;
}
