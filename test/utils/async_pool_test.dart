import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/async_pool.dart';

void main() {
  test('keeps input order while overlapping work', () async {
    final started = <int>[];
    var inFlight = 0;
    var maxInFlight = 0;

    final values = await mapWithLimit<int, String>(
      [1, 2, 3, 4, 5],
      (item) async {
        started.add(item);
        inFlight++;
        if (inFlight > maxInFlight) maxInFlight = inFlight;
        await Future<void>.delayed(Duration(milliseconds: 20 - item));
        inFlight--;
        return 'n$item';
      },
      limit: 3,
    );

    expect(values, ['n1', 'n2', 'n3', 'n4', 'n5']);
    expect(started.take(3).toSet(), {1, 2, 3});
    expect(maxInFlight, 3);
  });

  test('returns an empty list for empty input', () async {
    final values = await mapWithLimit<int, int>(
      const [],
      (item) async => item,
    );
    expect(values, isEmpty);
  });

  test('rejects a non-positive limit', () {
    expect(
      () => mapWithLimit<int, int>([1], (item) async => item, limit: 0),
      throwsArgumentError,
    );
  });
}
