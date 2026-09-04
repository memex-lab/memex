/// Runs [mapper] over [items] with a bounded number of in-flight futures.
///
/// Results stay in input order. Dart is single-threaded, so the cursor bump
/// between awaits is safe without a lock.
Future<List<T>> mapWithLimit<S, T>(
  Iterable<S> items,
  Future<T> Function(S item) mapper, {
  int limit = 6,
}) async {
  if (limit < 1) {
    throw ArgumentError.value(limit, 'limit', 'must be >= 1');
  }

  final source = items.toList(growable: false);
  if (source.isEmpty) return <T>[];

  final results = List<T?>.filled(source.length, null);
  var cursor = 0;

  Future<void> worker() async {
    while (true) {
      final index = cursor++;
      if (index >= source.length) return;
      results[index] = await mapper(source[index]);
    }
  }

  final workerCount = limit < source.length ? limit : source.length;
  await Future.wait(List.generate(workerCount, (_) => worker()));
  return results.cast<T>();
}
