import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/domain/models/timeline_card_visibility.dart';
import 'package:memex/domain/models/tag_model.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/ui/card_attachments/card_attachment_data.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/command.dart';

enum TimelineViewMode { timeline, insight }

typedef TimelineCardsFetcher = Future<Result<List<TimelineCardModel>>>
    Function({
  int page,
  int limit,
  List<String>? tags,
  DateTime? dateFrom,
  DateTime? dateTo,
});

typedef TimelineTagsFetcher = Future<Result<List<TagModel>>> Function();
typedef TimelineAttachmentFetcher = Future<List<CardAttachmentData>> Function(
    String factId);
typedef PendingAttachmentsFetcher = Future<List<CardAttachmentData>> Function();

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

/// Removes retired synthetic cards while preserving normal Timeline order.
@visibleForTesting
List<TimelineCardModel> prepareTimelineCards(List<TimelineCardModel> cards) {
  return dedupeTimelineCardsById(cards)
      .where((card) => !isRetiredTimelineCard(card))
      .toList();
}

/// ViewModel for the Timeline page. Holds cards, tags, loading state, and
/// delegates data access to [MemexRouter]. Call [init] once after creation.
class TimelineViewModel extends ChangeNotifier {
  TimelineViewModel({
    required MemexRouter router,
    TimelineCardsFetcher? fetchTimelineCards,
    TimelineTagsFetcher? fetchTags,
    TimelineAttachmentFetcher? fetchAttachmentForCard,
    PendingAttachmentsFetcher? fetchPendingAttachments,
    Duration auxiliaryQueryTimeout = defaultAuxiliaryQueryTimeout,
    bool autoLoad = true,
  }) : this._(
          fetchTimelineCards: fetchTimelineCards ??
              (({
                int page = 1,
                int limit = pageLimit,
                List<String>? tags,
                DateTime? dateFrom,
                DateTime? dateTo,
              }) =>
                  router.fetchTimelineCards(
                    page: page,
                    limit: limit,
                    tags: tags,
                    dateFrom: dateFrom,
                    dateTo: dateTo,
                  )),
          fetchTags: fetchTags ?? router.fetchTags,
          fetchAttachmentForCard: fetchAttachmentForCard ??
              CardAttachmentService.instance.getAttachments,
          fetchPendingAttachments: fetchPendingAttachments ??
              CardAttachmentService.instance.getPendingAttachments,
          auxiliaryQueryTimeout: auxiliaryQueryTimeout,
          autoLoad: autoLoad,
        );

  @visibleForTesting
  factory TimelineViewModel.forTest({
    TimelineCardsFetcher? fetchTimelineCards,
    TimelineTagsFetcher? fetchTags,
    TimelineAttachmentFetcher? fetchAttachmentForCard,
    PendingAttachmentsFetcher? fetchPendingAttachments,
    Duration auxiliaryQueryTimeout = defaultAuxiliaryQueryTimeout,
    bool autoLoad = false,
  }) {
    return TimelineViewModel._(
      fetchTimelineCards: fetchTimelineCards ??
          ({
            int page = 1,
            int limit = pageLimit,
            List<String>? tags,
            DateTime? dateFrom,
            DateTime? dateTo,
          }) async =>
              const Ok(<TimelineCardModel>[]),
      fetchTags: fetchTags ?? () async => const Ok(<TagModel>[]),
      fetchAttachmentForCard:
          fetchAttachmentForCard ?? (_) async => const <CardAttachmentData>[],
      fetchPendingAttachments:
          fetchPendingAttachments ?? () async => const <CardAttachmentData>[],
      auxiliaryQueryTimeout: auxiliaryQueryTimeout,
      autoLoad: autoLoad,
    );
  }

