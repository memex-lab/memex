import 'package:logging/logging.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/agent/comment_agent/comment_agent.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/agent/agent_utils.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/time_context.dart';

final _logger = Logger('PostCommentEndpoint');
final _fileSystemService = FileSystemService.instance;

/// Post comment (AI reply handled async)
///
/// Args:
///   cardId: card ID (fact_id)
///   userId: user ID
///   content: comment content
///   replyToId: optional, ID of the comment being replied to
///
/// Returns:
///   Map with user comment info (AI reply is async)
Future<Map<String, dynamic>> postCommentEndpoint(
  String cardId,
  String userId,
  String content, {
  String? replyToId,
}) async {
  _logger.info(
      'PostCommentEndpoint: postComment called: cardId=$cardId, userId=$userId');

  try {
    // Read card file
    final cardData = await _fileSystemService.readCardFile(userId, cardId);
    if (cardData == null) {
      throw Exception('Card not found: $cardId');
    }

    // Save user comment to card (persist immediately)
    final commentId = const Uuid().v4();
    final commentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String? targetCharacterId;
    if (replyToId != null && replyToId.isNotEmpty) {
      for (final c in cardData.comments.reversed) {
        if (c.id == replyToId && c.isAi && c.characterId != null) {
          targetCharacterId = c.characterId;
          break;
        }
      }
    }
    await _fileSystemService.updateCardFile(userId, cardId, (card) {
      final newComment = CardComment(
        id: commentId,
        content: content,
        isAi: false,
        timestamp: commentTimestamp,
        replyToId: replyToId,
      );
      return card.copyWith(comments: [...card.comments, newComment]);
    });

    if (targetCharacterId != null) {
      try {
        await CharacterMemoryService.instance.appendTimelineEvent(
          userId: userId,
          characterId: targetCharacterId,
          scene: CharacterMemoryScene.comment,
          type: CharacterMemoryEventType.userCommentReply,
          content: content,
          threadId: cardId,
          factId: cardId,
          commentId: commentId,
          replyToId: replyToId,
          sourceId: commentId,
          timestamp:
              DateTime.fromMillisecondsSinceEpoch(commentTimestamp * 1000),
          metadata: {
            if (replyToId != null && replyToId.isNotEmpty)
              'reply_to_id': replyToId,
            'source': 'post_comment',
          },
        );
      } catch (e) {
        _logger.warning('Failed to append user comment timeline event: $e');
      }
    }

    _logger.info('User comment saved for card $cardId, comment_id: $commentId');

    // Log event
    try {
      final cardPath = _fileSystemService.getCardPath(userId, cardId);
      final workspacePath = _fileSystemService.getWorkspacePath(userId);
      final relativePath =
          _fileSystemService.toRelativePath(cardPath, rootPath: workspacePath);
      await _fileSystemService.eventLogService.logFileModified(
        userId: userId,
        filePath: relativePath,
        description: 'User posted comment to card',
        metadata: {
          'card_id': cardId,
          'comment_id': commentId,
          'content': content,
        },
      );
    } catch (e) {
      // Event logging failure should not break comment posting
    }

    // Publish domain event and let event subscribers enqueue persistent tasks.
    await GlobalEventBus.instance.publish(
      userId: userId,
      event: SystemEvent(
        type: SystemEventTypes.cardCommentPosted,
        source: 'post_comment.postCommentEndpoint',
        payload: CardCommentPostedPayload(
          cardId: cardId,
          content: content,
          commentId: commentId,
          createdAtTs: commentTimestamp,
          replyToId: replyToId,
        ),
      ),
    );

    // Return user comment info immediately
    return {
      'comment_id': commentId,
      'status': 'pending',
      'message': 'Comment submitted, AI is replying...',
    };
  } catch (e) {
    _logger.severe('Failed to post comment for card $cardId: $e');
    rethrow;
  }
}

