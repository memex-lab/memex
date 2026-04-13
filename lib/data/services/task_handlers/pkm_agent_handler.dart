import 'package:logging/logging.dart';
import 'package:memex/agent/pkm_agent/pkm_agent.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/agent/agent_utils.dart';
import 'package:memex/data/services/memory_sync_service.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/logger.dart';

final Logger _logger = getLogger('PkmAgentHandler');

/// Reusable function to process content with PKM Agent.
///
/// This function constructs the prompt based on the provided inputs and
/// executes the PkmAgent. It mimics the backend's `_process_with_pkm_agent`.
///
/// [dryRun] - If true, the agent will run but tools will skip side-effects.
Future<void> processWithPkmAgent({
  required String userId,
  required String factId,
  required String contentText,
  List<Map<String, dynamic>>? assetAnalyses,
  DateTime? inputDateTime,
  bool dryRun = false,
}) async {
  try {
    _logger.info("processWithPkmAgent for $factId (dryRun: $dryRun)");

    // Skip if LLM is not configured.
    final llmConfig = await UserStorage.getAgentLLMConfig(
      AgentDefinitions.pkmAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    if (!llmConfig.isValid) {
      _logger.info('No LLM configured — skipping PKM agent for $factId');
      return;
    }

    // 1. Get LLM Resources (Default to Responses for PKM)
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.pkmAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final client = resources.client;

    // 2. Construct Fact Content
    final dateTime = inputDateTime ?? DateTime.now();

    // Build asset info string
    // Build asset info string
    final assetInfo = formatAssetAnalysis(assetAnalyses);

    final currentTime = dateTime.toString().substring(0, 19);

    // 3. (Client initialized above)

    final instruction = Prompts.pkmAgentInstructionForNewPublishedContent(
      currentTime,
      factId,
      contentText,
      assetInfo,
    );

    // 4. Run Agent
    await PkmAgent.runWithContent(
      client: client,
      modelConfig: resources.modelConfig,
      userId: userId,
      factId: factId,
      instruction: instruction,
    );

    await MemorySyncService.instance.enqueueFact(userId, factId);
  } catch (e, stack) {
    _logger.severe('Error in processWithPkmAgent', e, stack);
    rethrowIfNonRetryable(e);
  }
}

/// Task Handler implementation for `pkm_agent_task`.
Future<void> handlePkmAgentImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  _logger.info('Starting PKM Agent task for user: $userId');

  try {
    // 1. Parse Payload
    final factId = payload['fact_id'] as String;
    final combinedText = payload['combined_text'] as String;
    final createdAtTs = (payload['created_at_ts'] as num?)?.toInt();

    // Check for dry_run flag in payload, default to false
    final dryRun = payload['dry_run'] as bool? ?? false;

    final inputDateTime = createdAtTs != null
        ? DateTime.fromMillisecondsSinceEpoch(createdAtTs * 1000)
        : DateTime.now();

    // 2. Retrieve asset analyses (Stage 1 result)
    List<Map<String, dynamic>>? assetAnalyses;
    if (context.bizId != null) {
      // Check if asset analysis failed and input is media-only
      await failIfAssetAnalysisFailed(
        bizId: context.bizId,
        combinedText: combinedText,
      );
      try {
        final analysisResult = await LocalTaskExecutor.instance
            .getTaskResultByBizId(
                userId, 'handle_analyze_assets', context.bizId!);

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
    await processWithPkmAgent(
      userId: userId,
      factId: factId,
      contentText: combinedText,
      assetAnalyses: assetAnalyses,
      inputDateTime: inputDateTime,
      dryRun: dryRun,
    );

    _logger.info('PKM Agent task completed for $factId');
  } catch (e, stack) {
    _logger.severe('Error in PKM Agent task: $e', e, stack);
    rethrowIfNonRetryable(e);
  }
}
