import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/ui/chat/chat_submission_coordinator.dart';

void main() {
  test('rapid first sends share a session without waiting for the first reply',
      () async {
    final coordinator = ChatSubmissionCoordinator();
    final first = StreamController<ChatEvent>();
    final second = StreamController<ChatEvent>();
    final calls = <String?>[];
    final a = coordinator
        .submit(
            sessionId: null,
            send: (session) {
              calls.add(session);
              return first.stream;
            })
        .listen((_) {});
    final b = coordinator
        .submit(
            sessionId: null,
            send: (session) {
              calls.add(session);
              return second.stream;
            })
        .listen((_) {});
    await pumpEventQueue();
    expect(calls, [null]);
    first.add(ChatSessionCreatedEvent('shared'));
    await pumpEventQueue();
    expect(calls, [null, 'shared']);
    // The first response stream is still open, so we did not serialize runs.
    await a.cancel();
    await b.cancel();
    await first.close();
    await second.close();
    coordinator.dispose();
  });

  test('failed session creation releases the next send', () async {
    final coordinator = ChatSubmissionCoordinator();
    final calls = <String?>[];
    final first = coordinator
        .submit(
            sessionId: null,
            send: (_) => Stream.value(ChatErrorEvent('first', 'failed')))
        .toList();
    final second = coordinator
        .submit(
            sessionId: null,
            send: (session) {
              calls.add(session);
              return Stream.value(ChatSessionCreatedEvent('retry'));
            })
        .toList();
    await Future.wait([first, second]);
    expect(calls, [null]);
    coordinator.dispose();
  });

  test('disposing does not start a waiting send', () async {
    final coordinator = ChatSubmissionCoordinator();
    final first = StreamController<ChatEvent>();
    var secondStarted = false;
    final a = coordinator
        .submit(sessionId: null, send: (_) => first.stream)
        .listen((_) {});
    final b = coordinator
        .submit(
            sessionId: null,
            send: (_) {
              secondStarted = true;
              return const Stream.empty();
            })
        .toList();
    await pumpEventQueue();
    coordinator.dispose();
    await a.cancel();
    await b;
    await first.close();
    expect(secondStarted, isFalse);
  });
}
