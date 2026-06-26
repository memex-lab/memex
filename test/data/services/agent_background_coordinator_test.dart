import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/agent_background_coordinator.dart';
import 'package:memex/data/services/agent_background_platform.dart';
import 'package:memex/data/services/agent_background_status.dart';
import 'package:memex/data/services/agent_foreground_task_tracker.dart';
import 'package:memex/data/services/agent_queue_drain_scheduler.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LocalTaskExecutor executor;
  late _FakeActivityService activityService;
  late _FakePlatform platform;
  late _FakeScheduler scheduler;
  late AgentForegroundTaskTracker tracker;
  late AgentBackgroundCoordinator coordinator;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    executor = LocalTaskExecutor.forTesting();
    activityService = _FakeActivityService();
    platform = _FakePlatform();
    scheduler = _FakeScheduler();
    tracker = AgentForegroundTaskTracker.forTesting(db: db);
    coordinator = AgentBackgroundCoordinator(
      platform: platform,
      scheduler: scheduler,
      tracker: tracker,
      initialLifecycleState: AppLifecycleState.paused,
    );
  });

  tearDown(() async {
    await coordinator.stop();
    await activityService.dispose();
    await executor.stop();
    await db.close();
  });

  test('publishes active status and schedules one drain for a run', () async {
    coordinator.start(executor: executor, activityService: activityService);

    await _insertTrackedTask(db, tracker, id: 'pending-a', status: 'pending');
    await _waitUntil(() => platform.updates.isNotEmpty);

    expect(platform.updates.single.state, AgentBackgroundRunState.active);
    expect(platform.updates.single.remainingTasks, 1);
    expect(platform.updateBackgroundFlags.single, isTrue);
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
    expect(platform.updates.last.summary, 'Writing local notes');
    expect(platform.updates.last.summary, isNot(contains('Updating PKM')));
    expect(scheduler.scheduleCount, 1);
  });

  test(
    'schedules drain from local tasks even when foreground tracker is empty',
    () async {
      coordinator.start(executor: executor, activityService: activityService);

      await _insertTask(db, id: 'untracked-task', status: 'pending');
      await _waitUntil(() => scheduler.scheduleCount == 1);

      expect(platform.updates, isEmpty);
      expect(platform.finished, isEmpty);
      expect(platform.stopCount, greaterThanOrEqualTo(1));
      expect(scheduler.events.last, 'schedule:true:0');
    },
  );

  test('defers WorkManager drain while app is foregrounded', () async {
    coordinator = AgentBackgroundCoordinator(
      platform: platform,
      scheduler: scheduler,
      tracker: tracker,
      initialLifecycleState: AppLifecycleState.resumed,
    );
    coordinator.start(executor: executor, activityService: activityService);

    await _insertTrackedTask(db, tracker, id: 'pending-a', status: 'pending');
    await _waitUntil(() => platform.updates.isNotEmpty);

    expect(platform.updates.single.state, AgentBackgroundRunState.active);
    expect(platform.updateBackgroundFlags.single, isFalse);
    expect(scheduler.scheduleCount, 0);

    coordinator.didChangeAppLifecycleState(AppLifecycleState.paused);
    await _waitUntil(() => scheduler.scheduleCount == 1);
    await _waitUntil(() => platform.updates.length == 2);

    expect(platform.updateBackgroundFlags.last, isTrue);
    expect(scheduler.events.last, 'schedule:true:0');
  });

  test(
    'clears completed status and cancels drain when queue empties',
    () async {
      coordinator.start(executor: executor, activityService: activityService);
      await _insertTrackedTask(db, tracker, id: 'pending-a', status: 'pending');
      await _waitUntil(() => platform.updates.isNotEmpty);
      final stopCountBeforeCompletion = platform.stopCount;

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

      await _waitUntil(() => platform.stopCount > stopCountBeforeCompletion);

      expect(platform.finished, isEmpty);
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
    'keeps system surface active when error arrives with retryable tasks',
    () async {
      coordinator.start(executor: executor, activityService: activityService);
      await _insertTrackedTask(db, tracker, id: 'retry-a', status: 'retrying');
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
      expect(platform.updates.last.summary, 'Will retry automatically');
      expect(platform.finished, isEmpty);
      expect(scheduler.cancelCount, cancelCountBeforeError);
    },
  );

  test('retries publishing after platform update failure', () async {
    coordinator.start(executor: executor, activityService: activityService);
    platform.failNextUpdate = true;

    await _insertTrackedTask(db, tracker, id: 'pending-a', status: 'pending');
    await _waitUntil(() => platform.updateAttempts == 1);

    expect(platform.updates, isEmpty);
    expect(scheduler.scheduleCount, 1);

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
    expect(scheduler.scheduleCount, greaterThanOrEqualTo(1));
  });

  test('serializes delayed active publish before terminal publish', () async {
    platform.updateGate = Completer<void>();
    coordinator.start(executor: executor, activityService: activityService);

    await _insertTrackedTask(db, tracker, id: 'pending-a', status: 'pending');
    await _waitUntil(() => platform.updateAttempts == 1);
    final stopCountBeforeTerminal = platform.stopCount;
    platform.events.clear();
    scheduler.events.clear();

    activityService.emit(
      AgentActivityMessageModel(
        id: 5,
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

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(platform.finished, isEmpty);
    expect(platform.stopCount, stopCountBeforeTerminal);

    platform.updateGate!.complete();
    await _waitUntil(() => platform.stopCount > stopCountBeforeTerminal);

    expect(platform.events, ['update:active:bg=true', 'stop']);
    expect(scheduler.events, ['cancel']);
  });

  test(
    'normal app launch keeps tracked task progress visible in foreground',
    () async {
      coordinator = AgentBackgroundCoordinator(
        platform: platform,
        scheduler: scheduler,
        tracker: tracker,
        initialLifecycleState: AppLifecycleState.resumed,
      );
      await _insertTask(
        db,
        id: 'turn',
        status: 'processing',
        type: 'super_agent_chat_turn_task',
      );
      await tracker.trackTask('turn');

      coordinator.start(executor: executor, activityService: activityService);

      await _waitUntil(() => platform.updates.isNotEmpty);
      expect(platform.updates.last.state, AgentBackgroundRunState.active);
      expect(platform.updates.last.remainingTasks, 1);
      expect(platform.updateBackgroundFlags.last, isFalse);
      expect(scheduler.scheduleCount, 0);
    },
  );

  test(
    'paused tracked work remains visible and keeps drain scheduled',
    () async {
      await _insertTask(db, id: 'paused-task', status: 'pending');
      await tracker.trackTask('paused-task');
      await tracker.markPaused(
        message: 'Background time expired. Memex will continue later.',
      );

      coordinator.start(executor: executor, activityService: activityService);

      await _waitUntil(() => platform.updates.isNotEmpty);
      expect(platform.updates.last.state, AgentBackgroundRunState.paused);
      expect(platform.updates.last.detail, contains('continue later'));
      expect(platform.updateBackgroundFlags.last, isTrue);
      expect(scheduler.scheduleCount, 1);
    },
  );
}

class _FakePlatform implements AgentBackgroundPlatform {
  final updates = <AgentBackgroundStatus>[];
  final updateBackgroundFlags = <bool>[];
  final finished = <AgentBackgroundStatus>[];
  final finishBackgroundFlags = <bool>[];
  final events = <String>[];
  final initialActionConsumed = Completer<void>();
  var stopCount = 0;
  var updateAttempts = 0;
  var failNextUpdate = false;
  Completer<void>? updateGate;
  String? initialAction;
  final _actions = StreamController<String>.broadcast();

  @override
  bool get isSupported => true;

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
  Future<void> finishStatus(
    AgentBackgroundStatus status, {
    bool isInBackground = false,
  }) async {
    events.add('finish:${status.state.name}:bg=$isInBackground');
    finished.add(status);
    finishBackgroundFlags.add(isInBackground);
  }

  @override
  Future<void> stopStatus() async {
    events.add('stop');
    stopCount++;
  }

  @override
  Future<void> updateStatus(
    AgentBackgroundStatus status, {
    bool isInBackground = false,
  }) async {
    updateAttempts++;
    await updateGate?.future;
    if (failNextUpdate) {
      failNextUpdate = false;
      throw StateError('platform temporarily unavailable');
    }
    events.add('update:${status.state.name}:bg=$isInBackground');
    updates.add(status);
    updateBackgroundFlags.add(isInBackground);
  }

  void emitAction(String action) {
    _actions.add(action);
  }
}

class _FakeScheduler implements AgentQueueDrainScheduler {
  final events = <String>[];
  var scheduleCount = 0;
  var cancelCount = 0;

  @override
  Future<void> cancel() async {
    cancelCount++;
    events.add('cancel');
  }

  @override
  Future<void> schedule({
    Duration? initialDelay,
    bool expedited = false,
  }) async {
    scheduleCount++;
    events.add('schedule:$expedited:${initialDelay?.inMilliseconds ?? 0}');
  }
}

class _FakeActivityService implements AgentActivityService {
  final _messages = StreamController<AgentActivityMessageModel>.broadcast();
  final history = <AgentActivityMessageModel>[];

  @override
  Stream<AgentActivityMessageModel> get messageStream => _messages.stream;

  @override
  Future<List<AgentActivityMessageModel>> getHistory({int limit = 10}) async {
    return history.take(limit).toList();
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
  }) async {
    emit(
      AgentActivityMessageModel(
        id: history.length + 1,
        type: type,
        title: title,
        content: content,
        icon: icon,
        agentName: agentName,
        agentId: agentId,
        scene: scene,
        sceneId: sceneId,
        userId: userId,
        timestamp: DateTime(2026, 1, 1),
      ),
    );
  }

  void emit(AgentActivityMessageModel message) {
    history.insert(0, message);
    _messages.add(message);
  }

  Future<void> dispose() => _messages.close();
}

Future<void> _insertTask(
  AppDatabase db, {
  required String id,
  required String status,
  String type = 'agent_task',
  String? runId,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.into(db.tasks).insert(
        TasksCompanion.insert(
          id: id,
          type: type,
          payload: const Value('{}'),
          runId: Value(runId),
          status: status,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
}

Future<void> _insertTrackedTask(
  AppDatabase db,
  AgentForegroundTaskTracker tracker, {
  required String id,
  required String status,
  String type = 'agent_task',
}) async {
  await _insertTask(db, id: id, status: status, type: type);
  await tracker.trackTask(id);
}

Future<void> _waitUntil(
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition was not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}
