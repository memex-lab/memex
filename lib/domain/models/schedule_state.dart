/// Typed model for the user-level schedule_state YAML file.
///
/// One file per user at `Workspace/Schedule/schedule_state.yaml`. It is the
/// canonical "what is currently on my plate" view and is maintained by the
/// schedule aggregator agent.
///
/// Two kinds of items only:
///   - [SchedulePendingItem.kindTodo]: an actionable task with optional
///     `due_at` and optional `subtasks`.
///   - [SchedulePendingItem.kindEvent]: a calendar-shaped item with
///     `start_time` and optional `end_time`.
library;

class ScheduleState {
  ScheduleState({
    this.version = 1,
    DateTime? generatedAt,
    List<SchedulePendingItem>? pending,
    List<ScheduleCompletedItem>? completed,
    this.presentation,
  })  : generatedAt = generatedAt ?? DateTime.now(),
        pending = pending ?? <SchedulePendingItem>[],
        completed = completed ?? <ScheduleCompletedItem>[];

  final int version;
  final DateTime generatedAt;
  final List<SchedulePendingItem> pending;
  final List<ScheduleCompletedItem> completed;
  final SchedulePresentation? presentation;

  /// Empty state used as the bootstrap baseline.
  factory ScheduleState.empty() => ScheduleState();

