import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

const int cardCacheRebuildYieldEvery = 8;

/// A first-page reader waits for its own limit, regardless of which request
/// started the rebuild. Filtered and unbounded queries wait for completion.
class CardCacheRebuildProgress {
  final _done = Completer<void>();
  final _pages = <int, Completer<void>>{};
  int _indexed = 0;
  int get indexed => _indexed;

  Future<void> waitFor(int? limit) {
    if (limit == null || limit < 0) return _done.future;
    if (_done.isCompleted || limit <= _indexed) return Future.value();
    return _pages.putIfAbsent(limit, Completer<void>.new).future;
  }

  void cardIndexed() {
    _pages.remove(++_indexed)?.complete();
  }

  void finish() {
    for (final page in _pages.values) {
      page.complete();
    }
    _pages.clear();
    _done.complete();
  }
}

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

// Current files put both sort fields first. Older files can have large UI
// configurations before created_at, or omit it entirely. Stop at a complete
// YAML prefix containing the sort key; never infer a timestamp from the path.
Future<int?> readCardCacheSortTime(File file) async {
  final input = await file.open();
  Stream<List<int>> chunks() async* {
    var size = 1024;
    while (true) {
      final bytes = await input.read(size);
      if (bytes.isEmpty) return;
      yield bytes;
      if (bytes.length < size) return;
      size = 16384;
    }
  }

  final prefix = StringBuffer();
  try {
    final lines =
        chunks().transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in lines) {
      prefix.writeln(line);
      if (line.startsWith('created_at:')) {
        try {
          final fields = loadYaml(prefix.toString());
          if (fields is Map && fields.containsKey('created_at')) {
            final time = fields['created_at'] ?? fields['timestamp'];
            if (time is int) return time;
          }
        } on YamlException {
          // A multiline value may contain this text before the actual key.
        }
      }
    }
    // Preserve full YAML semantics for imported layouts and the timestamp-only
    // legacy format. Only one such document is materialized at a time.
    final fields = loadYaml(prefix.toString());
    if (fields is! Map || fields.isEmpty) return null;
    final time = fields['created_at'] ?? fields['timestamp'] ?? 0;
    return time is int ? time : null;
  } finally {
    await input.close();
  }
}
