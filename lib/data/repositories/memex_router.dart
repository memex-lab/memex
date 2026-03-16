import 'dart:convert';
import 'dart:io';
import 'package:memex/domain/models/calendar_model.dart';
import 'package:memex/data/repositories/update_card_ui_config.dart'
    as update_config_endpoint;
import 'package:memex/data/services/task_handlers/knowledge_insight_handler.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:memex/data/repositories/get_timeline_card.dart'; // Import for fetchTimelineCard
import 'package:logging/logging.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/domain/models/tag_model.dart';
import 'package:memex/domain/models/insight_detail_model.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/agent_config.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/repositories/submit_input.dart'
    as submit_input_endpoint;
import 'package:memex/data/services/task_handlers/analyze_assets_handler.dart';
import 'package:memex/data/services/task_handlers/card_agent_handler.dart';
import 'package:memex/data/services/task_handlers/pkm_agent_handler.dart';
import 'package:memex/data/services/task_handlers/comment_agent_handler.dart';
import 'package:memex/data/services/task_handlers/reprocess_cards_handler.dart';
import 'package:memex/data/services/task_handlers/reprocess_comments_handler.dart';
import 'package:memex/data/services/task_handlers/reprocess_knowledge_base_handler.dart';
import 'package:memex/data/repositories/get_tags.dart';
import 'package:memex/data/repositories/get_timeline_cards.dart';
import 'package:memex/data/repositories/get_aggregated_timeline.dart';
import 'package:memex/data/repositories/get_cards_by_ids.dart';
import 'package:memex/data/repositories/get_calendar_data.dart';
import 'package:memex/data/repositories/card.dart';
import 'package:memex/data/repositories/post_comment.dart';
import 'package:memex/data/repositories/pin_insight.dart';
import 'package:memex/data/repositories/character.dart';
import 'package:memex/data/repositories/health.dart' as health_endpoint;
import 'package:memex/data/repositories/pkm.dart' as pkm_endpoint;
import 'package:memex/domain/models/knowledge_insight_card.dart';
import 'package:memex/data/repositories/get_knowledge_insight_detail.dart';
import 'package:memex/data/repositories/chat.dart' as chat_endpoint;
import 'package:memex/data/services/llm_call_record_service.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/agent/skills/knowledge_insight/native_widgets.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/domain/models/system_event.dart';

/// Local data service for Memex. Handles all data operations via local storage (FileSystemService, DB).
class MemexRouter {
  static final MemexRouter _instance = MemexRouter._();
  factory MemexRouter() => _instance;

  final Logger _logger = getLogger('MemexRouter');

  Future<void>? _initFuture;

  FileSystemService get fileSystemService => FileSystemService.instance;

  MemexRouter._() {
    AgentActivityService.setInstance(LocalAgentActivityService.instance);
    _ensureInitialized();
  }

  Future<void> _init() async {
    try {
      // 1. Resolve data root for current user (per-user workspace storage; logs/DB stay in app dir)
      final userId = await UserStorage.getUserId();
      final dataRoot = await UserStorage.resolveDataRoot(userId);
      FileSystemService.init(dataRoot);

      if (userId == null) {
        _logger.warning(
            'No user ID found during initialization. Local DB will NOT be initialized until login.');
        return; // Do not initialize DB yet.
      }

      // Use userId to init DB (drift_flutter handles path isolation via name)
      _logger.info('Initializing Local DB for user: $userId');
      await AppDatabase.init(userId);
      await LocalTaskExecutor.instance.start(userId: userId);

      // Register Task Handlers - idempotent registration or check if registered?
      // LocalTaskExecutor handles this map, re-registering overwrites which is fine.
      LocalTaskExecutor.instance
          .registerHandler('handle_analyze_assets', handleAnalyzeAssetsImpl);
      LocalTaskExecutor.instance
          .registerHandler('card_agent_task', handleCardAgentImpl);
      LocalTaskExecutor.instance
          .registerHandler('pkm_agent_task', handlePkmAgentImpl);
      LocalTaskExecutor.instance
          .registerHandler('reprocess_cards_task', handleReprocessCardsImpl);
      LocalTaskExecutor.instance
          .registerHandler('comment_agent_task', handleCommentAgentImpl);
      LocalTaskExecutor.instance.registerHandler(
          'reprocess_comments_task', handleReprocessCommentsImpl);
      LocalTaskExecutor.instance.registerHandler(
          'reprocess_knowledge_base_task', handleReprocessKnowledgeBaseImpl);
      LocalTaskExecutor.instance
          .registerHandler('process_ai_reply', handleProcessAiReplyImpl);
      LocalTaskExecutor.instance
          .registerHandler('knowledge_insight_task', handleKnowledgeInsight);

      // Register Failure Handlers
      LocalTaskExecutor.instance.registerFailureHandler(
          'card_agent_task', handleCardAgentFailureImpl);

      // Register event subscriptions after task handlers are ready.
      _registerEventSubscriptions();
    } catch (e) {
      _logger.severe('Failed to initialize MemexRouter: $e');
      // Reset future to allow retry if needed, or keep failed state
      // _initFuture = null;
      rethrow;
    }
  }

