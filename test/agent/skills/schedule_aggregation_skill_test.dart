import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';

void main() {
  group('scheduleStartTimeForCard', () {
    test('uses task due_date when start_time is absent', () {
      expect(
        scheduleStartTimeForCard(
          'task',
          <String, dynamic>{'due_date': '2026-05-15 10:00:00'},
        ),
        '2026-05-15 10:00:00',
      );
    });

    test('keeps explicit task start_time ahead of due_date', () {
      expect(
        scheduleStartTimeForCard(
          'task',
          <String, dynamic>{
            'start_time': '2026-05-15 09:30:00',
            'due_date': '2026-05-15 10:00:00',
          },
        ),
        '2026-05-15 09:30:00',
      );
    });

    test('uses event start_time without rewriting it', () {
      expect(
        scheduleStartTimeForCard(
          'event',
          <String, dynamic>{'start_time': '2026-05-16T14:00:00'},
        ),
        '2026-05-16T14:00:00',
      );
    });

    test('treats blank start_time as missing', () {
      expect(
        scheduleStartTimeForCard(
          'task',
          <String, dynamic>{
            'start_time': ' ',
            'due_date': '2026-05-17 18:00:00',
          },
        ),
        '2026-05-17 18:00:00',
      );
    });
  });

  group('deriveScheduleCardStatus', () {
    test('keeps newly-created task cards pending when is_completed is absent',
        () {
      expect(
        deriveScheduleCardStatus('task', <String, dynamic>{}),
        'pending',
      );
    });

    test('uses only task is_completed to mark schedule tasks completed', () {
      expect(
        deriveScheduleCardStatus(
          'task',
          <String, dynamic>{'is_completed': true},
        ),
        'completed',
      );
      expect(
        deriveScheduleCardStatus(
          'task',
          <String, dynamic>{'is_completed': 'completed'},
        ),
        'completed',
      );
      expect(
        deriveScheduleCardStatus(
          'task',
          <String, dynamic>{'is_completed': 'false'},
        ),
        'pending',
      );
      expect(
        deriveScheduleCardStatus(
          'task',
          <String, dynamic>{'is_completed': 0},
        ),
        'pending',
      );
    });

    test('does not treat card processing status as task completion', () {
      expect(
        deriveScheduleCardStatus(
          'event',
          <String, dynamic>{'status': 'completed'},
        ),
        'pending',
      );
      expect(
        deriveScheduleCardStatus(
          'task',
          <String, dynamic>{'status': 'completed'},
        ),
        'pending',
      );
    });
  });
}
