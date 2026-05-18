import 'dart:convert';

import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';

const int defaultScheduleAggregationCardLimit = 80;

/// Builds a compact context packet for a fresh schedule aggregation run.
///
/// The agent still uses tools for detailed evidence, but this gives each fresh
/// run a deterministic map of current schedule data instead of relying on prior
/// LLM conversation history.
Future<String> buildScheduleAggregationRunContext({
  required String userId,
  required String runId,
  DateTime? now,
  int scheduleCardLimit = defaultScheduleAggregationCardLimit,
}) async {
  final fileSystem = FileSystemService.instance;
  final generatedAt = now ?? DateTime.now();
  final from = generatedAt.subtract(const Duration(days: 3));
  final to = generatedAt.add(const Duration(days: 7));

  final scheduleCards = await queryScheduleCardsForRange(
    userId: userId,
    from: from,
    to: to,
    limit: scheduleCardLimit,
  );
  final latestAggregation = await fileSystem.getLatestScheduleAggregation(
    userId,
  );
  final refreshState = await ScheduleRefreshStateService.instance.read(userId);

  final payload = {
    'run_id': runId,
    'generated_at': generatedAt.toIso8601String(),
    'fresh_execution_state': true,
    'durable_sources': {
      'schedule_cards': scheduleCards,
      'schedule_cards_limit': scheduleCardLimit,
      'latest_schedule_aggregation': _compactScheduleAggregation(
        latestAggregation,
      ),
      'refresh_state': refreshState.toJson(),
    },
    'execution_policy': [
      'This is a fresh schedule aggregation execution. Do not rely on prior LLM conversation history.',
      'Use durable workspace data as the source of truth: Cards, Facts, ScheduleAggregations, event log, and injected user memory context.',
      'Start from schedule_cards for the current refresh window, then inspect source cards with Read or BatchRead when details are needed.',
      'Use save_schedule_aggregation to persist exactly one current aggregation result.',
      'Preserve completed task status only when task is_completed is true; card processing status does not mean task completion.',
      'When a task card has subtasks, preserve those subtasks on the timeline item; do not invent subtasks for independent cards.',
    ],
  };

  return '<schedule_aggregation_run_context>\n'
      '${const JsonEncoder.withIndent('  ').convert(payload)}\n'
      '</schedule_aggregation_run_context>';
}

Map<String, dynamic>? _compactScheduleAggregation(Map<String, dynamic>? value) {
  if (value == null) return null;
  final timeline = value['timeline'];
  return {
    if (value['id'] != null) 'id': value['id'],
    if (value['generated_at'] != null) 'generated_at': value['generated_at'],
    if (value['time_range'] != null) 'time_range': value['time_range'],
    if (value['hero_item'] != null)
      'hero_item': _compactHero(value['hero_item']),
    if (value['editorial_intro'] != null)
      'editorial_intro': _truncate(value['editorial_intro'].toString(), 360),
    if (value['quote_blocks'] is List)
      'quote_block_count': (value['quote_blocks'] as List).length,
    if (value['conflicts'] is List)
      'conflict_count': (value['conflicts'] as List).length,
    if (value['completed'] is List)
      'completed_count': (value['completed'] as List).length,
    if (timeline is List) 'timeline_days': timeline.map(_compactDay).toList(),
  };
}

Map<String, dynamic> _compactHero(dynamic value) {
  if (value is! Map) return const {};
  return {
    if (value['card_id'] != null) 'card_id': value['card_id'],
    if (value['title'] != null) 'title': value['title'],
    if (value['start_time'] != null) 'start_time': value['start_time'],
    if (value['end_time'] != null) 'end_time': value['end_time'],
    if (value['priority'] != null) 'priority': value['priority'],
  };
}

Map<String, dynamic> _compactDay(dynamic value) {
  if (value is! Map) return const {};
  final items = value['items'];
  return {
    if (value['day_label'] != null) 'day_label': value['day_label'],
    if (value['day_date'] != null) 'day_date': value['day_date'],
    if (items is List) 'item_count': items.length,
    if (items is List)
      'item_ids': items.map(_itemId).whereType<String>().toList(),
  };
}

String? _itemId(dynamic value) {
  if (value is! Map) return null;
  return value['card_id']?.toString();
}

String _truncate(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength)}...';
}
