import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/agent/task_completion_agent/prompt.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/logger.dart';

final _logger = getLogger('TaskCompletionAgent');

/// Independent agent that decides whether a new raw input means an existing
/// task or subtask in the recent schedule context is now completed.
class TaskCompletionAgent {
  static Future<void> run({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String factId,
    required String combinedText,
    required Map<String, dynamic> recentScheduleContext,
  }) async {
    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    final sessionId = 'task_completion_${userId}_${_safeSessionPart(factId)}';
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'factId': factId,
      'scene': 'task_completion',
      'sceneId': factId,
      'agentName': 'task_completion_agent',
    });

    final tools = [
      _buildMarkExistingTaskCompletedTool(userId: userId),
    ];

    final agent = StatefulAgent(
      name: 'task_completion_agent',
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
      systemPrompts: [taskCompletionAgentSystemPrompt],
      disableSubAgents: true,
      controller: controller,
      withGeneralPrinciples: true,
      planMode: PlanMode.none,
      systemCallback: createSystemCallback(userId),
      autoSaveStateFunc: (state) async {
        await saveAgentState(state);
      },
    );

    final messages = [
      UserMessage([
        TextPart(
          'Decide whether this raw input means an existing task or subtask '
          'is now completed. If the match is unambiguous, call '
          '`mark_existing_task_completed`; otherwise stop without doing '
          'anything.\n\n'
          'Raw Input ID (fact_id): $factId\n\n'
          'Raw Input Content:\n$combinedText\n\n'
          '<recent_schedule_context>\n${jsonEncode(recentScheduleContext)}\n'
          '</recent_schedule_context>',
        ),
      ]),
    ];

    try {
      await agent.run(messages, useStream: false);
      _logger.info('TaskCompletionAgent run completed, sessionId:$sessionId');
    } on AgentException catch (e) {
      _logger.warning(
        'TaskCompletionAgent finished with agent exception (${e.code}) for '
        'fact_id=$factId, sessionId=$sessionId',
        e,
      );
      rethrow;
    } finally {
      try {
        await deleteAgentState(userId, sessionId);
      } catch (_) {
        // best effort cleanup
      }
    }
  }
}

Tool _buildMarkExistingTaskCompletedTool({required String userId}) {
  return Tool(
    name: 'mark_existing_task_completed',
    description:
        'Mark an existing todo/task card or one exact subtask as completed. '
        'Use only when the user explicitly says it is done and the target '
        'matches a card in recent_schedule_context.',
    parameters: {
      'type': 'object',
      'properties': {
        'card_id': {
          'type': 'string',
          'description': 'Existing task card ID from recent_schedule_context.',
        },
        'subtask_title': {
          'type': 'string',
          'description':
              'Exact subtask title from recent_schedule_context when only '
                  'one subtask was completed. Omit to complete the whole task.',
        },
        'reason': {
          'type': 'string',
          'description': 'Short user-facing reason.',
        },
        'confidence': {
          'type': 'number',
          'description': 'Confidence from 0 to 1.',
        },
      },
      'required': ['card_id', 'reason'],
    },
    executable: (
      String cardId,
      String? subtaskTitle,
      String reason,
      num? confidence,
    ) async {
      final updated = await markExistingScheduleTaskCompleted(
        userId: userId,
        cardId: cardId,
        subtaskTitle: subtaskTitle,
      );
      if (!updated) {
        throw StateError('Failed to update existing task $cardId');
      }
      await ScheduleRefreshStateService.instance.markDirty(
        userId: userId,
        reason: reason,
        cardIds: [cardId],
      );
      return 'Marked existing task completed: $cardId';
    },
  );
}

/// Update an existing task card or one of its subtasks to completed.
///
/// Returns true if the card was actually updated. Throws StateError when the
/// card is not a task card, the subtask cannot be located, or the update
/// did not produce a writable card.
Future<bool> markExistingScheduleTaskCompleted({
  required String userId,
  required String cardId,
  String? subtaskTitle,
}) async {
  final fileSystem = FileSystemService.instance;
  final trimmedSubtaskTitle = subtaskTitle?.trim();
  var didUpdate = false;

  final updatedCard = await fileSystem.updateCardFile(userId, cardId, (card) {
    final taskIndex = card.uiConfigs.indexWhere(
      (config) => config.templateId == 'task',
    );
    if (taskIndex < 0) {
      throw StateError('No task ui_config found for $cardId');
    }

    final config = card.uiConfigs[taskIndex];
    final data = Map<String, dynamic>.from(config.data);
    final rawSubtasks = data['subtasks'];

    if (rawSubtasks is List && rawSubtasks.isNotEmpty) {
      final subtasks = _normalizeTaskSubtasks(rawSubtasks);
      if (subtasks.isEmpty) {
        throw StateError('Malformed subtasks for $cardId');
      }

      if (trimmedSubtaskTitle == null || trimmedSubtaskTitle.isEmpty) {
        data['subtasks'] = _setSubtasksCompleted(subtasks);
        data['is_completed'] = true;
      } else {
        final index = _findSubtaskIndex(subtasks, trimmedSubtaskTitle);
        if (index < 0) {
          throw StateError(
            'No matching subtask "$trimmedSubtaskTitle" found for $cardId',
          );
        }
        subtasks[index] = {...subtasks[index], 'completed': true};
        data['subtasks'] = subtasks;
        data['is_completed'] = subtasks.every(
          (subtask) => _parseTaskCompleted(subtask['completed']),
        );
      }
    } else {
      data['is_completed'] = true;
    }

    final updatedConfigs = card.uiConfigs.toList();
    updatedConfigs[taskIndex] = UiConfig(
      templateId: config.templateId,
      data: data,
    );
    didUpdate = true;
    return card.copyWith(uiConfigs: updatedConfigs);
  });

  return didUpdate && updatedCard != null;
}

List<Map<String, dynamic>> _normalizeTaskSubtasks(List<dynamic> rawSubtasks) {
  return rawSubtasks
      .whereType<Map>()
      .map((subtask) => Map<String, dynamic>.from(subtask))
      .where(
        (subtask) => (subtask['title']?.toString().trim() ?? '').isNotEmpty,
      )
      .toList();
}

List<Map<String, dynamic>> _setSubtasksCompleted(
  List<Map<String, dynamic>> subtasks,
) {
  return subtasks.map((subtask) => {...subtask, 'completed': true}).toList();
}

int _findSubtaskIndex(
  List<Map<String, dynamic>> subtasks,
  String subtaskTitle,
) {
  final target = _normalizeTaskTitle(subtaskTitle);
  return subtasks.indexWhere(
    (subtask) => _normalizeTaskTitle(subtask['title']) == target,
  );
}

String _normalizeTaskTitle(dynamic value) {
  return value?.toString().trim().toLowerCase() ?? '';
}

bool _parseTaskCompleted(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    return switch (value.toLowerCase().trim()) {
      'true' || 'yes' || 'y' || '1' || 'done' || 'completed' => true,
      _ => false,
    };
  }
  return false;
}

String _safeSessionPart(String value) {
  return value.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
}
