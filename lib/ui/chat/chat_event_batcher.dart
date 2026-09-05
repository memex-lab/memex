import 'dart:async';

import 'package:memex/data/model/chat_events.dart';

/// Coalesces high-frequency chat stream events so the dialog can apply them
/// in one `setState` per frame instead of once per token.
class ChatEventBatcher {
  ChatEventBatcher({
    required this.apply,
    required this.onFlush,
    this.interval = const Duration(milliseconds: 32),
    this.flushImmediately,
  });

  final void Function(ChatEvent event) apply;
  final void Function() onFlush;
  final Duration interval;
  final bool Function(ChatEvent event)? flushImmediately;

  final List<ChatEvent> _pending = [];
  Timer? _timer;
  bool _disposed = false;

  void add(ChatEvent event) {
    if (_disposed) return;
    final immediate = flushImmediately?.call(event) ??
        event is ChatAgentStartedEvent ||
            event is ChatAgentStoppedEvent ||
            event is ChatErrorEvent ||
            event is ChatSessionCreatedEvent;
    if (immediate) {
      flush();
      apply(event);
      onFlush();
      return;
    }
    _pending.add(event);
    _timer ??= Timer(interval, flush);
  }

  void flush() {
    _timer?.cancel();
    _timer = null;
    if (_pending.isEmpty) return;
    final batch = List<ChatEvent>.of(_pending);
    _pending.clear();
    for (final event in batch) {
      apply(event);
    }
    onFlush();
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _pending.clear();
  }
}
