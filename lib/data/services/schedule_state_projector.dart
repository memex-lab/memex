import 'package:memex/domain/models/schedule_state.dart';

/// Move pending events whose end has passed into the completed list. Pure.
ScheduleState sweepPastEventsInState(
  ScheduleState state, {
  required DateTime now,
}) {
  final stillPending = <SchedulePendingItem>[];
  final newlyCompleted = <ScheduleCompletedItem>[];

  for (final item in state.pending) {
    final pastAfter = item.pastAfter;
    if (item.isEvent && pastAfter != null && !now.isBefore(pastAfter)) {
      newlyCompleted.add(
        ScheduleCompletedItem(
          id: item.id,
          kind: item.kind,
          title: item.title,
          closedAt: pastAfter,
          pendingSnapshot: item.copyWith(clearDeviceActionId: true),
          sourceFactIds: item.sourceFactIds,
        ),
      );
    } else {
      stillPending.add(item);
    }
  }

  if (newlyCompleted.isEmpty) return state;

  final completed = [...state.completed, ...newlyCompleted]
    ..sort((a, b) => b.closedAt.compareTo(a.closedAt));

  return state.copyWith(
    generatedAt: now,
    pending: stillPending,
    completed: completed,
  );
}
