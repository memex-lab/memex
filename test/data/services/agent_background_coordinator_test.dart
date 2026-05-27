import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/agent_background_coordinator.dart';
import 'package:memex/data/services/agent_background_platform.dart';
import 'package:memex/data/services/agent_background_status.dart';
import 'package:memex/data/services/agent_queue_drain_scheduler.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';

void main() {
  late AppDatabase db;
  late LocalTaskExecutor executor;
  late _FakeActivityService activityService;
  late _FakePlatform platform;
  late _FakeScheduler scheduler;
  late AgentBackgroundCoordinator coordinator;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    executor = LocalTaskExecutor.forTesting();
    activityService = _FakeActivityService();
    platform = _FakePlatform();
    scheduler = _FakeScheduler();
    coordinator = AgentBackgroundCoordinator(
      platform: platform,
      scheduler: scheduler,
    );
  });

  tearDown(() async {
    await coordinator.stop();
    await activityService.dispose();
    executor.stop();
    await db.close();
  });

  test('publishes active status and schedules one drain for a run', () async {
    coordinator.start(executor: executor, activityService: activityService);

    await _insertTask(db, id: 'pending-a', status: 'pending');
    await _waitUntil(() => platform.updates.isNotEmpty);

    expect(platform.updates.single.state, AgentBackgroundRunState.active);
    expect(platform.updates.single.remainingTasks, 1);
    expect(scheduler.scheduleCount, 1);

    activityService.emit(
      AgentActivityMessageModel(
        id: 1,
        type: AgentActivityType.info,
        title: 'Updating PKM',
        content: 'Writing local notes',
        agentName: 'PKM Agent',
        agentId: 'pkm',
        timestamp: DateTime(2026, 1, 1),
      ),
    );
    await _waitUntil(() => platform.updates.length == 2);

    expect(platform.updates.last.stage, 'Updating PKM');
    expect(platform.updates.last.detail, 'Writing local notes');
    expect(scheduler.scheduleCount, 1);
  });

  test(
    'finishes terminal status and cancels drain when queue empties',
    () async {
      coordinator.start(executor: executor, activityService: activityService);
      await _insertTask(db, id: 'pending-a', status: 'pending');
      await _waitUntil(() => platform.updates.isNotEmpty);

      activityService.emit(
        AgentActivityMessageModel(
          id: 2,
          type: AgentActivityType.agent_stop,
          title: 'Done',
          agentName: 'Card Agent',
          agentId: 'card',
          timestamp: DateTime(2026, 1, 1),
        ),
      );
      await (db.update(db.tasks)..where((t) => t.id.equals('pending-a'))).write(
        TasksCompanion(
          status: const Value('completed'),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        ),
      );

      await _waitUntil(() => platform.finished.isNotEmpty);

      expect(platform.finished.last.state, AgentBackgroundRunState.completed);
      expect(scheduler.cancelCount, greaterThanOrEqualTo(1));
    },
  );

  test('forwards notification tap requests to listeners', () async {
    final opened = Completer<void>();
    coordinator.openActivityRequests.listen((_) {
      if (!opened.isCompleted) opened.complete();
    });
    coordinator.start(executor: executor, activityService: activityService);

    platform.emitAction('agent_activity');

    await opened.future.timeout(const Duration(seconds: 1));
  });

  test('buffers initial notification tap until a listener attaches', () async {
    platform.initialAction = 'agent_activity';
    coordinator.start(executor: executor, activityService: activityService);

    await platform.initialActionConsumed.future.timeout(
      const Duration(seconds: 1),
    );

    final opened = Completer<void>();
    coordinator.openActivityRequests.listen((_) {
      if (!opened.isCompleted) opened.complete();
    });

    await opened.future.timeout(const Duration(seconds: 1));
  });

  test(
    'keeps system surface active when an error message arrives with retryable tasks',
    () async {
      coordinator.start(executor: executor, activityService: activityService);
      await _insertTask(db, id: 'retry-a', status: 'retrying');
      await _waitUntil(() => platform.updates.isNotEmpty);
      final cancelCountBeforeError = scheduler.cancelCount;

      activityService.emit(
        AgentActivityMessageModel(
          id: 3,
          type: AgentActivityType.error,
          title: 'Provider timeout',
          content: 'Will retry automatically',
          agentName: 'Insight Agent',
          agentId: 'insight',
          timestamp: DateTime(2026, 1, 1),
        ),
      );
      await _waitUntil(() => platform.updates.length == 2);

      expect(platform.updates.last.state, AgentBackgroundRunState.active);
      expect(platform.updates.last.detail, 'Will retry automatically');
      expect(platform.finished, isEmpty);
      expect(scheduler.cancelCount, cancelCountBeforeError);
    },
  );

  test('retries publishing after platform update failure', () async {
    coordinator.start(executor: executor, activityService: activityService);
    platform.failNextUpdate = true;

    await _insertTask(db, id: 'pending-a', status: 'pending');
    await _waitUntil(() => platform.updateAttempts == 1);

    expect(platform.updates, isEmpty);
    expect(scheduler.scheduleCount, 0);

    activityService.emit(
      AgentActivityMessageModel(
        id: 4,
        type: AgentActivityType.info,
        title: 'Retrying visible status',
        content: 'The platform recovered',
        agentName: 'Card Agent',
        agentId: 'card',
        timestamp: DateTime(2026, 1, 1),
      ),
    );
    await _waitUntil(() => platform.updates.isNotEmpty);

    expect(platform.updateAttempts, 2);
    expect(platform.updates.single.detail, 'The platform recovered');
    expect(scheduler.scheduleCount, 1);
  });
}

