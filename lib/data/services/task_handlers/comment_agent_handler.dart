import 'dart:math';

import 'package:logging/logging.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/repositories/post_comment.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';

final _logger = Logger('CommentAgentHandler');

Future<void> handleCommentAgentImpl(
    String userId, Map<String, dynamic> payload, TaskContext context) async {
  // Stage 4: Comment Agent (Selection Phase)
  final factId = payload['fact_id'] as String;
  final combinedText = payload['combined_text'] as String;

  _logger
      .info("Running Comment Agent selection for fact $factId, user $userId");

  try {
    // Skip if LLM is not configured.
    final llmConfig = await UserStorage.getAgentLLMConfig(
      AgentDefinitions.commentAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    if (!llmConfig.isValid) {
      _logger.info('No LLM configured — skipping comment agent for $factId');
      return;
    }

    // Check if asset analysis failed and input is media-only
    await failIfAssetAnalysisFailed(
      bizId: context.bizId,
      combinedText: combinedText,
    );

    // 1. Character Selection
    // If character_id is explicitly provided in payload, use it.
    // Otherwise, select one.
    String? selectedCharId = payload['character_id'] as String?;

    if (selectedCharId == null) {
      final characters =
          await CharacterService.instance.getAllCharacters(userId);
      final enabledCharacters = characters.where((c) => c.enabled).toList();

      if (enabledCharacters.isEmpty) {
        _logger.info("No enabled characters, skipping comment agent");
        if (characters.isNotEmpty) {
          _logger.warning("No ENABLED characters. Skipping.");
          return;
        }
        return;
      }

      // Deterministic random selection
      final seed = factId.hashCode;
      final rng = Random(seed);
      final selectedChar =
          enabledCharacters[rng.nextInt(enabledCharacters.length)];
      selectedCharId = selectedChar.id;
      _logger.info(
          "Selected character ${selectedChar.name} ($selectedCharId) for comment");
    }

    // 2. Process (Async / Await here since we are in a worker)
    await processAICommentReply(
      cardId: factId,
      userId: userId,
      userContent: Prompts.commentAgentInitialCommentPrompt,
      characterId: selectedCharId,
      rawInputContent: combinedText,
    );
  } catch (e, stack) {
    _logger.severe("CommentAgentHandler failed: $e", e, stack);
    rethrowIfNonRetryable(e);
  }
}

/// Handler for process_ai_reply task
Future<void> handleProcessAiReplyImpl(
    String userId, Map<String, dynamic> payload, TaskContext context) async {
  final cardId = payload['card_id'] as String;
  final content = payload['content'] as String;
  final commentId = payload['comment_id'] as String?;

  _logger.info(
      'HandleProcessAiReply: Processing AI reply for card $cardId, user $userId');

  await processAICommentReply(
    cardId: cardId,
    userId: userId,
    userContent: content,
    userCommentId: commentId,
    withMemoryManagement: true,
  );
}
