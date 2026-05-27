import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/data/services/schedule_state_service.dart';
import 'package:memex/domain/models/schedule_state.dart';

import '../../../utils/user_storage.dart';

class ScheduleAggregationSkill extends Skill {
  ScheduleAggregationSkill({
    super.forceActivate,
    bool stopAfterSetPresentation = false,
  }) : super(
          name: "update_schedule_aggregation",
          description:
              "Maintains schedule_state and its magazine-style presentation when the current input warrants it.",
          systemPrompt: Prompts.scheduleAggregatorSkillPrompt(
            UserStorage.l10n.scheduleAggregatorLanguageInstruction,
          ),
          tools: [
            buildGetScheduleStateTool(),
            buildAddPendingItemTool(),
            buildUpdatePendingItemTool(),
            buildCompletePendingItemTool(),
            buildCompleteSubtaskTool(),
            buildSetPresentationTool(
              stopAfterSetPresentation: stopAfterSetPresentation,
            ),
            buildSearchCompletedTool(),
          ],
        );
}

Tool buildGetScheduleStateTool() {
  return Tool(
    name: 'get_schedule_state',
    description:
        'Return the canonical schedule_state document. Completed items are '
        'truncated to the latest 20 entries; use search_completed for older '
        'history.',
    parameters: {'type': 'object', 'properties': {}},
    executable: () async {
      final userId = AgentCallToolContext.current!.state.metadata['userId'];
      final state = await ScheduleStateService.instance.read(userId);
      final data = state.toJson();
      data['completed'] =
          state.completed.take(20).map((item) => item.toJson()).toList();
      data['completed_truncated'] = state.completed.length > 20;
      return jsonEncode(data);
    },
  );
}

Tool buildAddPendingItemTool() {
  return Tool(
    name: 'add_pending_item',
    description:
        'Append a pending item to schedule_state. kind=todo uses due_at and '
        'optional subtasks; kind=event uses start_time plus optional end_time '
        'and location. Do not mix todo-only and event-only fields.',
    parameters: {
      'type': 'object',
      'properties': {
        'kind': {
          'type': 'string',
          'enum': ['todo', 'event']
        },
        'title': {'type': 'string'},
        'description': {'type': 'string'},
        'start_time': {
          'type': 'string',
          'description': 'Event-only ISO8601 start time.'
        },
        'end_time': {
          'type': 'string',
          'description': 'Event-only optional ISO8601 end time.'
        },
        'due_at': {
          'type': 'string',
          'description': 'Todo-only optional ISO8601 deadline/time anchor.'
        },
        'location': {
          'type': 'string',
          'description': 'Event-only optional location.'
        },
        'priority': {'type': 'number'},
        'subtasks': {
          'type': 'array',
          'description': 'Todo-only explicit subtasks.'
        },
        'sync_device_action': {
          'type': 'boolean',
          'description':
              'Set true when this item should also be synced to the device calendar/reminders. Defaults to false.'
        },
        'source_fact_id': {'type': 'string'},
      },
      'required': ['kind', 'title', 'source_fact_id'],
    },
    executable: (
      String kind,
      String title,
      String? description,
      String? startTime,
      String? endTime,
      String? dueAt,
      String? location,
      num? priority,
      List<dynamic>? subtasks,
      bool? syncDeviceAction,
      String sourceFactId,
    ) async {
      final userId = AgentCallToolContext.current!.state.metadata['userId'];
      final state = await ScheduleStateService.instance.addPendingItem(
        userId: userId,
        kind: kind,
        title: title,
        description: _nonEmptyString(description),
        startTime: _parseScheduleDateTime(startTime),
        endTime: _parseScheduleDateTime(endTime),
        dueAt: _parseScheduleDateTime(dueAt),
        location: _nonEmptyString(location),
        priority: priority?.toInt(),
        subtasks: _parseScheduleSubtasks(subtasks),
        sourceFactId: sourceFactId,
        syncDeviceAction: syncDeviceAction == true,
      );
      final item = _latestPendingItemForSource(
        state,
        sourceFactId: sourceFactId,
        title: title,
      );
      return jsonEncode({
        'status': 'ok',
        'item_id': item?.id,
        'pending': state.pending.length,
      });
    },
  );
}

