import 'package:memex/domain/models/character_message.dart';

enum CharacterInitiativeAction {
  speak,
  sleepUntil,
}

/// One concrete action selected by the character after reflecting privately.
///
/// This is an execution result, not simulated relationship state. Closeness,
/// attachment, and the character's current perspective remain narrative memory
/// in the character workspace.
class CharacterInitiativeDecision {
  const CharacterInitiativeDecision._({
    required this.action,
    required this.wakeAt,
    required this.reason,
    this.messages = const [],
  });

  CharacterInitiativeDecision.speak(
    List<Object> messages, {
    required DateTime wakeAt,
    required String reason,
  }) : this._(
          action: CharacterInitiativeAction.speak,
          messages: List.unmodifiable(
            normalizeCharacterOutgoingMessages(messages),
          ),
          wakeAt: wakeAt,
          reason: reason,
        );

  const CharacterInitiativeDecision.sleepUntil({
    required DateTime wakeAt,
    required String reason,
  }) : this._(
          action: CharacterInitiativeAction.sleepUntil,
          wakeAt: wakeAt,
          reason: reason,
        );

  final CharacterInitiativeAction action;
  final List<CharacterOutgoingMessage> messages;
  final DateTime wakeAt;
  final String reason;
}

/// A private intention the character explicitly chose to revisit later.
///
/// This is narrative prospective memory, not a modeled mood or relationship
/// score. Removing an item means the character resolved or abandoned it.
class CharacterPendingThought {
  const CharacterPendingThought({
    required this.id,
    required this.sourceEventId,
    required this.reason,
    required this.createdAt,
    required this.wakeAt,
    this.factId,
  });

  final String id;
  final String sourceEventId;
  final String? factId;
  final String reason;
  final DateTime createdAt;
  final DateTime wakeAt;

  factory CharacterPendingThought.fromJson(Map<String, dynamic> json) {
    return CharacterPendingThought(
      id: json['id'] as String,
      sourceEventId: json['source_event_id'] as String,
      factId: json['fact_id'] as String?,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      wakeAt: DateTime.parse(json['wake_at'] as String),
    );
  }

  CharacterPendingThought copyWith({
    String? reason,
    DateTime? wakeAt,
    String? factId,
  }) {
    return CharacterPendingThought(
      id: id,
      sourceEventId: sourceEventId,
      factId: factId ?? this.factId,
      reason: reason ?? this.reason,
      createdAt: createdAt,
      wakeAt: wakeAt ?? this.wakeAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source_event_id': sourceEventId,
        if (factId != null) 'fact_id': factId,
        'reason': reason,
        'created_at': createdAt.toIso8601String(),
        'wake_at': wakeAt.toIso8601String(),
      };
}

class CharacterConversationTurn {
  const CharacterConversationTurn({
    this.id,
    required this.isFromCharacter,
    required this.content,
    required this.timestamp,
    this.isRead = true,
    this.origin = 'conversation',
    this.contactEpisodeId,
    this.messageType = PersonaChatMessageTypes.text,
  });

  final int? id;
  final bool isFromCharacter;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String origin;
  final String? contactEpisodeId;
  final String messageType;
}

/// Actual recent interactions available when the character chooses whether to
/// make contact. The originating life record is intentionally absent: it has
/// already been transformed into the character's own memory.
class CharacterInitiativeContext {
  const CharacterInitiativeContext({
    required this.sourceEventId,
    required this.now,
    this.factId,
    this.recentPrivateChat = const [],
    this.characterComment,
    this.pendingThoughts = const [],
    this.resumedThought,
    this.wakeReason,
    this.latestPrivateMessageId = 0,
  });

  final String sourceEventId;
  final String? factId;
  final DateTime now;
  final List<CharacterConversationTurn> recentPrivateChat;
  final String? characterComment;
  final List<CharacterPendingThought> pendingThoughts;
  final CharacterPendingThought? resumedThought;
  final String? wakeReason;

  /// Chat revision captured before the character starts thinking. The handler
  /// revalidates it before delivering a proactive message so a newly arrived
  /// direct message cannot be overtaken by a stale initiative decision.
  final int latestPrivateMessageId;
}
