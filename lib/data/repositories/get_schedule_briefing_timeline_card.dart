import 'package:memex/data/repositories/get_schedule_view_data.dart';
import 'package:memex/domain/models/system_card_constants.dart';
import 'package:memex/domain/models/schedule_view_data.dart';
import 'package:memex/domain/models/timeline_card_model.dart';

Future<TimelineCardModel?> getScheduleBriefingTimelineCard() async {
  final schedule = await getScheduleViewData();

  if (schedule == null) {
    return null;
  }

  final generatedAt = schedule.generatedAt;
  return TimelineCardModel(
    id: scheduleBriefingCardId,
    timestamp: generatedAt,
    tags: const [],
    status: 'completed',
    title: 'Schedule briefing',
    uiConfigs: [
      UiConfig(
        templateId: scheduleBriefingTemplateId,
        data: _buildScheduleBriefingData(
          schedule: schedule,
          generatedAt: generatedAt,
        ),
      ),
    ],
  );
}

Map<String, dynamic> _buildScheduleBriefingData({
  required ScheduleViewData? schedule,
  required DateTime? generatedAt,
}) {
  final hero = schedule?.hero;
  final items = schedule == null
      ? const <Map<String, dynamic>>[]
      : _nextScheduleItems(schedule).take(3).toList();

  return {
    if (generatedAt != null) 'generated_at': generatedAt.toIso8601String(),
    if (schedule != null) ...{
      'aggregation_id': schedule.id,
      'summary': schedule.editorialIntro,
      if (hero != null) ...{
        'hero_title': hero.title,
        if (hero.description != null) 'hero_description': hero.description,
        if (hero.startTime != null)
          'hero_start_time': hero.startTime!.toIso8601String(),
        if (hero.location != null) 'hero_location': hero.location,
      },
      'items': items,
      'completed_count': schedule.completed.length,
    },
  };
}

Iterable<Map<String, dynamic>> _nextScheduleItems(
  ScheduleViewData schedule,
) sync* {
  final allItems = schedule.timeline
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
