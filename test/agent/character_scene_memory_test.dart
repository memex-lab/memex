import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/skills/comment_agent/comment_agent_skill.dart';
import 'package:memex/agent/skills/companion_agent/companion_agent_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  late CharacterModel character;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    tempRoot = await Directory.systemTemp.createTemp('memex_scene_memory_');
    await FileSystemService.init(tempRoot.path);
    character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她说话平常、温柔。',
      enabled: true,
    );
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('private chat uses the character workspace instead of legacy memory',
      () {
    final skill = CompanionAgentSkill(
      character: character,
      userId: 'user-1',
      userName: 'user-1',
      forceActivate: true,
    );
    final names = skill.tools!.map((tool) => tool.name).toSet();

    expect(names, containsAll(['Glob', 'Grep', 'Read', 'Remember']));
    expect(names, isNot(contains('MemoryRead')));
    expect(names, isNot(contains('MemoryWrite')));
    expect(names, isNot(contains('SendActionMessage')));
    expect(skill.systemPrompt, contains('search `/PKM`'));
    expect(skill.systemPrompt, isNot(contains('## User Profile')));
  });

  test('comments use the same character workspace and scene action tools', () {
    final skill = CommentAgentSkill(
      character: character,
      factId: 'fact-1',
      workingDirectory: tempRoot.path,
      userId: 'user-1',
      forceActivate: true,
    );
    final names = skill.tools!.map((tool) => tool.name).toSet();

    expect(names, containsAll(['Glob', 'Grep', 'Read', 'Remember']));
    expect(names, containsAll(['SaveComment', 'SkipComment']));
    expect(names, isNot(contains('MemoryRead')));
    expect(names, isNot(contains('MemoryWrite')));
    expect(skill.systemPrompt, contains('Your workspace is your durable'));
    expect(skill.systemPrompt, isNot(contains('## User Profile')));
  });
}
