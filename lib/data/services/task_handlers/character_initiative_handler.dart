import 'package:memex/agent/character_agent/character_agent.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:memex/data/services/character_initiative_service.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_message.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/logger.dart';

typedef CharacterInitiativeContextLoader = Future<CharacterInitiativeContext>
    Function({
  required String userId,
  required CharacterModel character,
  required String sourceEventId,
  required DateTime now,
  String? factId,
});

typedef CharacterInitiativeDecider = Future<CharacterInitiativeDecision>
    Function({
  required String userId,
  required CharacterModel character,
  required CharacterInitiativeContext context,
  CharacterWorkspaceService? workspaceService,
});

typedef CharacterInitiativeMessageSender = Future<void> Function({
  required String characterId,
  required List<CharacterOutgoingMessage> messages,
  required DateTime timestamp,
  required String contactEpisodeId,
  String? factId,
});

typedef CharacterInitiativeWakeScheduler = Future<void> Function({
  required String userId,
  required DateTime wakeAt,
  required String reason,
});

typedef CharacterLatestMessageIdLoader = Future<int> Function(
  String characterId,
);

class CharacterInitiativeTaskHandler {
  CharacterInitiativeTaskHandler({
    CharacterWorkspaceService? workspaceService,
    Future<CharacterModel?> Function(String userId)? primaryCompanionLoader,
    CharacterInitiativeContextLoader? contextLoader,
    CharacterInitiativeDecider? decider,
    CharacterInitiativeMessageSender? messageSender,
    PersonaChatService? chatService,
    EventBusService? eventBus,
    CharacterInitiativeWakeScheduler? wakeScheduler,
    CharacterLatestMessageIdLoader? latestMessageIdLoader,
    CharacterExecutionCoordinator? executionCoordinator,
    DateTime Function()? clock,
  })  : _workspaceService =
            workspaceService ?? CharacterWorkspaceService.instance,
        _primaryCompanionLoader = primaryCompanionLoader ??
            CharacterService.instance.getPrimaryCompanion,
        _contextLoader = contextLoader ?? _loadContext,
        _decider = decider ?? CharacterAgent.considerInitiative,
        _messageSender = messageSender ??
            _buildMessageSender(
              chatService ?? PersonaChatService.instance,
              eventBus ?? EventBusService.instance,
            ),
        _wakeScheduler = wakeScheduler ??
            CharacterInitiativeService.instance.scheduleNextWake,
        _latestMessageIdLoader = latestMessageIdLoader ??
            (messageSender == null
                ? _buildLatestMessageIdLoader(
                    chatService ?? PersonaChatService.instance,
                  )
                : null),
        _executionCoordinator =
            executionCoordinator ?? CharacterExecutionCoordinator.instance,
        _clock = clock ?? DateTime.now;

  final CharacterWorkspaceService _workspaceService;
  final Future<CharacterModel?> Function(String userId) _primaryCompanionLoader;
  final CharacterInitiativeContextLoader _contextLoader;
  final CharacterInitiativeDecider _decider;
  final CharacterInitiativeMessageSender _messageSender;
  final CharacterInitiativeWakeScheduler _wakeScheduler;
  final CharacterLatestMessageIdLoader? _latestMessageIdLoader;
  final CharacterExecutionCoordinator _executionCoordinator;
  final DateTime Function() _clock;
  final _logger = getLogger('CharacterInitiativeTaskHandler');

  Future<void> call(
    String userId,
    Map<String, dynamic> payload,
    TaskContext taskContext,
  ) async {
    final requestedCharacterId = payload['character_id'] as String?;
    final character = requestedCharacterId == null
        ? await _primaryCompanionLoader(userId)
        : await CharacterService.instance.getCharacter(
            userId,
            requestedCharacterId,
          );
    if (character == null || !character.enabled) {
      _logger.info('No enabled primary companion for user $userId');
      return;
    }

    await _executionCoordinator.run(
      userId: userId,
      characterId: character.id,
      action: () => _runForCharacter(
        userId: userId,
        payload: payload,
        taskContext: taskContext,
        character: character,
      ),
    );
  }

