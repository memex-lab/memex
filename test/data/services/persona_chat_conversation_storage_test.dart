import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/domain/models/character_message.dart';

const _userId = 'wujia';
const _characterId = 'yaoyao';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersonaChatConversationStorage', () {
    late Directory tempRoot;
    late FileSystemService fileSystem;
    late PersonaChatConversationStorage storage;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp('persona_chat_store_');
      fileSystem = FileSystemService.detached(dataRoot: tempRoot.path);
      storage = PersonaChatConversationStorage(fileSystem: fileSystem);
    });

    tearDown(() async {
      if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
    });

    test('appends one atomic JSONL envelope per episode and paginates bubbles',
        () async {
      await _appendUser(storage, content: '你醒了吗');
      final episode = await storage.appendEpisode(
        userId: _userId,
        characterId: _characterId,
        contactEpisodeId: 'character_conversation:task-1',
        expectedRecordCount: 2,
        consumedThroughSeq: 1,
        records: (nextSeq) => [
          _record(nextSeq, '醒了。', id: 'bubble-1'),
          _record(nextSeq + 1, '怎么了？', id: 'bubble-2'),
        ],
      );
      final retry = await storage.appendEpisode(
        userId: _userId,
        characterId: _characterId,
        contactEpisodeId: 'character_conversation:task-1',
        expectedRecordCount: 2,
        consumedThroughSeq: 1,
        records: (_) => throw StateError('retry must not append'),
      );

      expect(episode.map((record) => record.seq), [2, 3]);
      expect(retry.map((record) => record.id), ['bubble-1', 'bubble-2']);
      final lines = await _messagesFile(fileSystem).readAsLines();
      expect(lines, hasLength(2));
      expect(jsonDecode(lines.last)['record_type'], 'episode');
      final receiptDirectory = Directory(
        fileSystem.getCharacterConversationEpisodeReceiptsPath(
          _userId,
          _characterId,
        ),
      );
      final receiptFile = await receiptDirectory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .single;
      final receipt = jsonDecode(await receiptFile.readAsString());
      expect(receipt['status'], 'complete');
      expect(receipt['line_offset'], isNonNegative);
      expect(receipt, isNot(contains('records')));

      final newest = await storage.loadMessages(
        userId: _userId,
        characterId: _characterId,
        limit: 2,
      );
      expect(newest.map((record) => record.content), ['怎么了？', '醒了。']);
      final older = await storage.loadMessages(
        userId: _userId,
        characterId: _characterId,
        limit: 2,
        offset: 2,
      );
      expect(older.single.content, '你醒了吗');

      await File(
        fileSystem.getCharacterConversationMetadataPath(
          _userId,
          _characterId,
        ),
      ).writeAsString('{}\n', flush: true);
      expect(
        (await storage.loadMetadata(
          userId: _userId,
          characterId: _characterId,
        ))
            .consumedThroughSeq,
        1,
      );
    });

    test('recovers a pending episode receipt from the authoritative log',
        () async {
      await storage.appendEpisode(
        userId: _userId,
        characterId: _characterId,
        contactEpisodeId: 'character_conversation:task-1',
        expectedRecordCount: 2,
        records: (nextSeq) => [
          _record(nextSeq, '第一句', id: 'bubble-1'),
          _record(nextSeq + 1, '第二句', id: 'bubble-2'),
        ],
      );
      final receiptDirectory = Directory(
        fileSystem.getCharacterConversationEpisodeReceiptsPath(
          _userId,
          _characterId,
        ),
      );
      final receiptFile = await receiptDirectory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .single;
      await receiptFile.writeAsString(
        '${jsonEncode({
              'episode_id': 'character_conversation:task-1',
              'status': 'pending',
            })}\n',
        flush: true,
      );

      final recovered = await storage.appendEpisode(
        userId: _userId,
        characterId: _characterId,
        contactEpisodeId: 'character_conversation:task-1',
        expectedRecordCount: 2,
        records: (_) => throw StateError('recovery must not append'),
      );

      expect(recovered.map((record) => record.id), ['bubble-1', 'bubble-2']);
      expect(await _messagesFile(fileSystem).readAsLines(), hasLength(1));
      final repairedReceipt = jsonDecode(await receiptFile.readAsString());
      expect(repairedReceipt['status'], 'complete');
      expect(repairedReceipt, isNot(contains('records')));
    });

    test('serializes writers from separate storage instances', () async {
      final other = PersonaChatConversationStorage(fileSystem: fileSystem);
      await Future.wait([
        for (var index = 0; index < 12; index++)
          (index.isEven ? storage : other).appendMessage(
            userId: _userId,
            characterId: _characterId,
            isFromCharacter: index.isOdd,
            content: 'message-$index',
            timestamp: DateTime.parse('2026-07-15T09:00:00+08:00')
                .add(Duration(seconds: index)),
            messageType: PersonaChatMessageTypes.text,
            origin: PersonaChatMessageOrigin.conversation,
            isRead: index.isEven,
          ),
      ]);

      final messages = await storage.loadMessages(
        userId: _userId,
        characterId: _characterId,
        limit: 20,
      );
      expect(messages, hasLength(12));
      expect(messages.map((record) => record.seq).toSet(), hasLength(12));
      expect(
          (await storage.loadMetadata(
            userId: _userId,
            characterId: _characterId,
          ))
              .nextSeq,
          13);
    });

    test('repairs metadata after a crash between JSONL append and metadata',
        () async {
      await _appendUser(storage, content: '第一句');
      final file = _messagesFile(fileSystem);
      final second = PersonaChatConversationRecord(
        id: 'crash-gap',
        seq: 2,
        characterId: _characterId,
        isFromCharacter: true,
        content: '写入后崩溃',
        isRead: false,
        timestamp: DateTime.parse('2026-07-15T09:00:05+08:00'),
        messageType: PersonaChatMessageTypes.text,
        origin: PersonaChatMessageOrigin.conversation,
      );
      await file.writeAsString(
        '${jsonEncode(second.toJson())}\n',
        mode: FileMode.append,
        flush: true,
      );

      final messages = await storage.loadMessages(
        userId: _userId,
        characterId: _characterId,
      );
      final metadata = await storage.loadMetadata(
        userId: _userId,
        characterId: _characterId,
      );
      expect(messages.map((record) => record.content), ['写入后崩溃', '第一句']);
      expect(metadata.nextSeq, 3);
      expect(metadata.messageCount, 2);
      expect(metadata.unreadCount, 1);
      expect(metadata.messagesByteLength, await file.length());
    });

    test('truncates an incomplete UTF-8 tail without losing valid history',
        () async {
      await _appendUser(storage, content: '保留中文');
      final file = _messagesFile(fileSystem);
      await file.writeAsBytes(
        [...await file.readAsBytes(), 0xF0, 0x9F],
        flush: true,
      );

      final first = await storage.loadMessages(
        userId: _userId,
        characterId: _characterId,
      );
      final second = await storage.loadMessages(
        userId: _userId,
        characterId: _characterId,
      );
      expect(first.single.content, '保留中文');
      expect(second.single.content, '保留中文');
    });

    test('read and reply boundaries rebuild from the authoritative log',
        () async {
      await _appendUser(storage, content: '用户消息');
      await storage.appendMessage(
        userId: _userId,
        characterId: _characterId,
        isFromCharacter: true,
        content: '未读消息',
        timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
        messageType: PersonaChatMessageTypes.text,
        origin: PersonaChatMessageOrigin.initiative,
      );
      final file = _messagesFile(fileSystem);
      final before = await file.readAsBytes();

      await storage.advanceCursor(
        userId: _userId,
        characterId: _characterId,
        consumedThroughSeq: 1,
      );
      expect(
        await storage.markAllRead(
          userId: _userId,
          characterId: _characterId,
        ),
        1,
      );
      final after = await file.readAsBytes();
      expect(after.sublist(0, before.length), before);

      final metadataFile = File(
        fileSystem.getCharacterConversationMetadataPath(
          _userId,
          _characterId,
        ),
      );
      await metadataFile.writeAsString('{}\n', flush: true);
      final repaired = await storage.loadMetadata(
        userId: _userId,
        characterId: _characterId,
      );
      expect(repaired.consumedThroughSeq, 1);
      expect(repaired.readThroughSeq, 2);
      expect(repaired.unreadCount, 0);
      expect(
        (await storage.loadMessages(
          userId: _userId,
          characterId: _characterId,
        ))
            .first
            .isRead,
        isTrue,
      );
    });

    test('rejects character ids that escape the workspace', () {
      expect(
        () => fileSystem.getCharacterConversationPath(_userId, '../outside'),
        throwsArgumentError,
      );
    });
  });
}

PersonaChatConversationRecord _record(
  int seq,
  String content, {
  required String id,
}) {
  return PersonaChatConversationRecord(
    id: id,
    seq: seq,
    characterId: _characterId,
    isFromCharacter: true,
    content: content,
    isRead: false,
    timestamp: DateTime.parse('2026-07-15T09:00:05+08:00'),
    messageType: PersonaChatMessageTypes.text,
    origin: PersonaChatMessageOrigin.conversation,
    contactEpisodeId: 'character_conversation:task-1',
  );
}

Future<void> _appendUser(
  PersonaChatConversationStorage target, {
  required String content,
}) async {
  await target.appendMessage(
    userId: _userId,
    characterId: _characterId,
    isFromCharacter: false,
    content: content,
    timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
    messageType: PersonaChatMessageTypes.text,
    origin: PersonaChatMessageOrigin.conversation,
    isRead: true,
  );
}

File _messagesFile(FileSystemService fs) => File(
      fs.getCharacterConversationMessagesPath(_userId, _characterId),
    );
