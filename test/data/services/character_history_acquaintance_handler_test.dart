import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/character_history_acquaintance_handler.dart';
import 'package:memex/domain/models/character_model.dart';

void main() {
  test('completed acquaintance retries do not run the agent again', () async {
    final root = await Directory.systemTemp.createTemp('history_handler_');
    final workspace = CharacterWorkspaceService(
      fileSystem: FileSystemService.detached(dataRoot: root.path),
    );
    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她有自己的观察角度。',
      enabled: true,
    );
    var runs = 0;
    final handler = CharacterHistoryAcquaintanceTaskHandler(
      workspaceService: workspace,
      executionCoordinator: CharacterExecutionCoordinator(),
      characterLoader: (_, __) async => character,
      acquaint: ({
        required userId,
        required character,
        CharacterWorkspaceService? workspaceService,
      }) async {
        runs++;
        await workspace.completeHistoryAcquaintance(
          userId: userId,
          characterId: character.id,
          completedAt: DateTime.parse('2026-07-15T14:00:00+08:00'),
        );
      },
    );
    addTearDown(() => root.delete(recursive: true));
    final context = TaskContext(
      taskId: 'history-1',
      taskType: 'character_history_acquaintance_task',
    );

    await handler.call(
      'user-1',
      {'character_id': character.id},
      context,
    );
    await handler.call(
      'user-1',
      {'character_id': character.id},
      context,
    );

    expect(runs, 1);
  });
}
