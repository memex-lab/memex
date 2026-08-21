import 'package:flutter/foundation.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/data/services/persona_chat_legacy_migration_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_message.dart';

abstract final class PersonaChatMessageOrigin {
  static const conversation = 'conversation';
  static const initiative = 'initiative';
}

class PersonaChatMessagePage {
  const PersonaChatMessagePage({
    required this.messages,
    required this.olderCursor,
    required this.newestCursor,
  });

  final List<PersonaChatMessage> messages;
  final int? olderCursor;
  final int newestCursor;
}

/// Persona chat application service.
///
/// Runtime operations delegate to the character workspace store. SQLite is
/// consulted only by [initialize] for one-way legacy migration.
class PersonaChatService {
  PersonaChatService._()
      : _storage = PersonaChatConversationStorage.instance,
        _migration = PersonaChatLegacyMigrationService();

  @visibleForTesting
  PersonaChatService.forTesting({
    required PersonaChatConversationStorage storage,
    required String userId,
  })  : _storage = storage,
        _migration = null,
        _sessionUserId = userId;

  static final PersonaChatService instance = PersonaChatService._();

  final PersonaChatConversationStorage _storage;
  final PersonaChatLegacyMigrationService? _migration;
  String? _sessionUserId;

  Future<void> initialize(String userId, AppDatabase database) async {
    _sessionUserId = userId;
    await _migration?.ensureMigrated(userId: userId, database: database);
  }

  Future<List<PersonaChatMessage>> getMessages(
    String characterId, {
    int limit = 50,
    int offset = 0,
    String? userId,
  }) async {
    final records = await _storage.loadMessages(
      userId: _resolveUserId(userId),
      characterId: characterId,
      limit: limit,
      offset: offset,
    );
    return records.map(_toMessage).toList(growable: false);
  }

  Future<PersonaChatMessagePage> getMessagePage(
    String characterId, {
    int limit = 50,
    int? beforeCursor,
    String? userId,
  }) async {
    final page = await _storage.loadMessagePage(
      userId: _resolveUserId(userId),
      characterId: characterId,
      limit: limit,
      beforeCursor: beforeCursor,
    );
    return PersonaChatMessagePage(
      messages: page.records.map(_toMessage).toList(growable: false),
      olderCursor: page.olderCursor,
      newestCursor: page.newestCursor,
    );
  }

  Future<PersonaChatMessagePage> getMessagesAfter(
    String characterId, {
    required int afterCursor,
    String? userId,
  }) async {
    final page = await _storage.loadMessagesAfter(
      userId: _resolveUserId(userId),
      characterId: characterId,
      afterCursor: afterCursor,
    );
    return PersonaChatMessagePage(
      messages: page.records.map(_toMessage).toList(growable: false),
      olderCursor: page.olderCursor,
      newestCursor: page.newestCursor,
    );
  }

  Future<List<PersonaChatMessage>> getMessagesBefore(
    String characterId, {
    required int beforeMessageId,
    int limit = 50,
    String? userId,
  }) async {
    final records = await _storage.loadMessagesBefore(
      userId: _resolveUserId(userId),
      characterId: characterId,
      beforeMessageId: beforeMessageId,
      limit: limit,
    );
    return records.map(_toMessage).toList(growable: false);
  }

  Future<int> addUserMessage(
    String characterId,
    String content, {
    DateTime? timestamp,
    String? userId,
  }) async {
    final normalized = content.trim();
    final record = await _storage.appendMessage(
      userId: _resolveUserId(userId),
      characterId: characterId,
      isFromCharacter: false,
      content: normalized,
      timestamp: timestamp ?? DateTime.now(),
      messageType: isEmojiOnlyMessage(normalized)
          ? PersonaChatMessageTypes.emoji
          : PersonaChatMessageTypes.text,
      origin: PersonaChatMessageOrigin.conversation,
      isRead: true,
    );
    return record.id;
  }

  Future<int> getReplyCursor(String characterId, {String? userId}) {
    return _storage.getReplyCursor(
      userId: _resolveUserId(userId),
      characterId: characterId,
    );
  }

  Future<int> getConversationGeneration(
    String characterId, {
    String? userId,
  }) {
    return _storage.conversationGeneration(
      userId: _resolveUserId(userId),
      characterId: characterId,
    );
  }

