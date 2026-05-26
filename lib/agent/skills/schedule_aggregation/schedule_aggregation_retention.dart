const Duration scheduleFloatingItemRetention = Duration(days: 7);

const String scheduleDisplayUntilKey = 'display_until';
const String scheduleDisplayFirstSeenKey = 'display_first_seen_at';

Map<String, dynamic> applyScheduleDisplayRetention({
  required Map<String, dynamic> yamlData,
  Iterable<Map<String, dynamic>> previousAggregations = const [],
  DateTime? now,
  Duration retention = scheduleFloatingItemRetention,
}) {
  final generatedAt =
      _parseDateTime(yamlData['generated_at']) ?? now ?? DateTime.now();
  final expiryReferenceDate = now ?? generatedAt;
  final history = _buildRetentionHistory(
    previousAggregations,
    retention: retention,
  );
  final normalized = _copyMap(yamlData);
  final timeline = normalized['timeline'];
  if (timeline is! List) return normalized;

  final normalizedDays = <Map<String, dynamic>>[];
  for (final rawDay in timeline) {
    if (rawDay is! Map) continue;
    final day = Map<String, dynamic>.from(rawDay);
    final items = day['items'];
    if (items is! List) {
      normalizedDays.add(day);
      continue;
    }

    final retainedItems = <Map<String, dynamic>>[];
    for (final rawItem in items) {
      if (rawItem is! Map) continue;
      final item = Map<String, dynamic>.from(rawItem);
      if (!_isFloatingLongTermItem(day, item)) {
        retainedItems.add(item);
        continue;
      }

      final key = _retentionKey(item);
      final record = key == null ? null : history[key];
      final firstSeenAt = record?.firstSeenAt ??
          _parseDateTime(item[scheduleDisplayFirstSeenKey]) ??
          generatedAt;
      final displayUntil = record?.displayUntil ??
          _parseDateTime(item[scheduleDisplayUntilKey]) ??
          _retentionEndDate(firstSeenAt, retention);

      if (_isExpired(displayUntil, expiryReferenceDate)) {
        continue;
      }

      item[scheduleDisplayFirstSeenKey] = _formatDate(firstSeenAt);
      item[scheduleDisplayUntilKey] = _formatDate(displayUntil);
      retainedItems.add(item);
    }

    if (retainedItems.isNotEmpty) {
      day['items'] = retainedItems;
      normalizedDays.add(day);
    }
  }

  normalized['timeline'] = normalizedDays;
  return normalized;
}

Map<String, _RetentionRecord> _buildRetentionHistory(
  Iterable<Map<String, dynamic>> previousAggregations, {
  required Duration retention,
}) {
  final sorted = previousAggregations.toList()
    ..sort((a, b) {
      final aTime = _parseDateTime(a['generated_at']) ?? DateTime(0);
      final bTime = _parseDateTime(b['generated_at']) ?? DateTime(0);
      return aTime.compareTo(bTime);
    });

  final records = <String, _RetentionRecord>{};
  for (final aggregation in sorted) {
    final generatedAt = _parseDateTime(aggregation['generated_at']);
    if (generatedAt == null) continue;
    final timeline = aggregation['timeline'];
    if (timeline is! List) continue;

    for (final rawDay in timeline) {
      if (rawDay is! Map) continue;
      final day = Map<String, dynamic>.from(rawDay);
      final items = day['items'];
      if (items is! List) continue;

      for (final rawItem in items) {
        if (rawItem is! Map) continue;
        final item = Map<String, dynamic>.from(rawItem);
        if (!_isFloatingLongTermItem(day, item)) continue;

        final key = _retentionKey(item);
        if (key == null || records.containsKey(key)) continue;

        final firstSeenAt =
            _parseDateTime(item[scheduleDisplayFirstSeenKey]) ?? generatedAt;
        final displayUntil = _parseDateTime(item[scheduleDisplayUntilKey]) ??
            _retentionEndDate(firstSeenAt, retention);
        records[key] = _RetentionRecord(
          firstSeenAt: firstSeenAt,
          displayUntil: displayUntil,
        );
      }
    }
  }

  return records;
}

bool _isFloatingLongTermItem(
  Map<String, dynamic> day,
  Map<String, dynamic> item,
) {
  final type = item['type']?.toString().toLowerCase().trim();
  if (type == 'task' || type == 'todo') return false;
  return !_hasConcreteDate(day, item);
}

bool _hasConcreteDate(Map<String, dynamic> day, Map<String, dynamic> item) {
  final itemStartTime = _nonEmptyString(item['start_time']);
  if (itemStartTime != null && _parseDateTime(itemStartTime) != null) {
    return true;
  }
  final dayDate = _nonEmptyString(day['day_date']);
  return dayDate != null && _parseDateTime(dayDate) != null;
}

String? _retentionKey(Map<String, dynamic> item) {
  final cardId = _nonEmptyString(item['card_id']);
  if (cardId != null) return 'card:$cardId';

  final title = _nonEmptyString(item['title']);
  if (title == null) return null;
  final type = item['type']?.toString().trim().toLowerCase() ?? 'event';
  return 'fallback:$type:$title';
}

DateTime _retentionEndDate(DateTime firstSeenAt, Duration retention) {
  final end = firstSeenAt.add(retention);
  return DateTime(end.year, end.month, end.day);
}

bool _isExpired(DateTime displayUntil, DateTime generatedAt) {
  final generatedDay = DateTime(
    generatedAt.year,
    generatedAt.month,
    generatedAt.day,
  );
  final untilDay = DateTime(
    displayUntil.year,
    displayUntil.month,
    displayUntil.day,
  );
  return generatedDay.isAfter(untilDay);
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    final milliseconds = value > 100000000000 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal();
  }
  if (value is num) {
    final milliseconds = value > 100000000000 ? value.toInt() : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds.toInt()).toLocal();
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed);
  }
  return null;
}

String? _nonEmptyString(dynamic value) {
  if (value == null) return null;
  final string = value.toString().trim();
  return string.isEmpty ? null : string;
}

Map<String, dynamic> _copyMap(Map<String, dynamic> value) {
  return {
    for (final entry in value.entries) entry.key: _copyValue(entry.value),
  };
}

dynamic _copyValue(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(
      value.map((key, inner) => MapEntry(key.toString(), _copyValue(inner))),
    );
  }
  if (value is List) {
    return value.map(_copyValue).toList();
  }
  return value;
}

String _formatDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class _RetentionRecord {
  const _RetentionRecord({
    required this.firstSeenAt,
    required this.displayUntil,
  });

  final DateTime firstSeenAt;
  final DateTime displayUntil;
}
