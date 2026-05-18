import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/chat.dart';
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
