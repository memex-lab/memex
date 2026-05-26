import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_retention.dart';

void main() {
  group('applyScheduleDisplayRetention', () {
    test('adds a seven-day display deadline to undated non-task items', () {
      final result = applyScheduleDisplayRetention(
        yamlData: _aggregation(
          generatedAt: '2026-05-25T11:00:00+08:00',
          items: [
            _item(
              cardId: '2026/05/21.md#ts_3',
              title: '沙球转体转髋训练要点',
              type: 'procedure',
            ),
          ],
        ),
      );

      final item = _firstItem(result);
      expect(item[scheduleDisplayFirstSeenKey], '2026-05-25');
      expect(item[scheduleDisplayUntilKey], '2026-06-01');
    });

    test('preserves the previous deadline instead of renewing on refresh', () {
      final previous = _aggregation(
        generatedAt: '2026-05-22T09:00:00+08:00',
        items: [
          _item(
            cardId: 'procedure-1',
            title: '训练要点',
            type: 'procedure',
            firstSeenAt: '2026-05-22',
            displayUntil: '2026-05-29',
          ),
        ],
      );

      final result = applyScheduleDisplayRetention(
        yamlData: _aggregation(
          generatedAt: '2026-05-25T11:00:00+08:00',
          items: [
            _item(cardId: 'procedure-1', title: '训练要点', type: 'procedure'),
          ],
        ),
        previousAggregations: [previous],
      );

      final item = _firstItem(result);
      expect(item[scheduleDisplayFirstSeenKey], '2026-05-22');
      expect(item[scheduleDisplayUntilKey], '2026-05-29');
    });

    test('derives legacy deadlines from first historical appearance', () {
      final oldest = _aggregation(
        generatedAt: '2026-05-21T18:00:00+08:00',
        items: [_item(cardId: 'procedure-1', title: '训练要点', type: 'procedure')],
      );
      final latest = _aggregation(
        generatedAt: '2026-05-25T11:00:00+08:00',
        items: [_item(cardId: 'procedure-1', title: '训练要点', type: 'procedure')],
      );

      final result = applyScheduleDisplayRetention(
        yamlData: latest,
        previousAggregations: [latest, oldest],
      );

      final item = _firstItem(result);
      expect(item[scheduleDisplayFirstSeenKey], '2026-05-21');
      expect(item[scheduleDisplayUntilKey], '2026-05-28');
    });

    test('drops expired floating items and removes empty sections', () {
      final previous = _aggregation(
        generatedAt: '2026-05-21T18:00:00+08:00',
        items: [_item(cardId: 'procedure-1', title: '训练要点', type: 'procedure')],
      );
      final result = applyScheduleDisplayRetention(
        yamlData: _aggregation(
          generatedAt: '2026-05-29T09:00:00+08:00',
          items: [
            _item(cardId: 'procedure-1', title: '训练要点', type: 'procedure'),
          ],
        ),
        previousAggregations: [previous],
      );

      expect(result['timeline'], isEmpty);
    });

    test('uses current date to expire an old aggregation on read', () {
      final result = applyScheduleDisplayRetention(
        yamlData: _aggregation(
          generatedAt: '2026-05-25T09:00:00+08:00',
          items: [
            _item(
              cardId: 'procedure-1',
              title: '训练要点',
              type: 'procedure',
              firstSeenAt: '2026-05-21',
              displayUntil: '2026-05-28',
            ),
          ],
        ),
        now: DateTime(2026, 5, 29, 8),
      );

      expect(result['timeline'], isEmpty);
    });

    test('keeps tasks without dates because they are manually completable', () {
      final previous = _aggregation(
        generatedAt: '2026-05-21T18:00:00+08:00',
        items: [_item(cardId: 'task-1', title: '写作业', type: 'task')],
      );
      final result = applyScheduleDisplayRetention(
        yamlData: _aggregation(
          generatedAt: '2026-06-05T09:00:00+08:00',
          items: [_item(cardId: 'task-1', title: '写作业', type: 'task')],
        ),
        previousAggregations: [previous],
      );

      final item = _firstItem(result);
      expect(item['title'], '写作业');
      expect(item.containsKey(scheduleDisplayUntilKey), isFalse);
    });

    test(
      'keeps non-task items with concrete dates outside retention rules',
      () {
        final previous = _aggregation(
          generatedAt: '2026-05-21T18:00:00+08:00',
          items: [
            _item(cardId: 'procedure-1', title: '训练要点', type: 'procedure'),
          ],
        );
        final result = applyScheduleDisplayRetention(
          yamlData: _aggregation(
            generatedAt: '2026-06-05T09:00:00+08:00',
            dayDate: '2026-06-06',
            items: [
              _item(cardId: 'procedure-1', title: '训练要点复习', type: 'procedure'),
            ],
          ),
          previousAggregations: [previous],
        );

        final item = _firstItem(result);
        expect(item['title'], '训练要点复习');
        expect(item.containsKey(scheduleDisplayUntilKey), isFalse);
      },
    );

    test(
      'does not let an expired floating history suppress a later dated item',
      () {
        final previous = _aggregation(
          generatedAt: '2026-05-21T18:00:00+08:00',
          items: [
            _item(cardId: 'procedure-1', title: '训练要点', type: 'procedure'),
          ],
        );
        final result = applyScheduleDisplayRetention(
          yamlData: _aggregation(
            generatedAt: '2026-06-05T09:00:00+08:00',
            dayDate: '',
            items: [
              _item(
                cardId: 'procedure-1',
                title: '训练要点复习',
                type: 'procedure',
                startTime: '2026-06-06T10:00:00+08:00',
              ),
            ],
          ),
          previousAggregations: [previous],
        );

        expect(_firstItem(result)['title'], '训练要点复习');
      },
    );

    test(
      'retains mixed sections while dropping only expired floating items',
      () {
        final previous = _aggregation(
          generatedAt: '2026-05-21T18:00:00+08:00',
          items: [
            _item(cardId: 'procedure-1', title: '训练要点', type: 'procedure'),
          ],
        );
        final result = applyScheduleDisplayRetention(
          yamlData: _aggregation(
            generatedAt: '2026-05-29T09:00:00+08:00',
            items: [
              _item(cardId: 'procedure-1', title: '训练要点', type: 'procedure'),
              _item(cardId: 'task-1', title: '补税确认', type: 'task'),
            ],
          ),
          previousAggregations: [previous],
        );

        final items = _items(result);
        expect(items, hasLength(1));
        expect(items.single['title'], '补税确认');
      },
    );

    test('uses a stable title fallback when card id is missing', () {
      final previous = _aggregation(
        generatedAt: '2026-05-21T18:00:00+08:00',
        items: [_item(cardId: '', title: '训练要点', type: 'procedure')],
      );
      final result = applyScheduleDisplayRetention(
        yamlData: _aggregation(
          generatedAt: '2026-05-25T09:00:00+08:00',
          items: [_item(cardId: '', title: '训练要点', type: 'procedure')],
        ),
        previousAggregations: [previous],
      );

      expect(_firstItem(result)[scheduleDisplayUntilKey], '2026-05-28');
    });

    test('does not mutate the input aggregation map', () {
      final source = _aggregation(
        generatedAt: '2026-05-25T11:00:00+08:00',
        items: [_item(cardId: 'procedure-1', title: '训练要点', type: 'procedure')],
      );

      applyScheduleDisplayRetention(yamlData: source);

      expect(_firstItem(source).containsKey(scheduleDisplayUntilKey), isFalse);
    });
  });
}

