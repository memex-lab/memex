import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';

void main() {
  group('Super Agent chat turn rescheduling', () {
    late AppDatabase db;
    late LocalTaskExecutor executor;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      executor = LocalTaskExecutor.forTesting();
    });

    tearDown(() async {
      await executor.stop();
      await db.close();
    });

    test('normal processing persists one user message', () async {
      final state = AgentState(sessionId: 'normal');
      final client = _FinalTextClient();
      final harness = _ChatTurnHarness(state: state, clients: [client]);

      executor.registerHandler(
        _chatTaskType,
        (_, payload, __) => harness.handle(payload),
      );
      await _insertTask(db, id: 'normal-task', status: 'pending');

      await executor.drainAvailableTasks(
        userId: 'user-a',
        maxDuration: const Duration(seconds: 3),
        stopWhenDone: true,
      );

      expect((await _getTask(db, 'normal-task')).status, 'completed');
      expect(_userMessageCount(state), 1);
      expect(state.isRunning, isFalse);
      expect(state.metadata.containsKey(_runningTurnIdKey), isFalse);
      expect(client.requestUserCounts, [1]);
    });

    test('processing task reset to pending resumes without duplicating user',
        () async {
      final state = _runningStateAfterToolCommit(
        sessionId: 'processing-reset',
        turnId: _turnId,
      );
      final client = _FinalTextClient();
      final harness = _ChatTurnHarness(state: state, clients: [client]);

      executor.registerHandler(
        _chatTaskType,
        (_, payload, __) => harness.handle(payload),
      );
      await _insertTask(db, id: 'processing-task', status: 'processing');

      await executor.drainAvailableTasks(
        userId: 'user-a',
        maxDuration: const Duration(seconds: 3),
        stopWhenDone: true,
        minimumStaleTaskAge: Duration.zero,
      );

      expect((await _getTask(db, 'processing-task')).status, 'completed');
      expect(_userMessageCount(state), 1);
      expect(state.isRunning, isFalse);
      expect(state.metadata.containsKey(_runningTurnIdKey), isFalse);
      expect(client.requestUserCounts, [1]);
    });

    test('retrying after partial commit resumes without duplicating user',
        () async {
      final state = AgentState(sessionId: 'retrying');
      final firstAttempt = _ToolThenThrowClient();
      final retryAttempt = _FinalTextClient();
      final harness = _ChatTurnHarness(
        state: state,
        clients: [firstAttempt, retryAttempt],
      );

      executor.registerHandler(
        _chatTaskType,
        (_, payload, __) => harness.handle(payload),
      );
      await _insertTask(db, id: 'retry-task', status: 'pending');

      await executor.drainAvailableTasks(
        userId: 'user-a',
        maxDuration: const Duration(seconds: 3),
        stopWhenDone: true,
      );

      var task = await _getTask(db, 'retry-task');
      expect(task.status, 'retrying');
      expect(_userMessageCount(state), 1);
      expect(state.isRunning, isTrue);
      expect(state.metadata[_runningTurnIdKey], _turnId);
      expect(firstAttempt.requestUserCounts, [1, 1]);

      await _makeRetryRunnable(db, 'retry-task');
      await executor.drainAvailableTasks(
        userId: 'user-a',
        maxDuration: const Duration(seconds: 3),
        stopWhenDone: true,
      );

      task = await _getTask(db, 'retry-task');
      expect(task.status, 'completed');
      expect(_userMessageCount(state), 1);
      expect(state.isRunning, isFalse);
      expect(state.metadata.containsKey(_runningTurnIdKey), isFalse);
      expect(retryAttempt.requestUserCounts, [1]);
    });

    test('retrying after first LLM failure resumes without duplicating user',
        () async {
      final state = AgentState(sessionId: 'early-failure');
      final firstAttempt = _ThrowBeforeCommitClient();
      final retryAttempt = _FinalTextClient();
      final harness = _ChatTurnHarness(
        state: state,
        clients: [firstAttempt, retryAttempt],
      );

      executor.registerHandler(
        _chatTaskType,
        (_, payload, __) => harness.handle(payload),
      );
      await _insertTask(db, id: 'early-retry-task', status: 'pending');

      await executor.drainAvailableTasks(
        userId: 'user-a',
        maxDuration: const Duration(seconds: 3),
        stopWhenDone: true,
      );

      var task = await _getTask(db, 'early-retry-task');
      expect(task.status, 'retrying');
      expect(_userMessageCount(state), 1);
      expect(state.isRunning, isTrue);
      expect(state.metadata[_runningTurnIdKey], _turnId);
      expect(firstAttempt.requestUserCounts, [1]);

      await _makeRetryRunnable(db, 'early-retry-task');
      await executor.drainAvailableTasks(
        userId: 'user-a',
        maxDuration: const Duration(seconds: 3),
        stopWhenDone: true,
      );

      task = await _getTask(db, 'early-retry-task');
      expect(task.status, 'completed');
      expect(_userMessageCount(state), 1);
      expect(state.isRunning, isFalse);
      expect(state.metadata.containsKey(_runningTurnIdKey), isFalse);
      expect(retryAttempt.requestUserCounts, [1]);
    });
  });
}

