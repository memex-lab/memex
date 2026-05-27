import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_retention.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_aggregation_normalizer.dart';
import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/logger.dart';

import '../../../utils/user_storage.dart';

class ScheduleAggregationSkill extends Skill {
  ScheduleAggregationSkill({super.forceActivate})
      : super(
          name: "update_schedule_aggregation",
          description:
              "Analyzes user's temporal cards (events, tasks, routines) and generates a magazine-style schedule aggregation.",
          systemPrompt: Prompts.scheduleAggregatorSkillPrompt(
            UserStorage.l10n.scheduleAggregatorLanguageInstruction,
          ),
          tools: [
            buildGetScheduleCardsTool(),
            buildSaveScheduleAggregationTool(),
          ],
        );
}

const scheduleTemporalTemplateIds = {
  'event',
  'task',
  'routine',
  'duration',
  'procedure',
};

const defaultScheduleAggregationLookback = Duration(days: 3);
const defaultScheduleAggregationLookahead = Duration(days: 30);

dynamic scheduleStartTimeForCard(String templateId, Map<String, dynamic> data) {
  final startTime = _nonEmptyScheduleValue(data['start_time']);
  if (startTime != null) return startTime;

  if (templateId == 'task') {
    return _nonEmptyScheduleValue(data['due_date']);
  }
  return null;
}

Future<Map<String, dynamic>> queryScheduleCardsForRange({
  required String userId,
  DateTime? from,
  DateTime? to,
  int? limit,
}) async {
  final logger = getLogger('ScheduleAggregationSkill');
  final fileSystem = FileSystemService.instance;
  final now = DateTime.now();
  final effectiveFrom =
      from ?? now.subtract(defaultScheduleAggregationLookback);
  final effectiveTo = to ?? now.add(defaultScheduleAggregationLookahead);

  final db = AppDatabase.instance;
  if (await db.cardDao.isCacheEmpty()) {
    await fileSystem.rebuildCardCache(userId);
  }
  final query = db.select(db.cardCache);
  final cachedCards = await query.get();
  final results = <Map<String, dynamic>>[];

  for (final cached in cachedCards) {
    try {
      final cardData = await fileSystem.readCardFile(userId, cached.factId);
      if (cardData == null) continue;

      final temporalConfigs = cardData.uiConfigs.where(
        (config) => scheduleTemporalTemplateIds.contains(config.templateId),
      );
      if (temporalConfigs.isEmpty) continue;

      final uiConfig = temporalConfigs.first;
      final templateId = uiConfig.templateId;
      final data = uiConfig.data;
      final startTime = scheduleStartTimeForCard(templateId, data);
      final status = deriveScheduleCardStatus(templateId, data);
      final dateSource = scheduleDateSourceForCard(templateId, data);

      if (!_isCardInScheduleRange(
        templateId: templateId,
        data: data,
        fallbackTimestamp: cardData.timestamp,
        from: effectiveFrom,
        to: effectiveTo,
      )) {
        continue;
      }

      final result = <String, dynamic>{
        'card_id': cached.factId,
        'title': cardData.title,
        'template_id': templateId,
        'timestamp': cardData.timestamp,
        'status': status,
        'tags': cardData.tags,
        'start_time': startTime,
        'date_source': dateSource,
        'is_unscheduled': dateSource == 'created_at_fallback',
        'end_time': data['end_time'],
        'location': data['location'],
        'is_completed':
            templateId == 'task' ? status == 'completed' : data['is_completed'],
        'priority': data['priority'],
        'due_date': data['due_date'],
        'subtasks': data['subtasks'],
        'habit_name': data['habit_name'],
        'streak': data['streak'],
        'steps': data['steps'],
        'elapsed': data['elapsed'],
      };

      results.add(result);
    } catch (e) {
      logger.warning('Error processing card ${cached.factId}: $e');
    }
  }

  final actions = await SystemActionService.instance.getVisibleForSchedule();
  for (final action in actions) {
    try {
      final actionResult = scheduleResultForSystemAction(action);
      if (actionResult == null) continue;
      if (!_isResultInScheduleRange(actionResult, effectiveFrom, effectiveTo)) {
        continue;
      }
      if (_duplicatesExistingScheduleResult(results, actionResult)) {
        continue;
      }
      results.add(actionResult);
    } catch (e) {
      logger.warning('Error processing system action ${action.id}: $e');
    }
  }

  results.sort((a, b) {
    final aTime = _resultScheduleDate(a);
    final bTime = _resultScheduleDate(b);
    return aTime.compareTo(bTime);
  });

  final cards = limit == null ? results : results.take(limit).toList();
  return {
    'count': cards.length,
    'date_range': {
      'from': effectiveFrom.toIso8601String(),
      'to': effectiveTo.toIso8601String(),
    },
    'cards': cards,
  };
}

