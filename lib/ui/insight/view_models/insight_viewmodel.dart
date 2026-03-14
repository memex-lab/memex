import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:memex/domain/models/knowledge_insight_card.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

/// ViewModel for the Insight page. Holds insight list, pin/delete/reorder state.
class InsightViewModel extends ChangeNotifier {
  InsightViewModel({required MemexRouter router}) : _router = router {
    EventBusService.instance
        .addHandler(EventBusMessageType.newInsight, _handleNewInsightEvent);
  }

  final MemexRouter _router;

  List<KnowledgeInsightCard>? insights;
  bool isLoading = true;
  String? errorMessage;
  String? activeCardId;
  bool isDeleting = false;
  bool isRefreshing = false;
  bool isReordering = false;
  final Set<String> pinningIds = {};

  void _handleNewInsightEvent(EventBusMessage message) {
    if (message is! NewInsightMessage) return;
    unawaited(_reloadAfterInsightUpdated());
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
    notifyListeners();
    (await _router.updateKnowledgeInsights()).when(
      onOk: (_) {},
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
    EventBusService.instance
        .removeHandler(EventBusMessageType.newInsight, _handleNewInsightEvent);
    super.dispose();
  }
}
