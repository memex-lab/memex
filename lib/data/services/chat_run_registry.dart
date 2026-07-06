import 'dart:async';

import 'package:memex/data/model/chat_events.dart';

/// One in-flight agent chat turn, owned by the service layer so it survives
/// the chat dialog being closed.
///
/// Events are usually appended to a replay buffer and forwarded to a broadcast
/// stream. [attach] returns a stream that first replays buffered events and
/// then continues live — this is what lets a reopened dialog rebuild the
/// "thinking" UI mid-run. Persisted events can opt out of replay because the
/// session history is their source of truth after a dialog reopens. The
/// snapshot+subscribe happens in one synchronous block, so no event can be
/// dropped or duplicated in between.
class ActiveChatRun {
  ActiveChatRun(this.sessionId, {void Function()? onClosed})
      : _onClosed = onClosed;

  final String sessionId;
  final DateTime startedAt = DateTime.now();
  final List<ChatEvent> _replayBuffer = [];
  final StreamController<ChatEvent> _live =
      StreamController<ChatEvent>.broadcast();
  final void Function()? _onClosed;
  bool _closed = false;

  bool get isClosed => _closed;

  void add(ChatEvent event, {bool replay = true}) {
    if (_closed) return;
    if (replay) {
      _replayBuffer.add(event);
    }
    _live.add(event);
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _live.close();
    _onClosed?.call();
  }

  Stream<ChatEvent> attach() {
    final out = StreamController<ChatEvent>();
    // Synchronous block: snapshot and live subscription cannot interleave
    // with event delivery on Dart's single-threaded event loop.
    final snapshot = List<ChatEvent>.from(_replayBuffer);
    StreamSubscription<ChatEvent>? liveSub;
    if (!_closed) {
      liveSub = _live.stream.listen(
        out.add,
        onError: out.addError,
        onDone: () => out.close(),
      );
    }
    for (final event in snapshot) {
      out.add(event);
    }
    if (_closed) {
      out.close();
    }
    out.onCancel = () => liveSub?.cancel();
    return out.stream;
  }
}

/// Service-level registry of in-flight chat runs, keyed by session id.
class ChatRunRegistry {
  final Map<String, ActiveChatRun> _runs = {};

  bool isActive(String sessionId) => _runs.containsKey(sessionId);

  ActiveChatRun? operator [](String sessionId) => _runs[sessionId];

  /// Creates and registers a run for [sessionId]. The run removes itself on
  /// close.
  ActiveChatRun start(String sessionId) {
    late final ActiveChatRun run;
    run = ActiveChatRun(
      sessionId,
      onClosed: () {
        // Only remove if it is still the registered instance.
        if (_runs[sessionId] == run) {
          _runs.remove(sessionId);
        }
      },
    );
    _runs[sessionId] = run;
    return run;
  }

  /// Returns the active run for [sessionId], or creates one when a background
  /// task resumes without an attached chat dialog.
  ActiveChatRun getOrStart(String sessionId) =>
      _runs[sessionId] ?? start(sessionId);
}
