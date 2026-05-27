import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:memex/domain/models/system_card_constants.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/domain/models/tag_model.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/ui/card_attachments/card_attachment_data.dart';
import 'package:memex/ui/timeline/models/schedule_briefing_merge.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/command.dart';

enum TimelineViewMode { timeline, insight }

/// Upserts a card into a timeline list by stable card id.
///
/// New local submissions and card-added events can describe the same fact, so
/// the in-memory list must be idempotent even when multiple sources race.
@visibleForTesting
List<TimelineCardModel> upsertTimelineCardById(
  List<TimelineCardModel> cards,
  TimelineCardModel card,
) {
  return [card, ...cards.where((existing) => existing.id != card.id)];
}

/// Replaces all existing copies of [updatedCard] while preserving the first
/// loaded position. If the card is not currently visible, the list is unchanged.
@visibleForTesting
List<TimelineCardModel> replaceTimelineCardById(
  List<TimelineCardModel> cards,
  TimelineCardModel updatedCard,
) {
  var inserted = false;
  var found = false;
  final next = <TimelineCardModel>[];

  for (final card in cards) {
    if (card.id != updatedCard.id) {
      next.add(card);
      continue;
    }

    found = true;
    if (!inserted) {
      next.add(updatedCard);
      inserted = true;
    }
  }

  return found ? next : cards;
}

/// Keeps the first occurrence of each card id, preserving timeline order.
@visibleForTesting
List<TimelineCardModel> dedupeTimelineCardsById(List<TimelineCardModel> cards) {
  final seen = <String>{};
  final next = <TimelineCardModel>[];

  for (final card in cards) {
    if (seen.add(card.id)) {
      next.add(card);
    }
  }

  return next;
}

/// ViewModel for the Timeline page. Holds cards, tags, loading state, and
/// delegates data access to [MemexRouter]. Call [init] once after creation.
class TimelineViewModel extends ChangeNotifier {
  TimelineViewModel({required MemexRouter router}) : _router = router;

  final MemexRouter _router;
  final Logger _logger = getLogger('TimelineViewModel');

  static const int pageLimit = 20;
  static const Duration pollingInterval = Duration(seconds: 5);

  // Timeline list state
  List<TimelineCardModel> cards = [];
  List<TagModel> tags = [];
  bool isLoading = false;
  bool hasMore = true;
  int _currentPage = 1;
  String? errorMessage;
  bool isSubmitting = false;

  // Card attachments (system actions, clarification requests, etc.)
  // Keyed by factId.
  final Map<String, List<CardAttachmentData>> attachments = {};

  // Pending attachment count for notification badge.
  int pendingAttachmentCount = 0;

  // View mode state
  TimelineViewMode viewMode = TimelineViewMode.timeline;
  String activeFilter = 'all';

  Timer? _pollingTimer;
  bool _eventBusSetup = false;

  late final Command0<void> load = Command0<void>(_loadInitial)..execute();

  Future<Result<void>> _loadInitial() async {
    final cardsResult = await _router.fetchTimelineCards(
      page: 1,
      limit: pageLimit,
      tags: activeFilter == 'all' ? null : [activeFilter],
    );
    return cardsResult.when(
      onOk: (list) async {
        _currentPage = 1;
        final loadedHasMore = list.length >= pageLimit;
        cards = await _withScheduleBriefingCard(
          list,
          hasMoreAfterList: loadedHasMore,
        );
        hasMore = loadedHasMore;
        errorMessage = null;
        _startPollingIfNeeded();
        // Load attachments for all cards in parallel
        await _loadAttachmentsForCards(list);
        await _refreshPendingCount();
        notifyListeners();
        return const Ok.v();
      },
      onError: (error, stackTrace) {
        errorMessage = UserStorage.l10n.timelineLoadFailedRetry;
        notifyListeners();
        return Error<void>(error, stackTrace);
      },
    );
  }

  /// Call once after construction to register event bus (initial data via [load]).
  void init() {
    _setupEventBus();
    fetchTags();
  }

  void _setupEventBus() {
    if (_eventBusSetup) return;
    _eventBusSetup = true;
    final eventBus = EventBusService.instance;
    eventBus.addHandler(EventBusMessageType.cardUpdated, _handleCardUpdated);
    eventBus.addHandler(EventBusMessageType.cardAdded, _handleCardAdded);
    eventBus.addHandler(
      EventBusMessageType.attachmentsChanged,
      _handleAttachmentsChanged,
    );
    eventBus.addHandler(
      EventBusMessageType.scheduleAggregationUpdated,
      _handleScheduleBriefingChanged,
    );
    eventBus.connect();
  }

