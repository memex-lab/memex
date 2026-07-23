import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_message.dart';

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

  PersonaChatService._() : _testDb = null;

  @visibleForTesting
  PersonaChatService.forTesting(AppDatabase database) : _testDb = database;

  final AppDatabase? _testDb;

  AppDatabase get _db => _testDb ?? AppDatabase.instance;

  Future<List<PersonaChatMessage>> getMessages(String characterId,
      {int limit = 50, int offset = 0}) async {
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
  }) async {
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

  Future<int> addUserMessage(String characterId, String content,
      {DateTime? timestamp}) async {
    final createdAt = timestamp ?? DateTime.now();
    final normalized = content.trim();
    final id = await _db.into(_db.personaChatMessages).insert(
          PersonaChatMessagesCompanion.insert(
            characterId: characterId,
            isFromCharacter: false,
            content: normalized,
            isRead: const Value(true),
            timestamp: createdAt,
            messageType: Value(
              isEmojiOnlyMessage(normalized)
                  ? PersonaChatMessageTypes.emoji
                  : PersonaChatMessageTypes.text,
            ),
          ),
        );
    return id;
  }

  Future<int> getReplyCursor(String characterId) async {
    final cursor = await (_db.select(_db.personaChatReplyCursors)
          ..where((row) => row.characterId.equals(characterId)))
        .getSingleOrNull();
    return cursor?.consumedThroughMessageId ?? 0;
  }

  Future<List<PersonaChatMessage>> getPendingUserMessages(
    String characterId, {
    int limit = 50,
  }) async {
    final cursor = await getReplyCursor(characterId);
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
  }) {
    if (consumedThroughMessageId <= 0) {
      throw ArgumentError.value(
        consumedThroughMessageId,
        'consumedThroughMessageId',
      );
    }
    return _db.transaction(
      () => _advanceReplyCursor(
        characterId: characterId,
        consumedThroughMessageId: consumedThroughMessageId,
      ),
    );
  }

  Future<int> addCharacterMessage(String characterId, String content,
      {String? factId,
      bool isRead = false,
      DateTime? timestamp,
      String origin = PersonaChatMessageOrigin.conversation,
      String? contactEpisodeId}) async {
    final message = CharacterOutgoingMessage.fromContent(content);
    final ids = await addCharacterMessages(
      characterId,
      [message],
      factId: factId,
      isRead: isRead,
      timestamp: timestamp,
      origin: origin,
      contactEpisodeId: contactEpisodeId,
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
  }) async {
    final createdAt = timestamp ?? DateTime.now();
    if (messages.isEmpty) {
      throw ArgumentError('Character messages must be non-empty.');
    }

    final result = await _db.transaction(() async {
      if (contactEpisodeId != null) {
        final existing = await (_db.select(_db.personaChatMessages)
              ..where((t) =>
                  t.characterId.equals(characterId) &
                  t.contactEpisodeId.equals(contactEpisodeId))
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
        if (existing.isNotEmpty) {
          return (
            ids: existing.map((message) => message.id).toList(),
            inserted: false
          );
        }
      }

      final ids = <int>[];
      for (final message in messages) {
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
                ),
              ),
        );
      }
      return (ids: ids, inserted: true);
    });

    return result.ids;
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

    return _db.transaction(() async {
      final existing = await (_db.select(_db.personaChatMessages)
            ..where((t) =>
                t.characterId.equals(characterId) &
                t.contactEpisodeId.equals(episodeId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

      final ids = existing.map((message) => message.id).toList();
      if (ids.isEmpty) {
        for (final message in characterMessages) {
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
                  ),
                ),
          );
        }
      }

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
  Future<int> addActionMessage(String characterId, String content,
      {String? factId, bool isRead = false, DateTime? timestamp}) async {
    final createdAt = timestamp ?? DateTime.now();
    final id = await _db.into(_db.personaChatMessages).insert(
          PersonaChatMessagesCompanion.insert(
            characterId: characterId,
            isFromCharacter: true,
            content: content,
            factId: Value(factId),
            isRead: Value(isRead),
            timestamp: createdAt,
            messageType: const Value(PersonaChatMessageTypes.action),
          ),
        );
    return id;
  }

  Future<int> getUnreadCount(String characterId) async {
    final query = _db.selectOnly(_db.personaChatMessages)
      ..addColumns([_db.personaChatMessages.id.count()])
      ..where(_db.personaChatMessages.characterId.equals(characterId) &
          _db.personaChatMessages.isFromCharacter.equals(true) &
          _db.personaChatMessages.isRead.equals(false));
    final row = await query.getSingle();
    return row.read(_db.personaChatMessages.id.count()) ?? 0;
  }

  Future<int> getTotalUnreadCount() async {
    final query = _db.selectOnly(_db.personaChatMessages)
      ..addColumns([_db.personaChatMessages.id.count()])
      ..where(_db.personaChatMessages.isFromCharacter.equals(true) &
          _db.personaChatMessages.isRead.equals(false));
    final row = await query.getSingle();
    return row.read(_db.personaChatMessages.id.count()) ?? 0;
  }

  Future<int> markAllRead(String characterId) async {
    return (_db.update(_db.personaChatMessages)
          ..where((t) =>
              t.characterId.equals(characterId) &
              t.isFromCharacter.equals(true) &
              t.isRead.equals(false)))
        .write(const PersonaChatMessagesCompanion(isRead: Value(true)));
  }

  Future<PersonaChatMessage?> getLastMessage(String characterId) async {
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

  Future<int> getLatestMessageId(String characterId) async {
    final maxId = _db.personaChatMessages.id.max();
    final result = await (_db.selectOnly(_db.personaChatMessages)
          ..addColumns([maxId])
          ..where(_db.personaChatMessages.characterId.equals(characterId)))
        .getSingle();
    return result.read(maxId) ?? 0;
  }

  Future<int> clearMessages(String characterId) async {
    return (_db.delete(_db.personaChatMessages)
          ..where((t) => t.characterId.equals(characterId)))
        .go();
  }
}