  TimelineViewModel._({
    required TimelineCardsFetcher fetchTimelineCards,
    required TimelineTagsFetcher fetchTags,
    required TimelineAttachmentFetcher fetchAttachmentForCard,
    required PendingAttachmentsFetcher fetchPendingAttachments,
    required Duration auxiliaryQueryTimeout,
    required bool autoLoad,
  })  : _fetchTimelineCards = fetchTimelineCards,
        _fetchTags = fetchTags,
        _fetchAttachmentForCard = fetchAttachmentForCard,
        _fetchPendingAttachments = fetchPendingAttachments,
        _auxiliaryQueryTimeout = auxiliaryQueryTimeout {
    load = Command0<void>(_loadInitial);
    if (autoLoad) {
      unawaited(load.execute());
    }
  }

  final Logger _logger = getLogger('TimelineViewModel');
  final TimelineCardsFetcher _fetchTimelineCards;
  final TimelineTagsFetcher _fetchTags;
  final TimelineAttachmentFetcher _fetchAttachmentForCard;
  final PendingAttachmentsFetcher _fetchPendingAttachments;
  final Duration _auxiliaryQueryTimeout;

  static const int pageLimit = 20;
  static const Duration pollingInterval = Duration(seconds: 5);
  static const Duration defaultAuxiliaryQueryTimeout = Duration(seconds: 2);
  static const Duration tagsRefreshDelay = Duration(milliseconds: 300);

  // Timeline list state
  List<TimelineCardModel> cards = [];
  List<TagModel> tags = [];
  bool isLoading = false;
  bool hasMore = true;
  int _currentPage = 1;
  int _loadGeneration = 0;
  int? _visibleLoadGeneration;
  String? errorMessage;
  Timer? _tagsRefreshTimer;

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

  late final Command0<void> load;

