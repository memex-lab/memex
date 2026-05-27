import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/schedule_state_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/logger.dart';

final _logger = getLogger('ScheduleStateOnCardChangeHandler');

const Set<String> _taskCompletionUpdateFields = {
  'is_completed',
  'status',
  'completion_count',
  'completed_at',
  'subtasks',
};

Future<void> handleScheduleStateOnCardChanged(
  String userId,
  SystemEvent<DataChangeRecord> event,
) async {
  final record = event.payload;
  if (record.ns != DataChangeNs.card) return;
  if (ScheduleStateService.instance.isCardCompletionSyncSuppressed(
    userId: userId,
    factId: record.documentKey,
  )) {
    return;
  }

  try {
    final before = _cardFromJson(record.before);
    final after = _cardFromJson(record.after);
    if (!_didTaskBecomeCompleted(before: before, after: after)) return;

    final updated =
        await ScheduleStateService.instance.completeTodosForSourceFact(
      userId: userId,
      factId: record.documentKey,
      now: event.createdAt,
    );
    EventBusService.instance.emitEvent(
      ScheduleAggregationUpdatedMessage(aggregationId: 'schedule_state'),
    );
    _logger.fine(
      'schedule_state task completion synced for ${record.documentKey}: '
      'pending=${updated.pending.length}, completed=${updated.completed.length}',
    );
  } catch (e, st) {
    _logger.warning(
      'Failed to sync schedule_state task completion for ${record.documentKey}',
      e,
      st,
    );
  }
}

CardData? _cardFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return CardData.fromJson(json);
}

Future<void> handleScheduleStateOnCardUiConfigUpdated(
  String userId,
  SystemEvent<CardUiConfigUpdatedPayload> event,
) async {
  final payload = event.payload;
  if (!_shouldSyncTaskCompletionForCardUiConfigUpdate(payload)) {
    return;
  }
  if (ScheduleStateService.instance.isCardCompletionSyncSuppressed(
    userId: userId,
    factId: payload.cardId,
  )) {
    return;
  }

  try {
    final updated =
        await ScheduleStateService.instance.completeTodosForSourceFact(
      userId: userId,
      factId: payload.cardId,
      now: event.createdAt,
    );
    EventBusService.instance.emitEvent(
      ScheduleAggregationUpdatedMessage(aggregationId: 'schedule_state'),
    );
    _logger.fine(
      'schedule_state task completion synced for ui_config update ${payload.cardId}: '
      'pending=${updated.pending.length}, completed=${updated.completed.length}',
    );
  } catch (e, st) {
    _logger.warning(
      'Failed to sync schedule_state task completion for ui_config update ${payload.cardId}',
      e,
      st,
    );
  }
}

bool _shouldSyncTaskCompletionForCardUiConfigUpdate(
  CardUiConfigUpdatedPayload payload,
) {
  if (payload.templateId != 'task') {
    return false;
  }

  final changedKeys = payload.updates.keys.where((key) {
    if (!_taskCompletionUpdateFields.contains(key)) {
      return false;
    }
    return payload.previousData[key] != payload.updatedData[key];
  });

  if (changedKeys.isEmpty) return false;
  return !_isTaskDataCompleted(payload.previousData) &&
      _isTaskDataCompleted(payload.updatedData);
}

bool _didTaskBecomeCompleted({CardData? before, CardData? after}) {
  if (after == null || after.deleted == true) return false;
  final beforeTaskData = _taskData(before);
  final afterTaskData = _taskData(after);
  if (afterTaskData == null) return false;
  return !_isTaskDataCompleted(beforeTaskData) &&
      _isTaskDataCompleted(afterTaskData);
}

Map<String, dynamic>? _taskData(CardData? card) {
  if (card == null) return null;
  for (final config in card.uiConfigs) {
    if (config.templateId == 'task') {
      return config.data;
    }
  }
  return null;
}

bool _isTaskDataCompleted(Map<String, dynamic>? data) {
  if (data == null) return false;
  final explicit = _parseBool(data['is_completed']);
  if (explicit) return true;
  final status = data['status']?.toString().toLowerCase();
  if (status == 'completed' || status == 'done') return true;
  final subtasks = data['subtasks'];
  if (subtasks is List && subtasks.isNotEmpty) {
    final normalized = subtasks.whereType<Map>().toList();
    return normalized.isNotEmpty &&
        normalized.every((subtask) => _parseBool(subtask['completed']));
  }
  return false;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'done' ||
        normalized == 'completed';
  }
  return false;
}
