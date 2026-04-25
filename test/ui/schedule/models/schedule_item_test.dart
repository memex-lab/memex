import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';
import 'package:memex/ui/schedule/models/schedule_item.dart';
import 'package:yaml/yaml.dart';

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

    test('copyWith can clear completedAt when reopening a task', () {
      final item = ScheduleItem(
        id: 'test-1',
        title: 'Title',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.completed,
        completedAt: DateTime(2026, 4, 26, 10),
      );

      final updated = item.copyWith(
        status: ScheduleItemStatus.pending,
        clearCompletedAt: true,
      );

      expect(updated.status, ScheduleItemStatus.pending);
      expect(updated.completedAt, isNull);
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

    test('builds real UI items from LLM-style aggregation YAML', () {
      final yaml = loadYaml('''
id: schedule_agg_2026_04_26
generated_at: "2026-04-26T08:00:00+08:00"
version: "1"
time_range:
  from: "2026-04-26"
  to: "2026-05-03"
hero_item:
  card_id: "2026/04/26.md#ts_100"
  title: "产品发布会"
  description: "本周最重要的外部日程"
  start_time: "2026-04-26T14:00:00+08:00"
  end_time: "2026-04-26T16:00:00+08:00"
  location: "总部大礼堂"
  priority: high
editorial_intro: "今天重点是发布会和上线检查。"
timeline:
  - day_label: Today
    day_date: "2026-04-26"
    items:
      - card_id: "2026/04/26.md#ts_100"
        title: "产品发布会"
        status: pending
        type: event
        priority: 3
      - card_id: 101
        title: "上线检查清单"
        status: in_progress
        start_time: "2026-04-26T10:00:00+08:00"
        type: task
        priority: normal
completed:
  - card_id: "2026/04/25.md#ts_88"
    title: "完成彩排"
    completed_at: "2026-04-25T19:30:00+08:00"
conflicts:
  - description: "发布会和彩排复盘时间接近"
    item_ids: [2026/04/26.md#ts_100, 42]
''');

      final aggregation = ScheduleAggregationModel.fromYaml(
        _yamlToMap(yaml),
      );
      final items = ScheduleItem.fromAggregation(aggregation);

      expect(items, hasLength(3));

      final launch =
          items.singleWhere((item) => item.id == '2026/04/26.md#ts_100');
      expect(launch.type, ScheduleItemType.event);
      expect(launch.priority, 3);
      expect(launch.location, '总部大礼堂');
      expect(launch.description, '本周最重要的外部日程');

      final checklist = items.singleWhere((item) => item.id == '101');
      expect(checklist.type, ScheduleItemType.todo);
      expect(checklist.status, ScheduleItemStatus.inProgress);
      expect(checklist.priority, 2);

      final rehearsal =
          items.singleWhere((item) => item.id == '2026/04/25.md#ts_88');
      expect(rehearsal.status, ScheduleItemStatus.completed);
      expect(rehearsal.completedAt?.toUtc(), DateTime.utc(2026, 4, 25, 11, 30));
      expect(aggregation.conflicts.single.itemIds, [
        '2026/04/26.md#ts_100',
        '42',
      ]);
    });

    test('keeps timeline task fields when hero points to the same card', () {
      final aggregation = ScheduleAggregationModel.fromYaml(
        _yamlToMap(loadYaml('''
id: schedule_agg_2026_04_26
generated_at: "2026-04-26T08:00:00+08:00"
time_range:
  from: "2026-04-26"
  to: "2026-05-03"
hero_item:
  card_id: "deadline-1"
  title: "融资材料截止"
  description: "今天最需要守住的交付"
  start_time: "2026-04-26T18:00:00+08:00"
  location: "线上提交"
  priority: urgent
timeline:
  - day_label: Today
    day_date: "2026-04-26"
    items:
      - card_id: "deadline-1"
        title: "融资材料截止"
        status: " in-progress "
        type: task
        priority: 2
''')),
      );

      final item = ScheduleItem.fromAggregation(aggregation).single;

      expect(item.type, ScheduleItemType.todo);
      expect(item.status, ScheduleItemStatus.inProgress);
      expect(item.sourceType, 'task');
      expect(item.description, '今天最需要守住的交付');
      expect(item.location, '线上提交');
      expect(item.priority, 3);
    });

    test('completed section wins over duplicate pending timeline items', () {
      final aggregation = ScheduleAggregationModel.fromYaml(
        _yamlToMap(loadYaml('''
id: schedule_agg_2026_04_26
generated_at: "2026-04-26T08:00:00+08:00"
time_range:
  from: "2026-04-26"
  to: "2026-05-03"
timeline:
  - day_label: Today
    day_date: "2026-04-26"
    items:
      - card_id: "task-done"
        title: "同步发布稿"
        status: overdue
        type: task
completed:
  - card_id: "task-done"
    title: "同步发布稿"
    completed_at: "2026-04-26T11:20:00+08:00"
''')),
      );

      final item = ScheduleItem.fromAggregation(aggregation).single;

      expect(item.type, ScheduleItemType.todo);
      expect(item.status, ScheduleItemStatus.completed);
      expect(item.completedAt?.toUtc(), DateTime.utc(2026, 4, 26, 3, 20));
    });

    test('assigns stable fallback ids and sorts undated items by title', () {
      final aggregation = ScheduleAggregationModel(
        id: 'agg_missing_ids',
        generatedAt: DateTime(2026, 4, 26, 8),
        timeRange: TimeRange(
          from: DateTime(2026, 4, 26),
          to: DateTime(2026, 5, 3),
        ),
        timeline: [
          TimelineDay(
            dayLabel: 'Today',
            items: [
              TimelineItem(cardId: '', title: 'B task', type: 'task'),
              TimelineItem(cardId: '', title: 'A event', type: 'event'),
            ],
          ),
        ],
      );

      final items = ScheduleItem.fromAggregation(aggregation);

      expect(items.map((item) => item.id), [
        'schedule_item_1',
        'schedule_item_0',
      ]);
      expect(items.map((item) => item.title), ['A event', 'B task']);
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

Map<String, dynamic> _yamlToMap(dynamic yaml) {
  if (yaml is YamlMap) {
    return {
      for (final entry in yaml.entries)
        entry.key.toString(): _yamlToValue(entry.value),
    };
  }
  return Map<String, dynamic>.from(yaml as Map);
}

dynamic _yamlToValue(dynamic value) {
  if (value is YamlMap) return _yamlToMap(value);
  if (value is YamlList) return value.map(_yamlToValue).toList();
  return value;
}
