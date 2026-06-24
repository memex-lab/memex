import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memex/data/repositories/get_schedule_view_data.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/schedule_state.dart' show ScheduleSubtask;
import 'package:memex/domain/models/schedule_view_data.dart';
import 'package:memex/l10n/app_localizations_ext.dart';
import 'package:memex/ui/schedule/models/schedule_item.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('ScheduleAggregatorViewModel');

String _localizedOrFallback(
  String Function(AppLocalizationsExt l10n) resolve,
  String fallback,
) {
  try {
    return resolve(UserStorage.l10n);
  } catch (_) {
    return fallback;
  }
}

typedef ScheduleAggregationLoader = Future<ScheduleViewData?> Function();
typedef ScheduleAggregationFreshnessChecker = Future<bool> Function(
    {Duration? maxAge});
typedef ScheduleItemCompleter = Future<Result<void>> Function(String itemId);
typedef ScheduleCompletedItemRestorer = Future<Result<void>> Function(
    String itemId);
typedef ScheduleSubtaskCompletionSetter = Future<Result<void>> Function(
  String itemId,
  String subtaskTitle,
  bool completed,
);

class ScheduleAggregatorViewModel extends ChangeNotifier {
  ScheduleAggregatorViewModel({
    ScheduleAggregationLoader? loadAggregation,
    ScheduleAggregationFreshnessChecker? needsRefresh,
    ScheduleItemCompleter? completeScheduleItem,
    ScheduleCompletedItemRestorer? restoreScheduleItem,
    ScheduleSubtaskCompletionSetter? setScheduleSubtaskCompletion,
    bool listenToEvents = true,
  })  : _loadAggregation = loadAggregation ?? getScheduleViewData,
        _needsRefresh = needsRefresh ?? scheduleViewDataNeedsRefresh,
        _completeScheduleItem = completeScheduleItem ??
            ((itemId) => MemexRouter().completeScheduleItem(itemId)),
        _restoreScheduleItem = restoreScheduleItem ??
            ((itemId) => MemexRouter().restoreScheduleItem(itemId)),
        _setScheduleSubtaskCompletion = setScheduleSubtaskCompletion ??
            ((itemId, subtaskTitle, completed) =>
                MemexRouter().setScheduleSubtaskCompletion(
                  itemId: itemId,
                  subtaskTitle: subtaskTitle,
                  completed: completed,
                )),
        _listenToEvents = listenToEvents {
    if (_listenToEvents) {
      EventBusService.instance.addHandler(
        EventBusMessageType.scheduleAggregationUpdated,
        _handleScheduleDataUpdated,
      );
    }
  }

  final ScheduleAggregationLoader _loadAggregation;
  final ScheduleAggregationFreshnessChecker _needsRefresh;
  final ScheduleItemCompleter _completeScheduleItem;
  final ScheduleCompletedItemRestorer _restoreScheduleItem;
  final ScheduleSubtaskCompletionSetter _setScheduleSubtaskCompletion;
  final bool _listenToEvents;

  ScheduleViewData? _aggregation;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;
  final Map<String, ScheduleItemStatus> _statusOverrides = {};
  final Map<String, List<ScheduleSubtask>> _subtaskOverrides = {};

  ScheduleViewData? get aggregation => _aggregation;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  bool get hasData => _aggregation != null;
  List<ScheduleItem> get items {
    if (_aggregation == null) return const [];
    return ScheduleItem.fromViewData(_aggregation!).map((item) {
      final subtasks = _subtaskOverrides[item.itemId];
      final status = _statusOverrides[item.itemId];
      if (status == null && subtasks == null) return item;
      final effectiveSubtasks = subtasks ?? item.subtasks;
      final effectiveStatus = status ??
          (subtasks == null
              ? item.status
              : ScheduleItem.deriveTodoStatus(
                  effectiveSubtasks,
                  fallback: item.status,
                ));
      return item.copyWith(
        status: effectiveStatus,
        subtasks: effectiveSubtasks,
        completedAt: effectiveStatus == ScheduleItemStatus.completed
            ? item.completedAt ?? DateTime.now()
            : item.completedAt,
        clearCompletedAt: effectiveStatus != ScheduleItemStatus.completed,
      );
    }).toList();
  }

  List<ScheduleItem> get todayItems {
    final now = DateTime.now();
    return items.where((item) {
      final itemTime = item.startTime ?? item.completedAt;
      if (itemTime == null) return false;
      return itemTime.year == now.year &&
          itemTime.month == now.month &&
          itemTime.day == now.day;
    }).toList();
  }

  /// Load schedule aggregation from disk
  Future<void> loadAggregation() async {
    _setLoading(true);
    try {
      _aggregation = await _loadAggregation();
      _statusOverrides.clear();
      _subtaskOverrides.clear();
      _error = null;
    } catch (e) {
      _logger.severe('Failed to load schedule aggregation: $e');
      _error = _localizedOrFallback(
        (l10n) => l10n.scheduleAggregationLoadFailed,
        'Failed to load schedule data',
      );
    } finally {
      _hasLoaded = true;
      _setLoading(false);
    }
  }

