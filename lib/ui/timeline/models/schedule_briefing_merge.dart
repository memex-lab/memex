import 'package:memex/domain/models/system_card_constants.dart';
import 'package:memex/domain/models/timeline_card_model.dart';

List<TimelineCardModel> mergeScheduleBriefingInTimelineOrder({
  required List<TimelineCardModel> cards,
  required TimelineCardModel? briefing,
  required bool hasMore,
}) {
  final withoutBriefing =
      cards.where((card) => card.id != scheduleBriefingCardId).toList();
  if (briefing == null) return withoutBriefing;
  if (withoutBriefing.isEmpty) return [briefing];

  final oldestVisibleCard = withoutBriefing.last;
  if (hasMore && briefing.timestamp.isBefore(oldestVisibleCard.timestamp)) {
    return withoutBriefing;
  }

  final merged = [...withoutBriefing, briefing];
  merged.sort(compareTimelineCardsForFeed);
  return merged;
}

int compareTimelineCardsForFeed(TimelineCardModel a, TimelineCardModel b) {
  final timestampCompare = b.timestamp.compareTo(a.timestamp);
  if (timestampCompare != 0) return timestampCompare;
  return b.id.compareTo(a.id);
}
