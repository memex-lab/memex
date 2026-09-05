import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/domain/models/card_model.dart';

Future<void> emitTimelineCardAdded({
  required String userId,
  required String cardId,
  required CardData cardData,
}) async {
  final event = await _buildCardAddedMessage(
    userId: userId,
    cardId: cardId,
    cardData: cardData,
  );
  EventBusService.instance.emitEvent(event);
}

Future<void> emitTimelineCardUpdated({
  required String userId,
  required String cardId,
  required CardData cardData,
}) async {
  final event = await _buildCardUpdatedMessage(
    userId: userId,
    cardId: cardId,
    cardData: cardData,
  );
  EventBusService.instance.emitEvent(event);
}

Future<CardAddedMessage> _buildCardAddedMessage({
  required String userId,
  required String cardId,
  required CardData cardData,
}) async {
  final payload = await _buildTimelineCardEventPayload(
    userId: userId,
    cardData: cardData,
  );
  return CardAddedMessage(
    id: cardId,
    html: payload.html,
    timestamp: cardData.userFixedTimestamp ?? cardData.timestamp,
    tags: cardData.tags,
    status: payload.status,
    title: cardData.title,
    uiConfigs: payload.uiConfigs,
    assets: payload.assets,
    rawText: payload.rawText,
    address: cardData.userFixedAddress ?? cardData.address,
  );
}

Future<CardUpdatedMessage> _buildCardUpdatedMessage({
  required String userId,
  required String cardId,
  required CardData cardData,
}) async {
  final payload = await _buildTimelineCardEventPayload(
    userId: userId,
    cardData: cardData,
  );
  return CardUpdatedMessage(
    id: cardId,
    html: payload.html,
    timestamp: cardData.userFixedTimestamp ?? cardData.timestamp,
    tags: cardData.tags,
    status: payload.status,
    title: cardData.title,
    uiConfigs: payload.uiConfigs,
    assets: payload.assets,
    rawText: payload.rawText,
    address: cardData.userFixedAddress ?? cardData.address,
    failureReason: cardData.failureReason,
  );
}

Future<_TimelineCardEventPayload> _buildTimelineCardEventPayload({
  required String userId,
  required CardData cardData,
}) async {
  if (cardData.status == 'processing') {
    return _TimelineCardEventPayload(
      html: '',
      status: cardData.status,
      uiConfigs: cardData.uiConfigs,
      assets: null,
      rawText: cardData.fact,
    );
  }

  final renderResult = await renderCard(
    userId: userId,
    cardData: cardData,
    factContent: cardData.fact,
  );
  final assetsAndText = await extractAssetsAndRawText(userId, cardData);
  final assets = (assetsAndText['assets'] as List<AssetData>)
      .map((asset) => asset.toJson())
      .toList();
  final rawText = assetsAndText['rawText'] as String?;

  return _TimelineCardEventPayload(
    html: renderResult.html ?? '',
    status: renderResult.status,
    uiConfigs: renderResult.uiConfigs,
    assets: assets.isEmpty ? null : assets,
    rawText: rawText,
  );
}

class _TimelineCardEventPayload {
  const _TimelineCardEventPayload({
    required this.html,
    required this.status,
    required this.uiConfigs,
    required this.assets,
    required this.rawText,
  });

  final String html;
  final String status;
  final List<UiConfig> uiConfigs;
  final List<Map<String, dynamic>>? assets;
  final String? rawText;
}
