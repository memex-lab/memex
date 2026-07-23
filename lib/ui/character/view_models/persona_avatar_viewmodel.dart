import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/result.dart';

class PersonaAvatarViewModel extends ChangeNotifier {
  PersonaAvatarViewModel({
    required MemexRouter router,
    EventBusService? eventBus,
  })  : _router = router,
        _eventBus = eventBus ?? EventBusService.instance;

  final MemexRouter _router;
  final EventBusService _eventBus;

  CharacterModel? character;
  int unreadCount = 0;
  String? errorMessage;
  bool _initialized = false;
  bool _disposed = false;
  int _refreshGeneration = 0;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _eventBus.addHandler(
      EventBusMessageType.characterUpdated,
      _handleRelevantEvent,
    );
    _eventBus.addHandler(
      EventBusMessageType.personaChatMessageAdded,
      _handleRelevantEvent,
    );
    _eventBus.addHandler(
      EventBusMessageType.personaChatUnreadChanged,
      _handleRelevantEvent,
    );
    await refresh();
  }

  Future<void> refresh() async {
    final generation = ++_refreshGeneration;
    final result = await _router.loadPersonaAvatarSummary();
    if (_disposed || generation != _refreshGeneration) return;
    result.when(
      onOk: (summary) {
        character = summary.character;
        unreadCount = summary.unreadCount;
        errorMessage = null;
      },
      onError: (error, _) => errorMessage = error.toString(),
    );
    _notify();
  }

  void _handleRelevantEvent(EventBusMessage _) {
    unawaited(refresh());
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_initialized) {
      _eventBus.removeHandler(
        EventBusMessageType.characterUpdated,
        _handleRelevantEvent,
      );
      _eventBus.removeHandler(
        EventBusMessageType.personaChatMessageAdded,
        _handleRelevantEvent,
      );
      _eventBus.removeHandler(
        EventBusMessageType.personaChatUnreadChanged,
        _handleRelevantEvent,
      );
    }
    super.dispose();
  }
}
