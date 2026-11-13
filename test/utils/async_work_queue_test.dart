import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/async_work_queue.dart';

void main() {
  test('failed work releases its slot and queued work stays in order',
      () async {
    final queue = AsyncWorkQueue(maxConcurrent: 1);
    final first = Completer<int>();
    final calls = <int>[];
    final a = queue.run(() {
      calls.add(1);
      return first.future;
    });
    final failed = expectLater(a, throwsStateError);
    final b = queue.run(() async {
      calls.add(2);
      return 2;
    });
    final c = queue.run(() async {
      calls.add(3);
      return 3;
    });
    expect(calls, [1]);
    first.completeError(StateError('failure'));
    await failed;
    expect(await b, 2);
    expect(await c, 3);
    expect(calls, [1, 2, 3]);
  });
}
