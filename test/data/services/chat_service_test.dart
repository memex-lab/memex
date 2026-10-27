import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/services/agent_foreground_task_tracker.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/data/services/chat_session_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });
  group('request preparation events', () {
    test('announces text preparation before doing any user/session I/O', () async {
      final event = await ChatService.instance.sendMessage(
        'hello', requestId: 'request-text',
      ).first;
      expect(event, isA<ChatTurnPreparingEvent>());
      expect((event as ChatTurnPreparingEvent).turnId, 'request-text');
    });

    test('announces image preparation before trying to read the file', () async {
      final event = await ChatService.instance.sendMessage(
        '', images: [XFile('/nonexistent/attachment.jpg')],
      ).first;
      expect(event, isA<ChatTurnPreparingEvent>());
    });

    test('rejects empty and whitespace-only requests without preparation', () async {
      for (final text in ['', '   ']) {
        final events = await ChatService.instance.sendMessage(text).toList();
        expect(events, hasLength(1));
        expect(events.single, isA<ChatErrorEvent>());
      }
    });
  });

  group('isActiveChatTurnTaskForSession', () {
    test('matches only active chat turn tasks for the requested session', () {
      const taskType = 'super_agent_chat_turn_task';

      expect(
        isActiveChatTurnTaskForSession(
          sessionId: 'session-a',
          taskType: taskType,
          expectedTaskType: taskType,
          status: 'pending',
          payloadJson: jsonEncode({'session_id': 'session-a'}),
        ),
        isTrue,
      );

      expect(
        isActiveChatTurnTaskForSession(
          sessionId: 'session-a',
          taskType: taskType,
          expectedTaskType: taskType,
          status: 'pending',
          payloadJson: jsonEncode({'session_id': 'session-b'}),
        ),
        isFalse,
      );

      expect(
        isActiveChatTurnTaskForSession(
          sessionId: 'session-a',
          taskType: taskType,
          expectedTaskType: taskType,
          status: 'completed',
          payloadJson: jsonEncode({'session_id': 'session-a'}),
        ),
        isFalse,
      );

      expect(
        isActiveChatTurnTaskForSession(
          sessionId: 'session-a',
          taskType: 'other_task',
          expectedTaskType: taskType,
          status: 'processing',
          payloadJson: jsonEncode({'session_id': 'session-a'}),
        ),
        isFalse,
      );
    });
  });

  group('Super Agent chat turn resume guard', () {
    test('keeps the running turn id while the agent can still resume', () {
      final source =
          File('lib/data/services/chat_service.dart').readAsStringSync();
      final cleanupBlock = RegExp(
        r'if \(!activeAgent\.state\.isRunning &&\s*'
        r'activeAgent\.state\.metadata\[_runningChatTurnIdKey\] == turnId\) \{\s*'
        r'activeAgent\.state\.metadata\.remove\(_runningChatTurnIdKey\);',
        multiLine: true,
      );

      expect(cleanupBlock.hasMatch(source), isTrue);
    });
  });

  group('Super Agent state refresh', () {
    const userId = 'chat-state-refresh-user';
    const sessionId = 'memex_agent_state_refresh_session';
    late Directory tempDir;
    late AppDatabase db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      await UserStorage.saveUser(userId);
      tempDir = await Directory.systemTemp.createTemp(
        'memex_chat_state_refresh_test_',
      );
      await FileSystemService.init(tempDir.path);
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
    });

    tearDown(() async {
      await LocalAssetServer.stopServer();
      await db.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
        'creates a new agent state while preserving chat history and old state',
        () async {
      await _writeSession(
        userId: userId,
        sessionId: sessionId,
        data: _sessionData(messages: [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'hello'},
            ],
          },
        ], extra: {
          'total_usage': {
            'prompt_tokens': 100,
            'completion_tokens': 20,
            'cached_tokens': 10,
            'total_tokens': 120,
            'total_cost': 0.01,
          },
        }),
      );
      final oldState = await loadOrCreateAgentState(sessionId, {
        'userId': userId,
        'chat_session_id': sessionId,
      });
      await saveAgentState(oldState);

      final newStateId =
          await ChatService.instance.refreshAgentStateForSession(sessionId);
      final sessionData = await _readSession(userId, sessionId);
      final stateDir =
          await FileSystemService.instance.getAgentStateDirectory(userId);

      expect(newStateId, isNot(sessionId));
      expect(newStateId, startsWith('${sessionId}_state_'));
      expect(sessionData['active_agent_state_session_id'], newStateId);
      expect(sessionData.containsKey('total_usage'), isFalse);
      expect(sessionData['messages'], hasLength(1));
      expect(
        await File(ChatSessionStorage.instance.legacyYamlPath(
          userId,
          sessionId,
        )).exists(),
        isFalse,
      );
      expect(
        await File(ChatSessionStorage.instance.messagesPath(
          userId,
          sessionId,
        )).exists(),
        isTrue,
      );
      expect(await File(p.join(stateDir, '$sessionId.json')).exists(), isTrue);
      expect(await File(p.join(stateDir, '$newStateId.json')).exists(), isTrue);

      final newState = await loadOrCreateAgentState(newStateId, {
        'userId': userId,
      });
      expect(newState.metadata['chat_session_id'], sessionId);
      expect(newState.history.messages, isEmpty);
    });

    test('refuses to refresh while the session has an active queued turn',
        () async {
      await _writeSession(
        userId: userId,
        sessionId: sessionId,
        data: _sessionData(),
      );
      await db.into(db.tasks).insert(
            TasksCompanion.insert(
              id: 'queued-chat-turn',
              type: 'super_agent_chat_turn_task',
              payload: Value(jsonEncode({'session_id': sessionId})),
              status: 'pending',
              createdAt: const Value(1700000000),
            ),
          );

      await expectLater(
        ChatService.instance.refreshAgentStateForSession(sessionId),
        throwsA(isA<StateError>()),
      );

      final sessionData = await _readSession(userId, sessionId);
      expect(sessionData.containsKey('active_agent_state_session_id'), isFalse);
    });

    test('migrates legacy artifacts when loading a session', () async {
      await _writeSession(
        userId: userId,
        sessionId: sessionId,
        data: _sessionData(messages: [
          {
            'role': 'ai',
            'turn_id': 'turn-legacy',
            'timestamp': '2026-06-22T12:01:00.000Z',
            'content': [
              {'type': 'text', 'text': 'done'},
            ],
            'artifacts': [
              {
                'type': 'card',
                'id': '2026/06/22.md#ts_1',
                'title': 'Legacy card',
                'snippet': 'legacy summary',
                'updated': true,
              },
            ],
          },
        ]),
      );

      await ChatService.instance.refreshAgentStateForSession(sessionId);

      final sessionData = await _readSession(userId, sessionId);
      expect(
        sessionData[ChatArtifactSessionMigration.schemaVersionKey],
        ChatArtifact.schemaVersion,
      );

      final messages = sessionData['messages'] as List<dynamic>;
      final artifacts =
          (messages.single as Map<String, dynamic>)['artifacts'] as List;
      final artifactMap = Map<String, dynamic>.from(artifacts.single as Map);

      expect(artifactMap.containsKey('type'), isFalse);
      final artifact = ChatArtifact.fromJson(artifactMap)!;
      expect(artifact.kind, ChatArtifact.kindTimelineCard);
      expect(artifact.timelineCardId, '2026/06/22.md#ts_1');
      expect(artifact.sourceRunId, 'turn-legacy');
    });

    test('freezes the active agent state id into queued chat turn payload',
        () async {
      const queuedSessionId = '${sessionId}_queued';
      const activeStateId = '${queuedSessionId}_state_active';
      await _writeSession(
        userId: userId,
        sessionId: queuedSessionId,
        data: _sessionData(
          sessionId: queuedSessionId,
          extra: {'active_agent_state_session_id': activeStateId},
        ),
      );

      final events = <ChatEvent>[];
      final attached = Completer<ChatRunAttachedEvent>();
      final subscription = ChatService.instance
          .sendMessage(
            'next turn',
            requestId: 'request-with-frozen-state',
            sessionId: queuedSessionId,
            agentName: 'memex_agent',
            scene: 'super_agent_home',
          )
          .listen((event) {
        events.add(event);
        if (event is ChatRunAttachedEvent && !attached.isCompleted) {
          attached.complete(event);
        }
      });
      try {
        final task = await _waitForQueuedChatTask(db, queuedSessionId);
        final payload = jsonDecode(task.payload!) as Map<String, dynamic>;
        final foregroundSnapshot =
            await AgentForegroundTaskTracker.forTesting(db: db).getSnapshot();

        final attachment = await attached.future.timeout(const Duration(seconds: 5));
        expect(events.first, isA<ChatTurnPreparingEvent>());
        final queued = events.whereType<ChatTurnQueuedEvent>().first;
        expect(queued.runId, attachment.runId);
        expect(queued.turnId, 'request-with-frozen-state');
        expect(events.whereType<ChatAgentStartedEvent>(), isEmpty);
        expect(payload['turn_id'], queued.turnId);
        expect(events.indexOf(queued), lessThan(events.indexOf(attachment)));

        // A second submission announces the same run explicitly, allowing the
        // UI to deduplicate without guessing whether a listener exists.
        final second = await ChatService.instance.sendMessage(
          'follow up', sessionId: queuedSessionId, requestId: 'follow-up',
        ).take(4).toList();
        expect(second.first, isA<ChatTurnPreparingEvent>());
        expect(second.whereType<ChatRunAttachedEvent>().single.runId, attachment.runId);
        expect(second.whereType<ChatTurnQueuedEvent>().single.runId, attachment.runId);
        expect(payload['session_id'], queuedSessionId);
        expect(payload['agent_state_session_id'], activeStateId);
        expect(foregroundSnapshot.activeTaskIds, contains(task.id));
      } finally {
        await subscription.cancel();
      }
    });

    test('queues a later Super Agent turn behind the previous terminal state',
        () async {
      const queuedSessionId = '${sessionId}_ordered';
      await _writeSession(
        userId: userId,
        sessionId: queuedSessionId,
        data: _sessionData(sessionId: queuedSessionId),
      );
      await db.into(db.tasks).insert(
            TasksCompanion.insert(
              id: 'failed-super-agent-turn',
              type: 'super_agent_chat_turn_task',
              payload: Value(jsonEncode({
                'session_id': 'another-session',
                'turn_id': 'failed-turn',
              })),
              status: 'failed',
              createdAt: const Value(1700000000),
            ),
          );

      final subscription = ChatService.instance
          .sendMessage(
            'continue after failure',
            sessionId: queuedSessionId,
            agentName: 'memex_agent',
            scene: 'super_agent_home',
          )
          .listen((_) {});
      try {
        final task = await _waitForQueuedChatTask(db, queuedSessionId);
        final dependencies = jsonDecode(task.dependencies!) as List<dynamic>;

        expect(dependencies, [
          {
            'task_id': 'failed-super-agent-turn',
            'condition': 'wait_for_completion',
          },
        ]);
      } finally {
        await subscription.cancel();
      }
    });

    test('replaces a missing session id and persists the new turn', () async {
      const missingSessionId = 'memex_agent_missing_session';
      final createdSession = Completer<String>();
      final subscription = ChatService.instance
          .sendMessage(
        'recover this turn',
        sessionId: missingSessionId,
        agentName: 'memex_agent',
        scene: 'super_agent_home',
      )
          .listen((event) {
        if (event is ChatSessionCreatedEvent && !createdSession.isCompleted) {
          createdSession.complete(event.sessionId);
        }
      });

      try {
        final newSessionId = await createdSession.future.timeout(
          const Duration(seconds: 3),
        );
        expect(newSessionId, isNot(missingSessionId));

        await _waitForQueuedChatTask(db, newSessionId);
        final sessionData = await _readSession(userId, newSessionId);
        final messages = sessionData['messages'] as List<dynamic>;

        expect(messages, hasLength(1));
        expect(messages.single['role'], 'user');
        expect(
          messages.single['content'].single['text'],
          'recover this turn',
        );
      } finally {
        await subscription.cancel();
      }
    });
  });
}

Map<String, dynamic> _sessionData(
    {String sessionId = 'memex_agent_state_refresh_session',
    List<Map<String, dynamic>> messages = const [],
    Map<String, dynamic> extra = const {}}) {
  return {
    'session_id': sessionId,
    'agent_name': 'memex_agent',
    'scene': 'super_agent_home',
    'title': 'State refresh session',
    'created_at': '2026-06-22T12:00:00.000',
    'updated_at': '2026-06-22T12:00:00.000',
    'messages': messages,
    ...extra,
  };
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

Future<Map<String, dynamic>> _readSession(
    String userId, String sessionId) async {
  return ChatSessionStorage.instance.loadSessionData(userId, sessionId);
}

Future<Task> _waitForQueuedChatTask(AppDatabase db, String sessionId) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (DateTime.now().isBefore(deadline)) {
    final tasks = await db.select(db.tasks).get();
    for (final task in tasks) {
      final payload = jsonDecode(task.payload ?? '{}') as Map<String, dynamic>;
      if (task.type == 'super_agent_chat_turn_task' &&
          payload['session_id'] == sessionId) {
        return task;
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  throw StateError('Timed out waiting for queued chat task');
}