Tool buildUpdatePendingItemTool() {
  return Tool(
    name: 'update_pending_item',
    description:
        'Update an existing pending item by id. For todos, update due_at and '
        'subtasks. For events, update start_time, end_time, and location. '
        'Pass clear_* flags to remove optional fields.',
    parameters: {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'title': {'type': 'string'},
        'description': {'type': 'string'},
        'start_time': {
          'type': 'string',
          'description': 'Event-only ISO8601 start time.'
        },
        'end_time': {
          'type': 'string',
          'description': 'Event-only optional ISO8601 end time.'
        },
        'due_at': {
          'type': 'string',
          'description': 'Todo-only optional ISO8601 deadline/time anchor.'
        },
        'location': {
          'type': 'string',
          'description': 'Event-only optional location.'
        },
        'priority': {'type': 'number'},
        'subtasks': {
          'type': 'array',
          'description': 'Todo-only explicit subtasks.'
        },
        'sync_device_action': {
          'type': 'boolean',
          'description':
              'Set true to sync this item to the device calendar/reminders; set false to disable and cancel any existing synced action.'
        },
        'clear_description': {'type': 'boolean'},
        'clear_start_time': {'type': 'boolean'},
        'clear_end_time': {'type': 'boolean'},
        'clear_due_at': {'type': 'boolean'},
        'clear_location': {'type': 'boolean'},
        'clear_priority': {'type': 'boolean'},
      },
      'required': ['id'],
    },
    executable: (
      String id,
      String? title,
      String? description,
      String? startTime,
      String? endTime,
      String? dueAt,
      String? location,
      num? priority,
      List<dynamic>? subtasks,
      bool? syncDeviceAction,
      bool? clearDescription,
      bool? clearStartTime,
      bool? clearEndTime,
      bool? clearDueAt,
      bool? clearLocation,
      bool? clearPriority,
    ) async {
      final userId = AgentCallToolContext.current!.state.metadata['userId'];
      final state = await ScheduleStateService.instance.updatePendingItem(
        userId: userId,
        pendingId: id,
        title: _nonEmptyString(title),
        description: _nonEmptyString(description),
        startTime: _parseScheduleDateTime(startTime),
        endTime: _parseScheduleDateTime(endTime),
        dueAt: _parseScheduleDateTime(dueAt),
        location: _nonEmptyString(location),
        priority: priority?.toInt(),
        subtasks: _parseScheduleSubtasks(subtasks),
        syncDeviceAction: syncDeviceAction,
        clearDescription: clearDescription == true,
        clearStartTime: clearStartTime == true,
        clearEndTime: clearEndTime == true,
        clearDueAt: clearDueAt == true,
        clearLocation: clearLocation == true,
        clearPriority: clearPriority == true,
      );
      return 'Pending item updated. pending=${state.pending.length}';
    },
  );
}

Tool buildCompletePendingItemTool() {
  return Tool(
    name: 'complete_pending_item',
    description: 'Move a pending item to completed.',
    parameters: {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'closed_by_fact_id': {'type': 'string'},
        'closed_at': {'type': 'string'},
      },
      'required': ['id', 'closed_by_fact_id'],
    },
    executable: (String id, String closedByFactId, String? closedAt) async {
      final userId = AgentCallToolContext.current!.state.metadata['userId'];
      final state = await ScheduleStateService.instance.completePendingItem(
        userId: userId,
        pendingId: id,
        closedByFactId: closedByFactId,
        closedAt: _parseScheduleDateTime(closedAt),
      );
      return 'Pending item completed. completed=${state.completed.length}';
    },
  );
}

Tool buildCompleteSubtaskTool() {
  return Tool(
    name: 'complete_subtask',
    description:
        'Mark one exact subtask on a pending todo completed. If all subtasks '
        'are completed, the pending item is moved to completed.',
    parameters: {
      'type': 'object',
      'properties': {
        'item_id': {'type': 'string'},
        'subtask_title': {'type': 'string'},
        'closed_by_fact_id': {'type': 'string'},
        'closed_at': {'type': 'string'},
      },
      'required': ['item_id', 'subtask_title', 'closed_by_fact_id'],
    },
    executable: (
      String itemId,
      String subtaskTitle,
      String closedByFactId,
      String? closedAt,
    ) async {
      final userId = AgentCallToolContext.current!.state.metadata['userId'];
      final state = await ScheduleStateService.instance.completeSubtask(
        userId: userId,
        pendingId: itemId,
        subtaskTitle: subtaskTitle,
        closedByFactId: closedByFactId,
        closedAt: _parseScheduleDateTime(closedAt),
      );
      return 'Subtask completed. pending=${state.pending.length}';
    },
  );
}

Tool buildSetPresentationTool({bool stopAfterSetPresentation = false}) {
  return Tool(
    name: 'set_presentation',
    description:
        'Atomically update the cached magazine presentation in schedule_state. '
        'Use after any needed schedule state changes.',
    parameters: {
      'type': 'object',
      'properties': {
        'hero': {'type': 'object'},
        'editorial_intro': {'type': 'string'},
        'quote_blocks': {'type': 'array'},
        'timeline': {'type': 'array'},
      },
      'required': ['editorial_intro', 'timeline'],
    },
    executable: (
      Map<String, dynamic>? hero,
      String editorialIntro,
      List<dynamic>? quoteBlocks,
      List<dynamic>? timeline,
    ) async {
      final userId = AgentCallToolContext.current!.state.metadata['userId'];
      final state = await ScheduleStateService.instance.read(userId);
      final presentation = _normalizePresentationItemIds(
        SchedulePresentation(
          hero: hero == null ? null : SchedulePresentationHero.fromJson(hero),
          editorialIntro: editorialIntro,
          quoteBlocks: _parseQuoteBlocks(quoteBlocks),
          timeline: _parseTimelineDays(timeline),
        ),
        pending: state.pending,
      );
      final updated = await ScheduleStateService.instance.setPresentation(
        userId: userId,
        presentation: presentation,
      );
      return AgentToolResult(
        content: TextPart(
          'Presentation updated. pending=${updated.pending.length}',
        ),
        stopFlag: stopAfterSetPresentation,
      );
    },
  );
}

