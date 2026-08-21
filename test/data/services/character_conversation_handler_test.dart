import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/task_handlers/character_conversation_handler.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_conversation.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/character_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('one conversation decision writes several character bubbles', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final executor = LocalTaskExecutor.forTesting(db: db);
    final tempRoot =
        await Directory.systemTemp.createTemp('conversation_handler_');
    final chatService = PersonaChatService.forTesting(
      storage: PersonaChatConversationStorage(
        fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
      ),
      userId: 'user-1',
    );
    final eventBus = EventBusService.instance;
    await eventBus.connect();
    final eventReceived = Completer<PersonaChatMessageAddedMessage>();
    void onEvent(EventBusMessage message) {
      if (message is PersonaChatMessageAddedMessage &&
          !eventReceived.isCompleted) {
        eventReceived.complete(message);
      }
    }

    eventBus.addHandler(EventBusMessageType.personaChatMessageAdded, onEvent);
    addTearDown(() async {
      eventBus.removeHandler(
        EventBusMessageType.personaChatMessageAdded,
        onEvent,
      );
      await eventBus.disconnect();
      await executor.stop();
      await db.close();
      await tempRoot.delete(recursive: true);
    });

    final now = DateTime.parse('2026-07-15T09:30:00+08:00');
    await chatService.addCharacterMessage(
      'yaoyao',
      '今天是不是又玩不够。',
      isRead: true,
      timestamp: now.subtract(const Duration(minutes: 2)),
      origin: PersonaChatMessageOrigin.initiative,
    );
    await chatService.addCharacterMessage(
      'yaoyao',
      '刚才突然又想起你那句话。',
      isRead: true,
      timestamp: now.subtract(const Duration(minutes: 1)),
      origin: PersonaChatMessageOrigin.initiative,
    );
    for (final text in ['你醒了吗', '我刚刚做了个梦', '有点好笑']) {
      await chatService.addUserMessage('yaoyao', text, timestamp: now);
    }
    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她说话平常、温柔。',
      enabled: true,
    );
    var decisions = 0;
    final handler = CharacterConversationTaskHandler(
      chatService: chatService,
      workspaceService: CharacterWorkspaceService(
        fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
      ),
      eventBus: eventBus,
      taskExecutor: executor,
      executionCoordinator: CharacterExecutionCoordinator(),
      characterLoader: (_, __) async => character,
      clock: () => now.add(const Duration(seconds: 5)),
      decider: ({
        required userId,
        required character,
        required context,
        CharacterWorkspaceService? workspaceService,
      }) async {
        decisions += 1;
        expect(
          context.incomingMessages.map((message) => message.content),
          ['你醒了吗', '我刚刚做了个梦', '有点好笑'],
        );
        expect(
          context.recentPrivateChat.map((message) => message.content),
          ['今天是不是又玩不够。', '刚才突然又想起你那句话。'],
        );
        expect(
          context.recentPrivateChat.every(
            (message) => message.origin == PersonaChatMessageOrigin.initiative,
          ),
          isTrue,
        );
        return CharacterConversationDecision.speak([
          '醒啦。',
          '🙂🙂',
        ]);
      },
    );

    await handler.call(
      'user-1',
      {'character_id': 'yaoyao'},
      TaskContext(taskId: 'reply-1', taskType: 'character_conversation_task'),
    );

    final characterRows = (await chatService.getMessages('yaoyao'))
        .where((message) =>
            message.isFromCharacter &&
            message.origin == PersonaChatMessageOrigin.conversation)
        .toList()
        .reversed;
    expect(characterRows.map((message) => message.content), [
      '醒啦。',
      '🙂🙂',
    ]);
    expect(characterRows.map((message) => message.messageType), [
      PersonaChatMessageTypes.text,
      PersonaChatMessageTypes.emoji,
    ]);
    expect(
      characterRows.map((message) => message.contactEpisodeId).toSet(),
      {'character_conversation:3-5'},
    );
    expect(await chatService.getReplyCursor('yaoyao'), 5);
    expect(await chatService.getUnreadCount('yaoyao'), 2);
    expect((await eventReceived.future).replyPending, isFalse);

    await handler.call(
      'user-1',
      {'character_id': 'yaoyao'},
      TaskContext(taskId: 'reply-2', taskType: 'character_conversation_task'),
    );
    expect(decisions, 1);
    expect(await chatService.getMessages('yaoyao'), hasLength(7));
  });
}
