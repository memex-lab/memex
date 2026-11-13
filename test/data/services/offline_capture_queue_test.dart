import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:memex/agent/super_agent/super_agent_pre_minted_record_hook.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/network_reachability.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase db;
  late LocalTaskExecutor executor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    await UserStorage.saveUser('offline-capture-user');
    tempDir = await Directory.systemTemp.createTemp('memex_offline_capture_');
    await FileSystemService.init(tempDir.path);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    executor = LocalTaskExecutor.forTesting(db: db);
    executor.reachabilityCheck = () async => false;
    executor.reachabilityProbeInterval = Duration.zero;
    chatNetworkReachabilityCheck = () async => false;
  });

  tearDown(() async {
    chatNetworkReachabilityCheck = null;
    await executor.stop();
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('sendMessage parks the turn and shows the network message', () async {
    final events = await ChatService.instance
        .sendMessage(
          'garage note',
          sessionId: '',
          agentName: 'memex_agent',
          scene: 'super_agent_home',
        )
        .toList();

    expect(
      events.whereType<ChatErrorEvent>().single.error,
      UserStorage.l10n.llmNetworkError,
    );
    expect(
      events.whereType<ChatErrorEvent>().single.error,
      isNot(contains('AgentException')),
    );

    final tasks = await db.select(db.tasks).get();
    expect(tasks, hasLength(1));
    expect(tasks.single.status, waitingNetworkTaskStatus);
    expect(tasks.single.type, 'super_agent_chat_turn_task');

    final factId = _payloadFactId(tasks.single.payload);
    expect(factId, isNotNull);
    final card = await FileSystemService.instance.readCardFile(
      'offline-capture-user',
      factId!,
    );
    expect(card?.status, 'processing');
    expect((card?.fact ?? '').trim(), isEmpty);
    final content =
        card?.uiConfigs.single.data['content']?.toString().trim() ?? '';
    expect(content, isEmpty);
    expect(isUnusedPreallocatedRecordPlaceholder(card, factId), isTrue);
  });

  test('a local endpoint is not parked when public DNS fails', () async {
    await UserStorage.saveLLMConfigs(const [
      LLMConfig(
        key: LLMConfig.defaultClientKey,
        type: LLMConfig.typeOllama,
        modelId: 'llama3.2',
        apiKey: '',
        baseUrl: 'http://127.0.0.1:11434/v1',
      ),
    ]);
    await UserStorage.setDefaultLLMConfigKey(LLMConfig.defaultClientKey);

    final subscription = ChatService.instance
        .sendMessage(
          'is the garage light on',
          sessionId: '',
          agentName: 'memex_agent',
          scene: 'super_agent_home',
        )
        .listen((_) {});
    addTearDown(subscription.cancel);

    final tasks = await _waitForTaskCount(db, 1);
    expect(tasks.single.status, 'pending');
    expect(_payloadFactId(tasks.single.payload), isNull);
    final cardsRoot = Directory(
      FileSystemService.instance.getCardsPath('offline-capture-user'),
    );
    if (await cardsRoot.exists()) {
      final cardFiles = await cardsRoot
          .list(recursive: true)
          .where((entity) => entity is File)
          .toList();
      expect(cardFiles, isEmpty);
    }
  });

  test(
    'connection refused ends failed instead of waiting for network',
    () async {
      executor.registerHandler('super_agent_chat_turn_task', (
        _,
        __,
        ___,
      ) async {
        throw const SocketException('Connection refused');
      });

      await executor.enqueueTask(
        userId: 'offline-capture-user',
        taskType: 'super_agent_chat_turn_task',
        payload: {'turn_id': 'turn-refused'},
        maxRetries: 0,
      );
      await executor.start(
        userId: 'offline-capture-user',
        recoverStaleTasks: false,
      );

      final failed = await _waitForStatus(db, 'failed');
      expect(failed.status, 'failed');
      expect(failed.retryCount, 0);
    },
  );

  test('a host lookup failure waits, then runs when the network returns',
      () async {
    var runs = 0;
    executor.registerHandler('super_agent_chat_turn_task', (_, __, ___) async {
      runs += 1;
      if (runs == 1) {
        throw const SocketException(
          "Failed host lookup: 'api.anthropic.com'",
        );
      }
    });

    await executor.enqueueTask(
      userId: 'offline-capture-user',
      taskType: 'super_agent_chat_turn_task',
      payload: {
        'turn_id': 'turn-1',
        'pre_minted_fact_id': '2026/11/08.md#ts_1',
      },
    );
    await executor.start(
      userId: 'offline-capture-user',
      recoverStaleTasks: false,
    );

    final parked = await _waitForStatus(db, waitingNetworkTaskStatus);
    expect(parked.retryCount, 0);
    expect(runs, 1);

    executor.reachabilityCheck = () async => true;
    final completed = await _waitForStatus(db, 'completed');
    expect(completed.status, 'completed');
    expect(runs, 2);
  });

  test('private endpoints and offline errors are classified apart', () {
    expect(isPrivateModelEndpoint('http://127.0.0.1:11434/v1'), isTrue);
    expect(isPrivateModelEndpoint('http://localhost:11434/v1'), isTrue);
    expect(isPrivateModelEndpoint('http://[::1]:11434'), isTrue);
    expect(isPrivateModelEndpoint('http://ollama.local:11434'), isTrue);
    expect(isPrivateModelEndpoint('http://10.1.2.3:11434'), isTrue);
    expect(isPrivateModelEndpoint('http://192.168.1.20:11434/v1'), isTrue);
    expect(isPrivateModelEndpoint('http://172.16.0.1:11434'), isTrue);
    expect(isPrivateModelEndpoint('http://172.31.255.255:11434'), isTrue);
    expect(isPrivateModelEndpoint('http://172.15.255.255:11434'), isFalse);
    expect(isPrivateModelEndpoint('http://172.32.0.1:11434'), isFalse);
    expect(isPrivateModelEndpoint('https://api.openai.com/v1'), isFalse);

    expect(
      looksLikeNetworkError(
        const SocketException("Failed host lookup: 'api.anthropic.com'"),
      ),
      isTrue,
    );
    expect(
      looksLikeNetworkError(const SocketException('Connection refused')),
      isFalse,
    );
    expect(
      looksLikeNetworkError(const SocketException('Connection reset by peer')),
      isFalse,
    );
    expect(
      looksLikeNetworkError(ClientException('Connection refused')),
      isFalse,
    );
    expect(
      looksLikeNetworkError(
        ClientException("Failed host lookup: 'api.anthropic.com'"),
      ),
      isTrue,
    );
  });
}

String? _payloadFactId(String? payload) {
  if (payload == null) return null;
  final decoded = payload;
  final match = RegExp(
    r'"pre_minted_fact_id"\s*:\s*"([^"]+)"',
  ).firstMatch(decoded);
  return match?.group(1);
}

Future<List<Task>> _waitForTaskCount(AppDatabase db, int count) async {
  final deadline = DateTime.now().add(const Duration(seconds: 4));
  while (DateTime.now().isBefore(deadline)) {
    final tasks = await db.select(db.tasks).get();
    if (tasks.length >= count) return tasks;
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }
  final tasks = await db.select(db.tasks).get();
  fail('Timed out waiting for $count tasks, saw ${tasks.length}');
}

Future<Task> _waitForStatus(AppDatabase db, String status) async {
  final deadline = DateTime.now().add(const Duration(seconds: 4));
  while (DateTime.now().isBefore(deadline)) {
    final tasks = await db.select(db.tasks).get();
    for (final task in tasks) {
      if (task.status == status) return task;
    }
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }
  final tasks = await db.select(db.tasks).get();
  fail('Timed out waiting for $status, saw ${tasks.map((t) => t.status)}');
}
