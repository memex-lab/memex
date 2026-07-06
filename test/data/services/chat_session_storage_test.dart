import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/services/chat_session_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatSessionStorage', () {
    const userId = 'chat-storage-test-user';
    late Directory tempDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      await UserStorage.saveUser(userId);
      tempDir = await Directory.systemTemp.createTemp(
        'memex_chat_session_storage_test_',
      );
      await FileSystemService.init(tempDir.path);
    });

    tearDown(() async {
      await LocalAssetServer.stopServer();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('migrates legacy YAML to metadata JSON and message JSONL', () async {
      const sessionId = 'memex_agent_legacy_storage';
      await _writeLegacyYaml(
        userId: userId,
        sessionId: sessionId,
        data: {
          'session_id': sessionId,
          'agent_name': 'memex_agent',
          'title': 'Legacy Storage',
          'created_at': '2026-06-22T12:00:00.000',
          'updated_at': '2026-06-22T12:01:00.000',
          'messages': [
            {
              'role': 'ai',
              'turn_id': 'turn-1',
              'timestamp': '2026-06-22T12:01:00.000',
              'content': [
                {'type': 'text', 'text': 'done'},
              ],
              'artifacts': [
                {
                  'type': 'card',
                  'id': '2026/06/22.md#ts_1',
                  'title': 'Legacy card',
                },
              ],
            },
          ],
        },
      );

      final storage = ChatSessionStorage.instance;
      await storage.ensureMigrated(userId);

      expect(await File(storage.legacyYamlPath(userId, sessionId)).exists(),
          isFalse);
      expect(
          await File(storage.metadataPath(userId, sessionId)).exists(), isTrue);
      expect(
          await File(storage.messagesPath(userId, sessionId)).exists(), isTrue);

      final metadata = jsonDecode(
        await File(storage.metadataPath(userId, sessionId)).readAsString(),
      ) as Map<String, dynamic>;
      expect(metadata.containsKey('messages'), isFalse);
      expect(metadata.containsKey('message_count'), isFalse);
      expect(metadata[ChatSessionStorage.storageSchemaVersionKey],
          ChatSessionStorage.storageSchemaVersion);
      final migrationState = await _readMigrationState(userId);
      expect(
        migrationState[ChatSessionStorage.storageMigrationKey],
        isTrue,
      );

      final messages =
          await File(storage.messagesPath(userId, sessionId)).readAsLines();
      expect(messages, hasLength(1));
      final message = jsonDecode(messages.single) as Map<String, dynamic>;
      final artifact = ChatArtifact.fromJson(
        Map<String, dynamic>.from((message['artifacts'] as List).single as Map),
      );
      expect(artifact?.kind, ChatArtifact.kindTimelineCard);
    });

    test('appends messages to JSONL and updates metadata only', () async {
      const sessionId = 'memex_agent_new_storage';
      final storage = ChatSessionStorage.instance;

      await storage.createSession(
        userId: userId,
        sessionId: sessionId,
        metadata: {
          'session_id': sessionId,
          'agent_name': 'memex_agent',
          'title': 'New Storage',
          'created_at': '2026-06-22T12:00:00.000',
          'updated_at': '2026-06-22T12:00:00.000',
        },
      );

      await storage.appendMessage(
        userId: userId,
        sessionId: sessionId,
        message: {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'hello jsonl'},
          ],
          'timestamp': '2026-06-22T12:01:00.000',
        },
      );

      final metadata = jsonDecode(
        await File(storage.metadataPath(userId, sessionId)).readAsString(),
      ) as Map<String, dynamic>;
      final lines =
          await File(storage.messagesPath(userId, sessionId)).readAsLines();

      expect(metadata.containsKey('messages'), isFalse);
      expect(metadata.containsKey('message_count'), isFalse);
      expect(metadata['last_message_preview'], 'hello jsonl');
      expect(lines, hasLength(1));
      expect(jsonDecode(lines.single)['role'], 'user');
    });

    test('loads paged messages from newest backwards', () async {
      const sessionId = 'memex_agent_paged_storage';
      final storage = ChatSessionStorage.instance;

      await storage.createSession(
        userId: userId,
        sessionId: sessionId,
        metadata: {
          'session_id': sessionId,
          'agent_name': 'memex_agent',
          'title': 'Paged Storage',
          'created_at': '2026-06-22T12:00:00.000',
          'updated_at': '2026-06-22T12:00:00.000',
        },
        messages: [
          for (var i = 1; i <= 50; i++)
            {
              'role': i.isOdd ? 'user' : 'ai',
              'content': [
                {'type': 'text', 'text': 'message $i ${'x' * 600}'},
              ],
              'timestamp':
                  '2026-06-22T12:${(i % 60).toString().padLeft(2, '0')}:00.000',
            },
        ],
      );

      final latest = await storage.loadMessagePage(
        userId,
        sessionId,
        limit: 3,
      );
      final older = await storage.loadMessagePage(
        userId,
        sessionId,
        limit: 3,
        beforeCursor: latest.olderCursor,
      );

      expect(latest.hasMoreMessages, isTrue);
      expect(latest.olderCursor, isNotNull);
      expect(_messageText(latest.messages[0]), startsWith('message 48 '));
      expect(_messageText(latest.messages[1]), startsWith('message 49 '));
      expect(_messageText(latest.messages[2]), startsWith('message 50 '));
      expect(older.hasMoreMessages, isTrue);
      expect(_messageText(older.messages[0]), startsWith('message 45 '));
      expect(_messageText(older.messages[1]), startsWith('message 46 '));
      expect(_messageText(older.messages[2]), startsWith('message 47 '));
    });
  });
}

String _messageText(Map<String, dynamic> message) {
  final content = message['content'] as List<dynamic>;
  final textPart = content.single as Map<String, dynamic>;
  return textPart['text'] as String;
}

Future<void> _writeLegacyYaml({
  required String userId,
  required String sessionId,
  required Map<String, dynamic> data,
}) async {
  final sessionPath = p.join(
    FileSystemService.instance.getChatSessionsPath(userId),
    '$sessionId.yaml',
  );
  await FileSystemService.instance.writeYamlFile(sessionPath, data);
}

Future<Map<String, dynamic>> _readMigrationState(String userId) async {
  final stateFile = File(p.join(
    FileSystemService.instance.getSystemPath(userId),
    'migration_state.json',
  ));
  if (!await stateFile.exists()) return const {};
  return Map<String, dynamic>.from(
    jsonDecode(await stateFile.readAsString()) as Map,
  );
}
