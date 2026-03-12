import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/domain/models/card_detail_model.dart'; // Import for AssetData
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/card_renderer.dart';

final _logger = getLogger('GetTimelineCardEndpoint');

/// Get single timeline card
/// Maps to backend GET /timeline/:id (or equivalent)
Future<TimelineCardModel?> getTimelineCard(String cardId) async {
  _logger.info('getTimelineCard called: cardId=$cardId');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      _logger.warning('No user ID found');
      return null;
    }

    final fileSystemService = FileSystemService.instance;
    final factId = cardId;

    // Read card data
    final cardData = await fileSystemService.readCardFile(userId, factId);
    if (cardData == null) {
      _logger.warning('Card file not found: $factId');
      return null;
    }

    if (cardData.deleted == true) {
      _logger.warning('Card is deleted: $factId');
      return null;
    }

    // Get timestamp and content from Facts
    final factInfo =
        await fileSystemService.extractFactContentFromFile(userId, factId);

    int timestamp;
    String? factContent;

    if (factInfo != null) {
      timestamp = factInfo.timestamp;
      factContent = factInfo.content;
    } else {
      timestamp = cardData.timestamp;
    }

    // Render card
    final renderResult = await renderCard(
      userId: userId,
      cardData: cardData,
      factContent: factContent,
    );

    // Extract assets and rawText
    final assetsAndText = await extractAssetsAndRawText(userId, factContent);
    final assets = assetsAndText['assets'] as List<AssetData>;
    final rawText = assetsAndText['rawText'] as String?;

    // Build TimelineCardModel
    // timestamp is seconds, convert to ms
    return TimelineCardModel(
      id: factId,
      html: renderResult.html,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
              .toLocal(),
      tags: List<String>.from(cardData.tags),
      status: renderResult.status,
      title: cardData.title,
      uiConfigs: renderResult.uiConfigs,
      assets: assets.isNotEmpty ? assets : null,
      rawText: rawText,
      failureReason: cardData.failureReason,
    );
  } catch (e) {
    _logger.severe('Failed to fetch timeline card $cardId: $e');
    return null;
  }
}
