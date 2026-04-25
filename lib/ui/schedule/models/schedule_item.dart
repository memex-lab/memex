import 'package:memex/domain/models/schedule_aggregation_model.dart';

// =============================================================================
// Schedule presentation models
// =============================================================================

enum ScheduleItemType { todo, event }

enum ScheduleItemStatus { pending, completed, inProgress, overdue }

class ScheduleItem {
  final String id;
  final String title;
  final ScheduleItemType type;
  final ScheduleItemStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? completedAt;
  final String? location;
  final String? description;
  final List<String> tags;
  final int? priority; // 1-3, 3 = highest
  final String sourceType;
  final List<RelatedEvent> relatedEvents;

  ScheduleItem({
    required this.id,
    required this.title,
    required this.type,
    this.status = ScheduleItemStatus.pending,
    this.startTime,
    this.endTime,
    this.completedAt,
    this.location,
    this.description,
    this.tags = const [],
    this.priority,
    this.sourceType = 'event',
    this.relatedEvents = const [],
  });

  ScheduleItem copyWith({
    ScheduleItemType? type,
    ScheduleItemStatus? status,
    DateTime? completedAt,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    List<String>? tags,
    int? priority,
    String? sourceType,
    bool clearCompletedAt = false,
  }) {
    return ScheduleItem(
      id: id,
      title: title,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      location: location ?? this.location,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      sourceType: sourceType ?? this.sourceType,
      relatedEvents: relatedEvents,
    );
  }

  static List<ScheduleItem> fromAggregation(
    ScheduleAggregationModel aggregation,
  ) {
    final itemsById = <String, ScheduleItem>{};
    var fallbackIndex = 0;

    void upsert(ScheduleItem item) {
      final id = item.id.isEmpty ? 'schedule_item_${fallbackIndex++}' : item.id;
      final normalized = id == item.id
          ? item
          : ScheduleItem(
              id: id,
              title: item.title,
              type: item.type,
              status: item.status,
              startTime: item.startTime,
              endTime: item.endTime,
              completedAt: item.completedAt,
              location: item.location,
              description: item.description,
              tags: item.tags,
              priority: _normalizePriority(item.priority),
              sourceType: item.sourceType,
              relatedEvents: item.relatedEvents,
            );
      final existing = itemsById[id];
      itemsById[id] =
          existing == null ? normalized : _merge(existing, normalized);
    }

    if (aggregation.heroItem != null) {
      final hero = aggregation.heroItem!;
      upsert(ScheduleItem(
        id: hero.cardId,
        title: hero.title,
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: hero.startTime,
        endTime: hero.endTime,
        location: hero.location,
        description: hero.description,
        priority: _normalizePriority(hero.priority),
        sourceType: 'event',
      ));
    }

    for (final day in aggregation.timeline) {
      for (final timelineItem in day.items) {
        upsert(_fromTimelineItem(timelineItem, day.dayDate));
      }
    }

    for (final completedItem in aggregation.completed) {
      final id = completedItem.cardId;
      final existing = itemsById[id];
      if (existing != null) {
        itemsById[id] = existing.copyWith(
          status: ScheduleItemStatus.completed,
          completedAt: completedItem.completedAt,
        );
      } else {
        upsert(ScheduleItem(
          id: id,
          title: completedItem.title,
          type: ScheduleItemType.todo,
          status: ScheduleItemStatus.completed,
          completedAt: completedItem.completedAt,
          sourceType: 'task',
        ));
      }
    }

    final items = itemsById.values.toList()
      ..sort((a, b) {
        final aTime = a.startTime ?? a.completedAt;
        final bTime = b.startTime ?? b.completedAt;
        if (aTime == null && bTime == null) {
          return a.title.compareTo(b.title);
        }
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return aTime.compareTo(bTime);
      });
    return items;
  }

  static ScheduleItem _fromTimelineItem(
    TimelineItem item,
    DateTime? dayDate,
  ) {
    final sourceType = item.type;
    final itemType = _parseType(sourceType);
    final startTime = item.startTime ?? dayDate;
    return ScheduleItem(
      id: item.cardId,
      title: item.title,
      type: itemType,
      status: _parseStatus(item.status),
      startTime: startTime,
      description: item.description,
      priority: _normalizePriority(item.priority),
      sourceType: sourceType,
    );
  }

  static ScheduleItem _merge(ScheduleItem base, ScheduleItem incoming) {
    final status = _higherPriorityStatus(base.status, incoming.status);
    final type =
        incoming.type == ScheduleItemType.todo ? incoming.type : base.type;
    final sourceType =
        base.sourceType == 'event' && incoming.sourceType != 'event'
            ? incoming.sourceType
            : base.sourceType;
    return base.copyWith(
      type: type,
      status: status,
      startTime: base.startTime ?? incoming.startTime,
      endTime: base.endTime ?? incoming.endTime,
      completedAt: base.completedAt ?? incoming.completedAt,
      location: base.location ?? incoming.location,
      description: base.description ?? incoming.description,
      tags: base.tags.isNotEmpty ? base.tags : incoming.tags,
      priority: _normalizePriority(base.priority ?? incoming.priority),
      sourceType: sourceType,
    );
  }

  static ScheduleItemType _parseType(String value) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'task' || normalized == 'todo') {
      return ScheduleItemType.todo;
    }
    return ScheduleItemType.event;
  }

  static ScheduleItemStatus _parseStatus(String value) {
    final normalized = value.toLowerCase().trim().replaceAll('-', '_');
    return switch (normalized) {
      'completed' || 'done' => ScheduleItemStatus.completed,
      'in_progress' ||
      'inprogress' ||
      'active' =>
        ScheduleItemStatus.inProgress,
      'overdue' => ScheduleItemStatus.overdue,
      _ => ScheduleItemStatus.pending,
    };
  }

  static ScheduleItemStatus _higherPriorityStatus(
    ScheduleItemStatus a,
    ScheduleItemStatus b,
  ) {
    int rank(ScheduleItemStatus status) {
      return switch (status) {
        ScheduleItemStatus.completed => 4,
        ScheduleItemStatus.overdue => 3,
        ScheduleItemStatus.inProgress => 2,
        ScheduleItemStatus.pending => 1,
      };
    }

    return rank(b) > rank(a) ? b : a;
  }

  static int? _normalizePriority(int? value) {
    if (value == null) return null;
    if (value < 1) return 1;
    if (value > 3) return 3;
    return value;
  }
}

class RelatedEvent {
  final String id;
  final String title;
  final String type;
  final DateTime timestamp;

  RelatedEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.timestamp,
  });
}
