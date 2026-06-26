import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/agent_background_platform.dart';
import 'package:memex/data/services/agent_background_status.dart';
import 'package:memex/data/services/agent_foreground_task_tracker.dart';
import 'package:memex/data/services/agent_queue_background_worker.dart';
import 'package:memex/data/services/agent_queue_drain_scheduler.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AgentQueueBackgroundWorker', () {
    late AppDatabase db;
    late LocalTaskExecutor executor;
    late _FakeDrainScheduler scheduler;
    late AgentForegroundTaskTracker tracker;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'user_id': 'worker-user',
        'language': 'en',
      });
      await UserStorage.initL10n();
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      executor = LocalTaskExecutor.forTesting();
      scheduler = _FakeDrainScheduler();
      tracker = AgentForegroundTaskTracker.forTesting(db: db);
    });

    tearDown(() async {
      await executor.stop();
      await db.close();
    });

    test('recognizes both WorkManager task name and unique work name', () {
      expect(
        AgentQueueBackgroundWorker.isAgentQueueDrainTask(
          WorkmanagerAgentQueueDrainScheduler.taskName,
        ),
        isTrue,
      );
      expect(
        AgentQueueBackgroundWorker.isAgentQueueDrainTask(
          WorkmanagerAgentQueueDrainScheduler.uniqueName,
        ),
        isTrue,
      );
      expect(
        AgentQueueBackgroundWorker.isAgentQueueDrainTask(
          'workmanager.background.task',
        ),
        isFalse,
      );
    });

    test('uses KEEP for unique WorkManager drain scheduling', () {
      expect(
        WorkmanagerAgentQueueDrainScheduler.existingWorkPolicy,
        ExistingWorkPolicy.keep,
      );
    });

    test('clamps immediate retry delay to at least thirty seconds', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      expect(
        AgentQueueBackgroundWorker.clampNextDelay(now - 120),
        const Duration(seconds: 30),
      );
      expect(
        AgentQueueBackgroundWorker.clampNextDelay(now + 10),
        const Duration(seconds: 30),
      );
    });

    test('keeps future retry delay when it is longer than the clamp', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      expect(
        AgentQueueBackgroundWorker.clampNextDelay(now + 600),
        const Duration(seconds: 600),
      );
    });

    test('does not initialize task queue when no user is active', () async {
      SharedPreferences.setMockInitialValues({});
      var initialized = false;
      final platform = _FakeBackgroundPlatform();

      final completed = await AgentQueueBackgroundWorker.run(
        initializeTaskQueue: (_) async {
          initialized = true;
        },
        executor: executor,
        scheduler: scheduler,
        backgroundPlatform: platform,
      );

      expect(completed, isTrue);
      expect(initialized, isFalse);
      expect(scheduler.scheduleCalls, 0);
      expect(platform.stopCalls, 1);
    });

    test('retries a transient database lock before draining queue', () async {
      var attempts = 0;
      final platform = _FakeBackgroundPlatform();

      final completed = await AgentQueueBackgroundWorker.run(
        initializeTaskQueue: (_) async {
          attempts++;
          if (attempts == 1) {
            throw Exception('SqliteException(5): database is locked (code 5)');
          }
        },
        executor: executor,
        scheduler: scheduler,
        backgroundPlatform: platform,
        databaseRetryDelay: Duration.zero,
      );

      expect(completed, isTrue);
      expect(attempts, 2);
      expect(scheduler.scheduleCalls, 0);
      expect(platform.stopCalls, 1);
    });

    test('reschedules soon when another executor owns the queue', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await db.into(db.kvStore).insert(
            KvStoreCompanion.insert(
              key: 'agent_queue_lease:worker-user',
              value: const Value('foreground-owner:foreground'),
              bucket: const Value('agent_queue_lease'),
              updatedAt: Value(now),
            ),
          );
      await db.into(db.tasks).insert(
            TasksCompanion.insert(
              id: 'foreground-owned-task',
              type: 'owned_task',
              payload: const Value('{}'),
              status: 'pending',
              createdAt: Value(now),
            ),
          );
      await tracker.trackTask('foreground-owned-task');
      final platform = _FakeBackgroundPlatform();

      final completed = await AgentQueueBackgroundWorker.run(
        initializeTaskQueue: (_) async {},
        executor: executor,
        scheduler: scheduler,
        backgroundPlatform: platform,
        databaseRetryDelay: Duration.zero,
      );

      final snapshot = await tracker.getSnapshot();

      expect(completed, isTrue);
      expect(snapshot.paused, isTrue);
      expect(
        snapshot.pausedMessage,
        UserStorage.l10n.agentBackgroundPausedDetail,
      );
      expect(scheduler.scheduleCalls, 1);
      expect(scheduler.initialDelays.single, const Duration(seconds: 30));
      expect(scheduler.expeditedValues.single, isFalse);
      expect(platform.updates.single.state, AgentBackgroundRunState.paused);
      final task = await (db.select(
        db.tasks,
      )..where((row) => row.id.equals('foreground-owned-task')))
          .getSingle();
      expect(task.status, 'pending');
    });

    test('does not retry non-database initialization failures', () async {
      var attempts = 0;

      final completed = await AgentQueueBackgroundWorker.run(
        initializeTaskQueue: (_) async {
          attempts++;
          throw StateError('bad background setup');
        },
        executor: executor,
        scheduler: scheduler,
        databaseRetryDelay: Duration.zero,
      );

      expect(completed, isFalse);
      expect(attempts, 1);
    });

    test('reschedules when only future retrying tasks remain', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await db.into(db.tasks).insert(
            TasksCompanion.insert(
              id: 'future-retry',
              type: 'unknown_task',
              payload: const Value('{}'),
              status: 'retrying',
              createdAt: Value(now),
              scheduledAt: Value(now + 600),
            ),
          );
      await tracker.trackTask('future-retry');
      final platform = _FakeBackgroundPlatform();

      final completed = await AgentQueueBackgroundWorker.run(
        initializeTaskQueue: (_) async {},
        executor: executor,
        scheduler: scheduler,
        backgroundPlatform: platform,
        databaseRetryDelay: Duration.zero,
      );

      expect(completed, isTrue);
      expect(scheduler.scheduleCalls, 1);
      expect(scheduler.expeditedValues.single, isFalse);
      expect(
        scheduler.initialDelays.single!.inSeconds,
        inInclusiveRange(590, 600),
      );
      expect(platform.updates.single.state, AgentBackgroundRunState.active);
      expect(platform.updateBackgroundFlags.single, isTrue);
      expect(platform.stopCalls, 0);
    });

    test(
      'marks tracked foreground work paused when background slice ends with work left',
      () async {
        executor.registerHandler('slice_task', (_, __, ___) async {});
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        for (var i = 0; i < 6; i++) {
          final taskId = 'slice-task-$i';
          await db.into(db.tasks).insert(
                TasksCompanion.insert(
                  id: taskId,
                  type: 'slice_task',
                  payload: const Value('{}'),
                  status: 'pending',
                  createdAt: Value(now + i),
                ),
              );
          await tracker.trackTask(taskId);
        }
        final platform = _FakeBackgroundPlatform();

        final completed = await AgentQueueBackgroundWorker.run(
          initializeTaskQueue: (_) async {},
          executor: executor,
          scheduler: scheduler,
          backgroundPlatform: platform,
          maxRunDuration: Duration.zero,
          databaseRetryDelay: Duration.zero,
        );

        final snapshot = await tracker.getSnapshot();

        expect(completed, isTrue);
        expect(snapshot.paused, isTrue);
        expect(
          snapshot.pausedMessage,
          UserStorage.l10n.agentBackgroundPausedDetail,
        );
        expect(platform.updates.single.state, AgentBackgroundRunState.paused);
        expect(scheduler.scheduleCalls, 1);
      },
    );

    test('drains handlers that publish agent activity after init', () async {
      executor.registerHandler('activity_task', (
        userId,
        payload,
        context,
      ) async {
        await AgentActivityService.instance.pushMessage(
          type: AgentActivityType.info,
          title: 'Background activity',
          content: 'worker drain',
          agentName: 'Worker Agent',
          agentId: 'worker-agent',
          userId: userId,
        );
      });
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await db.into(db.tasks).insert(
            TasksCompanion.insert(
              id: 'activity-task',
              type: 'activity_task',
              payload: const Value('{}'),
              status: 'pending',
              createdAt: Value(now),
            ),
          );
      await tracker.trackTask('activity-task');
      final platform = _FakeBackgroundPlatform();

      final completed = await AgentQueueBackgroundWorker.run(
        initializeTaskQueue: (_) async {
          AgentActivityService.setInstance(LocalAgentActivityService.instance);
        },
        executor: executor,
        scheduler: scheduler,
        backgroundPlatform: platform,
        databaseRetryDelay: Duration.zero,
      );

      final task = await (db.select(
        db.tasks,
      )..where((t) => t.id.equals('activity-task')))
          .getSingle();
      final messages = await LocalAgentActivityService.instance.getHistory(
        limit: 1,
      );

      expect(completed, isTrue);
      expect(task.status, 'completed');
      expect(messages.single.title, 'Background activity');
      expect(scheduler.scheduleCalls, 0);
      expect(platform.stopCalls, 1);
    });

    test(
      'refreshes Android surface from live activity while task is processing',
      () async {
        final releaseHandler = Completer<void>();
        executor.registerHandler('activity_task', (
          userId,
          payload,
          context,
        ) async {
          await AgentActivityService.instance.pushMessage(
            type: AgentActivityType.info,
            title: 'Background activity',
            content: 'worker drain',
            agentName: 'Worker Agent',
            agentId: 'worker-agent',
            userId: userId,
          );
          await releaseHandler.future;
        });
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await db.into(db.tasks).insert(
              TasksCompanion.insert(
                id: 'live-activity-task',
                type: 'activity_task',
                payload: const Value('{}'),
                status: 'pending',
                createdAt: Value(now),
              ),
            );
        await tracker.trackTask('live-activity-task');
        final platform = _FakeBackgroundPlatform();

        final runFuture = AgentQueueBackgroundWorker.run(
          initializeTaskQueue: (_) async {
            AgentActivityService.setInstance(
              LocalAgentActivityService.instance,
            );
          },
          executor: executor,
          scheduler: scheduler,
          backgroundPlatform: platform,
          databaseRetryDelay: Duration.zero,
        );

        await _waitUntil(() => platform.updates.isNotEmpty);
        expect(platform.updates.single.state, AgentBackgroundRunState.active);
        expect(platform.updates.single.summary, 'worker drain');
        expect(platform.updateBackgroundFlags.single, isTrue);
        expect(platform.stopCalls, 0);

        releaseHandler.complete();
        final completed = await runFuture;

        expect(completed, isTrue);
        expect(platform.stopCalls, 1);
      },
    );

    test(
      'publishes each live activity update while task remains active',
      () async {
        final releaseHandler = Completer<void>();
        executor.registerHandler('multi_activity_task', (
          userId,
          payload,
          context,
        ) async {
          await AgentActivityService.instance.pushMessage(
            type: AgentActivityType.info,
            title: 'First step',
            content: 'reading context',
            agentName: 'Worker Agent',
            agentId: 'worker-agent',
            userId: userId,
          );
          await AgentActivityService.instance.pushMessage(
            type: AgentActivityType.info,
            title: 'Second step',
            content: 'writing results',
            agentName: 'Worker Agent',
            agentId: 'worker-agent',
            userId: userId,
          );
          await releaseHandler.future;
        });
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await db.into(db.tasks).insert(
              TasksCompanion.insert(
                id: 'multi-live-activity-task',
                type: 'multi_activity_task',
                payload: const Value('{}'),
                status: 'pending',
                createdAt: Value(now),
              ),
            );
        await tracker.trackTask('multi-live-activity-task');
        final platform = _FakeBackgroundPlatform();

        final runFuture = AgentQueueBackgroundWorker.run(
          initializeTaskQueue: (_) async {
            AgentActivityService.setInstance(
              LocalAgentActivityService.instance,
            );
          },
          executor: executor,
          scheduler: scheduler,
          backgroundPlatform: platform,
          databaseRetryDelay: Duration.zero,
        );

        await _waitUntil(() => platform.updates.length >= 2);
        expect(
          platform.updates.map((status) => status.summary),
          containsAllInOrder(['reading context', 'writing results']),
        );
        expect(
          platform.updates.map((status) => status.stage),
          containsAllInOrder(['First step', 'Second step']),
        );
        expect(platform.updateBackgroundFlags, everyElement(isTrue));
        expect(platform.stopCalls, 0);

        releaseHandler.complete();
        final completed = await runFuture;

        expect(completed, isTrue);
        expect(platform.stopCalls, 1);
      },
    );

    test(
      'uses latest live activity in final status when retrying work remains',
      () async {
        executor.registerHandler('activity_task', (
          userId,
          payload,
          context,
        ) async {
          await AgentActivityService.instance.pushMessage(
            type: AgentActivityType.info,
            title: 'Background activity',
            content: 'last visible step',
            agentName: 'Worker Agent',
            agentId: 'worker-agent',
            userId: userId,
          );
        });
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await db.into(db.tasks).insert(
              TasksCompanion.insert(
                id: 'activity-before-retry',
                type: 'activity_task',
                payload: const Value('{}'),
                status: 'pending',
                createdAt: Value(now),
              ),
            );
        await db.into(db.tasks).insert(
              TasksCompanion.insert(
                id: 'future-retry-after-activity',
                type: 'unknown_task',
                payload: const Value('{}'),
                status: 'retrying',
                createdAt: Value(now),
                scheduledAt: Value(now + 600),
              ),
            );
        await tracker.trackTask('future-retry-after-activity');
        final platform = _FakeBackgroundPlatform();

        final completed = await AgentQueueBackgroundWorker.run(
          initializeTaskQueue: (_) async {
            AgentActivityService.setInstance(
              LocalAgentActivityService.instance,
            );
          },
          executor: executor,
          scheduler: scheduler,
          backgroundPlatform: platform,
          databaseRetryDelay: Duration.zero,
        );

        expect(completed, isTrue);
        expect(scheduler.scheduleCalls, 1);
        expect(platform.stopCalls, 0);
        expect(platform.updates, isNotEmpty);
        expect(platform.updates.last.retrying, 1);
        expect(platform.updates.last.remainingTasks, 1);
        expect(platform.updates.last.summary, 'last visible step');
        expect(platform.updates.last.stage, 'Background activity');
        expect(platform.updateBackgroundFlags.last, isTrue);
      },
    );
  });
}

