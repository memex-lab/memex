import 'dart:async';
import 'dart:collection';

/// Runs independent jobs with bounded concurrency, in arrival order.
class AsyncWorkQueue {
  AsyncWorkQueue({required this.maxConcurrent}) : assert(maxConcurrent > 0);

  final int maxConcurrent;
  final Queue<void Function()> _waiting = Queue();
  int _active = 0;

  Future<T> run<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _waiting.add(() {
      _active++;
      Future<T>.sync(action)
          .then(result.complete, onError: result.completeError)
          .whenComplete(() {
        _active--;
        _pump();
      });
    });
    _pump();
    return result.future;
  }

  void _pump() {
    while (_active < maxConcurrent && _waiting.isNotEmpty) {
      _waiting.removeFirst()();
    }
  }
}