/// Tool to query temporal cards within a date range
Tool buildGetScheduleCardsTool() {
  return Tool(
    name: 'get_schedule_cards',
    description:
        'Query temporal cards (events, tasks, routines, durations, procedures) within a date range. Returns structured card data including title, normalized start_time, status, template type, and task subtasks. Task due_date is exposed as start_time when start_time is absent.',
    parameters: {
      'type': 'object',
      'properties': {
        'from_date': {
          'type': 'string',
          'description':
              'Start date in ISO format (e.g., 2026-04-20). Defaults to 3 days ago.',
        },
        'to_date': {
          'type': 'string',
          'description':
              'End date in ISO format (e.g., 2026-04-30). Defaults to 30 days from now.',
        },
      },
    },
    executable: (String? fromDate, String? toDate) async {
      final logger = getLogger('ScheduleAggregationSkill');
      final metadata = AgentCallToolContext.current!.state.metadata;
      final userId = metadata['userId'] as String;

      final now = DateTime.now();
      final defaultFrom = _parseBoundaryDate(
        metadata['schedule_window_from']?.toString(),
        fallback: now.subtract(defaultScheduleAggregationLookback),
      );
      final defaultTo = _parseBoundaryDate(
        metadata['schedule_window_to']?.toString(),
        fallback: now.add(defaultScheduleAggregationLookahead),
      );
      final from = _parseBoundaryDate(fromDate, fallback: defaultFrom);
      final to = _parseBoundaryDate(
        toDate,
        fallback: defaultTo,
        endOfDay: true,
      );

      try {
        final result = await queryScheduleCardsForRange(
          userId: userId,
          from: from,
          to: to,
        );
        if ((result['cards'] as List).isEmpty) {
          return "No temporal cards (event/task/routine/duration/procedure) found in the specified date range.";
        }

        return jsonEncode(result);
      } catch (e) {
        logger.severe('Failed to get schedule cards: $e');
        throw Exception('Failed to get schedule cards: $e');
      }
    },
  );
}

/// Tool to save schedule aggregation YAML
Tool buildSaveScheduleAggregationTool() {
  return Tool(
    name: 'save_schedule_aggregation',
    description:
        'Save the schedule aggregation as a YAML file. The aggregation_id should be in format "schedule_agg_YYYY_MM_DD".',
    parameters: {
      'type': 'object',
      'properties': {
        'aggregation_id': {
          'type': 'string',
          'description':
              'Unique ID for this aggregation, e.g., "schedule_agg_2026_04_23"',
        },
        'yaml_data': {
          'type': 'object',
          'description':
              'The schedule aggregation data object matching the required schema.',
        },
      },
      'required': ['aggregation_id', 'yaml_data'],
    },
    executable: (String aggregationId, Map<String, dynamic> yamlData) async {
      final logger = getLogger('ScheduleAggregationSkill');
      final fileSystem = FileSystemService.instance;
      final userId = AgentCallToolContext.current!.state.metadata['userId'];

      try {
        // Validate required fields
        if (!yamlData.containsKey('id')) {
          yamlData['id'] = aggregationId;
        }
        if (!yamlData.containsKey('generated_at')) {
          yamlData['generated_at'] = DateTime.now().toIso8601String();
        }
        if (!yamlData.containsKey('version')) {
          yamlData['version'] = 1;
        }

        final normalizedYamlData = await normalizeScheduleAggregationForCards(
          userId: userId,
          yamlData: yamlData,
        );
        final reconciledYamlData = normalizeScheduleAggregationYaml(
          normalizedYamlData,
        );
        final previousAggregations = await fileSystem.listScheduleAggregations(
          userId,
        );
        final retainedYamlData = applyScheduleDisplayRetention(
          yamlData: reconciledYamlData,
          previousAggregations: previousAggregations,
        );

        await fileSystem.writeScheduleAggregation(
          userId,
          aggregationId,
          retainedYamlData,
        );
        await ScheduleRefreshStateService.instance.clearDirty(
          userId: userId,
          aggregationId: aggregationId,
        );

        // Log event
        try {
          await fileSystem.eventLogService.logFileCreated(
            userId: userId,
            filePath: 'ScheduleAggregations/$aggregationId.yaml',
            description: 'Agent created schedule aggregation',
            metadata: {
              'aggregation_id': aggregationId,
              'card_count': _countAggregationItems(retainedYamlData),
            },
          );
        } catch (e) {
          // Event logging failure should not break tool
        }

        return "Schedule aggregation saved successfully: $aggregationId";
      } catch (e) {
        logger.severe('Failed to save schedule aggregation: $e');
        throw Exception('Failed to save schedule aggregation: $e');
      }
    },
  );
}

