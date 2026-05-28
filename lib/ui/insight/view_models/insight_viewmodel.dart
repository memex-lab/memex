import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:memex/domain/models/knowledge_insight_card.dart';
import 'package:memex/domain/models/user_stats_model.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

enum InsightSection { insights, stats }

typedef UserStatsFetcher =
    Future<Result<UserStatsSnapshot>> Function(UserStatsDateRange range);

/// ViewModel for the Insight page. Holds insight list, pin/delete/reorder state.
class InsightViewModel extends ChangeNotifier {
  InsightViewModel({
    required MemexRouter router,
    UserStatsFetcher? userStatsFetcher,
  }) : _router = router,
       _userStatsFetcher =
           userStatsFetcher ??
           ((range) => router.fetchUserStats(range: range)) {
    EventBusService.instance.addHandler(
      EventBusMessageType.newInsight,
      _handleNewInsightEvent,
    );
    EventBusService.instance.addHandler(
      EventBusMessageType.cardAdded,
      _handleActivityChangedEvent,
    );
    EventBusService.instance.addHandler(
      EventBusMessageType.cardUpdated,
      _handleActivityChangedEvent,
    );
  }

  final MemexRouter _router;
  final UserStatsFetcher _userStatsFetcher;

  List<KnowledgeInsightCard>? insights;
  InsightSection selectedSection = InsightSection.insights;
  bool isLoading = true;
  String? errorMessage;
  String? activeCardId;
  bool isDeleting = false;
  bool isRefreshing = false;
  bool isReordering = false;
  TaskActivitySnapshot taskActivity = const TaskActivitySnapshot.empty();
  final Set<String> pinningIds = {};
  UserStatsDateRange statsRange = UserStatsDateRange.lastDays(7);
  UserStatsSnapshot? statsSnapshot;
  bool isStatsLoading = false;
  String? statsErrorMessage;
  UserStatsMetric selectedStatsMetric = UserStatsMetric.inputs;
  int _statsLoadGeneration = 0;

  int get activeTaskCount => taskActivity.total;
  bool get hasActiveTaskBacklog => activeTaskCount > 0;

  void _handleNewInsightEvent(EventBusMessage message) {
    if (message is! NewInsightMessage) return;
    unawaited(_reloadAfterInsightUpdated());
  }

  void _handleActivityChangedEvent(EventBusMessage message) {
    unawaited(refreshStatsForVisibleInsightPage());
  }

