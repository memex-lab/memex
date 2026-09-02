import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:memex/data/repositories/migrate_cards_fact_assets.dart';
import 'package:memex/data/repositories/update_card_ui_config.dart'
    as update_config_endpoint;
import 'package:memex/data/services/search_service.dart';
import 'package:memex/data/services/backup_service.dart';
import 'package:memex/data/services/file_import_service.dart';
import 'package:memex/domain/models/calendar_model.dart';
import 'package:memex/data/repositories/hydrate_card.dart';
import 'package:memex/data/services/table_change_notifier.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/data/services/card_detail_notifier.dart';
import 'package:memex/data/services/agent_background_coordinator.dart';
import 'package:memex/data/services/agent_background_task_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:memex/data/services/user_notification_service.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:memex/data/repositories/get_timeline_card.dart'; // Import for fetchTimelineCard
import 'package:logging/logging.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/domain/models/card_model.dart';
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
import 'package:memex/data/services/chat_session_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/task_handlers/fts_index_handler.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/data/services/task_handlers/comment_agent_handler.dart';
import 'package:memex/data/services/task_handlers/character_initiative_handler.dart';
import 'package:memex/data/services/task_handlers/character_history_acquaintance_handler.dart';
import 'package:memex/data/services/task_handlers/character_perception_handler.dart';
import 'package:memex/data/services/task_handlers/character_conversation_handler.dart';
import 'package:memex/data/services/character_conversation_service.dart';
import 'package:memex/data/services/character_initiative_service.dart';
import 'package:memex/data/services/character_history_acquaintance_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/repositories/persona_chat_repository.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/repositories/character_editor_repository.dart';
import 'package:memex/data/services/task_handlers/reprocess_comments_handler.dart';
import 'package:memex/data/services/task_handlers/custom_agent_task_handler.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/data/repositories/get_tags.dart';
import 'package:memex/data/repositories/get_timeline_cards.dart';
import 'package:memex/data/repositories/get_aggregated_timeline.dart';
import 'package:memex/data/repositories/get_cards_by_ids.dart';
import 'package:memex/data/repositories/get_calendar_data.dart';
import 'package:memex/data/repositories/card.dart';
import 'package:memex/data/repositories/post_comment.dart';
import 'package:memex/data/services/comment_settings_service.dart';
import 'package:memex/data/repositories/pin_insight.dart';
import 'package:memex/data/repositories/character.dart';
import 'package:memex/data/repositories/health.dart' as health_endpoint;
import 'package:memex/data/repositories/pkm.dart' as pkm_endpoint;
import 'package:memex/domain/models/knowledge_insight_card.dart';
import 'package:memex/data/repositories/get_knowledge_insight_detail.dart';
import 'package:memex/data/repositories/chat.dart' as chat_endpoint;
import 'package:memex/data/services/llm_call_record_service.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/avatar_media_service.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/agent/skills/knowledge_insight/native_widgets.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/domain/models/persona_chat.dart';
import 'package:memex/domain/models/character_editor.dart';

/// Local data service for Memex. Handles all data operations via local storage (FileSystemService, DB).
class MemexRouter {
  static final MemexRouter _instance = MemexRouter._();
  factory MemexRouter() => _instance;

  final Logger _logger = getLogger('MemexRouter');
  final PersonaChatRepository _personaChatRepository = PersonaChatRepository();
  final CharacterEditorRepository _characterEditorRepository =
      CharacterEditorRepository();

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
      await FileSystemService.init(dataRoot);

      if (userId == null) {
        _logger.warning(
          'No user ID found during initialization. Local DB will NOT be initialized until login.',
        );
        return; // Do not initialize DB yet.
      }

      // Use userId to init DB (drift_flutter handles path isolation via name)
      _logger.info('Initializing Local DB for user: $userId');
      await ChatSessionStorage.instance.ensureMigrated(userId);
      await AppDatabase.init(userId);
      await PersonaChatService.instance
          .initialize(userId, AppDatabase.instance);

      _registerTaskHandlers(LocalTaskExecutor.instance);
      await LocalTaskExecutor.instance.start(userId: userId);
      await CharacterConversationService.instance.reconcilePendingReplies(
        userId: userId,
      );

