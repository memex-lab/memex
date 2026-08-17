import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersonaChatConversationStorage', () {
    late Directory tempRoot;
    late FileSystemService fileSystem;
    late PersonaChatConversationStorage storage;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp(
        'memex_persona_chat_storage_',
      );
      fileSystem = FileSystemService.detached(dataRoot: tempRoot.path);
      storage = PersonaChatConversationStorage(fileSystem: fileSystem);
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('appends user and character messages under Conversation/', () async {
      await storage.appendMessage(
        userId: 'wujia',
        characterId: 'yaoyao',
        isFromCharacter: false,
        content: '你醒了吗',
        timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
        messageType: PersonaChatMessageTypes.text,
        origin: PersonaChatMessageOrigin.conversation,
        isRead: true,
      );
      final episode = await storage.appendEpisode(
        userId: 'wujia',
        characterId: 'yaoyao',
        contactEpisodeId: 'character_conversation:task-1',
        records: (nextSeq) => [
          PersonaChatConversationRecord(
            id: 'bubble-1',
            seq: nextSeq,
            characterId: 'yaoyao',
            isFromCharacter: true,
            content: '醒了。',
            isRead: false,
            timestamp: DateTime.parse('2026-07-15T09:00:05+08:00'),
            messageType: PersonaChatMessageTypes.text,
            origin: PersonaChatMessageOrigin.conversation,
            contactEpisodeId: 'character_conversation:task-1',
          ),
          PersonaChatConversationRecord(
            id: 'bubble-2',
            seq: nextSeq + 1,
            characterId: 'yaoyao',
            isFromCharacter: true,
            content: '怎么了？',
            isRead: false,
            timestamp: DateTime.parse('2026-07-15T09:00:05+08:00'),
            messageType: PersonaChatMessageTypes.text,
            origin: PersonaChatMessageOrigin.conversation,
            contactEpisodeId: 'character_conversation:task-1',
          ),
        ],
      );
      final retry = await storage.appendEpisode(
        userId: 'wujia',
        characterId: 'yaoyao',
        contactEpisodeId: 'character_conversation:task-1',
        records: (_) => throw StateError('retry must not write again'),
      );

      expect(retry.map((record) => record.id), ['bubble-1', 'bubble-2']);
      expect(episode, hasLength(2));

      final messagesFile = File(
        fileSystem.getCharacterConversationMessagesPath('wujia', 'yaoyao'),
      );
      final lines = (await messagesFile.readAsLines())
          .where((line) => line.trim().isNotEmpty)
          .toList();
      expect(lines, hasLength(3));
      expect(jsonDecode(lines.first)['speaker'], 'user');
      expect(jsonDecode(lines[1])['contact_episode_id'],
          'character_conversation:task-1');
    });

    test('keeps valid JSONL history when the last line is truncated', () async {
      await storage.appendMessage(
        userId: 'wujia',
        characterId: 'yaoyao',
        isFromCharacter: false,
        content: '第一句',
        timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
        messageType: PersonaChatMessageTypes.text,
        origin: PersonaChatMessageOrigin.conversation,
        isRead: true,
        stableId: 'keep-me',
      );
      final file = File(
        fileSystem.getCharacterConversationMessagesPath('wujia', 'yaoyao'),
      );
      await file.writeAsString(
        '${await file.readAsString()}{"id":"partial"',
        flush: true,
      );

      final records = await storage.loadMessages(
        userId: 'wujia',
        characterId: 'yaoyao',
      );
      expect(records.map((record) => record.id), ['keep-me']);
      expect(await file.readAsString(), isNot(contains('partial')));
    });

    test('clearing a conversation survives a later projection rebuild',
        () async {
      await storage.appendMessage(
        userId: 'wujia',
        characterId: 'yaoyao',
        isFromCharacter: false,
        content: '稍后删掉',
        timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
        messageType: PersonaChatMessageTypes.text,
        origin: PersonaChatMessageOrigin.conversation,
        isRead: true,
      );
      await storage.clearConversation(
        userId: 'wujia',
        characterId: 'yaoyao',
        clearedAt: DateTime.parse('2026-07-15T10:00:00+08:00'),
      );

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await storage.rebuildSqliteProjection(
        userId: 'wujia',
        characterId: 'yaoyao',
        db: db,
      );
      final rows = await db.select(db.personaChatMessages).get();
      expect(rows, isEmpty);
      final state = await storage.loadState(
        userId: 'wujia',
        characterId: 'yaoyao',
      );
      expect(state.clearedAt, isNotNull);
      expect(state.consumedThroughMessageId, isNull);
    });
  });
}
