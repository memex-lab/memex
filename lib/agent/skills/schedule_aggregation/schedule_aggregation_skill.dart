import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/data/services/file_system_service.dart';
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

/// Tool to query temporal cards within a date range
Tool buildGetScheduleCardsTool() {
  return Tool(
    name: 'get_schedule_cards',
    description:
        'Query temporal cards (events, tasks, routines, durations, procedures) within a date range. Returns structured card data including title, times, status, and template type.',
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
              'End date in ISO format (e.g., 2026-04-30). Defaults to 7 days from now.',
        },
      },
    },
    executable: (
      String? fromDate,
      String? toDate,
    ) async {
      final logger = getLogger('ScheduleAggregationSkill');
      final fileSystem = FileSystemService.instance;
      final userId = AgentCallToolContext.current!.state.metadata['userId'];

      // Default date range: past 3 days ~ future 7 days
      final now = DateTime.now();
      final from = _parseBoundaryDate(
        fromDate,
        fallback: now.subtract(const Duration(days: 3)),
      );
      final to = _parseBoundaryDate(
        toDate,
        fallback: now.add(const Duration(days: 7)),
        endOfDay: true,
      );

      try {
        // Query all cached cards, then filter temporal cards by their own
        // schedule fields. Creation time alone misses tasks created earlier
        // with future due dates.
        final db = AppDatabase.instance;
        if (await db.cardDao.isCacheEmpty()) {
          await fileSystem.rebuildCardCache(userId);
        }
        final query = db.select(db.cardCache);
        final cachedCards = await query.get();

        if (cachedCards.isEmpty) {
          return "No temporal cards found in the specified date range.";
        }

        // Temporal template IDs
        const temporalTemplates = {
          'event',
          'task',
          'routine',
          'duration',
          'procedure',
        };

        final results = <Map<String, dynamic>>[];

        for (final cached in cachedCards) {
          try {
            // Read card YAML
            final cardData =
                await fileSystem.readCardFile(userId, cached.factId);
            if (cardData == null) continue;

            // Check if card has temporal template
            final uiConfigs = cardData.uiConfigs;
            if (uiConfigs.isEmpty) continue;

            final temporalConfigs = uiConfigs.where(
              (config) => temporalTemplates.contains(config.templateId),
            );
            if (temporalConfigs.isEmpty) continue;

            final uiConfig = temporalConfigs.first;
            final templateId = uiConfig.templateId;

            final data = uiConfig.data;
            if (!_isCardInScheduleRange(
              templateId: templateId,
              data: data,
              fallbackTimestamp: cardData.timestamp,
              from: from,
              to: to,
            )) {
              continue;
            }

            // Extract key fields
            final result = <String, dynamic>{
              'card_id': cached.factId,
              'title': cardData.title,
              'template_id': templateId,
              'timestamp': cardData.timestamp,
              'status': cardData.status,
              'tags': cardData.tags,
            };

            // Extract temporal-specific fields
            result['start_time'] = data['start_time'];
            result['end_time'] = data['end_time'];
            result['location'] = data['location'];
            result['is_completed'] = data['is_completed'];
            result['priority'] = data['priority'];
            result['due_date'] = data['due_date'];
            result['subtasks'] = data['subtasks'];
            result['habit_name'] = data['habit_name'];
            result['streak'] = data['streak'];
            result['steps'] = data['steps'];
            result['elapsed'] = data['elapsed'];

            results.add(result);
          } catch (e) {
            logger.warning('Error processing card ${cached.factId}: $e');
            continue;
          }
        }

        if (results.isEmpty) {
          return "No temporal cards (event/task/routine/duration/procedure) found in the specified date range.";
        }

        // Sort by actual schedule time, then by card timestamp.
        results.sort((a, b) {
          final aTime = _resultScheduleDate(a);
          final bTime = _resultScheduleDate(b);
          return aTime.compareTo(bTime);
        });

        return jsonEncode({
          'count': results.length,
          'date_range': {
            'from': from.toIso8601String(),
            'to': to.toIso8601String(),
          },
          'cards': results,
        });
      } catch (e) {
        logger.severe('Failed to get schedule cards: $e');
        return "Error: $e";
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
    executable: (
      String aggregationId,
      Map<String, dynamic> yamlData,
    ) async {
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

        await fileSystem.writeScheduleAggregation(
          userId,
          aggregationId,
          yamlData,
        );

        // Log event
        try {
          await fileSystem.eventLogService.logFileCreated(
            userId: userId,
            filePath: 'ScheduleAggregations/$aggregationId.yaml',
            description: 'Agent created schedule aggregation',
            metadata: {
              'aggregation_id': aggregationId,
              'card_count': _countAggregationItems(yamlData),
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

DateTime? _parseScheduleDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    final milliseconds = value > 100000000000 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true)
        .toLocal();
  }
  if (value is num) {
    final milliseconds = value > 100000000000 ? value.toInt() : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds.toInt(),
            isUtc: true)
        .toLocal();
  }
  if (value is String) return DateTime.tryParse(value);
  return null;
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
