class RecentPkmCacheEntry {
  const RecentPkmCacheEntry({
    required this.userId,
    required this.cachedAt,
    required this.files,
  });

  final String userId;
  final DateTime cachedAt;
  final List<Map<String, dynamic>> files;
}

const Duration recentPkmCacheTtl = Duration(seconds: 15);

bool shouldReuseRecentPkmCache({
  required RecentPkmCacheEntry? cache,
  required String userId,
  required DateTime now,
  Duration ttl = recentPkmCacheTtl,
  bool forceRefresh = false,
}) {
  if (forceRefresh) return false;
  if (cache == null) return false;
  if (cache.userId != userId) return false;
  return now.difference(cache.cachedAt) < ttl;
}

/// An in-flight listing must not write its snapshot back after a newer
/// invalidation or refresh has moved the generation forward.
bool shouldStoreRecentPkmResult({
  required int startedGeneration,
  required int currentGeneration,
}) {
  return startedGeneration == currentGeneration;
}

bool isPkmWorkspaceFile(String filePath) {
  final normalized = filePath.replaceAll('\\', '/');
  return normalized.contains('/PKM/') || normalized.endsWith('/PKM');
}
