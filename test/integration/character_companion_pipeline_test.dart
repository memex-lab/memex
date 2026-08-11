import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/character_initiative_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/task_handlers/character_initiative_handler.dart';
import 'package:memex/data/services/task_handlers/character_perception_handler.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:test/test.dart';

void main() {
  test('record becomes character memory, initiative, and reply context',
      () async {
    final tempRoot =
        await Directory.systemTemp.createTemp('character_pipeline_');
    final fileSystem = FileSystemService.detached(dataRoot: tempRoot.path);
    final workspace = CharacterWorkspaceService(fileSystem: fileSystem);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    final executor = LocalTaskExecutor.forTesting(db: db);
    final eventBus = GlobalEventBus.forTesting(executor);
    final chatService = PersonaChatService.forTesting(db);
    final initiativeService = CharacterInitiativeService.forTesting(
      taskExecutor: executor,
    );
    addTearDown(() async {
      await executor.stop();
      await db.close();
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她会记住平常生活里轻轻的小事。',
      enabled: true,
    );
    final perception = CharacterPerceptionTaskHandler(
      workspaceService: workspace,
      primaryCompanionLoader: (_) async => character,
      observationDigester: ({
        required userId,
        required character,
        required observation,
        workspaceService,
      }) async {
        await workspace.writePkmNote(
          userId: userId,
          characterId: character.id,
          relativePath: 'open_threads/growing-up.md',
          content: '# 长大\n\n她和小朋友最近常常聊到长大。',
        );
        await workspace.completeObservation(
          userId: userId,
          characterId: character.id,
          observationId: observation.id,
        );
      },
    );
    var commentFinished = false;
    final initiative = CharacterInitiativeTaskHandler(
      workspaceService: workspace,
      primaryCompanionLoader: (_) async => character,
      contextLoader: ({
        required userId,
        required character,
        required sourceEventId,
        required now,
        factId,
      }) async =>
          CharacterInitiativeContext(
        sourceEventId: sourceEventId,
        factId: factId,
        now: now,
      ),
      decider: ({
        required userId,
        required character,
        required context,
        workspaceService,
      }) async {
        expect(commentFinished, isTrue);
        final memory = await File(
          '${fileSystem.getCharacterPkmPath(userId, character.id)}'
          '/open_threads/growing-up.md',
        ).readAsString();
        expect(memory, contains('常常聊到长大'));
        return CharacterInitiativeDecision.speak(
          const [
            '现在每天都玩不够了吧。',
            '刚才又想起你说不想长大。',
          ],
          wakeAt: context.now.add(const Duration(hours: 8)),
          reason: '晚一点再想想她今天有没有新的小事。',
        );
      },
      wakeScheduler: initiativeService.scheduleNextWake,
      messageSender: ({
        required characterId,
        required messages,
        required timestamp,
        required contactEpisodeId,
        factId,
      }) async {
        await chatService.addCharacterMessages(
          characterId,
          messages,
          factId: factId,
          timestamp: timestamp,
          origin: PersonaChatMessageOrigin.initiative,
          contactEpisodeId: contactEpisodeId,
        );
        return true;
      },
    );

    executor.registerHandler(
      'character_perception_task',
      perception.call,
    );
    executor.registerHandler('comment_agent_task', (_, __, ___) async {
      commentFinished = true;
    });
    executor.registerHandler(
      'character_initiative_task',
      initiative.call,
    );
    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'character_perception',
        taskType: 'character_perception_task',
        payloadBuilder: (_, event) async {
          final payload = event.payload as UserInputSubmittedPayload;
          return {
            'source_event_id': event.eventId,
            'fact_id': payload.factId,
            'combined_text': payload.combinedText,
            'created_at_ts': payload.createdAtTs,
          };
        },
      ),
    );
    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'comment_agent',
        taskType: 'comment_agent_task',
        payloadBuilder: (_, event) async => const {},
      ),
    );
    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'character_initiative',
        taskType: 'character_initiative_task',
        dependsOn: const ['comment_agent', 'character_perception'],
        payloadBuilder: (_, event) async {
          final payload = event.payload as UserInputSubmittedPayload;
          return {
            'source_event_id': event.eventId,
            'fact_id': payload.factId,
          };
        },
      ),
    );

    final taskIds = await eventBus.publish(
      userId: 'user-1',
      event: SystemEvent<UserInputSubmittedPayload>(
        type: SystemEventTypes.userInputSubmitted,
        source: 'test',
        eventId: 'event-full-chain',
        payload: UserInputSubmittedPayload(
          factId: '2026/07/14.md#ts_1',
          assetPaths: const [],
          combinedText: '小朋友说现在每天都玩不够，所以不想长大。',
          markdownEntry: '',
          createdAtTs: 1783994400,
          pkmCreatedAtTs: 1783994400,
        ),
      ),
    );
    final drain = await executor.drainAvailableTasks(
      userId: 'user-1',
      maxDuration: const Duration(seconds: 5),
      pollInterval: const Duration(milliseconds: 20),
      stopWhenDone: true,
    );
    expect(drain.timedOut, isFalse);
    for (final taskId in taskIds) {
      await _waitForTaskStatus(db, taskId, 'completed');
    }

    final proactiveMessages = await chatService.getMessages('yaoyao');
    expect(proactiveMessages, hasLength(2));
    expect(
      proactiveMessages.every(
        (message) => message.origin == PersonaChatMessageOrigin.initiative,
      ),
      isTrue,
    );

    final replyId = await chatService.addUserMessage('yaoyao', '哈哈，是啊。');
    final history = await chatService.getMessagesBefore(
      'yaoyao',
      beforeMessageId: replyId,
    );
    expect(
      history.map((message) => message.content).join('\n'),
      contains('刚才又想起你说不想长大'),
    );
  });
}

Future<Task> _waitForTaskStatus(
  AppDatabase db,
  String taskId,
  String status,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final task = await (db.select(db.tasks)
          ..where((table) => table.id.equals(taskId)))
        .getSingle();
    if (task.status == status) return task;
    if (task.status == 'failed') {
      fail('Task $taskId failed: ${task.error}');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  final task = await (db.select(db.tasks)
        ..where((table) => table.id.equals(taskId)))
      .getSingle();
  throw TimeoutException(
    'Task $taskId did not reach $status; status=${task.status}, '
    'error=${task.error}',
  );
}
