import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('GetScheduleAggregation');

/// Get the latest schedule aggregation for the current user
Future<ScheduleAggregationModel?> getScheduleAggregation() async {
  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      _logger.warning('No user ID found, cannot get schedule aggregation');
      return null;
    }

    final fileSystem = FileSystemService.instance;
    final latest = await fileSystem.getLatestScheduleAggregation(userId);
    if (latest == null) {
      _logger.info('No schedule aggregation found for user $userId');
      return null;
    }

    final hydrated = await _hydrateLiveTaskState(
      fileSystem: fileSystem,
      userId: userId,
      aggregation: latest,
    );
    return ScheduleAggregationModel.fromYaml(hydrated);
  } catch (e) {
    _logger.severe('Failed to get schedule aggregation: $e');
    return null;
  }
}

/// Check if schedule aggregation needs refresh (older than given duration)
Future<bool> scheduleAggregationNeedsRefresh({Duration? maxAge}) async {
  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) return true;

    final fileSystem = FileSystemService.instance;
    final latest = await fileSystem.getLatestScheduleAggregation(userId);
    if (latest == null) return true;

    final generatedAt = DateTime.tryParse(latest['generated_at'] ?? '');
    if (generatedAt == null) return true;

    final age = DateTime.now().difference(generatedAt);
    return age > (maxAge ?? const Duration(minutes: 30));
  } catch (e) {
    _logger.warning('Failed to check schedule aggregation freshness: $e');
    return true;
  }
}

Future<Map<String, dynamic>> _hydrateLiveTaskState({
  required FileSystemService fileSystem,
  required String userId,
  required Map<String, dynamic> aggregation,
}) async {
  final cardIds = _collectScheduleCardIds(aggregation);
  if (cardIds.isEmpty) return aggregation;

  final states = <String, _LiveTaskState>{};
  for (final cardId in cardIds) {
    final card = await fileSystem.readCardFile(userId, cardId);
    final state = _LiveTaskState.fromCard(card);
    if (state != null) {
      states[cardId] = state;
    }
  }
  if (states.isEmpty) return aggregation;

  final hydrated = Map<String, dynamic>.from(aggregation);
  final timeline = hydrated['timeline'];
  if (timeline is List) {
    hydrated['timeline'] = timeline.map((dayValue) {
      if (dayValue is! Map) return dayValue;
      final day = Map<String, dynamic>.from(dayValue);
      final items = day['items'];
      if (items is List) {
        day['items'] = items.map((itemValue) {
          if (itemValue is! Map) return itemValue;
          final item = Map<String, dynamic>.from(itemValue);
          if (!_isTaskTimelineItem(item)) return item;
          final state = states[_readCardId(item)];
          if (state == null) return item;
          return _hydrateTimelineTaskItem(item, state);
        }).toList();
      }
      return day;
    }).toList();
  }

  final completed = hydrated['completed'];
  if (completed is List) {
    hydrated['completed'] = completed.where((itemValue) {
      if (itemValue is! Map) return true;
      final state = states[_readCardId(Map<String, dynamic>.from(itemValue))];
      return state == null || state.isCompleted;
    }).toList();
  }

  return hydrated;
}

Set<String> _collectScheduleCardIds(Map<String, dynamic> aggregation) {
  final cardIds = <String>{};
  final timeline = aggregation['timeline'];
  if (timeline is List) {
    for (final dayValue in timeline) {
      if (dayValue is! Map) continue;
      final items = dayValue['items'];
      if (items is! List) continue;
      for (final itemValue in items) {
        if (itemValue is! Map) continue;
        final cardId = _readCardId(Map<String, dynamic>.from(itemValue));
        if (cardId.isNotEmpty) cardIds.add(cardId);
      }
    }
  }

  final completed = aggregation['completed'];
  if (completed is List) {
    for (final itemValue in completed) {
      if (itemValue is! Map) continue;
      final cardId = _readCardId(Map<String, dynamic>.from(itemValue));
      if (cardId.isNotEmpty) cardIds.add(cardId);
    }
  }
  return cardIds;
}

Map<String, dynamic> _hydrateTimelineTaskItem(
  Map<String, dynamic> item,
  _LiveTaskState state,
) {
  return {
    ...item,
    'type': 'task',
    'status': state.status,
    if (state.subtasks.isNotEmpty) 'subtasks': state.subtasks,
    if (state.subtasks.isEmpty) 'subtasks': null,
  }..removeWhere((key, value) => key == 'subtasks' && value == null);
}

String _readCardId(Map<String, dynamic> value) {
  return (value['card_id'] ?? value['id'] ?? '').toString();
}

bool _isTaskTimelineItem(Map<String, dynamic> item) {
  final type = item['type']?.toString().toLowerCase().trim();
  return type == 'task' || type == 'todo';
}

class _LiveTaskState {
  _LiveTaskState({required this.isCompleted, required this.subtasks});

  final bool isCompleted;
  final List<Map<String, dynamic>> subtasks;

  String get status {
    if (isCompleted) return 'completed';
    if (subtasks.any((subtask) => _parseTaskBool(subtask['completed']))) {
      return 'in_progress';
    }
    return 'pending';
  }

  static _LiveTaskState? fromCard(CardData? card) {
    if (card == null) return null;
    UiConfig? taskConfig;
    for (final config in card.uiConfigs) {
      if (config.templateId == 'task') {
        taskConfig = config;
        break;
      }
    }
    if (taskConfig == null) return null;

    final data = taskConfig.data;
    final normalizedSubtasks = _normalizeSubtasks(data['subtasks']);
    final explicitCompleted = _parseTaskBool(data['is_completed']);
    final subtasksCompleted =
        normalizedSubtasks.isNotEmpty &&
        normalizedSubtasks.every(
          (subtask) => _parseTaskBool(subtask['completed']),
        );
    final isCompleted = explicitCompleted || subtasksCompleted;

    return _LiveTaskState(
      isCompleted: isCompleted,
      subtasks: isCompleted
          ? normalizedSubtasks
                .map((subtask) => {...subtask, 'completed': true})
                .toList()
          : normalizedSubtasks,
    );
  }
}

List<Map<String, dynamic>> _normalizeSubtasks(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((subtask) => Map<String, dynamic>.from(subtask))
      .where(
        (subtask) => (subtask['title']?.toString().trim() ?? '').isNotEmpty,
      )
      .toList();
}

bool _parseTaskBool(dynamic value) {
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