  factory ScheduleState.fromJson(Map<String, dynamic> json) {
    return ScheduleState(
      version: (json['version'] as num?)?.toInt() ?? 1,
      generatedAt: _parseDateTime(json['generated_at']) ?? DateTime.now(),
      pending: _parseList(
        json['pending'],
        SchedulePendingItem.fromJson,
      ),
      completed: _parseList(
        json['completed'],
        ScheduleCompletedItem.fromJson,
      ),
      presentation: json['presentation'] is Map
          ? SchedulePresentation.fromJson(
              Map<String, dynamic>.from(json['presentation'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'version': version,
      'generated_at': generatedAt.toIso8601String(),
      'pending': pending.map((e) => e.toJson()).toList(),
      'completed': completed.map((e) => e.toJson()).toList(),
    };
    if (presentation != null) {
      m['presentation'] = presentation!.toJson();
    }
    return m;
  }

  ScheduleState copyWith({
    int? version,
    DateTime? generatedAt,
    List<SchedulePendingItem>? pending,
    List<ScheduleCompletedItem>? completed,
    SchedulePresentation? presentation,
    bool clearPresentation = false,
  }) {
    return ScheduleState(
      version: version ?? this.version,
      generatedAt: generatedAt ?? this.generatedAt,
      pending: pending ?? this.pending,
      completed: completed ?? this.completed,
      presentation:
          clearPresentation ? null : (presentation ?? this.presentation),
    );
  }
}

/// A single pending entry. `kind` is one of [kindTodo] or [kindEvent].
class SchedulePendingItem {
  SchedulePendingItem({
    required this.id,
    required this.kind,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.dueAt,
    this.location,
    this.priority,
    List<ScheduleSubtask>? subtasks,
    List<String>? sourceFactIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncDeviceAction = false,
    this.deviceActionId,
  })  : assert(
          kind == kindTodo || kind == kindEvent,
          'kind must be "todo" or "event"',
        ),
        subtasks = subtasks ?? const <ScheduleSubtask>[],
        sourceFactIds = sourceFactIds ?? const <String>[],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  static const String kindTodo = 'todo';
  static const String kindEvent = 'event';

  final String id;
  final String kind;
  final String title;
  final String? description;

  // Event-only fields.
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;

  // Todo-only fields.
  final DateTime? dueAt;
  final List<ScheduleSubtask> subtasks;

  // Shared.
  final int? priority;
  final List<String> sourceFactIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncDeviceAction;

  /// Identifier of the [SystemAction] (if any) created on the user's device
  /// for this item. Cleared when the item is completed or its trigger time
  /// is removed.
  final String? deviceActionId;

  bool get isEvent => kind == kindEvent;
  bool get isTodo => kind == kindTodo;

  /// Returns the moment after which the item should be considered "in the
  /// past" by the deterministic auto-complete sweep. Null if there is no
  /// time anchor (an open todo without `due_at`).
  DateTime? get pastAfter {
    if (isEvent) return endTime ?? startTime;
    return null; // todos never auto-complete.
  }

  factory SchedulePendingItem.fromJson(Map<String, dynamic> json) {
    return SchedulePendingItem(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? kindTodo,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      startTime: _parseDateTime(json['start_time']),
      endTime: _parseDateTime(json['end_time']),
      dueAt: _parseDateTime(json['due_at']),
      location: json['location'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
      subtasks: _parseList(json['subtasks'], ScheduleSubtask.fromJson),
      sourceFactIds: _parseStringList(json['source_fact_ids']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      syncDeviceAction: _parseBool(json['sync_device_action']),
      deviceActionId: json['device_action_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'kind': kind,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (description != null) m['description'] = description;
    if (startTime != null) m['start_time'] = startTime!.toIso8601String();
    if (endTime != null) m['end_time'] = endTime!.toIso8601String();
    if (dueAt != null) m['due_at'] = dueAt!.toIso8601String();
    if (location != null) m['location'] = location;
    if (priority != null) m['priority'] = priority;
    if (subtasks.isNotEmpty) {
      m['subtasks'] = subtasks.map((e) => e.toJson()).toList();
    }
    if (sourceFactIds.isNotEmpty) m['source_fact_ids'] = sourceFactIds;
    m['sync_device_action'] = syncDeviceAction;
    if (deviceActionId != null) m['device_action_id'] = deviceActionId;
    return m;
  }

  SchedulePendingItem copyWith({
    String? id,
    String? kind,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? dueAt,
    String? location,
    int? priority,
    List<ScheduleSubtask>? subtasks,
    List<String>? sourceFactIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncDeviceAction,
    String? deviceActionId,
    bool clearDueAt = false,
    bool clearStartTime = false,
    bool clearEndTime = false,
    bool clearLocation = false,
    bool clearPriority = false,
    bool clearDescription = false,
    bool clearDeviceActionId = false,
  }) {
    return SchedulePendingItem(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      location: clearLocation ? null : (location ?? this.location),
      priority: clearPriority ? null : (priority ?? this.priority),
      subtasks: subtasks ?? this.subtasks,
      sourceFactIds: sourceFactIds ?? this.sourceFactIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncDeviceAction: syncDeviceAction ?? this.syncDeviceAction,
      deviceActionId:
          clearDeviceActionId ? null : (deviceActionId ?? this.deviceActionId),
    );
  }
}

class ScheduleSubtask {
  const ScheduleSubtask({
    required this.title,
    this.completed = false,
    this.closedByFactId,
  });

  final String title;
  final bool completed;
  final String? closedByFactId;

  factory ScheduleSubtask.fromJson(Map<String, dynamic> json) {
    return ScheduleSubtask(
      title: json['title']?.toString() ?? '',
      completed: _parseBool(json['completed']),
      closedByFactId: json['closed_by_fact_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'title': title,
      'completed': completed,
    };
    if (closedByFactId != null) m['closed_by_fact_id'] = closedByFactId;
    return m;
  }

  ScheduleSubtask copyWith({
    String? title,
    bool? completed,
    String? closedByFactId,
    bool clearClosedByFactId = false,
  }) {
    return ScheduleSubtask(
      title: title ?? this.title,
      completed: completed ?? this.completed,
      closedByFactId:
          clearClosedByFactId ? null : (closedByFactId ?? this.closedByFactId),
    );
  }
}

class ScheduleCompletedItem {
  ScheduleCompletedItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.closedAt,
    this.closedByFactId,
    List<String>? sourceFactIds,
  })  : assert(
          kind == SchedulePendingItem.kindTodo ||
              kind == SchedulePendingItem.kindEvent,
        ),
        sourceFactIds = sourceFactIds ?? const <String>[];

  final String id;
  final String kind;
  final String title;
  final DateTime closedAt;
  final String? closedByFactId;
  final List<String> sourceFactIds;

  factory ScheduleCompletedItem.fromJson(Map<String, dynamic> json) {
    return ScheduleCompletedItem(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? SchedulePendingItem.kindTodo,
      title: json['title'] as String? ?? '',
      closedAt: _parseDateTime(json['closed_at']) ?? DateTime.now(),
      closedByFactId: json['closed_by_fact_id'] as String?,
      sourceFactIds: _parseStringList(json['source_fact_ids']),
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'kind': kind,
      'title': title,
      'closed_at': closedAt.toIso8601String(),
    };
    if (closedByFactId != null) m['closed_by_fact_id'] = closedByFactId;
    if (sourceFactIds.isNotEmpty) m['source_fact_ids'] = sourceFactIds;
    return m;
  }
}

class SchedulePresentation {
  const SchedulePresentation({
    this.hero,
    this.editorialIntro,
    List<ScheduleQuoteBlock>? quoteBlocks,
    List<ScheduleTimelineDay>? timeline,
  })  : quoteBlocks = quoteBlocks ?? const <ScheduleQuoteBlock>[],
        timeline = timeline ?? const <ScheduleTimelineDay>[];

  final SchedulePresentationHero? hero;
  final String? editorialIntro;
  final List<ScheduleQuoteBlock> quoteBlocks;
  final List<ScheduleTimelineDay> timeline;

  factory SchedulePresentation.fromJson(Map<String, dynamic> json) {
    return SchedulePresentation(
      hero: json['hero'] is Map
          ? SchedulePresentationHero.fromJson(
              Map<String, dynamic>.from(json['hero'] as Map),
            )
          : null,
      editorialIntro: json['editorial_intro'] as String?,
      quoteBlocks:
          _parseList(json['quote_blocks'], ScheduleQuoteBlock.fromJson),
      timeline: _parseList(json['timeline'], ScheduleTimelineDay.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (hero != null) m['hero'] = hero!.toJson();
    if (editorialIntro != null) m['editorial_intro'] = editorialIntro;
    if (quoteBlocks.isNotEmpty) {
      m['quote_blocks'] = quoteBlocks.map((e) => e.toJson()).toList();
    }
    if (timeline.isNotEmpty) {
      m['timeline'] = timeline.map((e) => e.toJson()).toList();
    }
    return m;
  }
}

class SchedulePresentationHero {
  const SchedulePresentationHero({
    required this.itemId,
    required this.title,
    this.description,
  });

  final String itemId;
  final String title;
  final String? description;

  factory SchedulePresentationHero.fromJson(Map<String, dynamic> json) {
    return SchedulePresentationHero(
      itemId: json['item_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'item_id': itemId,
      'title': title,
    };
    if (description != null) m['description'] = description;
    return m;
  }
}

class ScheduleQuoteBlock {
  const ScheduleQuoteBlock({
    required this.title,
    required this.content,
    this.priority = 'normal',
    this.itemId,
  });

  final String title;
  final String content;
  final String priority;
  final String? itemId;

  factory ScheduleQuoteBlock.fromJson(Map<String, dynamic> json) {
    return ScheduleQuoteBlock(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      priority: (json['priority'] as String?) ?? 'normal',
      itemId: json['item_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'title': title,
      'content': content,
      'priority': priority,
    };
    if (itemId != null) m['item_id'] = itemId;
    return m;
  }
}

class ScheduleTimelineDay {
  const ScheduleTimelineDay({
    required this.dayLabel,
    required this.dayDate,
    List<String>? itemIds,
  }) : itemIds = itemIds ?? const <String>[];

  final String dayLabel;
  final String dayDate; // YYYY-MM-DD
  final List<String> itemIds;

  factory ScheduleTimelineDay.fromJson(Map<String, dynamic> json) {
    return ScheduleTimelineDay(
      dayLabel: json['day_label'] as String? ?? '',
      dayDate: json['day_date'] as String? ?? '',
      itemIds: _parseStringList(json['item_ids']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_label': dayLabel,
      'day_date': dayDate,
      if (itemIds.isNotEmpty) 'item_ids': itemIds,
    };
  }
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    final ms = value > 100000000000 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
  }
  if (value is num) {
    final ms = value > 100000000000 ? value.toInt() : (value * 1000).toInt();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    return switch (value.toLowerCase().trim()) {
      'true' || 'yes' || 'y' || '1' || 'done' || 'completed' => true,
      _ => false,
    };
  }
  return false;
}

List<T> _parseList<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (raw is! List) return <T>[];
  final out = <T>[];
  for (final item in raw) {
    if (item is Map) {
      out.add(fromJson(Map<String, dynamic>.from(item)));
    }
  }
  return out;
}

List<String> _parseStringList(dynamic raw) {
  if (raw is! List) return const <String>[];
  return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
}
