import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/utils/logger.dart';

final _logger = getLogger('HydrateCard');

/// Hydrate a single card from its fact_id: read card file, render HTML,
/// extract assets, and build a [TimelineCardModel].
///
/// Returns null if the card file is missing or unreadable.
/// Shared by getTimelineCards, getCardsByIds, and searchCards.
Future<TimelineCardModel?> hydrateCard(String userId, String factId) async {
  final fs = FileSystemService.instance;

  final cardData = await fs.readCardFile(userId, factId);
  if (cardData == null) {
    _logger.warning('Card file missing for: $factId');
    return null;
  }

  if (cardData.deleted == true) return null;

  final factInfo = await fs.extractFactContentFromFile(userId, factId);
  final factContent = factInfo?.content;
  final timestamp = factInfo?.timestamp ?? cardData.timestamp;

  final renderResult = await renderCard(
    userId: userId,
    cardData: cardData,
    factContent: factContent,
  );

  final assetsAndText = await extractAssetsAndRawText(userId, factContent);
  final assets = assetsAndText['assets'] as List<AssetData>;
  final rawText = assetsAndText['rawText'] as String?;

  return TimelineCardModel(
    id: factId,
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
    address: cardData.address,
    failureReason: cardData.failureReason,
  );
}
