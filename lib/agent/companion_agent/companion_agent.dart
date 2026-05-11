import 'dart:async';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/context/character_context_assembler.dart';
import 'package:memex/agent/memory/character_context_compressor.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/skills/companion_agent/companion_agent_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/tavern_macro.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';

/// Companion chat agent implemented with StatefulAgent for architecture parity
/// with other scene agents (e.g., CommentAgent).
class CompanionAgent {
  static final Logger _logger = getLogger('CompanionAgent');

  static Future<StatefulAgent?> _createAgent({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String characterId,
    required String queryHint,
  }) async {
    final character =
        await CharacterService.instance.getCharacter(userId, characterId);
    if (character == null) {
      return null;
    }

    final sessionPrefix = 'companion_${userId}_$characterId';
    final resolved = await resolveCharacterSessionId(
      prefix: sessionPrefix,
      userId: userId,
    );
    final state = await loadOrCreateAgentState(resolved.sessionId, {
      'userId': userId,
      'scene': 'companion_chat',
      'characterId': characterId,
    });

    final ctx = await CharacterContextAssembler.build(
      userId: userId,
      character: character,
      sourceAgent: 'companion_agent',
      queryHint: queryHint,
      excludeTrailingUserMessage: true,
    );

    final userName = (await UserStorage.getUserId()) ?? userId;

    final skill = CompanionAgentSkill(
      character: character,
      userId: userId,
      userName: userName,
      userProfile: ctx.userProfile,
      characterMemories: ctx.characterMemories,
      forceActivate: true,
    );

    // World, timeline, and knowledge go into systemReminders (refreshable context).
    if (ctx.characterWorld.isNotEmpty) {
      state.systemReminders['character_world'] =
          '## Triggered Character World Entries\n${TavernMacro.resolve(ctx.characterWorld, userName: userName, charName: character.name)}';
    }
    // Combine compaction checkpoints + recent timeline into one reminder.
    {
      final parts = <String>[];
      if (ctx.checkpoints.isNotEmpty) {
        parts.add('## Compressed Interaction History\n${ctx.checkpoints}');
      }
      if (ctx.recentTimeline.isNotEmpty) {
        parts.add('## Recent Cross-Scene Interactions\n${ctx.recentTimeline}');
      }
      if (parts.isNotEmpty) {
        state.systemReminders['character_timeline'] = parts.join('\n\n');
      }
    }
    if (ctx.knowledgeCards.isNotEmpty) {
      state.systemReminders['user_knowledge_cards'] =
          '## User Knowledge Cards\n${ctx.knowledgeCards}';
    }
    if (character.postHistoryInstructions != null &&
        character.postHistoryInstructions!.trim().isNotEmpty) {
      state.systemReminders['post_history_instructions'] = TavernMacro.resolve(
        character.postHistoryInstructions!,
        userName: userName,
        charName: character.name,
      );
    }

    final controller = AgentController();
    addAgentLogger(controller);
    addAgentActivityCollector(controller);

    // User-level memory management (append_memories tool)
    final memoryManagement = await MemoryManagement.createDefault(
      userId: userId,
      sourceAgent: 'companion_agent',
    );
    final memoryManagementPrompt =
        await memoryManagement.buildMemoryManagementPrompt();

    return StatefulAgent(
      name: 'companion_agent',
      client: client,
      modelConfig: modelConfig,
      state: state,
      skills: [skill],
      tools: memoryManagement.buildMemoryManagementTools(),
      systemPrompts: [memoryManagementPrompt],
      disableSubAgents: true,
      controller: controller,
      withGeneralPrinciples: true,
      planMode: PlanMode.none,
      autoSaveStateFunc: (s) async => saveAgentState(s),
      systemCallback: createSystemCallback(userId),
    );
  }

  /// Stream a response to a user message.
  static Stream<String> chat({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String characterId,
    required String userMessage,
    DateTime? userMessageTime,
    bool debugErrorOutput = false,
  }) async* {
    final agent = await _createAgent(
      client: client,
      modelConfig: modelConfig,
      userId: userId,
      characterId: characterId,
      queryHint: userMessage,
    );
    if (agent == null) {
      yield 'Sorry, character not found.';
      return;
    }
    final timedUserMessage = userMessageTime == null
        ? userMessage
        : '${buildMessageTimePrefix(userMessageTime)}$userMessage';
    _logger.info('CompanionAgent run for character $characterId');
    try {
      final state = agent.state;
      final input = [
        UserMessage([TextPart(timedUserMessage)])
      ];
      final resultHistory = await agent.run(input, useStream: false);
      if (resultHistory.isNotEmpty && resultHistory.last is ModelMessage) {
        final text = (resultHistory.last as ModelMessage).textOutput ?? '';
        if (text.isNotEmpty) {
          yield text;
        }
      }
      // Post-run: check if compression is needed based on real token usage.
      if (state.usages.isNotEmpty) {
        final lastPromptTokens = state.usages.last.promptTokens;
        await CharacterContextCompressor.instance.compressIfNeeded(
          userId: userId,
          characterId: characterId,
          lastPromptTokens: lastPromptTokens,
        );
      }
    } catch (e) {
      _logger.severe('CompanionAgent run error: $e');
      if (debugErrorOutput) {
        yield '\n[Connection interrupted: $e]';
      } else {
        yield '\n[Connection interrupted]';
      }
    }
  }
}
