import 'dart:convert';

import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/domain/models/schedule_refresh_state.dart';

const int defaultScheduleAggregationCardLimit = 80;
const Duration _dirtyFactWindowLookahead = Duration(days: 7);

class ScheduleAggregationWindow {
  const ScheduleAggregationWindow({
    required this.from,
    required this.to,
    required this.source,
    this.sourceCardIds = const [],
  });

  final DateTime from;
  final DateTime to;
  final String source;
  final List<String> sourceCardIds;

  Map<String, dynamic> toJson() {
    return {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'source': source,
      if (sourceCardIds.isNotEmpty) 'source_card_ids': sourceCardIds,
    };
  }
}

class ScheduleAggregationRunPlan {
  const ScheduleAggregationRunPlan({
    required this.runId,
    required this.generatedAt,
    required this.window,
    required this.scheduleCards,
    required this.refreshState,
    required this.latestAggregation,
  });

  final String runId;
  final DateTime generatedAt;
  final ScheduleAggregationWindow window;
  final Map<String, dynamic> scheduleCards;
  final ScheduleRefreshState refreshState;
  final Map<String, dynamic>? latestAggregation;

  bool get hasScheduleCards =>
      (scheduleCards['cards'] as List?)?.isNotEmpty == true;
}

Future<ScheduleAggregationRunPlan> buildScheduleAggregationRunPlan({
  required String userId,
  required String runId,
  DateTime? now,
  int scheduleCardLimit = defaultScheduleAggregationCardLimit,
}) async {
  final fileSystem = FileSystemService.instance;
  final generatedAt = now ?? DateTime.now();
  final refreshState = await ScheduleRefreshStateService.instance.read(userId);
  final dirtyScheduleDates = await _collectOutOfBandDirtyScheduleDates(
    userId: userId,
    cardIds: refreshState.cardIds,
  );
  final window = resolveScheduleAggregationWindow(
    generatedAt: generatedAt,
    refreshState: refreshState,
    dirtyScheduleDates: dirtyScheduleDates,
  );

  final scheduleCards = await queryScheduleCardsForRange(
    userId: userId,
    from: window.from,
    to: window.to,
    limit: scheduleCardLimit,
  );
  final latestAggregation = await fileSystem.getLatestScheduleAggregation(
    userId,
  );

  return ScheduleAggregationRunPlan(
    runId: runId,
    generatedAt: generatedAt,
    window: window,
    scheduleCards: scheduleCards,
    refreshState: refreshState,
    latestAggregation: latestAggregation,
  );
}

ScheduleAggregationWindow resolveScheduleAggregationWindow({
  required DateTime generatedAt,
  required ScheduleRefreshState refreshState,
  List<DateTime> dirtyScheduleDates = const [],
}) {
  final dirtyDates = <DateTime>[];
  final sourceCardIds = <String>[];
  for (final cardId in refreshState.cardIds) {
    final cardDate = _parseFactIdDate(cardId);
    if (cardDate == null) continue;
    dirtyDates.add(cardDate);
    sourceCardIds.add(cardId);
  }
  dirtyDates.addAll(dirtyScheduleDates);

  if (dirtyDates.isNotEmpty) {
    dirtyDates.sort();
    final first = _startOfDay(dirtyDates.first);
    final last = _endOfDay(dirtyDates.last);
    var to = last.add(_dirtyFactWindowLookahead);
    final recentBoundary =
        generatedAt.subtract(defaultScheduleAggregationLookback);
    if (!last.isBefore(recentBoundary)) {
      final defaultTo = generatedAt.add(defaultScheduleAggregationLookahead);
      if (to.isBefore(defaultTo)) {
        to = defaultTo;
      }
    }
    return ScheduleAggregationWindow(
      from: first.subtract(defaultScheduleAggregationLookback),
      to: to,
      source: dirtyScheduleDates.isNotEmpty
          ? 'dirty_schedule_dates'
          : 'dirty_card_dates',
      sourceCardIds: sourceCardIds,
    );
  }

  return ScheduleAggregationWindow(
    from: generatedAt.subtract(defaultScheduleAggregationLookback),
    to: generatedAt.add(defaultScheduleAggregationLookahead),
    source: 'generated_at_window',
  );
}

