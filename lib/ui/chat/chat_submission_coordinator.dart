import 'dart:async';

import 'package:memex/data/model/chat_events.dart';

/// Serializes only initial session creation. Once the first request reports
/// its session, later requests can prepare concurrently in that same session.
class ChatSubmissionCoordinator {
  Future<void>? _sessionPending;
  String? _createdSessionId;
  bool _disposed = false;

  Stream<ChatEvent> submit({
    required String? sessionId,
    required Stream<ChatEvent> Function(String? sessionId) send,
  }) {
    if (_disposed) return const Stream.empty();
    if (sessionId != null) return send(sessionId);
    final previous = _sessionPending;
    final ready = Completer<void>();
    _sessionPending = ready.future;
    StreamSubscription<ChatEvent>? inner;
    var cancelled = false;
    late final StreamController<ChatEvent> output;

    void releaseSession() {
      if (!ready.isCompleted) ready.complete();
      if (_sessionPending == ready.future) _sessionPending = null;
    }

    Future<void> start() async {
      try {
        if (previous != null) await previous;
        if (_disposed || cancelled) {
          releaseSession();
          unawaited(output.close());
          return;
        }
        inner = send(_createdSessionId).listen(
          (event) {
            if (event is ChatSessionCreatedEvent) {
              _createdSessionId = event.sessionId;
              releaseSession();
            }
            output.add(event);
          },
          onError: output.addError,
          onDone: () {
            releaseSession();
            output.close();
          },
        );
        if (output.isPaused) inner?.pause();
      } catch (error, stack) {
        releaseSession();
        output.addError(error, stack);
        unawaited(output.close());
      }
    }

    output = StreamController<ChatEvent>(
      onListen: start,
      onPause: () => inner?.pause(),
      onResume: () => inner?.resume(),
      onCancel: () {
        cancelled = true;
        // Release immediately even if the underlying I/O cannot be cancelled.
        releaseSession();
        return inner?.cancel();
      },
    );
    return output.stream;
  }

  void dispose() {
    _disposed = true;
  }
}
