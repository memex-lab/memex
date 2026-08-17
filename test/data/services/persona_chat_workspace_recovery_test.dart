import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('persona chat workspace recovery', () {
    const userId = 'wujia';
    const characterId = 'yaoyao';
    late Directory tempRoot;
    late AppDatabase db;
    late PersonaChatConversationStorage storage;
    late PersonaChatService chat;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempRoot = await Directory.systemTemp.createTemp(
        'memex_persona_chat_recovery_',
      );
      await FileSystemService.init(tempRoot.path);
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = PersonaChatConversationStorage(
        fileSystem: FileSystemService.instance,
      );
      chat = PersonaChatService.forTesting(
        db,
        userId: userId,
        storage: storage,
      );
    });

    tearDown(() async {
      await db.close();
      await LocalAssetServer.stopServer();
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('exports existing SQLite history once into the character workspace',
        () async {
      final sqliteOnly = PersonaChatService.forTesting(db);
      final first = await sqliteOnly.addUserMessage(
        characterId,
        '旧的一句',
        timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
      );
      await sqliteOnly.addCharacterMessages(
        characterId,
        [CharacterOutgoingMessage.text('我还在。')],
        timestamp: DateTime.parse('2026-07-15T09:00:02+08:00'),
        contactEpisodeId: 'character_conversation:old',
      );
      await sqliteOnly.advanceReplyCursor(
        characterId: characterId,
        consumedThroughMessageId: first,
      );

      await storage.ensureMigrated(userId: userId, db: db);
      await storage.ensureMigrated(userId: userId, db: db);

      final records = await storage.loadMessages(
        userId: userId,
        characterId: characterId,
      );
      expect(records.map((record) => record.content), ['旧的一句', '我还在。']);
      final exportedUser = records.first;
      final sqliteUser = await (db.select(db.personaChatMessages)
            ..where((row) => row.id.equals(first)))
          .getSingle();
      expect(exportedUser.id, sqliteUser.stableId);
      final state = await storage.loadState(
        userId: userId,
        characterId: characterId,
      );
      expect(state.consumedThroughMessageId, sqliteUser.stableId);
    });

    test('rebuilds SQLite from workspace after the database is wiped',
        () async {
      final userMessageId = await chat.addUserMessage(
        characterId,
        '我刚下楼',
        timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
      );
      await chat.completeConversationEpisode(
        characterId: characterId,
        consumedThroughMessageId: userMessageId,
        characterMessages: [
          CharacterOutgoingMessage.text('是有点热。'),
          CharacterOutgoingMessage.text('那就买一杯。'),
        ],
        episodeId: 'character_conversation:task-9',
        timestamp: DateTime.parse('2026-07-15T09:00:05+08:00'),
      );

      await db.delete(db.personaChatMessages).go();
      await db.delete(db.personaChatReplyCursors).go();

      await chat.reconcileFromWorkspace(userId);

      final restored = await chat.getMessages(characterId);
      expect(
        restored.map((message) => message.content).toList().reversed,
        ['我刚下楼', '是有点热。', '那就买一杯。'],
      );
      expect(await chat.getPendingUserMessages(characterId), isEmpty);
      expect(
        restored.where((message) => message.isFromCharacter).map(
              (message) => message.contactEpisodeId,
            ),
        everyElement('character_conversation:task-9'),
      );
    });

    test('does not re-answer historical user messages after a crash gap',
        () async {
      final userMessageId = await chat.addUserMessage(
        characterId,
        '在吗',
        timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
      );
      final userRow = await (db.select(db.personaChatMessages)
            ..where((row) => row.id.equals(userMessageId)))
          .getSingle();
      await storage.advanceCursor(
        userId: userId,
        characterId: characterId,
        consumedThroughMessageId: userRow.stableId!,
      );

      await db.delete(db.personaChatReplyCursors).go();
      await chat.reconcileFromWorkspace(userId);

      expect(await chat.getPendingUserMessages(characterId), isEmpty);
    });

    test('retried episodes do not duplicate workspace or SQLite rows',
        () async {
      final userMessageId = await chat.addUserMessage(
        characterId,
        '你好',
        timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
      );
      Future<void> speak() {
        return chat.completeConversationEpisode(
          characterId: characterId,
          consumedThroughMessageId: userMessageId,
          characterMessages: [CharacterOutgoingMessage.text('嗯。')],
          episodeId: 'character_conversation:task-retry',
          timestamp: DateTime.parse('2026-07-15T09:00:05+08:00'),
        );
      }

      await speak();
      await speak();

      final rows = await db.select(db.personaChatMessages).get();
      expect(rows.where((row) => row.isFromCharacter), hasLength(1));
      final records = await storage.loadMessages(
        userId: userId,
        characterId: characterId,
      );
      expect(
        records.where((record) => record.isFromCharacter),
        hasLength(1),
      );
    });
  });
}
