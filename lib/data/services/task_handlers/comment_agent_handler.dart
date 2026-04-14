import 'package:logging/logging.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/repositories/post_comment.dart';
import 'package:memex/data/services/character_selection_service.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';

final _logger = Logger('CommentAgentHandler');

Future<void> handleCommentAgentImpl(
    String userId, Map<String, dynamic> payload, TaskContext context) async {
  // Stage 4: Comment Agent (Selection Phase)
  final factId = payload['fact_id'] as String;
  final combinedText = payload['combined_text'] as String;

  _logger
      .info("Running Comment Agent selection for fact $factId, user $userId");

  try {
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
      // Smart character selection based on content affinity
      final selectedChar = await CharacterSelectionService.selectCharacter(
        userId: userId,
        inputContent: combinedText,
        factId: factId,
      );

      if (selectedChar == null) {
        _logger.info("No enabled characters, skipping comment agent");
        return;
      }

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
