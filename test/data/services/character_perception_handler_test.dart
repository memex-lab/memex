import 'dart:io';

import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/character_perception_handler.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/character_workspace.dart';
import 'package:test/test.dart';

void main() {
  group('CharacterPerceptionTaskHandler', () {
    late Directory tempRoot;
    late CharacterWorkspaceService workspaceService;
    late CharacterModel primary;

    setUp(() async {
      tempRoot =
          await Directory.systemTemp.createTemp('memex_perception_task_');
      workspaceService = CharacterWorkspaceService(
        fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
      );
      primary = CharacterModel(
        id: 'primary',
        name: '瑶瑶',
        tags: const [],
        persona: '安静地留意日常。',
        enabled: true,
        isPrimaryCompanion: true,
      );
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('routes once to the primary character and drains the inbox', () async {
      final digested = <CharacterObservation>[];
      final handler = CharacterPerceptionTaskHandler(
        workspaceService: workspaceService,
        primaryCompanionLoader: (_) async => primary,
        observationDigester: ({
          required userId,
          required character,
          required observation,
          workspaceService,
        }) async {
          digested.add(observation);
          await workspaceService!.completeObservation(
            userId: userId,
            characterId: character.id,
            observationId: observation.id,
          );
        },
      );
      final payload = <String, dynamic>{
        'source_event_id': 'event-1',
        'fact_id': '2026/07/13.md#ts_1',
        'combined_text': '今天她说每天都玩不够。',
        'created_at_ts': 1783958400,
      };
      final context = TaskContext(
        taskId: 'task-1',
        taskType: 'character_perception_task',
        bizId: 'event:user_input_submitted:event-1',
      );

      await handler('wujia', payload, context);
      await handler('wujia', payload, context);

      expect(digested, hasLength(1));
      expect(digested.single.factId, '2026/07/13.md#ts_1');
      expect(
        await workspaceService.loadPendingObservations('wujia', 'primary'),
        isEmpty,
      );
    });

    test('does nothing when no enabled primary companion exists', () async {
      var digesterCalled = false;
      final handler = CharacterPerceptionTaskHandler(
        workspaceService: workspaceService,
        primaryCompanionLoader: (_) async => null,
        observationDigester: ({
          required userId,
          required character,
          required observation,
          workspaceService,
        }) async {
          digesterCalled = true;
        },
      );

      await handler(
        'wujia',
        {
          'source_event_id': 'event-2',
          'combined_text': '一条普通记录',
          'created_at_ts': 1783958400,
        },
        TaskContext(
          taskId: 'task-2',
          taskType: 'character_perception_task',
        ),
      );

      expect(digesterCalled, isFalse);
    });
  });
}
