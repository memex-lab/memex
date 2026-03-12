import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/card_renderer.dart';

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

    final fileSystemService = FileSystemService.instance;
    final cards = <TimelineCardModel>[];

    for (final id in ids) {
      try {
        // ID format is expected to be fact_id (e.g. 2025/11/23.md#ts_1)
        // This is what readCardFile expects
        final cardData = await fileSystemService.readCardFile(userId, id);

        if (cardData == null) {
          _logger.warning('Card not found for id: $id');
          continue;
        }

        // Get Fact Info for timestamp/content
        final factInfo =
            await fileSystemService.extractFactContentFromFile(userId, id);

        int timestamp;
        String? factContent;

        if (factInfo != null) {
          timestamp = factInfo.timestamp;
          factContent = factInfo.content;
        } else {
          timestamp = cardData.timestamp;
          _logger.warning(
              'Could not get timestamp from Facts for id: $id, using data/current timestamp');
        }

        // Render Card
        final renderResult = await renderCard(
          userId: userId,
          cardData: cardData,
          factContent: factContent,
        );

        // Extract Assets & Raw Text
        final assetsAndText =
            await extractAssetsAndRawText(userId, factContent);
        final assets = assetsAndText['assets'] as List<AssetData>;
        final rawText = assetsAndText['rawText'] as String?;

        // Create Model
        final cardModel = TimelineCardModel(
          id: id,
          html: renderResult.html,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            timestamp * 1000,
            isUtc: true,
          ).toLocal(),
          tags: List<String>.from(cardData.tags),
          status: renderResult.status,
          title: cardData.title,
          uiConfigs: renderResult.uiConfigs,
          assets: assets.isNotEmpty ? assets : null,
          rawText: rawText,
          failureReason: cardData.failureReason,
        );

        cards.add(cardModel);
      } catch (e) {
        _logger.warning('Failed to process card id $id: $e');
        continue;
      }
    }

    return cards;
  } catch (e) {
    _logger.severe('Failed to get cards by ids: $e');
    return [];
  }
}
