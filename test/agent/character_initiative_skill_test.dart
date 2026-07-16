import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/character_agent/character_initiative_skill.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:memex/domain/models/character_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  late CharacterModel character;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('memex_initiative_skill_');
    await FileSystemService.init(tempRoot.path);
    character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她珍惜平常的来往，不把小事说得很重。',
      enabled: true,
    );
    await CharacterWorkspaceService().ensureInitialized('user-1', character);
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('offers memory retrieval and two continuous initiative choices', () {
    final skill = CharacterInitiativeSkill(
      character: character,
      userId: 'user-1',
      context: CharacterInitiativeContext(
        sourceEventId: 'event-1',
        now: DateTime.parse('2026-07-13T21:00:00+08:00'),
      ),
      workspaceService: CharacterWorkspaceService(),
      onDecision: (_) {},
    );
    final names = skill.tools!.map((tool) => tool.name).toSet();

    expect(names, containsAll(['Glob', 'Grep', 'Read', 'Remember']));
    expect(names, containsAll(['Speak', 'SleepUntil']));
    expect(names, isNot(contains('ThinkLater')));
    expect(names, isNot(contains('StayQuiet')));
    expect(names, isNot(contains('SendActionMessage')));
    expect(names, isNot(contains('SaveComment')));
    expect(
        skill.systemPrompt, contains('original life record is deliberately'));
    expect(skill.systemPrompt, contains('calm, warm, lightly sweet'));
    expect(skill.systemPrompt, contains('never from a score or field'));
    expect(skill.systemPrompt, contains('never gates imposed by the system'));
    expect(skill.systemPrompt, contains('There is no system push'));
  });

  test('keeps future reflection available without a fixed retry count', () {
    final skill = CharacterInitiativeSkill(
      character: character,
      userId: 'user-1',
      context: CharacterInitiativeContext(
        sourceEventId: 'event-2',
        now: DateTime.parse('2026-07-13T21:00:00+08:00'),
      ),
      workspaceService: CharacterWorkspaceService(),
      onDecision: (_) {},
    );

    expect(
      skill.tools!.map((tool) => tool.name),
      contains('SleepUntil'),
    );
    expect(skill.systemPrompt, isNot(contains('Deferral is no longer')));
    expect(skill.systemPrompt, contains('not a permanent shutdown'));
  });

  test('Speak includes the character-selected next wake', () {
    final now = DateTime.parse('2026-07-13T21:00:00+08:00');
    CharacterInitiativeDecision? decision;
    final skill = CharacterInitiativeSkill(
      character: character,
      userId: 'user-1',
      context: CharacterInitiativeContext(
        sourceEventId: 'event-speak',
        now: now,
      ),
      workspaceService: CharacterWorkspaceService(),
      onDecision: (value) => decision = value,
    );
    final tool = skill.tools!.singleWhere((tool) => tool.name == 'Speak');

    Function.apply(tool.executable!, [
      [
        {'type': 'text', 'content': '想起你了。'},
        {'type': 'emoji', 'content': '🙂'},
      ],
      now.add(const Duration(hours: 5)).toIso8601String(),
      '晚上想再看看她有没有说话。',
    ]);

    expect(decision?.action, CharacterInitiativeAction.speak);
    expect(
      decision?.messages,
      [
        CharacterOutgoingMessage.text('想起你了。'),
        CharacterOutgoingMessage.emoji('🙂'),
      ],
    );
    expect(decision?.wakeAt, now.add(const Duration(hours: 5)));
  });

  test('Speak rejects textual emoji placeholders', () {
    final now = DateTime.parse('2026-07-13T21:00:00+08:00');
    final skill = CharacterInitiativeSkill(
      character: character,
      userId: 'user-1',
      context: CharacterInitiativeContext(
        sourceEventId: 'event-invalid-emoji',
        now: now,
      ),
      workspaceService: CharacterWorkspaceService(),
      onDecision: (_) {},
    );
    final tool = skill.tools!.singleWhere((tool) => tool.name == 'Speak');

    expect(
      () => Function.apply(tool.executable!, [
        [
          {'type': 'emoji', 'content': '[smile]'},
        ],
        now.add(const Duration(hours: 1)).toIso8601String(),
        '稍后再想想。',
      ]),
      throwsArgumentError,
    );
  });

  test('SleepUntil stays quiet now without ending future initiative', () {
    final now = DateTime.parse('2026-07-13T21:00:00+08:00');
    CharacterInitiativeDecision? decision;
    final skill = CharacterInitiativeSkill(
      character: character,
      userId: 'user-1',
      context: CharacterInitiativeContext(
        sourceEventId: 'event-sleep',
        now: now,
      ),
      workspaceService: CharacterWorkspaceService(),
      onDecision: (value) => decision = value,
    );
    final tool = skill.tools!.singleWhere((tool) => tool.name == 'SleepUntil');

    Function.apply(tool.executable!, [
      now.add(const Duration(days: 1)).toIso8601String(),
      '明天再自然地想想要不要找她。',
    ]);

    expect(decision?.action, CharacterInitiativeAction.sleepUntil);
    expect(decision?.messages, isEmpty);
    expect(decision?.wakeAt, now.add(const Duration(days: 1)));
  });

  test('can deliberately resolve an obsolete pending thought', () {
    final now = DateTime.parse('2026-07-13T21:00:00+08:00');
    final skill = CharacterInitiativeSkill(
      character: character,
      userId: 'user-1',
      context: CharacterInitiativeContext(
        sourceEventId: 'event-3',
        now: now,
        pendingThoughts: [
          CharacterPendingThought(
            id: 'thought-1',
            sourceEventId: 'older-event',
            reason: '本来想晚点问问她。',
            createdAt: now.subtract(const Duration(hours: 2)),
            wakeAt: now.add(const Duration(hours: 1)),
          ),
        ],
      ),
      workspaceService: CharacterWorkspaceService(),
      onDecision: (_) {},
    );

    expect(
      skill.tools!.map((tool) => tool.name),
      contains('ResolvePendingThought'),
    );
    expect(skill.systemPrompt, contains('newer moment'));
  });
}
