import 'dart:async';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter/foundation.dart';
import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/skills/companion_agent/companion_agent_skill.dart';
import 'package:memex/agent/state_util.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/db/app_database.dart';
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
    List<PersonaChatMessage>? canonicalHistory,
  }) async {
    final character =
        await CharacterService.instance.getCharacter(userId, characterId);
    if (character == null) {
      return null;
    }
    await CharacterWorkspaceService.instance.ensureInitialized(
      userId,
      character,
    );

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
    if (canonicalHistory != null) {
      replaceHistoryWithPersonaChat(
        state,
        canonicalHistory,
        model: modelConfig.model,
      );
    }

    final userName = (await UserStorage.getUserId()) ?? userId;

    final skill = CompanionAgentSkill(
      character: character,
      userId: userId,
      userName: userName,
      forceActivate: true,
    );

    // Remove broad legacy context from persisted sessions. Long-term context
    // now comes from the character's own progressive workspace tools.
    state.systemReminders.remove('character_world');
    state.systemReminders.remove('character_timeline');
    state.systemReminders.remove('user_knowledge_cards');
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

    return StatefulAgent(
      name: 'companion_agent',
      client: client,
      modelConfig: modelConfig,
      state: state,
      skills: [skill],
      disableSubAgents: true,
      controller: controller,
      withGeneralPrinciples: false,
      planMode: PlanMode.none,
      autoSaveStateFunc: (s) async => saveAgentState(s),
      hooks: [
        createAgentPromptHookWithWorkingDirectory(
          userId,
          FileSystemService.instance.getCharacterWorkspacePath(
            userId,
            characterId,
          ),
        ),
      ],
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
    int? currentUserMessageId,
    PersonaChatService? chatService,
    bool debugErrorOutput = false,
  }) async* {
    final output = await CharacterExecutionCoordinator.instance.run<String>(
      userId: userId,
      characterId: characterId,
      action: () async {
        List<PersonaChatMessage>? canonicalHistory;
        if (currentUserMessageId != null) {
          canonicalHistory = await (chatService ?? PersonaChatService.instance)
              .getMessagesBefore(
            characterId,
            beforeMessageId: currentUserMessageId,
          );
        }
        final agent = await _createAgent(
          client: client,
          modelConfig: modelConfig,
          userId: userId,
          characterId: characterId,
          canonicalHistory: canonicalHistory,
        );
        if (agent == null) {
          return 'Sorry, character not found.';
        }
        final timedUserMessage = userMessageTime == null
            ? userMessage
            : '${buildMessageTimePrefix(userMessageTime)}$userMessage';
        _logger.info('CompanionAgent run for character $characterId');
        try {
          final input = [
            UserMessage([TextPart(timedUserMessage)])
          ];
          final resultHistory = await agent.run(input, useStream: false);
          if (resultHistory.isNotEmpty && resultHistory.last is ModelMessage) {
            return (resultHistory.last as ModelMessage).textOutput ?? '';
          }
          return '';
        } catch (e) {
          _logger.severe('CompanionAgent run error: $e');
          return debugErrorOutput
              ? '\n[Connection interrupted: $e]'
              : '\n[Connection interrupted]';
        }
      },
    );
    if (output.isNotEmpty) {
      yield output;
    }
  }

  /// Rebuilds transient agent history from the chat database, which is the
  /// canonical short-term conversation store. Durable understanding remains
  /// in the character workspace.
  @visibleForTesting
  static void replaceHistoryWithPersonaChat(
    AgentState state,
    List<PersonaChatMessage> newestFirst, {
    required String model,
  }) {
    final messages = <LLMMessage>[];
    for (final message in newestFirst.reversed) {
      final text = '${buildMessageTimePrefix(message.timestamp)}'
          '${message.content}';
      if (message.isFromCharacter) {
        messages.add(ModelMessage(model: model, textOutput: text));
      } else {
        messages.add(UserMessage([TextPart(text)]));
      }
    }
    state.history.messages
      ..clear()
      ..addAll(messages);
    state.metadata['persona_chat_history_source'] = 'database';
  }
}
