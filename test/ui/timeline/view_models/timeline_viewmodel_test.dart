import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';

void main() {
  group('timeline card idempotency helpers', () {
    test('upsert inserts a new local card at the top', () {
      final existing = [
        _card('2026/05/18.md#ts_1', title: 'older'),
        _card('2026/05/18.md#ts_2', title: 'oldest'),
      ];

      final result = upsertTimelineCardById(
        existing,
        _card('2026/05/18.md#ts_3', title: 'new'),
      );

      expect(result.map((card) => card.id), [
        '2026/05/18.md#ts_3',
        '2026/05/18.md#ts_1',
        '2026/05/18.md#ts_2',
      ]);
    });

    test(
      'upsert replaces a duplicate local submission instead of appending',
      () {
        final existing = [
          _card(
            '2026/05/18.md#ts_1',
            title: 'stale processing copy',
            status: 'processing',
          ),
          _card('2026/05/18.md#ts_0', title: 'older'),
        ];

        final result = upsertTimelineCardById(
          existing,
          _card(
            '2026/05/18.md#ts_1',
            title: 'fresh processing copy',
            status: 'processing',
          ),
        );

        expect(result, hasLength(2));
        expect(result.first.id, '2026/05/18.md#ts_1');
        expect(result.first.title, 'fresh processing copy');
        expect(
          result.where((card) => card.id == '2026/05/18.md#ts_1'),
          hasLength(1),
        );
      },
    );

    test(
      'update collapses duplicate processing copies in their first position',
      () {
        final existing = [
          _card('2026/05/18.md#ts_0', title: 'newer neighbor'),
          _card(
            '2026/05/18.md#ts_1',
            title: 'processing copy A',
            status: 'processing',
          ),
          _card(
            '2026/05/18.md#ts_1',
            title: 'processing copy B',
            status: 'processing',
          ),
          _card('2026/05/18.md#ts_2', title: 'older neighbor'),
        ];

        final result = replaceTimelineCardById(
          existing,
          _card(
            '2026/05/18.md#ts_1',
            title: 'completed result',
            status: 'completed',
          ),
        );

        expect(result.map((card) => card.title), [
          'newer neighbor',
          'completed result',
          'older neighbor',
        ]);
        expect(
          result.where((card) => card.id == '2026/05/18.md#ts_1'),
          hasLength(1),
        );
      },
    );

    test('update leaves unloaded cards out of the current filtered list', () {
      final existing = [_card('2026/05/18.md#ts_0', title: 'visible card')];

      final result = replaceTimelineCardById(
        existing,
        _card('2026/05/18.md#ts_9', title: 'hidden card'),
      );

      expect(result, same(existing));
      expect(result.map((card) => card.title), ['visible card']);
    });

    test(
      'dedupe keeps the already loaded page copy across pagination overlap',
      () {
        final result = dedupeTimelineCardsById([
          _card('2026/05/18.md#ts_3', title: 'top'),
          _card('2026/05/18.md#ts_2', title: 'page one boundary'),
          _card('2026/05/18.md#ts_2', title: 'page two duplicate'),
          _card('2026/05/18.md#ts_1', title: 'older'),
        ]);

        expect(result.map((card) => card.title), [
          'top',
          'page one boundary',
          'older',
        ]);
        expect(
          result.where((card) => card.id == '2026/05/18.md#ts_2'),
          hasLength(1),
        );
      },
    );
  });
}

TimelineCardModel _card(
  String id, {
  required String title,
  String status = 'completed',
}) {
  return TimelineCardModel(
    id: id,
    timestamp: DateTime(2026, 5, 18, 12),
    tags: const [],
    status: status,
    title: title,
    uiConfigs: [
      UiConfig(templateId: 'classic_card', data: {'content': title}),
    ],
  );
}
