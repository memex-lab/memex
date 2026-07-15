import 'package:flutter/foundation.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_service.dart';

class CharacterConversationService {
  CharacterConversationService._({
    required PersonaChatService chatService,
    required LocalTaskExecutor taskExecutor,
    required DateTime Function() clock,
    required Duration settleDelay,
  })  : _chatService = chatService,
        _taskExecutor = taskExecutor,
        _clock = clock,
        _settleDelay = settleDelay;

  static final CharacterConversationService instance =
      CharacterConversationService._(
    chatService: PersonaChatService.instance,
    taskExecutor: LocalTaskExecutor.instance,
    clock: DateTime.now,
    settleDelay: const Duration(seconds: 1),
  );

  @visibleForTesting
  factory CharacterConversationService.forTesting({
    required PersonaChatService chatService,
    required LocalTaskExecutor taskExecutor,
    DateTime Function()? clock,
    Duration settleDelay = const Duration(seconds: 1),
  }) {
    return CharacterConversationService._(
      chatService: chatService,
      taskExecutor: taskExecutor,
      clock: clock ?? DateTime.now,
      settleDelay: settleDelay,
    );
  }

  static const taskType = 'character_conversation_task';

  final PersonaChatService _chatService;
  final LocalTaskExecutor _taskExecutor;
  final DateTime Function() _clock;
  final Duration _settleDelay;

  static String taskBizId(String characterId) =>
      'character_conversation:$characterId';

  Future<int> sendUserMessage({
    required String userId,
    required String characterId,
    required String content,
    DateTime? timestamp,
  }) async {
    final text = content.trim();
    if (text.isEmpty) {
      throw ArgumentError.value(content, 'content', 'Message cannot be empty.');
    }
    final sentAt = timestamp ?? _clock();
    final messageId = await _chatService.addUserMessage(
      characterId,
      text,
      timestamp: sentAt,
    );
    final scheduledAt =
        _clock().add(_settleDelay).millisecondsSinceEpoch ~/ 1000;
    await _taskExecutor.enqueueOrRescheduleTask(
      userId: userId,
      taskType: taskType,
      payload: {
        'character_id': characterId,
      },
      bizId: taskBizId(characterId),
      scheduledAt: scheduledAt,
      maxRetries: 3,
    );
    return messageId;
  }
}
