import 'package:logging/logging.dart';
import 'package:memex/agent/card_agent/card_agent.dart';
import 'package:memex/agent/card_agent/rule_based_card_matcher.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/data/services/file_system_service.dart';

import 'package:memex/utils/logger.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/agent/agent_utils.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';

final Logger _logger = getLogger('CardAgentHandler');

/// Reusable function to process content with Card Agent.
///
/// This function constructs the prompt based on the provided inputs and
/// executes the CardAgent. It mimics the backend's `_process_with_card_agent`.
///
/// [dryRun] - If true, the agent will run but tools will skip side-effects.
Future<void> processWithCardAgent({
  required String userId,
  required String factId,
  required String contentText,
  List<Map<String, dynamic>>? assetAnalyses,
  DateTime? inputDateTime,
  bool dryRun = false,
}) async {
  try {
    _logger.info("processWithCardAgent for $factId (dryRun: $dryRun)");

    // Check if LLM is configured; fall back to rule-based matching if not.
    final llmConfig = await UserStorage.getAgentLLMConfig(
      AgentDefinitions.cardAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    if (!llmConfig.isValid) {
      _logger.info(
        'No LLM configured — using rule-based card matching for $factId',
      );
      await _applyRuleBasedCard(
        userId: userId,
        factId: factId,
        combinedText: contentText,
      );
      return;
    }

    // 1. Get LLM Config
    // 1. Get LLM Resources (Default to Responses for Cards)
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.cardAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    // getAgentLLMResources already checks if apiKey is empty and throws exception.

    // 2. Prepare Fact Content (merge assets info if needed)
    var enhancedFactContent = contentText;
    if (assetAnalyses != null && assetAnalyses.isNotEmpty) {
      enhancedFactContent += formatAssetAnalysis(
        assetAnalyses,
        includeExif: true,
      );
    }

    // 3. (Client initialized above)
    final client = resources.client;

    final publishTime = inputDateTime.toString().substring(0, 19);

    final userMessageContent =
        Prompts.cardAgentUserMessagePromptForPublishNewContent(
          publishTime,
          factId,
          enhancedFactContent,
        );

    // 4. Run Agent
    await CardAgent.runWithContent(
      client: client,
      modelConfig: resources.modelConfig,
      userId: userId,
      factId: factId,
      instruction: userMessageContent,
    );

    _logger.info('Card Agent task completed for $factId');
  } catch (e, stack) {
    _logger.severe('Error in processWithCardAgent', e, stack);
    rethrowIfNonRetryable(e);
  }
}

/// Applies rule-based template matching and writes the card file.
Future<void> _applyRuleBasedCard({
  required String userId,
  required String factId,
  required String combinedText,
}) async {
  final fs = FileSystemService.instance;

  // Extract image URLs and audio URL from combinedText markdown refs
  final imageUrls = RegExp(
    r'!\[.*?\]\((fs://[^\)]+)\)',
  ).allMatches(combinedText).map((m) => m.group(1)!).toList();
  final audioMatch = RegExp(
    r'\[audio\]\((fs://[^\)]+)\)',
  ).firstMatch(combinedText);
  final audioUrl = audioMatch?.group(1);

  final result = await fs.updateCardFile(userId, factId, (existing) {
    return applyRuleBasedTemplate(
      card: existing,
      combinedText: combinedText,
      imageUrls: imageUrls,
      audioUrl: audioUrl,
    );
  });

  if (result == null) {
    _logger.warning('Rule-based: card file not found for $factId, skipping');
    return;
  }
  _logger.info(
    'Rule-based card written for $factId: ${result.uiConfigs.first.templateId}',
  );
}

/// Task Handler implementation for `card_agent_task`.
Future<void> handleCardAgentImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext taskContext,
) async {
  _logger.info("Handling Card Agent task for user: $userId");

  try {
    // 1. Parse Payload
    final factId = payload['fact_id'] as String;
    final combinedText = payload['combined_text'] as String;
    final createdAtTs = (payload['created_at_ts'] as num?)?.toInt();

    final inputDateTime = createdAtTs != null
        ? DateTime.fromMillisecondsSinceEpoch(createdAtTs * 1000)
        : DateTime.now();

    // 2. Retrieve asset analyses (Stage 1 result)
    List<Map<String, dynamic>>? assetAnalyses;
    if (taskContext.bizId != null) {
      // Check if asset analysis failed and input is media-only
      await failIfAssetAnalysisFailed(
        bizId: taskContext.bizId,
        combinedText: combinedText,
      );
      try {
        final analysisResult = await LocalTaskExecutor.instance
            .getTaskResultByBizId(
              userId,
              'handle_analyze_assets',
              taskContext.bizId!,
            );

        if (analysisResult != null &&
            analysisResult.containsKey('asset_analyses')) {
          assetAnalyses = (analysisResult['asset_analyses'] as List)
              .cast<Map<String, dynamic>>();
        }
      } catch (e) {
        _logger.severe("Failed to retrieve asset analyses from DB: $e");
        throw Exception('Failed to retrieve asset analyses from DB: $e');
      }
    }

    // 3. Call re-usable process function
    await processWithCardAgent(
      userId: userId,
      factId: factId,
      contentText: combinedText,
      assetAnalyses: assetAnalyses,
      inputDateTime: inputDateTime,
      dryRun: false,
    );

    _logger.info("Card Agent task completed successfully for $factId");

    // 5. Render and Push Update
    await renderAndPushCardUpdate(userId, factId, combinedText);
  } catch (e, stack) {
    _logger.severe("Card Agent Handler failed: $e", e, stack);
    rethrow;
  }
}