Map<String, dynamic> _aggregation({
  required String generatedAt,
  String dayDate = '',
  required List<Map<String, dynamic>> items,
}) {
  return {
    'id': 'schedule_agg_test',
    'generated_at': generatedAt,
    'time_range': {'from': '2026-05-21', 'to': '2026-06-01'},
    'timeline': [
      {'day_label': '待安排', 'day_date': dayDate, 'items': items},
    ],
    'completed': [],
    'conflicts': [],
  };
}

Map<String, dynamic> _item({
  required String cardId,
  required String title,
  required String type,
  String? firstSeenAt,
  String? displayUntil,
  String? startTime,
}) {
  return {
    'card_id': cardId,
    'title': title,
    'status': 'pending',
    'type': type,
    if (firstSeenAt != null) scheduleDisplayFirstSeenKey: firstSeenAt,
    if (displayUntil != null) scheduleDisplayUntilKey: displayUntil,
    if (startTime != null) 'start_time': startTime,
  };
}

List<Map<String, dynamic>> _items(Map<String, dynamic> aggregation) {
  final timeline = aggregation['timeline'] as List;
  final day = timeline.single as Map<String, dynamic>;
  return (day['items'] as List).cast<Map<String, dynamic>>();
}

Map<String, dynamic> _firstItem(Map<String, dynamic> aggregation) {
  return _items(aggregation).single;
}
