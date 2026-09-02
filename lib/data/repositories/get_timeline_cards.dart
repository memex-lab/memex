import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/repositories/hydrate_card.dart';

final _logger = getLogger('GetTimelineCardsEndpoint');

/// Get timeline card list
/// Maps to backend GET /timeline

/// Get timeline card list
/// Maps to backend GET /timeline
Future<List<TimelineCardModel>> getTimelineCards({
  int page = 1,
  int limit = 20,
  List<String>? tags,
  DateTime? dateFrom,
  DateTime? dateTo,
}) async {
  _logger.info(
      'getTimelineCards called: page=$page, limit=$limit, tags=$tags, dateFrom=$dateFrom, dateTo=$dateTo');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      _logger.warning('No user ID found, returning empty cards list');
      return [];
    }

    final fileSystemService = FileSystemService.instance;
    final db = AppDatabase.instance;

    // 1. Check if cache needs initialization (if empty)
    if (await db.cardDao.isCacheEmpty()) {
      _logger.info('Card cache is empty, triggering rebuild...');
      // Synchronous rebuild for first run to ensure data is available
      await fileSystemService.rebuildCardCache(userId);
    }

    // 2. Query Cards using DAO
    final cachedCards = await db.cardDao.getCards(
      page: page,
      limit: limit,
      tags: tags,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    // 3. Hydrate cards with bounded parallelism. Sequential YAML + render
    // on the UI isolate made first paint wait on every card in the page.
    final hydrateStarted = DateTime.now();
    final timelineCards = await hydrateCards(
      userId,
      cachedCards.map((card) => card.factId),
      onError: (factId, error) {
        _logger.warning('Failed to hydrate card $factId: $error');
      },
    );

    _logger.info(
      'Returned ${timelineCards.length} cards for page $page '
      'in ${DateTime.now().difference(hydrateStarted).inMilliseconds}ms',
    );

    return timelineCards;
  } catch (e) {
    _logger.severe('Failed to fetch timeline cards: $e');
    return [];
  }
}
