import 'package:memex/agent/character_agent/character_agent.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/character_workspace.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';

typedef PrimaryCompanionLoader = Future<CharacterModel?> Function(
  String userId,
);

typedef CharacterObservationDigester = Future<void> Function({
  required String userId,
  required CharacterModel character,
  required CharacterObservation observation,
  CharacterWorkspaceService? workspaceService,
});

class CharacterPerceptionTaskHandler {
  CharacterPerceptionTaskHandler({
    CharacterWorkspaceService? workspaceService,
    PrimaryCompanionLoader? primaryCompanionLoader,
    CharacterObservationDigester? observationDigester,
    CharacterExecutionCoordinator? executionCoordinator,
  })  : _workspaceService =
            workspaceService ?? CharacterWorkspaceService.instance,
        _primaryCompanionLoader = primaryCompanionLoader ??
            CharacterService.instance.getPrimaryCompanion,
        _observationDigester =
            observationDigester ?? CharacterAgent.digestObservation,
        _executionCoordinator =
            executionCoordinator ?? CharacterExecutionCoordinator.instance;

  final CharacterWorkspaceService _workspaceService;
  final PrimaryCompanionLoader _primaryCompanionLoader;
  final CharacterObservationDigester _observationDigester;
  final CharacterExecutionCoordinator _executionCoordinator;
  final _logger = getLogger('CharacterPerceptionTaskHandler');

  Future<void> call(
    String userId,
    Map<String, dynamic> payload,
    TaskContext context,
  ) async {
    final content = (payload['combined_text'] as String? ?? '').trim();
    if (content.isEmpty) {
      _logger.info('Skipping empty character observation for user $userId');
      return;
    }

    final character = await _primaryCompanionLoader(userId);
    if (character == null || !character.enabled) {
      _logger.info('No enabled primary companion for user $userId');
      return;
    }

    await _executionCoordinator.run(
      userId: userId,
      characterId: character.id,
      action: () async {
        final factId = payload['fact_id'] as String?;
        final sourceEventId = payload['source_event_id'] as String? ??
            context.bizId ??
            '${factId ?? 'record'}:${payload['created_at_ts'] ?? 'unknown'}';
        await _workspaceService.enqueueObservation(
          userId: userId,
          character: character,
          sourceEventId: sourceEventId,
          source: CharacterObservationSources.userRecord,
          factId: factId,
          content: content,
          observedAt: dateTimeFromUnixSeconds(payload['created_at_ts']),
        );

        try {
          // A newer event also drains older pending observations. This lets a
          // character recover naturally after a temporary model failure.
          final pending = await _workspaceService.loadPendingObservations(
            userId,
            character.id,
          );
          for (final observation in pending) {
            await _observationDigester(
              userId: userId,
              character: character,
              observation: observation,
              workspaceService: _workspaceService,
            );
          }
        } catch (error, stackTrace) {
          _logger.severe(
            'Character perception failed for ${character.id}',
            error,
            stackTrace,
          );
          rethrowIfNonRetryable(error);
        }
      },
    );
  }
}

final CharacterPerceptionTaskHandler _defaultHandler =
    CharacterPerceptionTaskHandler();

Future<void> handleCharacterPerceptionImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) {
  return _defaultHandler(userId, payload, context);
}

Future<void> handleCharacterPerceptionFailure(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
  Object error,
  StackTrace? stackTrace,
) async {
  getLogger('CharacterPerceptionTaskHandler').severe(
    'Shadow character perception task ${context.taskId} failed permanently '
    'for user $userId',
    error,
    stackTrace,
  );
}
