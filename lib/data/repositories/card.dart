import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/llm_call_record_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/card_renderer.dart';

final _logger = getLogger('CardDetailEndpoint');
final _fileSystemService = FileSystemService.instance;

/// Get card detail
/// Maps to backend GET /cards/detail
Future<CardDetailModel> getCardDetail(String cardId) async {
  _logger.info('getCardDetail called: cardId=$cardId');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw Exception('No user ID found');
    }

    // card_id is fact_id, same format
    final factId = cardId;

    // Read card data
    final cardData = await _fileSystemService.readCardFile(userId, factId);
    if (cardData == null) {
      throw Exception('Card not found: $cardId');
    }

    // Note: client uses physical delete, so no need to check soft-delete flag
    // If card file exists, it is not deleted

    // Extract basic info
    final title = cardData.title ?? '';
    var timestamp = cardData.timestamp;
    var address = cardData.address ?? '';
    final tags = List<String>.from(cardData.tags);

    // Check for timestamp override
    if (cardData.userFixedTimestamp != null) {
      timestamp = cardData.userFixedTimestamp!;
    }

    // Check for location override
    Map<String, dynamic>? locationInfo;
    final userLoc = cardData.userFixedLocation;
    if (userLoc != null) {
      locationInfo = {
        'lat': userLoc.lat,
        'lng': userLoc.lng,
        'name': userLoc.name,
      };
    }

    if (cardData.userFixedAddress != null) {
      address = cardData.userFixedAddress!;
    } else if (locationInfo != null && locationInfo['name'] != null) {
      address = locationInfo['name'] as String? ?? address;
    }

    // Read raw fact content
    final factInfo =
        await _fileSystemService.extractFactContentFromFile(userId, factId);
    var rawContent = factInfo?.content ?? '';
    final originalRawContent = rawContent;

    // Build asset analysis result map (kept but unused)
    if (factInfo?.assetAnalyses != null && factInfo!.assetAnalyses.isNotEmpty) {
      // Map index -> analysis result
      final analysisMap = <int, String>{};
      for (final analysis in factInfo.assetAnalyses) {
        final index = analysis['index'] as int;
        final analysisContent = analysis['analysis'] as String;
        final toolAnalysis = _extractToolAnalysis(analysisContent);
        if (toolAnalysis.isNotEmpty) {
          analysisMap[index] = toolAnalysis;
        }
      }
    }

    // Extract insight
    final insightData = cardData.insight;
    final insightText = insightData?.text ?? '';
    final summaryText = insightData?.summary ?? '';
    final relatedFactIds =
        insightData?.relatedFacts.map((r) => r.id).toList() ?? <String>[];
    final characterId = insightData?.characterId;

    // Load character info
    CharacterInfo? characterInfo;
    if (characterId != null && characterId.isNotEmpty) {
      try {
        final character =
            await CharacterService.instance.getCharacter(userId, characterId);
        if (character != null) {
          characterInfo = CharacterInfo(
            id: character.id,
            name: character.name,
            tags: character.tags,
            avatar: character.avatar,
          );
        }
      } catch (e) {
        _logger.warning('Failed to load character $characterId: $e');
      }
    }

    // Convert related_fact_ids to RelatedCard list
    // related_facts format: each element is a map with id, e.g. [{"id": "2025/12/05.md#ts_3"}]
    final relatedCards = <RelatedCard>[];
    for (final relatedId in relatedFactIds) {
      try {
        if (relatedId.isEmpty) {
          continue;
        }

        // Parse date from fact_id
        final match = RegExp(r'(\d{4})/(\d{2})/(\d{2})\.md#ts_\d+$')
            .firstMatch(relatedId);
        if (match == null) {
          _logger.warning('Invalid fact_id format in related_fact: $relatedId');
          continue;
        }

        final year = match.group(1)!;
        final month = match.group(2)!;
        final day = match.group(3)!;
        final dateStr = '$year-$month-$day';

        // Read related card title
        final relatedCardData =
            await _fileSystemService.readCardFile(userId, relatedId);

        // Skip if related card was deleted (physical delete; readCardFile returns null)
        if (relatedCardData == null) {
          _logger.info('Related card deleted, skipping: $relatedId');
          continue;
        }

        final relatedTitle = relatedCardData.title ?? '';

        // card_id uses same format as fact_id
        final relatedCardId = relatedId;

        // Read related card content and process assets
        final relatedFactInfo = await _fileSystemService
            .extractFactContentFromFile(userId, relatedId);
        final relatedRawContent = relatedFactInfo?.content ?? '';

        final relatedProcessed = await _parseAssetsAndCleanContent(
            userId, relatedRawContent,
            maxContentLength: 60);

        relatedCards.add(RelatedCard(
          id: relatedCardId,
          title: relatedTitle,
          date: dateStr,
          rawContent: relatedProcessed['content'] as String,
          assets: relatedProcessed['assets'] as List<AssetData>,
        ));
      } catch (e) {
        _logger.warning('Failed to process related fact $relatedId: $e');
        continue;
      }
    }

    // Extract assets and clean rawContent
    final processed = await _parseAssetsAndCleanContent(userId, rawContent);
    final assets = processed['assets'] as List<AssetData>;
    rawContent = processed['content'] as String;

    // Read comments (from card file comments field if present)
    final comments = <Comment>[];
    for (final commentData in cardData.comments) {
      try {
        CharacterInfo? commentCharacter;
        if (commentData.isAi && commentData.characterId != null) {
          try {
            final commentChar = await CharacterService.instance
                .getCharacter(userId, commentData.characterId!);
            if (commentChar != null) {
              commentCharacter = CharacterInfo(
                id: commentChar.id,
                name: commentChar.name,
                tags: commentChar.tags,
                avatar: commentChar.avatar,
              );
            }
          } catch (e) {
            _logger.warning(
                'Failed to load comment character ${commentData.characterId}: $e');
          }
        }

        comments.add(Comment(
          id: commentData.id,
          content: commentData.content,
          isAi: commentData.isAi,
          timestamp: commentData.timestamp,
          character: commentCharacter,
        ));
      } catch (e) {
        _logger.warning('Failed to process comment: $e');
        continue;
      }
    }

    // Get LLM call stats
    LLMStats? llmStats;
    try {
      final record = await LLMCallRecordService.instance.getRecord(
        userId: userId,
        scene: 'input',
        sceneId: cardId,
      );

      if (record != null) {
        final _pricing = {
          'gemini-3-flash-preview': {
            'input': 0.0000005,
            'cached': 0.00000005,
            'output': 0.000003,
          },
          'gemini-2.5-flash': {
            'input': 0.0000003,
            'cached': 0.00000003,
            'output': 0.0000025,
          },
          'gemini-3.1-pro-preview': {
            'input': 0.000002,
            'cached': 0.0000002,
            'output': 0.000012,
          },
          'gemini-3-pro-preview': {
            'input': 0.000002,
            'cached': 0.0000002,
            'output': 0.000012,
          },
          'gpt-4o': {
            'input': 0.0000025,
            'cached': 0.00000125,
            'output': 0.00001,
          },
        };

        double _calculateCost(
            String model, int prompt, int completion, int cached, int thought) {
          // Find matching model pricing
          Map<String, double>? prices;
          for (final key in _pricing.keys) {
            if (model.toLowerCase().contains(key)) {
              prices = _pricing[key];
              break;
            }
          }

          // Default to gpt-4o if not found
          prices ??= _pricing['gpt-4o'];

          if (prices == null) return 0.0;

          // Input cost: (prompt - cached) * input_price + cached * cached_price
          final effectivePrompt = (prompt - cached) > 0 ? (prompt - cached) : 0;
          final inputCost = (effectivePrompt * prices['input']!) +
              (cached * prices['cached']!);

          // Output cost: (completion + thought) * output_price
          final outputCost = model.startsWith(
                  'ep-') // todo: responses API completion includes thought
              ? completion * prices['output']!
              : (completion + thought) * prices['output']!;

          return inputCost + outputCost;
        }

        final calls = record['calls'] as List? ?? [];
        final agentStats = <String, AgentStats>{};
        int totalCalls = 0;
        int totalPromptTokens = 0;
        int totalCompletionTokens = 0;
        int totalCachedTokens = 0;
        int totalThoughtTokens = 0;
        int totalTokens = 0;
        double totalCost = 0.0;

        for (final call in calls) {
          final usage = call['usage'] as Map<String, dynamic>;
          final promptTokens = usage['prompt_tokens'] as int? ?? 0;
          final completionTokens = usage['completion_tokens'] as int? ?? 0;
          final cachedTokens = usage['cached_tokens'] as int? ?? 0;
          final thoughtTokens = usage['thought_tokens'] as int? ?? 0;
          final tokens = usage['total_tokens'] as int? ?? 0;
          final agentName = call['agent_name'] as String;
          final model = call['model'] as String? ?? '';

          final cost = _calculateCost(model, promptTokens, completionTokens,
              cachedTokens, thoughtTokens);

          totalCalls++;
          totalPromptTokens += promptTokens;
          totalCompletionTokens += completionTokens;
          totalCachedTokens += cachedTokens;
          totalThoughtTokens += thoughtTokens;
          totalTokens += tokens;
          totalCost += cost;

          if (!agentStats.containsKey(agentName)) {
            agentStats[agentName] = AgentStats(
              calls: 0,
              promptTokens: 0,
              completionTokens: 0,
              cachedTokens: 0,
              thoughtTokens: 0,
              totalTokens: 0,
              totalCost: 0.0,
            );
          }
          final agentStat = agentStats[agentName]!;
          agentStats[agentName] = AgentStats(
            calls: agentStat.calls + 1,
            promptTokens: agentStat.promptTokens + promptTokens,
            completionTokens: agentStat.completionTokens + completionTokens,
            cachedTokens: agentStat.cachedTokens + cachedTokens,
            thoughtTokens: agentStat.thoughtTokens + thoughtTokens,
            totalTokens: agentStat.totalTokens + tokens,
            totalCost: agentStat.totalCost + cost,
          );
        }

        llmStats = LLMStats(
          totalCalls: totalCalls,
          totalPromptTokens: totalPromptTokens,
          totalCompletionTokens: totalCompletionTokens,
          totalCachedTokens: totalCachedTokens,
          totalThoughtTokens: totalThoughtTokens,
          totalTokens: totalTokens,
          totalCost: totalCost,
          byAgent: agentStats,
        );
      }
    } catch (e) {
      _logger.warning('Failed to get LLM stats for card $cardId: $e');
      // Continue without stats
    }

    // rawContent already cleaned in _parseAssetsAndCleanContent

    // Render card to get uiConfigs
    final renderResult = await renderCard(
      userId: userId,
      cardData: cardData,
      factContent: originalRawContent,
    );

    // Build CardDetailModel
    // timestamp is local seconds, parse to local time
    return CardDetailModel(
      id: cardId,
      title: title,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
              .toLocal(),
      address: address,
      lat: locationInfo?['lat'] != null
          ? (locationInfo!['lat'] as num?)?.toDouble()
          : null,
      lng: locationInfo?['lng'] != null
          ? (locationInfo!['lng'] as num?)?.toDouble()
          : null,
      tags: tags,
      rawContent: rawContent,
      insight: InsightData(
        text: insightText,
        relatedCards: relatedCards,
        characterId: characterId,
        character: characterInfo,
        summary: summaryText,
        comments: comments,
      ),
      assets: assets,
      llmStats: llmStats,
      uiConfigs: renderResult.uiConfigs,
    );
  } catch (e) {
    _logger.severe('Failed to get card detail $cardId: $e');
    rethrow;
  }
}