      // Start table change notifier (binlog-style listener for Drift tables)
      TableChangeNotifier.instance.init();
      // Register attachment table watchers
      CardAttachmentService.instance.init();
      // Register user notification table watch (must precede CardDetailNotifier)
      UserNotificationService.instance.init();
      // Register card-detail change notifier (subscribes to GlobalEventBus)
      CardDetailNotifier.instance.init();

      // Register event subscriptions after task handlers are ready.
      _registerEventSubscriptions();

      // Initialize custom agent handler and register user-defined agents.
      initCustomAgentHandler();
      registerBuiltInEventSerializers();
      await CustomAgentConfigService.instance.registerAll(userId);
      await AgentBackgroundTaskService.instance.startMonitoring();
      AgentBackgroundCoordinator.instance.start(
        executor: LocalTaskExecutor.instance,
        activityService: LocalAgentActivityService.instance,
      );

      // Register file change callback and FTS event subscriptions.
      // Also triggers a one-time full rebuild when FTS tables were just created
      // via migration (existing users upgrading to schema v10).
      SearchService.instance.init(userId);

      // One-time migration: backfill legacy cards' fact/assets/created_at
      // fields from their Facts files. Runs after SearchService subscribes so
      // migrated card facts are incrementally reflected in FTS.
      await migrateCardsToFactAssets(userId);

      // Existing records must be fully readable before a companion privately
      // explores them for the first time.
      final primaryCompanion =
          await CharacterService.instance.getPrimaryCompanion(userId);
      if (primaryCompanion?.enabled == true) {
        await CharacterHistoryAcquaintanceService.instance.ensureScheduled(
          userId: userId,
          character: primaryCompanion!,
        );
        await CharacterInitiativeService.instance.ensureScheduled(
          userId: userId,
        );
      }

      scheduleAutoBackupCheck(trigger: 'app_start');
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

