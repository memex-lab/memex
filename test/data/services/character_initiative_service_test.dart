import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_initiative_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores one wake loop and preserves an existing chosen time',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final executor = LocalTaskExecutor.forTesting(db: db);
    final now = DateTime.parse('2026-07-15T12:00:00+08:00');
    var clockNow = now;
    final service = CharacterInitiativeService.forTesting(
      taskExecutor: executor,
      clock: () => clockNow,
    );
    addTearDown(db.close);

    await service.ensureScheduled(userId: 'user-1');
    await service.ensureScheduled(userId: 'user-1');

    var tasks = await db.select(db.tasks).get();
    expect(tasks, hasLength(1));
    expect(tasks.single.bizId, CharacterInitiativeService.taskBizId);
    expect(tasks.single.scheduledAt, now.millisecondsSinceEpoch ~/ 1000);

    final wakeAt = now.add(const Duration(hours: 7, minutes: 30));
    await service.scheduleNextWake(
      userId: 'user-1',
      wakeAt: wakeAt,
      reason: '晚上想起她时，再看看要不要说句话。',
    );
    await service.ensureScheduled(userId: 'user-1');

    tasks = await db.select(db.tasks).get();
    expect(tasks, hasLength(1));
    expect(tasks.single.scheduledAt, wakeAt.millisecondsSinceEpoch ~/ 1000);
    final payload = jsonDecode(tasks.single.payload!) as Map<String, dynamic>;
    expect(payload['wake_reason'], '晚上想起她时，再看看要不要说句话。');
    expect(payload['scheduled_wake_at'], wakeAt.toIso8601String());
    expect(
      await executor.hasActiveTask(
        taskType: CharacterInitiativeService.taskType,
        bizId: CharacterInitiativeService.taskBizId,
      ),
      isTrue,
    );

    clockNow = wakeAt.add(const Duration(minutes: 1));
    await service.scheduleNextWake(
      userId: 'user-1',
      wakeAt: wakeAt,
      reason: '醒来的时间已经到了，现在就重新想一想。',
    );
    tasks = await db.select(db.tasks).get();
    expect(
      tasks.single.scheduledAt,
      clockNow.millisecondsSinceEpoch ~/ 1000,
    );
  });

  test('conversation deferral preserves the initiative task identity',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final executor = LocalTaskExecutor.forTesting(db: db);
    final now = DateTime.parse('2026-07-25T16:25:00+08:00');
    final retryAt = now.add(const Duration(seconds: 2));
    final service = CharacterInitiativeService.forTesting(
      taskExecutor: executor,
      clock: () => now,
    );
    addTearDown(db.close);

    await service.scheduleConversationDeferredRetry(
      userId: 'user-1',
      characterId: 'auntie',
      payload: const {
        'source_event_id': 'initiative-due',
        'pending_thought_id': 'thought-1',
        'pending_thought_wake_at': '2026-07-25T16:00:00+08:00',
      },
      retryAt: retryAt,
      reason: 'Wait until the direct reply is complete.',
    );

    final task = (await db.select(db.tasks).get()).single;
    final payload = jsonDecode(task.payload!) as Map<String, dynamic>;
    expect(task.type, CharacterInitiativeService.taskType);
    expect(task.bizId, CharacterInitiativeService.taskBizId);
    expect(task.scheduledAt, retryAt.millisecondsSinceEpoch ~/ 1000);
    expect(payload['character_id'], 'auntie');
    expect(payload['source_event_id'], 'initiative-due');
    expect(payload['pending_thought_id'], 'thought-1');
    expect(
      payload['pending_thought_wake_at'],
      '2026-07-25T16:00:00+08:00',
    );
    expect(
      payload['wake_reason'],
      'Wait until the direct reply is complete.',
    );
  });
}