String scheduleAggregationIdFor(DateTime generatedAt) {
  return 'schedule_agg_${generatedAt.year.toString().padLeft(4, '0')}_'
      '${generatedAt.month.toString().padLeft(2, '0')}_'
      '${generatedAt.day.toString().padLeft(2, '0')}';
}

Map<String, dynamic> buildNoOpScheduleAggregation({
  required String aggregationId,
  required ScheduleAggregationRunPlan plan,
  String reason = 'no_temporal_cards_in_window',
}) {
  return {
    'id': aggregationId,
    'generated_at': plan.generatedAt.toIso8601String(),
    'version': 1,
    'time_range': {
      'from': _formatDate(plan.window.from),
      'to': _formatDate(plan.window.to),
    },
    'editorial_intro':
        'No temporal schedule cards found for this refresh window.',
    'quote_blocks': const [],
    'timeline': const [],
    'completed': const [],
    'conflicts': const [],
    'no_op': true,
    'no_op_reason': reason,
    'diagnostics': {
      'target_window_source': plan.window.source,
      'target_window': plan.window.toJson(),
      'schedule_card_count': 0,
      'refresh_state': plan.refreshState.toJson(),
    },
  };
}

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
  ScheduleAggregationRunPlan? plan,
}) async {
  final resolvedPlan = plan ??
      await buildScheduleAggregationRunPlan(
        userId: userId,
        runId: runId,
        now: now,
        scheduleCardLimit: scheduleCardLimit,
      );

  final payload = {
    'run_id': resolvedPlan.runId,
    'generated_at': resolvedPlan.generatedAt.toIso8601String(),
    'fresh_execution_state': true,
    'target_window': resolvedPlan.window.toJson(),
    'durable_sources': {
      'schedule_cards': resolvedPlan.scheduleCards,
      'schedule_cards_limit': scheduleCardLimit,
      'latest_schedule_aggregation': _compactScheduleAggregation(
        resolvedPlan.latestAggregation,
      ),
      'refresh_state': resolvedPlan.refreshState.toJson(),
    },
    'execution_policy': [
      'This is a fresh schedule aggregation execution. Do not rely on prior LLM conversation history.',
      'Use durable workspace data as the source of truth: Cards, Facts, ScheduleAggregations, event log, and injected user memory context.',
      'Start from schedule_cards for target_window, then inspect source cards with Read or BatchRead when details are needed.',
      'Use save_schedule_aggregation to persist exactly one current aggregation result.',
      'Preserve completed task status only when task is_completed is true; card processing status does not mean task completion.',
      'When a task card has subtasks, preserve those subtasks on the timeline item; do not invent subtasks for independent cards.',
      'Long-term non-task reference items without a concrete day/start time are display-limited; keep existing display_until values and do not renew them.',
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

Future<List<DateTime>> _collectOutOfBandDirtyScheduleDates({
  required String userId,
  required List<String> cardIds,
}) async {
  if (cardIds.isEmpty) return const [];

  final fileSystem = FileSystemService.instance;
  final dates = <DateTime>[];
  for (final cardId in cardIds) {
    final factDate = _parseFactIdDate(cardId);
    final card = await fileSystem.readCardFile(userId, cardId);
    if (card == null) continue;

    for (final config in card.uiConfigs) {
      if (!scheduleTemporalTemplateIds.contains(config.templateId)) {
        continue;
      }
      final scheduleDate = scheduleExplicitDateForCard(
        config.templateId,
        config.data,
      );
      if (scheduleDate == null) continue;
      if (_isOutOfBandScheduleDate(
        scheduleDate: scheduleDate,
        factDate: factDate,
      )) {
        dates.add(scheduleDate);
      }
    }
  }
  return dates;
}

bool _isOutOfBandScheduleDate({
  required DateTime scheduleDate,
  required DateTime? factDate,
}) {
  if (factDate == null) return true;

  final from =
      _startOfDay(factDate).subtract(defaultScheduleAggregationLookback);
  final to = _endOfDay(factDate).add(_dirtyFactWindowLookahead);
  return scheduleDate.isBefore(from) || scheduleDate.isAfter(to);
}

String _truncate(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength)}...';
}

DateTime? _parseFactIdDate(String value) {
  final match = RegExp(r'(\d{4})/(\d{2})/(\d{2})\.md#ts_\d+').firstMatch(value);
  if (match == null) return null;
  return DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

DateTime _startOfDay(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime _endOfDay(DateTime value) {
  return DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
}

String _formatDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