  void _handleCardAdded(EventBusMessage message) {
    if (message is CardAddedMessage) {
      List<AssetData>? assets;
      if (message.assets != null && message.assets!.isNotEmpty) {
        assets = message.assets!.map((a) => AssetData.fromJson(a)).toList();
      }
      final newCard = TimelineCardModel(
        id: message.id,
        html: message.html.isEmpty ? null : message.html,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          message.timestamp * 1000,
          isUtc: true,
        ).toLocal(),
        tags: message.tags,
        status: message.status,
        title: message.title,
        uiConfigs: message.uiConfigs,
        assets: assets,
        rawText: message.rawText,
        address: message.address,
      );
      addCard(newCard);
      fetchTags();
    }
  }

  void _handleCardUpdated(EventBusMessage message) {
    if (message is CardUpdatedMessage) {
      List<AssetData>? assets;
      if (message.assets != null && message.assets!.isNotEmpty) {
        assets = message.assets!.map((a) => AssetData.fromJson(a)).toList();
      }
      final updatedCard = TimelineCardModel(
        id: message.id,
        html: message.html.isEmpty ? null : message.html,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          message.timestamp * 1000,
          isUtc: true,
        ).toLocal(),
        tags: message.tags,
        status: message.status,
        title: message.title,
        uiConfigs: message.uiConfigs,
        assets: assets,
        rawText: message.rawText,
        address: message.address,
        failureReason: message.failureReason,
      );
      updateCard(updatedCard);
      unawaited(_refreshPendingCount());
      fetchTags();
    }
  }

  void _handleAttachmentsChanged(EventBusMessage message) {
    if (message is AttachmentsChangedMessage) {
      final factId = message.factId;
      if (factId != null && cards.any((c) => c.id == factId)) {
        // Refresh attachments for the specific card
        _refreshAttachments(factId);
      } else {
        // Global change (no factId) — refresh all
        _loadAttachmentsForCards(cards);
      }
      _refreshPendingCount();
    }
  }

  Future<void> _loadAttachmentsForCards(
    List<TimelineCardModel> cardList,
  ) async {
    if (cardList.isEmpty) return;
    final factIds = cardList.map((c) => c.id).toList();
    final map = await CardAttachmentService.instance.getAttachmentsForFacts(
      factIds,
    );
    attachments.addAll(map);
    // Don't call notifyListeners here — caller is responsible.
  }

  Future<void> _refreshAttachments(String factId) async {
    final data = await CardAttachmentService.instance.getAttachments(factId);
    attachments[factId] = data;
    notifyListeners();
  }

  Future<void> _refreshPendingCount() async {
    final pending = await CardAttachmentService.instance
        .getPendingAttachments();
    final failedCardCount = await _router.countFailedCardGenerations();
    pendingAttachmentCount = pending.length + (failedCardCount > 0 ? 1 : 0);
    notifyListeners();
  }

  void _handleScheduleBriefingChanged(EventBusMessage message) {
    unawaited(_refreshScheduleBriefingCard());
  }

  void _startPollingIfNeeded() {
    final hasProcessing = cards.any((c) => c.status == 'processing');
    if (hasProcessing && _pollingTimer == null) {
      _logger.info('Starting polling for processing cards');
      _pollingTimer = Timer.periodic(
        pollingInterval,
        (_) => _pollProcessingCards(),
      );
    } else if (!hasProcessing && _pollingTimer != null) {
      _stopPolling();
    }
  }

  void _checkAndStopPollingIfNeeded() {
    if (!cards.any((c) => c.status == 'processing') && _pollingTimer != null) {
      _stopPolling();
    }
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _pollProcessingCards() {
    final processingIds = cards
        .where((c) => c.status == 'processing')
        .map((c) => c.id)
        .toList();
    if (processingIds.isEmpty) {
      _stopPolling();
      return;
    }
    final eventBus = EventBusService.instance;
    if (eventBus.isConnected) {
      eventBus.sendMessage({
        'type': 'check_processing_cards',
        'data': {'card_ids': processingIds},
      });
    }
  }

  void setSubmitting(bool value) {
    if (isSubmitting == value) return;
    isSubmitting = value;
    notifyListeners();
  }

  /// Refresh timeline and tags (e.g. after pull-to-refresh or scroll-to-top).
  Future<void> refresh() async {
    await load.execute();
    await fetchTags();
  }

  void addCard(TimelineCardModel card) {
    cards = upsertTimelineCardById(cards, card);
    isSubmitting = false;
    if (card.status == 'processing') {
      _startPollingIfNeeded();
    }
    notifyListeners();
  }

  void updateCard(TimelineCardModel updatedCard) {
    cards = replaceTimelineCardById(cards, updatedCard);
    _checkAndStopPollingIfNeeded();
    notifyListeners();
  }

  void removeCardById(String cardId) {
    cards.removeWhere((c) => c.id == cardId);
    _checkAndStopPollingIfNeeded();
    notifyListeners();
  }

  void setActiveFilter(String tag) {
    activeFilter = tag;
    notifyListeners();
  }

  void setViewMode(TimelineViewMode mode) {
    if (viewMode == mode) return;
    viewMode = mode;
    notifyListeners();
  }

  Future<void> loadCards({bool refresh = false}) async {
    if (refresh) {
      await load.execute();
      return;
    }
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();
    final result = await _router.fetchTimelineCards(
      page: _currentPage,
      limit: pageLimit,
      tags: activeFilter == 'all' ? null : [activeFilter],
    );
    result.when(
      onOk: (newCards) async {
        _currentPage++;
        final loadedHasMore = newCards.length >= pageLimit;
        cards = await _withScheduleBriefingCard([
          ...cards,
          ...newCards,
        ], hasMoreAfterList: loadedHasMore);
        hasMore = loadedHasMore;
        _startPollingIfNeeded();
        await _loadAttachmentsForCards(newCards);
      },
      onError: (_, __) {},
    );
    isLoading = false;
    notifyListeners();
  }

  Future<List<TimelineCardModel>> _withScheduleBriefingCard(
    List<TimelineCardModel> list, {
    required bool hasMoreAfterList,
  }) async {
    final withoutBriefing = dedupeTimelineCardsById(
      list,
    ).where((card) => card.id != scheduleBriefingCardId).toList();
    if (!_shouldShowScheduleBriefing) return withoutBriefing;

    final briefingResult = await _router.fetchScheduleBriefingCard();
    return briefingResult.when(
      onOk: (briefing) {
        return mergeScheduleBriefingInTimelineOrder(
          cards: withoutBriefing,
          briefing: briefing,
          hasMore: hasMoreAfterList,
        );
      },
      onError: (e, st) {
        _logger.warning('Failed to load schedule briefing card: $e');
        return withoutBriefing;
      },
    );
  }

  Future<void> _refreshScheduleBriefingCard() async {
    if (!_shouldShowScheduleBriefing) return;
    cards = await _withScheduleBriefingCard(cards, hasMoreAfterList: hasMore);
    notifyListeners();
  }

  bool get _shouldShowScheduleBriefing =>
      viewMode == TimelineViewMode.timeline && activeFilter == 'all';

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();
    final result = await _router.fetchTimelineCards(
      page: _currentPage + 1,
      limit: pageLimit,
      tags: activeFilter == 'all' ? null : [activeFilter],
    );
    result.when(
      onOk: (newCards) async {
        _currentPage++;
        final loadedHasMore = newCards.length >= pageLimit;
        cards = await _withScheduleBriefingCard([
          ...cards,
          ...newCards,
        ], hasMoreAfterList: loadedHasMore);
        hasMore = loadedHasMore;
        await _loadAttachmentsForCards(newCards);
      },
      onError: (_, __) {},
    );
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTags() async {
    final result = await _router.fetchTags();
    tags = result.when(onOk: (t) => t, onError: (_, __) => <TagModel>[]);
    notifyListeners();
  }

  @override
  void dispose() {
    _stopPolling();
    if (_eventBusSetup) {
      final eventBus = EventBusService.instance;
      eventBus.removeHandler(
        EventBusMessageType.cardUpdated,
        _handleCardUpdated,
      );
      eventBus.removeHandler(EventBusMessageType.cardAdded, _handleCardAdded);
      eventBus.removeHandler(
        EventBusMessageType.attachmentsChanged,
        _handleAttachmentsChanged,
      );
      eventBus.removeHandler(
        EventBusMessageType.scheduleAggregationUpdated,
        _handleScheduleBriefingChanged,
      );
    }
    super.dispose();
  }
}
