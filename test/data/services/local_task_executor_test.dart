import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';

void main() {
  late AppDatabase db;
  late LocalTaskExecutor executor;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    executor = LocalTaskExecutor.forTesting();
  });

  tearDown(() async {
    executor.stop();
    await db.close();
  });

  group('LocalTaskExecutor scheduling', () {
    test('scans past dependency-blocked queue head to run later tasks',
        () async {
      final completed = Completer<void>();
      executor.registerHandler('runnable_task', (_, __, ___) async {
        if (!completed.isCompleted) completed.complete();
      });

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await db.into(db.tasks).insert(TasksCompanion.insert(
            id: 'unresolved-dependency',
            type: 'dependency_task',
            payload: const Value('{}'),
            status: 'retrying',
            createdAt: Value(now),
            scheduledAt: Value(now + 3600),
          ));

      for (var i = 0; i < 50; i++) {
        await db.into(db.tasks).insert(TasksCompanion.insert(
              id: 'blocked-$i',
              type: 'blocked_task',
              payload: const Value('{}'),
              status: 'pending',
              createdAt: Value(now + i + 1),
              dependencies: Value(jsonEncode(['unresolved-dependency'])),
            ));
      }

      await db.into(db.tasks).insert(TasksCompanion.insert(
            id: 'runnable',
            type: 'runnable_task',
            payload: const Value('{}'),
            status: 'pending',
            createdAt: Value(now + 100),
          ));

      await executor.start(userId: 'user-a');

      await completed.future.timeout(const Duration(seconds: 3));

      final runnable = await _waitForTaskStatus(db, 'runnable', 'completed');
      expect(runnable.status, 'completed');

      final blocked = await _getTask(db, 'blocked-0');
      expect(blocked.status, 'pending');
    });

    test('fails malformed dependencies and still runs a later valid task',
        () async {
      final completed = Completer<void>();
      executor.registerHandler('runnable_task', (_, __, ___) async {
        if (!completed.isCompleted) completed.complete();
      });

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await db.into(db.tasks).insert(TasksCompanion.insert(
            id: 'bad-dependency',
            type: 'blocked_task',
            payload: const Value('{}'),
            status: 'pending',
            priority: const Value(10),
            createdAt: Value(now),
            dependencies: const Value('not-json'),
          ));

      await db.into(db.tasks).insert(TasksCompanion.insert(
            id: 'runnable',
            type: 'runnable_task',
            payload: const Value('{}'),
            status: 'pending',
            createdAt: Value(now + 1),
          ));

      await executor.start(userId: 'user-a');

      await completed.future.timeout(const Duration(seconds: 3));
      await _waitForTaskStatus(db, 'runnable', 'completed');

      final malformed = await _getTask(db, 'bad-dependency');
      expect(malformed.status, 'failed');
      expect(malformed.error, contains('Invalid task dependencies'));
    });

    test('uses only available concurrency slots while backlog remains queued',
        () async {
      final release = Completer<void>();
      var startedCount = 0;
      executor.registerHandler('runnable_task', (_, __, ___) async {
        startedCount++;
        await release.future;
      });

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await executor.start(userId: 'user-a');
      for (var i = 0; i < 4; i++) {
        await db.into(db.tasks).insert(TasksCompanion.insert(
              id: 'active-$i',
              type: 'already_processing',
              payload: const Value('{}'),
              status: 'processing',
              createdAt: Value(now + i),
            ));
      }

      for (var i = 0; i < 3; i++) {
        await db.into(db.tasks).insert(TasksCompanion.insert(
              id: 'runnable-$i',
              type: 'runnable_task',
              payload: const Value('{}'),
              status: 'pending',
              createdAt: Value(now + 10 + i),
            ));
      }

      await _waitUntil(() => startedCount == 1);
      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(startedCount, 1);

      release.complete();
      await _waitForTaskStatus(db, 'runnable-0', 'completed');
      executor.stop();
    });

    test('serializes tasks that share a concurrency policy key', () async {
      final firstStarted = Completer<void>();
      final releaseFirst = Completer<void>();
      final secondStarted = Completer<void>();
      final otherCompleted = Completer<void>();

      executor.registerHandler(
        'serial_task',
        (_, __, context) async {
          if (context.taskId == 'serial-1') {
            if (!firstStarted.isCompleted) firstStarted.complete();
            await releaseFirst.future;
          } else if (context.taskId == 'serial-2') {
            if (!secondStarted.isCompleted) secondStarted.complete();
          }
        },
        concurrencyPolicy: TaskConcurrencyPolicy.byUser(),
      );
      executor.registerHandler('other_task', (_, __, ___) async {
        if (!otherCompleted.isCompleted) otherCompleted.complete();
      });

      await _insertTask(
        db,
        id: 'serial-1',
        type: 'serial_task',
        status: 'pending',
        payload: {'value': 1},
      );
      await _insertTask(
        db,
        id: 'serial-2',
        type: 'serial_task',
        status: 'pending',
        payload: {'value': 2},
      );
      await _insertTask(
        db,
        id: 'other',
        type: 'other_task',
        status: 'pending',
        payload: {'value': 3},
      );

      await executor.start(userId: 'user-a');
      await firstStarted.future.timeout(const Duration(seconds: 3));
      await otherCompleted.future.timeout(const Duration(seconds: 3));
      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect((await _getTask(db, 'serial-2')).status, 'pending');

      releaseFirst.complete();
      await secondStarted.future.timeout(const Duration(seconds: 3));
      await _waitForTaskStatus(db, 'serial-1', 'completed');
      await _waitForTaskStatus(db, 'serial-2', 'completed');
    });

    test('reports active task activity snapshot', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await db.into(db.tasks).insert(TasksCompanion.insert(
            id: 'pending-task',
            type: 'task',
            payload: const Value('{}'),
            status: 'pending',
            createdAt: Value(now),
          ));
      await db.into(db.tasks).insert(TasksCompanion.insert(
            id: 'processing-task',
            type: 'task',
            payload: const Value('{}'),
            status: 'processing',
            createdAt: Value(now),
          ));
      await db.into(db.tasks).insert(TasksCompanion.insert(
            id: 'retrying-task',
            type: 'task',
            payload: const Value('{}'),
            status: 'retrying',
            createdAt: Value(now),
          ));
      await db.into(db.tasks).insert(TasksCompanion.insert(
            id: 'completed-task',
            type: 'task',
            payload: const Value('{}'),
            status: 'completed',
            createdAt: Value(now),
          ));

      final snapshot = await executor.getTaskActivitySnapshot();

      expect(
        snapshot,
        const TaskActivitySnapshot(
          pending: 1,
          processing: 1,
          retrying: 1,
        ),
      );
      expect(snapshot.total, 3);
      expect(snapshot.hasActiveTasks, isTrue);
    });
  });

  group('LocalTaskExecutor crash loop guard', () {
    test('clears execution marker after successful task completion', () async {
      var handled = false;
      executor.registerHandler('ok_task', (userId, payload, context) async {
        handled = true;
      });

      await executor.start(userId: 'user-a');
      final taskId = await executor.enqueueTask(
        userId: 'user-a',
        taskType: 'ok_task',
        payload: {'value': 1},
      );

      final task = await _waitForTaskStatus(db, taskId, 'completed');

      expect(handled, isTrue);
      expect(task.status, 'completed');
      expect(await executor.getTaskExecutionMarkerForTesting(), isNull);
    });

    test(
      'clears execution marker when Dart handler failure is retryable',
      () async {
        executor.registerHandler('throw_task', (
          userId,
          payload,
          context,
        ) async {
          throw StateError('boom');
        });

        await executor.start(userId: 'user-a');
        final taskId = await executor.enqueueTask(
          userId: 'user-a',
          taskType: 'throw_task',
          payload: {'value': 1},
          maxRetries: 1,
        );

        final task = await _waitForTaskStatus(db, taskId, 'retrying');

        expect(task.retryCount, 1);
        expect(task.error, contains('boom'));
        expect(await executor.getTaskExecutionMarkerForTesting(), isNull);
      },
    );

    test('first crash-like restart requeues stale processing task', () async {
      final task = await _insertTask(
        db,
        id: 'task-first-crash',
        type: 'dangerous_task',
        status: 'processing',
        payload: {'asset': 'large-image'},
      );
      await executor.markTaskExecutionStartedForTesting(task);

      await executor.start(userId: 'user-a');
      executor.stop();

      final updated = await _getTask(db, task.id);
      final marker = await executor.getTaskExecutionMarkerForTesting(task.id);
      final markerPayload = jsonDecode(marker!.value!) as Map<String, dynamic>;

      expect(updated.status, 'pending');
      expect(markerPayload['task_id'], task.id);
      expect(markerPayload['crash_count'], 1);
    });

    test('graceful app exit requeues stale task without crash count', () async {
      final task = await _insertTask(
        db,
        id: 'task-graceful-exit',
        type: 'long_running_task',
        status: 'processing',
        payload: {'value': 1},
      );
      await executor.markTaskExecutionStartedForTesting(task);
      await Future<void>.delayed(const Duration(milliseconds: 2));
      await executor.recordGracefulShutdown(reason: 'test_manual_exit');

      await executor.start(userId: 'user-a');
      executor.stop();

      final updated = await _getTask(db, task.id);

      expect(updated.status, 'pending');
      expect(await executor.getTaskExecutionMarkerForTesting(task.id), isNull);
      expect(await executor.getGracefulExitMarkerForTesting(), isNull);
    });

    test('keeps separate crash markers for concurrent processing tasks',
        () async {
      final taskA = await _insertTask(
        db,
        id: 'task-concurrent-a',
        type: 'dangerous_task_a',
        status: 'processing',
        payload: {'asset': 'large-image-a'},
      );
      final taskB = await _insertTask(
        db,
        id: 'task-concurrent-b',
        type: 'dangerous_task_b',
        status: 'processing',
        payload: {'asset': 'large-image-b'},
      );
      await executor.markTaskExecutionStartedForTesting(taskA);
      await executor.markTaskExecutionStartedForTesting(taskB);

      await executor.start(userId: 'user-a');
      executor.stop();

      final updatedA = await _getTask(db, taskA.id);
      final updatedB = await _getTask(db, taskB.id);
      final markerRows = await executor.getTaskExecutionMarkersForTesting();
      final crashCounts = {
        for (final row in markerRows)
          (jsonDecode(row.value!) as Map<String, dynamic>)['task_id']:
              (jsonDecode(row.value!) as Map<String, dynamic>)['crash_count'],
      };

      expect(updatedA.status, 'pending');
      expect(updatedB.status, 'pending');
      expect(markerRows, hasLength(2));
      expect(crashCounts[taskA.id], 1);
      expect(crashCounts[taskB.id], 1);
    });

    test('simulates process death while a real task execution is in progress',
        () async {
      final firstHandlerStarted = Completer<void>();
      final firstNeverCompletes = Completer<void>();
      executor.registerHandler('native_crash_task', (
        userId,
        payload,
        context,
      ) async {
        if (!firstHandlerStarted.isCompleted) {
          firstHandlerStarted.complete();
        }
        await firstNeverCompletes.future;
      });

      await executor.start(userId: 'user-a');
      final taskId = await executor.enqueueTask(
        userId: 'user-a',
        taskType: 'native_crash_task',
        payload: {'asset': 'oversized-image'},
      );
      await firstHandlerStarted.future.timeout(const Duration(seconds: 3));
      await _waitForTaskStatus(db, taskId, 'processing');
      await _waitForMarkerCrashCount(executor, taskId, 0);

      // Simulate process death: the task is still in progress, so the marker
      // remains and Dart finally/catch never gets a chance to clean it up.
      executor.stop();

      final secondHandlerStarted = Completer<void>();
      final secondNeverCompletes = Completer<void>();
      executor = LocalTaskExecutor.forTesting()
        ..registerHandler('native_crash_task', (
          userId,
          payload,
          context,
        ) async {
          if (!secondHandlerStarted.isCompleted) {
            secondHandlerStarted.complete();
          }
          await secondNeverCompletes.future;
        });

      await executor.start(userId: 'user-a');
      await secondHandlerStarted.future.timeout(const Duration(seconds: 3));
      await _waitForTaskStatus(db, taskId, 'processing');
      await _waitForMarkerCrashCount(executor, taskId, 1);
      executor.stop();

      executor = LocalTaskExecutor.forTesting();
      await executor.start(userId: 'user-a');
      executor.stop();

      final updated = await _getTask(db, taskId);

      expect(updated.status, 'failed');
      expect(updated.error, contains('crash-like exits'));
      expect(await executor.getTaskExecutionMarkerForTesting(taskId), isNull);
    });

    test('second crash-like restart fails task and clears marker', () async {
      final task = await _insertTask(
        db,
        id: 'task-second-crash',
        type: 'dangerous_task',
        status: 'processing',
        payload: {'asset': 'large-image'},
      );
      await executor.markTaskExecutionStartedForTesting(task);
      await _setMarkerCrashCount(db, executor, task.id, 1);

      await executor.start(userId: 'user-a');
      executor.stop();

      final updated = await _getTask(db, task.id);

      expect(updated.status, 'failed');
      expect(updated.error, contains('crash-like exits'));
      expect(await executor.getTaskExecutionMarkerForTesting(), isNull);
    });

    test(
      'bad dependency JSON fails task instead of leaving it pending forever',
      () async {
        await _insertTask(
          db,
          id: 'task-bad-deps',
          type: 'never_runs',
          status: 'pending',
          payload: {'value': 1},
          dependencies: 'not-json',
        );

        await executor.start(userId: 'user-a');

        final updated = await _waitForTaskStatus(db, 'task-bad-deps', 'failed');

        expect(updated.error, contains('Invalid task dependencies'));
        expect(await executor.getTaskExecutionMarkerForTesting(), isNull);
      },
    );
  });
}

