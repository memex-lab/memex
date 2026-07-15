import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/character_agent/character_initiative_skill.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_initiative.dart';
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

  test('offers memory retrieval and exactly three initiative choices', () {
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
    expect(
      names,
      containsAll(['Speak', 'ThinkLater', 'StayQuiet']),
    );
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
      contains('ThinkLater'),
    );
    expect(skill.systemPrompt, isNot(contains('Deferral is no longer')));
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
