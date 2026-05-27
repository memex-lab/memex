import 'dart:async';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart';
import 'package:memex/domain/models/task_exceptions.dart';

final Logger _logger = getLogger('LocalTaskHandlers');

/// Handler for Schedule Aggregation Update
Future<void> handleScheduleAggregation(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  _logger.info(
    'Executing handleScheduleAggregation for task ${context.taskId}, bizId: ${context.bizId}',
  );

  try {
    final factId = payload['fact_id'] as String?;
    final runId = factId != null && factId.isNotEmpty
        ? factId
        : context.taskId;
    await ScheduleAggregatorAgent.updateScheduleAggregation(
      userId: userId,
      runId: runId,
      routerHint: payload,
    );
  } on AgentException catch (e) {
    if (e.code == AgentExceptionCode.loopDetection) {
      _logger.severe('Schedule aggregation loop detected: $e');
      throw NonRetryableAgentLoopException(
        'Schedule aggregation reached the max-turn guard.',
        originalError: e,
      );
    }
    rethrow;
  } catch (e) {
    _logger.severe('Schedule aggregation failed: $e');
    rethrow;
  }
}
