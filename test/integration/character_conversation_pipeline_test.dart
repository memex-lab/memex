import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_conversation_service.dart';
import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/task_handlers/character_conversation_handler.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_conversation.dart';
import 'package:memex/domain/models/character_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('consecutive sends become one durable multi-bubble conversation turn',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    final executor = LocalTaskExecutor.forTesting(db: db);
    final chatService = PersonaChatService.forTesting(db);
    final tempRoot =
        await Directory.systemTemp.createTemp('conversation_pipeline_');
    final workspace = CharacterWorkspaceService(
      fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
    );
    final eventBus = EventBusService.instance;
    await eventBus.connect();
    addTearDown(() async {
      await eventBus.disconnect();
      await executor.stop();
      await db.close();
      await tempRoot.delete(recursive: true);
    });

    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她说话平常、温柔。',
      enabled: true,
    );
    var decisionCount = 0;
    final handler = CharacterConversationTaskHandler(
      chatService: chatService,
      workspaceService: workspace,
      taskExecutor: executor,
      eventBus: eventBus,
      executionCoordinator: CharacterExecutionCoordinator(),
      characterLoader: (_, __) async => character,
      decider: ({
        required userId,
        required character,
        required context,
        CharacterWorkspaceService? workspaceService,
      }) async {
        decisionCount += 1;
        expect(
          context.incomingMessages.map((message) => message.content),
          ['我刚下楼', '外面有点热', '突然想喝冰的'],
        );
        return CharacterConversationDecision.speak([
          '是有点热。',
          '那就买一杯，慢慢喝。',
        ]);
      },
    );
    executor.registerHandler(
      CharacterConversationService.taskType,
      handler.call,
    );
    final conversation = CharacterConversationService.forTesting(
      chatService: chatService,
      taskExecutor: executor,
      clock: () => DateTime.now().subtract(const Duration(seconds: 1)),
      settleDelay: Duration.zero,
    );

    for (final text in ['我刚下楼', '外面有点热', '突然想喝冰的']) {
      await conversation.sendUserMessage(
        userId: 'user-1',
        characterId: character.id,
        content: text,
      );
    }
    final drain = await executor.drainAvailableTasks(
      userId: 'user-1',
      maxDuration: const Duration(seconds: 5),
      pollInterval: const Duration(milliseconds: 20),
      stopWhenDone: true,
    );

    expect(drain.timedOut, isFalse);
    expect(decisionCount, 1);
    final messages = await chatService.getMessages(character.id);
    expect(messages.reversed.map((message) => message.content), [
      '我刚下楼',
      '外面有点热',
      '突然想喝冰的',
      '是有点热。',
      '那就买一杯，慢慢喝。',
    ]);
    final userMessageIds = messages
        .where((message) => !message.isFromCharacter)
        .map((message) => message.id);
    final newestUserMessageId = userMessageIds.reduce(
      (current, next) => current > next ? current : next,
    );
    expect(
      await chatService.getReplyCursor(character.id),
      newestUserMessageId,
    );

    final tasks = await (db.select(db.tasks)
          ..where((task) =>
              task.type.equals(CharacterConversationService.taskType)))
        .get();
    expect(tasks, hasLength(1));
    expect(tasks.single.status, 'completed');
  });
}