DateTime _parseBoundaryDate(
  String? value, {
  required DateTime fallback,
  bool endOfDay = false,
}) {
  final parsed = value == null ? null : DateTime.tryParse(value);
  if (parsed == null) return fallback;

  final isDateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value!);
  if (!endOfDay || !isDateOnly) return parsed;
  return DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59, 999);
}

bool _isCardInScheduleRange({
  required String templateId,
  required Map<String, dynamic> data,
  required int fallbackTimestamp,
  required DateTime from,
  required DateTime to,
}) {
  final fallback = DateTime.fromMillisecondsSinceEpoch(
    fallbackTimestamp * 1000,
    isUtc: true,
  ).toLocal();

  final start = switch (templateId) {
    'event' => _parseScheduleDateTime(data['start_time']) ?? fallback,
    'task' => _parseScheduleDateTime(data['due_date']) ?? fallback,
    _ => _parseScheduleDateTime(data['start_time']) ??
        _parseScheduleDateTime(data['due_date']) ??
        fallback,
  };

  final end = _parseScheduleDateTime(data['end_time']) ?? start;
  return !end.isBefore(from) && !start.isAfter(to);
}

String scheduleDateSourceForCard(String templateId, Map<String, dynamic> data) {
  final startTime = _parseScheduleDateTime(data['start_time']);
  if (startTime != null) return 'start_time';
  if (templateId == 'task') {
    final dueDate = _parseScheduleDateTime(data['due_date']);
    if (dueDate != null) return 'due_date';
  }
  return 'created_at_fallback';
}

DateTime? scheduleExplicitDateForCard(
  String templateId,
  Map<String, dynamic> data,
) {
  final startTime = _parseScheduleDateTime(data['start_time']);
  if (startTime != null) return startTime;
  if (templateId == 'task') {
    return _parseScheduleDateTime(data['due_date']);
  }
  return _parseScheduleDateTime(data['due_date']);
}

Map<String, dynamic>? scheduleResultForSystemAction(SystemAction action) {
  if (action.status == 'rejected') return null;
  if (action.actionType != 'calendar' && action.actionType != 'reminder') {
    return null;
  }

  final data = _decodeActionData(action.actionData);
  if (data == null) return null;
  final title = _nonEmptyScheduleValue(data['title'])?.toString();
  if (title == null) return null;

  final isCalendar = action.actionType == 'calendar';
  final startTime = isCalendar
      ? _nonEmptyScheduleValue(data['start_time'])
      : _nonEmptyScheduleValue(data['due_date']);
  if (_parseScheduleDateTime(startTime) == null) return null;

  return <String, dynamic>{
    'card_id': 'system_action:${action.id}',
    'source_fact_id': action.factId,
    'system_action_id': action.id,
    'source': 'system_action',
    'title': title,
    'template_id': isCalendar ? 'event' : 'reminder',
    'timestamp': action.createdAt ?? action.updatedAt ?? 0,
    'status': 'pending',
    'action_status': action.status,
    'tags': const [],
    'start_time': startTime,
    'end_time': data['end_time'],
    'location': data['location'],
    'due_date': data['due_date'],
    'notes': data['notes'],
    'date_source':
        isCalendar ? 'system_action_start_time' : 'system_action_due_date',
    'is_unscheduled': false,
  };
}

