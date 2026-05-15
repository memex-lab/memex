import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('ScheduleDirtyOnCardUpdateHandler');

const Set<String> _scheduleSensitiveUpdateFields = {
  'is_completed',
  'status',
  'due_date',
  'due_time',
  'start_date',
  'start_time',
  'end_date',
  'end_time',
  'date',
  'time',
  'scheduled_at',
  'deadline',
  'duration',
  'completion_count',
  'completed_at',
  'steps',
  'subtasks',
};

Future<void> handleScheduleDirtyOnCardUiConfigUpdated(
  String userId,
  SystemEvent<CardUiConfigUpdatedPayload> event,
) async {
  final payload = event.payload;
  if (!shouldMarkScheduleDirtyForCardUiConfigUpdate(payload)) {
    return;
  }

  try {
    await ScheduleRefreshStateService.instance.markDirty(
      userId: userId,
      reason: UserStorage.l10n.scheduleAggregationDirtyReason,
      cardIds: [payload.cardId],
    );
  } catch (e, st) {
    _logger.warning(
      'Failed to mark schedule dirty for ${payload.cardId}',
      e,
      st,
    );
  }
}

bool shouldMarkScheduleDirtyForCardUiConfigUpdate(
  CardUiConfigUpdatedPayload payload,
) {
  if (!scheduleTemporalTemplateIds.contains(payload.templateId)) {
    return false;
  }

  final changedKeys = payload.updates.keys.where((key) {
    if (!_scheduleSensitiveUpdateFields.contains(key)) {
      return false;
    }
    return payload.previousData[key] != payload.updatedData[key];
  });

  return changedKeys.isNotEmpty;
}
