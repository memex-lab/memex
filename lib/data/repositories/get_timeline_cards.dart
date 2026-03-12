import 'package:memex/domain/models/card_detail_model.dart';

import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/card_renderer.dart';

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

    // 3. Hydrate Cards (Read full content from files)
    final timelineCards = <TimelineCardModel>[];
    for (final cachedCard in cachedCards) {
      try {
        // Read card data from file
        final cardData =
            await fileSystemService.readCardFile(userId, cachedCard.factId);

        // If file missing (integrity issue), skip or delete from cache?
        if (cardData == null) {
          _logger.warning(
              'Card file missing for cached entry: ${cachedCard.factId}');
          // Optionally auto-repair cache here?
          continue;
        }

        // Get fact info
        final factInfo = await fileSystemService.extractFactContentFromFile(
            userId, cachedCard.factId);
        final factContent = factInfo?.content;

        // Render card
        final renderResult = await renderCard(
          userId: userId,
          cardData: cardData,
          factContent: factContent,
        );

        // Extract assets
        final assetsAndText =
            await extractAssetsAndRawText(userId, factContent);
        final assets = assetsAndText['assets'] as List<AssetData>;
        final rawText = assetsAndText['rawText'] as String?;

        final timelineCard = TimelineCardModel(
          id: cachedCard.factId,
          html: renderResult.html,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
                  cachedCard.timestamp * 1000,
                  isUtc: true)
              .toLocal(),
          tags: List<String>.from(cardData.tags),
          status: renderResult.status,
          title: cardData.title,
          uiConfigs: renderResult.uiConfigs,
          assets: assets.isNotEmpty ? assets : null,
          rawText: rawText,
          address: cardData.address,
          failureReason: cardData.failureReason,
        );
        timelineCards.add(timelineCard);
      } catch (e) {
        _logger.warning('Failed to hydrate card ${cachedCard.factId}: $e');
        continue;
      }
    }

    _logger.info(
        'Returned ${timelineCards.length} cards for page $page (cache hit)');

    return timelineCards;
  } catch (e) {
    _logger.severe('Failed to fetch timeline cards: $e');
    return [];
  }
}
