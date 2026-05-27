Map<String, dynamic> normalizeScheduleAggregationYaml(
  Map<String, dynamic> yaml,
) {
  final normalized = Map<String, dynamic>.from(yaml);
  final conflictResult = _normalizeConflicts(normalized['conflicts']);
  final completed = _normalizeCompleted(normalized['completed']);

  normalized['completed'] = completed;
  normalized['timeline'] = _normalizeTimeline(
    normalized['timeline'],
    completedIds: _collectItemIds(completed),
    duplicateConflictIds: conflictResult.duplicateItemIds,
    hasGlobalDuplicateAdvisory: conflictResult.hasDuplicateAdvisory,
  );
  normalized['conflicts'] = conflictResult.conflicts;

  return normalized;
}

List<Map<String, dynamic>> _normalizeCompleted(dynamic value) {
  if (value is! List) return const [];

  final mergedByKey = <String, Map<String, dynamic>>{};
  final order = <String>[];
  var fallbackIndex = 0;

  for (final itemValue in value) {
    final item = _asMap(itemValue);
    if (item == null) continue;
    final id = _readItemId(item);
    final key = id == null ? 'completed_index_${fallbackIndex++}' : 'id:$id';
    if (!mergedByKey.containsKey(key)) {
      order.add(key);
      mergedByKey[key] = item;
    } else {
      mergedByKey[key] = _mergeScheduleItem(mergedByKey[key]!, item);
    }
  }

  return [
    for (final key in order)
      if (mergedByKey[key] != null) mergedByKey[key]!,
  ];
}

List<Map<String, dynamic>> _normalizeTimeline(
  dynamic value, {
  required Set<String> completedIds,
  required Set<String> duplicateConflictIds,
  required bool hasGlobalDuplicateAdvisory,
}) {
  if (value is! List) return const [];

  final mergedByKey = <String, Map<String, dynamic>>{};
  final winnerByKey = <String, _TimelineEntry>{};

  for (final dayEntry in value.indexed) {
    final day = _asMap(dayEntry.$2);
    if (day == null) continue;
    final items = day['items'];
    if (items is! List) continue;

    for (final itemEntry in items.indexed) {
      final item = _asMap(itemEntry.$2);
      if (item == null) continue;
      final id = _readItemId(item);
      if (id != null && completedIds.contains(id)) continue;

      final key = _timelineItemKey(
        item,
        duplicateConflictIds: duplicateConflictIds,
        hasGlobalDuplicateAdvisory: hasGlobalDuplicateAdvisory,
      );
      if (key == null) continue;

      final entry = _TimelineEntry(
        dayIndex: dayEntry.$1,
        itemIndex: itemEntry.$1,
      );
      mergedByKey[key] = mergedByKey.containsKey(key)
          ? _mergeScheduleItem(mergedByKey[key]!, item)
          : item;
      winnerByKey[key] = entry;
    }
  }

  final normalizedDays = <Map<String, dynamic>>[];
  for (final dayEntry in value.indexed) {
    final day = _asMap(dayEntry.$2);
    if (day == null) continue;
    final items = day['items'];
    if (items is! List) continue;

    final normalizedItems = <Map<String, dynamic>>[];
    for (final itemEntry in items.indexed) {
      final item = _asMap(itemEntry.$2);
      if (item == null) continue;
      final id = _readItemId(item);
      if (id != null && completedIds.contains(id)) continue;

      final key = _timelineItemKey(
        item,
        duplicateConflictIds: duplicateConflictIds,
        hasGlobalDuplicateAdvisory: hasGlobalDuplicateAdvisory,
      );
      if (key == null) {
        normalizedItems.add(item);
        continue;
      }

      final winner = winnerByKey[key];
      if (winner != null &&
          winner.dayIndex == dayEntry.$1 &&
          winner.itemIndex == itemEntry.$1) {
        normalizedItems.add(mergedByKey[key]!);
      }
    }

    if (normalizedItems.isNotEmpty) {
      normalizedDays.add({...day, 'items': normalizedItems});
    }
  }

  return normalizedDays;
}

