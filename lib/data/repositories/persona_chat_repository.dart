import 'package:memex/data/services/character_conversation_service.dart';
import 'package:memex/data/services/character_history_acquaintance_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/persona_chat.dart';
import 'package:memex/utils/tavern_macro.dart';

class PersonaChatRepository {
  PersonaChatRepository({
    PersonaChatService? chatService,
    CharacterConversationService? conversationService,
    CharacterHistoryAcquaintanceService? historyAcquaintanceService,
    CharacterService? characterService,
  })  : _chatService = chatService ?? PersonaChatService.instance,
        _conversationService =
            conversationService ?? CharacterConversationService.instance,
        _historyAcquaintanceService = historyAcquaintanceService ??
            CharacterHistoryAcquaintanceService.instance,
        _characterService = characterService ?? CharacterService.instance;

  final PersonaChatService _chatService;
  final CharacterConversationService _conversationService;
  final CharacterHistoryAcquaintanceService _historyAcquaintanceService;
  final CharacterService _characterService;

  Future<PersonaAvatarSummary> loadAvatarSummary(String userId) async {
    final characterFuture = _characterService.getPrimaryCompanion(userId);
    final unreadCountFuture = _chatService.getTotalUnreadCount(userId: userId);
    return PersonaAvatarSummary(
      character: await characterFuture,
      unreadCount: await unreadCountFuture,
    );
  }

  Future<PersonaChatThreadModel> loadThread({
    required String userId,
    required String characterId,
    required int limit,
    String? userAvatar,
  }) async {
    final character = await _characterService.getCharacter(userId, characterId);
    if (character == null) {
      throw StateError('Character $characterId was not found.');
    }
    if (character.enabled) {
      await _historyAcquaintanceService.ensureScheduled(
        userId: userId,
        character: character,
      );
    }
    var messages = await _chatService.getMessages(
      characterId,
      limit: limit,
      userId: userId,
    );
    final firstMessage = character.firstMessage?.trim();
    if (messages.isEmpty && firstMessage != null && firstMessage.isNotEmpty) {
      await _chatService.addCharacterMessage(
        characterId,
        TavernMacro.resolve(
          firstMessage,
          userName: userId,
          charName: character.name,
        ),
        isRead: true,
        contactEpisodeId: 'greeting:first_message',
        userId: userId,
      );
      messages = await _chatService.getMessages(
        characterId,
        limit: limit,
        userId: userId,
      );
    }
    return PersonaChatThreadModel(
      character: character,
      userId: userId,
      userAvatar: userAvatar,
      messages: messages.map(_toDomain).toList(growable: false),
    );
  }

  Future<List<PersonaChatMessageModel>> getMessages(
    String characterId, {
    required int limit,
    int offset = 0,
    String? userId,
  }) async {
    final rows = await _chatService.getMessages(
      characterId,
      limit: limit,
      offset: offset,
      userId: userId,
    );
    return rows.map(_toDomain).toList(growable: false);
  }

  Future<int> sendMessage({
    required String userId,
    required String characterId,
    required String content,
    DateTime? timestamp,
  }) {
    return _conversationService.sendUserMessage(
      userId: userId,
      characterId: characterId,
      content: content,
      timestamp: timestamp,
    );
  }

  Future<int> markAllRead(String characterId, {String? userId}) {
    return _chatService.markAllRead(characterId, userId: userId);
  }

  Future<List<CharacterModel>> getEnabledCharacters(String userId) async {
    final characters = await _characterService.getAllCharacters(userId);
    return characters.where((character) => character.enabled).toList();
  }

  Future<void> setPrimaryCharacter(String userId, String characterId) {
    return _characterService.setPrimaryCompanion(userId, characterId);
  }

  static PersonaChatMessageModel _toDomain(PersonaChatMessage row) {
    return PersonaChatMessageModel(
      id: row.id,
      characterId: row.characterId,
      isFromCharacter: row.isFromCharacter,
      content: row.content,
      factId: row.factId,
      isRead: row.isRead,
      timestamp: row.timestamp,
      messageType: row.messageType,
      origin: row.origin,
      episodeId: row.contactEpisodeId,
    );
  }
}
