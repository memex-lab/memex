import 'package:memex/agent/character_agent/character_agent.dart';
import 'package:memex/data/services/character_conversation_service.dart';
import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_conversation.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/logger.dart';

typedef CharacterConversationDecider = Future<CharacterConversationDecision>
    Function({
  required String userId,
  required CharacterModel character,
  required CharacterConversationContext context,
  CharacterWorkspaceService? workspaceService,
});

class CharacterConversationTaskHandler {
  CharacterConversationTaskHandler({
    PersonaChatService? chatService,
    CharacterWorkspaceService? workspaceService,
    CharacterConversationDecider? decider,
    CharacterExecutionCoordinator? executionCoordinator,
    EventBusService? eventBus,
    LocalTaskExecutor? taskExecutor,
    Future<CharacterModel?> Function(String userId, String characterId)?
        characterLoader,
    DateTime Function()? clock,
  })  : _chatService = chatService ?? PersonaChatService.instance,
        _workspaceService =
            workspaceService ?? CharacterWorkspaceService.instance,
        _decider = decider ?? CharacterAgent.considerConversation,
        _executionCoordinator =
            executionCoordinator ?? CharacterExecutionCoordinator.instance,
        _eventBus = eventBus ?? EventBusService.instance,
        _taskExecutor = taskExecutor ?? LocalTaskExecutor.instance,
        _characterLoader = characterLoader ??
            ((userId, characterId) =>
                CharacterService.instance.getCharacter(userId, characterId)),
        _clock = clock ?? DateTime.now;

  final PersonaChatService _chatService;
  final CharacterWorkspaceService _workspaceService;
  final CharacterConversationDecider _decider;
  final CharacterExecutionCoordinator _executionCoordinator;
  final EventBusService _eventBus;
  final LocalTaskExecutor _taskExecutor;
  final Future<CharacterModel?> Function(String, String) _characterLoader;
  final DateTime Function() _clock;
  final _logger = getLogger('CharacterConversationTaskHandler');

  Future<void> call(
    String userId,
    Map<String, dynamic> payload,
    TaskContext taskContext,
  ) async {
    final characterId = payload['character_id'] as String?;
    if (characterId == null || characterId.trim().isEmpty) {
      throw ArgumentError('character_conversation_task needs character_id.');
    }
    final character = await _characterLoader(userId, characterId);
    if (character == null || !character.enabled) return;

    await _executionCoordinator.run(
      userId: userId,
      characterId: characterId,
      action: () => _runForCharacter(
        userId: userId,
        character: character,
        payload: payload,
      ),
    );
  }

  Future<void> _runForCharacter({
    required String userId,
    required CharacterModel character,
    required Map<String, dynamic> payload,
  }) async {
    final conversationGeneration = await _chatService
        .getConversationGeneration(character.id, userId: userId);
    final incoming = await _chatService.getPendingUserMessages(
      character.id,
      userId: userId,
    );
    if (incoming.isEmpty) return;
    if (await _chatService.getConversationGeneration(
          character.id,
          userId: userId,
        ) !=
        conversationGeneration) {
      return;
    }

    final history = await _chatService.getMessagesBefore(
      character.id,
      beforeMessageId: incoming.first.id,
      limit: 24,
      userId: userId,
    );
    final context = CharacterConversationContext(
      sourceEventId: 'private_chat:${incoming.first.id}',
      now: _clock(),
      incomingMessages: incoming.map(_toTurn).toList(growable: false),
      recentPrivateChat: history.reversed.map(_toTurn).toList(growable: false),
      deferredReason: payload['deferred_reason'] as String?,
    );

    try {
      final decision = await _decider(
        userId: userId,
        character: character,
        context: context,
        workspaceService: _workspaceService,
      );
      final turnId =
          'character_conversation:${incoming.first.id}-${incoming.last.id}';
      final incomingIds = incoming.map((message) => message.id).toList();
      var replyPending = false;
      switch (decision.action) {
        case CharacterConversationAction.speak:
          await _chatService.completeConversationEpisode(
            characterId: character.id,
            consumedThroughMessageId: incoming.last.id,
            characterMessages: decision.messages,
            episodeId: turnId,
            timestamp: _clock(),
            expectedGeneration: conversationGeneration,
            userId: userId,
          );
          _logger.info(
            'Character ${character.id} replied with '
            '${decision.messages.length} message(s)',
          );
          replyPending = (await _chatService.getPendingUserMessages(
            character.id,
            userId: userId,
          ))
              .isNotEmpty;
        case CharacterConversationAction.thinkLater:
          final wakeAt = decision.wakeAt;
          final reason = decision.reason?.trim() ?? '';
          if (wakeAt == null || !wakeAt.isAfter(_clock()) || reason.isEmpty) {
            throw StateError('Invalid ThinkLater conversation decision.');
          }
          final latestPending = await _chatService.getPendingUserMessages(
            character.id,
            userId: userId,
          );
          final hasNewerInput = latestPending.any(
            (message) => !incomingIds.contains(message.id),
          );
          replyPending = hasNewerInput;
          final scheduledAt =
              hasNewerInput ? _clock().add(const Duration(seconds: 1)) : wakeAt;
          await _taskExecutor.enqueueOrRescheduleTask(
            userId: userId,
            taskType: CharacterConversationService.taskType,
            payload: {
              'character_id': character.id,
              if (!hasNewerInput) 'deferred_reason': reason,
            },
            bizId: CharacterConversationService.taskBizId(character.id),
            scheduledAt: scheduledAt.millisecondsSinceEpoch ~/ 1000,
            maxRetries: 3,
          );
          _logger.info(
            'Character ${character.id} will reconsider conversation at '
            '$scheduledAt',
          );
        case CharacterConversationAction.stayQuiet:
          await _chatService.advanceReplyCursor(
            characterId: character.id,
            consumedThroughMessageId: incoming.last.id,
            userId: userId,
          );
          _logger.info(
            'Character ${character.id} stayed quiet: ${decision.reason}',
          );
          replyPending = (await _chatService.getPendingUserMessages(
            character.id,
            userId: userId,
          ))
              .isNotEmpty;
      }
      _eventBus.emitEvent(
        PersonaChatMessageAddedMessage(
          characterId: character.id,
          replyPending: replyPending,
        ),
      );
    } catch (error, stackTrace) {
      _logger.severe(
        'Character conversation failed for ${character.id}',
        error,
        stackTrace,
      );
      rethrowIfNonRetryable(error);
    }
  }

  static CharacterConversationTurn _toTurn(PersonaChatMessage message) {
    return CharacterConversationTurn(
      id: message.id,
      isFromCharacter: message.isFromCharacter,
      content: message.content,
      timestamp: message.timestamp,
      isRead: message.isRead,
      origin: message.origin,
      contactEpisodeId: message.contactEpisodeId,
      messageType: message.messageType,
    );
  }
}

final CharacterConversationTaskHandler _defaultHandler =
    CharacterConversationTaskHandler();

Future<void> handleCharacterConversationImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) {
  return _defaultHandler(userId, payload, context);
}

Future<void> handleCharacterConversationFailure(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
  Object error,
  StackTrace? stackTrace,
) async {
  final characterId = payload['character_id'] as String?;
  getLogger('CharacterConversationTaskHandler').severe(
    'Character conversation task ${context.taskId} failed permanently for '
    'user $userId',
    error,
    stackTrace,
  );
  if (characterId != null) {
    EventBusService.instance.emitEvent(
      PersonaChatMessageAddedMessage(
        characterId: characterId,
        replyPending: false,
      ),
    );
  }
}
