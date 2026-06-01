import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/schedule_state.dart';
import 'package:memex/utils/logger.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

import 'schedule_state_projector.dart';

/// Singleton wrapper around the typed `schedule_state.yaml` file.
///
/// Responsibilities:
///   * read / write the typed [ScheduleState];
///   * one-time initialization of the canonical schedule state;
///   * task-card completion sync for existing schedule todos;
///   * code-driven sweeps (auto-complete past events).
///
/// All mutations go through this service so the file content stays
/// consistent with the in-memory model.
class ScheduleStateService {
  ScheduleStateService._();

  static final ScheduleStateService instance = ScheduleStateService._();

  final _logger = getLogger('ScheduleStateService');
  final Set<String> _suppressedCardCompletionSyncKeys = <String>{};
  final Lock _lock = Lock(reentrant: true);

  /// Read the current state, returning [ScheduleState.empty] when the file
  /// is absent.
  Future<ScheduleState> read(String userId) async {
    final raw = await FileSystemService.instance.readScheduleStateRaw(userId);
    if (raw == null) return ScheduleState.empty();
    try {
      return ScheduleState.fromJson(raw);
    } catch (e, st) {
      _logger.warning(
        'Failed to decode schedule_state, falling back to empty',
        e,
        st,
      );
      return ScheduleState.empty();
    }
  }

  Future<void> write(String userId, ScheduleState state) async {
    await FileSystemService.instance.writeScheduleStateRaw(
      userId,
      state.toJson(),
    );
  }

  bool isCardCompletionSyncSuppressed({
    required String userId,
    required String factId,
  }) {
    return _suppressedCardCompletionSyncKeys.contains(
      _cardCompletionSyncKey(userId, factId),
    );
  }

  /// Ensure a schedule_state file exists for this user. Existing files are left
  /// intact and only receive the time-based past-event sweep.
  Future<ScheduleState> ensureInitialized(
    String userId, {
    DateTime? now,
  }) async {
    return _lock.synchronized(() async {
      final raw = await FileSystemService.instance.readScheduleStateRaw(userId);
      if (raw == null) {
        return migrateLegacyDataOnce(userId, now: now);
      }
      return sweepPastEvents(userId, now: now);
    });
  }

  /// One-time schedule_state initialization. Once a schedule_state file exists,
  /// this is never run again.
  Future<ScheduleState> migrateLegacyDataOnce(
    String userId, {
    DateTime? now,
  }) async {
    return _lock.synchronized(() async {
      final raw = await FileSystemService.instance.readScheduleStateRaw(userId);
      if (raw != null) {
        return read(userId);
      }
      final clock = now ?? DateTime.now();
      final state = ScheduleState(generatedAt: clock);
      await write(userId, state);
      _logger.info('Schedule state initialized without card import');
      return state;
    });
  }

  /// Fully rebuild the schedule_state from no external inputs. This is for
  /// explicit repair/debug flows.
  Future<ScheduleState> rebuildFromCards(String userId, {DateTime? now}) async {
    return _lock.synchronized(() async {
      final clock = now ?? DateTime.now();
      final state = ScheduleState(generatedAt: clock);
      await write(userId, state);
      _logger.info('Schedule state rebuilt without legacy card migration');
      return state;
    });
  }

  /// Mirror a task card completion into existing schedule todos sourced from
  /// that card. This never creates schedule items from card data.
  Future<ScheduleState> completeTodosForSourceFact({
    required String userId,
    required String factId,
    DateTime? now,
  }) async {
    return _lock.synchronized(() async {
      final clock = now ?? DateTime.now();
      final current = await read(userId);
      final matching = current.pending
          .where((item) => item.isTodo && item.sourceFactIds.contains(factId))
          .toList();
      if (matching.isEmpty) {
        _logger.info(
          'Task card completion sync no-op, factId=$factId: no matching pending todo',
        );
        return current;
      }

      final matchingIds = matching.map((item) => item.id).toSet();
      final pending = current.pending
          .where((item) => !matchingIds.contains(item.id))
          .toList();
      final completed = [
        for (final item in matching)
          ScheduleCompletedItem(
            id: item.id,
            kind: item.kind,
            title: item.title,
            closedAt: clock,
            closedByFactId: factId,
            pendingSnapshot: item.copyWith(clearDeviceActionId: true),
            sourceFactIds: item.sourceFactIds,
          ),
        ...current.completed,
      ]..sort((a, b) => b.closedAt.compareTo(a.closedAt));

      final updated = current.copyWith(
        generatedAt: clock,
        pending: pending,
        completed: completed,
      );
      await write(userId, updated);
      _logger.info(
        'Task card completion synced to schedule_state, factId=$factId, '
        'pending ${current.pending.length}->${updated.pending.length}, '
        'completed ${current.completed.length}->${updated.completed.length}',
      );
      return updated;
    });
  }

