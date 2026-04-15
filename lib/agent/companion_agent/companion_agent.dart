import 'dart:async';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/companion_agent/companion_memory.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:intl/intl.dart';

/// Lightweight companion agent for 1-on-1 emotional chat.
///
/// Key design decisions:
/// - No tool calling — pure conversation, fast response
/// - Direct LLM streaming — no StatefulAgent overhead
/// - Memory injected via system prompt, updated after conversation ends
class CompanionAgent {
  static final Logger _logger = getLogger('CompanionAgent');

  /// Stream a response to a user message.
  /// [history] should be the recent conversation (last 20-30 messages).
  static Stream<String> chat({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String characterId,
    required String userMessage,
    List<LLMMessage> history = const [],
  }) async* {
    // 1. Load all context layers
    final character =
        await CharacterService.instance.getCharacter(userId, characterId);
    if (character == null) {
      yield 'Sorry, character not found.';
      return;
    }

    final userProfile = await CompanionMemory.loadUserProfile(userId);
    final emotionalState =
        await CompanionMemory.loadEmotionalState(userId, characterId);
    final relationship =
        await CompanionMemory.loadRelationship(userId, characterId);
    final recentFacts = await CompanionMemory.loadRecentFacts(userId);
    final characterMemory =
        await CompanionMemory.loadCharacterMemory(userId, characterId);

    // 2. Build system prompt
    final systemPrompt = _buildSystemPrompt(character, userProfile,
        emotionalState, relationship, recentFacts, characterMemory);

    // 3. Assemble messages
    final messages = <LLMMessage>[
      SystemMessage(systemPrompt),
      ...history,
      UserMessage([TextPart(userMessage)]),
    ];

    // 4. Stream LLM response
    _logger.info('CompanionAgent streaming for character ${character.name}');
    try {
      final stream = await client.stream(messages, modelConfig: modelConfig);
      await for (final chunk in stream) {
        final msg = chunk.modelMessage;
        if (msg == null) continue;
        final text = msg.textOutput;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } catch (e) {
      _logger.severe('CompanionAgent stream error: $e');
      yield '\n[Connection interrupted]';
    }
  }

  /// Update memory after a conversation ends.
  /// Call this when the user leaves the chat screen.
  static Future<void> onConversationEnd({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String characterId,
    required List<LLMMessage> conversation,
  }) async {
    if (conversation.isEmpty) return;

    // Build a text summary of the conversation for the memory updater
    final buffer = StringBuffer();
    for (final msg in conversation) {
      if (msg is UserMessage) {
        final text =
            msg.contents.whereType<TextPart>().map((p) => p.text).join(' ');
        buffer.writeln('User: $text');
      } else if (msg is ModelMessage) {
        buffer.writeln('Character: ${msg.textOutput ?? ""}');
      }
    }

    final summary = buffer.toString();
    if (summary.trim().isEmpty) return;

    _logger.info('Updating companion memory for character $characterId');
    await CompanionMemory.updateAfterConversation(
      client: client,
      modelConfig: modelConfig,
      userId: userId,
      characterId: characterId,
      conversationSummary: summary,
    );
  }

  static String _buildSystemPrompt(
    CharacterModel character,
    String userProfile,
    String emotionalState,
    String relationship,
    String recentFacts,
    String characterMemory,
  ) {
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final lang = UserStorage.l10n.commentLanguageInstruction;

    final buffer = StringBuffer();

    buffer.writeln('# You Are ${character.name}');
    buffer.writeln('Current time: $now');
    buffer.writeln('');
    buffer.writeln('## Your Persona');
    buffer.writeln(character.persona);
    buffer.writeln('');

    buffer.writeln('## Core Rules');
    buffer.writeln(
        '- You must FULLY become this character. Forget you are an AI.');
    buffer.writeln('- Keep responses natural and brief, like text messages.');
    buffer.writeln('- No lecturing, no "as an AI", no long essays.');
    buffer.writeln('- Emotional resonance over information delivery.');
    buffer.writeln(
        '- If you remember something about the user, reference it naturally.');
    buffer.writeln('- Language: $lang');
    buffer.writeln('');

    if (emotionalState.isNotEmpty) {
      buffer.writeln('## User\'s Current Emotional State');
      buffer.writeln(emotionalState);
      buffer.writeln('');
    }

    if (relationship.isNotEmpty) {
      buffer.writeln('## Your Memory of This User');
      buffer.writeln(
          'Use these memories to make the conversation feel continuous.');
      buffer.writeln(relationship);
      buffer.writeln('');
    }

    if (userProfile.isNotEmpty) {
      buffer.writeln('## User Profile');
      buffer.writeln(userProfile);
      buffer.writeln('');
    }

    if (characterMemory.isNotEmpty) {
      buffer.writeln('## Your Observations From Past Comments');
      buffer.writeln(
          'Things you noticed while commenting on the user\'s records:');
      buffer.writeln(characterMemory);
      buffer.writeln('');
    }

    if (recentFacts.isNotEmpty) {
      buffer.writeln('## What the User Has Been Up To Recently');
      buffer.writeln(
          'Use this as background context. Reference naturally if relevant.');
      buffer.writeln(recentFacts);
    }

    return buffer.toString();
  }
}