  Future<void> _reloadAfterInsightUpdated() async {
    await loadData();
    if (isRefreshing) {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final result = await _router.fetchKnowledgeInsights();
    await refreshTaskActivity(notify: false);
    await loadStats(notify: false);
    result.when(
      onOk: (list) {
        insights = list;
        errorMessage = null;
      },
      onError: (_, __) {
        errorMessage = UserStorage.l10n.dataLoadFailedRetry;
      },
    );
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshTaskActivity({bool notify = true}) async {
    try {
      taskActivity = await _router.getTaskActivitySnapshot();
    } catch (_) {
      taskActivity = const TaskActivitySnapshot.empty();
    }
    if (notify) notifyListeners();
  }

  Future<void> loadStats({
    bool notify = true,
    UserStatsDateRange? range,
  }) async {
    final requestGeneration = ++_statsLoadGeneration;
    final requestRange = range ?? statsRange;
    isStatsLoading = true;
    statsErrorMessage = null;
    if (notify) notifyListeners();

    final result = await _userStatsFetcher(requestRange);
    if (requestGeneration != _statsLoadGeneration) {
      return;
    }

    result.when(
      onOk: (snapshot) {
        statsSnapshot = snapshot;
        statsErrorMessage = null;
      },
      onError: (_, __) {
        statsErrorMessage = UserStorage.l10n.dataLoadFailedRetry;
      },
    );
    isStatsLoading = false;
    if (notify) notifyListeners();
  }

  void setSection(InsightSection section) {
    if (selectedSection == section) return;
    selectedSection = section;
    notifyListeners();
    if (section == InsightSection.stats) {
      unawaited(loadStats());
    }
  }

  Future<void> refreshStatsForVisibleInsightPage() {
    return loadStats();
  }

  void setStatsMetric(UserStatsMetric metric) {
    if (selectedStatsMetric == metric) return;
    selectedStatsMetric = metric;
    notifyListeners();
  }

  void setStatsPresetDays(int days) {
    final nextRange = UserStatsDateRange.lastDays(days);
    if (statsRange.start == nextRange.start &&
        statsRange.end == nextRange.end) {
      return;
    }
    statsRange = nextRange;
    notifyListeners();
    unawaited(loadStats(range: nextRange));
  }

  Future<void> togglePin(KnowledgeInsightCard item) async {
    if (pinningIds.contains(item.id)) return;

    final isOriginallyPinned = item.isPinned;
    final index = insights?.indexWhere((i) => i.id == item.id) ?? -1;
    if (index == -1 || insights == null) return;

    pinningIds.add(item.id);
    insights![index] = item.copyWith(isPinned: !isOriginallyPinned);
    notifyListeners();

    final result = isOriginallyPinned
        ? await _router.unpinInsight(item.id)
        : await _router.pinInsight(item.id);
    final success = result.when(onOk: (v) => v, onError: (_, __) => false);
    if (!success) {
      insights![index] = item;
    }
    pinningIds.remove(item.id);
    notifyListeners();
  }

  Future<void> refreshInsights() async {
    if (isRefreshing) return;
    isRefreshing = true;
    await refreshTaskActivity(notify: false);
    notifyListeners();
    (await _router.updateKnowledgeInsights()).when(
      onOk: (_) {
        // Request sent. The handler will emit NewInsightMessage on
        // both success and failure via try/finally, which triggers
        // _reloadAfterInsightUpdated to reset isRefreshing.
      },
      onError: (_, __) {
        errorMessage = UserStorage.l10n.dataLoadFailedRetry;
        isRefreshing = false;
        notifyListeners();
      },
    );
  }

  void setActiveCardId(String? id) {
    if (activeCardId == id) return;
    activeCardId = id;
    notifyListeners();
  }

  void setReordering(bool value) {
    if (isReordering == value) return;
    isReordering = value;
    notifyListeners();
  }

  void moveItem(int oldIndex, int newIndex) {
    if (insights == null) return;
    if (oldIndex < newIndex) newIndex -= 1;
    final item = insights!.removeAt(oldIndex);
    insights!.insert(newIndex, item);
    notifyListeners();
  }

  Future<void> saveSortOrder() async {
    if (insights == null) return;

    isReordering = false;
    notifyListeners();

    final ids = insights!.map((e) => e.id).toList();
    final result = await _router.updateInsightCardSortOrder(ids);
    if (result.isError) await loadData();
    notifyListeners();
  }

  Future<void> deleteCard(KnowledgeInsightCard item) async {
    if (isDeleting) return;

    isDeleting = true;
    final originalList = List<KnowledgeInsightCard>.from(insights ?? []);
    final index = insights?.indexWhere((i) => i.id == item.id) ?? -1;

    if (index != -1 && insights != null) {
      insights!.removeAt(index);
      activeCardId = null;
      notifyListeners();
    }

    final result = await _router.deleteKnowledgeInsight(item.id);
    final success = result.when(onOk: (v) => v, onError: (_, __) => false);
    if (!success) {
      insights = originalList;
    }
    isDeleting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    EventBusService.instance.removeHandler(
      EventBusMessageType.newInsight,
      _handleNewInsightEvent,
    );
    EventBusService.instance.removeHandler(
      EventBusMessageType.cardAdded,
      _handleActivityChangedEvent,
    );
    EventBusService.instance.removeHandler(
      EventBusMessageType.cardUpdated,
      _handleActivityChangedEvent,
    );
    super.dispose();
  }
}