  String?
      _targetUserIdForInit; // Track the user ID we are currently initializing for

  void _registerEventSubscriptions() {
    final eventBus = GlobalEventBus.instance;

    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'analyze_assets',
        taskType: 'handle_analyze_assets',
        payloadBuilder: (_, event) {
          return Future.value({
            'fact_id': event.payload['fact_id'],
            'asset_paths': event.payload['asset_paths'] ?? const [],
          });
        },
      ),
    );

    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'card_agent',
        taskType: 'card_agent_task',
        dependsOn: const ['analyze_assets'],
        payloadBuilder: (_, event) {
          return Future.value({
            'fact_id': event.payload['fact_id'],
            'combined_text': event.payload['combined_text'],
            'markdown_entry': event.payload['markdown_entry'],
            'created_at_ts': event.payload['created_at_ts'],
          });
        },
      ),
    );

    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'pkm_agent',
        taskType: 'pkm_agent_task',
        dependsOn: const ['analyze_assets'],
        payloadBuilder: (_, event) {
          return Future.value({
            'fact_id': event.payload['fact_id'],
            'combined_text': event.payload['combined_text'],
            'created_at_ts': event.payload['pkm_created_at_ts'],
          });
        },
        dependenciesBuilder: (_, __) async {
          final lastPkmTaskId = await LocalTaskExecutor.instance
              .getLastTaskByType('pkm_agent_task');
          return lastPkmTaskId == null ? const [] : [lastPkmTaskId];
        },
      ),
    );

    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'comment_agent',
        taskType: 'comment_agent_task',
        dependsOn: const ['pkm_agent'],
        payloadBuilder: (_, event) {
          return Future.value({
            'fact_id': event.payload['fact_id'],
            'combined_text': event.payload['combined_text'],
            'created_at_ts': event.payload['created_at_ts'],
          });
        },
      ),
    );

    eventBus.subscribe(
      eventType: SystemEventTypes.cardCommentPosted,
      subscription: EventTaskSubscription(
        subscriptionId: 'ai_reply',
        taskType: 'process_ai_reply',
        payloadBuilder: (_, event) {
          return Future.value({
            'card_id': event.payload['card_id'],
            'content': event.payload['content'],
            'comment_id': event.payload['comment_id'],
          });
        },
      ),
    );

    eventBus.subscribe(
      eventType: SystemEventTypes.knowledgeInsightRefreshRequested,
      subscription: EventTaskSubscription(
        subscriptionId: 'knowledge_insight_refresh',
        taskType: 'knowledge_insight_task',
        payloadBuilder: (_, event) => Future.value(event.payload),
      ),
    );
  }

  Future<void> _ensureInitialized() async {
    // We double check if a user is logged in now, and if we need to re-init.
    final currentUser = await UserStorage.getUserId();

    // If we are already initializing (or have initialized) for this user, return the existing future.
    // This prevents infinite loops when multiple calls happen while initialization is in progress.
    if (_targetUserIdForInit == currentUser && _initFuture != null) {
      return _initFuture!;
    }

    _logger.info(
        'Re-initializing MemexRouter. Previous Target: $_targetUserIdForInit, New Target: $currentUser');

    _targetUserIdForInit = currentUser;
    _initFuture = _init();
    return _initFuture!;
  }

  /// External hook to force switch user (e.g. on login)
  Future<void> switchUser(String userId) async {
    _logger.info('Switching user to $userId');
    _targetUserIdForInit = null;
    _initFuture = null;
    await _ensureInitialized();
  }

  /// Clear init state and stop executor on logout so next login re-inits for new user.
  void resetForLogout() {
    _logger.info('Resetting MemexRouter for logout');
    _targetUserIdForInit = null;
    _initFuture = null;
    LocalTaskExecutor.instance.stop();
  }

  void dispose() {
    LocalTaskExecutor.instance.stop();
  }

  AgentActivityService get agentActivityService =>
      LocalAgentActivityService.instance;

  Future<String?> getToken() async {
    return null;
  }

  Future<Map<String, dynamic>> submitInput({
    String? text,
    List<XFile> images = const [],
    String? audioPath,
    String? textHash,
    List<String>? imageHashes,
    String? audioHash,
  }) async {
    await _ensureInitialized();
    _logger.info(
        'LocalMode: submitInput called. Text: $text, Images: ${images.length}, Audio: $audioPath');

    final content = <Map<String, dynamic>>[];

    // Add Text
    if (text != null && text.isNotEmpty) {
      content.add({'type': 'text', 'text': text, 'client_hash': textHash});
    }

    // Add Images
    for (var i = 0; i < images.length; i++) {
      final image = images[i];
      final hash = (imageHashes != null && i < imageHashes.length)
          ? imageHashes[i]
          : null;

      // Local Optimization: Pass file path directly
      content.add({
        'type': 'image_url',
        'client_hash': hash,
        'image_url': {
          'filePath': image.path,
        }
      });
    }

    // Add Audio
    if (audioPath != null) {
      final audioFile = File(audioPath);
      if (await audioFile.exists()) {
        // Local Optimization: Pass file path directly
        content.add({
          'type': 'input_audio',
          'client_hash': audioHash,
          'input_audio': {
            'filePath': audioPath,
          }
        });
      }
    }

    // Get current user ID
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw Exception('User not logged in, cannot submit local data');
    }

    return submit_input_endpoint.submitInput(userId, content);
  }

  Future<List<String>> checkProcessedHashes(List<String> hashes) async {
    await _ensureInitialized();
    if (hashes.isEmpty) return [];

    final userId = await UserStorage.getUserId();
    if (userId == null) return hashes;

    return submit_input_endpoint.checkUnprocessedHashes(userId, hashes);
  }

  Future<Result<List<TagModel>>> fetchTags() async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info('LocalMode: fetchTags called');
      return getTags();
    });
  }

  Future<List<TagModel>> fetchTagsByPeriod({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    await _ensureInitialized();
    _logger.info(
        'LocalMode: fetchTagsByPeriod called: dateFrom=$dateFrom, dateTo=$dateTo');

    // Get all cards in the period with a large limit to capture all tags
    final cards = await getTimelineCards(
      page: 1,
      limit: 1000, // Large limit to get all cards in period
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    // Extract unique tag names from cards
    final Set<String> uniqueTagNames = {};
    for (final card in cards) {
      uniqueTagNames.addAll(card.tags);
    }

    // Get all tag definitions
    final allTags = await getTags();

    // Filter to only tags that exist in the period
    return allTags.where((tag) => uniqueTagNames.contains(tag.name)).toList();
  }

  Future<Result<List<TimelineCardModel>>> fetchTimelineCards({
    int page = 1,
    int limit = 20,
    List<String>? tags,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
          'LocalMode: fetchTimelineCards called: page=$page, limit=$limit, tags=$tags, dateFrom=$dateFrom, dateTo=$dateTo');
      return getTimelineCards(
        page: page,
        limit: limit,
        tags: tags,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    });
  }

  Future<Result<Map<String, dynamic>>> fetchAggregatedTimeline({
    required String groupBy,
    int page = 1,
    int limit = 20,
    List<String>? tags,
  }) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
          'LocalMode: fetchAggregatedTimeline called: groupBy=$groupBy, page=$page, limit=$limit, tags=$tags');
      return getAggregatedTimeline(
        groupBy: groupBy,
        page: page,
        limit: limit,
        tags: tags,
      );
    });
  }

  Future<List<TimelineCardModel>> fetchCardByIds(List<String> ids) async {
    await _ensureInitialized();
    _logger.info('LocalMode: fetchCardByIds called: ids=$ids');
    return getCardsByIds(ids);
  }

  Future<Result<List<CalendarDay>>> fetchCalendarData(
      int fromTimestamp, int toTimestamp) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
          'LocalMode: fetchCalendarData called: fromTimestamp=$fromTimestamp, toTimestamp=$toTimestamp');
      return getCalendarData(fromTimestamp, toTimestamp);
    });
  }

  Future<TimelineCardModel?> fetchTimelineCard(String cardId) async {
    await _ensureInitialized();
    _logger.info('LocalMode: fetchTimelineCard called: cardId=$cardId');
    return getTimelineCard(cardId);
  }

  Future<CardDetailModel> fetchCardDetail(String cardId) async {
    await _ensureInitialized();
    _logger.info('LocalMode: fetchCardDetail called: cardId=$cardId');
    return getCardDetail(cardId);
  }

  Future<Map<String, dynamic>> postComment(
      String cardId, String content) async {
    await _ensureInitialized();
    _logger.info('LocalMode: postComment called: cardId=$cardId');

    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in, cannot submit comment');
      }

      return await postCommentEndpoint(cardId, userId, content);
    } catch (e) {
      _logger.severe('Failed to post comment for card $cardId: $e');
      rethrow;
    }
  }

  Future<void> enqueueTask({
    required String taskType,
    required Map<String, dynamic> payload,
    String? bizId,
  }) async {
    await _ensureInitialized();
    _logger.info('LocalMode: enqueueTask called: type=$taskType, bizId=$bizId');

    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      await LocalTaskExecutor.instance.enqueueTask(
        userId: userId,
        taskType: taskType,
        payload: payload,
        bizId: bizId,
      );
    } catch (e) {
      _logger.severe('Failed to enqueue task $taskType: $e');
      rethrow;
    }
  }

  /// Clears all workspace data except the Facts directory.
  /// Only the Facts directory is kept; all other subdirectories are deleted.
  Future<void> clearData() async {
    await _ensureInitialized();
    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final workspacePath = fileSystemService.getWorkspacePath(userId);
      final workspaceDir = Directory(workspacePath);
      if (!await workspaceDir.exists()) return;

      await for (final entity in workspaceDir.list(followLinks: false)) {
        if (entity is Directory) {
          final name = path.basename(entity.path);
          if (name == 'Facts') continue;
          try {
            await entity.delete(recursive: true);
            _logger.info('Deleted directory: ${entity.path}');
          } catch (e) {
            _logger.warning('Failed to delete ${entity.path}: $e');
          }
        }
      }

      // Clear card cache
      await AppDatabase.instance.cardDao.clearCache();
    } catch (e) {
      _logger.severe('Failed to clear data locally: $e');
      rethrow;
    }
  }

  // Native widget IDs are now dynamically loaded from nativeWidgets definition

  Future<Result<List<KnowledgeInsightCard>>> fetchKnowledgeInsights() async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info('LocalMode: fetchKnowledgeInsights called');

      final userId = await UserStorage.getUserId();
      if (userId == null) return [];

      final cardsData =
          await fileSystemService.listKnowledgeInsightCards(userId);
      final insights = <KnowledgeInsightCard>[];

      for (final card in cardsData) {
        final id = card['id'] as String? ?? 'unknown';
        final templateId = card['template_id'] as String? ?? '';
        final isNative = nativeWidgets.any((w) => w.id == templateId);

        final title = card['title'] as String?;

        int createdAt = DateTime.now().millisecondsSinceEpoch;
        if (card.containsKey('updated_at')) {
          createdAt = DateTime.parse(card['updated_at']).millisecondsSinceEpoch;
        }

        String? chartHtml;
        if (!isNative) {
          chartHtml = await _renderInsightCardHtml(userId, card);
        }

        Map<String, dynamic>? widgetData;
        if (isNative) {
          widgetData = Map<String, dynamic>.from(card);
          if (card['data'] is Map) {
            widgetData.addAll((card['data'] as Map).cast<String, dynamic>());
          }
          widgetData.remove('data');
          widgetData = await replaceFsInData(widgetData, userId);
        }

        insights.add(KnowledgeInsightCard(
          id: id,
          title: title,
          html: chartHtml ?? '',
          createdAt: createdAt,
          isPinned: card['pinned'] == true,
          sortOrder: (card['sort_order'] as num? ?? 0).toInt(),
          tags: (card['tags'] as List?)?.cast<String>() ?? const [],
          widgetType: isNative ? 'native' : 'html',
          widgetTemplate: isNative ? templateId : null,
          widgetData: widgetData,
        ));
      }

      insights.sort((a, b) {
        final sortCompare = a.sortOrder.compareTo(b.sortOrder);
        if (sortCompare != 0) return sortCompare;
        return b.createdAt.compareTo(a.createdAt);
      });

      return insights;
    });
  }

  Future<String> _renderInsightCardHtml(
      String userId, Map<String, dynamic> card) async {
    final templateId = card['template_id'] as String? ?? '';
    final title = card['title'] as String? ?? '';
    final insight = card['insight'] as String? ?? '';
    final data = card['data'] as Map<String, dynamic>? ?? {};

    final htmlTemplate = await fileSystemService
        .readKnowledgeInsightCardTemplateHtml(userId, templateId);

    if (htmlTemplate != null && htmlTemplate.isNotEmpty) {
      try {
        final templateData = <String, dynamic>{
          'title': title,
          'insight': insight,
        };
        templateData.addAll(data);

        final renderedHtml =
            fileSystemService.renderHtmlTemplate(htmlTemplate, templateData);
        return await fileSystemService.replaceFsInHtml(renderedHtml, userId);
      } catch (e) {
        _logger
            .warning('Failed to render insight card template $templateId: $e');
      }
    }
    // Fallback? Currently returns empty if failed or no template
    return '';
  }

  Future<Result<bool>> unpinInsight(String id) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info('LocalMode: unpinInsight called: id=$id');
      return await unpinInsightEndpoint(id);
    });
  }

  Future<Result<bool>> pinInsight(String id) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info('LocalMode: pinInsight called: id=$id');
      return await pinInsightEndpoint(id);
    });
  }

  Future<Result<bool>> deleteKnowledgeInsight(String id) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info('LocalMode: deleteKnowledgeInsight called: id=$id');
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        _logger.warning('No user logged in, cannot delete insight');
        return false;
      }
      final cardFileName = '$id.yaml';
      final success = await fileSystemService.deleteKnowledgeInsightCard(
          userId, cardFileName);
      if (success) {
        try {
          final cardPath = 'KnowledgeInsights/Cards/$cardFileName';
          await fileSystemService.eventLogService.logEvent(
            userId: userId,
            eventType: 'user_action',
            description: 'User deleted knowledge insight card',
            filePath: cardPath,
            metadata: {'action': 'delete', 'card_id': id},
          );
        } catch (e) {
          _logger.warning('Failed to log delete insight event: $e');
        }
      }
      return success;
    });
  }

  Future<Result<bool>> updateInsightCardSortOrder(
      List<String> sortedIds) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
          'LocalMode: updateInsightCardSortOrder called with ${sortedIds.length} ids');
      final userId = await UserStorage.getUserId();
      if (userId == null) return false;
      for (int i = 0; i < sortedIds.length; i++) {
        final id = sortedIds[i];
        try {
          final cardData =
              await fileSystemService.readKnowledgeInsightCard(userId, id);
          if (cardData != null) {
            final currentSortOrder =
                (cardData['sort_order'] as num? ?? 0).toInt();
            if (currentSortOrder != i) {
              cardData['sort_order'] = i;
              await fileSystemService.writeKnowledgeInsightCard(
                  userId, id, cardData);
            }
          }
        } catch (e) {
          _logger.warning('Failed to update sort order for card $id: $e');
        }
      }
      return true;
    });
  }

  Future<List<String>> fetchInsightTags() async {
    await _ensureInitialized();
    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) return [];
      return await fileSystemService.readInsightTags(userId);
    } catch (e) {
      _logger.severe('Failed to fetch insight tags: $e');
      return [];
    }
  }

  Future<bool> deleteCard(String id) async {
    await _ensureInitialized();
    _logger.info('LocalMode: deleteCard called: id=$id');

    try {
      return await deleteCardEndpoint(id);
    } catch (e) {
      _logger.severe('Failed to delete card $id: $e');
      return false;
    }
  }

  Future<bool> updateCardUiConfig(
      String cardId, int configIndex, Map<String, dynamic> data) async {
    await _ensureInitialized();
    _logger.info(
        'LocalMode: updateCardUiConfig called: cardId=$cardId, index=$configIndex');

    try {
      return await update_config_endpoint.updateCardUiConfigEndpoint(
          cardId, configIndex, data);
    } catch (e) {
      _logger.severe('Failed to update card ui config for $cardId: $e');
      return false;
    }
  }

  Future<bool> updateCardTime(String cardId, int timestamp) async {
    await _ensureInitialized();
    _logger.info(
        'LocalMode: updateCardTime called: cardId=$cardId, timestamp=$timestamp');

    try {
      return await updateCardTimeEndpoint(cardId, timestamp);
    } catch (e) {
      _logger.severe('Failed to update card time for $cardId: $e');
      return false;
    }
  }

  Future<bool> updateCardLocation(
      String cardId, double lat, double lng, String name) async {
    await _ensureInitialized();
    _logger.info(
        'LocalMode: updateCardLocation called: cardId=$cardId, lat=$lat, lng=$lng, name=$name');

    try {
      return await updateCardLocationEndpoint(cardId, lat, lng, name);
    } catch (e) {
      _logger.severe('Failed to update card location for $cardId: $e');
      return false;
    }
  }

  Future<InsightDetailModel> fetchInsightDetail(String insightId) async {
    await _ensureInitialized();
    _logger.info('LocalMode: fetchInsightDetail called: insightId=$insightId');

    try {
      // Knowledge insight
      return await getKnowledgeInsightDetail(insightId);
    } catch (e) {
      _logger.severe('Failed to fetch insight detail $insightId: $e');
      rethrow;
    }
  }

  Future<Result<List<Map<String, dynamic>>>> fetchChatSessions({
    String? agentName,
    int? limit,
  }) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
          'LocalMode: fetchChatSessions called: agentName=$agentName, limit=$limit');
      return await chat_endpoint.fetchChatSessionsEndpoint(
        agentName: agentName,
        limit: limit,
      );
    });
  }

  Future<Map<String, dynamic>> fetchChatSessionDetail(String sessionId) async {
    await _ensureInitialized();
    _logger
        .info('LocalMode: fetchChatSessionDetail called: sessionId=$sessionId');

    try {
      return await chat_endpoint.fetchChatSessionDetailEndpoint(sessionId);
    } catch (e) {
      _logger.severe('Failed to fetch chat session detail: $e');
      rethrow;
    }
  }

  Future<bool> deleteChatSession(String sessionId) async {
    await _ensureInitialized();
    _logger.info('LocalMode: deleteChatSession called: sessionId=$sessionId');

    try {
      return await chat_endpoint.deleteChatSessionEndpoint(sessionId);
    } catch (e) {
      _logger.severe('Failed to delete chat session: $e');
      return false;
    }
  }

  Future<Result<List<CharacterModel>>> fetchCharacters() async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info('LocalMode: fetchCharacters called');
      return await getCharacters();
    });
  }

  Future<CharacterModel> fetchCharacter(String characterId) async {
    await _ensureInitialized();
    _logger.info('LocalMode: fetchCharacter called: characterId=$characterId');

    try {
      return await getCharacter(characterId);
    } catch (e) {
      _logger.severe('Failed to fetch character $characterId: $e');
      rethrow;
    }
  }

  Future<CharacterModel> createCharacter({
    required String name,
    required List<String> tags,
    required String persona,
  }) async {
    await _ensureInitialized();
    _logger.info('LocalMode: createCharacter called: name=$name');

    try {
      return await createCharacterEndpoint(
        name: name,
        tags: tags,
        persona: persona,
      );
    } catch (e) {
      _logger.severe('Failed to create character: $e');
      rethrow;
    }
  }

  Future<CharacterModel> updateCharacter({
    required String characterId,
    String? name,
    List<String>? tags,
    String? persona,
  }) async {
    await _ensureInitialized();
    _logger.info('LocalMode: updateCharacter called: characterId=$characterId');

    try {
      return await updateCharacterEndpoint(
        characterId: characterId,
        name: name,
        tags: tags,
        persona: persona,
      );
    } catch (e) {
      _logger.severe('Failed to update character $characterId: $e');
      rethrow;
    }
  }

  Future<bool> deleteCharacter(String characterId) async {
    await _ensureInitialized();
    _logger.info('LocalMode: deleteCharacter called: characterId=$characterId');

    try {
      return await deleteCharacterEndpoint(characterId);
    } catch (e) {
      _logger.severe('Failed to delete character $characterId: $e');
      rethrow;
    }
  }

  Future<Result<bool>> setCharacterEnabled(
      String characterId, bool enabled) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
          'LocalMode: setCharacterEnabled called: characterId=$characterId, enabled=$enabled');
      return await setCharacterEnabledEndpoint(characterId, enabled);
    });
  }

  Stream<ChatEvent> sendMessage(
    String message, {
    String? sessionId,
    String? agentName = 'memex_agent',
    String? scene = 'assistant',
    String? sceneId,
    List<Map<String, String>>? refs,
  }) {
    // Local implementation delegates to ChatService
    // ChatService uses imported ChatEvent which matches the interface
    // but ChatService.sendMessage returns Stream<ChatEvent> from package:memex/data/services/chat_service.dart
    // which exports package:memex/data/model/chat_events.dart
    // So types should be compatible.

    // Check if we need to initialize something?
    // ChatService handles its own initialization somewhat, but depends on global state.
    // _ensureInitialized might be needed if ChatService uses DB or FileSystem that we init.
    // However, ChatService.instance uses FileSystemService.instance which is static.
    // MemexRouter inits FileSystemService.

    // We can't await inside a sync generator or stream return easily without Stream.fromFuture or async*
    // ChatService.sendMessage is async*.

    return ChatService.instance.sendMessage(
      message,
      sessionId: sessionId,
      agentName: agentName,
      scene: scene,
      sceneId: sceneId,
      refs: refs,
    );
  }

  Future<bool> reportDailyHealthSummary(
      Map<String, Map<String, dynamic>> dailySummary) async {
    await _ensureInitialized();
    _logger.info(
        'LocalMode: reportDailyHealthSummary called: ${dailySummary.length} days');

    try {
      // We will create health_endpoint.dart to handle this
      return await health_endpoint
          .reportDailyHealthSummaryEndpoint(dailySummary);
    } catch (e) {
      _logger.severe('Failed to report daily health summary: $e');
      return false;
    }
  }

  Future<Result<Map<String, dynamic>>> getMemory() async {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final systemPath = fileSystemService.getSystemPath(userId);
      final memoryPath = path.join(systemPath, 'memory', 'memory.json');
      final file = File(memoryPath);

      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isEmpty) {
          return {
            'archived_memory': '',
            'recent_buffer': [],
          };
        }
        return jsonDecode(content) as Map<String, dynamic>;
      }
      return {
        'archived_memory': '',
        'recent_buffer': [],
      };
    });
  }

  Future<Result<List<Map<String, dynamic>>>> getRecentPkmFiles(
      {int limit = 10}) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info('LocalMode: getRecentPkmFiles called: limit=$limit');
      final userId = await UserStorage.getUserId();
      if (userId == null) return <Map<String, dynamic>>[];
      return await fileSystemService.getRecentPkmFiles(userId, limit: limit);
    });
  }

  Future<Result<Map<String, int>>> countPkmItems(List<String> paths) async {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) return <String, int>{};
      return await fileSystemService.countPkmItems(userId, paths);
    });
  }

  Future<Result<Map<String, dynamic>>> listPkmDirectory({String? path}) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info('LocalMode: listPkmDirectory called: path=$path');
      return await pkm_endpoint.listPkmDirectory(path: path);
    });
  }

  Future<Result<List<Map<String, dynamic>>>> searchPkmFiles(
      String query) async {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) return <Map<String, dynamic>>[];
      return await fileSystemService.searchPkmFiles(userId, query);
    });
  }

  Future<Map<String, dynamic>> readPkmFile(String filePath) async {
    await _ensureInitialized();
    _logger.info('LocalMode: readPkmFile called: path=$filePath');

    try {
      return await pkm_endpoint.readPkmFileEndpoint(filePath);
    } catch (e) {
      _logger.severe('Failed to read PKM file: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAggregatedStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? scene,
  }) async {
    await _ensureInitialized();
    _logger.info('LocalMode: getAggregatedStatistics called');

    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        _logger.warning(
            'getAggregatedStatistics called without logged in user, returning empty');
        return {};
      }

      return await LLMCallRecordService.instance.getAggregatedStatistics(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        scene: scene,
      );
    } catch (e) {
      _logger.severe('Failed to get aggregated statistics: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getAgentUsages({
    DateTime? startDate,
    DateTime? endDate,
    String? scene,
  }) async {
    await _ensureInitialized();
    _logger.info('LocalMode: getAgentUsages called');

    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        return [];
      }

      return await LLMCallRecordService.instance.getAllRecords(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        scene: scene,
      );
    } catch (e) {
      _logger.severe('Failed to get agent usages: $e');
      return [];
    }
  }

  Future<bool> uploadWorkspace(String targetUserId) async {
    await _ensureInitialized();
    _logger.info('LocalMode: uploadWorkspace not supported (client-only)');
    return false;
  }

  Future<List<Map<String, dynamic>>> listSharedWorkspaces() async {
    await _ensureInitialized();
    return [];
  }

  Future<bool> downloadWorkspace(String workspaceName,
      {void Function(int received, int total)? onReceiveProgress}) async {
    await _ensureInitialized();
    _logger.info('LocalMode: downloadWorkspace not supported (client-only)');
    return false;
  }

  Future<List<LLMConfig>> getLLMConfigs() => UserStorage.getLLMConfigs();

  Future<void> saveLLMConfigs(List<LLMConfig> configs) =>
      UserStorage.saveLLMConfigs(configs);

  Future<void> resetLLMConfigs() => UserStorage.resetLLMConfigs();

  Future<AgentConfig> getAgentConfig(String agentId) =>
      UserStorage.getAgentConfig(agentId);

  Future<void> saveAgentConfig(String agentId, AgentConfig config) =>
      UserStorage.saveAgentConfig(agentId, config);

  Future<void> saveOpenAiAuth(Map<String, dynamic> authData) async {
    // local_todo: to be implemented
    // Usually local mode doesn't need to sync to backend, but we can implement it as a no-op
    // or log it here.
    return;
  }

  Future<void> resetAllAgentConfigs() => UserStorage.resetAllAgentConfigs();

  Future<Result<void>> updateKnowledgeInsights() => runResultVoid(() async {
        await _ensureInitialized();
        final userId = await UserStorage.getUserId();
        if (userId == null) {
          throw Exception('User not logged in');
        }

        await GlobalEventBus.instance.publish(
          userId: userId,
          event: SystemEvent(
            type: SystemEventTypes.knowledgeInsightRefreshRequested,
            source: 'memex_router.updateKnowledgeInsights',
            payload: const {},
          ),
        );
      });

  Future<List<Task>> getTasks({int limit = 10, int offset = 0}) =>
      LocalTaskExecutor.instance.getTasks(limit: limit, offset: offset);
}
