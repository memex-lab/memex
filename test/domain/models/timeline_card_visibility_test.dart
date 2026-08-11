import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/domain/models/timeline_card_visibility.dart';

void main() {
  group('isRetiredTimelineCard', () {
    test('recognizes the legacy schedule briefing id', () {
      expect(
        isRetiredTimelineCard(
          _card(
            id: retiredScheduleBriefingCardId,
            templateId: 'classic_card',
          ),
        ),
        isTrue,
      );
    });

    test('recognizes legacy schedule briefing template copies', () {
      expect(
        isRetiredTimelineCard(
          _card(
            id: 'legacy-schedule-copy',
            templateId: retiredScheduleBriefingTemplateId,
          ),
        ),
        isTrue,
      );
    });

    test('keeps normal timeline cards visible', () {
      expect(
        isRetiredTimelineCard(
          _card(id: '2026/07/27.md#ts_1', templateId: 'classic_card'),
        ),
        isFalse,
      );
    });
  });
}

TimelineCardModel _card({
  required String id,
  required String templateId,
}) {
  return TimelineCardModel(
    id: id,
    timestamp: DateTime(2026, 7, 27),
    tags: const [],
    status: 'completed',
    uiConfigs: [UiConfig(templateId: templateId, data: const {})],
  );
}