Future<Map<String, dynamic>> normalizeScheduleAggregationForCards({
  required String userId,
  required Map<String, dynamic> yamlData,
}) async {
  final fileSystem = FileSystemService.instance;
  final normalized = _deepCopyMap(yamlData);
  final timeline = normalized['timeline'];
  if (timeline is! List) return normalized;

  final normalizedTimeline = <Map<String, dynamic>>[];
  final unscheduledItems = <Map<String, dynamic>>[];

  for (final rawDay in timeline) {
    if (rawDay is! Map) continue;
    final day = Map<String, dynamic>.from(rawDay);
    final items = day['items'];
    if (items is! List) {
      normalizedTimeline.add(day);
      continue;
    }

    final retainedItems = <Map<String, dynamic>>[];
    for (final rawItem in items) {
      if (rawItem is! Map) continue;
      final item = Map<String, dynamic>.from(rawItem);
      if (await _shouldMoveToUnscheduled(
        fileSystem: fileSystem,
        userId: userId,
        day: day,
        item: item,
      )) {
        unscheduledItems.add(item);
      } else {
        retainedItems.add(item);
      }
    }

    if (retainedItems.isNotEmpty || !_isUnscheduledDay(day)) {
      day['items'] = retainedItems;
      if (retainedItems.isNotEmpty) {
        normalizedTimeline.add(day);
      }
    } else {
      unscheduledItems.insertAll(0, retainedItems);
    }
  }

  if (unscheduledItems.isNotEmpty) {
    final existingIndex = normalizedTimeline.indexWhere(_isUnscheduledDay);
    if (existingIndex >= 0) {
      final existing = normalizedTimeline[existingIndex];
      final existingItems = existing['items'];
      existing['items'] = [
        if (existingItems is List) ...existingItems,
        ...unscheduledItems,
      ];
    } else {
      normalizedTimeline.add({
        'day_label': '待安排',
        'day_date': '',
        'items': unscheduledItems,
      });
    }
  }

  normalized['timeline'] = normalizedTimeline;
  return normalized;
}

Future<bool> _shouldMoveToUnscheduled({
  required FileSystemService fileSystem,
  required String userId,
  required Map<String, dynamic> day,
  required Map<String, dynamic> item,
}) async {
  if (_isUnscheduledDay(day)) return false;
  if (_parseScheduleDateTime(item['start_time']) != null ||
      _parseScheduleDateTime(item['due_date']) != null) {
    return false;
  }

  final type = item['type']?.toString().toLowerCase().trim();
  if (type != 'task' && type != 'todo') return false;

  final cardId = item['card_id']?.toString();
  if (cardId == null || !_isFactId(cardId)) return false;

  final cardData = await fileSystem.readCardFile(userId, cardId);
  if (cardData == null) return false;
  for (final config in cardData.uiConfigs) {
    if (config.templateId != 'task') continue;
    return scheduleExplicitDateForCard(config.templateId, config.data) == null;
  }
  return false;
}

bool _isUnscheduledDay(Map<dynamic, dynamic> day) {
  final label = day['day_label']?.toString().trim();
  final dayDate = day['day_date']?.toString().trim();
  return dayDate == null ||
      dayDate.isEmpty ||
      label == '待安排' ||
      label == '周末待定';
}

bool _isFactId(String value) {
  return RegExp(r'^\d{4}/\d{2}/\d{2}\.md#ts_\d+$').hasMatch(value);
}

bool _isResultInScheduleRange(
  Map<String, dynamic> result,
  DateTime from,
  DateTime to,
) {
  final start = _parseScheduleDateTime(result['start_time']) ??
      _parseScheduleDateTime(result['due_date']);
  if (start == null) return false;
  final end = _parseScheduleDateTime(result['end_time']) ?? start;
  return !end.isBefore(from) && !start.isAfter(to);
}

