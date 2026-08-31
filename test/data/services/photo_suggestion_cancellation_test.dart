import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/photo_suggestion_service.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  test('cancels every registered native request exactly once', () async {
    final cancelled = <PMCancelToken>[];
    final token = PhotoSuggestionCancellationToken(
      cancelRequest: (request) async => cancelled.add(request),
    );
    final first = PMCancelToken(debugLabel: 'first');
    final second = PMCancelToken(debugLabel: 'second');

    expect(token.registerNativeRequest(first), isTrue);
    expect(token.registerNativeRequest(second), isTrue);

    token.cancel();
    token.cancel();
    await Future<void>.delayed(Duration.zero);

    expect(cancelled, containsAllInOrder([first, second]));
  });

  test('does not cancel a native request after it is unregistered', () async {
    final cancelled = <PMCancelToken>[];
    final token = PhotoSuggestionCancellationToken(
      cancelRequest: (request) async => cancelled.add(request),
    );
    final request = PMCancelToken(debugLabel: 'completed');

    expect(token.registerNativeRequest(request), isTrue);
    token.unregisterNativeRequest(request);
    token.cancel();
    await Future<void>.delayed(Duration.zero);

    expect(cancelled, isEmpty);
  });

  test('immediately rejects and cancels requests registered after cancellation',
      () async {
    final cancelled = <PMCancelToken>[];
    final token = PhotoSuggestionCancellationToken(
      cancelRequest: (request) async => cancelled.add(request),
    );
    final request = PMCancelToken(debugLabel: 'late');

    token.cancel();
    expect(token.registerNativeRequest(request), isFalse);
    await Future<void>.delayed(Duration.zero);

    expect(cancelled, [request]);
  });
}