Future<Task> _insertTask(
  AppDatabase db, {
  required String id,
  required String type,
  required String status,
  required Map<String, dynamic> payload,
  String? dependencies,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await db.into(db.tasks).insert(
        TasksCompanion.insert(
          id: id,
          type: type,
          payload: Value(jsonEncode(payload)),
          status: status,
          createdAt: Value(now),
          updatedAt: Value(now),
          maxRetries: const Value(5),
          dependencies: Value(dependencies),
        ),
      );
  return _getTask(db, id);
}

Future<Task> _getTask(AppDatabase db, String id) {
  return (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
}

Future<Task> _waitForTaskStatus(
  AppDatabase db,
  String taskId,
  String status, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final task = await _getTask(db, taskId);
    if (task.status == status) return task;
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  final task = await _getTask(db, taskId);
  fail('Task $taskId did not reach $status. Last status: ${task.status}');
}

Future<Map<String, dynamic>> _waitForMarkerCrashCount(
  LocalTaskExecutor executor,
  String taskId,
  int crashCount, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final marker = await executor.getTaskExecutionMarkerForTesting(taskId);
    if (marker?.value != null) {
      final payload = jsonDecode(marker!.value!) as Map<String, dynamic>;
      if (payload['crash_count'] == crashCount) return payload;
    }
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  final marker = await executor.getTaskExecutionMarkerForTesting(taskId);
  fail(
    'Task $taskId marker did not reach crash_count=$crashCount. '
    'Last marker: ${marker?.value}',
  );
}

Future<void> _setMarkerCrashCount(
  AppDatabase db,
  LocalTaskExecutor executor,
  String taskId,
  int crashCount,
) async {
  final marker = await executor.getTaskExecutionMarkerForTesting(taskId);
  final payload = jsonDecode(marker!.value!) as Map<String, dynamic>;
  payload['crash_count'] = crashCount;

  await (db.update(db.kvStore)..where((kv) => kv.key.equals(marker.key))).write(
    KvStoreCompanion(
      value: Value(jsonEncode(payload)),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    ),
  );
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
