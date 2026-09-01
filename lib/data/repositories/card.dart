import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/llm_call_record_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/data/services/timeline_card_event_publisher.dart';
import 'package:memex/utils/token_usage_utils.dart';

final _logger = getLogger('CardDetailEndpoint');
FileSystemService get _fileSystemService => FileSystemService.instance;

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

    // Raw user input now lives on the card itself (card.fact).
    var rawContent = cardData.fact ?? '';

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
        final character = await CharacterService.instance.getCharacter(
          userId,
          characterId,
        );
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
        final match = RegExp(
          r'(\d{4})/(\d{2})/(\d{2})\.md#ts_\d+$',
        ).firstMatch(relatedId);
        if (match == null) {
          _logger.warning('Invalid fact_id format in related_fact: $relatedId');
          continue;
        }

        final year = match.group(1)!;
        final month = match.group(2)!;
        final day = match.group(3)!;
        final dateStr = '$year-$month-$day';

        // Read related card title
        final relatedCardData = await _fileSystemService.readCardFile(
          userId,
          relatedId,
        );

        // Skip if related card was deleted (physical delete; readCardFile returns null)
        if (relatedCardData == null) {
          _logger.info('Related card deleted, skipping: $relatedId');
          continue;
        }

        final relatedTitle = relatedCardData.title ?? '';

        // card_id uses same format as fact_id
        final relatedCardId = relatedId;

        // Related card content + assets now come from the card's own fields.
        final relatedAssetsAndText =
            await extractAssetsAndRawText(userId, relatedCardData);
        var relatedRawText =
            (relatedAssetsAndText['rawText'] as String?)?.trim() ?? '';
        if (relatedRawText.length > 60) {
          relatedRawText = '${relatedRawText.substring(0, 60)}...';
        }

        relatedCards.add(
          RelatedCard(
            id: relatedCardId,
            title: relatedTitle,
            date: dateStr,
            rawContent: relatedRawText,
            assets: relatedAssetsAndText['assets'] as List<AssetData>,
          ),
        );
      } catch (e) {
        _logger.warning('Failed to process related fact $relatedId: $e');
        continue;
      }
    }

    // Assets come from the card's own fields; rawContent (card.fact) is
    // already free of asset markers.
    final assetsAndText = await extractAssetsAndRawText(userId, cardData);
    final assets = assetsAndText['assets'] as List<AssetData>;
    rawContent = (assetsAndText['rawText'] as String?) ?? rawContent;

    // Read comments (from card file comments field if present)
    final builtComments = <Comment>[];
    // First pass: build comments with character info
    for (final commentData in cardData.comments) {
      try {
        CharacterInfo? commentCharacter;
        if (commentData.isAi && commentData.characterId != null) {
          try {
            final commentChar = await CharacterService.instance.getCharacter(
              userId,
              commentData.characterId!,
            );
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
              'Failed to load comment character ${commentData.characterId}: $e',
            );
          }
        }

        builtComments.add(
          Comment(
            id: commentData.id,
            content: commentData.content,
            isAi: commentData.isAi,
            timestamp: commentData.timestamp,
            character: commentCharacter,
            replyToId: commentData.replyToId,
          ),
        );
      } catch (e) {
        _logger.warning('Failed to process comment: $e');
        continue;
      }
    }

    final comments = withResolvedReplyNames(
      builtComments,
      userDisplayName: UserStorage.l10n.commentReplyToYou,
    );

    // Get LLM call stats
    LLMStats? llmStats;
    try {
      final record = await LLMCallRecordService.instance.getRecord(
        userId: userId,
        scene: 'input',
        sceneId: cardId,
      );

      if (record != null) {
        final calls = record['calls'] as List? ?? [];
        final agentTokens = <String, AgentStats>{};
        int totalCalls = 0;
        int totalPromptTokens = 0;
        int totalCompletionTokens = 0;
        int totalCachedTokens = 0;
        int totalEffectivePromptTokens = 0;
        int totalCachedForRate = 0;
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
          final sem = TokenUsageUtils.resolveFromUsageRecord(usage);
          final effPrompt = TokenUsageUtils.effectivePromptTokensOrNull(
            promptTokens: promptTokens,
            cachedTokens: cachedTokens,
            cachedTokensIncludedInPrompt: sem,
          );

          final cost = TokenUsageUtils.calculateCost(
            model: model,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            cachedTokens: cachedTokens,
            thoughtTokens: thoughtTokens,
            cachedTokensIncludedInPrompt: sem,
          )['total']!;

          totalCalls++;
          totalPromptTokens += promptTokens;
          totalCompletionTokens += completionTokens;
          totalCachedTokens += cachedTokens;
          if (effPrompt != null) {
            totalEffectivePromptTokens += effPrompt;
            totalCachedForRate += cachedTokens;
          }
          totalThoughtTokens += thoughtTokens;
          totalTokens += tokens;
          totalCost += cost;

          // Per-agent accumulation
          final prev = agentTokens[agentName];
          agentTokens[agentName] = AgentStats(
            calls: (prev?.calls ?? 0) + 1,
            promptTokens: (prev?.promptTokens ?? 0) + promptTokens,
            completionTokens: (prev?.completionTokens ?? 0) + completionTokens,
            cachedTokens: (prev?.cachedTokens ?? 0) + cachedTokens,
            effectivePromptTokens:
                (prev?.effectivePromptTokens ?? 0) + (effPrompt ?? 0),
            cachedTokensForRate: (prev?.cachedTokensForRate ?? 0) +
                (effPrompt != null ? cachedTokens : 0),
            thoughtTokens: (prev?.thoughtTokens ?? 0) + thoughtTokens,
            totalTokens: (prev?.totalTokens ?? 0) + tokens,
            totalCost: (prev?.totalCost ?? 0) + cost,
          );
        }

        llmStats = LLMStats(
          totalCalls: totalCalls,
          totalPromptTokens: totalPromptTokens,
          totalCompletionTokens: totalCompletionTokens,
          totalCachedTokens: totalCachedTokens,
          totalEffectivePromptTokens: totalEffectivePromptTokens,
          totalCachedTokensForRate: totalCachedForRate,
          totalThoughtTokens: totalThoughtTokens,
          totalTokens: totalTokens,
          totalCost: totalCost,
          byAgent: agentTokens,
        );
      }
    } catch (e) {
      _logger.warning('Failed to get LLM stats for card $cardId: $e');
      // Continue without stats
    }

    // Render card to get uiConfigs
    final renderResult = await renderCard(
      userId: userId,
      cardData: cardData,
      factContent: cardData.fact,
    );

    // Build CardDetailModel
    // timestamp is local seconds, parse to local time
    return CardDetailModel(
      id: cardId,
      title: title,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000,
        isUtc: true,
      ).toLocal(),
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
      status: renderResult.status,
      failureReason: cardData.failureReason,
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

    await emitTimelineCardUpdated(
      userId: userId,
      cardId: cardId,
      cardData: updatedCardData,
    );

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
  String cardId,
  double lat,
  double lng,
  String name,
) async {
  _logger.info(
    'updateCardLocation called: cardId=$cardId, lat=$lat, lng=$lng, name=$name',
  );

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

    final savedUserLocation =
        await _fileSystemService.addUserLocation(userId, lat, lng, name);
    if (!savedUserLocation) {
      _logger.warning(
        'Updated card location for $cardId, but failed to save reusable user location mark: $name',
      );
    }

    await emitTimelineCardUpdated(
      userId: userId,
      cardId: cardId,
      cardData: updatedCardData,
    );

    _logger.info('Updated user_fixed_location for card $cardId');
    return true;
  } catch (e) {
    _logger.severe('Failed to update card location for $cardId: $e');
    return false;
  }
}

