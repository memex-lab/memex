import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/schedule_aggregation_normalizer.dart';

void main() {
  group('normalizeScheduleAggregationYaml', () {
    test(
      'silently keeps one rebuilt duplicate and drops advisory conflicts',
      () {
        final normalized = normalizeScheduleAggregationYaml({
          'timeline': [
            {
              'day_label': 'Today',
              'day_date': '2026-05-26',
              'items': [
                {
                  'card_id': 'event-visa',
                  'title': '签证预约',
                  'type': 'event',
                  'start_time': '2026-05-26T10:00:00+08:00',
                  'description': '旧版本',
                },
              ],
            },
            {
              'day_label': 'Today',
              'day_date': '2026-05-26',
              'items': [
                {
                  'card_id': 'event-visa',
                  'title': '签证预约',
                  'type': 'event',
                  'start_time': '2026-05-26T10:00:00+08:00',
                  'description': '重建版本',
                },
              ],
            },
          ],
          'completed': [],
          'conflicts': [
            {
              'description': '签证预约事件重复，建议以重建版本为准',
              'item_ids': ['event-visa', 'event-visa'],
            },
          ],
        });

        final timeline = normalized['timeline'] as List;
        final items = (timeline.single as Map)['items'] as List;

        expect(items, hasLength(1));
        expect((items.single as Map)['card_id'], 'event-visa');
        expect((items.single as Map)['description'], '重建版本');
        expect(normalized['conflicts'], isEmpty);
      },
    );

    test(
      'dedupes semantic duplicates only when conflict marked them duplicate',
      () {
        final normalized = normalizeScheduleAggregationYaml({
          'timeline': [
            {
              'day_label': 'Today',
              'day_date': '2026-05-26',
              'items': [
                {
                  'card_id': 'event-old',
                  'title': '牙医预约',
                  'type': 'event',
                  'start_time': '2026-05-26T10:00:00+08:00',
                },
                {
                  'card_id': 'event-new',
                  'title': '牙医预约',
                  'type': 'event',
                  'start_time': '2026-05-26T10:00:00+08:00',
                  'location': '诊所',
                },
              ],
            },
          ],
          'completed': [],
          'conflicts': [
            {
              'description': '重复事件，保留重建版本',
              'item_ids': ['event-old', 'event-new'],
            },
          ],
        });

        final items =
            (((normalized['timeline'] as List).single as Map)['items'] as List);

        expect(items, hasLength(1));
        expect((items.single as Map)['card_id'], 'event-new');
        expect((items.single as Map)['location'], '诊所');
        expect(normalized['conflicts'], isEmpty);
      },
    );

    test('keeps real overlap conflicts between distinct source cards', () {
      final normalized = normalizeScheduleAggregationYaml({
        'timeline': [
          {
            'day_label': 'Today',
            'items': [
              {
                'card_id': 'event-a',
                'title': 'Design review',
                'type': 'event',
                'start_time': '2026-05-26T10:00:00+08:00',
              },
              {
                'card_id': 'event-b',
                'title': 'Dentist',
                'type': 'event',
                'start_time': '2026-05-26T10:30:00+08:00',
              },
            ],
          },
        ],
        'completed': [],
        'conflicts': [
          {
            'description': 'Two fixed events overlap at 10:30.',
            'item_ids': ['event-a', 'event-b'],
          },
        ],
      });

      expect(normalized['conflicts'], hasLength(1));
      expect(
        ((normalized['timeline'] as List).single as Map)['items'],
        hasLength(2),
      );
    });

    test('completed items suppress duplicate pending timeline entries', () {
      final normalized = normalizeScheduleAggregationYaml({
        'timeline': [
          {
            'day_label': 'Today',
            'items': [
              {
                'card_id': 'task-done',
                'title': '同步发布稿',
                'type': 'task',
                'status': 'pending',
              },
            ],
          },
        ],
        'completed': [
          {'card_id': 'task-done', 'title': '同步发布稿'},
        ],
        'conflicts': [],
      });

      expect(normalized['timeline'], isEmpty);
      expect(normalized['completed'], hasLength(1));
    });
  });
}
