import 'package:memex/agent/task_completion_agent/task_completion_agent.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('TaskCompletionHandler');

Future<void> handleTaskCompletionTask(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  final factId = payload['fact_id'] as String?;
  if (factId == null || factId.isEmpty) {
    _logger.warning('Task completion task skipped: missing fact_id');
    return;
  }
  final combinedText = payload['combined_text'] as String? ?? '';
  final recentScheduleContext =
      (payload['recent_schedule_context'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};

  final llmConfig = await UserStorage.getAgentLLMConfig(
    AgentDefinitions.taskCompletionAgent,
    defaultClientKey: LLMConfig.defaultClientKey,
  );
  if (!llmConfig.isValid) {
    _logger.info('No LLM configured for task_completion; skipping $factId');
    return;
  }

  try {
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.taskCompletionAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    await TaskCompletionAgent.run(
      client: resources.client,
      modelConfig: resources.modelConfig,
      userId: userId,
      factId: factId,
      combinedText: combinedText,
      recentScheduleContext: recentScheduleContext,
    );
  } catch (e, st) {
    _logger.severe('TaskCompletionAgent failed for $factId', e, st);
    rethrowIfNonRetryable(e);
  }
}
