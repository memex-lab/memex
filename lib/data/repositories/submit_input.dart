import 'package:synchronized/synchronized.dart';

import 'package:memex/utils/logger.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/data/services/resource_recognition/resource_recognizer.dart';
import 'package:memex/data/services/resource_recognition/resource_type.dart';

final _logger = getLogger('SubmitInputEndpoint');
final _fileSystem = FileSystemService.instance;
final _lock = Lock();

/// Submit input locally
///
/// Mirroring backend logic:
/// 1. Save assets
/// 2. Create Fact ID
/// 3. Append to Daily Fact
/// 4. Create Placeholder Card
/// 5. Enqueue Async Tasks
Future<Map<String, dynamic>> submitInput(
  String userId,
  List<Map<String, dynamic>> content,
) async {
  return _lock.synchronized(() async {
    final now = DateTime.now();
    _logger.info('Processing local input for user $userId at $now');

    final textParts = <String>[];
    final assetPaths = <String>[];
    final imageUrls = <String>[];
    String? audioUrl;
    final hashesToRecord = <String>[];

    // 2. Generate Fact ID (Moved up before content processing to get factId)
    final factId = await _fileSystem.generateFactId(userId, now);
    final simpleFactId = _fileSystem.extractSimpleFactId(factId);
    final timeStr = _fileSystem.formatTime(now);

    int imgIndex = 1;
    int audioIndex = 1;

    // 1. Process Content (Text & Media)
    for (final item in content) {
      final type = item['type'];
      final clientHash = item['client_hash'] as String?;
      if (clientHash != null && clientHash.isNotEmpty) {
        hashesToRecord.add(clientHash);
      }

      if (type == 'text') {
        final text = item['text'] as String?;
        if (text != null && text.trim().isNotEmpty) {
          textParts.add(text.trim());
        }
      } else if (type == 'image_url') {
        // Handle images (filepath)
        final imageUrl = item['image_url'] as Map<String, dynamic>?;
        final filePath = imageUrl?['filePath'] as String?;

        if (filePath != null && filePath.isNotEmpty) {
          // Optimized local path
          try {
            final (filename, relativePath) =
                await _fileSystem.saveAssetFromFile(
              userId: userId,
              sourcePath: filePath,
              assetType: 'img',
              index: imgIndex,
              factId: factId,
            );
            imgIndex++;

            // Add to images list for native card
            imageUrls.add('fs://$filename');
            // Also add to markdown for fact file
            textParts.add('![image](fs://$filename)');
            // Save relative path (already returned from saveAssetFromFile)
            assetPaths.add(relativePath);
          } catch (e) {
            _logger.warning('Failed to save image asset from file: $e');
          }
        }
      } else if (type == 'input_audio') {
        // Handle audio (filepath)
        final inputAudio = item['input_audio'] as Map<String, dynamic>?;
        final filePath = inputAudio?['filePath'] as String?;

        if (filePath != null && filePath.isNotEmpty) {
          // Optimized local path
          try {
            final (filename, relativePath) =
                await _fileSystem.saveAssetFromFile(
              userId: userId,
              sourcePath: filePath,
              assetType: 'audio',
              index: audioIndex,
              factId: factId,
            );
            audioIndex++;

            // Set audioUrl for native card
            audioUrl = 'fs://$filename';
            // Also add to markdown for fact file
            textParts.add('[audio](fs://$filename)');
            // Save relative path (already returned from saveAssetFromFile)
            assetPaths.add(relativePath);
          } catch (e) {
            _logger.warning('Failed to save audio asset from file: $e');
          }
        }
      }
    }

    // Default to "(Empty Input)" if nothing
    if (textParts.isEmpty) {
      textParts.add('(Empty input)');
    }

    final combinedText = textParts.join('\n\n');

    // 1.5 Resource Recognition: detect URLs, PDFs, etc. in text input
    // Phase 1: Synchronous detection (instant, no network calls)
    // Phase 2 (async enrichment) runs in the background after submit — see TODO below
    List<ResourceMetadata>? recognizedResources;
    // Only filter out image/audio markdown refs (![...]), keep [link](url) for URL detection
    final pureText = textParts.where((p) => !p.startsWith('![')).join('\n');
    try {
      if (ResourceRecognizer.containsResources(pureText)) {
        // Synchronous detection — just regex, no blocking
        final detected = ResourceRecognizer.detectResources(pureText);
        if (detected.isNotEmpty) {
          recognizedResources = detected;
          _logger
              .info('Detected ${detected.length} resource(s) from input text');
        }
      }
    } catch (e) {
      _logger.warning('Resource detection failed (non-blocking): $e');
    }
    // Extract pure text content (without markdown image/audio references)
    final textContent = textParts
        .where((part) => !part.startsWith('![') && !part.startsWith('['))
        .join('\n\n');
    final pureTextContent = textContent.isEmpty ? '' : textContent;

    // 3. Append to Daily Fact
    // Format: ## <id:ts_X> HH:MM:SS "{}"\n\nContent
    final markdownEntry =
        '## <id:$simpleFactId> $timeStr "{}"\n\n$combinedText\n';
    try {
      await _fileSystem.appendToDailyFactFile(userId, now, markdownEntry);

      // Log user input event
      try {
        await _fileSystem.eventLogService.logUserInput(
          userId: userId,
          description: 'User submitted input',
          metadata: {
            'fact_id': factId,
            'has_text': pureTextContent.isNotEmpty,
            'has_images': imageUrls.isNotEmpty,
            'has_audio': audioUrl != null,
          },
        );

        // Log fact file modification
        final year = now.year;
        final month = now.month.toString().padLeft(2, '0');
        final day = now.day.toString().padLeft(2, '0');
        final factFilePath = 'Facts/$year/$month/$day.md';
        await _fileSystem.eventLogService.logFileModified(
          userId: userId,
          filePath: factFilePath,
          description: 'User input appended to daily fact file',
          metadata: {'fact_id': factId},
        );
      } catch (e) {
        // Event logging failure should not break submission
      }
    } catch (e) {
      _logger.severe('Failed to append to daily fact: $e');
      rethrow;
    }

    // 4. Create Placeholder Card (Processing state)
    // Build data object with proper field separation for placeholder card
    final placeholderData = <String, dynamic>{
      'content': pureTextContent,
    };

    // Add images if any
    if (imageUrls.isNotEmpty) {
      placeholderData['images'] = imageUrls;
    }

    // Add audio if any
    if (audioUrl != null && audioUrl.isNotEmpty) {
      placeholderData['audioUrl'] = audioUrl;
    }

    // Add recognized resources if any
    if (recognizedResources != null && recognizedResources.isNotEmpty) {
      placeholderData['resources'] =
          recognizedResources.map((r) => r.toJson()).toList();
    }

    final placeholderCard = CardData(
      factId: factId,
      title: '',
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
      status: 'processing',
      tags: const [],
      uiConfigs: [
        UiConfig(
          templateId: 'classic_card',
          data: placeholderData,
        ),
      ],
    );

    final cardPath = _fileSystem.getCardPath(userId, factId);
    try {
      final success =
          await _fileSystem.safeWriteCardFile(userId, factId, placeholderCard);
      if (success) {
        _logger.info('Created placeholder card: $cardPath');
      } else {
        _logger.warning(
            'Failed to create placeholder card (safeWriteCardFile returned false)');
      }
    } catch (e) {
      _logger.warning('Failed to create placeholder card: $e');
      // Continue anyway
    }

    final publishTimestamp = now.millisecondsSinceEpoch ~/ 1000;

    // 5. Publish domain event.
    // Event subscriptions convert this event into persistent tasks and dependency chains.
    await GlobalEventBus.instance.publish(
      userId: userId,
      event: SystemEvent(
        type: SystemEventTypes.userInputSubmitted,
        source: 'submit_input.submitInput',
        payload: UserInputSubmittedPayload(
          factId: factId,
          assetPaths: assetPaths,
          combinedText: combinedText,
          markdownEntry: markdownEntry,
          createdAtTs: publishTimestamp,
          pkmCreatedAtTs: now.millisecondsSinceEpoch / 1000.0,
          resources: recognizedResources,
        ),
      ),
    );

    _logger.info('Published user input submitted event for fact $factId');

    // Use unified renderCard method to process placeholder card
    // This will replace fs:// URLs with http URLs
    final renderResult = await renderCard(
      userId: userId,
      cardData: placeholderCard,
      factContent: combinedText,
    );

    if (hashesToRecord.isNotEmpty) {
      await _fileSystem.recordProcessedHashes(userId, hashesToRecord);
    }

    return {
      'fact_id': factId,
      'card': {
        'id': factId,
        'status': renderResult.status,
        'timestamp': now.millisecondsSinceEpoch ~/ 1000,
        'title': "",
        'ui_configs': renderResult.uiConfigs.map((e) => e.toJson()).toList(),
        'tags': [],
      }
    };
  });
}

/// Check unprocessed hashes
Future<List<String>> checkUnprocessedHashes(
  String userId,
  List<String> hashes,
) async {
  return _fileSystem.checkUnprocessedHashes(userId, hashes);
}
