import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';
import 'package:memex/domain/models/schedule_refresh_state.dart';
import 'package:memex/ui/schedule/models/schedule_item.dart';
import 'package:memex/ui/schedule/view_models/schedule_aggregator_view_model.dart';
import 'package:memex/utils/result.dart';

void main() {
  setUp(() async {
    EventBusService.instance.clearHandlers();
    await EventBusService.instance.connect();
  });

  tearDown(() {
    EventBusService.instance.clearHandlers();
  });

  group('ScheduleAggregatorViewModel', () {
    test('loads aggregation and exposes derived schedule items', () async {
      final now = DateTime.now();
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _aggregation(
          id: 'agg_today',
          taskTitle: '写测试',
          taskStartTime: now,
        ),
        listenToEvents: false,
      );

      await vm.loadAggregation();

      expect(vm.hasData, isTrue);
      expect(vm.error, isNull);
      expect(vm.items, hasLength(1));
      expect(vm.items.single.id, 'task-1');
      expect(vm.items.single.type, ScheduleItemType.todo);
      expect(vm.todayItems.single.id, 'task-1');

      vm.dispose();
    });

    test('reloads aggregation when schedule update event is emitted', () async {
      var loadCount = 0;
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async {
          loadCount += 1;
          return _aggregation(
            id: 'agg_$loadCount',
            taskTitle: '任务 $loadCount',
          );
        },
      );

      await vm.loadAggregation();
      expect(vm.aggregation?.id, 'agg_1');

      EventBusService.instance.emitEvent(
        ScheduleAggregationUpdatedMessage(aggregationId: 'agg_2'),
      );
      await _drainEventQueue();

      expect(loadCount, 2);
      expect(vm.aggregation?.id, 'agg_2');
      expect(vm.items.single.title, '任务 2');

      vm.dispose();
    });

    test('loads and updates dirty state from schedule dirty events', () async {
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _aggregation(),
        loadRefreshState: () async => ScheduleRefreshState(
          isDirty: true,
          reason: '新卡片可能影响日程',
          dirtySince: DateTime(2026, 4, 26, 9),
        ),
      );

      await vm.loadAggregation();

      expect(vm.isDirty, isTrue);
      expect(vm.dirtyReason, '新卡片可能影响日程');

      EventBusService.instance.emitEvent(
        ScheduleAggregationDirtyMessage(
          isDirty: false,
          cardIds: const ['task-1'],
        ),
      );
      await _drainEventQueue();

      expect(vm.isDirty, isFalse);
      expect(vm.dirtyReason, isNull);

      vm.dispose();
    });

    test('refresh triggers agent and reloads aggregation on success', () async {
      var refreshCount = 0;
      var loadCount = 0;
      final vm = ScheduleAggregatorViewModel(
        refreshAggregation: () async {
          refreshCount += 1;
          return const Ok<void>.v();
        },
        loadAggregation: () async {
          loadCount += 1;
          return _aggregation(id: 'fresh');
        },
        refreshReloadDelay: Duration.zero,
        listenToEvents: false,
      );

      await vm.refreshAggregation();

      expect(refreshCount, 1);
      expect(loadCount, 1);
      expect(vm.aggregation?.id, 'fresh');
      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);

      vm.dispose();
    });

    test('refresh does not reload when agent trigger fails', () async {
      var loadCount = 0;
      final vm = ScheduleAggregatorViewModel(
        refreshAggregation: () async => Error<void>(Exception('no model')),
        loadAggregation: () async {
          loadCount += 1;
          return _aggregation(id: 'should_not_load');
        },
        refreshReloadDelay: Duration.zero,
        listenToEvents: false,
      );

      await vm.refreshAggregation();

      expect(loadCount, 0);
      expect(vm.hasData, isFalse);
      expect(vm.isLoading, isFalse);
      expect(vm.error, contains('no model'));

      vm.dispose();
    });

    test('ensureFresh loads missing data but skips reload when data is fresh',
        () async {
      var loadCount = 0;
      final checkedMaxAges = <Duration?>[];
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async {
          loadCount += 1;
          return _aggregation(id: 'agg_$loadCount');
        },
        needsRefresh: ({maxAge}) async {
          checkedMaxAges.add(maxAge);
          return false;
        },
        listenToEvents: false,
      );

      const maxAge = Duration(minutes: 5);
      await vm.ensureFresh(maxAge: maxAge);
      await vm.ensureFresh(maxAge: maxAge);

      expect(loadCount, 1);
      expect(checkedMaxAges, [maxAge, maxAge]);
      expect(vm.aggregation?.id, 'agg_1');

      vm.dispose();
    });

    test('ensureFresh reloads existing data when it is stale', () async {
      var loadCount = 0;
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async {
          loadCount += 1;
          return _aggregation(id: 'agg_$loadCount');
        },
        needsRefresh: ({maxAge}) async => true,
        listenToEvents: false,
      );

      await vm.loadAggregation();
      await vm.ensureFresh();

      expect(loadCount, 2);
      expect(vm.aggregation?.id, 'agg_2');

      vm.dispose();
    });

    test('toggleCompletion writes the real task ui_config optimistically',
        () async {
      String? updatedCardId;
      int? updatedConfigIndex;
      Map<String, dynamic>? updatedData;
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _aggregation(),
        fetchCardDetail: (_) async => _cardDetailWithTaskConfig(),
        updateCardUiConfig: (cardId, configIndex, data) async {
          updatedCardId = cardId;
          updatedConfigIndex = configIndex;
          updatedData = data;
          return true;
        },
        listenToEvents: false,
      );

      await vm.loadAggregation();
      final item = vm.items.single;

      final toggle = vm.toggleCompletion(item);
      expect(vm.items.single.status, ScheduleItemStatus.completed);
      await toggle;

      expect(updatedCardId, 'task-1');
      expect(updatedConfigIndex, 1);
      expect(updatedData, {'is_completed': true});
      expect(vm.error, isNull);

      vm.dispose();
    });

    test('toggleCompletion reverts optimistic state when write fails',
        () async {
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _aggregation(),
        fetchCardDetail: (_) async => _cardDetailWithTaskConfig(),
        updateCardUiConfig: (_, __, ___) async => false,
        listenToEvents: false,
      );

      await vm.loadAggregation();
      final item = vm.items.single;

      await vm.toggleCompletion(item);

      expect(vm.items.single.status, ScheduleItemStatus.pending);
      expect(vm.error, 'Failed to update task');

      vm.dispose();
    });

    test('toggleCompletion ignores event items', () async {
      var didFetchDetail = false;
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _eventAggregation(),
        fetchCardDetail: (_) async {
          didFetchDetail = true;
          return _cardDetailWithTaskConfig();
        },
        listenToEvents: false,
      );

      await vm.loadAggregation();
      await vm.toggleCompletion(vm.items.single);

      expect(vm.items.single.type, ScheduleItemType.event);
      expect(vm.items.single.status, ScheduleItemStatus.pending);
      expect(didFetchDetail, isFalse);

      vm.dispose();
    });

    test('toggleCompletion reverts when the card has no task ui_config',
        () async {
      var didUpdate = false;
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _aggregation(),
        fetchCardDetail: (_) async => _cardDetailWithoutTaskConfig(),
        updateCardUiConfig: (_, __, ___) async {
          didUpdate = true;
          return true;
        },
        listenToEvents: false,
      );

      await vm.loadAggregation();
      await vm.toggleCompletion(vm.items.single);

      expect(didUpdate, isFalse);
      expect(vm.items.single.status, ScheduleItemStatus.pending);
      expect(vm.error, 'Failed to update task');

      vm.dispose();
    });
  });
}