const _chatTaskType = 'test_super_agent_chat_turn';
const _turnId = 'turn-1';
const _runningTurnIdKey = 'running_chat_turn_id';
const _userText = 'remember this';

class _ChatTurnHarness {
  _ChatTurnHarness({required this.state, required List<LLMClient> clients})
      : _clients = List<LLMClient>.from(clients);

  final AgentState state;
  final List<LLMClient> _clients;

  Future<void> handle(Map<String, dynamic> payload) async {
    final client = _clients.removeAt(0);
    final turnId = payload['turn_id'] as String;
    final message = payload['message'] as String;
    final agent = _agent(state: state, client: client);

    final runningTurnId = state.metadata[_runningTurnIdKey] as String?;
    final resumeExistingRun = state.isRunning && runningTurnId == turnId;
    if (state.isRunning && !resumeExistingRun) {
      state.isRunning = false;
      state.metadata.remove(_runningTurnIdKey);
    }
    if (!resumeExistingRun) {
      state.metadata[_runningTurnIdKey] = turnId;
    }

    final future = resumeExistingRun
        ? agent.resume(useStream: false)
        : agent.run([UserMessage.text(message)], useStream: false);

    await future.whenComplete(() {
      if (!state.isRunning && state.metadata[_runningTurnIdKey] == turnId) {
        state.metadata.remove(_runningTurnIdKey);
      }
    });
  }
}

StatefulAgent _agent({
  required AgentState state,
  required LLMClient client,
}) {
  return StatefulAgent(
    name: 'test-agent',
    client: client,
    modelConfig: ModelConfig(model: 'test-model'),
    state: state,
    tools: [_noopTool()],
    systemPrompts: const [],
    withGeneralPrinciples: false,
    disableSubAgents: true,
    maxTurns: 4,
  );
}

Tool _noopTool() {
  return Tool(
    name: 'noop',
    description: 'No-op tool for retry tests.',
    parameters: const {
      'type': 'object',
      'properties': <String, dynamic>{},
    },
    executable: () => 'ok',
  );
}

AgentState _runningStateAfterToolCommit({
  required String sessionId,
  required String turnId,
}) {
  return AgentState(
    sessionId: sessionId,
    isRunning: true,
    metadata: {_runningTurnIdKey: turnId},
    history: AgentMessageHistory(messages: [
      UserMessage.text(_userText),
      ModelMessage(
        model: 'test-model',
        stopReason: 'tool_calls',
        functionCalls: [
          FunctionCall(id: 'call-1', name: 'noop', arguments: '{}'),
        ],
      ),
      FunctionExecutionResultMessage(results: [
        FunctionExecutionResult(
          id: 'call-1',
          name: 'noop',
          isError: false,
          arguments: '{}',
          content: [TextPart('ok')],
        ),
      ]),
    ]),
  );
}

class _FinalTextClient extends LLMClient {
  final requestUserCounts = <int>[];

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    requestUserCounts.add(messages.whereType<UserMessage>().length);
    return ModelMessage(
      model: modelConfig.model,
      textOutput: 'done',
      stopReason: 'stop',
    );
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    throw UnsupportedError('Streaming is not used by this test client.');
  }
}

class _ToolThenThrowClient extends LLMClient {
  final requestUserCounts = <int>[];
  var _callCount = 0;

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    requestUserCounts.add(messages.whereType<UserMessage>().length);
    _callCount++;
    if (_callCount == 1) {
      return ModelMessage(
        model: modelConfig.model,
        stopReason: 'tool_calls',
        functionCalls: [
          FunctionCall(id: 'call-1', name: 'noop', arguments: '{}'),
        ],
      );
    }
    throw Exception('synthetic post-tool failure');
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    throw UnsupportedError('Streaming is not used by this test client.');
  }
}

class _ThrowBeforeCommitClient extends LLMClient {
  final requestUserCounts = <int>[];

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    requestUserCounts.add(messages.whereType<UserMessage>().length);
    throw Exception('synthetic first-call failure');
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    throw UnsupportedError('Streaming is not used by this test client.');
  }
}

int _userMessageCount(AgentState state) {
  return state.history.messages.whereType<UserMessage>().length;
}

Future<void> _insertTask(
  AppDatabase db, {
  required String id,
  required String status,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.into(db.tasks).insert(TasksCompanion.insert(
        id: id,
        type: _chatTaskType,
        payload: Value(jsonEncode({
          'turn_id': _turnId,
          'message': _userText,
        })),
        status: status,
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
}

Future<void> _makeRetryRunnable(AppDatabase db, String taskId) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
    TasksCompanion(scheduledAt: Value(now), updatedAt: Value(now)),
  );
}

Future<Task> _getTask(AppDatabase db, String id) {
  return (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
}