SchedulePendingItem? _latestPendingItemForSource(
  ScheduleState state, {
  required String sourceFactId,
  required String title,
}) {
  final matches = state.pending
      .where(
        (item) =>
            item.sourceFactIds.contains(sourceFactId) && item.title == title,
      )
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  if (matches.isEmpty) return null;
  return matches.first;
}

SchedulePresentation _normalizePresentationItemIds(
  SchedulePresentation presentation, {
  required List<SchedulePendingItem> pending,
}) {
  final pendingIds = {for (final item in pending) item.id};
  final sourceIdToItemId = <String, String>{
    for (final item in pending)
      for (final sourceFactId in item.sourceFactIds) sourceFactId: item.id,
  };

  String? normalizeId(String? id) {
    if (id == null || id.isEmpty) return null;
    if (pendingIds.contains(id)) return id;
    const prefix = 'pi_';
    if (id.startsWith(prefix)) {
      final sourceFactId = id.substring(prefix.length);
      return sourceIdToItemId[sourceFactId];
    }
    return sourceIdToItemId[id];
  }

  final normalizedHeroId = normalizeId(presentation.hero?.itemId);
  return SchedulePresentation(
    hero: presentation.hero == null || normalizedHeroId == null
        ? null
        : SchedulePresentationHero(
            itemId: normalizedHeroId,
            title: presentation.hero!.title,
            description: presentation.hero!.description,
          ),
    editorialIntro: presentation.editorialIntro,
    quoteBlocks: [
      for (final block in presentation.quoteBlocks)
        ScheduleQuoteBlock(
          title: block.title,
          content: block.content,
          priority: block.priority,
          itemId: normalizeId(block.itemId),
        ),
    ],
    timeline: [
      for (final day in presentation.timeline)
        ScheduleTimelineDay(
          dayLabel: day.dayLabel,
          dayDate: day.dayDate,
          itemIds: [
            for (final itemId in day.itemIds)
              if (normalizeId(itemId) case final normalized?) normalized,
          ],
        ),
    ],
  );
}

Tool buildSearchCompletedTool() {
  return Tool(
    name: 'search_completed',
    description:
        'Search completed schedule history by title text and/or closed_at lower bound.',
    parameters: {
      'type': 'object',
      'properties': {
        'query': {'type': 'string'},
        'since': {'type': 'string'},
        'limit': {'type': 'number'},
      },
    },
    executable: (String? query, String? since, num? limit) async {
      final userId = AgentCallToolContext.current!.state.metadata['userId'];
      final results = await ScheduleStateService.instance.searchCompleted(
        userId: userId,
        query: query,
        since: _parseScheduleDateTime(since),
        limit: limit?.toInt() ?? 20,
      );
      return jsonEncode(results.map((item) => item.toJson()).toList());
    },
  );
}

String? _nonEmptyString(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

List<ScheduleSubtask>? _parseScheduleSubtasks(List<dynamic>? raw) {
  if (raw == null) return null;
  final out = <ScheduleSubtask>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final title = item['title']?.toString().trim();
    if (title == null || title.isEmpty) continue;
    out.add(
      ScheduleSubtask(
        title: title,
        completed: _parseScheduleBool(item['completed']) == true,
        closedByFactId: item['closed_by_fact_id']?.toString(),
      ),
    );
  }
  return out;
}

List<ScheduleQuoteBlock> _parseQuoteBlocks(List<dynamic>? raw) {
  if (raw == null) return const <ScheduleQuoteBlock>[];
  return raw
      .whereType<Map>()
      .map(
        (item) => ScheduleQuoteBlock.fromJson(Map<String, dynamic>.from(item)),
      )
      .take(2)
      .toList();
}

List<ScheduleTimelineDay> _parseTimelineDays(List<dynamic>? raw) {
  if (raw == null) return const <ScheduleTimelineDay>[];
  return raw
      .whereType<Map>()
      .map(
        (item) => ScheduleTimelineDay.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList();
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
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text)?.toLocal();
}

bool? _parseScheduleBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  if (text.isEmpty) return null;
  return text == 'true' ||
      text == '1' ||
      text == 'yes' ||
      text == 'y' ||
      text == 'done' ||
      text == 'completed';
}
