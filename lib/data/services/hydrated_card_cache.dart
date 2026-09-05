import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/timeline_card_model.dart';

/// In-memory render cache keyed by fact id + content hash.
///
/// CardCache in SQLite only stores id/path/timestamp/tags. This keeps the
/// expensive `renderCard` + asset extraction result for unchanged YAML.
class HydratedCardCache {
  HydratedCardCache._();

  static final HydratedCardCache instance = HydratedCardCache._();

  static const int _maxEntries = 200;

  final Map<String, _CachedHydratedCard> _entries =
      <String, _CachedHydratedCard>{};

  TimelineCardModel? get(String factId, String contentHash) {
    final cached = _entries.remove(factId);
    if (cached == null || cached.contentHash != contentHash) {
      return null;
    }
    _entries[factId] = cached;
    return cached.card;
  }

  void put(String factId, String contentHash, TimelineCardModel card) {
    _entries.remove(factId);
    _entries[factId] = _CachedHydratedCard(
      contentHash: contentHash,
      card: card,
    );
    while (_entries.length > _maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void invalidate(String factId) => _entries.remove(factId);

  @visibleForTesting
  void clear() => _entries.clear();

  @visibleForTesting
  int get length => _entries.length;
}

class _CachedHydratedCard {
  const _CachedHydratedCard({
    required this.contentHash,
    required this.card,
  });

  final String contentHash;
  final TimelineCardModel card;
}

String hydratedCardContentHash(CardData cardData) {
  return sha256.convert(utf8.encode(jsonEncode(cardData.toJson()))).toString();
}