  Future<List<PersonaChatMessage>> getPendingUserMessages(
    String characterId, {
    int limit = 50,
    String? userId,
  }) async {
    final records = await _storage.loadPendingUserMessages(
      userId: _resolveUserId(userId),
      characterId: characterId,
      limit: limit,
    );
    return records.map(_toMessage).toList(growable: false);
  }

  Future<void> advanceReplyCursor({
    required String characterId,
    required int consumedThroughMessageId,
    String? userId,
  }) {
    return _storage.advanceCursor(
      userId: _resolveUserId(userId),
      characterId: characterId,
      processedThroughUserMessageId: consumedThroughMessageId,
    );
  }

  Future<int> addCharacterMessage(
    String characterId,
    String content, {
    String? factId,
    bool isRead = false,
    DateTime? timestamp,
    String origin = PersonaChatMessageOrigin.conversation,
    String? contactEpisodeId,
    String? userId,
  }) async {
    final ids = await addCharacterMessages(
      characterId,
      [CharacterOutgoingMessage.fromContent(content)],
      factId: factId,
      isRead: isRead,
      timestamp: timestamp,
      origin: origin,
      contactEpisodeId: contactEpisodeId,
      userId: userId,
    );
    return ids.single;
  }

  Future<List<int>> addCharacterMessages(
    String characterId,
    List<CharacterOutgoingMessage> messages, {
    String? factId,
    bool isRead = false,
    DateTime? timestamp,
    String origin = PersonaChatMessageOrigin.conversation,
    String? contactEpisodeId,
    String? userId,
  }) async {
    _requireMessages(messages);
    final resolvedUserId = _resolveUserId(userId);
    final createdAt = timestamp ?? DateTime.now();
    if (contactEpisodeId != null) {
      final records = await _storage.appendTurn(
        userId: resolvedUserId,
        characterId: characterId,
        turnId: contactEpisodeId,
        expectedRecordCount: messages.length,
        records: (firstMessageId) => _buildRecords(
          characterId: characterId,
          messages: messages,
          firstMessageId: firstMessageId,
          timestamp: createdAt,
          origin: origin,
          factId: factId,
          isRead: isRead,
          turnId: contactEpisodeId,
        ),
      );
      return records.map((record) => record.id).toList(growable: false);
    }

    final ids = <int>[];
    for (final message in messages) {
      final record = await _storage.appendMessage(
        userId: resolvedUserId,
        characterId: characterId,
        isFromCharacter: true,
        content: message.content,
        factId: factId,
        isRead: isRead,
        timestamp: createdAt,
        messageType: message.storageType,
        origin: origin,
      );
      ids.add(record.id);
    }
    return ids;
  }

  Future<bool> tryAddInitiativeMessages(
    String characterId,
    List<CharacterOutgoingMessage> messages, {
    String? factId,
    bool isRead = false,
    DateTime? timestamp,
    required String contactEpisodeId,
    int? expectedGeneration,
    String? userId,
  }) {
    _requireMessages(messages);
    final createdAt = timestamp ?? DateTime.now();
    return _storage.tryAppendInitiativeTurn(
      userId: _resolveUserId(userId),
      characterId: characterId,
      turnId: contactEpisodeId,
      expectedRecordCount: messages.length,
      expectedGeneration: expectedGeneration,
      records: (firstMessageId) => _buildRecords(
        characterId: characterId,
        messages: messages,
        firstMessageId: firstMessageId,
        timestamp: createdAt,
        origin: PersonaChatMessageOrigin.initiative,
        factId: factId,
        isRead: isRead,
        turnId: contactEpisodeId,
      ),
    );
  }

