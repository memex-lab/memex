import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/card_cache_rebuild.dart';

void main() {
  test('sorts card files newest-first by path', () {
    final original = [
      '/Cards/2024/01/01_ts_1.yaml',
      '/Cards/2026/09/10_ts_2.yaml',
      '/Cards/2025/12/31_ts_9.yaml',
    ];
    expect(
      sortCardFilesNewestFirst(original),
      [
        '/Cards/2026/09/10_ts_2.yaml',
        '/Cards/2025/12/31_ts_9.yaml',
        '/Cards/2024/01/01_ts_1.yaml',
      ],
    );
    expect(original, [
      '/Cards/2024/01/01_ts_1.yaml',
      '/Cards/2026/09/10_ts_2.yaml',
      '/Cards/2025/12/31_ts_9.yaml',
    ]);
  });

  test('sortCardFilesNewestFirst copies empty and single-item lists', () {
    expect(sortCardFilesNewestFirst(const []), isEmpty);
    expect(sortCardFilesNewestFirst(['/Cards/2026/09/10_ts_1.yaml']), [
      '/Cards/2026/09/10_ts_1.yaml',
    ]);
  });

  test('orders a tied timestamp like the card query, ts_99 before ts_100', () {
    final order = compareCardCacheRows(
      timestamp: 1781971200,
      factId: '2026/09/10.md#ts_100',
      otherTimestamp: 1781971200,
      otherFactId: '2026/09/10.md#ts_99',
    );
    expect(order, greaterThan(0));
    expect(
      compareCardCacheRows(
        timestamp: 20,
        factId: '2026/09/10.md#ts_1',
        otherTimestamp: 10,
        otherFactId: '2026/09/10.md#ts_100',
      ),
      lessThan(0),
    );
  });

  test('orders ts_10 ahead of ts_9 on the same day', () {
    expect(
      sortCardFilesNewestFirst([
        '/Cards/2026/09/10_ts_9.yaml',
        '/Cards/2026/09/10_ts_10.yaml',
      ]),
      [
        '/Cards/2026/09/10_ts_10.yaml',
        '/Cards/2026/09/10_ts_9.yaml',
      ],
    );
  });

  test('an interrupted rebuild is not treated as a finished cache', () {
    expect(
      cardCacheNeedsRebuild(cacheEmpty: false, rebuildInterrupted: true),
      isTrue,
    );
    expect(
      cardCacheNeedsRebuild(cacheEmpty: false, rebuildInterrupted: false),
      isFalse,
    );
  });

  test('yields every eight indexed cards', () {
    expect(shouldYieldCardCacheRebuild(0), isFalse);
    expect(shouldYieldCardCacheRebuild(7), isFalse);
    expect(shouldYieldCardCacheRebuild(8), isTrue);
    expect(shouldYieldCardCacheRebuild(16), isTrue);
  });

  test('waits for a full index on filtered or later pages', () {
    expect(timelineQueryNeedsFullCardCache(), isFalse);
    expect(timelineQueryNeedsFullCardCache(page: 2), isTrue);
    expect(timelineQueryNeedsFullCardCache(tags: ['work']), isTrue);
    expect(
      timelineQueryNeedsFullCardCache(dateFrom: DateTime.utc(2026, 1, 1)),
      isTrue,
    );
  });
}
