import 'package:memex/agent/schedule_refresh_router_agent/schedule_refresh_router_agent.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('ScheduleRefreshRouterHandler');

Future<void> handleScheduleRefreshRouter(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  final factId = payload['fact_id'] as String?;
  if (factId == null || factId.isEmpty) {
    _logger.warning('Schedule refresh router skipped: missing fact_id');
    return;
  }

  final combinedText = payload['combined_text'] as String? ?? '';
  final fileSystem = FileSystemService.instance;
  final cardData = await fileSystem.readCardFile(userId, factId);
  if (cardData == null) {
    _logger.warning('Schedule refresh router skipped: card not found $factId');
    return;
  }

  final llmConfig = await UserStorage.getAgentLLMConfig(
    AgentDefinitions.scheduleRefreshRouterAgent,
    defaultClientKey: LLMConfig.defaultClientKey,
  );

  if (!llmConfig.isValid) {
    final decision = await fallbackScheduleRefreshDecision(
      userId: userId,
      factId: factId,
      cardData: cardData,
    );
    _logger.info(
      'Schedule refresh router fallback for $factId: ${decision.action.name}',
    );
    return;
  }

  final now = DateTime.now();
  final recentScheduleContext = await queryScheduleCardsForRange(
    userId: userId,
    from: now.subtract(const Duration(days: 3)),
    to: now.add(const Duration(days: 7)),
    limit: 40,
  );
  final refreshState =
      (await ScheduleRefreshStateService.instance.read(userId)).toJson();

  try {
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.scheduleRefreshRouterAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final decision = await ScheduleRefreshRouterAgent.route(
      client: resources.client,
      modelConfig: resources.modelConfig,
      userId: userId,
      factId: factId,
      combinedText: combinedText,
      cardData: cardData,
      recentScheduleContext: recentScheduleContext,
      refreshState: refreshState,
    );
    _logger.info(
      'Schedule refresh router decision for $factId: ${decision.action.name}',
    );
  } catch (e, st) {
    _logger.warning(
      'Schedule refresh router LLM failed for $factId; using fallback',
      e,
      st,
    );
    await fallbackScheduleRefreshDecision(
      userId: userId,
      factId: factId,
      cardData: cardData,
    );
  }
}
