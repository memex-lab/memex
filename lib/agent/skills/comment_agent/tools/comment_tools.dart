// ignore_for_file: non_constant_identifier_names

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:uuid/uuid.dart';
import 'package:memex/utils/logger.dart';

class CommentToolFactory {
  final String userId;
  final String cardId;
  final String? characterId;

  CommentToolFactory({
    required this.userId,
    required this.cardId,
    this.characterId,
  });

  Tool buildSaveCommentTool() {
    return Tool(
      name: 'SaveComment',
      description: 'Saves your comment to the current raw input or reply.',
      parameters: {
        'type': 'object',
        'properties': {
          'content': {
            'type': 'string',
            'description': 'The content of your comment.'
          },
          'reply_to_id': {
            'type': 'string',
            'description':
                'Optional. The ID of the comment you are replying to. Leave empty for a top-level comment.'
          },
        },
        'required': ['content']
      },
      executable: (String content, String? reply_to_id) async {
        if (content.isEmpty) {
          return "Error: Comment content cannot be empty.";
        }

        try {
          final fileSystemService = FileSystemService.instance;
          final commentId = const Uuid().v4();
          final now = DateTime.now();

          final updatedCardData = await fileSystemService.updateCardFile(
            userId,
            cardId,
            (card) {
              final newComment = CardComment(
                id: commentId,
                content: content,
                isAi: true,
                timestamp: now.millisecondsSinceEpoch ~/ 1000,
                characterId: characterId,
                replyToId: reply_to_id,
              );
              return card.copyWith(comments: [...card.comments, newComment]);
            },
          );

          if (updatedCardData == null) {
            return "Error: Card not found: $cardId";
          }

          // Log event
          try {
            final cardPath = fileSystemService.getCardPath(userId, cardId);
            final workspacePath = fileSystemService.getWorkspacePath(userId);
            final relativePath = fileSystemService.toRelativePath(cardPath,
                rootPath: workspacePath);
            await fileSystemService.eventLogService.logFileModified(
              userId: userId,
              filePath: relativePath,
              description: 'AI comment added to card via tool',
              metadata: {
                'card_id': cardId,
                'comment_id': commentId,
                'character_id': characterId,
                'content': content
              },
            );
          } catch (e) {
            getLogger('CommentTool').warning('Failed to log event: $e');
          }

          if (characterId != null) {
            try {
              await CharacterMemoryService.instance.appendTimelineEvent(
                userId: userId,
                characterId: characterId!,
                scene: CharacterMemoryScene.comment,
                type: CharacterMemoryEventType.characterComment,
                content: content,
                threadId: cardId,
                factId: cardId,
                commentId: commentId,
                replyToId: reply_to_id != null && reply_to_id.isNotEmpty
                    ? reply_to_id
                    : null,
                sourceId: commentId,
                timestamp: now,
                metadata: {
                  if (reply_to_id != null && reply_to_id.isNotEmpty)
                    'reply_to_id': reply_to_id,
                  'source': 'comment_tool',
                },
              );
            } catch (e) {
              getLogger('CommentTool')
                  .warning('Failed to append character timeline event: $e');
            }
          }

          return AgentToolResult(
            content: TextPart("Comment saved successfully."),
            stopFlag: true,
          );
        } catch (e) {
          return "Error saving comment: $e";
        }
      },
    );
  }
}