  /// Run only the past-event sweep. Useful on app launch / periodic ticks
  /// where we know cards have not changed but time has moved on.
  Future<ScheduleState> sweepPastEvents(String userId, {DateTime? now}) async {
    return _lock.synchronized(() async {
      final clock = now ?? DateTime.now();
      final current = await read(userId);
      final swept = sweepPastEventsInState(current, now: clock);
      if (identical(swept, current)) return current;
      await write(userId, swept);
      return swept;
    });
  }

  Future<ScheduleState> addPendingItem({
    required String userId,
    required String kind,
    required String title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? dueAt,
    String? location,
    int? priority,
    List<ScheduleSubtask>? subtasks,
    required String sourceFactId,
    bool syncDeviceAction = false,
    DateTime? now,
  }) async {
    return _lock.synchronized(() async {
      final clock = now ?? DateTime.now();
      var item = SchedulePendingItem(
        id: 'pi_${const Uuid().v4().substring(0, 8)}',
        kind: kind,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        dueAt: dueAt,
        location: location,
        priority: priority,
        subtasks: subtasks,
        sourceFactIds: [sourceFactId],
        createdAt: clock,
        updatedAt: clock,
        syncDeviceAction: syncDeviceAction,
      );
      item = await _maintainDeviceAction(userId, item);

      final state = await read(userId);
      final pending = [...state.pending, item]
        ..sort(compareSchedulePendingItems);
      final updated = state.copyWith(generatedAt: clock, pending: pending);
      await write(userId, updated);
      _logger.info(
        'Schedule pending item added, userId=$userId, itemId=${item.id}, '
        'sourceFactId=$sourceFactId, kind=${item.kind}, title=${item.title}, '
        'pending ${state.pending.length}->${updated.pending.length}',
      );
      return updated;
    });
  }

  Future<ScheduleState> updatePendingItem({
    required String userId,
    required String pendingId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? dueAt,
    String? location,
    int? priority,
    List<ScheduleSubtask>? subtasks,
    bool? syncDeviceAction,
    DateTime? now,
    bool clearDescription = false,
    bool clearStartTime = false,
    bool clearEndTime = false,
    bool clearDueAt = false,
    bool clearLocation = false,
    bool clearPriority = false,
  }) async {
    return _lock.synchronized(() async {
      final clock = now ?? DateTime.now();
      final state = await read(userId);
      final index = state.pending.indexWhere((item) => item.id == pendingId);
      if (index < 0) {
        throw StateError('No pending schedule item found: $pendingId');
      }

      var item = state.pending[index].copyWith(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        dueAt: dueAt,
        location: location,
        priority: priority,
        subtasks: subtasks,
        syncDeviceAction: syncDeviceAction,
        updatedAt: clock,
        clearDescription: clearDescription,
        clearStartTime: clearStartTime,
        clearEndTime: clearEndTime,
        clearDueAt: clearDueAt,
        clearLocation: clearLocation,
        clearPriority: clearPriority,
      );
      item = await _maintainDeviceAction(userId, item);

      final pending = state.pending.toList();
      pending[index] = item;
      pending.sort(compareSchedulePendingItems);
      final updated = state.copyWith(generatedAt: clock, pending: pending);
      await write(userId, updated);
      return updated;
    });
  }

  Future<ScheduleState> completePendingItem({
    required String userId,
    required String pendingId,
    String? closedByFactId,
    DateTime? closedAt,
  }) async {
    return _lock.synchronized(() async {
      final clock = closedAt ?? DateTime.now();
      final state = await read(userId);
      final item = state.pending.firstWhere(
        (candidate) => candidate.id == pendingId,
        orElse: () =>
            throw StateError('No pending schedule item found: $pendingId'),
      );

      if (item.deviceActionId != null) {
        await _cancelPendingDeviceAction(item.deviceActionId!);
      }

      final completed = [
        ScheduleCompletedItem(
          id: item.id,
          kind: item.kind,
          title: item.title,
          closedAt: clock,
          closedByFactId: closedByFactId,
          pendingSnapshot: item.copyWith(clearDeviceActionId: true),
          sourceFactIds: item.sourceFactIds,
        ),
        ...state.completed,
      ]..sort((a, b) => b.closedAt.compareTo(a.closedAt));
      final pending = state.pending
          .where((candidate) => candidate.id != pendingId)
          .toList();

      final updated = state.copyWith(
        generatedAt: clock,
        pending: pending,
        completed: completed,
      );

      final sourceFactId = item.sourceFactIds.isEmpty
          ? null
          : item.sourceFactIds.first;
      if (sourceFactId != null && item.isTodo) {
        await _withSuppressedCardCompletionSync(
          userId: userId,
          factId: sourceFactId,
          action: () =>
              _setSourceTaskCompletion(userId, sourceFactId, completed: true),
        );
      }
      await write(userId, updated);
      return updated;
    });
  }

