import 'package:memex/agent/ask_clarification_agent/ask_clarification_agent.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('AskClarificationHandler');

Future<void> handleAskClarificationTask(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  final factId = payload['fact_id'] as String?;
  if (factId == null || factId.isEmpty) {
    _logger.warning('Ask clarification task skipped: missing fact_id');
    return;
  }
  final combinedText = payload['combined_text'] as String? ?? '';

  final llmConfig = await UserStorage.getAgentLLMConfig(
    AgentDefinitions.askClarificationAgent,
    defaultClientKey: LLMConfig.defaultClientKey,
  );
  if (!llmConfig.isValid) {
    _logger.info('No LLM configured for ask_clarification; skipping $factId');
    return;
  }

  try {
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.askClarificationAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    await AskClarificationAgent.run(
      client: resources.client,
      modelConfig: resources.modelConfig,
      userId: userId,
      factId: factId,
      combinedText: combinedText,
    );
  } catch (e, st) {
    _logger.severe('AskClarificationAgent failed for $factId', e, st);
    rethrowIfNonRetryable(e);
  }
}
