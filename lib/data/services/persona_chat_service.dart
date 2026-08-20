import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:uuid/uuid.dart';

abstract final class PersonaChatMessageOrigin {
  static const conversation = 'conversation';
  static const initiative = 'initiative';
}

/// Service for managing persona chat messages.
class PersonaChatService {
  static PersonaChatService? _instance;
  static PersonaChatService get instance {
    _instance ??= PersonaChatService._();
    return _instance!;
  }

  PersonaChatService._()
      : _testDb = null,
        _boundUserId = null,
        _storage = PersonaChatConversationStorage.instance,
        _uuid = const Uuid();

  @visibleForTesting
  PersonaChatService.forTesting(
    AppDatabase database, {
    String? userId,
    PersonaChatConversationStorage? storage,
  })  : _testDb = database,
        _boundUserId = userId,
        _storage = storage,
        _uuid = const Uuid();

  final AppDatabase? _testDb;
  final String? _boundUserId;
  final PersonaChatConversationStorage? _storage;
  final Uuid _uuid;
  String? _sessionUserId;

  AppDatabase get _db => _testDb ?? AppDatabase.instance;

  void bindUser(String userId) {
    _sessionUserId = userId;
  }

  Future<void> reconcileFromWorkspace(String userId) async {
    final storage = _storage;
    if (storage == null) return;
    await storage.ensureMigrated(userId: userId, db: _db);
    await storage.reconcileAll(userId: userId, db: _db);
  }

