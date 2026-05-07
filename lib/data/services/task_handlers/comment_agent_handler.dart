import 'package:logging/logging.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/repositories/post_comment.dart';
import 'package:memex/data/services/character_selection_service.dart';
import 'package:memex/data/services/comment_settings_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/time_context.dart';

final _logger = Logger('CommentAgentHandler');

Future<void> handleCommentAgentImpl(
    String userId, Map<String, dynamic> payload, TaskContext context) async {
  final factId = payload['fact_id'] as String;
  final combinedText = payload['combined_text'] as String;
  final inputDateTime = tryParseUnixSeconds(payload['created_at_ts']);

  _logger
      .info("Running Comment Agent selection for fact $factId, user $userId");

  try {
    // Load per-user comment settings
    final settings = await CommentSettingsService.load(userId);

    // Check if character comments are enabled
    if (!settings.enableCharacterComment) {
      _logger.info(
          'Character comments disabled — skipping comment agent for $factId');
      return;
    }

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

    // If character_id is explicitly provided in payload, use it (single character).
    String? selectedCharId = payload['character_id'] as String?;

    if (selectedCharId != null) {
      // Explicit character — single comment
      _logger.info("Using explicitly provided character $selectedCharId");
      await processAICommentReply(
        cardId: factId,
        userId: userId,
        userContent: Prompts.commentAgentInitialCommentPrompt,
        characterId: selectedCharId,
        rawInputContent: combinedText,
        inputDateTime: inputDateTime,
      );
      return;
    }

    final maxChars = settings.maxCommentCharacters;

    if (maxChars <= 1) {
      // Single-character mode: keyword-based selection (no LLM call)
      final selectedChar = await CharacterSelectionService.selectCharacter(
        userId: userId,
        inputContent: combinedText,
        factId: factId,
      );

      if (selectedChar == null) {
        _logger.info("No enabled characters, skipping comment agent");
        return;
      }

      _logger.info(
          "Selected character ${selectedChar.name} (${selectedChar.id}) for comment");
      await processAICommentReply(
        cardId: factId,
        userId: userId,
        userContent: Prompts.commentAgentInitialCommentPrompt,
        characterId: selectedChar.id,
        rawInputContent: combinedText,
        inputDateTime: inputDateTime,
      );
    } else {
      // Multi-character mode: LLM-based selection
      final resources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.commentAgent,
        defaultClientKey: LLMConfig.defaultClientKey,
      );

      final selectedChars =
          await CharacterSelectionService.selectMultipleCharacters(
        userId: userId,
        inputContent: combinedText,
        factId: factId,
        client: resources.client,
        modelConfig: resources.modelConfig,
        maxCharacters: maxChars,
      );

      if (selectedChars.isEmpty) {
        _logger.info("No enabled characters, skipping comment agent");
        return;
      }

      // Process characters sequentially so later characters can see earlier comments
      for (final char in selectedChars) {
        _logger.info(
            "Processing comment from character ${char.name} (${char.id})");
        await processAICommentReply(
          cardId: factId,
          userId: userId,
          userContent: Prompts.commentAgentInitialCommentPrompt,
          characterId: char.id,
          rawInputContent: combinedText,
          inputDateTime: inputDateTime,
        );
      }
    }
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
  final replyToId = payload['reply_to_id'] as String?;
  final inputDateTime = tryParseUnixSeconds(payload['created_at_ts']);

  _logger.info(
      'HandleProcessAiReply: Processing AI reply for card $cardId, user $userId');

  // If the user replied to a specific comment, resolve the target character
  String? targetCharacterId;
  if (replyToId != null) {
    try {
      final cardData =
          await FileSystemService.instance.readCardFile(userId, cardId);
      if (cardData != null) {
        for (final c in cardData.comments) {
          if (c.id == replyToId && c.isAi && c.characterId != null) {
            targetCharacterId = c.characterId;
            _logger.info(
                'User replied to comment $replyToId, routing to character $targetCharacterId');
            break;
          }
        }
      }
    } catch (e) {
      _logger.warning('Failed to resolve reply target character: $e');
    }
  }

  await processAICommentReply(
    cardId: cardId,
    userId: userId,
    userContent: content,
    userCommentId: commentId,
    characterId: targetCharacterId,
    inputDateTime: inputDateTime,
    withMemoryManagement: true,
  );
}
