import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:memex/agent/schedule_aggregator_agent/schedule_aggregation_run_context.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:test/test.dart';

void main() {
  group('buildScheduleAggregationRunContext', () {
    late Directory tempRoot;
    late AppDatabase db;
    const userId = 'schedule_context_user';

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp(
        'memex_schedule_context_',
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

    test('summarizes durable schedule sources for a fresh run', () async {
      final fileSystem = FileSystemService.instance;
      await fileSystem.safeWriteCardFile(
        userId,
        '2026/05/18.md#ts_1',
        CardData(
          factId: '2026/05/18.md#ts_1',
          title: 'Passport appointment',
          timestamp:
              DateTime.utc(2026, 5, 18, 9).millisecondsSinceEpoch ~/ 1000,
          status: 'completed',
          tags: const ['schedule'],
          uiConfigs: const [
            UiConfig(
              templateId: 'event',
              data: {
                'start_time': '2026-05-18T09:00:00Z',
                'end_time': '2026-05-18T10:00:00Z',
                'location': 'Service center',
              },
            ),
          ],
        ),
      );
      await fileSystem.safeWriteCardFile(
        userId,
        '2026/05/19.md#ts_2',
        CardData(
          factId: '2026/05/19.md#ts_2',
          title: 'Prepare documents',
          timestamp:
              DateTime.utc(2026, 5, 19, 12).millisecondsSinceEpoch ~/ 1000,
          status: 'completed',
          tags: const ['todo'],
          uiConfigs: const [
            UiConfig(
              templateId: 'task',
              data: {
                'due_date': '2026-05-19T18:00:00Z',
                'priority': 3,
                'is_completed': false,
              },
            ),
          ],
        ),
      );
      await fileSystem.safeWriteCardFile(
        userId,
        '2026/06/30.md#ts_3',
        CardData(
          factId: '2026/06/30.md#ts_3',
          title: 'Outside current range',
          timestamp: DateTime.utc(2026, 6, 30).millisecondsSinceEpoch ~/ 1000,
          status: 'completed',
          tags: const [],
          uiConfigs: const [
            UiConfig(
              templateId: 'event',
              data: {'start_time': '2026-06-30T08:00:00Z'},
            ),
          ],
        ),
      );

      await fileSystem.writeScheduleAggregation(
        userId,
        'schedule_agg_2026_05_17',
        {
          'id': 'schedule_agg_2026_05_17',
          'generated_at': '2026-05-17T08:00:00Z',
          'time_range': {
            'from': '2026-05-17T00:00:00Z',
            'to': '2026-05-24T00:00:00Z',
          },
          'hero_item': {
            'card_id': '2026/05/18.md#ts_1',
            'title': 'Passport appointment',
            'start_time': '2026-05-18T09:00:00Z',
          },
          'editorial_intro': 'Keep documents ready before the appointment.',
          'conflicts': [
            {'description': 'Document prep is close to the appointment.'},
          ],
          'completed': [
            {'card_id': 'done-1', 'title': 'Book appointment'},
          ],
          'timeline': [
            {
              'day_label': 'Monday',
              'day_date': '2026-05-18',
              'items': [
                {'card_id': '2026/05/18.md#ts_1'},
                {'card_id': '2026/05/19.md#ts_2'},
              ],
            },
          ],
        },
      );
      await ScheduleRefreshStateService.instance.markDirty(
        userId: userId,
        reason: 'new schedule card',
        cardIds: const ['2026/05/19.md#ts_2'],
        refreshRequested: true,
      );

      final context = await buildScheduleAggregationRunContext(
        userId: userId,
        runId: 'task_123',
        now: DateTime.utc(2026, 5, 17, 12),
        scheduleCardLimit: 10,
      );

      final payload = _decodeContextPayload(context);
      final sources = payload['durable_sources'] as Map<String, dynamic>;
      final cards = sources['schedule_cards'] as Map<String, dynamic>;
      final latest =
          sources['latest_schedule_aggregation'] as Map<String, dynamic>;
      final refreshState = sources['refresh_state'] as Map<String, dynamic>;

      expect(payload['run_id'], 'task_123');
      expect(payload['fresh_execution_state'], isTrue);
      expect((cards['cards'] as List), hasLength(2));
      expect(
        (cards['cards'] as List).map((card) => card['card_id']),
        containsAll(['2026/05/18.md#ts_1', '2026/05/19.md#ts_2']),
      );
      expect(
        (cards['cards'] as List).map((card) => card['card_id']),
        isNot(contains('2026/06/30.md#ts_3')),
      );
      expect(latest['id'], 'schedule_agg_2026_05_17');
      expect(latest['conflict_count'], 1);
      expect(latest['completed_count'], 1);
      expect(refreshState['is_dirty'], isTrue);
      expect(refreshState['card_ids'], ['2026/05/19.md#ts_2']);
      expect(
        payload['execution_policy'],
        contains(contains('Do not rely on prior LLM conversation history')),
      );
    });
  });
}

Map<String, dynamic> _decodeContextPayload(String context) {
  const openTag = '<schedule_aggregation_run_context>';
  const closeTag = '</schedule_aggregation_run_context>';
  final start = context.indexOf(openTag);
  final end = context.indexOf(closeTag);
  expect(start, isNot(-1));
  expect(end, greaterThan(start));
  return jsonDecode(context.substring(start + openTag.length, end).trim())
      as Map<String, dynamic>;
}