/// Delete card (physical delete)
///
/// Args:
///   cardId: card ID (fact_id)
///
/// Returns:
///   bool: success
///
/// Note:
///   Client uses physical delete; card file is removed, not soft-deleted
Future<bool> deleteCardEndpoint(String cardId) async {
  _logger.info('deleteCard called: cardId=$cardId');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw Exception('User not logged in, cannot delete card');
    }

    // Check if card exists
    final cardData = await _fileSystemService.readCardFile(userId, cardId);
    if (cardData == null) {
      _logger.warning('Card not found: $cardId');
      return false;
    }

    // Delegate to FileSystemService which handles both physical file and cache deletion
    final success = await _fileSystemService.deleteCard(userId, cardId);
    if (!success) {
      _logger.warning('Failed to delete card: $cardId');
    }
    return success;
  } catch (e) {
    _logger.severe('Failed to delete card $cardId: $e');
    return false;
  }
}

/// Update card time
///
/// Args:
///   cardId: card ID (fact_id)
///   timestamp: new timestamp (Unix seconds)
///
/// Returns:
///   bool: success
Future<bool> updateCardTimeEndpoint(String cardId, int timestamp) async {
  _logger.info('updateCardTime called: cardId=$cardId, timestamp=$timestamp');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw Exception('User not logged in, cannot update card time');
    }

    // Use updateCardFile for user_fixed_timestamp, concurrency-safe
    final updatedCardData = await _fileSystemService.updateCardFile(
      userId,
      cardId,
      (card) => card.copyWith(userFixedTimestamp: timestamp),
    );

    if (updatedCardData == null) {
      _logger.warning('Card not found: $cardId');
      return false;
    }

    _logger.info('Updated user_fixed_timestamp for card $cardId to $timestamp');
    return true;
  } catch (e) {
    _logger.severe('Failed to update card time for $cardId: $e');
    return false;
  }
}