  Future<List<int>> completeConversationEpisode({
    required String characterId,
    required int consumedThroughMessageId,
    required List<CharacterOutgoingMessage> characterMessages,
    required String episodeId,
    required DateTime timestamp,
    bool isRead = false,
    int? expectedGeneration,
    String? userId,
  }) async {
    if (consumedThroughMessageId <= 0) {
      throw ArgumentError.value(
        consumedThroughMessageId,
        'consumedThroughMessageId',
      );
    }
    _requireMessages(characterMessages);
    final records = await _storage.appendTurn(
      userId: _resolveUserId(userId),
      characterId: characterId,
      turnId: episodeId,
      expectedRecordCount: characterMessages.length,
      agentProcessedThroughUserMessageId: consumedThroughMessageId,
      expectedGeneration: expectedGeneration,
      records: (firstMessageId) => _buildRecords(
        characterId: characterId,
        messages: characterMessages,
        firstMessageId: firstMessageId,
        timestamp: timestamp,
        origin: PersonaChatMessageOrigin.conversation,
        isRead: isRead,
        turnId: episodeId,
      ),
    );
    return records.map((record) => record.id).toList(growable: false);
  }

  Future<int> addActionMessage(
    String characterId,
    String content, {
    String? factId,
    bool isRead = false,
    DateTime? timestamp,
    String? userId,
  }) async {
    final record = await _storage.appendMessage(
      userId: _resolveUserId(userId),
      characterId: characterId,
      isFromCharacter: true,
      content: content,
      factId: factId,
      isRead: isRead,
      timestamp: timestamp ?? DateTime.now(),
      messageType: PersonaChatMessageTypes.action,
      origin: PersonaChatMessageOrigin.conversation,
    );
    return record.id;
  }

  Future<int> getUnreadCount(String characterId, {String? userId}) {
    return _storage.unreadCount(
      userId: _resolveUserId(userId),
      characterId: characterId,
    );
  }

  Future<int> getTotalUnreadCount({String? userId}) {
    return _storage.totalUnreadCount(_resolveUserId(userId));
  }

  Future<Set<String>> getCharactersWithPendingUserMessages({String? userId}) {
    final resolvedUserId = _resolveUserId(userId);
    return _storage.charactersWithPendingUserMessages(resolvedUserId);
  }

  Future<int> markAllRead(String characterId, {String? userId}) {
    return _storage.markAllRead(
      userId: _resolveUserId(userId),
      characterId: characterId,
    );
  }

  Future<PersonaChatMessage?> getLastMessage(
    String characterId, {
    String? userId,
  }) async {
    final record = await _storage.lastMessage(
      userId: _resolveUserId(userId),
      characterId: characterId,
    );
    return record == null ? null : _toMessage(record);
  }

  Future<int> getLatestMessageId(String characterId, {String? userId}) {
    return _storage.latestMessageId(
      userId: _resolveUserId(userId),
      characterId: characterId,
    );
  }

  Future<int> clearMessages(String characterId, {String? userId}) {
    return _storage.clearConversation(
      userId: _resolveUserId(userId),
      characterId: characterId,
      clearedAt: DateTime.now(),
    );
  }

  String _resolveUserId(String? userId) {
    final resolved =
        userId?.trim().isNotEmpty == true ? userId!.trim() : _sessionUserId;
    if (resolved == null || resolved.isEmpty) {
      throw StateError('PersonaChatService has not been initialized.');
    }
    return resolved;
  }

  List<PersonaChatConversationRecord> _buildRecords({
    required String characterId,
    required List<CharacterOutgoingMessage> messages,
    required int firstMessageId,
    required DateTime timestamp,
    required String origin,
    required bool isRead,
    required String turnId,
    String? factId,
  }) {
    return [
      for (var index = 0; index < messages.length; index++)
        PersonaChatConversationRecord(
          id: firstMessageId + index,
          characterId: characterId,
          isFromCharacter: true,
          content: messages[index].content,
          factId: factId,
          isRead: isRead,
          timestamp: timestamp,
          messageType: messages[index].storageType,
          origin: origin,
          turnId: turnId,
        ),
    ];
  }

  PersonaChatMessage _toMessage(PersonaChatConversationRecord record) {
    return PersonaChatMessage(
      id: record.id,
      characterId: record.characterId,
      isFromCharacter: record.isFromCharacter,
      content: record.content,
      factId: record.factId,
      isRead: record.isRead,
      timestamp: record.timestamp,
      messageType: record.messageType,
      origin: record.origin,
      contactEpisodeId: record.turnId,
    );
  }

  void _requireMessages(List<CharacterOutgoingMessage> messages) {
    if (messages.isEmpty) {
      throw ArgumentError('Character messages must be non-empty.');
    }
  }
}
