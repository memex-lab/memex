import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';

void main() {
  group('ScheduleAggregationModel', () {
    test('parses complete YAML data correctly', () {
      final yaml = {
        'id': 'schedule_agg_2026_04_23',
        'generated_at': '2026-04-23T08:00:00Z',
        'version': 1,
        'time_range': {
          'from': '2026-04-21',
          'to': '2026-04-30',
        },
        'hero_item': {
          'card_id': '2026/04/25.md#ts_1',
          'title': 'Q3 产品发布会',
          'description': '本季度最重要的产品发布会',
          'start_time': '2026-04-25T14:00:00Z',
          'end_time': '2026-04-25T16:00:00Z',
          'location': '总部大礼堂',
          'priority': 3,
        },
        'editorial_intro': '这是一个忙碌的星期',
        'quote_blocks': [
          {
            'title': '截止提醒',
            'content': 'Q3 OKR 提交本周五截止',
            'priority': 'high',
            'related_card_id': '2026/04/25.md#ts_3',
          },
        ],
        'timeline': [
          {
            'day_label': 'Today',
            'day_date': '2026-04-23',
            'items': [
              {
                'card_id': '2026/04/23.md#ts_1',
                'title': '设计评审',
                'status': 'pending',
                'start_time': '2026-04-23T14:00:00Z',
                'type': 'event',
                'priority': 2,
              },
            ],
          },
        ],
        'completed': [
          {
            'card_id': '2026/04/22.md#ts_1',
            'title': '架构评审',
            'completed_at': '2026-04-22T12:10:00Z',
          },
        ],
        'conflicts': [
          {
            'description': '14:00-15:00 有两个会议冲突',
            'item_ids': ['id1', 'id2'],
          },
        ],
      };

      final model = ScheduleAggregationModel.fromYaml(yaml);

      expect(model.id, 'schedule_agg_2026_04_23');
      expect(model.version, 1);
      expect(model.editorialIntro, '这是一个忙碌的星期');
      expect(model.heroItem, isNotNull);
      expect(model.heroItem!.title, 'Q3 产品发布会');
      expect(model.heroItem!.priority, 3);
      expect(model.heroItem!.location, '总部大礼堂');
      expect(model.quoteBlocks.length, 1);
      expect(model.quoteBlocks.first.title, '截止提醒');
      expect(model.quoteBlocks.first.priority, 'high');
      expect(model.timeline.length, 1);
      expect(model.timeline.first.dayLabel, 'Today');
      expect(model.timeline.first.items.length, 1);
      expect(model.timeline.first.items.first.title, '设计评审');
      expect(model.completed.length, 1);
      expect(model.completed.first.title, '架构评审');
      expect(model.conflicts.length, 1);
      expect(model.conflicts.first.itemIds, ['id1', 'id2']);
    });

    test('handles missing optional fields gracefully', () {
      final yaml = {
        'id': 'schedule_agg_2026_04_23',
        'generated_at': '2026-04-23T08:00:00Z',
        'time_range': {
          'from': '2026-04-21',
          'to': '2026-04-30',
        },
      };

      final model = ScheduleAggregationModel.fromYaml(yaml);

      expect(model.id, 'schedule_agg_2026_04_23');
      expect(model.heroItem, isNull);
      expect(model.editorialIntro, '');
      expect(model.quoteBlocks, isEmpty);
      expect(model.timeline, isEmpty);
      expect(model.completed, isEmpty);
      expect(model.conflicts, isEmpty);
    });

    test('handles null input gracefully', () {
      final model = ScheduleAggregationModel.fromYaml({});

      expect(model.id, '');
      expect(model.heroItem, isNull);
      expect(model.timeline, isEmpty);
    });

    test('parses LLM-style scalar variants and ignores malformed list entries',
        () {
      final model = ScheduleAggregationModel.fromYaml({
        'id': 20260426,
        'generated_at': DateTime.utc(2026, 4, 26, 1),
        'version': '2',
        'time_range': {
          'from': DateTime(2026, 4, 26),
          'to': '2026-05-03',
        },
        'hero_item': {
          'id': 42,
          'title': 123,
          'priority': 'urgent',
        },
        'quote_blocks': [
          {
            'title': '风险',
            'content': 88,
            'priority': 'high',
            'related_card_id': 42,
          },
          'not a map',
        ],
        'timeline': [
          {
            'day_label': 'Today',
            'day_date': '2026-04-26',
            'items': [
              {
                'id': 101,
                'title': '确认材料',
                'status': 'done',
                'type': 'task',
                'priority': 'low',
              },
              false,
            ],
          },
          7,
        ],
        'completed': [
          {
            'id': 102,
            'title': '完成彩排',
            'completed_at': 'invalid datetime',
          },
        ],
        'conflicts': [
          {
            'description': 404,
            'item_ids': [101, '42'],
          },
        ],
      });

      expect(model.id, '20260426');
      expect(model.generatedAt, DateTime.utc(2026, 4, 26, 1));
      expect(model.version, 2);
      expect(model.heroItem?.cardId, '42');
      expect(model.heroItem?.title, '123');
      expect(model.heroItem?.priority, 3);
      expect(model.quoteBlocks, hasLength(1));
      expect(model.quoteBlocks.single.content, '88');
      expect(model.quoteBlocks.single.relatedCardId, '42');
      expect(model.timeline, hasLength(1));
      expect(model.timeline.single.items, hasLength(1));
      expect(model.timeline.single.items.single.cardId, '101');
      expect(model.timeline.single.items.single.priority, 1);
      expect(model.completed.single.cardId, '102');
      expect(model.completed.single.completedAt, isNull);
      expect(model.conflicts.single.description, '404');
      expect(model.conflicts.single.itemIds, ['101', '42']);
    });

    test('round-trip serialization preserves data', () {
      final original = ScheduleAggregationModel(
        id: 'test_id',
        generatedAt: DateTime(2026, 4, 23, 8, 0),
        timeRange: TimeRange(
          from: DateTime(2026, 4, 21),
          to: DateTime(2026, 4, 30),
        ),
        heroItem: HeroItem(
          cardId: 'card_1',
          title: 'Hero Event',
          description: 'Important event',
          startTime: DateTime(2026, 4, 25, 14),
          location: 'Room A',
          priority: 3,
        ),
        editorialIntro: 'Test intro',
        quoteBlocks: [
          QuoteBlock(
            title: 'Reminder',
            content: 'Do not forget',
            priority: 'high',
          ),
        ],
        timeline: [
          TimelineDay(
            dayLabel: 'Today',
            dayDate: DateTime(2026, 4, 23),
            items: [
              TimelineItem(
                cardId: 'item_1',
                title: 'Meeting',
                status: 'pending',
                type: 'event',
              ),
            ],
          ),
        ],
        completed: [
          CompletedItem(
            cardId: 'done_1',
            title: 'Finished task',
          ),
        ],
      );

      final json = original.toJson();
      final restored = ScheduleAggregationModel.fromYaml(json);

      expect(restored.id, original.id);
      expect(restored.editorialIntro, original.editorialIntro);
      expect(restored.heroItem?.title, original.heroItem?.title);
      expect(restored.quoteBlocks.length, original.quoteBlocks.length);
      expect(restored.timeline.length, original.timeline.length);
      expect(restored.completed.length, original.completed.length);
    });
  });

  group('HeroItem', () {
    test('falls back to id when card_id is missing', () {
      final yaml = {'id': 'fallback_id', 'title': 'Test'};
      final hero = HeroItem.fromYaml(yaml);
      expect(hero.cardId, 'fallback_id');
    });

    test('handles null datetime fields', () {
      final yaml = {
        'card_id': 'c1',
        'title': 'Test',
      };
      final hero = HeroItem.fromYaml(yaml);
      expect(hero.startTime, isNull);
      expect(hero.endTime, isNull);
    });
  });

  group('TimelineItem', () {
    test('uses defaults for missing fields', () {
      final yaml = {'card_id': 'c1', 'title': 'Test'};
      final item = TimelineItem.fromYaml(yaml);
      expect(item.status, 'pending');
      expect(item.type, 'event');
      expect(item.priority, isNull);
    });
  });

  group('TimeRange', () {
    test('formats dates correctly in JSON', () {
      final range = TimeRange(
        from: DateTime(2026, 4, 23),
        to: DateTime(2026, 4, 30),
      );
      final json = range.toJson();
      expect(json['from'], '2026-04-23');
      expect(json['to'], '2026-04-30');
    });
  });
}