bool _duplicatesExistingScheduleResult(
  List<Map<String, dynamic>> existing,
  Map<String, dynamic> candidate,
) {
  final candidateTitle = _normalizeTitle(candidate['title']);
  final candidateDate = _parseScheduleDateTime(candidate['start_time']) ??
      _parseScheduleDateTime(candidate['due_date']);
  if (candidateTitle.isEmpty || candidateDate == null) return false;

  for (final item in existing) {
    final itemTitle = _normalizeTitle(item['title']);
    final itemDate = _parseScheduleDateTime(item['start_time']) ??
        _parseScheduleDateTime(item['due_date']);
    if (itemTitle == candidateTitle && _sameMinute(itemDate, candidateDate)) {
      return true;
    }
  }
  return false;
}

String _normalizeTitle(dynamic value) {
  return value
          ?.toString()
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '') ??
      '';
}

bool _sameMinute(DateTime? a, DateTime b) {
  if (a == null) return false;
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;
}

Map<String, dynamic>? _decodeActionData(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final decoded = jsonDecode(value);
  if (decoded is Map) return Map<String, dynamic>.from(decoded);
  return null;
}

Map<String, dynamic> _deepCopyMap(Map<String, dynamic> value) {
  return Map<String, dynamic>.from(_deepCopy(value) as Map);
}

dynamic _deepCopy(dynamic value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key.toString(): _deepCopy(entry.value),
    };
  }
  if (value is List) {
    return value.map(_deepCopy).toList();
  }
  return value;
}

DateTime? _parseScheduleDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    final milliseconds = value > 100000000000 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    ).toLocal();
  }
  if (value is num) {
    final milliseconds = value > 100000000000 ? value.toInt() : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(
      milliseconds.toInt(),
      isUtc: true,
    ).toLocal();
  }
  if (value is String) return DateTime.tryParse(value);
  return null;
}

dynamic _nonEmptyScheduleValue(dynamic value) {
  if (value is String && value.trim().isEmpty) return null;
  return value;
}

DateTime _resultScheduleDate(Map<String, dynamic> result) {
  final timestamp = (result['timestamp'] as num?)?.toInt() ?? 0;
  final fallback = DateTime.fromMillisecondsSinceEpoch(
    timestamp * 1000,
    isUtc: true,
  ).toLocal();
  return _parseScheduleDateTime(result['start_time']) ??
      _parseScheduleDateTime(result['due_date']) ??
      fallback;
}

String deriveScheduleCardStatus(String templateId, Map<String, dynamic> data) {
  if (templateId == 'task') {
    if (_deriveTaskCompleted(data)) return 'completed';
    if (_hasCompletedSubtask(data['subtasks'])) return 'in_progress';
    return 'pending';
  }

  return 'pending';
}

bool _deriveTaskCompleted(Map<String, dynamic> data) {
  if (_parseScheduleBool(data['is_completed']) == true) return true;
  final subtasks = data['subtasks'];
  return subtasks is List &&
      subtasks.isNotEmpty &&
      subtasks.every(
        (subtask) =>
            subtask is Map && _parseScheduleBool(subtask['completed']) == true,
      );
}

bool _hasCompletedSubtask(dynamic value) {
  return value is List &&
      value.any(
        (subtask) =>
            subtask is Map && _parseScheduleBool(subtask['completed']) == true,
      );
}

bool? _parseScheduleBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    return switch (value.toLowerCase().trim()) {
      'true' || 'yes' || 'y' || '1' || 'done' || 'completed' => true,
      'false' || 'no' || 'n' || '0' || 'pending' || 'todo' => false,
      _ => null,
    };
  }
  return null;
}

int _countAggregationItems(Map<String, dynamic> yamlData) {
  final heroCount = yamlData['hero_item'] == null ? 0 : 1;
  final timelineCount =
      (yamlData['timeline'] as List?)?.whereType<Map>().fold<int>(
                0,
                (count, day) => count + ((day['items'] as List?)?.length ?? 0),
              ) ??
          0;
  final completedCount = (yamlData['completed'] as List?)?.length ?? 0;
  return heroCount + timelineCount + completedCount;
}
