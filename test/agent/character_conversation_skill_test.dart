import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/character_agent/character_conversation_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_conversation.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test('conversation skill treats several bubbles as one agent decision',
      () async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    final tempRoot =
        await Directory.systemTemp.createTemp('conversation_skill_');
    await FileSystemService.init(tempRoot.path);
    addTearDown(() => tempRoot.delete(recursive: true));
    final character = CharacterModel(
      id: 'yaoyao',
      name: '瑶瑶',
      tags: const [],
      persona: '她说话平常、温柔。',
      enabled: true,
    );
    final now = DateTime.parse('2026-07-15T10:00:00+08:00');
    CharacterConversationDecision? decision;
    final skill = CharacterConversationSkill(
      character: character,
      userId: 'user-1',
      userName: 'user-1',
      context: CharacterConversationContext(
        sourceEventId: 'private_chat:1',
        now: now,
        incomingMessages: [
          CharacterConversationTurn(
            content: '第一句',
            isFromCharacter: false,
            timestamp: now,
          ),
          CharacterConversationTurn(
            content: '第二句',
            isFromCharacter: false,
            timestamp: now,
          ),
        ],
      ),
      onDecision: (value) => decision = value,
    );

    expect(
      skill.tools!.map((tool) => tool.name),
      containsAll(['Glob', 'Grep', 'Read', 'Remember']),
    );
    expect(
      skill.tools!.map((tool) => tool.name),
      containsAll(['Speak', 'ThinkLater', 'StayQuiet']),
    );
    expect(skill.systemPrompt, contains('several bubbles'));
    expect(skill.systemPrompt, contains('never from a score'));
    expect(skill.systemPrompt, contains('New messages can cross'));
    expect(skill.systemPrompt, contains('exact text bubble strings'));
    expect(skill.systemPrompt, contains('Speak.emoji'));
    final speak = skill.tools!.singleWhere((tool) => tool.name == 'Speak');
    final properties = speak.parameters['properties'] as Map;
    expect((properties['messages'] as Map)['items'], {'type': 'string'});
    expect(
      (properties['emoji'] as Map)['enum'],
      containsAll(['warm_smile', 'heart', 'wave']),
    );
    expect(speak.parameters['required'], isNull);

    Function.apply(speak.executable!, [
      ['晚安。'],
      'heart',
    ]);
    expect(
      decision?.messages,
      [
        CharacterOutgoingMessage.text('晚安。'),
        CharacterOutgoingMessage.emoji('❤️'),
      ],
    );
  });
}
