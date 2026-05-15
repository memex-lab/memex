import 'dart:io';

import 'package:test/test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/agent/companion_agent/companion_agent.dart';
import 'package:memex/agent/comment_agent/comment_agent.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/agent_activity_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('Live Agent Evaluation', () {
    test('companion + comment agent live run with env config', () async {
      final baseUrl = Platform.environment['OPENAI_BASE_URL'] ?? '';
      final apiKey = Platform.environment['OPENAI_API_KEY'] ?? '';
      if (baseUrl.isEmpty || apiKey.isEmpty) {
        fail('OPENAI_BASE_URL / OPENAI_API_KEY not set in test process env');
      }

      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();

      const userId = 'agent_eval_user';
      await UserStorage.saveUser(userId);
      AgentActivityService.setInstance(LocalAgentActivityService.instance);

      final llmConfig = LLMConfig(
        key: LLMConfig.defaultClientKey,
        type: LLMConfig.typeChatCompletion,
        modelId: 'anthropic/claude-opus-4.7',
        apiKey: apiKey,
        baseUrl: baseUrl,
        maxTokens: 4096,
        extra: const {},
      );
      await UserStorage.saveLLMConfigs([llmConfig]);

      final tempRoot =
          await Directory.systemTemp.createTemp('memex_agent_eval_');
      await FileSystemService.init(tempRoot.path);

      final fs = FileSystemService.instance;
      final chars = CharacterService.instance;

      final character = await chars.createCharacter(
        userId: userId,
        characterData: {
          'name': 'Luna',
          'tags': ['companion', 'warm', 'direct'],
          'persona': '''
## Identity
You are Luna, a close friend companion.

## Style
Natural, concise, empathetic. Avoid lecturing.
''',
          'enabled': true,
        },
      );

      const factId = '2026/05/08.md#ts_1';
      final card = CardData(
        factId: factId,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        status: 'completed',
        tags: const ['mood', 'work'],
        uiConfigs: const [
          UiConfig(
            templateId: 'classic_card',
            data: {'text': 'Work stress today'},
          )
        ],
      );
      final wrote = await fs.safeWriteCardFile(userId, factId, card);
      expect(wrote, isTrue);

      // Seed cross-scene memory directly through unified timeline.
      await CharacterMemoryService.instance.appendTimelineEvent(
        userId: userId,
        characterId: character.id,
        scene: CharacterMemoryScene.chat,
        type: CharacterMemoryEventType.userChatMessage,
        content: 'I do not want long advice. Just listen and keep it short.',
      );
      await CharacterMemoryService.instance.appendTimelineEvent(
        userId: userId,
        characterId: character.id,
        scene: CharacterMemoryScene.chat,
        type: CharacterMemoryEventType.characterChatMessage,
        content: 'Got it. I will keep responses short and stay with you.',
      );
      await CharacterMemoryService.instance.writeMemoryEntry(
        userId: userId,
        characterId: character.id,
        label: 'response_style',
        content: 'User prefers short support instead of long advice.',
        salience: 0.9,
      );

      final chatResources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.companionAgent,
        defaultClientKey: LLMConfig.defaultClientKey,
      );

      // Scenario A: companion emotional response quality.
      final companionChunks = <String>[];
      await for (final chunk in CompanionAgent.chat(
        client: chatResources.client,
        modelConfig: chatResources.modelConfig,
        userId: userId,
        characterId: character.id,
        userMessage: 'I am overwhelmed and tired tonight.',
        debugErrorOutput: true,
      )) {
        companionChunks.add(chunk);
      }
      final companionText = companionChunks.join('').trim();
      expect(companionText, isNotEmpty);
      expect(companionText, isNot(contains('Connection interrupted')));
      // Basic quality sanity checks (heuristic).
      expect(companionText.length < 1200, isTrue);

      final commentResources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.commentAgent,
        defaultClientKey: LLMConfig.defaultClientKey,
      );

      // Scenario B: comment generation with cross-scene continuity context.
      final commentRunOutput = await CommentAgent.runWithContent(
        'Please leave one warm, concise comment on this entry.',
        client: commentResources.client,
        modelConfig: commentResources.modelConfig,
        userId: userId,
        factId: factId,
        characterId: character.id,
        rawInputContent:
            'Today I had back-to-back meetings and felt mentally drained.',
        withMemoryManagement: true,
      );

      final updatedCard = await fs.readCardFile(userId, factId);
      expect(updatedCard, isNotNull);
      final comments = updatedCard!.comments.where((c) => c.isAi).toList();
      expect(comments.isNotEmpty, isTrue);
      final latestComment = comments.last.content;
      expect(latestComment.trim(), isNotEmpty);

      // Scenario C: comment should generally stay concise.
      expect(latestComment.length < 900, isTrue);
      expect(latestComment, isNot(contains('Connection interrupted')));

      final timeline = await CharacterMemoryService.instance.loadTimelineLines(
        userId,
        character.id,
      );
      expect(
          timeline
              .any((line) => line.contains('"event_type":"userChatMessage"')),
          isTrue);
      expect(
          timeline.any(
              (line) => line.contains('"event_type":"characterChatMessage"')),
          isTrue);
      expect(
          timeline.any((line) => line.contains('"event_type":"postObserved"')),
          isTrue);
      expect(
          timeline
              .any((line) => line.contains('"event_type":"characterComment"')),
          isTrue);

      // Print evaluation artifacts for manual review in test logs.
      // ignore: avoid_print
      print('=== Agent Eval: Companion Output ===\n$companionText\n');
      // ignore: avoid_print
      print('=== Agent Eval: Comment Tool Output ===\n$commentRunOutput\n');
      // ignore: avoid_print
      print('=== Agent Eval: Saved AI Comment ===\n$latestComment\n');
    }, timeout: const Timeout(Duration(minutes: 8)));
  });
}