ScheduleAggregationModel _aggregation({
  String id = 'agg',
  String taskTitle = '待办事项',
  DateTime? taskStartTime,
}) {
  final start = taskStartTime ?? DateTime(2026, 4, 26, 10);
  return ScheduleAggregationModel(
    id: id,
    generatedAt: DateTime(2026, 4, 26, 8),
    timeRange: TimeRange(
      from: DateTime(2026, 4, 26),
      to: DateTime(2026, 5, 3),
    ),
    timeline: [
      TimelineDay(
        dayLabel: 'Today',
        dayDate: DateTime(start.year, start.month, start.day),
        items: [
          TimelineItem(
            cardId: 'task-1',
            title: taskTitle,
            status: 'pending',
            startTime: start,
            type: 'task',
            priority: 2,
          ),
        ],
      ),
    ],
  );
}

ScheduleAggregationModel _eventAggregation() {
  return ScheduleAggregationModel(
    id: 'event_agg',
    generatedAt: DateTime(2026, 4, 26, 8),
    timeRange: TimeRange(
      from: DateTime(2026, 4, 26),
      to: DateTime(2026, 5, 3),
    ),
    timeline: [
      TimelineDay(
        dayLabel: 'Today',
        dayDate: DateTime(2026, 4, 26),
        items: [
          TimelineItem(
            cardId: 'event-1',
            title: '发布会',
            status: 'pending',
            startTime: DateTime(2026, 4, 26, 14),
            type: 'event',
          ),
        ],
      ),
    ],
  );
}

CardDetailModel _cardDetailWithTaskConfig() {
  return CardDetailModel.fromJson(<String, dynamic>{
    'id': 'task-1',
    'title': '待办事项',
    'timestamp': 1777188000,
    'ui_configs': <Map<String, dynamic>>[
      <String, dynamic>{
        'template_id': 'event',
        'data': <String, dynamic>{},
      },
      <String, dynamic>{
        'template_id': 'task',
        'data': <String, dynamic>{'is_completed': false},
      },
    ],
  });
}

CardDetailModel _cardDetailWithoutTaskConfig() {
  return CardDetailModel.fromJson(<String, dynamic>{
    'id': 'task-1',
    'title': '待办事项',
    'timestamp': 1777188000,
    'ui_configs': <Map<String, dynamic>>[
      <String, dynamic>{
        'template_id': 'event',
        'data': <String, dynamic>{},
      },
    ],
  });
}

Future<void> _drainEventQueue() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