  Future<List<PersonaChatMessage>> getMessages(
    String characterId, {
    int limit = 50,
    int offset = 0,
    String? userId,
  }) async {
    await _ensureProjected(characterId, userId: userId);
    return (_db.select(_db.personaChatMessages)
          ..where((t) => t.characterId.equals(characterId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.timestamp),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Returns the canonical chat history preceding one already-persisted user
  /// message. Results remain newest-first, matching [getMessages].
  Future<List<PersonaChatMessage>> getMessagesBefore(
    String characterId, {
    required int beforeMessageId,
    int limit = 50,
    String? userId,
  }) async {
    await _ensureProjected(characterId, userId: userId);
    return (_db.select(_db.personaChatMessages)
          ..where((t) =>
              t.characterId.equals(characterId) &
              t.id.isSmallerThanValue(beforeMessageId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.timestamp),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(limit))
        .get();
  }

  Future<int> addUserMessage(
    String characterId,
    String content, {
    DateTime? timestamp,
    String? userId,
  }) async {
    final createdAt = timestamp ?? DateTime.now();
    final normalized = content.trim();
    final messageType = isEmojiOnlyMessage(normalized)
        ? PersonaChatMessageTypes.emoji
        : PersonaChatMessageTypes.text;
    final resolvedUserId = _resolveUserId(userId);
    final record = await _persistToWorkspace(
      userId: resolvedUserId,
      characterId: characterId,
      isFromCharacter: false,
      content: normalized,
      timestamp: createdAt,
      messageType: messageType,
      origin: PersonaChatMessageOrigin.conversation,
      isRead: true,
    );
    return _db.into(_db.personaChatMessages).insert(
          PersonaChatMessagesCompanion.insert(
            characterId: characterId,
            isFromCharacter: false,
            content: normalized,
            isRead: const Value(true),
            timestamp: createdAt,
            messageType: Value(messageType),
            stableId: Value(record?.id ?? _uuid.v4()),
          ),
        );
  }

  Future<int> getReplyCursor(String characterId, {String? userId}) async {
    await _ensureProjected(characterId, userId: userId);
    final cursor = await (_db.select(_db.personaChatReplyCursors)
          ..where((row) => row.characterId.equals(characterId)))
        .getSingleOrNull();
    return cursor?.consumedThroughMessageId ?? 0;
  }

  Future<List<PersonaChatMessage>> getPendingUserMessages(
    String characterId, {
    int limit = 50,
    String? userId,
  }) async {
    await _ensureProjected(characterId, userId: userId);
    final cursor = await getReplyCursor(characterId, userId: userId);
    return (_db.select(_db.personaChatMessages)
          ..where((t) =>
              t.characterId.equals(characterId) &
              t.isFromCharacter.equals(false) &
              t.id.isBiggerThanValue(cursor))
          ..orderBy([
            (t) => OrderingTerm.asc(t.id),
          ])
          ..limit(limit))
        .get();
  }

  Future<void> advanceReplyCursor({
    required String characterId,
    required int consumedThroughMessageId,
    String? userId,
  }) {
    if (consumedThroughMessageId <= 0) {
      throw ArgumentError.value(
        consumedThroughMessageId,
        'consumedThroughMessageId',
      );
    }
    return _db.transaction(() async {
      await _advanceWorkspaceCursor(
        characterId: characterId,
        consumedThroughMessageId: consumedThroughMessageId,
        userId: userId,
      );
      await _advanceReplyCursor(
        characterId: characterId,
        consumedThroughMessageId: consumedThroughMessageId,
      );
    });
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
    final message = CharacterOutgoingMessage.fromContent(content);
    final ids = await addCharacterMessages(
      characterId,
      [message],
      factId: factId,
      isRead: isRead,
      timestamp: timestamp,
      origin: origin,
      contactEpisodeId: contactEpisodeId,
      userId: userId,
    );
    return ids.single;
  }

  /// Atomically persists the bubbles from one character contact decision.
  /// A repeated [contactEpisodeId] returns the existing rows without writing
  /// duplicate chat or timeline events.
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
    final createdAt = timestamp ?? DateTime.now();
    if (messages.isEmpty) {
      throw ArgumentError('Character messages must be non-empty.');
    }

    final result = await _db.transaction(() async {
      if (contactEpisodeId != null) {
        final existing = await _getEpisodeMessages(
          characterId,
          contactEpisodeId,
        );
        if (existing.isNotEmpty) {
          if (existing.length == messages.length) {
            return (
              ids: existing.map((message) => message.id).toList(),
              inserted: false
            );
          }
          await _deleteEpisodeMessages(characterId, contactEpisodeId);
        }
      }

      final workspaceRecords = await _persistEpisodeToWorkspace(
        userId: _resolveUserId(userId),
        characterId: characterId,
        messages: messages,
        factId: factId,
        isRead: isRead,
        timestamp: createdAt,
        origin: origin,
        contactEpisodeId: contactEpisodeId,
      );

      final ids = <int>[];
      for (var index = 0; index < messages.length; index++) {
        final message = messages[index];
        ids.add(
          await _db.into(_db.personaChatMessages).insert(
                PersonaChatMessagesCompanion.insert(
                  characterId: characterId,
                  isFromCharacter: true,
                  content: message.content,
                  factId: Value(factId),
                  isRead: Value(isRead),
                  timestamp: createdAt,
                  messageType: Value(message.storageType),
                  origin: Value(origin),
                  contactEpisodeId: Value(contactEpisodeId),
                  stableId: Value(
                    workspaceRecords != null
                        ? workspaceRecords[index].id
                        : _uuid.v4(),
                  ),
                ),
              ),
        );
      }
      return (ids: ids, inserted: true);
    });

    return result.ids;
  }

  /// Commits an Initiative episode only when no direct user message is waiting
  /// for Conversation. The check and inserts share one database transaction so
  /// a proactive reply cannot knowingly overtake an unanswered user turn.
  Future<bool> tryAddInitiativeMessages(
    String characterId,
    List<CharacterOutgoingMessage> messages, {
    String? factId,
    bool isRead = false,
    DateTime? timestamp,
    required String contactEpisodeId,
    String? userId,
  }) async {
    final createdAt = timestamp ?? DateTime.now();
    if (messages.isEmpty) {
      throw ArgumentError('Character messages must be non-empty.');
    }

    await _ensureProjected(characterId, userId: userId);
    return _db.transaction(() async {
      final existing = await _getEpisodeMessages(
        characterId,
        contactEpisodeId,
      );
      if (existing.isNotEmpty) {
        if (existing.length == messages.length) return true;
        await _deleteEpisodeMessages(characterId, contactEpisodeId);
      }

      final cursor = await (_db.select(_db.personaChatReplyCursors)
            ..where((row) => row.characterId.equals(characterId)))
          .getSingleOrNull();
      final pendingUserMessage = await (_db.select(_db.personaChatMessages)
            ..where((t) =>
                t.characterId.equals(characterId) &
                t.isFromCharacter.equals(false) &
                t.id.isBiggerThanValue(
                  cursor?.consumedThroughMessageId ?? 0,
                ))
            ..limit(1))
          .getSingleOrNull();
      if (pendingUserMessage != null) return false;

      final workspaceRecords = await _persistEpisodeToWorkspace(
        userId: _resolveUserId(userId),
        characterId: characterId,
        messages: messages,
        factId: factId,
        isRead: isRead,
        timestamp: createdAt,
        origin: PersonaChatMessageOrigin.initiative,
        contactEpisodeId: contactEpisodeId,
      );

      for (var index = 0; index < messages.length; index++) {
        final message = messages[index];
        await _db.into(_db.personaChatMessages).insert(
              PersonaChatMessagesCompanion.insert(
                characterId: characterId,
                isFromCharacter: true,
                content: message.content,
                factId: Value(factId),
                isRead: Value(isRead),
                timestamp: createdAt,
                messageType: Value(message.storageType),
                origin: const Value(PersonaChatMessageOrigin.initiative),
                contactEpisodeId: Value(contactEpisodeId),
                stableId: Value(
                  workspaceRecords != null
                      ? workspaceRecords[index].id
                      : _uuid.v4(),
                ),
              ),
            );
      }
      return true;
    });
  }

  /// Atomically records one character speaking episode and advances the
  /// private-chat inbox cursor through the messages it considered. Retrying
  /// the same episode is idempotent.
  Future<List<int>> completeConversationEpisode({
    required String characterId,
    required int consumedThroughMessageId,
    required List<CharacterOutgoingMessage> characterMessages,
    required String episodeId,
    required DateTime timestamp,
    bool isRead = false,
    String? userId,
  }) async {
    if (consumedThroughMessageId <= 0) {
      throw ArgumentError.value(
        consumedThroughMessageId,
        'consumedThroughMessageId',
      );
    }
    if (characterMessages.isEmpty) {
      throw ArgumentError('Character messages must be non-empty.');
    }

    await _ensureProjected(characterId, userId: userId);
    return _db.transaction(() async {
      final existing = await _getEpisodeMessages(characterId, episodeId);

      final ids = existing.map((message) => message.id).toList();
      if (ids.isNotEmpty && ids.length != characterMessages.length) {
        await _deleteEpisodeMessages(characterId, episodeId);
        ids.clear();
      }
      if (ids.isEmpty) {
        final workspaceRecords = await _persistEpisodeToWorkspace(
          userId: _resolveUserId(userId),
          characterId: characterId,
          messages: characterMessages,
          isRead: isRead,
          timestamp: timestamp,
          origin: PersonaChatMessageOrigin.conversation,
          contactEpisodeId: episodeId,
        );
        for (var index = 0; index < characterMessages.length; index++) {
          final message = characterMessages[index];
          ids.add(
            await _db.into(_db.personaChatMessages).insert(
                  PersonaChatMessagesCompanion.insert(
                    characterId: characterId,
                    isFromCharacter: true,
                    content: message.content,
                    isRead: Value(isRead),
                    timestamp: timestamp,
                    messageType: Value(message.storageType),
                    origin: const Value(
                      PersonaChatMessageOrigin.conversation,
                    ),
                    contactEpisodeId: Value(episodeId),
                    stableId: Value(
                      workspaceRecords != null
                          ? workspaceRecords[index].id
                          : _uuid.v4(),
                    ),
                  ),
                ),
          );
        }
      }

      await _advanceWorkspaceCursor(
        characterId: characterId,
        consumedThroughMessageId: consumedThroughMessageId,
        userId: userId,
      );
      await _advanceReplyCursor(
        characterId: characterId,
        consumedThroughMessageId: consumedThroughMessageId,
      );
      return ids;
    });
  }

  Future<void> _advanceReplyCursor({
    required String characterId,
    required int consumedThroughMessageId,
  }) async {
    final current = await (_db.select(_db.personaChatReplyCursors)
          ..where((row) => row.characterId.equals(characterId)))
        .getSingleOrNull();
    if (current != null &&
        current.consumedThroughMessageId >= consumedThroughMessageId) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (current == null) {
      await _db.into(_db.personaChatReplyCursors).insert(
            PersonaChatReplyCursorsCompanion.insert(
              characterId: characterId,
              consumedThroughMessageId: Value(consumedThroughMessageId),
              updatedAt: now,
            ),
          );
      return;
    }
    await (_db.update(_db.personaChatReplyCursors)
          ..where((row) => row.characterId.equals(characterId)))
        .write(
      PersonaChatReplyCursorsCompanion(
        consumedThroughMessageId: Value(consumedThroughMessageId),
        updatedAt: Value(now),
      ),
    );
  }

  /// Adds a narrative/action message from the character (e.g. *leans closer*).
  /// Rendered differently in the UI — no bubble, italic, centered.
  Future<int> addActionMessage(
    String characterId,
    String content, {
    String? factId,
    bool isRead = false,
    DateTime? timestamp,
    String? userId,
  }) async {
    final createdAt = timestamp ?? DateTime.now();
    final record = await _persistToWorkspace(
      userId: _resolveUserId(userId),
      characterId: characterId,
      isFromCharacter: true,
      content: content,
      timestamp: createdAt,
      messageType: PersonaChatMessageTypes.action,
      origin: PersonaChatMessageOrigin.conversation,
      factId: factId,
      isRead: isRead,
    );
    return _db.into(_db.personaChatMessages).insert(
          PersonaChatMessagesCompanion.insert(
            characterId: characterId,
            isFromCharacter: true,
            content: content,
            factId: Value(factId),
            isRead: Value(isRead),
            timestamp: createdAt,
            messageType: const Value(PersonaChatMessageTypes.action),
            stableId: Value(record?.id ?? _uuid.v4()),
          ),
        );
  }

  Future<int> getUnreadCount(String characterId, {String? userId}) async {
    await _ensureProjected(characterId, userId: userId);
    final query = _db.selectOnly(_db.personaChatMessages)
      ..addColumns([_db.personaChatMessages.id.count()])
      ..where(_db.personaChatMessages.characterId.equals(characterId) &
          _db.personaChatMessages.isFromCharacter.equals(true) &
          _db.personaChatMessages.isRead.equals(false));
    final row = await query.getSingle();
    return row.read(_db.personaChatMessages.id.count()) ?? 0;
  }

  Future<int> getTotalUnreadCount({String? userId}) async {
    final query = _db.selectOnly(_db.personaChatMessages)
      ..addColumns([_db.personaChatMessages.id.count()])
      ..where(_db.personaChatMessages.isFromCharacter.equals(true) &
          _db.personaChatMessages.isRead.equals(false));
    final row = await query.getSingle();
    return row.read(_db.personaChatMessages.id.count()) ?? 0;
  }

  Future<int> markAllRead(String characterId, {String? userId}) async {
    final storage = _storage;
    final resolvedUserId = storage == null ? null : _resolveUserId(userId);
    if (storage != null && resolvedUserId != null) {
      await storage.markAllRead(
        userId: resolvedUserId,
        characterId: characterId,
      );
    }
    return (_db.update(_db.personaChatMessages)
          ..where((t) =>
              t.characterId.equals(characterId) &
              t.isFromCharacter.equals(true) &
              t.isRead.equals(false)))
        .write(const PersonaChatMessagesCompanion(isRead: Value(true)));
  }

  Future<PersonaChatMessage?> getLastMessage(
    String characterId, {
    String? userId,
  }) async {
    await _ensureProjected(characterId, userId: userId);
    final results = await (_db.select(_db.personaChatMessages)
          ..where((t) => t.characterId.equals(characterId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.timestamp),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  Future<int> getLatestMessageId(String characterId, {String? userId}) async {
    await _ensureProjected(characterId, userId: userId);
    final maxId = _db.personaChatMessages.id.max();
    final result = await (_db.selectOnly(_db.personaChatMessages)
          ..addColumns([maxId])
          ..where(_db.personaChatMessages.characterId.equals(characterId)))
        .getSingle();
    return result.read(maxId) ?? 0;
  }

  Future<int> clearMessages(String characterId, {String? userId}) async {
    final storage = _storage;
    final resolvedUserId = storage == null ? null : _resolveUserId(userId);
    if (storage != null && resolvedUserId != null) {
      await storage.clearConversation(
        userId: resolvedUserId,
        characterId: characterId,
        clearedAt: DateTime.now(),
      );
    }
    await (_db.delete(_db.personaChatReplyCursors)
          ..where((t) => t.characterId.equals(characterId)))
        .go();
    return (_db.delete(_db.personaChatMessages)
          ..where((t) => t.characterId.equals(characterId)))
        .go();
  }

  String? _resolveUserId(String? userId) {
    if (userId != null && userId.isNotEmpty) return userId;
    return _boundUserId ?? _sessionUserId;
  }

  Future<void> _ensureProjected(String characterId, {String? userId}) async {
    final storage = _storage;
    final resolvedUserId = _resolveUserId(userId);
    if (storage == null || resolvedUserId == null) return;
    final sqliteCount = await _sqliteCount(characterId);
    final records = await storage.loadMessages(
      userId: resolvedUserId,
      characterId: characterId,
    );
    if (records.isEmpty) {
      if (sqliteCount == 0) return;
      final state = await storage.loadState(
        userId: resolvedUserId,
        characterId: characterId,
      );
      if (state.clearedAt == null) return;
    } else if (sqliteCount == records.length) {
      return;
    }
    await storage.rebuildSqliteProjection(
      userId: resolvedUserId,
      characterId: characterId,
      db: _db,
    );
  }

  Future<int> _sqliteCount(String characterId) async {
    final count = _db.personaChatMessages.id.count();
    final row = await (_db.selectOnly(_db.personaChatMessages)
          ..addColumns([count])
          ..where(_db.personaChatMessages.characterId.equals(characterId)))
        .getSingle();
    return row.read(count) ?? 0;
  }

  Future<List<PersonaChatMessage>> _getEpisodeMessages(
    String characterId,
    String episodeId,
  ) {
    return (_db.select(_db.personaChatMessages)
          ..where((row) =>
              row.characterId.equals(characterId) &
              row.contactEpisodeId.equals(episodeId))
          ..orderBy([(row) => OrderingTerm.asc(row.id)]))
        .get();
  }

  Future<int> _deleteEpisodeMessages(
    String characterId,
    String episodeId,
  ) {
    return (_db.delete(_db.personaChatMessages)
          ..where((row) =>
              row.characterId.equals(characterId) &
              row.contactEpisodeId.equals(episodeId)))
        .go();
  }

  Future<PersonaChatConversationRecord?> _persistToWorkspace({
    required String? userId,
    required String characterId,
    required bool isFromCharacter,
    required String content,
    required DateTime timestamp,
    required String messageType,
    required String origin,
    String? factId,
    bool isRead = false,
    String? contactEpisodeId,
  }) async {
    final storage = _storage;
    if (storage == null || userId == null) return null;
    return storage.appendMessage(
      userId: userId,
      characterId: characterId,
      isFromCharacter: isFromCharacter,
      content: content,
      timestamp: timestamp,
      messageType: messageType,
      origin: origin,
      factId: factId,
      isRead: isRead,
      contactEpisodeId: contactEpisodeId,
    );
  }

  Future<List<PersonaChatConversationRecord>?> _persistEpisodeToWorkspace({
    required String? userId,
    required String characterId,
    required List<CharacterOutgoingMessage> messages,
    required DateTime timestamp,
    required String origin,
    String? factId,
    bool isRead = false,
    String? contactEpisodeId,
  }) async {
    final storage = _storage;
    if (storage == null || userId == null) return null;
    if (contactEpisodeId == null) {
      final records = <PersonaChatConversationRecord>[];
      for (final message in messages) {
        records.add(
          await storage.appendMessage(
            userId: userId,
            characterId: characterId,
            isFromCharacter: true,
            content: message.content,
            timestamp: timestamp,
            messageType: message.storageType,
            origin: origin,
            factId: factId,
            isRead: isRead,
          ),
        );
      }
      return records;
    }
    return storage.appendEpisode(
      userId: userId,
      characterId: characterId,
      contactEpisodeId: contactEpisodeId,
      expectedRecordCount: messages.length,
      records: (nextSeq) {
        return [
          for (var index = 0; index < messages.length; index++)
            PersonaChatConversationRecord(
              id: _uuid.v4(),
              seq: nextSeq + index,
              characterId: characterId,
              isFromCharacter: true,
              content: messages[index].content,
              factId: factId,
              isRead: isRead,
              timestamp: timestamp,
              messageType: messages[index].storageType,
              origin: origin,
              contactEpisodeId: contactEpisodeId,
            ),
        ];
      },
    );
  }

  Future<void> _advanceWorkspaceCursor({
    required String characterId,
    required int consumedThroughMessageId,
    String? userId,
  }) async {
    final storage = _storage;
    final resolvedUserId = _resolveUserId(userId);
    if (storage == null || resolvedUserId == null) return;
    final row = await (_db.select(_db.personaChatMessages)
          ..where((t) =>
              t.characterId.equals(characterId) &
              t.id.equals(consumedThroughMessageId)))
        .getSingleOrNull();
    final stableId = row?.stableId;
    if (stableId == null || stableId.isEmpty) return;
    await storage.advanceCursor(
      userId: resolvedUserId,
      characterId: characterId,
      consumedThroughMessageId: stableId,
    );
  }
}
