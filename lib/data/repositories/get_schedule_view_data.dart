import 'package:memex/data/services/schedule_state_service.dart';
import 'package:memex/domain/models/schedule_state.dart';
import 'package:memex/domain/models/schedule_view_data.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('GetScheduleViewData');

Future<ScheduleViewData?> getScheduleViewData() async {
  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      _logger.warning('No user ID found, cannot get schedule view data');
      return null;
    }

    final state = await ScheduleStateService.instance.read(userId);
    if (state.pending.isEmpty &&
        state.completed.isEmpty &&
        state.presentation == null) {
      _logger.info('No schedule_state data found for user $userId');
      return null;
    }

    return scheduleStateToViewData(state);
  } catch (e) {
    _logger.severe('Failed to get schedule view data: $e');
    return null;
  }
}

Future<bool> scheduleViewDataNeedsRefresh({Duration? maxAge}) async {
  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) return true;

    final state = await ScheduleStateService.instance.read(userId);
    if (state.pending.isNotEmpty ||
        state.completed.isNotEmpty ||
        state.presentation != null) {
      final age = DateTime.now().difference(state.generatedAt);
      return age > (maxAge ?? const Duration(minutes: 30));
    }

    return true;
  } catch (e) {
    _logger.warning('Failed to check schedule view data freshness: $e');
    return true;
  }
}

ScheduleViewData scheduleStateToViewData(ScheduleState state) {
  final pendingById = {for (final item in state.pending) item.id: item};
  final presentation = state.presentation;
  final hero = presentation?.hero;

  return ScheduleViewData(
    id: 'schedule_state',
    generatedAt: state.generatedAt,
    timeRange: _timeRangeForState(state),
    hero: hero == null ? null : _heroForState(hero, pendingById),
    editorialIntro: presentation?.editorialIntro ?? '',
    quoteBlocks: (presentation?.quoteBlocks ?? const <ScheduleQuoteBlock>[])
        .map((block) => _quoteBlockForState(block, pendingById))
        .toList(),
    timeline: _pendingTimelineForState(state.pending),
    completed: state.completed.take(20).map(_completedForState).toList(),
  );
}

ScheduleViewHero? _heroForState(
  SchedulePresentationHero hero,
  Map<String, SchedulePendingItem> pendingById,
) {
  final item = pendingById[hero.itemId];
  if (item == null) return null;
  return ScheduleViewHero(
    cardId: _sourceCardId(item),
    title: hero.title,
    description: hero.description,
    startTime: item.startTime ?? item.dueAt,
    endTime: item.endTime,
    location: item.location,
    priority: item.priority,
  );
}

ScheduleViewQuoteBlock _quoteBlockForState(
  ScheduleQuoteBlock block,
  Map<String, SchedulePendingItem> pendingById,
) {
  final item = block.itemId == null ? null : pendingById[block.itemId];
  return ScheduleViewQuoteBlock(
    title: block.title,
    content: block.content,
    priority: block.priority,
    relatedCardId: item == null ? null : _sourceCardId(item),
  );
}

List<ScheduleViewTimelineDay> _pendingTimelineForState(
  List<SchedulePendingItem> pending,
) {
  final byDate = <String, List<SchedulePendingItem>>{};
  for (final item in pending) {
    final anchor = item.startTime ?? item.dueAt ?? item.createdAt;
    final date = _dateOnly(anchor);
    byDate.putIfAbsent(date, () => <SchedulePendingItem>[]).add(item);
  }

  final dates = byDate.keys.toList()..sort();
  return [
    for (final date in dates)
      ScheduleViewTimelineDay(
        dayLabel: _dayLabel(date),
        dayDate: DateTime.tryParse(date),
        items: byDate[date]!.map(_pendingForState).toList(),
      ),
  ];
}

ScheduleViewPendingItem _pendingForState(SchedulePendingItem item) {
  return ScheduleViewPendingItem(
    cardId: _sourceCardId(item),
    itemId: item.id,
    title: item.title,
    status: item.isTodo && item.subtasks.any((subtask) => subtask.completed)
        ? 'in_progress'
        : 'pending',
    type: item.isTodo ? 'task' : 'event',
    startTime: item.startTime ?? item.dueAt,
    endTime: item.endTime,
    location: item.location,
    priority: item.priority,
    description: item.description,
    subtasks: item.subtasks,
  );
}

ScheduleViewCompletedItem _completedForState(ScheduleCompletedItem item) {
  return ScheduleViewCompletedItem(
    cardId: item.sourceFactIds.isEmpty ? item.id : item.sourceFactIds.first,
    itemId: item.id,
    title: item.title,
    completedAt: item.closedAt,
  );
}

ScheduleViewTimeRange _timeRangeForState(ScheduleState state) {
  final anchors = <DateTime>[
    for (final item in state.pending)
      if (item.startTime ?? item.dueAt case final DateTime anchor) anchor,
    for (final item in state.completed.take(20)) item.closedAt,
  ]..sort();

  final from = anchors.isEmpty ? state.generatedAt : anchors.first;
  final to = anchors.isEmpty ? state.generatedAt : anchors.last;
  return ScheduleViewTimeRange(from: from, to: to);
}

String _sourceCardId(SchedulePendingItem item) {
  if (item.sourceFactIds.isEmpty) return item.id;
  return item.sourceFactIds.first;
}

String _dateOnly(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _dayLabel(String date) {
  final day = DateTime.tryParse(date);
  if (day == null) return date;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(day.year, day.month, day.day);
  final diff = target.difference(today).inDays;
  return switch (diff) {
    0 => '今天',
    1 => '明天',
    -1 => '昨天',
    _ => date,
  };
}
