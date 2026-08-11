import 'package:flutter/foundation.dart';
import 'package:memex/data/services/local_task_executor.dart';

class CharacterInitiativeService {
  CharacterInitiativeService._({
    required LocalTaskExecutor taskExecutor,
    required DateTime Function() clock,
  })  : _taskExecutor = taskExecutor,
        _clock = clock;

  static final CharacterInitiativeService instance =
      CharacterInitiativeService._(
    taskExecutor: LocalTaskExecutor.instance,
    clock: DateTime.now,
  );

  @visibleForTesting
  factory CharacterInitiativeService.forTesting({
    required LocalTaskExecutor taskExecutor,
    DateTime Function()? clock,
  }) {
    return CharacterInitiativeService._(
      taskExecutor: taskExecutor,
      clock: clock ?? DateTime.now,
    );
  }

  static const taskType = 'character_initiative_task';
  static const taskBizId = 'character_initiative_wake:primary';
  static const _bootstrapReason =
      'Restore your own ongoing rhythm of contact from recent interaction '
      'and memory.';

  final LocalTaskExecutor _taskExecutor;
  final DateTime Function() _clock;

  /// Restores the primary companion's wake loop after an upgrade or restart.
  /// Existing pending or processing work is left at the time the character
  /// previously chose.
  Future<void> ensureScheduled({required String userId}) async {
    final hasWake = await _taskExecutor.hasActiveTask(
      taskType: taskType,
      bizId: taskBizId,
    );
    if (hasWake) return;

    final now = _clock();
    await _enqueueWake(
      userId: userId,
      wakeAt: now,
      reason: _bootstrapReason,
    );
  }

  Future<void> scheduleNextWake({
    required String userId,
    required DateTime wakeAt,
    required String reason,
  }) async {
    final now = _clock();
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'Must not be empty.');
    }
    await _enqueueWake(
      userId: userId,
      // A short wake can become due while the model is still thinking. In
      // that case the character should wake immediately, not lose the loop.
      wakeAt: wakeAt.isAfter(now) ? wakeAt : now,
      reason: normalizedReason,
    );
  }

  /// Defers the current initiative task without losing its source or pending
  /// thought identity while Conversation owns an unanswered user turn.
  Future<void> scheduleConversationDeferredRetry({
    required String userId,
    required String characterId,
    required Map<String, dynamic> payload,
    required DateTime retryAt,
    required String reason,
  }) {
    final retryPayload = Map<String, dynamic>.from(payload)
      ..['character_id'] = characterId
      ..['wake_reason'] = reason;
    return _taskExecutor.enqueueOrRescheduleTask(
      userId: userId,
      taskType: taskType,
      payload: retryPayload,
      bizId: taskBizId,
      scheduledAt: retryAt.millisecondsSinceEpoch ~/ 1000,
      maxRetries: 3,
    );
  }

  Future<void> _enqueueWake({
    required String userId,
    required DateTime wakeAt,
    required String reason,
  }) {
    return _taskExecutor.enqueueOrRescheduleTask(
      userId: userId,
      taskType: taskType,
      payload: {
        'source_event_id': 'character_wake:${wakeAt.microsecondsSinceEpoch}',
        'wake_reason': reason,
        'scheduled_wake_at': wakeAt.toIso8601String(),
      },
      bizId: taskBizId,
      scheduledAt: wakeAt.millisecondsSinceEpoch ~/ 1000,
      maxRetries: 3,
    );
  }
}
