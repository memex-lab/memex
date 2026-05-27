import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/schedule_state_projector.dart';
import 'package:memex/domain/models/schedule_state.dart';

const _now = '2026-05-26T12:00:00';
final DateTime _clock = DateTime.parse(_now);

void main() {
  group('sweepPastEventsInState', () {
    test('moves now-past pending events into completed', () {
      final state = ScheduleState(
        generatedAt: DateTime.parse('2026-05-26T09:00:00'),
        pending: [
          SchedulePendingItem(
            id: 'future',
            kind: SchedulePendingItem.kindEvent,
            title: 'future',
            startTime: DateTime.parse('2026-05-28T10:00:00'),
            createdAt: _clock,
            updatedAt: _clock,
          ),
          SchedulePendingItem(
            id: 'just-passed',
            kind: SchedulePendingItem.kindEvent,
            title: 'just-passed',
            startTime: DateTime.parse('2026-05-26T10:00:00'),
            endTime: DateTime.parse('2026-05-26T11:00:00'),
            createdAt: _clock,
            updatedAt: _clock,
          ),
        ],
      );

      final swept = sweepPastEventsInState(state, now: _clock);

      expect(swept.pending, hasLength(1));
      expect(swept.pending.single.title, 'future');
      expect(swept.completed, hasLength(1));
      expect(swept.completed.single.title, 'just-passed');
    });

    test('does not auto-complete todos', () {
      final state = ScheduleState(
        generatedAt: _clock,
        pending: [
          SchedulePendingItem(
            id: 'todo',
            kind: SchedulePendingItem.kindTodo,
            title: 'overdue todo',
            dueAt: DateTime.parse('2026-05-25T10:00:00'),
            createdAt: _clock,
            updatedAt: _clock,
          ),
        ],
      );

      final swept = sweepPastEventsInState(state, now: _clock);

      expect(identical(swept, state), isTrue);
    });

    test('returns the same instance when nothing to sweep', () {
      final state = ScheduleState.empty();
      final swept = sweepPastEventsInState(state, now: _clock);
      expect(identical(swept, state), isTrue);
    });
  });
}