/// Update card location
///
/// Args:
///   cardId: card ID (fact_id)
///   lat: latitude
///   lng: longitude
///   name: place name
///
/// Returns:
///   bool: success
Future<bool> updateCardLocationEndpoint(
    String cardId, double lat, double lng, String name) async {
  _logger.info(
      'updateCardLocation called: cardId=$cardId, lat=$lat, lng=$lng, name=$name');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw Exception('User not logged in, cannot update card location');
    }

    // Use updateCardFile for user_fixed_location, concurrency-safe
    final updatedCardData = await _fileSystemService.updateCardFile(
      userId,
      cardId,
      (card) => card.copyWith(
        userFixedAddress: name,
        userFixedLocation: UserFixedLocation(lat: lat, lng: lng, name: name),
      ),
    );

    if (updatedCardData == null) {
      _logger.warning('Card not found: $cardId');
      return false;
    }

    _logger.info('Updated user_fixed_location for card $cardId');
    return true;
  } catch (e) {
    _logger.severe('Failed to update card location for $cardId: $e');
    return false;
  }
}

/// Extract tool analysis part from analysis result (excluding EXIF)
/// EXIF section starts with "Image metadata:" or "Image Metadata:", format: Image metadata:...\n\nTool analysis result
String _extractToolAnalysis(String analysisContent) {
  // Support both Chinese and English markers
  final exifMarkers = ['Image metadata:', 'Image Metadata:'];
  String? foundMarker;
  int? exifIndex;

  // Find first matching marker
  for (final marker in exifMarkers) {
    final index = analysisContent.indexOf(marker);
    if (index != -1) {
      foundMarker = marker;
      exifIndex = index;
      break;
    }
  }

  // If EXIF present, split it out
  if (foundMarker != null && exifIndex != null) {
    // Search after marker
    final afterExif = analysisContent.substring(exifIndex + foundMarker.length);
    // Content after first double newline is tool analysis
    // Per analyze_assets_handler, EXIF and tool analysis are separated by two newlines
    final doubleNewlineIndex = afterExif.indexOf('\n\n');
    if (doubleNewlineIndex != -1) {
      final toolAnalysis = afterExif.substring(doubleNewlineIndex + 2).trim();
      if (toolAnalysis.isNotEmpty) {
        return toolAnalysis;
      }
    }
    // No double newline or empty after it => EXIF only
    return '';
  }
  // No EXIF, return full analysis
  return analysisContent.trim();
}

