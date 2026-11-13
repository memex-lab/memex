const int cardCacheRebuildYieldEvery = 8;

List<String> sortCardFilesNewestFirst(List<String> paths) {
  if (paths.length <= 1) return List<String>.from(paths);
  final next = List<String>.from(paths)..sort(compareCardFilesNewestFirst);
  return next;
}

final _cardFileOrder = RegExp(
  r'(\d{4})[\\/](\d{2})[\\/](\d{2})_ts_(\d+)\.yaml$',
);

/// Newest calendar day first, then the numeric `ts_N` on that day.
/// A string sort puts `ts_9` ahead of `ts_10`.
int compareCardFilesNewestFirst(String a, String b) {
  final left = _cardFileOrder.firstMatch(a);
  final right = _cardFileOrder.firstMatch(b);
  if (left == null || right == null) return b.compareTo(a);
  for (var group = 1; group <= 3; group++) {
    final compared =
        int.parse(right.group(group)!).compareTo(int.parse(left.group(group)!));
    if (compared != 0) return compared;
  }
  return int.parse(right.group(4)!).compareTo(int.parse(left.group(4)!));
}

/// Same order as [CardDao.getCards]: newer timestamp first, then fact id
/// descending as text. `ts_99` sorts ahead of `ts_100` when the timestamps match.
int compareCardCacheRows({
  required int timestamp,
  required String factId,
  required int otherTimestamp,
  required String otherFactId,
}) {
  final byTime = otherTimestamp.compareTo(timestamp);
  if (byTime != 0) return byTime;
  return otherFactId.compareTo(factId);
}

bool cardCacheNeedsRebuild({
  required bool cacheEmpty,
  required bool rebuildInterrupted,
}) {
  return cacheEmpty || rebuildInterrupted;
}

bool shouldYieldCardCacheRebuild(
  int indexedCount, {
  int every = cardCacheRebuildYieldEvery,
}) {
  return every > 0 && indexedCount > 0 && indexedCount % every == 0;
}

bool timelineQueryNeedsFullCardCache({
  int page = 1,
  List<String>? tags,
  DateTime? dateFrom,
  DateTime? dateTo,
}) {
  if (page > 1) return true;
  if (tags != null && tags.isNotEmpty) return true;
  return dateFrom != null || dateTo != null;
}
