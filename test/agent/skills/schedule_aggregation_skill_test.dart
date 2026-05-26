import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';

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

    test('uses task completion fields to mark schedule tasks completed', () {
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

    test('derives grouped task status from subtasks', () {
      expect(
        deriveScheduleCardStatus(
          'task',
          <String, dynamic>{
            'subtasks': [
              {'title': 'A', 'completed': true},
              {'title': 'B', 'completed': true},
            ],
          },
        ),
        'completed',
      );
      expect(
        deriveScheduleCardStatus(
          'task',
          <String, dynamic>{
            'subtasks': [
              {'title': 'A', 'completed': true},
              {'title': 'B', 'completed': false},
            ],
          },
        ),
        'in_progress',
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

  group('queryScheduleCardsForRange', () {
    late Directory tempRoot;
    late AppDatabase db;
    const userId = 'schedule_skill_user';

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp(
        'memex_schedule_skill_',
      );
      await FileSystemService.init(tempRoot.path);
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      await db.searchDao.createFtsTables();
    });

    tearDown(() async {
      await db.close();
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('includes visible system actions and excludes rejected actions',
        () async {
      await _writeTemporalCard(
        userId: userId,
        factId: '2026/05/25.md#ts_7',
        title: '排查小白院日程问题',
        templateId: 'task',
        data: const {'is_completed': false},
      );

      await SystemActionService.instance.createAction(
        id: 'action-party',
        type: 'calendar',
        factId: '2026/05/25.md#ts_7',
        data: const {
          'title': '天津小白院领证Party调研',
          'start_time': '2026-06-06 09:00:00',
          'location': '天津',
        },
      );
      await SystemActionService.instance.createAction(
        id: 'action-reminder',
        type: 'reminder',
        factId: '2026/05/25.md#ts_7',
        data: const {
          'title': '确认小白院预约',
          'due_date': '2026-06-07 12:00:00',
        },
      );
      await SystemActionService.instance.updateActionStatus(
        'action-reminder',
        'dismissed',
      );
      await SystemActionService.instance.createAction(
        id: 'action-rejected',
        type: 'calendar',
        factId: '2026/05/25.md#ts_7',
        data: const {
          'title': '旧的小白院日程',
          'start_time': '2026-06-08 09:00:00',
        },
      );
      await SystemActionService.instance.updateActionStatus(
        'action-rejected',
        'rejected',
      );

      final result = await queryScheduleCardsForRange(
        userId: userId,
        from: DateTime(2026, 5, 22),
        to: DateTime(2026, 6, 24, 23, 59),
      );
      final cards = (result['cards'] as List).cast<Map<String, dynamic>>();
      final ids = cards.map((card) => card['card_id']).toList();

      expect(ids, contains('system_action:action-party'));
      expect(ids, contains('system_action:action-reminder'));
      expect(ids, isNot(contains('system_action:action-rejected')));

      final party = cards.firstWhere(
        (card) => card['card_id'] == 'system_action:action-party',
      );
      expect(party['source'], 'system_action');
      expect(party['source_fact_id'], '2026/05/25.md#ts_7');
      expect(party['action_status'], 'pending');
      expect(party['date_source'], 'system_action_start_time');

      final undatedTask = cards.firstWhere(
        (card) => card['card_id'] == '2026/05/25.md#ts_7',
      );
      expect(undatedTask['date_source'], 'created_at_fallback');
      expect(undatedTask['is_unscheduled'], isTrue);
    });

    test('deduplicates a system action matching an existing schedule card',
        () async {
      await _writeTemporalCard(
        userId: userId,
        factId: '2026/05/20.md#ts_5',
        title: '天津小白院领证Party调研',
        templateId: 'event',
        data: const {
          'start_time': '2026-06-06 09:00:00',
          'location': '天津',
        },
      );
      await SystemActionService.instance.createAction(
        id: 'action-duplicate',
        type: 'calendar',
        factId: '2026/05/20.md#ts_5',
        data: const {
          'title': '天津小白院领证Party调研',
          'start_time': '2026-06-06 09:00:00',
          'location': '天津',
        },
      );

      final result = await queryScheduleCardsForRange(
        userId: userId,
        from: DateTime(2026, 5, 22),
        to: DateTime(2026, 6, 24, 23, 59),
      );
      final cards = (result['cards'] as List).cast<Map<String, dynamic>>();
      final matchingTitle =
          cards.where((card) => card['title'] == '天津小白院领证Party调研').toList();

      expect(matchingTitle, hasLength(1));
      expect(
        cards.map((card) => card['card_id']),
        isNot(contains('system_action:action-duplicate')),
      );
    });
  });

  group('normalizeScheduleAggregationForCards', () {
    late Directory tempRoot;
    late AppDatabase db;
    const userId = 'schedule_normalize_user';

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp(
        'memex_schedule_normalize_',
      );
      await FileSystemService.init(tempRoot.path);
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      await db.searchDao.createFtsTables();
    });

    tearDown(() async {
      await db.close();
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('moves undated task items to 待安排 and keeps dated tasks in place',
        () async {
      await _writeTemporalCard(
        userId: userId,
        factId: '2026/05/25.md#ts_7',
        title: '排查小白院日程问题',
        templateId: 'task',
        data: const {'is_completed': false},
      );
      await _writeTemporalCard(
        userId: userId,
        factId: '2026/05/25.md#ts_8',
        title: '6月6日前确认小白院',
        templateId: 'task',
        data: const {
          'due_date': '2026-06-06 18:00:00',
          'is_completed': false,
        },
      );

      final normalized = await normalizeScheduleAggregationForCards(
        userId: userId,
        yamlData: {
          'id': 'schedule_agg_2026_05_25',
          'generated_at': DateTime(2026, 5, 25, 9),
          'timeline': [
            {
              'day_label': '今天',
              'day_date': '2026-05-25',
              'items': [
                {
                  'card_id': '2026/05/25.md#ts_7',
                  'title': '排查小白院日程问题',
                  'type': 'task',
                  'status': 'pending',
                },
                {
                  'card_id': '2026/05/25.md#ts_8',
                  'title': '6月6日前确认小白院',
                  'type': 'task',
                  'status': 'pending',
                },
              ],
            },
          ],
        },
      );

      final timeline =
          (normalized['timeline'] as List).cast<Map<String, dynamic>>();
      final datedDay = timeline.firstWhere(
        (day) => day['day_date'] == '2026-05-25',
      );
      expect(
        (datedDay['items'] as List).map((item) => item['card_id']),
        ['2026/05/25.md#ts_8'],
      );

      final unscheduled = timeline.firstWhere(
        (day) => day['day_label'] == '待安排',
      );
      expect(unscheduled['day_date'], '');
      expect(
        (unscheduled['items'] as List).map((item) => item['card_id']),
        ['2026/05/25.md#ts_7'],
      );
      expect(normalized['generated_at'], DateTime(2026, 5, 25, 9));
    });
  });
}

Future<void> _writeTemporalCard({
  required String userId,
  required String factId,
  required String title,
  required String templateId,
  required Map<String, dynamic> data,
}) async {
  final timestamp = _timestampFromFactId(factId);
  final success = await FileSystemService.instance.safeWriteCardFile(
    userId,
    factId,
    CardData(
      factId: factId,
      title: title,
      timestamp: timestamp,
      status: 'completed',
      tags: const ['schedule'],
      uiConfigs: [
        UiConfig(templateId: templateId, data: data),
      ],
    ),
  );
  expect(success, isTrue);
}

int _timestampFromFactId(String factId) {
  final match =
      RegExp(r'^(\d{4})/(\d{2})/(\d{2})\.md#ts_\d+$').firstMatch(factId);
  if (match == null) return 0;
  return DateTime.utc(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      ).millisecondsSinceEpoch ~/
      1000;
}
