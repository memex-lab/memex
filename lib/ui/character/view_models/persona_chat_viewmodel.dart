import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/persona_chat.dart';
import 'package:memex/utils/result.dart';

class PersonaChatViewModel extends ChangeNotifier {
  PersonaChatViewModel({
    required MemexRouter router,
    required String initialCharacterId,
    EventBusService? eventBus,
    Duration typingIndicatorDelay = defaultTypingIndicatorDelay,
  })  : _router = router,
        _currentCharacterId = initialCharacterId,
        _eventBus = eventBus ?? EventBusService.instance,
        _typingIndicatorDelay = typingIndicatorDelay {
    _eventBus.addHandler(
      EventBusMessageType.personaChatMessageAdded,
      _onPersonaChatMessageAdded,
    );
  }

  static const pageSize = 30;
  static const defaultTypingIndicatorDelay = Duration(milliseconds: 1200);

  final MemexRouter _router;
  final EventBusService _eventBus;
  final Duration _typingIndicatorDelay;

  String _currentCharacterId;
  Timer? _typingIndicatorTimer;
  bool _replyPending = false;
  CharacterModel? character;
  String? userId;
  String? userAvatar;
  List<PersonaChatMessageModel> messages = const [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreHistory = true;
  bool isReplying = false;
  String? errorMessage;
  bool _disposed = false;

  String get currentCharacterId => _currentCharacterId;

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    _notify();
    final result = await _router.loadPersonaChatThread(
      _currentCharacterId,
      limit: pageSize,
    );
    result.when(
      onOk: _applyThread,
      onError: (error, _) => errorMessage = error.toString(),
    );
    isLoading = false;
    _notify();
  }

  Future<bool> sendMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty) return false;
    final characterId = _currentCharacterId;
    errorMessage = null;
    _notify();

    var sent = false;
    final result = await _router.sendPersonaChatMessage(
      characterId,
      text,
    );
    result.when(
      onOk: (_) => sent = true,
      onError: (error, _) {
        errorMessage = error.toString();
      },
    );
    if (sent && characterId == _currentCharacterId) {
      _setReplyPending(true);
      await refreshLatest(extraCapacity: 1);
    } else {
      _notify();
    }
    return sent;
  }

  Future<void> refreshLatest({int extraCapacity = 5}) async {
    final characterId = _currentCharacterId;
    final result = await _router.fetchPersonaChatMessages(
      characterId,
      limit: messages.length + extraCapacity,
    );
    result.when(
      onOk: (updated) {
        if (characterId == _currentCharacterId) messages = updated;
      },
      onError: (error, _) => errorMessage = error.toString(),
    );
    _notify();
  }

  Future<void> loadMoreHistory() async {
    if (isLoadingMore || !hasMoreHistory) return;
    isLoadingMore = true;
    _notify();
    final characterId = _currentCharacterId;
    final result = await _router.fetchPersonaChatMessages(
      characterId,
      limit: pageSize,
      offset: messages.length,
    );
    result.when(
      onOk: (older) {
        if (characterId != _currentCharacterId) return;
        messages = [...messages, ...older];
        hasMoreHistory = older.length >= pageSize;
      },
      onError: (error, _) => errorMessage = error.toString(),
    );
    isLoadingMore = false;
    _notify();
  }

  Future<List<CharacterModel>> loadEnabledCharacters() async {
    var characters = <CharacterModel>[];
    final result = await _router.fetchEnabledPersonaCharacters();
    result.when(
      onOk: (value) => characters = value,
      onError: (error, _) => errorMessage = error.toString(),
    );
    _notify();
    return characters;
  }

  Future<void> switchCharacter(String characterId) async {
    if (characterId == _currentCharacterId) return;
    isLoading = true;
    _typingIndicatorTimer?.cancel();
    _typingIndicatorTimer = null;
    _replyPending = false;
    isReplying = false;
    errorMessage = null;
    _notify();
    final result = await _router.switchPersonaChatCharacter(
      characterId,
      limit: pageSize,
    );
    result.when(
      onOk: (thread) {
        _currentCharacterId = characterId;
        _applyThread(thread);
      },
      onError: (error, _) => errorMessage = error.toString(),
    );
    isLoading = false;
    _notify();
  }

  Future<void> markVisibleMessagesRead() async {
    final result = await _router.markPersonaChatRead(_currentCharacterId);
    result.when(
      onOk: (_) {},
      onError: (error, _) => errorMessage = error.toString(),
    );
  }

  void _applyThread(PersonaChatThreadModel thread) {
    character = thread.character;
    userId = thread.userId;
    userAvatar = thread.userAvatar;
    messages = thread.messages;
    hasMoreHistory = thread.messages.length >= pageSize;
  }

  void _onPersonaChatMessageAdded(EventBusMessage message) {
    if (message is! PersonaChatMessageAddedMessage ||
        message.characterId != _currentCharacterId) {
      return;
    }
    if (message.replyPending != null) {
      _setReplyPending(message.replyPending!);
    }
    unawaited(refreshLatest());
  }

  void _setReplyPending(bool pending) {
    if (_disposed) return;
    _replyPending = pending;
    if (!pending) {
      _typingIndicatorTimer?.cancel();
      _typingIndicatorTimer = null;
      if (isReplying) {
        isReplying = false;
        _notify();
      }
      return;
    }

    if (isReplying || (_typingIndicatorTimer?.isActive ?? false)) return;
    _typingIndicatorTimer = Timer(_typingIndicatorDelay, () {
      _typingIndicatorTimer = null;
      if (_disposed || !_replyPending) return;
      isReplying = true;
      _notify();
    });
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _typingIndicatorTimer?.cancel();
    _typingIndicatorTimer = null;
    _eventBus.removeHandler(
      EventBusMessageType.personaChatMessageAdded,
      _onPersonaChatMessageAdded,
    );
    super.dispose();
  }
}