  Future<ScheduleState> restoreCompletedItem({
    required String userId,
    required String completedId,
    DateTime? now,
  }) async {
    return _lock.synchronized(() async {
      final clock = now ?? DateTime.now();
      final state = await read(userId);
      final item = state.completed.firstWhere(
        (candidate) => candidate.id == completedId,
        orElse: () =>
            throw StateError('No completed schedule item found: $completedId'),
      );

      var restored =
          (item.pendingSnapshot ??
                  SchedulePendingItem(
                    id: item.id,
                    kind: item.kind,
                    title: item.title,
                    sourceFactIds: item.sourceFactIds,
                    createdAt: item.closedAt,
                    updatedAt: clock,
                  ))
              .copyWith(updatedAt: clock, clearDeviceActionId: true);
      restored = await _maintainDeviceAction(userId, restored);

      final pending = [
        ...state.pending.where((candidate) => candidate.id != restored.id),
        restored,
      ]..sort(compareSchedulePendingItems);
      final completed = state.completed
          .where((candidate) => candidate.id != completedId)
          .toList();
      final updated = state.copyWith(
        generatedAt: clock,
        pending: pending,
        completed: completed,
      );

      final sourceFactId = restored.sourceFactIds.isEmpty
          ? null
          : restored.sourceFactIds.first;
      if (sourceFactId != null && restored.isTodo) {
        await _withSuppressedCardCompletionSync(
          userId: userId,
          factId: sourceFactId,
          action: () => _setSourceTaskCompletion(
            userId,
            sourceFactId,
            completed: false,
            restoredItem: restored,
          ),
        );
      }

      await write(userId, updated);
      return updated;
    });
  }

  Future<ScheduleState> completeSubtask({
    required String userId,
    required String pendingId,
    required String subtaskTitle,
    required String closedByFactId,
    DateTime? closedAt,
  }) async {
    return setSubtaskCompletion(
      userId: userId,
      pendingId: pendingId,
      subtaskTitle: subtaskTitle,
      completed: true,
      changedByFactId: closedByFactId,
      changedAt: closedAt,
    );
  }

  Future<ScheduleState> setSubtaskCompletion({
    required String userId,
    required String pendingId,
    required String subtaskTitle,
    required bool completed,
    String? changedByFactId,
    DateTime? changedAt,
  }) async {
    return _lock.synchronized(() async {
      final clock = changedAt ?? DateTime.now();
      final state = await read(userId);
      final item = state.pending.firstWhere(
        (candidate) => candidate.id == pendingId,
        orElse: () =>
            throw StateError('No pending schedule item found: $pendingId'),
      );
      final index = item.subtasks.indexWhere(
        (subtask) =>
            _normalizeTitle(subtask.title) == _normalizeTitle(subtaskTitle),
      );
      if (index < 0) {
        throw StateError('No subtask "$subtaskTitle" found on $pendingId');
      }

      final subtasks = item.subtasks.toList();
      subtasks[index] = subtasks[index].copyWith(
        completed: completed,
        closedByFactId: completed ? changedByFactId : null,
        clearClosedByFactId: !completed,
      );

      if (subtasks.every((subtask) => subtask.completed)) {
        return completePendingItem(
          userId: userId,
          pendingId: pendingId,
          closedByFactId: changedByFactId,
          closedAt: clock,
        );
      }

      final pending =
          state.pending
              .map(
                (candidate) => candidate.id == pendingId
                    ? candidate.copyWith(subtasks: subtasks, updatedAt: clock)
                    : candidate,
              )
              .toList()
            ..sort(compareSchedulePendingItems);
      final updated = state.copyWith(generatedAt: clock, pending: pending);
      await write(userId, updated);
      return updated;
    });
  }

  Future<ScheduleState> setPresentation({
    required String userId,
    required SchedulePresentation presentation,
    DateTime? now,
  }) async {
    return _lock.synchronized(() async {
      final clock = now ?? DateTime.now();
      final state = await read(userId);
      final updated = state.copyWith(
        generatedAt: clock,
        presentation: presentation,
      );
      await write(userId, updated);
      _logger.info(
        'Schedule presentation updated, userId=$userId, '
        'pending=${updated.pending.length}, completed=${updated.completed.length}',
      );
      return updated;
    });
  }

  Future<List<ScheduleCompletedItem>> searchCompleted({
    required String userId,
    String? query,
    DateTime? since,
    int limit = 20,
  }) async {
    final normalizedQuery = query == null ? null : _normalizeTitle(query);
    final state = await read(userId);
    final matches = state.completed.where((item) {
      if (since != null && item.closedAt.isBefore(since)) return false;
      if (normalizedQuery == null || normalizedQuery.isEmpty) return true;
      return _normalizeTitle(item.title).contains(normalizedQuery);
    }).toList()..sort((a, b) => b.closedAt.compareTo(a.closedAt));
    return matches.take(limit).toList();
  }