/// Process AI comment reply (async task)
///
/// Args:
///   cardId: card ID (fact_id)
///   userId: user ID
///   userContent: user comment or prompt
///   userCommentId: optional, for reply scenario
///   characterId: optional, from existing comment if not provided
///   rawInputContent: optional, read from file if not provided
///   sendEventBus: whether to send event bus update (default true)
Future<void> processAICommentReply({
  required String cardId,
  required String userId,
  required String userContent,
  String? userCommentId,
  String? characterId,
  String? rawInputContent,
  bool sendEventBus = true,
  DateTime? inputDateTime,
  bool withMemoryManagement = false,
}) async {
  _logger.info(
      'PostCommentEndpoint: processAICommentReply called: cardId=$cardId, userId=$userId');

  try {
    // 1. Read card file
    final cardData = await _fileSystemService.readCardFile(userId, cardId);
    if (cardData == null) {
      _logger.warning('Card not found for AI reply: $cardId');
      return;
    }

    final initialInsight = cardData.insight?.text;

    // 2. Character ID Fallback
    // When no explicit characterId: pick the most recent AI commenter
    // (the character most recently active in the conversation).
    // Falls back to the insight character if no AI comments exist.
    if (characterId == null) {
      for (final c in cardData.comments.reversed) {
        if (c.isAi && c.characterId != null) {
          characterId = c.characterId;
          _logger.info('Using most recent AI commenter $characterId');
          break;
        }
      }
      if (characterId == null && cardData.insight != null) {
        characterId = cardData.insight!.characterId;
        if (characterId != null) {
          _logger.info('Using character_id $characterId from insight data');
        }
      }
    }

    // 3. Raw Input Content
    // If rawInputContent is null, we should try to extract it from file.
    // Always extract factContent to get assetAnalyses
    final factContent =
        await _fileSystemService.extractFactContentFromFile(userId, cardId);
    String contentToUse = rawInputContent ?? '';
    if (contentToUse.isEmpty) {
      contentToUse = factContent?.content ?? '';
    }

    // Build asset info string

    final assetAnalyses = factContent?.assetAnalyses;
    final entryDateTime = factContent?.datetime;
    // Build asset info string
    final assetInfo = formatAssetAnalysis(assetAnalyses);
    contentToUse = contentToUse + assetInfo;

    // 4. PKM Context
    // CommentAgent.run handles searching PKM context if not passed.

    // 5. Initialize Agent
    // 5. Initialize Agent (Default to Responses for Comments)
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.commentAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final client = resources.client;
    final modelConfig = resources.modelConfig;

    // 6. Build existing comments context for multi-character interaction
    String existingCommentsContext = '';
    if (cardData.comments.isNotEmpty) {
      final buf = StringBuffer();
      buf.writeln('\n<existing_comments>');
      for (final c in cardData.comments) {
        final author = c.isAi ? (c.characterId ?? 'AI') : 'User';
        final replyInfo =
            c.replyToId != null ? ' (replying to ${c.replyToId})' : '';
        final commentTime = formatLocalDateTimeWithZone(
          DateTime.fromMillisecondsSinceEpoch(c.timestamp * 1000),
        );
        buf.writeln(
            '- [$author] (id: ${c.id}, time: $commentTime)$replyInfo: ${c.content}');
      }
      buf.writeln('</existing_comments>');
      existingCommentsContext = buf.toString();
    }

    // 7. Initialize and Run Agent
    final fullUserContent = existingCommentsContext.isNotEmpty
        ? '$userContent\n$existingCommentsContext'
        : userContent;

    try {
      await CommentAgent.runWithContent(
        fullUserContent,
        client: client,
        modelConfig: modelConfig,
        userId: userId,
        factId: cardId,
        rawInputContent: contentToUse,
        initialInsight: initialInsight,
        characterId: characterId,
        currentTime: inputDateTime ?? DateTime.now(),
        entryTime: entryDateTime,
        withMemoryManagement: withMemoryManagement,
      );
    } catch (e) {
      _logger.severe('Error running comment agent: $e');
    }

    // 7. Save Reply to Card - REMOVED
    // The Agent now uses the SaveComment tool to save the reply directly.
    // If the agent fails, no comment is posted (unless we add fallback logic here, but keeping it simple for now).

    // 8. EventBus Update
    if (sendEventBus) {
      EventBusService.instance.emitEvent(CardDetailUpdatedMessage(
        cardId: cardId,
      ));
    }
  } catch (e) {
    _logger.severe('Failed to process AI comment reply for card $cardId: $e');
    rethrow;
  }
}
