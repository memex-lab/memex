import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memex/data/repositories/get_schedule_aggregation.dart';
import 'package:memex/data/repositories/get_schedule_refresh_state.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';
import 'package:memex/domain/models/schedule_refresh_state.dart';
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

typedef ScheduleAggregationLoader = Future<ScheduleAggregationModel?>
    Function();
typedef ScheduleAggregationFreshnessChecker = Future<bool> Function({
  Duration? maxAge,
});
typedef ScheduleAggregationRefresher = Future<Result<void>> Function();
typedef ScheduleRefreshStateLoader = Future<ScheduleRefreshState> Function();
typedef ScheduleCardDetailFetcher = Future<CardDetailModel> Function(
  String cardId,
);
typedef ScheduleCardUiConfigUpdater = Future<bool> Function(
  String cardId,
  int configIndex,
  Map<String, dynamic> data,
);

class ScheduleAggregatorViewModel extends ChangeNotifier {
  ScheduleAggregatorViewModel({
    ScheduleAggregationLoader? loadAggregation,
    ScheduleAggregationFreshnessChecker? needsRefresh,
    ScheduleAggregationRefresher? refreshAggregation,
    ScheduleRefreshStateLoader? loadRefreshState,
    ScheduleCardDetailFetcher? fetchCardDetail,
    ScheduleCardUiConfigUpdater? updateCardUiConfig,
    Duration refreshReloadDelay = const Duration(seconds: 90),
    bool listenToEvents = true,
  })  : _loadAggregation = loadAggregation ?? getScheduleAggregation,
        _needsRefresh = needsRefresh ?? scheduleAggregationNeedsRefresh,
        _refreshAggregation = refreshAggregation ??
            (() => MemexRouter().refreshScheduleAggregation()),
        _loadRefreshState = loadRefreshState ?? getScheduleRefreshState,
        _fetchCardDetail = fetchCardDetail ??
            ((cardId) => MemexRouter().fetchCardDetail(cardId)),
        _updateCardUiConfig = updateCardUiConfig ??
            ((cardId, configIndex, data) =>
                MemexRouter().updateCardUiConfig(cardId, configIndex, data)),
        _refreshReloadDelay = refreshReloadDelay,
        _listenToEvents = listenToEvents {
    if (_listenToEvents) {
      EventBusService.instance.addHandler(
        EventBusMessageType.scheduleAggregationUpdated,
        _handleScheduleAggregationUpdated,
      );
      EventBusService.instance.addHandler(
        EventBusMessageType.scheduleAggregationDirty,
        _handleScheduleAggregationDirty,
      );
    }
  }

  final ScheduleAggregationLoader _loadAggregation;
  final ScheduleAggregationFreshnessChecker _needsRefresh;
  final ScheduleAggregationRefresher _refreshAggregation;
  final ScheduleRefreshStateLoader _loadRefreshState;
  final ScheduleCardDetailFetcher _fetchCardDetail;
  final ScheduleCardUiConfigUpdater _updateCardUiConfig;
  final Duration _refreshReloadDelay;
  final bool _listenToEvents;

  ScheduleAggregationModel? _aggregation;
  bool _isLoading = false;
  String? _error;
  ScheduleRefreshState _refreshState = ScheduleRefreshState.clean();
  Completer<void>? _pendingRefreshCompletion;
  final Map<String, ScheduleItemStatus> _statusOverrides = {};