    // Capture happens inside SuperAgent. After a new card is saved,
    // SuperAgent re-publishes this event so independent consumers such as
    // comment_agent can react through the persistent task queue.
    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'comment_agent',
        taskType: 'comment_agent_task',
        requiresSuccessOf: const ['character_perception'],
        payloadBuilder: (_, event) {
          final p = event.payload as UserInputSubmittedPayload;
          return Future.value({
            'fact_id': p.factId,
            'combined_text': p.combinedText,
            'created_at_ts': p.createdAtTs,
            'location_context_reminder': p.locationContextReminder,
          });
        },
      ),
    );

    // The primary companion privately transforms each new record into its own
    // workspace before deciding whether the moment warrants contact.
    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'character_perception',
        taskType: 'character_perception_task',
        maxRetries: 3,
        payloadBuilder: (_, event) {
          final p = event.payload as UserInputSubmittedPayload;
          return Future.value({
            'source_event_id': event.eventId,
            'fact_id': p.factId,
            'combined_text': p.combinedText,
            'created_at_ts': p.createdAtTs,
          });
        },
      ),
    );

    eventBus.subscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventTaskSubscription(
        subscriptionId: 'character_initiative',
        taskType: CharacterInitiativeService.taskType,
        requiresSuccessOf: const ['comment_agent', 'character_perception'],
        maxRetries: 3,
        payloadBuilder: (_, event) {
          final p = event.payload as UserInputSubmittedPayload;
          return Future.value({
            'source_event_id': event.eventId,
            'fact_id': p.factId,
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
          final p = event.payload as CardCommentPostedPayload;
          return Future.value({
            'card_id': p.cardId,
            'content': p.content,
            'comment_id': p.commentId,
            if (p.createdAtTs != null) 'created_at_ts': p.createdAtTs,
            if (p.replyToId != null) 'reply_to_id': p.replyToId,
            'location_context_reminder': p.locationContextReminder,
          });
        },
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
      'Re-initializing MemexRouter. Previous Target: $_targetUserIdForInit, New Target: $currentUser',
    );

    _targetUserIdForInit = currentUser;
    _initFuture = _init();
    return _initFuture!;
  }

  Future<void> ensureInitialized() => _ensureInitialized();

  /// Initializes only the task queue pieces needed from a WorkManager callback
  /// isolate.
  ///
  /// Keep this as a background-only entry point. It deliberately avoids
  /// front-end observers, UI notifiers, event subscriptions, search startup, and
  /// platform background surfaces that are already owned by the foreground
  /// isolate.
  static Future<void> ensureTaskQueueInitializedForBackgroundTask(
    String userId, {
    LocalTaskExecutor? executor,
  }) async {
    final dataRoot = await UserStorage.resolveDataRoot(userId);
    await FileSystemService.init(dataRoot);
    await ChatSessionStorage.instance.ensureMigrated(userId);
    await AppDatabase.init(userId);
    await PersonaChatService.instance.initialize(userId, AppDatabase.instance);

    final taskExecutor = executor ?? LocalTaskExecutor.instance;
    AgentActivityService.setInstance(LocalAgentActivityService.instance);
    _registerTaskHandlers(taskExecutor);
    initCustomAgentHandler();
    registerBuiltInEventSerializers();
    await CustomAgentConfigService.instance.registerAll(userId);
  }

  static void _registerTaskHandlers(LocalTaskExecutor executor) {
    // LocalTaskExecutor handles this map; re-registering overwrites which is fine.
    executor.registerHandler(
      'super_agent_chat_turn_task',
      ChatService.instance.handleSuperAgentChatTurnTask,
      concurrencyPolicy: TaskConcurrencyPolicy.byUser(),
    );
    executor.registerHandler(
      'fts_index_update',
      handleFtsIndexUpdateImpl,
    );
    executor.registerHandler(
      'comment_agent_task',
      handleCommentAgentImpl,
      legacyDependenciesRequireSuccess: true,
    );
    executor.registerHandler(
      'character_perception_task',
      handleCharacterPerceptionImpl,
      concurrencyPolicy: TaskConcurrencyPolicy.byUser(),
    );
    executor.registerHandler(
      CharacterHistoryAcquaintanceService.taskType,
      handleCharacterHistoryAcquaintanceImpl,
      concurrencyPolicy: TaskConcurrencyPolicy.byUser(),
    );
    executor.registerHandler(
      CharacterInitiativeService.taskType,
      handleCharacterInitiativeImpl,
      concurrencyPolicy: TaskConcurrencyPolicy.byUser(),
      legacyDependenciesRequireSuccess: true,
    );
    executor.registerHandler(
      CharacterConversationService.taskType,
      handleCharacterConversationImpl,
      concurrencyPolicy: TaskConcurrencyPolicy.byUser(),
    );
    executor.registerHandler(
      'reprocess_comments_task',
      handleReprocessCommentsImpl,
      concurrencyPolicy: TaskConcurrencyPolicy.byUser(),
    );
    executor.registerHandler(
      'process_ai_reply',
      handleProcessAiReplyImpl,
    );
    for (final taskType in [
      'comment_agent_task',
      'reprocess_comments_task',
      'process_ai_reply',
    ]) {
      executor.registerFailureHandler(
        taskType,
        handleGenericAgentFailure,
      );
    }
    executor.registerFailureHandler(
      'character_perception_task',
      handleCharacterPerceptionFailure,
    );
    executor.registerFailureHandler(
      CharacterHistoryAcquaintanceService.taskType,
      handleCharacterHistoryAcquaintanceFailure,
    );
    executor.registerFailureHandler(
      CharacterInitiativeService.taskType,
      handleCharacterInitiativeFailure,
    );
    executor.registerFailureHandler(
      CharacterConversationService.taskType,
      handleCharacterConversationFailure,
    );
  }

  /// External hook to force switch user (e.g. on login)
  Future<void> switchUser(String userId) async {
    _logger.info('Switching user to $userId');
    _targetUserIdForInit = null;
    _initFuture = null;
    await _ensureInitialized();
  }

  /// Apply latest per-user workspace storage configuration immediately.
  /// Rebuilds card cache for current user so reads reflect new workspace root.
  Future<void> applyWorkspaceStorageChange() async {
    final userId = await UserStorage.getUserId();
    final dataRoot = await UserStorage.resolveDataRoot(userId);
    await FileSystemService.init(dataRoot);
    if (userId != null && userId.isNotEmpty) {
      await ChatSessionStorage.instance.ensureMigrated(userId);
      try {
        await FileSystemService.instance.rebuildCardCache(userId);
      } catch (e) {
        _logger.warning('Failed to rebuild cache after storage switch: $e');
      }
    }
  }

  Future<BackupSnapshot?> maybeRunAutoBackup({
    required String trigger,
    bool force = false,
  }) async {
    await _ensureInitialized();
    return BackupService.maybeCreateAutoBackup(trigger: trigger, force: force);
  }

  void scheduleAutoBackupCheck({required String trigger}) {
    unawaited(
      maybeRunAutoBackup(trigger: trigger).catchError((
        Object e,
        StackTrace st,
      ) {
        _logger.warning('Automatic backup check failed: $e', e, st);
        return null;
      }),
    );
  }

  /// Clear init state and stop executor on logout so next login re-inits for new user.
  void resetForLogout() {
    _logger.info('Resetting MemexRouter for logout');
    _targetUserIdForInit = null;
    _initFuture = null;
    unawaited(AgentBackgroundCoordinator.instance.stop());
    unawaited(AgentBackgroundTaskService.instance.stopMonitoring(
      reason: 'logout',
    ));
    LocalTaskExecutor.instance.stop();
    SearchService.instance.reset();
  }

  void dispose() {
    unawaited(AgentBackgroundCoordinator.instance.stop());
    unawaited(AgentBackgroundTaskService.instance.stopMonitoring(
      reason: 'router_dispose',
    ));
    LocalTaskExecutor.instance.stop();
  }

  AgentActivityService get agentActivityService =>
      LocalAgentActivityService.instance;

  Future<String?> getToken() async {
    return null;
  }

  Future<List<String>> checkProcessedHashes(List<String> hashes) async {
    await _ensureInitialized();
    if (hashes.isEmpty) return [];

    final userId = await UserStorage.getUserId();
    if (userId == null) return hashes;

    return fileSystemService.checkUnprocessedHashes(userId, hashes);
  }

  Future<void> recordProcessedHashes(List<String> hashes) async {
    await _ensureInitialized();
    if (hashes.isEmpty) return;

    final userId = await UserStorage.getUserId();
    if (userId == null) return;

    await fileSystemService.recordProcessedHashes(userId, hashes);
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
      'LocalMode: fetchTagsByPeriod called: dateFrom=$dateFrom, dateTo=$dateTo',
    );

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
        'LocalMode: fetchTimelineCards called: page=$page, limit=$limit, tags=$tags, dateFrom=$dateFrom, dateTo=$dateTo',
      );
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
        'LocalMode: fetchAggregatedTimeline called: groupBy=$groupBy, page=$page, limit=$limit, tags=$tags',
      );
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
    int fromTimestamp,
    int toTimestamp,
  ) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
        'LocalMode: fetchCalendarData called: fromTimestamp=$fromTimestamp, toTimestamp=$toTimestamp',
      );
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
    String cardId,
    String content, {
    String? replyToId,
  }) async {
    await _ensureInitialized();
    _logger.info('LocalMode: postComment called: cardId=$cardId');

    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in, cannot submit comment');
      }

      return await postCommentEndpoint(
        cardId,
        userId,
        content,
        replyToId: replyToId,
      );
    } catch (e) {
      _logger.severe('Failed to post comment for card $cardId: $e');
      rethrow;
    }
  }

  /// Load per-user comment settings.
  Future<CommentSettings> getCommentSettings() async {
    await _ensureInitialized();
    final userId = await UserStorage.getUserId();
    if (userId == null) return const CommentSettings();
    return CommentSettingsService.load(userId);
  }

  /// Save per-user comment settings.
  Future<void> saveCommentSettings(CommentSettings settings) async {
    await _ensureInitialized();
    final userId = await UserStorage.getUserId();
    if (userId == null) return;
    await CommentSettingsService.save(userId, settings);
  }

  Future<AppUpdateSettings> getAppUpdateSettings() {
    return AppUpdateService.instance.loadSettings();
  }

  Future<void> saveAppUpdateSettings(AppUpdateSettings settings) {
    return AppUpdateService.instance.saveSettings(settings);
  }

  Future<Result<AppUpdateCheckResult>> checkEarlyUpdate({
    bool manual = false,
    bool respectWifi = false,
  }) {
    return runResult(() {
      return AppUpdateService.instance.checkForUpdate(
        manual: manual,
        respectWifi: respectWifi,
      );
    });
  }

  Future<Result<AppUpdateDownloadResult>> downloadEarlyUpdate(
    AppUpdateInfo update, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) {
    return runResult(() {
      return AppUpdateService.instance.downloadUpdate(
        update,
        onProgress: onProgress,
      );
    });
  }

  Future<Result<AppUpdateInstallResult>> installEarlyUpdate(String apkPath) {
    return runResult(() => AppUpdateService.instance.installUpdate(apkPath));
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

  /// Clears all workspace data for the current user.
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

  Future<int> clearFailedAgentConversationContexts() async {
    await _ensureInitialized();
    final userId = await UserStorage.getUserId();
    if (userId == null) throw Exception('User not logged in');

    final deleted = await deleteAgentStatesWhere(userId, (sessionId, metadata) {
      final scene = metadata['scene']?.toString();
      return scene == 'insight' || scene == 'schedule_aggregation';
    });
    _logger.info(
      'Cleared ${deleted.length} failed agent conversation context(s): $deleted',
    );
    return deleted.length;
  }

  // Native widget IDs are now dynamically loaded from nativeWidgets definition

  Future<Result<List<KnowledgeInsightCard>>> fetchKnowledgeInsights() async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info('LocalMode: fetchKnowledgeInsights called');

      final userId = await UserStorage.getUserId();
      if (userId == null) return [];

      final cardsData = await fileSystemService.listKnowledgeInsightCards(
        userId,
      );
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

        insights.add(
          KnowledgeInsightCard(
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
          ),
        );
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
    String userId,
    Map<String, dynamic> card,
  ) async {
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

        final renderedHtml = fileSystemService.renderHtmlTemplate(
          htmlTemplate,
          templateData,
        );
        return await fileSystemService.replaceFsInHtml(renderedHtml, userId);
      } catch (e) {
        _logger.warning(
          'Failed to render insight card template $templateId: $e',
        );
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
        userId,
        cardFileName,
      );
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
    List<String> sortedIds,
  ) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
        'LocalMode: updateInsightCardSortOrder called with ${sortedIds.length} ids',
      );
      final userId = await UserStorage.getUserId();
      if (userId == null) return false;
      for (int i = 0; i < sortedIds.length; i++) {
        final id = sortedIds[i];
        try {
          final cardData = await fileSystemService.readKnowledgeInsightCard(
            userId,
            id,
          );
          if (cardData != null) {
            final currentSortOrder =
                (cardData['sort_order'] as num? ?? 0).toInt();
            if (currentSortOrder != i) {
              cardData['sort_order'] = i;
              await fileSystemService.writeKnowledgeInsightCard(
                userId,
                id,
                cardData,
              );
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
    String cardId,
    int configIndex,
    Map<String, dynamic> data,
  ) async {
    await _ensureInitialized();
    _logger.info(
      'LocalMode: updateCardUiConfig called: cardId=$cardId, index=$configIndex',
    );

    try {
      return await update_config_endpoint.updateCardUiConfigEndpoint(
        cardId,
        configIndex,
        data,
      );
    } catch (e) {
      _logger.severe('Failed to update card ui config for $cardId: $e');
      return false;
    }
  }

  Future<bool> updateCardTime(String cardId, int timestamp) async {
    await _ensureInitialized();
    _logger.info(
      'LocalMode: updateCardTime called: cardId=$cardId, timestamp=$timestamp',
    );

    try {
      return await updateCardTimeEndpoint(cardId, timestamp);
    } catch (e) {
      _logger.severe('Failed to update card time for $cardId: $e');
      return false;
    }
  }

  Future<bool> updateCardLocation(
    String cardId,
    double lat,
    double lng,
    String name,
  ) async {
    await _ensureInitialized();
    _logger.info(
      'LocalMode: updateCardLocation called: cardId=$cardId, lat=$lat, lng=$lng, name=$name',
    );

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
        'LocalMode: fetchChatSessions called: agentName=$agentName, limit=$limit',
      );
      return await chat_endpoint.fetchChatSessionsEndpoint(
        agentName: agentName,
        limit: limit,
      );
    });
  }

  Future<Result<bool>> chatSessionExists(String sessionId) {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
        'LocalMode: chatSessionExists called: sessionId=$sessionId',
      );
      return chat_endpoint.chatSessionExistsEndpoint(sessionId);
    });
  }

  Future<Map<String, dynamic>> fetchChatSessionDetail(
    String sessionId, {
    int? messageLimit,
    String? messageBeforeCursor,
  }) async {
    await _ensureInitialized();
    _logger.info(
      'LocalMode: fetchChatSessionDetail called: sessionId=$sessionId',
    );

    try {
      return await chat_endpoint.fetchChatSessionDetailEndpoint(
        sessionId,
        messageLimit: messageLimit,
        messageBeforeCursor: messageBeforeCursor,
      );
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

  Future<Result<CharacterEditorData>> loadCharacterEditor(
    CharacterModel character,
  ) {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      return _characterEditorRepository.load(
        userId: userId,
        character: character,
      );
    });
  }

  Future<Result<CharacterModel>> saveCharacterDraft(
    CharacterDraft draft,
  ) {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      return _characterEditorRepository.save(userId: userId, draft: draft);
    });
  }

  Future<Result<CharacterEditorMedia>> importCharacterEditorImage(
    String sourcePath,
  ) {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      return _characterEditorRepository.importImage(
        userId: userId,
        sourcePath: sourcePath,
      );
    });
  }

  Future<Result<PersonaChatThreadModel>> loadPersonaChatThread(
    String characterId, {
    int limit = 30,
  }) {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      return _personaChatRepository.loadThread(
        userId: userId,
        characterId: characterId,
        limit: limit,
        userAvatar: await getUserAvatar(),
      );
    });
  }

  Future<Result<PersonaAvatarSummary>> loadPersonaAvatarSummary() {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      return _personaChatRepository.loadAvatarSummary(userId);
    });
  }

  Future<Result<PersonaChatMessagePageModel>> fetchPersonaChatMessagePage(
    String characterId, {
    required int limit,
    int? beforeCursor,
  }) {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      return _personaChatRepository.getMessagePage(
        characterId,
        userId: userId,
        limit: limit,
        beforeCursor: beforeCursor,
      );
    });
  }

  Future<Result<PersonaChatMessagePageModel>> fetchNewPersonaChatMessages(
    String characterId, {
    required int afterCursor,
  }) {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      return _personaChatRepository.getMessagesAfter(
        characterId,
        userId: userId,
        afterCursor: afterCursor,
      );
    });
  }

  Future<Result<int>> sendPersonaChatMessage(
    String characterId,
    String content,
  ) {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      return _personaChatRepository.sendMessage(
        userId: userId,
        characterId: characterId,
        content: content,
      );
    });
  }

  Future<Result<int>> markPersonaChatRead(String characterId) {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      final count = await _personaChatRepository.markAllRead(
        characterId,
        userId: userId,
      );
      EventBusService.instance.emitEvent(
        PersonaChatUnreadChangedMessage(characterId: characterId),
      );
      return count;
    });
  }

  Future<Result<List<CharacterModel>>> fetchEnabledPersonaCharacters() {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      return _personaChatRepository.getEnabledCharacters(userId);
    });
  }

  Future<Result<PersonaChatThreadModel>> switchPersonaChatCharacter(
    String characterId, {
    int limit = 30,
  }) {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) throw StateError('No active user.');
      await _personaChatRepository.setPrimaryCharacter(userId, characterId);
      return _personaChatRepository.loadThread(
        userId: userId,
        characterId: characterId,
        limit: limit,
        userAvatar: await getUserAvatar(),
      );
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

  Future<Result<bool>> deleteCharacter(String characterId) {
    return runResult(() async {
      await _ensureInitialized();
      _logger
          .info('LocalMode: deleteCharacter called: characterId=$characterId');
      return await deleteCharacterEndpoint(characterId);
    });
  }

  Future<Result<bool>> setCharacterEnabled(
    String characterId,
    bool enabled,
  ) async {
    return runResult(() async {
      await _ensureInitialized();
      _logger.info(
        'LocalMode: setCharacterEnabled called: characterId=$characterId, enabled=$enabled',
      );
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
    List<XFile> images = const [],
    Map<String, String>? imageOriginalFilenames,
    bool isQuickQuery = false,
    String runMode = 'auto',
  }) async* {
    await _ensureInitialized();
    yield* ChatService.instance.sendMessage(
      message,
      sessionId: sessionId,
      agentName: agentName,
      scene: scene,
      sceneId: sceneId,
      refs: refs,
      images: images,
      imageOriginalFilenames: imageOriginalFilenames,
      isQuickQuery: isQuickQuery,
      runMode: runMode,
    );
  }

  /// Whether the session has an in-memory run or a persisted chat turn waiting
  /// to resume after app restart.
  Future<bool> hasActiveChatRun(String? sessionId) =>
      ChatService.instance.hasActiveRun(sessionId);

  /// Re-attaches to an in-flight chat run: replays missed events, then
  /// continues live.
  Stream<ChatEvent> attachToChatRun(String sessionId) =>
      ChatService.instance.attachToActiveRun(sessionId);

  Future<Result<String>> refreshSuperAgentChatState(String sessionId) {
    return runResult(() async {
      await _ensureInitialized();
      return ChatService.instance.refreshAgentStateForSession(sessionId);
    });
  }

  Future<bool> reportDailyHealthSummary(
    Map<String, Map<String, dynamic>> dailySummary,
  ) async {
    await _ensureInitialized();
    _logger.info(
      'LocalMode: reportDailyHealthSummary called: ${dailySummary.length} days',
    );

    try {
      // We will create health_endpoint.dart to handle this
      return await health_endpoint.reportDailyHealthSummaryEndpoint(
        dailySummary,
      );
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
          return {'archived_memory': '', 'recent_buffer': []};
        }
        return jsonDecode(content) as Map<String, dynamic>;
      }
      return {'archived_memory': '', 'recent_buffer': []};
    });
  }

  Future<Result<List<Map<String, dynamic>>>> getRecentPkmFiles({
    int limit = 10,
  }) async {
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
    String query,
  ) async {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) return <Map<String, dynamic>>[];
      return await SearchService.instance.searchPkmFiles(userId, query);
    });
  }

  /// Search timeline cards using FTS5 full-text search.
  ///
  /// Returns hydrated [TimelineCardModel] list, same format as [fetchTimelineCards].
  Future<Result<List<TimelineCardModel>>> searchCards(
    String query, {
    int limit = 50,
  }) async {
    return runResult(() async {
      await _ensureInitialized();
      final userId = await UserStorage.getUserId();
      if (userId == null) return <TimelineCardModel>[];

      final ftsResults = await SearchService.instance.searchCards(
        query,
        limit: limit,
      );

      return await hydrateCards(
        userId,
        ftsResults.map((r) => r['fact_id'] as String),
        onError: (factId, error) {
          _logger.warning('Failed to hydrate search result $factId: $error');
        },
      );
    });
  }

  /// Rebuild the PKM FTS index (e.g. after import or manual trigger).
  Future<void> rebuildPkmFtsIndex() async {
    await _ensureInitialized();
    final userId = await UserStorage.getUserId();
    if (userId == null) return;
    await SearchService.instance.rebuildPkmFtsIndex(userId);
  }

  Future<Result<FileImportResult>> importFilesToUserSettingsImported(
    List<String> sourcePaths, {
    void Function(String status)? onProgress,
  }) {
    return runResult(() async {
      await _ensureInitialized();
      return FileImportService.instance.importToUserSettingsImported(
        sourcePaths,
        onProgress: onProgress,
      );
    });
  }

  /// Rebuild all FTS indexes (card + PKM). Intended for debugging / manual trigger.
  Future<void> rebuildAllFtsIndexes() async {
    await _ensureInitialized();
    final userId = await UserStorage.getUserId();
    if (userId == null) return;
    await SearchService.instance.rebuildAll(userId);
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
          'getAggregatedStatistics called without logged in user, returning empty',
        );
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

  Future<bool> downloadWorkspace(
    String workspaceName, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    await _ensureInitialized();
    _logger.info('LocalMode: downloadWorkspace not supported (client-only)');
    return false;
  }

  Future<List<LLMConfig>> getLLMConfigs() => UserStorage.getLLMConfigs();

  Future<String?> getUserAvatar() async {
    await _ensureInitialized();
    final userId = await UserStorage.getUserId();
    if (userId == null || userId.isEmpty) return null;

    final meta = await fileSystemService.readProfileMeta(userId);
    var avatar = meta['avatar'] as String?;
    if (avatar == null || avatar.isEmpty) {
      final legacyAvatar = await UserStorage.getUserAvatar();
      if (legacyAvatar != null && legacyAvatar.isNotEmpty) {
        meta['avatar'] = legacyAvatar;
        await fileSystemService.writeProfileMeta(userId, meta);
        avatar = legacyAvatar;
      }
    }
    if (avatar == null || avatar.isEmpty) {
      return null;
    }

    return AvatarMediaService.resolveAvatarPath(
      avatar,
      fileSystemService: fileSystemService,
    );
  }

  Future<void> updateUserAvatar(String avatar) async {
    await _ensureInitialized();
    final userId = await UserStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('User not logged in');
    }

    final meta = await fileSystemService.readProfileMeta(userId);
    meta['avatar'] = avatar;
    await fileSystemService.writeProfileMeta(userId, meta);
    AvatarMediaService.precacheDiceBearAvatar(avatar);
    EventBusService.instance.emitEvent(
      ProfileUpdatedMessage(userId: userId, avatar: avatar),
    );
  }

  Future<void> saveLLMConfigs(List<LLMConfig> configs) async {
    await UserStorage.saveLLMConfigs(configs);
    _emitLLMConfigChanged(configs, reason: 'saved');
  }

  Future<void> resetLLMConfigs() async {
    await UserStorage.resetLLMConfigs();
    final configs = await UserStorage.getLLMConfigs();
    _emitLLMConfigChanged(configs, reason: 'reset');
  }

  Future<String> getDefaultLLMConfigKey() =>
      UserStorage.getDefaultLLMConfigKey();

  Future<void> setDefaultLLMConfigKey(String configKey) async {
    await UserStorage.setDefaultLLMConfigKey(configKey);
    final configs = await UserStorage.getLLMConfigs();
    _emitLLMConfigChanged(configs, reason: 'default_changed');
  }

  void _emitLLMConfigChanged(
    List<LLMConfig> configs, {
    required String reason,
  }) {
    EventBusService.instance.emitEvent(
      LLMConfigChangedMessage(
        hasValidConfig: configs.any((c) => c.isValid),
        reason: reason,
      ),
    );
  }

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

  Future<List<Task>> getTasks({int limit = 10, int offset = 0}) =>
      LocalTaskExecutor.instance.getTasks(limit: limit, offset: offset);

  Future<TaskActivitySnapshot> getTaskActivitySnapshot() async {
    await _ensureInitialized();
    return LocalTaskExecutor.instance.getTaskActivitySnapshot();
  }

  // ---------------------------------------------------------------------------
  // Card-detail notification helpers
  // ---------------------------------------------------------------------------

  /// Resolve the [CardData] for a notification's subject card.
  /// Returns `null` if the card no longer exists or the user is not logged in.
  Future<CardData?> resolveCardForNotification(String factId) async {
    await _ensureInitialized();
    final userId = await UserStorage.getUserId();
    if (userId == null) return null;
    return FileSystemService.instance.readCardFile(userId, factId);
  }

  /// Dismiss a user notification by its primary key.
  Future<void> dismissNotification(String id) async {
    await _ensureInitialized();
    await UserNotificationService.instance.dismiss(id);
  }

  /// Register a card detail page as viewing [factId] (foreground suppression).
  void registerCardDetailForeground(String factId) {
    CardDetailNotifier.instance.registerForeground(factId);
  }

  /// Unregister a card detail page for [factId].
  void unregisterCardDetailForeground(String factId) {
    CardDetailNotifier.instance.unregisterForeground(factId);
  }

  /// Dismiss any pending card-detail notification after the user has viewed
  /// the card's latest content.
  Future<void> dismissCardDetailOnViewed(String factId) async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return;
    await CardDetailNotifier.instance.dismissOnViewed(userId, factId);
  }
}
