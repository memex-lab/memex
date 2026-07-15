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
}
