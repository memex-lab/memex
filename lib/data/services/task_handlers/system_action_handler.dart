import 'package:memex/agent/system_action_agent/system_action_agent.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('SystemActionHandler');

Future<void> handleSystemActionTask(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  final factId = payload['fact_id'] as String?;
  if (factId == null || factId.isEmpty) {
    _logger.warning('System action task skipped: missing fact_id');
    return;
  }
  final combinedText = payload['combined_text'] as String? ?? '';

  final llmConfig = await UserStorage.getAgentLLMConfig(
    AgentDefinitions.systemActionAgent,
    defaultClientKey: LLMConfig.defaultClientKey,
  );
  if (!llmConfig.isValid) {
    _logger.info('No LLM configured for system_action; skipping $factId');
    return;
  }

  try {
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.systemActionAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    await SystemActionAgent.run(
      client: resources.client,
      modelConfig: resources.modelConfig,
      userId: userId,
      factId: factId,
      combinedText: combinedText,
    );
  } catch (e, st) {
    _logger.severe('SystemActionAgent failed for $factId', e, st);
    rethrowIfNonRetryable(e);
  }
}
