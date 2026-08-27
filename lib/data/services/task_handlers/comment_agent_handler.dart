import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/repositories/post_comment.dart';
import 'package:memex/data/services/character_selection_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/comment_settings_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/mention_parser.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/time_context.dart';

final _logger = Logger('CommentAgentHandler');

Future<void> handleCommentAgentImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  final factId = payload['fact_id'] as String;
  final combinedText = payload['combined_text'] as String;
  final inputDateTime = tryParseUnixSeconds(payload['created_at_ts']);
  final locationContextReminder =
      payload['location_context_reminder'] as String?;

  _logger.info(
    "Running Comment Agent selection for fact $factId, user $userId",
  );

  try {
    // Load per-user comment settings
    final settings = await CommentSettingsService.load(userId);

    // If character_id is explicitly provided in payload, use it (single
    // character). Also support lightweight @mentions in the input text.
    String? selectedCharId = payload['character_id'] as String?;
    selectedCharId ??= await _resolveMentionedCharacterId(
      userId: userId,
      content: combinedText,
    );
    final forceReply = selectedCharId != null;

    // Check if character comments are enabled. Directly mentioned characters
    // still answer because the user explicitly routed the turn to them.
    if (!forceReply && !settings.enableCharacterComment) {
      _logger.info(
        'Character comments disabled — skipping comment agent for $factId',
      );
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

    if (selectedCharId != null) {
      // Explicit character — single comment
      _logger.info("Using explicitly routed character $selectedCharId");
      await processAICommentReply(
        cardId: factId,
        userId: userId,
        userContent: Prompts.commentAgentInitialCommentPrompt,
        characterId: selectedCharId,
        rawInputContent: combinedText,
        inputDateTime: inputDateTime,
        locationContextReminder: locationContextReminder,
        forceReply: forceReply,
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
        "Selected character ${selectedChar.name} (${selectedChar.id}) for comment",
      );
      await processAICommentReply(
        cardId: factId,
        userId: userId,
        userContent: Prompts.commentAgentInitialCommentPrompt,
        characterId: selectedChar.id,
        rawInputContent: combinedText,
        inputDateTime: inputDateTime,
        locationContextReminder: locationContextReminder,
        forceReply: false,
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
          "Processing comment from character ${char.name} (${char.id})",
        );
        await processAICommentReply(
          cardId: factId,
          userId: userId,
          userContent: Prompts.commentAgentInitialCommentPrompt,
          characterId: char.id,
          rawInputContent: combinedText,
          inputDateTime: inputDateTime,
          locationContextReminder: locationContextReminder,
          forceReply: false,
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
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  final cardId = payload['card_id'] as String;
  final content = payload['content'] as String;
  final commentId = payload['comment_id'] as String?;
  final replyToId = payload['reply_to_id'] as String?;
  final inputDateTime = tryParseUnixSeconds(payload['created_at_ts']);
  final locationContextReminder =
      payload['location_context_reminder'] as String?;

  _logger.info(
    'HandleProcessAiReply: Processing AI reply for card $cardId, user $userId',
  );

  // If the user replied to a specific comment, resolve the target character
  String? targetCharacterId;
  if (replyToId != null) {
    try {
      final cardData = await FileSystemService.instance.readCardFile(
        userId,
        cardId,
      );
      if (cardData != null) {
        targetCharacterId = resolveReplyTargetCharacterId(
          cardData.comments,
          replyToId,
        );
        if (targetCharacterId != null) {
          _logger.info(
            'User replied to comment $replyToId, routing to character $targetCharacterId',
          );
        }
      }
    } catch (e) {
      _logger.warning('Failed to resolve reply target character: $e');
    }
  }
  targetCharacterId ??= await _resolveMentionedCharacterId(
    userId: userId,
    content: content,
  );

  await processAICommentReply(
    cardId: cardId,
    userId: userId,
    userContent: content,
    userCommentId: commentId,
    characterId: targetCharacterId,
    inputDateTime: inputDateTime,
    locationContextReminder: locationContextReminder,
    withMemoryManagement: true,
    forceReply: targetCharacterId != null,
  );
}

Future<String?> _resolveMentionedCharacterId({
  required String userId,
  required String content,
}) async {
  if (!content.contains('@')) return null;

  try {
    final characters = await CharacterService.instance.getAllCharacters(userId);
    final candidates = <({String id, String token, int index})>[];

    for (final character in characters) {
      for (final token in {character.id, character.name}) {
        final trimmed = token.trim();
        if (trimmed.isEmpty) continue;
        final mention = '@$trimmed';
        final index = indexOfStandaloneMention(content, mention);
        if (index >= 0) {
          candidates.add((id: character.id, token: mention, index: index));
        }
      }
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final indexCompare = a.index.compareTo(b.index);
      if (indexCompare != 0) return indexCompare;
      return b.token.length.compareTo(a.token.length);
    });
    final selected = candidates.first;
    _logger.info(
      'Resolved character mention ${selected.token} to ${selected.id}',
    );
    return selected.id;
  } catch (e) {
    _logger.warning('Failed to resolve character mention: $e');
    return null;
  }
}

/// Walks `reply_to_id` until it finds an AI comment with a character.
/// Direct replies to an AI comment still resolve in one hop; a reply to a
/// user comment in that thread walks up to the character that owns it.
@visibleForTesting
String? resolveReplyTargetCharacterId(
  List<CardComment> comments,
  String replyToId,
) {
  final byId = {for (final comment in comments) comment.id: comment};
  CardComment? current = byId[replyToId];
  final seen = <String>{};
  while (current != null && seen.add(current.id)) {
    if (current.isAi && current.characterId != null) {
      return current.characterId;
    }
    final nextId = current.replyToId;
    if (nextId == null || nextId.isEmpty) {
      break;
    }
    current = byId[nextId];
  }
  return null;
}
