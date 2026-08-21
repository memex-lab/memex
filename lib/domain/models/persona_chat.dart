import 'package:memex/domain/models/character_model.dart';

class PersonaAvatarSummary {
  const PersonaAvatarSummary({
    required this.character,
    required this.unreadCount,
  });

  final CharacterModel? character;
  final int unreadCount;
}

class PersonaChatMessageModel {
  const PersonaChatMessageModel({
    required this.id,
    required this.characterId,
    required this.isFromCharacter,
    required this.content,
    required this.isRead,
    required this.timestamp,
    required this.messageType,
    required this.origin,
    this.factId,
    this.turnId,
  });

  final int id;
  final String characterId;
  final bool isFromCharacter;
  final String content;
  final String? factId;
  final bool isRead;
  final DateTime timestamp;
  final String messageType;
  final String origin;
  final String? turnId;
}

class PersonaChatThreadModel {
  const PersonaChatThreadModel({
    required this.character,
    required this.userId,
    required this.messages,
    required this.olderCursor,
    required this.newestCursor,
    this.userAvatar,
  });

  final CharacterModel character;
  final String userId;
  final String? userAvatar;
  final List<PersonaChatMessageModel> messages;
  final int? olderCursor;
  final int newestCursor;
}

class PersonaChatMessagePageModel {
  const PersonaChatMessagePageModel({
    required this.messages,
    required this.olderCursor,
    required this.newestCursor,
  });

  final List<PersonaChatMessageModel> messages;
  final int? olderCursor;
  final int newestCursor;
}
