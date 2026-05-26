import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/domain/models/card_generation_retry_result.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('RetryFailedCardsEndpoint');

Future<int> countFailedCardGenerations() async {
  final userId = await UserStorage.getUserId();
  if (userId == null) return 0;

  final failedIds = await _listFailedCardIds(userId);
  return failedIds.length;
}

Future<bool> retryFailedCardGeneration(String factId) async {
  final userId = await UserStorage.getUserId();
  if (userId == null) {
    throw Exception('User not logged in, cannot retry card generation');
  }

  final result = await _retryCardForUser(userId, factId);
  return result;
}

Future<CardGenerationRetryResult> retryAllFailedCardGenerations() async {
  final userId = await UserStorage.getUserId();
  if (userId == null) {
    throw Exception('User not logged in, cannot retry failed cards');
  }

  final failedIds = await _listFailedCardIds(userId);
  var retried = 0;
  var skipped = 0;
  final errors = <String, String>{};

  for (final factId in failedIds) {
    try {
      final didRetry = await _retryCardForUser(userId, factId);
      if (didRetry) {
        retried++;
      } else {
        skipped++;
      }
    } catch (e) {
      errors[factId] = e.toString();
    }
  }

  return CardGenerationRetryResult(
    requested: failedIds.length,
    retried: retried,
    skipped: skipped,
    errors: errors,
  );
}

Future<List<String>> _listFailedCardIds(String userId) async {
  final fs = FileSystemService.instance;
  final cardFiles = await fs.listAllCardFiles(userId);
  final failedIds = <String>[];

  for (final path in cardFiles) {
    final factId = fs.factIdFromCardPath(path);
    if (factId == null) continue;

    try {
      final card = await fs.readCardFile(userId, factId);
      if (card?.status == 'failed') {
        failedIds.add(factId);
      }
    } catch (e) {
      _logger.warning('Failed to inspect card $factId for retry: $e');
    }
  }

  return failedIds;
}

Future<bool> _retryCardForUser(String userId, String factId) async {
  final fs = FileSystemService.instance;
  final card = await fs.readCardFile(userId, factId);
  if (card == null || card.status != 'failed') {
    _logger.info('Skip retry for $factId: card is missing or not failed');
    return false;
  }

  final factInfo = await fs.extractFactContentFromFile(userId, factId);
  if (factInfo == null) {
    throw Exception('Original fact content not found for $factId');
  }

  final updatedCard = await fs.updateCardFile(
    userId,
    factId,
    (current) =>
        current.copyWith(status: 'processing', clearFailureReason: true),
  );

  if (updatedCard == null) {
    throw Exception('Card not found for retry: $factId');
  }

  await _emitCardProcessingUpdate(
    userId: userId,
    factId: factId,
    combinedText: factInfo.content,
  );

  final simpleFactId = fs.extractSimpleFactId(factId);
  final dt = factInfo.datetime;
  final timeStr =
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  final markdownEntry =
      '## <id:$simpleFactId> $timeStr "{}"\n\n${factInfo.content}\n';

  await GlobalEventBus.instance.publish(
    userId: userId,
    event: SystemEvent(
      type: SystemEventTypes.userInputSubmitted,
      source: 'retry_failed_cards.retryFailedCardGeneration',
      payload: UserInputSubmittedPayload(
        factId: factId,
        assetPaths: _assetPathsFromContent(userId, factInfo.content),
        combinedText: factInfo.content,
        markdownEntry: markdownEntry,
        createdAtTs: factInfo.timestamp,
        pkmCreatedAtTs: factInfo.timestamp.toDouble(),
      ),
    ),
  );

  _logger.info('Triggered card generation retry for $factId');
  return true;
}

List<String> _assetPathsFromContent(String userId, String content) {
  final fs = FileSystemService.instance;
  final assetsDir = fs.getAssetsPath(userId);
  return RegExp(r'fs://([^\s\)]+)').allMatches(content).map((m) {
    final filename = m.group(1)!;
    return fs.toRelativePath('$assetsDir/$filename');
  }).toList();
}

Future<void> _emitCardProcessingUpdate({
  required String userId,
  required String factId,
  required String combinedText,
}) async {
  final fs = FileSystemService.instance;
  final cardData = await fs.readCardFile(userId, factId);
  if (cardData == null) return;

  final renderResult = await renderCard(
    userId: userId,
    cardData: cardData,
    factContent: combinedText,
  );
  final assetsAndText = await extractAssetsAndRawText(userId, combinedText);
  final assets = (assetsAndText['assets'] as List<AssetData>)
      .map((a) => a.toJson())
      .toList();
  final rawText = assetsAndText['rawText'] as String?;

  EventBusService.instance.emitEvent(
    CardUpdatedMessage(
      id: factId,
      html: renderResult.html ?? '',
      timestamp: cardData.timestamp,
      tags: cardData.tags,
      status: renderResult.status,
      title: cardData.title,
      uiConfigs: renderResult.uiConfigs,
      assets: assets.isNotEmpty ? assets : null,
      rawText: rawText,
      address: cardData.address,
    ),
  );
}
