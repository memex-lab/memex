import 'package:memex/domain/models/character_initiative.dart';

enum CharacterConversationAction {
  speak,
  thinkLater,
  stayQuiet,
}

/// One speaking decision for a batch of pending private-chat messages.
/// Infrastructure tracks whether the batch was handled; relationship and
/// emotional interpretation remain in the character's narrative memory.
class CharacterConversationDecision {
  const CharacterConversationDecision._({
    required this.action,
    this.messages = const [],
    this.wakeAt,
    this.reason,
  });

  CharacterConversationDecision.speak(List<String> messages)
      : this._(
          action: CharacterConversationAction.speak,
          messages: List.unmodifiable(messages),
        );

  const CharacterConversationDecision.thinkLater({
    required DateTime wakeAt,
    required String reason,
  }) : this._(
          action: CharacterConversationAction.thinkLater,
          wakeAt: wakeAt,
          reason: reason,
        );

  const CharacterConversationDecision.stayQuiet({required String reason})
      : this._(
          action: CharacterConversationAction.stayQuiet,
          reason: reason,
        );

  final CharacterConversationAction action;
  final List<String> messages;
  final DateTime? wakeAt;
  final String? reason;
}

class CharacterConversationContext {
  const CharacterConversationContext({
    required this.sourceEventId,
    required this.now,
    required this.incomingMessages,
    this.recentPrivateChat = const [],
    this.deferredReason,
  });

  final String sourceEventId;
  final DateTime now;
  final List<CharacterConversationTurn> incomingMessages;
  final List<CharacterConversationTurn> recentPrivateChat;
  final String? deferredReason;
}
