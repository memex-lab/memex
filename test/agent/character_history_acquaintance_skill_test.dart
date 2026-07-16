import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/character_agent/character_history_acquaintance_skill.dart';
import 'package:memex/data/services/character_history_acquaintance_service.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/character_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('requires a real history visit before completing acquaintance',
      () async {
    final root = await Directory.systemTemp.createTemp('history_skill_');
    await FileSystemService.init(root.path);
    final workspace = CharacterWorkspaceService();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = CharacterHistoryAcquaintanceService.forTesting(
      fileSystem: FileSystemService.instance,
      workspaceService: workspace,
      taskExecutor: LocalTaskExecutor.forTesting(db: db),
    );
    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她会留意家庭里轻轻的玩笑。',
      enabled: true,
    );
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    await workspace.ensureInitialized('user-1', character);
    const factId = '2026/07/13.md#ts_1';
    await FileSystemService.instance.writeYamlFile(
      FileSystemService.instance.getCardPath('user-1', factId),
      const CardData(
        factId: factId,
        timestamp: 1783951200,
        status: 'completed',
        tags: ['日常'],
        uiConfigs: [],
        title: '长大',
        fact: '小朋友说现在每天都玩不够。',
      ).toJson(),
    );

    final skill = CharacterHistoryAcquaintanceSkill(
      character: character,
      userId: 'user-1',
      workspaceService: workspace,
      historyService: service,
    );
    final browse = skill.tools!.singleWhere(
      (tool) => tool.name == 'BrowseHistory',
    );
    final finish = skill.tools!.singleWhere(
      (tool) => tool.name == 'FinishAcquaintance',
    );

    await expectLater(
      Future.sync(() => Function.apply(finish.executable!, const [])),
      throwsStateError,
    );
    final result = await Function.apply(browse.executable!, [1, 12]);
    expect(result, contains('每天都玩不够'));
    await Function.apply(finish.executable!, const []);

    expect(
      await workspace.isHistoryAcquaintanceComplete('user-1', 'yaoyao'),
      isTrue,
    );
    expect(skill.systemPrompt, contains('subjective and selective'));
  });
}
