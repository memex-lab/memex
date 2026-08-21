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

    test('stores only messages and commits a multi-bubble turn once', () async {
      await _appendUser(storage, content: '你醒了吗');
      final cursorAfterUser = (await storage.loadMetadata(
        userId: _userId,
        characterId: _characterId,
      ))
          .messagesByteLength;

      Future<List<PersonaChatConversationRecord>> commit() {
        return storage.appendTurn(
          userId: _userId,
          characterId: _characterId,
          turnId: 'character_conversation:1-1',
          expectedRecordCount: 2,
          agentProcessedThroughUserMessageId: 1,
          records: (firstMessageId) => [
            _record(firstMessageId, '醒了。'),
            _record(firstMessageId + 1, '怎么了？'),
          ],
        );
      }

      expect((await commit()).map((record) => record.id), [2, 3]);
      expect((await commit()).map((record) => record.id), [2, 3]);

      final lines = await _messagesFile(fileSystem).readAsLines();
      expect(lines, hasLength(3));
      for (final line in lines) {
        final message = jsonDecode(line) as Map<String, dynamic>;
        expect(message['id'], isA<int>());
        expect(message['role'], isIn(['user', 'assistant']));
        expect(message['content'], isA<List>());
        expect(message, isNot(contains('seq')));
        expect(message, isNot(contains('record_type')));
        expect(message, isNot(contains('operation_id')));
      }

      final metadata = await storage.loadMetadata(
        userId: _userId,
        characterId: _characterId,
      );
      expect(metadata.nextMessageId, 4);
      expect(metadata.agentProcessedThroughUserMessageId, 1);
      expect(metadata.lastTurnId, 'character_conversation:1-1');
      expect(
        File(fileSystem.getCharacterConversationPendingCommitPath(
          _userId,
          _characterId,
        )).existsSync(),
        isFalse,
      );

      final newest = await storage.loadMessagePage(
        userId: _userId,
        characterId: _characterId,
        limit: 2,
      );
      expect(newest.records.map((record) => record.content), ['怎么了？', '醒了。']);
      expect(newest.olderCursor, isNotNull);
      final older = await storage.loadMessagePage(
        userId: _userId,
        characterId: _characterId,
        limit: 2,
        beforeCursor: newest.olderCursor,
      );
      expect(older.records.single.content, '你醒了吗');

      final appended = await storage.loadMessagesAfter(
        userId: _userId,
        characterId: _characterId,
        afterCursor: cursorAfterUser,
      );
      expect(appended.records.map((record) => record.content), ['怎么了？', '醒了。']);
    });

    test('finds an older committed turn without a receipt or duplicate',
        () async {
      await _appendUser(storage, content: '第一句');
      await storage.appendTurn(
        userId: _userId,
        characterId: _characterId,
        turnId: 'character_conversation:1-1',
        expectedRecordCount: 1,
        agentProcessedThroughUserMessageId: 1,
        records: (firstMessageId) => [_record(firstMessageId, '旧回复')],
      );
      await storage.tryAppendInitiativeTurn(
        userId: _userId,
        characterId: _characterId,
        turnId: 'character_initiative:newer-source',
        expectedRecordCount: 1,
        records: (firstMessageId) => [
          _record(
            firstMessageId,
            '后来的主动消息',
            turnId: 'character_initiative:newer-source',
          ),
        ],
      );

      final retry = await storage.appendTurn(
        userId: _userId,
        characterId: _characterId,
        turnId: 'character_conversation:1-1',
        expectedRecordCount: 1,
        agentProcessedThroughUserMessageId: 1,
        records: (_) => throw StateError('retry must not regenerate'),
      );

      expect(retry.single.content, '旧回复');
      expect(await _messagesFile(fileSystem).readAsLines(), hasLength(3));
      await _appendUser(storage, content: '更新最后一个 turn 缓存');
      await storage.appendTurn(
        userId: _userId,
        characterId: _characterId,
        turnId: 'character_conversation:4-4',
        expectedRecordCount: 1,
        agentProcessedThroughUserMessageId: 4,
        records: (firstMessageId) => [
          _record(
            firstMessageId,
            '新回复',
            turnId: 'character_conversation:4-4',
          ),
        ],
      );
      expect(
        await storage.tryAppendInitiativeTurn(
          userId: _userId,
          characterId: _characterId,
          turnId: 'character_initiative:newer-source',
          expectedRecordCount: 1,
          records: (_) => throw StateError('retry must not regenerate'),
        ),
        isTrue,
      );
      expect(await _messagesFile(fileSystem).readAsLines(), hasLength(5));
      expect(
        Directory(fileSystem.getCharacterConversationPath(
          _userId,
          _characterId,
        )).listSync().whereType<File>().map((file) => file.path),
        everyElement(isNot(contains('_episodes'))),
      );
    });

    for (final phase in PersonaChatCommitPhase.values) {
      test('recovers an interrupted turn after ${phase.name}', () async {
        await _appendUser(storage, content: '第一句');
        var failed = false;
        final interrupted = PersonaChatConversationStorage(
          fileSystem: fileSystem,
          commitObserver: (current) async {
            if (!failed && current == phase) {
              failed = true;
              throw StateError('simulated crash after ${phase.name}');
            }
          },
        );

        expect(
          () => interrupted.appendTurn(
            userId: _userId,
            characterId: _characterId,
            turnId: 'character_conversation:1-1',
            expectedRecordCount: 2,
            agentProcessedThroughUserMessageId: 1,
            records: (firstMessageId) => [
              _record(firstMessageId, '第二句'),
              _record(firstMessageId + 1, '第三句'),
            ],
          ),
          throwsStateError,
        );

        final recovered = PersonaChatConversationStorage(
          fileSystem: fileSystem,
        );
        final messages = await recovered.loadMessages(
          userId: _userId,
          characterId: _characterId,
        );
        expect(
          messages.reversed.map((record) => record.content),
          ['第一句', '第二句', '第三句'],
        );
        expect(
          await recovered.getReplyCursor(
            userId: _userId,
            characterId: _characterId,
          ),
          1,
        );
        expect(
          File(fileSystem.getCharacterConversationPendingCommitPath(
            _userId,
            _characterId,
          )).existsSync(),
          isFalse,
        );

        final retry = await recovered.appendTurn(
          userId: _userId,
          characterId: _characterId,
          turnId: 'character_conversation:1-1',
          expectedRecordCount: 2,
          agentProcessedThroughUserMessageId: 1,
          records: (_) => throw StateError('retry must not regenerate'),
        );
        expect(retry.map((record) => record.id), [2, 3]);
      });
    }

    test('replays a partially appended batch from its write-ahead file',
        () async {
      await _appendUser(storage, content: '第一句');
      var interrupted = false;
      final crashing = PersonaChatConversationStorage(
        fileSystem: fileSystem,
        commitObserver: (phase) async {
          if (interrupted || phase != PersonaChatCommitPhase.pendingWritten) {
            return;
          }
          interrupted = true;
          final pending = File(
            fileSystem.getCharacterConversationPendingCommitPath(
              _userId,
              _characterId,
            ),
          );
          final payload = jsonDecode(await pending.readAsString()) as Map;
          final firstRow = (payload['messages'] as List).first;
          await _messagesFile(fileSystem).writeAsString(
            '${jsonEncode(firstRow)}\n',
            mode: FileMode.append,
            flush: true,
          );
          throw StateError('simulated partial append');
        },
      );

      await expectLater(
        crashing.appendTurn(
          userId: _userId,
          characterId: _characterId,
          turnId: 'character_conversation:1-1',
          expectedRecordCount: 2,
          agentProcessedThroughUserMessageId: 1,
          records: (firstMessageId) => [
            _record(firstMessageId, '第二句'),
            _record(firstMessageId + 1, '第三句'),
          ],
        ),
        throwsStateError,
      );

      final messages = await storage.loadMessages(
        userId: _userId,
        characterId: _characterId,
      );
      expect(messages.map((record) => record.id).toSet(), {1, 2, 3});
      expect(await _messagesFile(fileSystem).readAsLines(), hasLength(3));
    });

    test('serializes writers and allocates one ordered message id', () async {
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
      expect(messages.map((record) => record.id).toSet(), {
        for (var id = 1; id <= 12; id++) id,
      });
      expect(
        (await storage.loadMetadata(
          userId: _userId,
          characterId: _characterId,
        ))
            .nextMessageId,
        13,
      );
    });

    test('repairs derived metadata after an unindexed single append', () async {
      await _appendUser(storage, content: '第一句');
      await storage.advanceCursor(
        userId: _userId,
        characterId: _characterId,
        processedThroughUserMessageId: 1,
      );
      final file = _messagesFile(fileSystem);
      final second = PersonaChatConversationRecord(
        id: 2,
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

      final metadata = await storage.loadMetadata(
        userId: _userId,
        characterId: _characterId,
      );
      expect(metadata.nextMessageId, 3);
      expect(metadata.messageCount, 2);
      expect(metadata.unreadCount, 1);
      expect(metadata.agentProcessedThroughUserMessageId, 1);
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

    test('keeps read and agent-processing boundaries outside messages',
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
        processedThroughUserMessageId: 1,
      );
      expect(
        await storage.markAllRead(
          userId: _userId,
          characterId: _characterId,
        ),
        1,
      );
      expect(await file.readAsBytes(), before);

      final metadata = await storage.loadMetadata(
        userId: _userId,
        characterId: _characterId,
      );
      expect(metadata.agentProcessedThroughUserMessageId, 1);
      expect(metadata.readThroughMessageId, 2);
      expect(metadata.unreadCount, 0);
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

    test('clear changes generation and never reuses a message id', () async {
      await _appendUser(storage, content: '旧消息');
      final before = await storage.loadMetadata(
        userId: _userId,
        characterId: _characterId,
      );
      expect(
        await storage.clearConversation(
          userId: _userId,
          characterId: _characterId,
          clearedAt: DateTime.parse('2026-07-15T10:00:00+08:00'),
        ),
        1,
      );
      await expectLater(
        storage.appendTurn(
          userId: _userId,
          characterId: _characterId,
          turnId: 'character_conversation:1-1',
          expectedRecordCount: 1,
          agentProcessedThroughUserMessageId: 1,
          expectedGeneration: before.generation,
          records: (firstMessageId) => [
            _record(firstMessageId, '不应出现的旧回复'),
          ],
        ),
        throwsStateError,
      );
      expect(
        await storage.tryAppendInitiativeTurn(
          userId: _userId,
          characterId: _characterId,
          turnId: 'character_initiative:old-source',
          expectedRecordCount: 1,
          expectedGeneration: before.generation,
          records: (firstMessageId) => [
            _record(
              firstMessageId,
              '不应出现的旧主动消息',
              turnId: 'character_initiative:old-source',
            ),
          ],
        ),
        isFalse,
      );
      final next = await storage.appendMessage(
        userId: _userId,
        characterId: _characterId,
        isFromCharacter: false,
        content: '新消息',
        timestamp: DateTime.parse('2026-07-15T10:00:01+08:00'),
        messageType: PersonaChatMessageTypes.text,
        origin: PersonaChatMessageOrigin.conversation,
      );
      final after = await storage.loadMetadata(
        userId: _userId,
        characterId: _characterId,
      );
      expect(next.id, 2);
      expect(after.generation, before.generation + 1);
    });

    for (final phase in PersonaChatCommitPhase.values) {
      test('recovers an interrupted clear after ${phase.name}', () async {
        await _appendUser(storage, content: '即将清空');
        final before = await storage.loadMetadata(
          userId: _userId,
          characterId: _characterId,
        );
        var failed = false;
        final interrupted = PersonaChatConversationStorage(
          fileSystem: fileSystem,
          commitObserver: (current) async {
            if (!failed && current == phase) {
              failed = true;
              throw StateError('simulated clear crash after ${phase.name}');
            }
          },
        );

        await expectLater(
          interrupted.clearConversation(
            userId: _userId,
            characterId: _characterId,
            clearedAt: DateTime.parse('2026-07-15T10:00:00+08:00'),
          ),
          throwsStateError,
        );

        final recovered = PersonaChatConversationStorage(
          fileSystem: fileSystem,
        );
        expect(
          await recovered.loadMessages(
            userId: _userId,
            characterId: _characterId,
          ),
          isEmpty,
        );
        final metadata = await recovered.loadMetadata(
          userId: _userId,
          characterId: _characterId,
        );
        expect(metadata.generation, before.generation + 1);
        expect(metadata.nextMessageId, before.nextMessageId);
      });
    }

    test('recovers an interrupted legacy snapshot import', () async {
      var failed = false;
      final interrupted = PersonaChatConversationStorage(
        fileSystem: fileSystem,
        commitObserver: (phase) async {
          if (!failed && phase == PersonaChatCommitPhase.messagesAppended) {
            failed = true;
            throw StateError('simulated import crash');
          }
        },
      );
      final records = [
        PersonaChatConversationRecord(
          id: 1,
          characterId: _characterId,
          isFromCharacter: false,
          content: '旧用户消息',
          isRead: true,
          timestamp: DateTime.parse('2026-07-15T09:00:00+08:00'),
          messageType: PersonaChatMessageTypes.text,
          origin: PersonaChatMessageOrigin.conversation,
        ),
        _record(2, '旧角色回复'),
      ];

      await expectLater(
        interrupted.importLegacySnapshot(
          userId: _userId,
          characterId: _characterId,
          records: records,
          agentProcessedThroughUserMessageId: 1,
        ),
        throwsStateError,
      );

      final recovered = PersonaChatConversationStorage(
        fileSystem: fileSystem,
      );
      expect(
        (await recovered.loadMessages(
          userId: _userId,
          characterId: _characterId,
        ))
            .map((record) => record.content),
        ['旧角色回复', '旧用户消息'],
      );
      expect(
        await recovered.getReplyCursor(
          userId: _userId,
          characterId: _characterId,
        ),
        1,
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
  int id,
  String content, {
  String turnId = 'character_conversation:1-1',
}) {
  return PersonaChatConversationRecord(
    id: id,
    characterId: _characterId,
    isFromCharacter: true,
    content: content,
    isRead: false,
    timestamp: DateTime.parse('2026-07-15T09:00:05+08:00'),
    messageType: PersonaChatMessageTypes.text,
    origin: PersonaChatMessageOrigin.conversation,
    turnId: turnId,
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
