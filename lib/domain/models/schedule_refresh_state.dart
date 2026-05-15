class ScheduleRefreshState {
  const ScheduleRefreshState({
    required this.isDirty,
    this.reason,
    this.dirtySince,
    this.updatedAt,
    this.lastClearedAt,
    this.lastAggregationId,
    this.cardIds = const [],
    this.refreshRequested = false,
  });

  factory ScheduleRefreshState.clean() {
    return ScheduleRefreshState(
      isDirty: false,
      updatedAt: DateTime.now(),
    );
  }

  factory ScheduleRefreshState.fromJson(Map<String, dynamic> json) {
    return ScheduleRefreshState(
      isDirty: json['is_dirty'] as bool? ?? false,
      reason: json['reason'] as String?,
      dirtySince: _parseDateTime(json['dirty_since']),
      updatedAt: _parseDateTime(json['updated_at']),
      lastClearedAt: _parseDateTime(json['last_cleared_at']),
      lastAggregationId: json['last_aggregation_id'] as String?,
      cardIds: (json['card_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      refreshRequested: json['refresh_requested'] as bool? ?? false,
    );
  }

  final bool isDirty;
  final String? reason;
  final DateTime? dirtySince;
  final DateTime? updatedAt;
  final DateTime? lastClearedAt;
  final String? lastAggregationId;
  final List<String> cardIds;
  final bool refreshRequested;

  Map<String, dynamic> toJson() {
    return {
      'is_dirty': isDirty,
      if (reason != null) 'reason': reason,
      if (dirtySince != null) 'dirty_since': dirtySince!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (lastClearedAt != null)
        'last_cleared_at': lastClearedAt!.toIso8601String(),
      if (lastAggregationId != null) 'last_aggregation_id': lastAggregationId,
      if (cardIds.isNotEmpty) 'card_ids': cardIds,
      'refresh_requested': refreshRequested,
    };
  }

  ScheduleRefreshState copyWith({
    bool? isDirty,
    String? reason,
    DateTime? dirtySince,
    DateTime? updatedAt,
    DateTime? lastClearedAt,
    String? lastAggregationId,
    List<String>? cardIds,
    bool? refreshRequested,
    bool clearReason = false,
    bool clearDirtySince = false,
  }) {
    return ScheduleRefreshState(
      isDirty: isDirty ?? this.isDirty,
      reason: clearReason ? null : reason ?? this.reason,
      dirtySince: clearDirtySince ? null : dirtySince ?? this.dirtySince,
      updatedAt: updatedAt ?? this.updatedAt,
      lastClearedAt: lastClearedAt ?? this.lastClearedAt,
      lastAggregationId: lastAggregationId ?? this.lastAggregationId,
      cardIds: cardIds ?? this.cardIds,
      refreshRequested: refreshRequested ?? this.refreshRequested,
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