class _FakeBackgroundPlatform implements AgentBackgroundPlatform {
  final updates = <AgentBackgroundStatus>[];
  final updateBackgroundFlags = <bool>[];
  var finishCalls = 0;
  var stopCalls = 0;

  @override
  bool get isSupported => true;

  @override
  Stream<String> get actionStream => const Stream<String>.empty();

  @override
  Future<String?> consumeInitialAction() async => null;

  @override
  Future<void> finishStatus(
    AgentBackgroundStatus status, {
    bool isInBackground = false,
  }) async {
    finishCalls++;
  }

  @override
  Future<void> stopStatus() async {
    stopCalls++;
  }

  @override
  Future<void> updateStatus(
    AgentBackgroundStatus status, {
    bool isInBackground = false,
  }) async {
    updates.add(status);
    updateBackgroundFlags.add(isInBackground);
  }
}

class _FakeDrainScheduler implements AgentQueueDrainScheduler {
  final initialDelays = <Duration?>[];
  final expeditedValues = <bool>[];
  var cancelCalls = 0;

  int get scheduleCalls => initialDelays.length;

  @override
  Future<void> cancel() async {
    cancelCalls++;
  }

  @override
  Future<void> schedule({
    Duration? initialDelay,
    bool expedited = false,
  }) async {
    initialDelays.add(initialDelay);
    expeditedValues.add(expedited);
  }
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
