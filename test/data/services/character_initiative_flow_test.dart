import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/task_handlers/character_initiative_handler.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initiative reaches chat persistence, unread state, and the UI event',
      () async {
    final tempRoot =
        await Directory.systemTemp.createTemp('initiative_flow_workspace_');
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final chatService = PersonaChatService.forTesting(
      storage: PersonaChatConversationStorage(
        fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
      ),
      userId: 'user-1',
    );
    final eventBus = EventBusService.instance;
    await eventBus.connect();
    final eventReceived = Completer<PersonaChatMessageAddedMessage>();
    void eventHandler(EventBusMessage message) {
      if (message is PersonaChatMessageAddedMessage &&
          !eventReceived.isCompleted) {
        eventReceived.complete(message);
      }
    }

    eventBus.addHandler(
      EventBusMessageType.personaChatMessageAdded,
      eventHandler,
    );
    addTearDown(() async {
      eventBus.removeHandler(
        EventBusMessageType.personaChatMessageAdded,
        eventHandler,
      );
      await eventBus.disconnect();
      await db.close();
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final now = DateTime.parse('2026-07-13T21:00:00+08:00');
    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她会在想说话时自然地来找用户。',
      enabled: true,
    );
    final handler = CharacterInitiativeTaskHandler(
      workspaceService: CharacterWorkspaceService(
        fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
      ),
      chatService: chatService,
      eventBus: eventBus,
      primaryCompanionLoader: (_) async => character,
      clock: () => now,
      contextLoader: ({
        required userId,
        required character,
        required sourceEventId,
        required now,
        factId,
      }) async {
        return CharacterInitiativeContext(
          sourceEventId: sourceEventId,
          factId: factId,
          now: now,
        );
      },
      decider: ({
        required userId,
        required character,
        required context,
        CharacterWorkspaceService? workspaceService,
      }) async {
        return CharacterInitiativeDecision.speak(
          const [
            '今天是不是又觉得没玩够。',
            '我刚才又想起你那句话了。',
          ],
          wakeAt: now.add(const Duration(hours: 8)),
          reason: '晚一点再想想她今天过得怎么样。',
        );
      },
      wakeScheduler: ({
        required userId,
        required wakeAt,
        required reason,
      }) async {},
    );

    await handler.call(
      'user-1',
      {
        'source_event_id': 'event-flow-1',
        'fact_id': 'fact-flow-1',
      },
      TaskContext(
        taskId: 'task-flow-1',
        taskType: 'character_initiative_task',
      ),
    );

    // Persistent task retries use the same source turn and must be idempotent.
    await handler.call(
      'user-1',
      {
        'source_event_id': 'event-flow-1',
        'fact_id': 'fact-flow-1',
      },
      TaskContext(
        taskId: 'task-flow-1',
        taskType: 'character_initiative_task',
      ),
    );

    final messages = await chatService.getMessages('yaoyao');
    expect(messages, hasLength(2));
    expect(
      messages.map((message) => message.content).toList(),
      ['我刚才又想起你那句话了。', '今天是不是又觉得没玩够。'],
    );
    expect(
        messages.every((message) => message.factId == 'fact-flow-1'), isTrue);
    expect(messages.every((message) => message.isFromCharacter), isTrue);
    expect(messages.every((message) => !message.isRead), isTrue);
    expect(
      messages.every(
        (message) =>
            message.origin == PersonaChatMessageOrigin.initiative &&
            message.contactEpisodeId == 'character_initiative:event-flow-1',
      ),
      isTrue,
    );
    expect(await chatService.getUnreadCount('yaoyao'), 2);
    expect((await eventReceived.future).characterId, 'yaoyao');
  });
}
