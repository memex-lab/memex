import 'package:memex/domain/models/schedule_state.dart';

class ScheduleViewData {
  const ScheduleViewData({
    required this.id,
    required this.generatedAt,
    required this.timeRange,
    this.hero,
    this.editorialIntro = '',
    this.quoteBlocks = const <ScheduleViewQuoteBlock>[],
    this.timeline = const <ScheduleViewTimelineDay>[],
    this.completed = const <ScheduleViewCompletedItem>[],
  });

  final String id;
  final DateTime generatedAt;
  final ScheduleViewTimeRange timeRange;
  final ScheduleViewHero? hero;
  final String editorialIntro;
  final List<ScheduleViewQuoteBlock> quoteBlocks;
  final List<ScheduleViewTimelineDay> timeline;
  final List<ScheduleViewCompletedItem> completed;
}

class ScheduleViewTimeRange {
  const ScheduleViewTimeRange({
    required this.from,
    required this.to,
  });

  final DateTime from;
  final DateTime to;
}

class ScheduleViewHero {
  const ScheduleViewHero({
    required this.cardId,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.location,
    this.priority,
  });

  final String cardId;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;
  final int? priority;
}

class ScheduleViewQuoteBlock {
  const ScheduleViewQuoteBlock({
    required this.title,
    required this.content,
    this.priority = 'normal',
    this.relatedCardId,
  });

  final String title;
  final String content;
  final String priority;
  final String? relatedCardId;
}

class ScheduleViewTimelineDay {
  const ScheduleViewTimelineDay({
    required this.dayLabel,
    this.dayDate,
    this.items = const <ScheduleViewPendingItem>[],
  });

  final String dayLabel;
  final DateTime? dayDate;
  final List<ScheduleViewPendingItem> items;
}

class ScheduleViewPendingItem {
  const ScheduleViewPendingItem({
    required this.cardId,
    required this.title,
    this.itemId,
    this.status = 'pending',
    this.type = 'event',
    this.startTime,
    this.endTime,
    this.location,
    this.priority,
    this.description,
    this.subtasks = const <ScheduleSubtask>[],
  });

  final String cardId;
  final String? itemId;
  final String title;
  final String status;
  final String type;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;
  final int? priority;
  final String? description;
  final List<ScheduleSubtask> subtasks;
}

class ScheduleViewCompletedItem {
  const ScheduleViewCompletedItem({
    required this.cardId,
    required this.title,
    this.completedAt,
  });

  final String cardId;
  final String title;
  final DateTime? completedAt;
}
