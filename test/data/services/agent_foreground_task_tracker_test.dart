import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/agent_foreground_task_tracker.dart';
import 'package:memex/db/app_database.dart';

void main() {
  group('AgentForegroundTaskTracker', () {
    late AppDatabase db;
    late AgentForegroundTaskTracker tracker;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      tracker = AgentForegroundTaskTracker.forTesting(db: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('tracks active task ids and counts current task statuses', () async {
      await _insertTask(db, id: 'pending-a', status: 'pending');
      await _insertTask(db, id: 'processing-a', status: 'processing');
      await _insertTask(db, id: 'untracked-a', status: 'processing');

      await tracker.trackTask('pending-a');
      await tracker.trackTask('processing-a');

      final snapshot = await tracker.getSnapshot();

      expect(snapshot.activeTaskIds, {'pending-a', 'processing-a'});
      expect(snapshot.taskSnapshot.pending, 1);
      expect(snapshot.taskSnapshot.processing, 1);
      expect(snapshot.taskSnapshot.retrying, 0);
      expect(snapshot.taskSnapshot.total, 2);
    });

    test('removes completed tasks from tracking', () async {
      await _insertTask(db, id: 'task-a', status: 'pending');
      await tracker.trackTask('task-a');

      await (db.update(db.tasks)..where((task) => task.id.equals('task-a')))
          .write(const TasksCompanion(status: Value('completed')));

      final snapshot = await tracker.getSnapshot();

      expect(snapshot.activeTaskIds, isEmpty);
      expect(snapshot.hasActiveTasks, isFalse);
      expect(snapshot.hasAttention, isFalse);
    });

    test('moves failed tracked tasks to clearable attention state', () async {
      await _insertTask(db, id: 'task-a', status: 'pending');
      await tracker.trackTask('task-a');

      await (db.update(db.tasks)..where((task) => task.id.equals('task-a')))
          .write(
        const TasksCompanion(
          status: Value('failed'),
          error: Value('API key is missing'),
        ),
      );

      final failed = await tracker.getSnapshot();
      expect(failed.activeTaskIds, isEmpty);
      expect(failed.attentionTaskErrors, {'task-a': 'API key is missing'});

      await tracker.clearAttention();
      final cleared = await tracker.getSnapshot();
      expect(cleared.hasAttention, isFalse);
      expect(cleared.activeTaskIds, isEmpty);
    });

    test('pauses only while tracked active tasks remain', () async {
      await _insertTask(db, id: 'task-a', status: 'retrying');
      await tracker.trackTask('task-a');

      await tracker.markPaused(message: 'Background window ended.');
      final paused = await tracker.getSnapshot();
      expect(paused.paused, isTrue);
      expect(paused.pausedMessage, 'Background window ended.');

      await (db.update(db.tasks)..where((task) => task.id.equals('task-a')))
          .write(const TasksCompanion(status: Value('completed')));
      final completed = await tracker.getSnapshot();
      expect(completed.paused, isFalse);
      expect(completed.activeTaskIds, isEmpty);
    });
  });
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
          type: 'super_agent_chat_turn_task',
          payload: const Value('{}'),
          status: status,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
}