_ConflictNormalization _normalizeConflicts(dynamic value) {
  if (value is! List) {
    return const _ConflictNormalization(conflicts: []);
  }

  final conflicts = <Map<String, dynamic>>[];
  final duplicateItemIds = <String>{};
  var hasDuplicateAdvisory = false;

  for (final conflictValue in value) {
    final conflict = _asMap(conflictValue);
    if (conflict == null) continue;
    final itemIds = _readItemIds(conflict);
    if (_isDuplicateAdvisoryConflict(conflict, itemIds)) {
      duplicateItemIds.addAll(itemIds);
      hasDuplicateAdvisory = true;
      continue;
    }
    conflicts.add(conflict);
  }

  return _ConflictNormalization(
    conflicts: conflicts,
    duplicateItemIds: duplicateItemIds,
    hasDuplicateAdvisory: hasDuplicateAdvisory,
  );
}

bool _isDuplicateAdvisoryConflict(
  Map<String, dynamic> conflict,
  List<String> itemIds,
) {
  if (itemIds.toSet().length != itemIds.length) return true;

  final description = (conflict['description'] ?? '').toString().toLowerCase();
  return _duplicateAdvisoryTerms.any(description.contains);
}

String? _timelineItemKey(
  Map<String, dynamic> item, {
  required Set<String> duplicateConflictIds,
  required bool hasGlobalDuplicateAdvisory,
}) {
  final id = _readItemId(item);
  final semanticKey = _semanticTimelineItemKey(item);
  if (semanticKey != null &&
      ((id != null && duplicateConflictIds.contains(id)) ||
          (id == null && hasGlobalDuplicateAdvisory))) {
    return 'semantic:$semanticKey';
  }
  if (id != null) return 'id:$id';
  if (semanticKey != null) return 'semantic:$semanticKey';
  return null;
}

String? _semanticTimelineItemKey(Map<String, dynamic> item) {
  final title = _normalizeText(item['title']);
  final startTime = _normalizeText(item['start_time']);
  if (title.isEmpty || startTime.isEmpty) return null;

  final type = _normalizeText(item['type']);
  return '${type.isEmpty ? 'item' : type}|$startTime|$title';
}

Map<String, dynamic> _mergeScheduleItem(
  Map<String, dynamic> base,
  Map<String, dynamic> incoming,
) {
  final merged = Map<String, dynamic>.from(base);
  for (final entry in incoming.entries) {
    if (_hasMeaningfulValue(entry.value)) {
      merged[entry.key] = entry.value;
    }
  }
  return merged;
}

bool _hasMeaningfulValue(dynamic value) {
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  if (value is Iterable) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  return true;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

String? _readItemId(Map<String, dynamic> value) {
  final id = (value['card_id'] ?? value['id'])?.toString().trim();
  return id == null || id.isEmpty ? null : id;
}

List<String> _readItemIds(Map<String, dynamic> conflict) {
  final itemIds = conflict['item_ids'];
  if (itemIds is! List) return const [];
  return itemIds
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

Set<String> _collectItemIds(List<Map<String, dynamic>> items) {
  return {
    for (final item in items)
      if (_readItemId(item) != null) _readItemId(item)!,
  };
}

String _normalizeText(dynamic value) {
  if (value == null) return '';
  return value.toString().trim().toLowerCase();
}

const _duplicateAdvisoryTerms = [
  'duplicate',
  'duplicated',
  'duplication',
  'rebuild',
  'rebuilt',
  'regenerated',
  'recreated',
  'previous version',
  'current version',
  '重复',
  '重建',
  '重新生成',
  '再生成',
  '旧版本',
  '新版本',
  '当前版本',
];

class _ConflictNormalization {
  const _ConflictNormalization({
    required this.conflicts,
    this.duplicateItemIds = const {},
    this.hasDuplicateAdvisory = false,
  });

  final List<Map<String, dynamic>> conflicts;
  final Set<String> duplicateItemIds;
  final bool hasDuplicateAdvisory;
}

class _TimelineEntry {
  const _TimelineEntry({required this.dayIndex, required this.itemIndex});

  final int dayIndex;
  final int itemIndex;
}