  Future<SchedulePendingItem> _maintainDeviceAction(
    String userId,
    SchedulePendingItem item,
  ) async {
    if (!item.syncDeviceAction) {
      if (item.deviceActionId != null) {
        await _cancelPendingDeviceAction(item.deviceActionId!);
      }
      return item.copyWith(clearDeviceActionId: true);
    }

    if (item.deviceActionId != null) {
      final existingAction = await SystemActionService.instance.getAction(
        item.deviceActionId!,
      );
      if (existingAction != null && existingAction.status != 'pending') {
        return item;
      }
      await _cancelPendingDeviceAction(item.deviceActionId!);
    }

    final trigger = item.isEvent ? item.startTime : item.dueAt;
    if (trigger == null || !trigger.isAfter(DateTime.now())) {
      return item.copyWith(clearDeviceActionId: true);
    }

    try {
      final actionId = const Uuid().v4();
      final sourceFactId = item.sourceFactIds.isEmpty
          ? null
          : item.sourceFactIds.first;
      if (item.isEvent) {
        await SystemActionService.instance.createAction(
          id: actionId,
          type: 'calendar',
          factId: sourceFactId,
          data: {
            'title': item.title,
            'start_time': item.startTime?.toIso8601String(),
            'end_time': item.endTime?.toIso8601String(),
            'location': item.location,
            'notes': item.description,
            'all_day': false,
          },
        );
      } else {
        await SystemActionService.instance.createAction(
          id: actionId,
          type: 'reminder',
          factId: sourceFactId,
          data: {
            'title': item.title,
            'due_date': item.dueAt?.toIso8601String(),
            'notes': item.description,
          },
        );
      }
      return item.copyWith(deviceActionId: actionId);
    } catch (e, st) {
      _logger.warning('Failed to maintain device action for ${item.id}', e, st);
      return item.copyWith(clearDeviceActionId: true);
    }
  }

  Future<void> _cancelPendingDeviceAction(String actionId) async {
    try {
      await SystemActionService.instance.cancelPendingAction(actionId);
    } catch (e, st) {
      _logger.warning(
        'Failed to cancel pending device action $actionId',
        e,
        st,
      );
    }
  }

  Future<void> _setSourceTaskCompletion(
    String userId,
    String cardId, {
    required bool completed,
    SchedulePendingItem? restoredItem,
  }) async {
    await FileSystemService.instance.updateCardFile(userId, cardId, (card) {
      final taskIndex = card.uiConfigs.indexWhere(
        (config) => config.templateId == 'task',
      );
      if (taskIndex < 0) return card;
      final config = card.uiConfigs[taskIndex];
      final data = Map<String, dynamic>.from(config.data);
      data['is_completed'] = completed;
      final rawSubtasks = data['subtasks'];
      if (rawSubtasks is List) {
        final restoredSubtasks = {
          for (final subtask in restoredItem?.subtasks ?? const [])
            _normalizeTitle(subtask.title): subtask.completed,
        };
        data['subtasks'] = rawSubtasks.whereType<Map>().map((subtask) {
          final normalized = _normalizeTitle(
            subtask['title']?.toString() ?? '',
          );
          return {
            ...Map<String, dynamic>.from(subtask),
            'completed': completed
                ? true
                : (restoredSubtasks[normalized] ?? false),
          };
        }).toList();
      }
      final configs = card.uiConfigs.toList();
      configs[taskIndex] = UiConfig(templateId: config.templateId, data: data);
      return card.copyWith(uiConfigs: configs);
    });
  }
}

Future<T> _withSuppressedCardCompletionSync<T>({
  required String userId,
  required String factId,
  required Future<T> Function() action,
}) async {
  final service = ScheduleStateService.instance;
  final key = _cardCompletionSyncKey(userId, factId);
  service._suppressedCardCompletionSyncKeys.add(key);
  try {
    return await action();
  } finally {
    service._suppressedCardCompletionSyncKeys.remove(key);
  }
}

String _cardCompletionSyncKey(String userId, String factId) =>
    '$userId::$factId';

int compareSchedulePendingItems(SchedulePendingItem a, SchedulePendingItem b) {
  final aAnchor = a.startTime ?? a.dueAt;
  final bAnchor = b.startTime ?? b.dueAt;
  if (aAnchor == null && bAnchor == null) {
    return a.createdAt.compareTo(b.createdAt);
  }
  if (aAnchor == null) return 1;
  if (bAnchor == null) return -1;
  return aAnchor.compareTo(bAnchor);
}

String _normalizeTitle(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
