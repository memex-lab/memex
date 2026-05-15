import 'package:memex/data/repositories/get_schedule_aggregation.dart';
import 'package:memex/data/repositories/get_schedule_refresh_state.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';
import 'package:memex/domain/models/system_card_constants.dart';
import 'package:memex/domain/models/timeline_card_model.dart';

Future<TimelineCardModel?> getScheduleBriefingTimelineCard() async {
  final aggregation = await getScheduleAggregation();
  final refreshState = await getScheduleRefreshState();

  if (aggregation == null && !refreshState.isDirty) {
    return null;
  }

  final generatedAt = aggregation?.generatedAt ?? refreshState.updatedAt;
  return TimelineCardModel(
    id: scheduleBriefingCardId,
    timestamp: generatedAt ?? DateTime.now(),
    tags: const [],
    status: 'completed',
    title: 'Schedule briefing',
    uiConfigs: [
      UiConfig(
        templateId: scheduleBriefingTemplateId,
        data: _buildScheduleBriefingData(
          aggregation: aggregation,
          generatedAt: generatedAt,
          isDirty: refreshState.isDirty,
          dirtyReason: refreshState.reason,
        ),
      ),
    ],
  );
}

Map<String, dynamic> _buildScheduleBriefingData({
  required ScheduleAggregationModel? aggregation,
  required DateTime? generatedAt,
  required bool isDirty,
  required String? dirtyReason,
}) {
  final hero = aggregation?.heroItem;
  final items = aggregation == null
      ? const <Map<String, dynamic>>[]
      : _nextScheduleItems(aggregation).take(3).toList();

  return {
    'is_dirty': isDirty,
    if (generatedAt != null) 'generated_at': generatedAt.toIso8601String(),
    if (dirtyReason != null && dirtyReason.isNotEmpty)
      'dirty_reason': dirtyReason,
    if (aggregation != null) ...{
      'aggregation_id': aggregation.id,
      'summary': aggregation.editorialIntro,
      if (hero != null) ...{
        'hero_title': hero.title,
        if (hero.description != null) 'hero_description': hero.description,
        if (hero.startTime != null)
          'hero_start_time': hero.startTime!.toIso8601String(),
        if (hero.location != null) 'hero_location': hero.location,
      },
      'items': items,
      'completed_count': aggregation.completed.length,
      'conflict_count': aggregation.conflicts.length,
    },
  };
}

Iterable<Map<String, dynamic>> _nextScheduleItems(
  ScheduleAggregationModel aggregation,
) sync* {
  final allItems = aggregation.timeline
      .expand((day) => day.items)
      .where((item) => item.status != 'completed')
      .toList()
    ..sort((a, b) {
      final aTime = a.startTime;
      final bTime = b.startTime;
      if (aTime == null && bTime == null) {
        return a.title.compareTo(b.title);
      }
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return aTime.compareTo(bTime);
    });

  for (final item in allItems) {
    yield {
      'card_id': item.cardId,
      'title': item.title,
      'type': item.type,
      'status': item.status,
      if (item.startTime != null)
        'start_time': item.startTime!.toIso8601String(),
    };
  }
}
