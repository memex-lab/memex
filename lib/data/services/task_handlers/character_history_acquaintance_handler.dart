import 'package:memex/agent/character_agent/character_agent.dart';
import 'package:memex/data/services/character_execution_coordinator.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/logger.dart';

typedef CharacterHistoryAcquainter = Future<void> Function({
  required String userId,
  required CharacterModel character,
  CharacterWorkspaceService? workspaceService,
});

class CharacterHistoryAcquaintanceTaskHandler {
  CharacterHistoryAcquaintanceTaskHandler({
    CharacterWorkspaceService? workspaceService,
    Future<CharacterModel?> Function(String userId, String characterId)?
        characterLoader,
    CharacterHistoryAcquainter? acquaint,
    CharacterExecutionCoordinator? executionCoordinator,
  })  : _workspaceService =
            workspaceService ?? CharacterWorkspaceService.instance,
        _characterLoader = characterLoader ??
            ((userId, characterId) =>
                CharacterService.instance.getCharacter(userId, characterId)),
        _acquaint = acquaint ?? CharacterAgent.acquaintWithHistory,
        _executionCoordinator =
            executionCoordinator ?? CharacterExecutionCoordinator.instance;

  final CharacterWorkspaceService _workspaceService;
  final Future<CharacterModel?> Function(String, String) _characterLoader;
  final CharacterHistoryAcquainter _acquaint;
  final CharacterExecutionCoordinator _executionCoordinator;

  Future<void> call(
    String userId,
    Map<String, dynamic> payload,
    TaskContext context,
  ) async {
    final characterId = payload['character_id'] as String?;
    if (characterId == null || characterId.trim().isEmpty) {
      throw ArgumentError(
        'character_history_acquaintance_task needs character_id.',
      );
    }
    final character = await _characterLoader(userId, characterId);
    if (character == null || !character.enabled) return;

    await _executionCoordinator.run(
      userId: userId,
      characterId: characterId,
      action: () async {
        if (await _workspaceService.isHistoryAcquaintanceComplete(
          userId,
          characterId,
        )) {
          return;
        }
        try {
          await _acquaint(
            userId: userId,
            character: character,
            workspaceService: _workspaceService,
          );
        } catch (error) {
          rethrowIfNonRetryable(error);
        }
      },
    );
  }
}

final CharacterHistoryAcquaintanceTaskHandler _defaultHandler =
    CharacterHistoryAcquaintanceTaskHandler();

Future<void> handleCharacterHistoryAcquaintanceImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) {
  return _defaultHandler(userId, payload, context);
}

Future<void> handleCharacterHistoryAcquaintanceFailure(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
  Object error,
  StackTrace? stackTrace,
) async {
  getLogger('CharacterHistoryAcquaintanceTaskHandler').severe(
    'Character history acquaintance ${context.taskId} failed permanently',
    error,
    stackTrace,
  );
}
