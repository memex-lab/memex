import 'package:flutter/foundation.dart';
import 'package:memex/data/model/chat_events.dart';

enum ChatTurnPhase { preparing, queued, running, completed, failed }

/// Per-request lifecycle. Closing one run never clears another request's
/// attachment preparation or a different run's queued work.
class ChatTurnViewModel extends ChangeNotifier {
  final Map<String, ChatTurnPhase> _phases = {};
  final Map<String, String> _runs = {};

  ChatTurnPhase? phaseOf(String turnId) => _phases[turnId];
  bool get hasPending => _phases.values.any((phase) =>
      phase == ChatTurnPhase.preparing ||
      phase == ChatTurnPhase.queued ||
      phase == ChatTurnPhase.running);
  bool get hasPreparing => _phases.containsValue(ChatTurnPhase.preparing);
  bool get hasQueued => _phases.containsValue(ChatTurnPhase.queued);
  bool get hasRunning => _phases.containsValue(ChatTurnPhase.running);

  void prepare(String turnId) {
    _phases.putIfAbsent(turnId, () => ChatTurnPhase.preparing);
    notifyListeners();
  }

  void handle(ChatEvent event, {required String runId}) {
    if (event is ChatTurnPreparingEvent) {
      prepare(event.turnId);
      return;
    }
    String? turnId;
    ChatTurnPhase? phase;
    if (event is ChatTurnQueuedEvent) {
      turnId = event.turnId;
      // A fast worker can start/finish before enqueue acknowledgement arrives.
      phase = ChatTurnPhase.queued;
    } else if (event is ChatAgentStartedEvent) {
      turnId = event.turnId;
      phase = ChatTurnPhase.running;
    } else if (event is ChatAgentStoppedEvent) {
      turnId = event.turnId;
      phase = ChatTurnPhase.completed;
    } else if (event is ChatErrorEvent) {
      turnId = event.turnId;
      phase = ChatTurnPhase.failed;
    }
    if (turnId == null || phase == null) return;
    final previous = _phases[turnId];
    if (phase == ChatTurnPhase.queued &&
        previous != null &&
        previous.index > phase.index) {
      return;
    }
    _phases[turnId] = phase;
    _runs[turnId] = event is ChatTurnQueuedEvent ? event.runId : runId;
    notifyListeners();
  }

  void fail(String turnId) {
    _phases[turnId] = ChatTurnPhase.failed;
    notifyListeners();
  }

  void finishRun(String runId) {
    for (final entry in _runs.entries) {
      if (entry.value == runId &&
          (_phases[entry.key] == ChatTurnPhase.queued ||
              _phases[entry.key] == ChatTurnPhase.running)) {
        _phases[entry.key] = ChatTurnPhase.completed;
      }
    }
    notifyListeners();
  }

  void finishPreparation(String? turnId) {
    if (turnId != null && _phases[turnId] == ChatTurnPhase.preparing) {
      fail(turnId);
    }
  }
}
