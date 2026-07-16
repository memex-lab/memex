import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/character_initiative_handler.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:memex/domain/models/character_model.dart';

void main() {
  final now = DateTime.parse('2026-07-13T21:00:00+08:00');
  final character = CharacterModel(
    id: 'yaoyao',
    name: '瑶瑶',
    tags: const [],
    persona: '她喜欢平常、轻轻的来往。',
    enabled: true,
  );
  late Directory tempRoot;
  late CharacterWorkspaceService workspaceService;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('initiative_handler_');
    workspaceService = CharacterWorkspaceService(
      fileSystem: FileSystemService.detached(dataRoot: tempRoot.path),
    );
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('persists one unread contact episode selected by the character',
      () async {
    List<CharacterOutgoingMessage>? sentMessages;
    String? sentFactId;
    String? sentEpisodeId;
    DateTime? scheduledWakeAt;
    String? scheduledWakeReason;
    var clockReads = 0;
    final handler = CharacterInitiativeTaskHandler(
      workspaceService: workspaceService,
      primaryCompanionLoader: (_) async => character,
      clock: () => now.add(Duration(seconds: clockReads++)),
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
          characterComment: '哈哈，是的，每天都玩不够。',
        );
      },
      decider: ({
        required userId,
        required character,
        required context,
        CharacterWorkspaceService? workspaceService,
      }) async {
        expect(context.characterComment, '哈哈，是的，每天都玩不够。');
        return CharacterInitiativeDecision.speak(
          const [
            '你刚才那句，',
            '我过了一会儿还是觉得有点可爱。',
          ],
          wakeAt: now.add(const Duration(hours: 6)),
          reason: '晚上再想想她今天过得怎么样。',
        );
      },
      messageSender: ({
        required characterId,
        required messages,
        required timestamp,
        required contactEpisodeId,
        factId,
      }) async {
        expect(characterId, 'yaoyao');
        expect(timestamp, now.add(const Duration(seconds: 1)));
        sentMessages = messages;
        sentFactId = factId;
        sentEpisodeId = contactEpisodeId;
      },
      wakeScheduler: ({
        required userId,
        required wakeAt,
        required reason,
      }) async {
        scheduledWakeAt = wakeAt;
        scheduledWakeReason = reason;
      },
    );

    await handler.call(
      'user-1',
      {
        'source_event_id': 'event-1',
        'fact_id': '2026/07/13.md#ts_1',
      },
      TaskContext(taskId: 'task-1', taskType: 'character_initiative_task'),
    );

    expect(
      sentMessages?.map((message) => message.content),
      ['你刚才那句，', '我过了一会儿还是觉得有点可爱。'],
    );
    expect(sentFactId, '2026/07/13.md#ts_1');
    expect(sentEpisodeId, 'character_initiative:task-1');
    expect(scheduledWakeAt, now.add(const Duration(hours: 6)));
    expect(scheduledWakeReason, '晚上再想想她今天过得怎么样。');
  });

  test('lets the agent decide while the character owns the last chat turn',
      () async {
    var decided = false;
    var sent = false;
    final handler = CharacterInitiativeTaskHandler(
      workspaceService: workspaceService,
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
          now: now,
          recentPrivateChat: [
            CharacterConversationTurn(
              isFromCharacter: true,
              content: '你慢慢玩，我在呢。',
              timestamp: now.subtract(const Duration(hours: 1)),
            ),
          ],
        );
      },
      decider: ({
        required userId,
        required character,
        required context,
        CharacterWorkspaceService? workspaceService,
      }) async {
        decided = true;
        return CharacterInitiativeDecision.sleepUntil(
          wakeAt: now.add(const Duration(days: 1)),
          reason: '明天再看看她有没有想说话。',
        );
      },
      messageSender: ({
        required characterId,
        required messages,
        required timestamp,
        required contactEpisodeId,
        factId,
      }) async {
        sent = true;
      },
      wakeScheduler: ({
        required userId,
        required wakeAt,
        required reason,
      }) async {},
    );

    await handler.call(
      'user-1',
      {'source_event_id': 'event-2'},
      TaskContext(taskId: 'task-2', taskType: 'character_initiative_task'),
    );

    expect(decided, isTrue);
    expect(sent, isFalse);
  });

  test('turns SleepUntil into an agent-chosen persistent wake', () async {
    DateTime? capturedScheduledFor;
    String? capturedReason;
    final handler = CharacterInitiativeTaskHandler(
      workspaceService: workspaceService,
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
        return CharacterInitiativeDecision.sleepUntil(
          wakeAt: now.add(const Duration(days: 3, hours: 2)),
          reason: '等她忙完再说。',
        );
      },
      messageSender: ({
        required characterId,
        required messages,
        required timestamp,
        required contactEpisodeId,
        factId,
      }) async {},
      wakeScheduler: ({
        required userId,
        required wakeAt,
        required reason,
      }) async {
        capturedScheduledFor = wakeAt;
        capturedReason = reason;
      },
    );

    await handler.call(
      'user-1',
      {
        'source_event_id': 'event-3',
        'fact_id': 'fact-3',
      },
      TaskContext(taskId: 'task-3', taskType: 'character_initiative_task'),
    );

    expect(
      capturedScheduledFor,
      now.add(const Duration(days: 3, hours: 2)),
    );
    expect(capturedReason, '等她忙完再说。');
    expect(
      await workspaceService.loadPendingThoughts('user-1', 'yaoyao'),
      isEmpty,
    );
  });

  test('ignores stale schedules and resolves a revisited thought', () async {
    final thought = await workspaceService.rememberPendingThought(
      userId: 'user-1',
      characterId: character.id,
      sourceEventId: 'event-pending',
      reason: '晚点想问她今天是不是累了。',
      wakeAt: now,
      now: now.subtract(const Duration(hours: 1)),
    );
    var decisions = 0;
    final handler = CharacterInitiativeTaskHandler(
      workspaceService: workspaceService,
      primaryCompanionLoader: (_) async => character,
      clock: () => now,
      contextLoader: ({
        required userId,
        required character,
        required sourceEventId,
        required now,
        factId,
      }) async =>
          CharacterInitiativeContext(
        sourceEventId: sourceEventId,
        now: now,
      ),
      decider: ({
        required userId,
        required character,
        required context,
        CharacterWorkspaceService? workspaceService,
      }) async {
        decisions += 1;
        expect(context.resumedThought?.id, thought.id);
        expect(context.pendingThoughts.map((item) => item.id),
            contains(thought.id));
        return CharacterInitiativeDecision.sleepUntil(
          wakeAt: now.add(const Duration(days: 1)),
          reason: '她已经聊过了，这个念头可以放下。',
        );
      },
      messageSender: ({
        required characterId,
        required messages,
        required timestamp,
        required contactEpisodeId,
        factId,
      }) async {},
      wakeScheduler: ({
        required userId,
        required wakeAt,
        required reason,
      }) async {},
    );

    await handler.call(
      'user-1',
      {
        'pending_thought_id': thought.id,
        'pending_thought_wake_at':
            now.subtract(const Duration(minutes: 1)).toIso8601String(),
      },
      TaskContext(
        taskId: 'stale-task',
        taskType: 'character_initiative_task',
      ),
    );
    expect(decisions, 0);

    await handler.call(
      'user-1',
      {
        'pending_thought_id': thought.id,
        'pending_thought_wake_at': thought.wakeAt.toIso8601String(),
      },
      TaskContext(
        taskId: 'current-task',
        taskType: 'character_initiative_task',
      ),
    );

    expect(decisions, 1);
    expect(
      await workspaceService.loadPendingThoughts('user-1', 'yaoyao'),
      isEmpty,
    );
  });

  test('discards a proactive decision when direct chat changes mid-thought',
      () async {
    var sent = false;
    var scheduled = false;
    final handler = CharacterInitiativeTaskHandler(
      workspaceService: workspaceService,
      primaryCompanionLoader: (_) async => character,
      clock: () => now,
      latestMessageIdLoader: (_) async => 8,
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
          latestPrivateMessageId: 7,
        );
      },
      decider: ({
        required userId,
        required character,
        required context,
        CharacterWorkspaceService? workspaceService,
      }) async {
        return CharacterInitiativeDecision.speak(
          ['刚想找你。'],
          wakeAt: now.add(const Duration(hours: 3)),
          reason: '过一会儿再看看她有没有聊完。',
        );
      },
      messageSender: ({
        required characterId,
        required messages,
        required timestamp,
        required contactEpisodeId,
        factId,
      }) async {
        sent = true;
      },
      wakeScheduler: ({
        required userId,
        required wakeAt,
        required reason,
      }) async {
        scheduled = true;
      },
    );

    await handler.call(
      'user-1',
      {'source_event_id': 'event-race'},
      TaskContext(taskId: 'task-race', taskType: 'character_initiative_task'),
    );

    expect(sent, isFalse);
    expect(scheduled, isTrue);
  });
}
