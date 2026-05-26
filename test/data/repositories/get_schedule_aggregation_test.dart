import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/get_schedule_aggregation.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _userId = 'schedule_aggregation_test_user';
const _cardId = '2026/05/23.md#ts_1';

void main() {
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser(_userId);
    await UserStorage.setLocale(const Locale('en'));
    tempDir = await Directory.systemTemp.createTemp(
      'memex_get_schedule_aggregation_',
    );
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('hydrates timeline task status from the live card file', () async {
    await _writeAggregation(
      timelineItems: [
        {
          'card_id': _cardId,
          'title': 'Visa checklist',
          'type': 'task',
          'status': 'pending',
          'subtasks': [
            {'title': 'Collect documents', 'completed': false},
            {'title': 'Submit form', 'completed': false},
          ],
        },
      ],
    );
    await _writeTaskCard(
      isCompleted: true,
      subtasks: const [
        {'title': 'Collect documents', 'completed': false},
        {'title': 'Submit form', 'completed': false},
      ],
    );

    final aggregation = await getScheduleAggregation();
    final item = aggregation!.timeline.single.items.single;

    expect(item.status, 'completed');
    expect(item.subtasks.map((subtask) => subtask.completed), [true, true]);
  });

  test(
    'removes stale completed task entries when the source card is pending',
    () async {
      await _writeAggregation(
        completedItems: [
          {'card_id': _cardId, 'title': 'Visa checklist'},
        ],
      );
      await _writeTaskCard(isCompleted: false);

      final aggregation = await getScheduleAggregation();

      expect(aggregation!.completed, isEmpty);
    },
  );

  test(
      'filters expired floating non-task items when reading latest aggregation',
      () async {
    await _writeAggregation(
      aggregationId: 'schedule_agg_2020_01_01',
      generatedAt: '2020-01-01T09:00:00',
      dayLabel: '待安排',
      dayDate: '',
      timelineItems: [
        {
          'card_id': 'procedure-1',
          'title': '沙球转体转髋训练要点',
          'type': 'procedure',
          'status': 'pending',
        },
      ],
    );
    await _writeAggregation(
      aggregationId: 'schedule_agg_2020_01_10',
      generatedAt: '2020-01-10T09:00:00',
      dayLabel: '待安排',
      dayDate: '',
      timelineItems: [
        {
          'card_id': 'procedure-1',
          'title': '沙球转体转髋训练要点',
          'type': 'procedure',
          'status': 'pending',
        },
        {
          'card_id': 'task-1',
          'title': '无日期待办仍保留',
          'type': 'task',
          'status': 'pending',
        },
      ],
    );

    final aggregation = await getScheduleAggregation();

    expect(
      aggregation!.timeline
          .expand((day) => day.items)
          .map((item) => item.title),
      ['无日期待办仍保留'],
    );
  });
}

Future<void> _writeAggregation({
  String aggregationId = 'schedule_agg_test',
  String generatedAt = '2026-05-23T09:00:00',
  String dayLabel = 'Today',
  String dayDate = '2026-05-23',
  List<Map<String, dynamic>> timelineItems = const [],
  List<Map<String, dynamic>> completedItems = const [],
}) {
  return FileSystemService.instance.writeScheduleAggregation(
    _userId,
    aggregationId,
    {
      'id': aggregationId,
      'generated_at': generatedAt,
      'version': 1,
      'time_range': {'from': '2026-05-23', 'to': '2026-05-30'},
      'timeline': [
        if (timelineItems.isNotEmpty)
          {
            'day_label': dayLabel,
            'day_date': dayDate,
            'items': timelineItems,
          },
      ],
      'completed': completedItems,
      'conflicts': [],
    },
  );
}

Future<void> _writeTaskCard({
  required bool isCompleted,
  List<Map<String, dynamic>> subtasks = const [],
}) {
  return FileSystemService.instance.safeWriteCardFile(
    _userId,
    _cardId,
    CardData(
      factId: _cardId,
      timestamp: DateTime(2026, 5, 23, 9).millisecondsSinceEpoch ~/ 1000,
      status: 'completed',
      tags: const [],
      title: 'Visa checklist',
      uiConfigs: [
        UiConfig(
          templateId: 'task',
          data: {
            'title': 'Visa checklist',
            'is_completed': isCompleted,
            if (subtasks.isNotEmpty) 'subtasks': subtasks,
          },
        ),
      ],
    ),
  );
}
