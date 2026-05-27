import 'dart:io';

import 'package:drift/native.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/schedule_aggregator_handler.dart';
import 'package:memex/db/app_database.dart';
import 'package:test/test.dart';

void main() {
  group('handleScheduleAggregation', () {
    late Directory tempRoot;
    late AppDatabase db;
    const userId = 'schedule_handler_user';

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp(
        'memex_schedule_handler_',
      );
      await FileSystemService.init(tempRoot.path);
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      await db.searchDao.createFtsTables();
    });

    tearDown(() async {
      await db.close();
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('completes empty schedule request as no-op', () async {
      await handleScheduleAggregation(
        userId,
        const {},
        TaskContext(
          taskId: 'schedule_empty_request',
          taskType: 'schedule_aggregator_task',
        ),
      );

      final state =
          await FileSystemService.instance.readScheduleStateRaw(userId);

      expect(state, isNotNull);
      expect(state!['pending'], isEmpty);
      expect(state['presentation'], isNull);
    });
  });
}