/// Parse assets and clean rawContent
Future<Map<String, dynamic>> _parseAssetsAndCleanContent(
    String userId, String rawContent,
    {int? maxContentLength}) async {
  final assets = <AssetData>[];
  var cleanedContent = rawContent;

  if (rawContent.isNotEmpty) {
    // Find images: ![image](fs://xxx.png)
    final imgPattern = RegExp(r'!\[.*?\]\(fs://([^\)]+)\)');
    final imgMatches = imgPattern.allMatches(rawContent);
    final imgFiles = <String>[];
    for (final match in imgMatches) {
      final imgFile = match.group(1)!;
      imgFiles.add(imgFile);

      // Build full assets path
      final assetsPath = _fileSystemService.getAssetsPath(userId);
      final imgPath = path.join(assetsPath, imgFile);
      final imgFileObj = File(imgPath);
      if (await imgFileObj.exists()) {
        // In local mode, convert to local HTTP URL
        final url = await FileSystemService.convertFsToLocalHttp(
            'fs://$imgFile', userId);
        assets.add(AssetData(
          type: 'image',
          url: url,
        ));
      }
    }

    // Find audio: [audio](fs://xxx.m4a)
    final audioPattern = RegExp(r'\[.*?\]\(fs://([^\)]+)\)');
    final audioMatches = audioPattern.allMatches(rawContent);
    for (final match in audioMatches) {
      final audioFile = match.group(1)!;
      // Skip image files (already handled)
      if (!imgFiles.contains(audioFile)) {
        final assetsPath = _fileSystemService.getAssetsPath(userId);
        final audioPath = path.join(assetsPath, audioFile);
        final audioFileObj = File(audioPath);
        if (await audioFileObj.exists()) {
          // In local mode, convert to local HTTP URL
          final url = await FileSystemService.convertFsToLocalHttp(
              'fs://$audioFile', userId);
          assets.add(AssetData(
            type: 'audio',
            url: url,
          ));
        }
      }
    }
  }

  // Remove all image/audio placeholders from rawContent
  final assetPattern =
      RegExp(r'((?:!\[(?:图片|image)\]|\[(?:音频|audio)\])\(fs://[^)]+\))');
  cleanedContent = cleanedContent.replaceAll(assetPattern, '');

  // Collapse 3+ newlines to 2, trim
  cleanedContent = cleanedContent.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

  // Truncate if max length given
  if (maxContentLength != null && cleanedContent.length > maxContentLength) {
    cleanedContent = '${cleanedContent.substring(0, maxContentLength)}...';
  }

  return {
    'assets': assets,
    'content': cleanedContent,
  };
}
