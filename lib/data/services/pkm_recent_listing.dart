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
}) {
  if (cache == null) return false;
  if (cache.userId != userId) return false;
  return now.difference(cache.cachedAt) < ttl;
}