Future<void> renderAndPushCardUpdate(
  String userId,
  String factId,
  String combinedText,
) async {
  final fs = FileSystemService.instance;
  CardData? cardData;
  try {
    cardData = await fs.readCardFile(userId, factId);
  } catch (e) {
    _logger.severe("Failed to read card file: $e");
    throw Exception('Failed to read card file: $e');
  }

  final tags = cardData?.tags ?? <String>[];
  final cardForRender =
      cardData ??
      CardData(
        factId: factId,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        status: 'processing',
        tags: const [],
        uiConfigs: const [],
      );

  final renderResult = await renderCard(
    userId: userId,
    cardData: cardForRender,
    factContent: combinedText,
  );

  final title = cardData?.title;

  // Extract assets and rawText from factContent
  final assetsAndText = await extractAssetsAndRawText(userId, combinedText);
  final assets = (assetsAndText['assets'] as List<AssetData>)
      .map((a) => a.toJson())
      .toList();
  final rawText = assetsAndText['rawText'] as String?;

  EventBusService.instance.emitEvent(
    CardUpdatedMessage(
      id: factId,
      html: renderResult.html ?? '',
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      tags: tags,
      status: renderResult.status,
      title: title,
      uiConfigs: renderResult.uiConfigs,
      assets: assets.isNotEmpty ? assets : null,
      rawText: rawText,
      address: cardData?.address,
    ),
  );
}

/// Failure handler for card agent task
/// Updates card status to 'failed' when all retries are exhausted
Future<void> handleCardAgentFailureImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
  Object error,
  StackTrace? stackTrace,
) async {
  _logger.severe(
    'Card Agent task failed permanently for user: $userId, error: $error, stackTrace: ${stackTrace?.toString()}',
  );

  try {
    final factId = payload['fact_id'] as String?;
    if (factId == null) {
      _logger.warning(
        'Cannot update card status: fact_id is missing in payload',
      );
      return;
    }

    // Classify error and generate friendly message
    final category = classifyError(error);
    final friendlyMessage = getLocalizedErrorMessage(category, error);

    final fs = FileSystemService.instance;

    // Update status to 'failed' using updateCardFile for concurrent safety
    final cardData = await fs.updateCardFile(userId, factId, (card) {
      // Handle uiConfigs: preserve existing or set classic_card fallback
      final uiConfigs = card.uiConfigs.isEmpty
          ? [const UiConfig(templateId: 'classic_card', data: {})]
          : card.uiConfigs;

      return card.copyWith(
        status: 'failed',
        failureReason: friendlyMessage,
        uiConfigs: uiConfigs,
      );
    });

    if (cardData == null) {
      _logger.warning(
        'Cannot update card status: card file not found for $factId',
      );
      return;
    }

    _logger.info('Updated card $factId status to failed');

    // Send EventBus update to notify frontend
    try {
      final combinedText = payload['combined_text'] as String? ?? '';
      final renderResult = await renderCard(
        userId: userId,
        cardData: cardData,
        factContent: combinedText,
      );

      final tags = cardData.tags;
      final title = cardData.title;

      // Extract assets and rawText from factContent
      final assetsAndText = await extractAssetsAndRawText(userId, combinedText);
      final assets = (assetsAndText['assets'] as List<AssetData>)
          .map((a) => a.toJson())
          .toList();
      final rawText = assetsAndText['rawText'] as String?;

      EventBusService.instance.emitEvent(
        CardUpdatedMessage(
          id: factId,
          html: renderResult.html ?? '',
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          tags: tags,
          status: 'failed',
          title: title,
          uiConfigs: renderResult.uiConfigs,
          assets: assets.isNotEmpty ? assets : null,
          rawText: rawText,
          address: cardData.address,
          failureReason: friendlyMessage,
        ),
      );

      // Emit error notification for UI dialog
      EventBusService.instance.emitEvent(
        ErrorNotificationMessage(
          errorCategory: category.name,
          errorMessage: friendlyMessage,
          cardId: factId,
        ),
      );
    } catch (e) {
      _logger.warning('Failed to send EventBus update for failed card: $e');
      // Don't throw - status update is more important
    }
  } catch (e, stack) {
    _logger.severe('Error in card agent failure handler for $userId', e, stack);
    // Don't rethrow - failure handler should not cause additional failures
  }
}
