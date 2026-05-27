import 'package:memex/agent/post_card_router_agent/post_card_router_agent.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/task_exceptions.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('PostCardRouterHandler');

Future<void> handlePostCardRouter(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  final factId = payload['fact_id'] as String?;
  if (factId == null || factId.isEmpty) {
    _logger.warning('Post-card router skipped: missing fact_id');
    return;
  }

  final combinedText = payload['combined_text'] as String? ?? '';
  final inputDateTime = dateTimeFromUnixSeconds(payload['created_at_ts']);
  final locationContextReminder =
      payload['location_context_reminder'] as String?;

  final llmConfig = await UserStorage.getAgentLLMConfig(
    AgentDefinitions.postCardRouterAgent,
    defaultClientKey: LLMConfig.defaultClientKey,
  );

  if (!llmConfig.isValid) {
    _logger.info('Post-card router skipped for $factId: no valid LLM config');
    return;
  }

  try {
    List<Map<String, dynamic>>? assetAnalyses;
    if (context.bizId != null) {
      await failIfAssetAnalysisFailed(
        bizId: context.bizId,
        combinedText: combinedText,
      );
      final analysisResult =
          await LocalTaskExecutor.instance.getTaskResultByBizId(
        userId,
        'handle_analyze_assets',
        context.bizId!,
      );
      if (analysisResult != null &&
          analysisResult.containsKey('asset_analyses')) {
        assetAnalyses = (analysisResult['asset_analyses'] as List)
            .cast<Map<String, dynamic>>();
      }
    }

    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.postCardRouterAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final decision = await runPostCardRouter(
      userId: userId,
      factId: factId,
      combinedText: combinedText,
      assetAnalyses: assetAnalyses,
      inputDateTime: inputDateTime,
      locationContextReminder: locationContextReminder,
      client: resources.client,
      modelConfig: resources.modelConfig,
    );
    _logger.info(
      'Post-card router decision for $factId: '
      'agents=${decision.activatedAgents}',
    );
  } catch (e, st) {
    if (e is NonRetryableLlmException) {
      rethrow;
    }
    _logger.warning(
      'Post-card router LLM failed for $factId; activating nothing.',
      e,
      st,
    );
  }
}
