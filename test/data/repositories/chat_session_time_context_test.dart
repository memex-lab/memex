import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/repositories/chat.dart';
import 'package:memex/data/services/chat_session_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('chat session time context', () {
    const userId = 'chat-time-test-user';
    late Directory tempDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      await UserStorage.saveUser(userId);
      tempDir = await Directory.systemTemp.createTemp(
        'memex_chat_time_context_test_',
      );
      await FileSystemService.init(tempDir.path);
    });

    tearDown(() async {
      await LocalAssetServer.stopServer();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('hydrates local time fields for legacy session detail', () async {
      await _writeSession(
        userId: userId,
        sessionId: 'legacy-session',
        data: {
          'session_id': 'legacy-session',
          'agent_name': 'memex_agent',
          'title': 'Legacy Session',
          'created_at': '2026-04-28T20:00:46.000',
          'updated_at': '2026-04-28T20:05:00.000',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': '今天晚上聊过什么？'},
              ],
              'timestamp': '2026-04-28T20:00:46.000',
            },
            {
              'role': 'ai',
              'content': [
                {'type': 'text', 'text': '这是一个坏时间戳。'},
              ],
              'timestamp': 'not-a-date',
            },
          ],
        },
      );

      final detail = await fetchChatSessionDetailEndpoint('legacy-session');
      final messages = detail['messages'] as List<dynamic>;
      final firstMessage = messages.first as Map<String, dynamic>;
      final secondMessage = messages.last as Map<String, dynamic>;

      expect(detail['created_at_local'], contains('2026-04-28 20:00:46'));
      expect(detail['updated_at_local'], contains('2026-04-28 20:05:00'));
      expect(detail['created_at_unix_seconds'], isA<int>());
      expect(firstMessage['local_time'], contains('2026-04-28 20:00:46'));
      expect(firstMessage['unix_seconds'], isA<int>());
      expect(secondMessage.containsKey('local_time'), isFalse);
      expect(secondMessage.containsKey('unix_seconds'), isFalse);
    });

    test('preserves existing local time fields in session messages', () async {
      await _writeSession(
        userId: userId,
        sessionId: 'preserved-session',
        data: {
          'session_id': 'preserved-session',
          'agent_name': 'memex_agent',
          'title': 'Preserved Session',
          'created_at': '2026-04-28T20:00:46.000',
          'created_at_local': 'already-local-created',
          'created_at_unix_seconds': 111,
          'updated_at': '2026-04-28T20:05:00.000',
          'updated_at_local': 'already-local-updated',
          'updated_at_unix_seconds': 222,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': 'preserve me'},
              ],
              'timestamp': '2026-04-28T20:00:46.000',
              'local_time': 'already-local-message',
              'unix_seconds': 333,
            },
          ],
        },
      );

      final detail = await fetchChatSessionDetailEndpoint('preserved-session');
      final message =
          (detail['messages'] as List<dynamic>).single as Map<String, dynamic>;

      expect(detail['created_at_local'], 'already-local-created');
      expect(detail['created_at_unix_seconds'], 111);
      expect(detail['updated_at_local'], 'already-local-updated');
      expect(detail['updated_at_unix_seconds'], 222);
      expect(message['local_time'], 'already-local-message');
      expect(message['unix_seconds'], 333);
    });

    test('migrates legacy artifacts in session detail and persists v2',
        () async {
      await _writeSession(
        userId: userId,
        sessionId: 'legacy-artifact-session',
        data: {
          'session_id': 'legacy-artifact-session',
          'agent_name': 'memex_agent',
          'title': 'Legacy Artifact Session',
          'created_at': '2026-04-28T20:00:46.000',
          'updated_at': '2026-04-28T20:05:00.000',
          'messages': [
            {
              'role': 'ai',
              'turn_id': 'turn-detail',
              'content': [
                {'type': 'text', 'text': 'done'},
              ],
              'timestamp': '2026-04-28T20:05:00.000',
              'artifacts': [
                {
                  'type': 'file',
                  'path': 'PKM/Projects/memex.md',
                  'snippet': '# Memex',
                  'updated': true,
                },
              ],
            },
          ],
        },
      );

      final detail =
          await fetchChatSessionDetailEndpoint('legacy-artifact-session');
      final message =
          (detail['messages'] as List<dynamic>).single as Map<String, dynamic>;
      final artifactMap = Map<String, dynamic>.from(
        (message['artifacts'] as List).single as Map,
      );
      final artifact = ChatArtifact.fromJson(artifactMap)!;

      expect(artifact.kind, ChatArtifact.kindKnowledgeFile);
      expect(artifact.workspacePath, 'PKM/Projects/memex.md');
      expect(artifact.sourceRunId, 'turn-detail');

      final storage = ChatSessionStorage.instance;
      final persisted = await storage.loadSessionData(
        userId,
        'legacy-artifact-session',
      );
      expect(
        persisted[ChatArtifactSessionMigration.schemaVersionKey],
        ChatArtifact.schemaVersion,
      );
      final persistedArtifact =
          (((persisted['messages'] as List).single as Map)['artifacts'] as List)
              .single as Map;
      expect(persistedArtifact.containsKey('type'), isFalse);
      expect(
        await File(storage.legacyYamlPath(
          userId,
          'legacy-artifact-session',
        )).exists(),
        isFalse,
      );
      expect(
        await File(storage.messagesPath(
          userId,
          'legacy-artifact-session',
        )).exists(),
        isTrue,
      );
    });

    test('paginates session detail messages from newest backwards', () async {
      await _writeSession(
        userId: userId,
        sessionId: 'paged-session',
        data: {
          'session_id': 'paged-session',
          'agent_name': 'memex_agent',
          'title': 'Paged Session',
          'created_at': '2026-04-28T20:00:46.000',
          'updated_at': '2026-04-28T20:05:00.000',
          'messages': [
            for (var i = 1; i <= 5; i++)
              {
                'role': i.isOdd ? 'user' : 'ai',
                'content': [
                  {'type': 'text', 'text': 'message $i'},
                ],
                'timestamp': '2026-04-28T20:0$i:00.000',
              },
          ],
        },
      );

      final latest = await fetchChatSessionDetailEndpoint(
        'paged-session',
        messageLimit: 2,
      );
      final latestMessages = latest['messages'] as List<dynamic>;

      expect(latest['has_more_messages'], isTrue);
      expect(latest['older_cursor'], isNotNull);
      expect(_messageText(latestMessages[0]), 'message 4');
      expect(_messageText(latestMessages[1]), 'message 5');

      final older = await fetchChatSessionDetailEndpoint(
        'paged-session',
        messageLimit: 2,
        messageBeforeCursor: latest['older_cursor'] as String?,
      );
      final olderMessages = older['messages'] as List<dynamic>;

      expect(older['has_more_messages'], isTrue);
      expect(older['older_cursor'], isNotNull);
      expect(_messageText(olderMessages[0]), 'message 2');
      expect(_messageText(olderMessages[1]), 'message 3');

      final oldest = await fetchChatSessionDetailEndpoint(
        'paged-session',
        messageLimit: 2,
        messageBeforeCursor: older['older_cursor'] as String?,
      );
      final oldestMessages = oldest['messages'] as List<dynamic>;

      expect(oldest['has_more_messages'], isFalse);
      expect(_messageText(oldestMessages.single), 'message 1');
    });

    test('adds local time fallback to chat session list rows', () async {
      await _writeSession(
        userId: userId,
        sessionId: 'memex_agent_list-session',
        data: {
          'session_id': 'memex_agent_list-session',
          'agent_name': 'memex_agent',
          'title': 'List Session',
          'created_at': '2026-04-28T20:00:46.000',
          'updated_at': '2026-04-28T20:05:00.000',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': 'preview text'},
              ],
              'timestamp': '2026-04-28T20:00:46.000',
            },
          ],
        },
      );

      final sessions = await fetchChatSessionsEndpoint(
        agentName: 'memex_agent',
        limit: 10,
      );

      expect(sessions, hasLength(1));
      expect(sessions.single['created_at_local'], contains('2026-04-28'));
      expect(sessions.single['updated_at_local'], contains('2026-04-28'));
      expect(sessions.single['last_message_preview'], 'preview text');
    });
  });
}

String _messageText(dynamic message) {
  final map = message as Map<String, dynamic>;
  final content = map['content'] as List<dynamic>;
  final textPart = content.single as Map<String, dynamic>;
  return textPart['text'] as String;
}

Future<void> _writeSession({
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
