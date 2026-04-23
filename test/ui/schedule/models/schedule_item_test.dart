import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/schedule/models/schedule_item.dart';

void main() {
  group('ScheduleItem', () {
    test('copyWith creates a new instance with updated fields', () {
      final item = ScheduleItem(
        id: 'test-1',
        title: 'Original Title',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 2,
      );

      final updated = item.copyWith(
        status: ScheduleItemStatus.completed,
        completedAt: DateTime(2026, 4, 23, 10, 30),
      );

      expect(updated.id, 'test-1');
      expect(updated.title, 'Original Title');
      expect(updated.status, ScheduleItemStatus.completed);
      expect(updated.completedAt, isNotNull);
      expect(updated.priority, 2);
      // Original should be unchanged
      expect(item.status, ScheduleItemStatus.pending);
    });

    test('copyWith preserves values when null is passed', () {
      final item = ScheduleItem(
        id: 'test-1',
        title: 'Title',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
      );

      final updated = item.copyWith();

      expect(updated.id, 'test-1');
      expect(updated.status, ScheduleItemStatus.pending);
      expect(updated.type, ScheduleItemType.event);
    });

    test('event item has correct defaults', () {
      final event = ScheduleItem(
        id: 'event-1',
        title: 'Meeting',
        type: ScheduleItemType.event,
        startTime: DateTime(2026, 4, 23, 14, 0),
        endTime: DateTime(2026, 4, 23, 15, 0),
      );

      expect(event.status, ScheduleItemStatus.pending);
      expect(event.tags, isEmpty);
      expect(event.relatedEvents, isEmpty);
    });
  });

  group('ScheduleItemStatus', () {
    test('has correct enum values', () {
      expect(ScheduleItemStatus.values.length, 4);
      expect(ScheduleItemStatus.pending.name, 'pending');
      expect(ScheduleItemStatus.completed.name, 'completed');
      expect(ScheduleItemStatus.inProgress.name, 'inProgress');
      expect(ScheduleItemStatus.overdue.name, 'overdue');
    });
  });

  group('RelatedEvent', () {
    test('stores all fields correctly', () {
      final related = RelatedEvent(
        id: 're-1',
        title: 'Created card',
        type: 'card',
        timestamp: DateTime(2026, 4, 23, 10, 0),
      );

      expect(related.id, 're-1');
      expect(related.title, 'Created card');
      expect(related.type, 'card');
      expect(related.timestamp.hour, 10);
    });
  });
}
