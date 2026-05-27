import 'package:memex/domain/models/schedule_state.dart' show ScheduleSubtask;
import 'package:memex/domain/models/schedule_view_data.dart';

// =============================================================================
// Schedule presentation models
// =============================================================================

enum ScheduleItemType { todo, event }

enum ScheduleItemStatus { pending, completed, inProgress, overdue }

class ScheduleItem {
  final String itemId;
  final String sourceFactId;
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
  final List<ScheduleSubtask> subtasks;

  ScheduleItem({
    required this.sourceFactId,
    String? itemId,
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
    this.subtasks = const [],
  }) : itemId = itemId ?? sourceFactId;

  ScheduleItem copyWith({
    String? itemId,
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
    List<ScheduleSubtask>? subtasks,
    bool clearCompletedAt = false,
  }) {
    return ScheduleItem(
      itemId: itemId ?? this.itemId,
      sourceFactId: sourceFactId,
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
      subtasks: subtasks ?? this.subtasks,
    );
  }

  static List<ScheduleItem> fromViewData(ScheduleViewData data) {
    final itemsByItemId = <String, ScheduleItem>{};
    var fallbackIndex = 0;

    void upsert(ScheduleItem item) {
      final sourceFactId = item.sourceFactId.isEmpty
          ? 'schedule_item_${fallbackIndex++}'
          : item.sourceFactId;
      final itemId = item.itemId.isEmpty ? sourceFactId : item.itemId;
      final normalized = sourceFactId == item.sourceFactId
          ? item
          : ScheduleItem(
              itemId: itemId,
              sourceFactId: sourceFactId,
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
              subtasks: item.subtasks,
            );
      final existing = itemsByItemId[itemId];
      if (existing != null) {
        itemsByItemId[itemId] = _merge(existing, normalized);
        return;
      }

      itemsByItemId[itemId] = normalized;
    }

    if (data.hero != null) {
      final hero = data.hero!;
      upsert(
        ScheduleItem(
          itemId: hero.cardId,
          sourceFactId: hero.cardId,
          title: hero.title,
          type: ScheduleItemType.event,
          status: ScheduleItemStatus.pending,
          startTime: hero.startTime,
          endTime: hero.endTime,
          location: hero.location,
          description: hero.description,
          priority: _normalizePriority(hero.priority),
          sourceType: 'event',
        ),
      );
    }

    for (final day in data.timeline) {
      for (final timelineItem in day.items) {
        upsert(_fromTimelineItem(timelineItem, day.dayDate));
      }
    }

    for (final completedItem in data.completed) {
      final sourceFactId = completedItem.cardId;
      final existingEntry = itemsByItemId.entries.where((entry) {
        return entry.value.sourceFactId == sourceFactId;
      }).firstOrNull;
      final existing = existingEntry?.value;
      if (existing != null) {
        itemsByItemId[existing.itemId] = existing.copyWith(
          status: ScheduleItemStatus.completed,
          completedAt: completedItem.completedAt,
        );
      } else {
        upsert(
          ScheduleItem(
            sourceFactId: sourceFactId,
            title: completedItem.title,
            type: ScheduleItemType.todo,
            status: ScheduleItemStatus.completed,
            completedAt: completedItem.completedAt,
            sourceType: 'task',
          ),
        );
      }
    }

    final items = itemsByItemId.values.toList()
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
    ScheduleViewPendingItem item,
    DateTime? dayDate,
  ) {
    final sourceType = item.type;
    final itemType = _parseType(sourceType);
    final startTime = item.startTime ?? dayDate;
    final parsedStatus = _parseStatus(item.status);
    return ScheduleItem(
      itemId: item.itemId ?? item.cardId,
      sourceFactId: item.cardId,
      title: item.title,
      type: itemType,
      status: itemType == ScheduleItemType.todo
          ? deriveTodoStatus(item.subtasks, fallback: parsedStatus)
          : parsedStatus,
      startTime: startTime,
      description: item.description,
      priority: _normalizePriority(item.priority),
      sourceType: sourceType,
      subtasks: item.subtasks,
    );
  }

  static ScheduleItem _merge(ScheduleItem base, ScheduleItem incoming) {
    final type =
        incoming.type == ScheduleItemType.todo ? incoming.type : base.type;
    final subtasks =
        base.subtasks.isNotEmpty ? base.subtasks : incoming.subtasks;
    final status = type == ScheduleItemType.todo
        ? deriveTodoStatus(
            subtasks,
            fallback: _higherPriorityStatus(base.status, incoming.status),
          )
        : _higherPriorityStatus(base.status, incoming.status);
    final sourceType =
        base.sourceType == 'event' && incoming.sourceType != 'event'
            ? incoming.sourceType
            : base.sourceType;
    return base.copyWith(
      itemId: incoming.type == ScheduleItemType.todo ? incoming.itemId : null,
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
      subtasks: subtasks,
    );
  }

  static ScheduleItemStatus deriveTodoStatus(
    List<ScheduleSubtask> subtasks, {
    required ScheduleItemStatus fallback,
  }) {
    if (fallback == ScheduleItemStatus.completed || subtasks.isEmpty) {
      return fallback;
    }

    final completedCount =
        subtasks.where((subtask) => subtask.completed).length;
    if (completedCount == subtasks.length) {
      return ScheduleItemStatus.completed;
    }
    if (completedCount > 0) {
      return ScheduleItemStatus.inProgress;
    }
    return fallback == ScheduleItemStatus.overdue
        ? ScheduleItemStatus.overdue
        : ScheduleItemStatus.pending;
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
