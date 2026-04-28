import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/repositories/hydrate_card.dart';

final _logger = getLogger('GetCardsByIdsEndpoint');

/// Get specific cards by their IDs
/// Used for Source Trace in Knowledge Base
Future<List<TimelineCardModel>> getCardsByIds(List<String> ids) async {
  _logger.info('getCardsByIds called with ${ids.length} ids');

  if (ids.isEmpty) return [];

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      _logger.warning('No user ID found, returning empty cards list');
      return [];
    }

    final cards = <TimelineCardModel>[];

    for (final id in ids) {
      try {
        final card = await hydrateCard(userId, id);
        if (card != null) cards.add(card);
      } catch (e) {
        _logger.warning('Failed to process card id $id: $e');
      }
    }

    return cards;
  } catch (e) {
    _logger.severe('Failed to get cards by ids: $e');
    return [];
  }
}