  Future<Result<void>> _loadInitial({bool notifyLoading = false}) async {
    final generation = ++_loadGeneration;
    final filter = activeFilter;
    if (notifyLoading) {
      _beginVisibleLoad(generation);
    }
    final cardsResult = await _fetchTimelineCards(
      page: 1,
      limit: pageLimit,
      tags: filter == 'all' ? null : [filter],
    );
    return cardsResult.when(
      onOk: (list) async {
        if (_isStaleTimelineLoad(generation, filter)) {
          _finishVisibleLoadIfCurrent(generation);
          return const Ok.v();
        }
        _currentPage = 1;
        final loadedHasMore = list.length >= pageLimit;
        final nextCards = prepareTimelineCards(list);
        if (_isStaleTimelineLoad(generation, filter)) {
          _finishVisibleLoadIfCurrent(generation);
          return const Ok.v();
        }
        cards = nextCards;
        hasMore = loadedHasMore;
        _finishVisibleLoadIfCurrent(generation, notify: false);
        errorMessage = null;
        _startPollingIfNeeded();
        notifyListeners();
        _refreshAuxiliaryTimelineState(
          generation: generation,
          filter: filter,
          cardList: list,
        );
        return const Ok.v();
      },
      onError: (error, stackTrace) {
        if (_isStaleTimelineLoad(generation, filter)) {
          _finishVisibleLoadIfCurrent(generation);
          return const Ok.v();
        }
        _finishVisibleLoadIfCurrent(generation, notify: false);
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
      _scheduleFetchTags();
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
      _scheduleFetchTags();
    }
  }

  void _handleAttachmentsChanged(EventBusMessage message) {
    if (message is AttachmentsChangedMessage) {
      final factId = message.factId;
      if (factId != null && cards.any((c) => c.id == factId)) {
        // Refresh attachments for the specific card
        unawaited(_refreshAttachments(factId));
      } else {
        // Global change (no factId) — refresh all
        unawaited(_loadAttachmentsForCards(cards, notify: true));
      }
      unawaited(_refreshPendingCount());
    }
  }

  Future<bool> _loadAttachmentsForCards(
    List<TimelineCardModel> cardList, {
    int? generation,
    String? filter,
    bool notify = false,
  }) async {
    if (cardList.isEmpty) return false;
    final factIds = cardList.map((c) => c.id).toList();
    final entries = await Future.wait(
      factIds.map((factId) async {
        final data = await _runAuxiliaryQuery<List<CardAttachmentData>>(
          label: 'load attachments for $factId',
          query: () => _fetchAttachmentForCard(factId),
        );
        return data == null ? null : MapEntry(factId, data);
      }),
    );
    if (generation != null &&
        filter != null &&
        _isStaleTimelineLoad(generation, filter)) {
      return false;
    }
    final map = <String, List<CardAttachmentData>>{};
    for (final entry in entries) {
      if (entry != null) {
        map[entry.key] = entry.value;
      }
    }
    if (map.isEmpty) return false;
    attachments.addAll(map);
    if (notify) notifyListeners();
    return true;
  }

  Future<void> _refreshAttachments(String factId) async {
    final data = await _runAuxiliaryQuery<List<CardAttachmentData>>(
      label: 'refresh attachments for $factId',
      query: () => _fetchAttachmentForCard(factId),
    );
    if (data == null) return;
    attachments[factId] = data;
    notifyListeners();
  }

  Future<bool> _refreshPendingCount({bool notify = true}) async {
    final pending = await _runAuxiliaryQuery<List<CardAttachmentData>>(
      label: 'refresh pending attachment count',
      query: _fetchPendingAttachments,
    );
    if (pending == null) {
      return false;
    }
    pendingAttachmentCount = pending.length;
    if (notify) notifyListeners();
    return true;
  }

  void _refreshAuxiliaryTimelineState({
    required int generation,
    required String filter,
    required List<TimelineCardModel> cardList,
  }) {
    unawaited(() async {
      final attachmentChanged = await _loadAttachmentsForCards(
        cardList,
        generation: generation,
        filter: filter,
      );
      final pendingChanged = await _refreshPendingCount(notify: false);
      if (_isStaleTimelineLoad(generation, filter)) return;
      if (attachmentChanged || pendingChanged) {
        notifyListeners();
      }
    }());
  }

  Future<T?> _runAuxiliaryQuery<T>({
    required String label,
    required Future<T> Function() query,
  }) async {
    try {
      return await query().timeout(_auxiliaryQueryTimeout);
    } on TimeoutException catch (e, st) {
      _logger.warning('$label timed out', e, st);
    } catch (e, st) {
      _logger.warning('$label failed', e, st);
    }
    return null;
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
    final processingIds =
        cards.where((c) => c.status == 'processing').map((c) => c.id).toList();
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

  /// Refresh timeline and tags (e.g. after pull-to-refresh or scroll-to-top).
  Future<void> refresh() async {
    await load.execute();
    unawaited(fetchTags());
  }

  void addCard(TimelineCardModel card) {
    if (isRetiredTimelineCard(card)) return;
    cards = upsertTimelineCardById(cards, card);
    if (card.status == 'processing') {
      _startPollingIfNeeded();
    }
    notifyListeners();
  }

  void updateCard(TimelineCardModel updatedCard) {
    if (isRetiredTimelineCard(updatedCard)) {
      final previousLength = cards.length;
      cards = cards.where((card) => card.id != updatedCard.id).toList();
      _checkAndStopPollingIfNeeded();
      if (cards.length != previousLength) {
        notifyListeners();
      }
      return;
    }
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
    if (activeFilter == tag) return;
    _loadGeneration++;
    _visibleLoadGeneration = null;
    activeFilter = tag;
    cards = [];
    attachments.clear();
    hasMore = true;
    _currentPage = 1;
    isLoading = false;
    notifyListeners();
  }

  void setViewMode(TimelineViewMode mode) {
    if (viewMode == mode) return;
    viewMode = mode;
    notifyListeners();
  }

  Future<void> loadCards({bool refresh = false}) async {
    if (refresh) {
      await _loadInitial(notifyLoading: true);
      return;
    }
    if (isLoading || !hasMore) return;
    final generation = _loadGeneration;
    final filter = activeFilter;
    _beginVisibleLoad(generation);
    final result = await _fetchTimelineCards(
      page: _currentPage,
      limit: pageLimit,
      tags: filter == 'all' ? null : [filter],
    );
    switch (result) {
      case Ok(:final value):
        if (_isStaleTimelineLoad(generation, filter)) {
          _finishVisibleLoadIfCurrent(generation);
          return;
        }
        final newCards = value;
        _currentPage++;
        final loadedHasMore = newCards.length >= pageLimit;
        final nextCards = prepareTimelineCards([...cards, ...newCards]);
        if (_isStaleTimelineLoad(generation, filter)) {
          _finishVisibleLoadIfCurrent(generation);
          return;
        }
        cards = nextCards;
        hasMore = loadedHasMore;
        _startPollingIfNeeded();
        _finishVisibleLoadIfCurrent(generation, notify: false);
        notifyListeners();
        _refreshAuxiliaryTimelineState(
          generation: generation,
          filter: filter,
          cardList: newCards,
        );
        return;
      case Error():
        break;
    }
    _finishVisibleLoadIfCurrent(generation, notify: false);
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    final generation = _loadGeneration;
    final filter = activeFilter;
    _beginVisibleLoad(generation);
    final result = await _fetchTimelineCards(
      page: _currentPage + 1,
      limit: pageLimit,
      tags: filter == 'all' ? null : [filter],
    );
    switch (result) {
      case Ok(:final value):
        if (_isStaleTimelineLoad(generation, filter)) {
          _finishVisibleLoadIfCurrent(generation);
          return;
        }
        final newCards = value;
        _currentPage++;
        final loadedHasMore = newCards.length >= pageLimit;
        final nextCards = prepareTimelineCards([...cards, ...newCards]);
        if (_isStaleTimelineLoad(generation, filter)) {
          _finishVisibleLoadIfCurrent(generation);
          return;
        }
        cards = nextCards;
        hasMore = loadedHasMore;
        _finishVisibleLoadIfCurrent(generation, notify: false);
        notifyListeners();
        _refreshAuxiliaryTimelineState(
          generation: generation,
          filter: filter,
          cardList: newCards,
        );
        return;
      case Error():
        break;
    }
    _finishVisibleLoadIfCurrent(generation, notify: false);
    notifyListeners();
  }

  bool _isStaleTimelineLoad(int generation, String filter) {
    return generation != _loadGeneration || filter != activeFilter;
  }

  void _scheduleFetchTags() {
    _tagsRefreshTimer?.cancel();
    _tagsRefreshTimer = Timer(tagsRefreshDelay, () {
      unawaited(fetchTags());
    });
  }

  Future<void> fetchTags() async {
    try {
      final result = await _fetchTags();
      final next = result.when(onOk: (t) => t, onError: (_, __) => <TagModel>[]);
      if (_sameTimelineTags(tags, next)) return;
      tags = next;
    } catch (e, stackTrace) {
      _logger.warning('Failed to fetch timeline tags: $e', e, stackTrace);
      if (tags.isEmpty) return;
      tags = <TagModel>[];
    }
    notifyListeners();
  }

  void _beginVisibleLoad(int generation) {
    _visibleLoadGeneration = generation;
    isLoading = true;
    notifyListeners();
  }

  void _finishVisibleLoadIfCurrent(int generation, {bool notify = true}) {
    if (_visibleLoadGeneration != generation) return;
    _visibleLoadGeneration = null;
    isLoading = false;
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _tagsRefreshTimer?.cancel();
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
    }
    super.dispose();
  }
}

@visibleForTesting
bool sameTimelineTags(List<TagModel> current, List<TagModel> next) =>
    _sameTimelineTags(current, next);

bool _sameTimelineTags(List<TagModel> current, List<TagModel> next) {
  if (identical(current, next)) return true;
  if (current.length != next.length) return false;
  for (var i = 0; i < current.length; i++) {
    if (current[i].name != next[i].name ||
        current[i].icon != next[i].icon ||
        current[i].iconType != next[i].iconType) {
      return false;
    }
  }
  return true;
}