  Future<void> _runForCharacter({
    required String userId,
    required Map<String, dynamic> payload,
    required TaskContext taskContext,
    required CharacterModel character,
  }) async {
    await _workspaceService.ensureInitialized(userId, character);

    CharacterPendingThought? resumedThought;
    final pendingThoughtId = payload['pending_thought_id'] as String?;
    if (pendingThoughtId != null) {
      resumedThought = await _workspaceService.getPendingThought(
        userId,
        character.id,
        pendingThoughtId,
      );
      if (resumedThought == null) {
        _logger.info('Skipping resolved pending thought $pendingThoughtId');
        return;
      }
      final expectedWakeAt = DateTime.tryParse(
        payload['pending_thought_wake_at'] as String? ?? '',
      );
      if (expectedWakeAt == null ||
          !expectedWakeAt.isAtSameMomentAs(resumedThought.wakeAt)) {
        _logger.info('Skipping stale schedule for $pendingThoughtId');
        return;
      }
    }

    final sourceEventId = resumedThought?.sourceEventId ??
        ((payload['source_event_id'] as String?)?.trim().isNotEmpty == true
            ? payload['source_event_id'] as String
            : taskContext.bizId ?? taskContext.taskId);
    final factId = resumedThought?.factId ?? payload['fact_id'] as String?;
    final now = _clock();
    final baseContext = await _contextLoader(
      userId: userId,
      character: character,
      sourceEventId: sourceEventId,
      factId: factId,
      now: now,
    );
    final context = CharacterInitiativeContext(
      sourceEventId: baseContext.sourceEventId,
      factId: baseContext.factId,
      now: baseContext.now,
      recentPrivateChat: baseContext.recentPrivateChat,
      characterComment: baseContext.characterComment,
      pendingThoughts: await _workspaceService.loadPendingThoughts(
        userId,
        character.id,
      ),
      resumedThought: resumedThought,
      wakeReason: resumedThought?.reason ?? payload['wake_reason'] as String?,
      latestPrivateMessageId: baseContext.latestPrivateMessageId,
    );

    try {
      final decision = await _decider(
        userId: userId,
        character: character,
        context: context,
        workspaceService: _workspaceService,
      );
      final wakeAt = decision.wakeAt;
      if (!wakeAt.isAfter(now)) {
        throw StateError('Character selected an invalid future wake time.');
      }
      final wakeReason = decision.reason.trim();
      if (wakeReason.isEmpty) {
        throw StateError('The next wake requires a private reason.');
      }

      switch (decision.action) {
        case CharacterInitiativeAction.speak:
          final messages = decision.messages;
          if (messages.isEmpty) {
            throw StateError('Character selected invalid private messages.');
          }
          var shouldSend = true;
          final latestMessageIdLoader = _latestMessageIdLoader;
          if (latestMessageIdLoader != null) {
            final currentRevision = await latestMessageIdLoader(character.id);
            if (currentRevision != context.latestPrivateMessageId) {
              shouldSend = false;
              _logger.info(
                'Discarded stale initiative for ${character.id}: chat changed '
                'from ${context.latestPrivateMessageId} to $currentRevision',
              );
            }
          }
          if (shouldSend) {
            await _messageSender(
              characterId: character.id,
              messages: messages,
              factId: factId,
              timestamp: _clock(),
              contactEpisodeId: 'character_initiative:${taskContext.taskId}',
            );
            _logger.info(
              'Character ${character.id} initiated private contact with '
              '${messages.length} message(s)',
            );
          }
        case CharacterInitiativeAction.sleepUntil:
          _logger.info(
            'Character ${character.id} chose not to speak now',
          );
      }

      if (resumedThought != null) {
        await _workspaceService.resolvePendingThought(
          userId,
          character.id,
          resumedThought.id,
        );
      }
      await _wakeScheduler(
        userId: userId,
        wakeAt: wakeAt,
        reason: wakeReason,
      );
      _logger.info(
        'Character ${character.id} will wake again at $wakeAt',
      );
    } catch (error, stackTrace) {
      _logger.severe(
        'Character initiative failed for ${character.id}',
        error,
        stackTrace,
      );
      rethrowIfNonRetryable(error);
    }
  }

  static Future<CharacterInitiativeContext> _loadContext({
    required String userId,
    required CharacterModel character,
    required String sourceEventId,
    required DateTime now,
    String? factId,
  }) async {
    final messages = await PersonaChatService.instance.getMessages(
      character.id,
      limit: 24,
    );
    final recentPrivateChat = messages.reversed
        .map(
          (message) => CharacterConversationTurn(
            id: message.id,
            isFromCharacter: message.isFromCharacter,
            content: message.content,
            timestamp: message.timestamp,
            isRead: message.isRead,
            origin: message.origin,
            contactEpisodeId: message.contactEpisodeId,
            messageType: message.messageType,
          ),
        )
        .toList();

    String? characterComment;
    if (factId != null) {
      final card =
          await FileSystemService.instance.readCardFile(userId, factId);
      characterComment = card?.comments.reversed
          .where(
            (comment) => comment.isAi && comment.characterId == character.id,
          )
          .firstOrNull
          ?.content;
    }

    return CharacterInitiativeContext(
      sourceEventId: sourceEventId,
      factId: factId,
      now: now,
      recentPrivateChat: recentPrivateChat,
      characterComment: characterComment,
      latestPrivateMessageId: messages.fold<int>(
        0,
        (latest, message) => message.id > latest ? message.id : latest,
      ),
    );
  }

  static CharacterLatestMessageIdLoader _buildLatestMessageIdLoader(
    PersonaChatService chatService,
  ) {
    return chatService.getLatestMessageId;
  }

  static CharacterInitiativeMessageSender _buildMessageSender(
    PersonaChatService chatService,
    EventBusService eventBus,
  ) {
    return ({
      required String characterId,
      required List<CharacterOutgoingMessage> messages,
      required DateTime timestamp,
      required String contactEpisodeId,
      String? factId,
    }) async {
      await chatService.addCharacterMessages(
        characterId,
        messages,
        factId: factId,
        isRead: false,
        timestamp: timestamp,
        origin: PersonaChatMessageOrigin.initiative,
        contactEpisodeId: contactEpisodeId,
      );
      eventBus.emitEvent(
        PersonaChatMessageAddedMessage(characterId: characterId),
      );
    };
  }
}

final CharacterInitiativeTaskHandler _defaultHandler =
    CharacterInitiativeTaskHandler();

Future<void> handleCharacterInitiativeImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) {
  return _defaultHandler(userId, payload, context);
}

Future<void> handleCharacterInitiativeFailure(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
  Object error,
  StackTrace? stackTrace,
) async {
  getLogger('CharacterInitiativeTaskHandler').severe(
    'Character initiative task ${context.taskId} failed permanently for '
    'user $userId',
    error,
    stackTrace,
  );
}
