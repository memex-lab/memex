import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_conversation_service.dart';
import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/task_handlers/character_conversation_handler.dart';
import 'package:memex/data/services/task_handlers/character_initiative_handler.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_conversation.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:memex/domain/models/character_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('consecutive sends become one durable multi-bubble conversation turn',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    final executor = LocalTaskExecutor.forTesting(db: db);
    final tempRoot =
        await Directory.systemTemp.createTemp('conversation_pipeline_');
    final chatService = PersonaChatService.forTesting(
      storage: PersonaChatConversationStorage(
        fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
      ),
      userId: 'user-1',
    );
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

  test('initiative yields one pending user turn to the direct reply task',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    final executor = LocalTaskExecutor.forTesting(db: db);
    final tempRoot =
        await Directory.systemTemp.createTemp('conversation_ownership_');
    final chatService = PersonaChatService.forTesting(
      storage: PersonaChatConversationStorage(
        fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
      ),
      userId: 'user-1',
    );
    final workspace = CharacterWorkspaceService(
      fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
    );
    final eventBus = EventBusService.instance;
    final coordinator = CharacterExecutionCoordinator();
    await eventBus.connect();
    addTearDown(() async {
      await eventBus.disconnect();
      await executor.stop();
      await db.close();
      await tempRoot.delete(recursive: true);
    });

    final now = DateTime.parse('2026-07-25T16:25:00+08:00');
    final character = CharacterModel(
      id: 'auntie',
      name: '热心长辈',
      tags: const [],
      persona: '她关心用户，也尊重当前对话的节奏。',
      enabled: true,
    );
    final userMessageId = await chatService.addUserMessage(
      character.id,
      '订了个青年旅馆',
      timestamp: now,
    );

    final deferralStarted = Completer<void>();
    final releaseDeferral = Completer<void>();
    var conversationFinished = false;
    var conversationDecisions = 0;
    var initiativeDecisions = 0;
    var initiativeMessages = 0;
    final initiativeWakeTimes = <DateTime>[];
    final initiativeRetryTimes = <DateTime>[];
    final initiativeRetryPayloads = <Map<String, dynamic>>[];

    final initiativeHandler = CharacterInitiativeTaskHandler(
      workspaceService: workspace,
      chatService: chatService,
      executionCoordinator: coordinator,
      primaryCompanionLoader: (_) async => character,
      clock: () => now,
      conversationReplyScheduler: ({
        required userId,
        required characterId,
      }) async {
        expect(userId, 'user-1');
        expect(characterId, character.id);
        if (!deferralStarted.isCompleted) deferralStarted.complete();
        await releaseDeferral.future;
      },
      initiativeRetryScheduler: ({
        required userId,
        required characterId,
        required payload,
        required retryAt,
        required reason,
      }) async {
        initiativeRetryTimes.add(retryAt);
        initiativeRetryPayloads.add(Map<String, dynamic>.from(payload));
      },
      contextLoader: ({
        required userId,
        required character,
        required sourceEventId,
        required now,
        factId,
      }) async {
        return CharacterInitiativeContext(
          sourceEventId: sourceEventId,
          now: now,
        );
      },
      decider: ({
        required userId,
        required character,
        required context,
        CharacterWorkspaceService? workspaceService,
      }) async {
        initiativeDecisions += 1;
        if (!conversationFinished) {
          return CharacterInitiativeDecision.speak(
            ['这会成为针对同一条用户消息的重复回复。'],
            wakeAt: now.add(const Duration(hours: 1)),
            reason: '稍后再看看。',
          );
        }
        return CharacterInitiativeDecision.sleepUntil(
          wakeAt: now.add(const Duration(hours: 1)),
          reason: '刚聊完，先让对话自然停一停。',
        );
      },
      messageSender: ({
        required characterId,
        required messages,
        required timestamp,
        required contactEpisodeId,
        required expectedGeneration,
        factId,
      }) async {
        initiativeMessages += messages.length;
        await chatService.addCharacterMessages(
          characterId,
          messages,
          timestamp: timestamp,
          origin: PersonaChatMessageOrigin.initiative,
          contactEpisodeId: contactEpisodeId,
        );
        return true;
      },
      wakeScheduler: ({
        required userId,
        required wakeAt,
        required reason,
      }) async {
        initiativeWakeTimes.add(wakeAt);
      },
    );
    final conversationHandler = CharacterConversationTaskHandler(
      chatService: chatService,
      workspaceService: workspace,
      taskExecutor: executor,
      eventBus: eventBus,
      executionCoordinator: coordinator,
      characterLoader: (_, __) async => character,
      clock: () => now,
      decider: ({
        required userId,
        required character,
        required context,
        CharacterWorkspaceService? workspaceService,
      }) async {
        conversationDecisions += 1;
        expect(
          context.incomingMessages.map((message) => message.content),
          ['订了个青年旅馆'],
        );
        conversationFinished = true;
        return CharacterConversationDecision.speak([
          '订了青旅呀？这是准备去哪儿玩？',
        ]);
      },
    );

    final initiativeFuture = initiativeHandler.call(
      'user-1',
      {'source_event_id': 'initiative-due'},
      TaskContext(
        taskId: 'initiative-task',
        taskType: 'character_initiative_task',
      ),
    );
    await deferralStarted.future;
    final conversationFuture = conversationHandler.call(
      'user-1',
      {'character_id': character.id},
      TaskContext(
        taskId: 'conversation-task',
        taskType: CharacterConversationService.taskType,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(initiativeDecisions, 0);
    expect(conversationDecisions, 0);
    releaseDeferral.complete();
    await Future.wait([initiativeFuture, conversationFuture]);

    expect(conversationDecisions, 1);
    expect(initiativeDecisions, 0);
    expect(initiativeMessages, 0);
    expect(
      await chatService.getReplyCursor(character.id),
      userMessageId,
    );
    expect(
      await chatService.getPendingUserMessages(character.id),
      isEmpty,
    );

    // Once Conversation owns and completes the user turn, Initiative may
    // evaluate again, but it sees a settled chat rather than answering it.
    await initiativeHandler.call(
      'user-1',
      {'source_event_id': 'initiative-retry'},
      TaskContext(
        taskId: 'initiative-retry-task',
        taskType: 'character_initiative_task',
      ),
    );

    expect(initiativeDecisions, 1);
    expect(initiativeMessages, 0);
    expect(initiativeRetryTimes, [now.add(const Duration(seconds: 2))]);
    expect(
      initiativeRetryPayloads.single,
      {'source_event_id': 'initiative-due'},
    );
    expect(initiativeWakeTimes, [now.add(const Duration(hours: 1))]);
    final messages = await chatService.getMessages(character.id);
    final characterMessages =
        messages.where((message) => message.isFromCharacter).toList();
    expect(characterMessages, hasLength(1));
    expect(
      characterMessages.single.origin,
      PersonaChatMessageOrigin.conversation,
    );
    expect(
      characterMessages.single.contactEpisodeId,
      'character_conversation:1-1',
    );
  });

  test('initiative commit cannot overtake a pending direct message', () async {
    final tempRoot =
        await Directory.systemTemp.createTemp('initiative_commit_');
    final chatService = PersonaChatService.forTesting(
      storage: PersonaChatConversationStorage(
        fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
      ),
      userId: 'user-1',
    );
    addTearDown(() => tempRoot.delete(recursive: true));
    final now = DateTime.parse('2026-07-25T16:25:00+08:00');
    final userMessageId = await chatService.addUserMessage(
      'auntie',
      '我又补充了一句',
      timestamp: now,
    );

    final committedWhilePending = await chatService.tryAddInitiativeMessages(
      'auntie',
      [CharacterOutgoingMessage.fromContent('这条不应该抢在回复前。')],
      timestamp: now,
      contactEpisodeId: 'initiative-race',
    );

    expect(committedWhilePending, isFalse);
    expect(
      (await chatService.getMessages('auntie'))
          .where((message) => message.isFromCharacter),
      isEmpty,
    );

    await chatService.advanceReplyCursor(
      characterId: 'auntie',
      consumedThroughMessageId: userMessageId,
    );
    final committedAfterConversation =
        await chatService.tryAddInitiativeMessages(
      'auntie',
      [CharacterOutgoingMessage.fromContent('现在才可以主动说。')],
      timestamp: now,
      contactEpisodeId: 'initiative-after-conversation',
    );

    expect(committedAfterConversation, isTrue);
    final characterMessage = (await chatService.getMessages('auntie'))
        .singleWhere((message) => message.isFromCharacter);
    expect(characterMessage.content, '现在才可以主动说。');
    expect(characterMessage.origin, PersonaChatMessageOrigin.initiative);
  });
}
