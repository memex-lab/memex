import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/pkm_recent_listing.dart';

void main() {
  test('reuses a fresh listing for the same user', () {
    final cachedAt = DateTime.utc(2026, 9, 10, 12);
    final cache = RecentPkmCacheEntry(
      userId: 'u1',
      cachedAt: cachedAt,
      files: [
        {'name': 'note.md', 'path': 'Projects/note.md'},
      ],
    );

    expect(
      shouldReuseRecentPkmCache(
        cache: cache,
        userId: 'u1',
        now: cachedAt.add(const Duration(seconds: 5)),
      ),
      isTrue,
    );
    expect(
      shouldReuseRecentPkmCache(
        cache: cache,
        userId: 'u2',
        now: cachedAt.add(const Duration(seconds: 5)),
      ),
      isFalse,
    );
    expect(
      shouldReuseRecentPkmCache(
        cache: cache,
        userId: 'u1',
        now: cachedAt.add(const Duration(seconds: 16)),
      ),
      isFalse,
    );
    expect(
      shouldReuseRecentPkmCache(
        cache: cache,
        userId: 'u1',
        now: cachedAt.add(recentPkmCacheTtl),
      ),
      isFalse,
    );
    expect(
      shouldReuseRecentPkmCache(
        cache: cache,
        userId: 'u1',
        now: cachedAt.add(const Duration(seconds: 1)),
        forceRefresh: true,
      ),
      isFalse,
    );
  });

  test('detects PKM workspace files for cache invalidation', () {
    expect(
      isPkmWorkspaceFile('/workspace/_u1/PKM/Projects/note.md'),
      isTrue,
    );
    expect(isPkmWorkspaceFile('/workspace/_u1/Cards/2026/01/01.yaml'), isFalse);
  });
}
