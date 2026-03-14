import 'dart:async';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/agent/insight_agent/knowledge_insight_agent.dart';
import 'package:memex/data/services/event_bus_service.dart';

final Logger _logger = getLogger('LocalTaskHandlers');

/// Handler for Knowledge Insight Update
Future<void> handleKnowledgeInsight(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  _logger.info(
      'Executing handleKnowledgeInsight for task ${context.taskId}, bizId: ${context.bizId}');
  // We don't need type or period for global insights anymore, but we can log them if present
  // final type = payload['type'] as String?;
  // final period = payload['period'] as String?;

  await KnowledgeInsightAgent.updateKnowledgeInsight();

  // Notify UI layer that insight data should be reloaded.
  EventBusService.instance.emitEvent(NewInsightMessage(
    insightId: context.bizId ?? context.taskId,
    html: '',
  ));
}
