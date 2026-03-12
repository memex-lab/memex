import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/domain/models/tag_model.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/command.dart';

enum TimelineViewMode { timeline, insight }

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
      onOk: (list) {
        _currentPage = 1;
        cards = list;
        hasMore = list.length >= pageLimit;
        errorMessage = null;
        _startPollingIfNeeded();
        notifyListeners();
        return const Ok.v();
      },
      onError: (e, st) {
        errorMessage = UserStorage.l10n.timelineLoadFailedRetry;
        notifyListeners();
        return Error<void>(e, st);
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
      fetchTags();
    }
  }

  void _startPollingIfNeeded() {
    final hasProcessing = cards.any((c) => c.status == 'processing');
    if (hasProcessing && _pollingTimer == null) {
      _logger.info('Starting polling for processing cards');
      _pollingTimer =
          Timer.periodic(pollingInterval, (_) => _pollProcessingCards());
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
    cards.insert(0, card);
    isSubmitting = false;
    if (card.status == 'processing') {
      _startPollingIfNeeded();
    }
    notifyListeners();
  }

  void updateCard(TimelineCardModel updatedCard) {
    final index = cards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      cards[index] = updatedCard;
    }
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
      onOk: (newCards) {
        _currentPage++;
        cards.addAll(newCards);
        hasMore = newCards.length >= pageLimit;
        _startPollingIfNeeded();
      },
      onError: (_, __) {},
    );
    isLoading = false;
    notifyListeners();
  }

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
      onOk: (newCards) {
        _currentPage++;
        cards.addAll(newCards);
        hasMore = newCards.length >= pageLimit;
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
          EventBusMessageType.cardUpdated, _handleCardUpdated);
      eventBus.removeHandler(EventBusMessageType.cardAdded, _handleCardAdded);
    }
    super.dispose();
  }
}