String replyDisplayNameFor(Comment c, String userDisplayName) =>
    c.isAi
        ? (c.character?.name ?? UserStorage.l10n.commentAuthorAi)
        : userDisplayName;

Map<String, String> commentReplyNameMap(
  Iterable<Comment> comments, {
  required String userDisplayName,
}) {
  final commentNameMap = <String, String>{};
  for (final c in comments) {
    commentNameMap[c.id] = replyDisplayNameFor(c, userDisplayName);
  }
  return commentNameMap;
}

List<Comment> withResolvedReplyNames(
  List<Comment> comments, {
  required String userDisplayName,
}) {
  final commentNameMap = commentReplyNameMap(
    comments,
    userDisplayName: userDisplayName,
  );
  final resolved = List<Comment>.from(comments);
  for (var i = 0; i < resolved.length; i++) {
    final c = resolved[i];
    if (c.replyToId != null && c.replyToName == null) {
      final resolvedName = commentNameMap[c.replyToId];
      if (resolvedName != null) {
        resolved[i] = Comment(
          id: c.id,
          content: c.content,
          isAi: c.isAi,
          timestamp: c.timestamp,
          character: c.character,
          replyToId: c.replyToId,
          replyToName: resolvedName,
        );
      }
    }
  }
  return resolved;
}
