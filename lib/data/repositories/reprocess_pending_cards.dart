import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/logger.dart';

final _logger = getLogger('ReprocessPendingCards');

/// Re-publishes the full agent pipeline (analyze_assets → card_agent → pkm_agent → comment_agent)
/// for every card currently in 'processing' status.
///
/// Called when a valid LLM config is saved for the first time, so cards that were
/// submitted without AI can be properly processed.
Future<void> reprocessPendingCards(String userId) async {
  try {
    final fs = FileSystemService.instance;
    final cardFiles = await fs.listAllCardFiles(userId);
    // Reverse to process oldest first — preserves chronological order for PKM agent
    final orderedFiles = cardFiles.reversed.toList();
    _logger.info('Scanning ${cardFiles.length} cards for pending reprocessing');

    int count = 0;
    for (final cardFilePath in orderedFiles) {
      try {
        final factId = fs.factIdFromCardPath(cardFilePath);
        if (factId == null) continue;

        final card = await fs.readCardFile(userId, factId);
        if (card == null || card.status != 'processing') continue;

        final factInfo = await fs.extractFactContentFromFile(userId, factId);
        if (factInfo == null) continue;

        // Reconstruct assetPaths from fs:// references in combinedText.
        // fs:// URIs contain only the filename; convert to relative paths
        // (relative to dataRoot) so that toAbsolutePath resolves correctly
        // even after an iOS sandbox UUID change.
        final assetsDir = fs.getAssetsPath(userId);
        final assetPaths =
            RegExp(r'fs://([^\s\)]+)').allMatches(factInfo.content).map((m) {
          final filename = m.group(1)!;
          final absolutePath = '$assetsDir/$filename';
          return fs.toRelativePath(absolutePath);
        }).toList();

        // Reconstruct markdownEntry
        final simpleFactId = fs.extractSimpleFactId(factId);
        final dt = factInfo.datetime;
        final timeStr =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
        final markdownEntry =
            '## <id:$simpleFactId> $timeStr "{}"\n\n${factInfo.content}\n';

        // Re-publish the same event submit_input would have published.
        // Event subscriptions in MemexRouter will create the full task chain:
        // analyze_assets → card_agent → pkm_agent → comment_agent
        await GlobalEventBus.instance.publish(
          userId: userId,
          event: SystemEvent(
            type: SystemEventTypes.userInputSubmitted,
            source: 'reprocess_pending_cards',
            payload: UserInputSubmittedPayload(
              factId: factId,
              assetPaths: assetPaths,
              combinedText: factInfo.content,
              markdownEntry: markdownEntry,
              createdAtTs: factInfo.timestamp,
              pkmCreatedAtTs: factInfo.timestamp.toDouble(),
            ),
          ),
        );
        count++;
      } catch (e) {
        _logger.warning('Failed to reprocess card at $cardFilePath: $e');
      }
    }
    _logger.info('Triggered reprocessing for $count pending cards');
  } catch (e) {
    _logger.severe('Failed to reprocess pending cards: $e');
  }
}