  ScheduleAggregationModel? get aggregation => _aggregation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _aggregation != null;
  bool get isDirty => _refreshState.isDirty;
  String? get dirtyReason => _refreshState.reason;
  List<ScheduleItem> get items {
    if (_aggregation == null) return const [];
    return ScheduleItem.fromAggregation(_aggregation!).map((item) {
      final status = _statusOverrides[item.id];
      if (status == null) return item;
      return item.copyWith(
        status: status,
        completedAt: status == ScheduleItemStatus.completed
            ? item.completedAt ?? DateTime.now()
            : item.completedAt,
        clearCompletedAt: status != ScheduleItemStatus.completed,
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
      _refreshState = await _loadRefreshState();
      _statusOverrides.clear();
      _error = null;
    } catch (e) {
      _logger.severe('Failed to load schedule aggregation: $e');
      _error = _localizedOrFallback(
        (l10n) => l10n.scheduleAggregationLoadFailed,
        'Failed to load schedule data',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh schedule aggregation by triggering the Agent
  Future<void> refreshAggregation() async {
    _setLoading(true);
    final completion = Completer<void>();
    _pendingRefreshCompletion = completion;
    try {
      // Trigger agent run via MemexRouter
      final result = await _refreshAggregation();
      final triggered = result.when(
        onOk: (_) {
          _logger.info('Schedule aggregation refresh triggered');
          return true;
        },
        onError: (e, st) {
          _logger.warning('Failed to trigger schedule aggregation: $e');
          _error = _localizedOrFallback(
            (l10n) => l10n.updateFailed(e.toString()),
            'Failed to update: $e',
          );
          return false;
        },
      );

      if (!triggered) {
        _pendingRefreshCompletion = null;
        return;
      }

      try {
        await completion.future.timeout(_refreshReloadDelay);
      } on TimeoutException {
        _logger.info('Schedule aggregation refresh wait timed out');
      }
      await loadAggregation();
    } catch (e) {
      _logger.severe('Failed to refresh schedule aggregation: $e');
      _error = _localizedOrFallback(
        (l10n) => l10n.scheduleAggregationRefreshFailed,
        'Failed to refresh schedule data',
      );
    } finally {
      if (identical(_pendingRefreshCompletion, completion)) {
        _pendingRefreshCompletion = null;
      }
      _setLoading(false);
    }
  }

  Future<void> toggleCompletion(ScheduleItem item) async {
    if (item.type != ScheduleItemType.todo) return;

    final nextStatus = item.status == ScheduleItemStatus.completed
        ? ScheduleItemStatus.pending
        : ScheduleItemStatus.completed;
    _applyStatusOverride(item.id, nextStatus);

    try {
      final detail = await _fetchCardDetail(item.id);
      final configIndex =
          detail.uiConfigs.indexWhere((config) => config.templateId == 'task');

      if (configIndex < 0) {
        throw Exception('No task ui_config found for ${item.id}');
      }

      final success = await _updateCardUiConfig(
        item.id,
        configIndex,
        {'is_completed': nextStatus == ScheduleItemStatus.completed},
      );

      if (!success) {
        throw Exception('Failed to update task card');
      }
      _error = null;
    } catch (e) {
      _logger.warning('Failed to toggle schedule item ${item.id}: $e');
      _statusOverrides[item.id] = item.status;
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

  void _handleScheduleAggregationUpdated(EventBusMessage message) {
    if (message is! ScheduleAggregationUpdatedMessage) return;
    final pending = _pendingRefreshCompletion;
    if (pending != null && !pending.isCompleted) {
      pending.complete();
      return;
    }
    unawaited(loadAggregation());
  }

  void _handleScheduleAggregationDirty(EventBusMessage message) {
    if (message is! ScheduleAggregationDirtyMessage) return;
    _refreshState = _refreshState.copyWith(
      isDirty: message.isDirty,
      reason: message.reason,
      cardIds: message.cardIds,
      clearReason: !message.isDirty,
      clearDirtySince: !message.isDirty,
    );
    notifyListeners();
  }

  void _applyStatusOverride(String itemId, ScheduleItemStatus status) {
    _statusOverrides[itemId] = status;
    notifyListeners();
  }

  void _setLoading(bool value) {
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
        _handleScheduleAggregationUpdated,
      );
      EventBusService.instance.removeHandler(
        EventBusMessageType.scheduleAggregationDirty,
        _handleScheduleAggregationDirty,
      );
    }
    super.dispose();
  }
}
