import 'package:memex/agent/post_card_router_agent/post_card_router_agent.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';
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

  final llmConfig = await UserStorage.getAgentLLMConfig(
    AgentDefinitions.postCardRouterAgent,
    defaultClientKey: LLMConfig.defaultClientKey,
  );

  if (!llmConfig.isValid) {
    final fallback = fallbackPostCardRoute(
      factId: factId,
      combinedText: combinedText,
    );
    _logger.info(
      'Post-card router fallback for $factId: '
      'agents=${fallback.activatedAgents}',
    );
    return;
  }

  try {
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.postCardRouterAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final decision = await runPostCardRouter(
      userId: userId,
      factId: factId,
      combinedText: combinedText,
      client: resources.client,
      modelConfig: resources.modelConfig,
    );
    _logger.info(
      'Post-card router decision for $factId: '
      'agents=${decision.activatedAgents}',
    );
  } catch (e, st) {
    _logger.warning(
      'Post-card router LLM failed for $factId; activating nothing.',
      e,
      st,
    );
  }
}
