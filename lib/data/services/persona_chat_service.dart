import 'package:drift/drift.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/user_storage.dart';

/// Service for managing persona chat messages.
class PersonaChatService {
  static PersonaChatService? _instance;
  static PersonaChatService get instance {
    _instance ??= PersonaChatService._();
    return _instance!;
  }

  PersonaChatService._();

  AppDatabase get _db => AppDatabase.instance;

  Future<List<PersonaChatMessage>> getMessages(String characterId,
      {int limit = 50, int offset = 0}) async {
    return (_db.select(_db.personaChatMessages)
          ..where((t) => t.characterId.equals(characterId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<int> addUserMessage(String characterId, String content,
      {DateTime? timestamp}) async {
    final createdAt = timestamp ?? DateTime.now();
    final id = await _db.into(_db.personaChatMessages).insert(
          PersonaChatMessagesCompanion.insert(
            characterId: characterId,
            isFromCharacter: false,
            content: content,
            isRead: const Value(true),
            timestamp: createdAt,
          ),
        );
    await _appendTimelineEventIfPossible(
      characterId: characterId,
      content: content,
      timestamp: createdAt,
      type: CharacterMemoryEventType.userChatMessage,
      sourceId: id.toString(),
    );
    return id;
  }

  Future<int> addCharacterMessage(String characterId, String content,
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
          ),
        );
    await _appendTimelineEventIfPossible(
      characterId: characterId,
      content: content,
      timestamp: createdAt,
      type: CharacterMemoryEventType.characterChatMessage,
      factId: factId,
      sourceId: id.toString(),
    );
    return id;
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
            messageType: const Value('action'),
          ),
        );
    await _appendTimelineEventIfPossible(
      characterId: characterId,
      content: content,
      timestamp: createdAt,
      type: CharacterMemoryEventType.characterActionMessage,
      factId: factId,
      sourceId: id.toString(),
    );
    return id;
  }

  Future<void> _appendTimelineEventIfPossible({
    required String characterId,
    required String content,
    required DateTime timestamp,
    required CharacterMemoryEventType type,
    String? factId,
    String? sourceId,
  }) async {
    try {
      final userId = await UserStorage.getUserId();
      if (userId == null || content.trim().isEmpty) {
        return;
      }
      await CharacterMemoryService.instance.appendTimelineEvent(
        userId: userId,
        characterId: characterId,
        scene: CharacterMemoryScene.chat,
        type: type,
        content: content,
        threadId: 'chat:$characterId',
        messageId: sourceId,
        factId: factId,
        sourceId: sourceId,
        timestamp: timestamp,
        metadata: {'source': 'persona_chat'},
      );
    } catch (_) {
      // Timeline append failure must not break normal chat persistence.
    }
  }

  Stream<int> watchUnreadCount(String characterId) {
    final query = _db.selectOnly(_db.personaChatMessages)
      ..addColumns([_db.personaChatMessages.id.count()])
      ..where(_db.personaChatMessages.characterId.equals(characterId) &
          _db.personaChatMessages.isFromCharacter.equals(true) &
          _db.personaChatMessages.isRead.equals(false));
    return query
        .watchSingle()
        .map((row) => row.read(_db.personaChatMessages.id.count()) ?? 0);
  }

  Stream<int> watchTotalUnreadCount() {
    final query = _db.selectOnly(_db.personaChatMessages)
      ..addColumns([_db.personaChatMessages.id.count()])
      ..where(_db.personaChatMessages.isFromCharacter.equals(true) &
          _db.personaChatMessages.isRead.equals(false));
    return query
        .watchSingle()
        .map((row) => row.read(_db.personaChatMessages.id.count()) ?? 0);
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
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  Future<int> clearMessages(String characterId) async {
    return (_db.delete(_db.personaChatMessages)
          ..where((t) => t.characterId.equals(characterId)))
        .go();
  }
}