  Future<void> toggleCompletion(ScheduleItem item) async {
    if (item.type != ScheduleItemType.todo) return;

    final nextStatus = item.status == ScheduleItemStatus.completed
        ? ScheduleItemStatus.pending
        : ScheduleItemStatus.completed;
    final nextCompleted = nextStatus == ScheduleItemStatus.completed;
    final previousStatusOverride = _statusOverrides[item.itemId];
    final previousSubtaskOverride = _subtaskOverrides[item.itemId];
    final optimisticSubtasks = item.subtasks.isEmpty
        ? null
        : item.subtasks
            .map((subtask) => subtask.copyWith(completed: nextCompleted))
            .toList();
    _applyTaskOverride(
      item.itemId,
      status: nextStatus,
      subtasks: optimisticSubtasks,
    );

    try {
      if (nextCompleted) {
        _throwOnError(await _completeScheduleItem(item.itemId));
      } else {
        for (final subtask in item.subtasks) {
          if (!subtask.completed) continue;
          _throwOnError(
            await _setScheduleSubtaskCompletion(
              item.itemId,
              subtask.title,
              false,
            ),
          );
        }
      }
      _error = null;
    } catch (e) {
      _logger.warning(
        'Failed to toggle schedule item ${item.sourceFactId}: $e',
      );
      _restoreTaskOverrides(
        item.itemId,
        previousStatusOverride,
        previousSubtaskOverride,
      );
      _error = _localizedOrFallback(
        (l10n) => l10n.scheduleTaskUpdateFailed,
        'Failed to update task',
      );
      notifyListeners();
    }
  }

  Future<void> restoreCompletedItem(String itemId) async {
    try {
      _throwOnError(await _restoreScheduleItem(itemId));
      _error = null;
      await loadAggregation();
    } catch (e) {
      _logger.warning('Failed to restore schedule item $itemId: $e');
      _error = _localizedOrFallback(
        (l10n) => l10n.scheduleTaskUpdateFailed,
        'Failed to update task',
      );
      notifyListeners();
    }
  }

  Future<void> toggleSubtask(ScheduleItem item, int subtaskIndex) async {
    if (item.type != ScheduleItemType.todo) return;
    if (subtaskIndex < 0 || subtaskIndex >= item.subtasks.length) return;

    final previousStatusOverride = _statusOverrides[item.itemId];
    final previousSubtaskOverride = _subtaskOverrides[item.itemId];
    final nextSubtasks = item.subtasks.toList();
    final currentSubtask = nextSubtasks[subtaskIndex];
    nextSubtasks[subtaskIndex] = currentSubtask.copyWith(
      completed: !currentSubtask.completed,
    );
    final nextStatus = ScheduleItem.deriveTodoStatus(
      nextSubtasks,
      fallback: item.status,
    );
    _applyTaskOverride(item.itemId, status: nextStatus, subtasks: nextSubtasks);

    try {
      _throwOnError(
        await _setScheduleSubtaskCompletion(
          item.itemId,
          currentSubtask.title,
          !currentSubtask.completed,
        ),
      );
      _error = null;
    } catch (e) {
      _logger.warning(
        'Failed to toggle schedule subtask $subtaskIndex for ${item.sourceFactId}: $e',
      );
      _restoreTaskOverrides(
        item.itemId,
        previousStatusOverride,
        previousSubtaskOverride,
      );
      _error = _localizedOrFallback(
        (l10n) => l10n.scheduleTaskUpdateFailed,
        'Failed to update task',
      );
      notifyListeners();
    }
  }

  /// Check if data needs refresh and load if needed
  Future<void> ensureFresh({Duration? maxAge}) async {
    final needsRefresh = await _needsRefresh(maxAge: maxAge);
    if (needsRefresh || _aggregation == null) {
      await loadAggregation();
    }
  }

  void _handleScheduleDataUpdated(EventBusMessage message) {
    if (message is! ScheduleAggregationUpdatedMessage) return;
    unawaited(loadAggregation());
  }

  void _applyTaskOverride(
    String itemId, {
    required ScheduleItemStatus status,
    List<ScheduleSubtask>? subtasks,
  }) {
    _statusOverrides[itemId] = status;
    if (subtasks != null) {
      _subtaskOverrides[itemId] = subtasks;
    }
    notifyListeners();
  }

  void _restoreTaskOverrides(
    String itemId,
    ScheduleItemStatus? statusOverride,
    List<ScheduleSubtask>? subtaskOverride,
  ) {
    if (statusOverride == null) {
      _statusOverrides.remove(itemId);
    } else {
      _statusOverrides[itemId] = statusOverride;
    }
    if (subtaskOverride == null) {
      _subtaskOverrides.remove(itemId);
    } else {
      _subtaskOverrides[itemId] = subtaskOverride;
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_listenToEvents) {
      EventBusService.instance.removeHandler(
        EventBusMessageType.scheduleAggregationUpdated,
        _handleScheduleDataUpdated,
      );
    }
    super.dispose();
  }
}

void _throwOnError(Result<void> result) {
  result.when(onOk: (_) {}, onError: (e, st) => throw e);
}
