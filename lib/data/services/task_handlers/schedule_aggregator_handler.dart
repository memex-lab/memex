import 'dart:async';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart';

final Logger _logger = getLogger('LocalTaskHandlers');

/// Handler for Schedule Aggregation Update
Future<void> handleScheduleAggregation(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  _logger.info(
      'Executing handleScheduleAggregation for task ${context.taskId}, bizId: ${context.bizId}');

  try {
    await ScheduleAggregatorAgent.updateScheduleAggregation();
  } catch (e) {
    _logger.severe('Schedule aggregation failed: $e');
    rethrow;
  }
}
