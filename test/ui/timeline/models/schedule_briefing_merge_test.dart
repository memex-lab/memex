import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/system_card_constants.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/ui/timeline/models/schedule_briefing_merge.dart';

void main() {
  group('mergeScheduleBriefingInTimelineOrder', () {
    test('inserts briefing by timestamp instead of pinning it to the top', () {
      final merged = mergeScheduleBriefingInTimelineOrder(
        cards: [
          _card('new-record', DateTime(2026, 5, 16, 12)),
          _card('older-record', DateTime(2026, 5, 16, 8)),
        ],
        briefing: _briefing(DateTime(2026, 5, 16, 10)),
        hasMore: false,
      );

      expect(merged.map((card) => card.id), [
        'new-record',
        scheduleBriefingCardId,
        'older-record',
      ]);
    });

    test('keeps briefing hidden when it is older than the loaded page window',
        () {
      final merged = mergeScheduleBriefingInTimelineOrder(
        cards: [
          _card('noon-record', DateTime(2026, 5, 16, 12)),
          _card('morning-record', DateTime(2026, 5, 16, 8)),
        ],
        briefing: _briefing(DateTime(2026, 5, 15, 20)),
        hasMore: true,
      );

      expect(merged.map((card) => card.id), [
        'noon-record',
        'morning-record',
      ]);
    });

    test('appends old briefing after the final loaded page', () {
      final merged = mergeScheduleBriefingInTimelineOrder(
        cards: [
          _card('noon-record', DateTime(2026, 5, 16, 12)),
          _card('morning-record', DateTime(2026, 5, 16, 8)),
        ],
        briefing: _briefing(DateTime(2026, 5, 15, 20)),
        hasMore: false,
      );

      expect(merged.map((card) => card.id), [
        'noon-record',
        'morning-record',
        scheduleBriefingCardId,
      ]);
    });

    test('replaces existing briefing copy when refreshed', () {
      final merged = mergeScheduleBriefingInTimelineOrder(
        cards: [
          _card('noon-record', DateTime(2026, 5, 16, 12)),
          _briefing(DateTime(2026, 5, 16, 10)),
          _card('morning-record', DateTime(2026, 5, 16, 8)),
        ],
        briefing: _briefing(DateTime(2026, 5, 16, 13)),
        hasMore: false,
      );

      expect(merged.map((card) => card.id), [
        scheduleBriefingCardId,
        'noon-record',
        'morning-record',
      ]);
      expect(merged.first.timestamp, DateTime(2026, 5, 16, 13));
    });

    test('removes existing briefing when no briefing should be shown', () {
      final merged = mergeScheduleBriefingInTimelineOrder(
        cards: [
          _card('noon-record', DateTime(2026, 5, 16, 12)),
          _briefing(DateTime(2026, 5, 16, 10)),
        ],
        briefing: null,
        hasMore: false,
      );

      expect(merged.map((card) => card.id), ['noon-record']);
    });
  });
}

TimelineCardModel _briefing(DateTime timestamp) {
  return _card(
    scheduleBriefingCardId,
    timestamp,
    templateId: scheduleBriefingTemplateId,
  );
}

TimelineCardModel _card(
  String id,
  DateTime timestamp, {
  String templateId = 'classic_card',
}) {
  return TimelineCardModel(
    id: id,
    timestamp: timestamp,
    tags: const [],
    status: 'completed',
    title: id,
    uiConfigs: [
      UiConfig(templateId: templateId, data: const {}),
    ],
  );
}
