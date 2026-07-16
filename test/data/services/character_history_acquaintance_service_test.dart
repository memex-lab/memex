import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_history_acquaintance_service.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/character_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('browses existing moments and schedules acquaintance only once',
      () async {
    final root = await Directory.systemTemp.createTemp('character_history_');
    final fileSystem = FileSystemService.detached(dataRoot: root.path);
    final workspace = CharacterWorkspaceService(fileSystem: fileSystem);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final executor = LocalTaskExecutor.forTesting(db: db);
    final service = CharacterHistoryAcquaintanceService.forTesting(
      fileSystem: fileSystem,
      workspaceService: workspace,
      taskExecutor: executor,
    );
    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她对平常生活里的小事很好奇。',
      enabled: true,
    );
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });

    for (final entry in [
      (
        id: '2026/07/13.md#ts_1',
        timestamp: 1783951200,
        title: '不想长大',
        fact: '小朋友说现在每天都玩不够。',
      ),
      (
        id: '2025/02/02.md#ts_1',
        timestamp: 1738483200,
        title: '回家',
        fact: '一家人一起回家吃饭。',
      ),
    ]) {
      await fileSystem.writeYamlFile(
        fileSystem.getCardPath('user-1', entry.id),
        CardData(
          factId: entry.id,
          timestamp: entry.timestamp,
          status: 'completed',
          tags: const ['日常'],
          uiConfigs: const [],
          title: entry.title,
          fact: entry.fact,
        ).toJson(),
      );
    }

    final page = await service.browseMoments(
      userId: 'user-1',
      page: 1,
      pageSize: 1,
    );
    expect(page.total, 2);
    expect(page.hasMore, isTrue);
    expect(page.moments.single.factId, '2026/07/13.md#ts_1');

    final search = await service.searchMoments(
      userId: 'user-1',
      query: '回家',
    );
    expect(search.single.factId, '2025/02/02.md#ts_1');

    expect(
      await service.ensureScheduled(userId: 'user-1', character: character),
      isTrue,
    );
    expect(
      await service.ensureScheduled(userId: 'user-1', character: character),
      isFalse,
    );
    expect(await db.select(db.tasks).get(), hasLength(1));
  });
}
