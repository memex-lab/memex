const int cardCacheRebuildYieldEvery = 8;

List<String> sortCardFilesNewestFirst(List<String> paths) {
  if (paths.length <= 1) return List<String>.from(paths);
  final next = List<String>.from(paths)..sort((a, b) => b.compareTo(a));
  return next;
}

bool shouldYieldCardCacheRebuild(
  int indexedCount, {
  int every = cardCacheRebuildYieldEvery,
}) {
  return every > 0 && indexedCount > 0 && indexedCount % every == 0;
}
