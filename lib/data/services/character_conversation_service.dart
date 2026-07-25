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
    await schedulePendingReply(
      userId: userId,
      characterId: characterId,
      delay: _settleDelay,
    );
    return messageId;
  }

  /// Ensures pending direct messages have one durable conversation task.
  ///
  /// Initiative uses this as a recovery path when it observes an unclaimed
  /// user message before deciding whether to speak.
  Future<void> schedulePendingReply({
    required String userId,
    required String characterId,
    Duration delay = Duration.zero,
  }) async {
    final scheduledAt = _clock().add(delay).millisecondsSinceEpoch ~/ 1000;
    await _taskExecutor.enqueueOrRescheduleTask(
      userId: userId,
      taskType: taskType,
      payload: {'character_id': characterId},
      bizId: taskBizId(characterId),
      scheduledAt: scheduledAt,
      maxRetries: 3,
    );
  }

  /// Restores a missing conversation task without changing the debounce time
  /// of one that is already pending or processing.
  Future<void> ensurePendingReplyScheduled({
    required String userId,
    required String characterId,
  }) async {
    final bizId = taskBizId(characterId);
    final alreadyScheduled = await _taskExecutor.hasActiveTask(
      taskType: taskType,
      bizId: bizId,
    );
    if (alreadyScheduled) return;

    await _taskExecutor.enqueueOrRescheduleTask(
      userId: userId,
      taskType: taskType,
      payload: {'character_id': characterId},
      bizId: bizId,
      scheduledAt: _clock().millisecondsSinceEpoch ~/ 1000,
      maxRetries: 3,
    );
  }
}