class _FakePlatform implements AgentBackgroundPlatform {
  final updates = <AgentBackgroundStatus>[];
  final finished = <AgentBackgroundStatus>[];
  final initialActionConsumed = Completer<void>();
  var stopCount = 0;
  var updateAttempts = 0;
  var failNextUpdate = false;
  String? initialAction;
  final _actions = StreamController<String>.broadcast();

  @override
  Stream<String> get actionStream => _actions.stream;

  @override
  Future<String?> consumeInitialAction() async {
    if (!initialActionConsumed.isCompleted) {
      initialActionConsumed.complete();
    }
    return initialAction;
  }

  @override
  Future<void> finishStatus(AgentBackgroundStatus status) async {
    finished.add(status);
  }

  @override
  Future<void> stopStatus() async {
    stopCount++;
  }

  @override
  Future<void> updateStatus(AgentBackgroundStatus status) async {
    updateAttempts++;
    if (failNextUpdate) {
      failNextUpdate = false;
      throw StateError('platform unavailable');
    }
    updates.add(status);
  }

  void emitAction(String action) => _actions.add(action);
}

class _FakeScheduler implements AgentQueueDrainScheduler {
  var scheduleCount = 0;
  var cancelCount = 0;

  @override
  Future<void> cancel() async {
    cancelCount++;
  }

  @override
  Future<void> schedule({
    Duration? initialDelay,
    bool expedited = false,
  }) async {
    scheduleCount++;
  }
}

class _FakeActivityService implements AgentActivityService {
  final _messages = StreamController<AgentActivityMessageModel>.broadcast();

  @override
  Stream<AgentActivityMessageModel> get messageStream => _messages.stream;

  void emit(AgentActivityMessageModel message) => _messages.add(message);

  Future<void> dispose() => _messages.close();

  @override
  Future<List<AgentActivityMessageModel>> getHistory({int limit = 10}) async {
    return const [];
  }

  @override
  Future<void> pushMessage({
    required AgentActivityType type,
    required String title,
    String? content,
    String? icon,
    required String agentName,
    required String agentId,
    String? scene,
    String? sceneId,
    String? userId,
  }) async {}
}

Future<void> _insertTask(
  AppDatabase db, {
  required String id,
  required String status,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.into(db.tasks).insert(
        TasksCompanion.insert(
          id: id,
          type: 'test_task',
          payload: const Value('{}'),
          status: status,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
}

Future<void> _waitUntil(
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}
