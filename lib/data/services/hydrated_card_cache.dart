import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/timeline_card_model.dart';

/// In-memory render cache keyed by user id + fact id + content hash.
///
/// CardCache in SQLite only stores id/path/timestamp/tags. This keeps the
/// expensive `renderCard` + asset extraction result for unchanged YAML.
class HydratedCardCache {
  HydratedCardCache._();

  static final HydratedCardCache instance = HydratedCardCache._();

  static const int _maxEntries = 200;

  final Map<(String, String), _CachedHydratedCard> _entries =
      <(String, String), _CachedHydratedCard>{};

  TimelineCardModel? get(String userId, String factId, String contentHash) {
    final key = (userId, factId);
    final cached = _entries.remove(key);
    if (cached == null || cached.contentHash != contentHash) {
      return null;
    }
    _entries[key] = cached;
    return cached.card;
  }

  void put(
    String userId,
    String factId,
    String contentHash,
    TimelineCardModel card,
  ) {
    final key = (userId, factId);
    _entries.remove(key);
    _entries[key] = _CachedHydratedCard(contentHash: contentHash, card: card);
    while (_entries.length > _maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void invalidate(String userId, String factId) =>
      _entries.remove((userId, factId));

  void clearUser(String userId) {
    _entries.removeWhere((key, _) => key.$1 == userId);
  }

  void clearAll() => _entries.clear();

  @visibleForTesting
  void clear() => clearAll();

  @visibleForTesting
  int get length => _entries.length;
}

class _CachedHydratedCard {
  const _CachedHydratedCard({required this.contentHash, required this.card});

  final String contentHash;
  final TimelineCardModel card;
}

String hydratedCardContentHash(CardData cardData) {
  return sha256.convert(utf8.encode(jsonEncode(cardData.toJson()))).toString();
}
