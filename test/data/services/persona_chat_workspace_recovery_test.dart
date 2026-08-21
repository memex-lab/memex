import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/data/services/persona_chat_legacy_migration_service.dart';
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
      tempRoot = await Directory.systemTemp.createTemp('persona_recovery_');
      await FileSystemService.init(tempRoot.path);
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = PersonaChatConversationStorage(
        fileSystem: FileSystemService.instance,
      );
      chat = PersonaChatService.forTesting(storage: storage, userId: userId);
    });

    tearDown(() async {
      await db.close();
      await LocalAssetServer.stopServer();
      if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
    });

    test('imports legacy SQLite once, including its reply cursor', () async {
      final first = await db.into(db.personaChatMessages).insert(
            PersonaChatMessagesCompanion.insert(
              characterId: characterId,
              isFromCharacter: false,
              content: '旧的一句',
              isRead: const Value(true),
              timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
            ),
          );
      await db.into(db.personaChatMessages).insert(
            PersonaChatMessagesCompanion.insert(
              characterId: characterId,
              isFromCharacter: true,
              content: '我还在。',
              timestamp: DateTime.parse('2026-07-15T09:00:02+08:00'),
              contactEpisodeId: const Value('character_conversation:old'),
            ),
          );
      await db.into(db.personaChatReplyCursors).insert(
            PersonaChatReplyCursorsCompanion.insert(
              characterId: characterId,
              consumedThroughMessageId: Value(first),
              updatedAt: 1,
            ),
          );

      final migration = PersonaChatLegacyMigrationService(storage: storage);
      await migration.ensureMigrated(userId: userId, database: db);
      await migration.ensureMigrated(userId: userId, database: db);

      final messages = await chat.getMessages(characterId);
      expect(
        messages.reversed.map((message) => message.content),
        ['旧的一句', '我还在。'],
      );
      expect(await chat.getReplyCursor(characterId), 1);
      expect(await chat.getPendingUserMessages(characterId), isEmpty);
    });

    test('runtime conversation remains available after SQLite is wiped',
        () async {
      final userMessageId = await chat.addUserMessage(characterId, '我刚下楼');
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

      final restored = await chat.getMessages(characterId);
      expect(
        restored.reversed.map((message) => message.content),
        ['我刚下楼', '是有点热。', '那就买一杯。'],
      );
      expect(await chat.getPendingUserMessages(characterId), isEmpty);
    });

    test('retried multi-bubble episodes are idempotent', () async {
      final userMessageId = await chat.addUserMessage(characterId, '你好');
      Future<List<int>> speak() => chat.completeConversationEpisode(
            characterId: characterId,
            consumedThroughMessageId: userMessageId,
            characterMessages: [
              CharacterOutgoingMessage.text('第一句'),
              CharacterOutgoingMessage.text('第二句'),
            ],
            episodeId: 'character_conversation:task-retry',
            timestamp: DateTime.parse('2026-07-15T09:00:05+08:00'),
          );

      expect(await speak(), [2, 3]);
      expect(await speak(), [2, 3]);
      final messages = await chat.getMessages(characterId);
      expect(
          messages.where((message) => message.isFromCharacter), hasLength(2));
      expect(await db.select(db.personaChatMessages).get(), isEmpty);
    });
  });
}
