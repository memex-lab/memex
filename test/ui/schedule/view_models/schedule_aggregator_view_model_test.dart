import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/schedule_state.dart' show ScheduleSubtask;
import 'package:memex/domain/models/schedule_view_data.dart';
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
        loadAggregation: () async =>
            _aggregation(id: 'agg_today', taskTitle: '写测试', taskStartTime: now),
        listenToEvents: false,
      );

      expect(vm.hasLoaded, isFalse);
      await vm.loadAggregation();

      expect(vm.hasLoaded, isTrue);
      expect(vm.hasData, isTrue);
      expect(vm.error, isNull);
      expect(vm.items, hasLength(1));
      expect(vm.items.single.sourceFactId, 'task-1');
      expect(vm.items.single.type, ScheduleItemType.todo);
      expect(vm.todayItems.single.sourceFactId, 'task-1');

      vm.dispose();
    });

    test('reloads aggregation when schedule update event is emitted', () async {
      var loadCount = 0;
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async {
          loadCount += 1;
          return _aggregation(id: 'agg_$loadCount', taskTitle: '任务 $loadCount');
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

    test(
      'ensureFresh loads missing data but skips reload when data is fresh',
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
      },
    );

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

    test(
      'toggleCompletion completes the canonical schedule item optimistically',
      () async {
        String? completedItemId;
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregation(),
          completeScheduleItem: (itemId) async {
            completedItemId = itemId;
            return const Ok.v();
          },
          listenToEvents: false,
        );

        await vm.loadAggregation();
        final item = vm.items.single;

        final toggle = vm.toggleCompletion(item);
        expect(vm.items.single.status, ScheduleItemStatus.completed);
        await toggle;

        expect(completedItemId, 'schedule-task-1');
        expect(vm.error, isNull);

        vm.dispose();
      },
    );

    test(
      'toggleCompletion completes grouped tasks through schedule state',
      () async {
        String? completedItemId;
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(),
          completeScheduleItem: (itemId) async {
            completedItemId = itemId;
            return const Ok.v();
          },
          listenToEvents: false,
        );

        await vm.loadAggregation();
        final toggle = vm.toggleCompletion(vm.items.single);
        expect(vm.items.single.status, ScheduleItemStatus.completed);
        expect(vm.items.single.subtasks.map((subtask) => subtask.completed), [
          true,
          true,
        ]);
        await toggle;

        expect(completedItemId, 'schedule-task-1');
        expect(vm.error, isNull);

        vm.dispose();
      },
    );

    test(
      'toggleCompletion reverts optimistic state when write fails',
      () async {
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(),
          completeScheduleItem: (_) async => Error(Exception('failed')),
          listenToEvents: false,
        );

        await vm.loadAggregation();
        await vm.toggleCompletion(vm.items.single);

        expect(vm.items.single.status, ScheduleItemStatus.pending);
        expect(vm.items.single.subtasks.map((subtask) => subtask.completed), [
          false,
          false,
        ]);
        expect(vm.error, 'Failed to update task');

        vm.dispose();
      },
    );

    test('toggleCompletion reverts plain tasks when write fails', () async {
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _aggregation(),
        completeScheduleItem: (_) async => Error(Exception('failed')),
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
      var didComplete = false;
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _eventAggregation(),
        completeScheduleItem: (_) async {
          didComplete = true;
          return const Ok.v();
        },
        listenToEvents: false,
      );

      await vm.loadAggregation();
      await vm.toggleCompletion(vm.items.single);

      expect(vm.items.single.type, ScheduleItemType.event);
      expect(vm.items.single.status, ScheduleItemStatus.pending);
      expect(didComplete, isFalse);

      vm.dispose();
    });

    test('restoreCompletedItem writes canonical restore and reloads', () async {
      String? restoredItemId;
      var loadCount = 0;
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async {
          loadCount += 1;
          return _completedAggregation(id: 'completed_$loadCount');
        },
        restoreScheduleItem: (itemId) async {
          restoredItemId = itemId;
          return const Ok.v();
        },
        listenToEvents: false,
      );

      await vm.loadAggregation();
      await vm.restoreCompletedItem('schedule-task-1');

      expect(restoredItemId, 'schedule-task-1');
      expect(loadCount, 2);
      expect(vm.error, isNull);

      vm.dispose();
    });

    test('toggleSubtask writes one subtask to schedule state', () async {
      String? updatedItemId;
      String? updatedSubtaskTitle;
      bool? updatedCompleted;
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _aggregationWithSubtasks(),
        setScheduleSubtaskCompletion: (itemId, title, completed) async {
          updatedItemId = itemId;
          updatedSubtaskTitle = title;
          updatedCompleted = completed;
          return const Ok.v();
        },
        listenToEvents: false,
      );

      await vm.loadAggregation();
      final item = vm.items.single;

      final toggle = vm.toggleSubtask(item, 0);
      expect(vm.items.single.status, ScheduleItemStatus.inProgress);
      expect(vm.items.single.subtasks.first.completed, isTrue);
      await toggle;

      expect(updatedItemId, 'schedule-task-1');
      expect(updatedSubtaskTitle, 'Collect documents');
      expect(updatedCompleted, isTrue);
      expect(vm.error, isNull);

      vm.dispose();
    });

    test(
      'toggleSubtask marks parent completed when last subtask is done',
      () async {
        bool? updatedCompleted;
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(
            subtasks: const [
              ScheduleSubtask(title: 'Collect documents', completed: true),
              ScheduleSubtask(title: 'Submit form'),
            ],
          ),
          setScheduleSubtaskCompletion: (_, __, completed) async {
            updatedCompleted = completed;
            return const Ok.v();
          },
          listenToEvents: false,
        );

        await vm.loadAggregation();
        await vm.toggleSubtask(vm.items.single, 1);

        expect(vm.items.single.status, ScheduleItemStatus.completed);
        expect(updatedCompleted, isTrue);

        vm.dispose();
      },
    );

    test(
      'toggleSubtask ignores invalid indexes without writing state',
      () async {
        var didWrite = false;
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(),
          setScheduleSubtaskCompletion: (_, __, ___) async {
            didWrite = true;
            return const Ok.v();
          },
          listenToEvents: false,
        );

        await vm.loadAggregation();
        await vm.toggleSubtask(vm.items.single, 99);

        expect(didWrite, isFalse);
        expect(vm.items.single.status, ScheduleItemStatus.pending);

        vm.dispose();
      },
    );

    test('toggleSubtask reverts optimistic state when write fails', () async {
      final vm = ScheduleAggregatorViewModel(
        loadAggregation: () async => _aggregationWithSubtasks(),
        setScheduleSubtaskCompletion: (_, __, ___) async =>
            Error(Exception('failed')),
        listenToEvents: false,
      );

      await vm.loadAggregation();
      await vm.toggleSubtask(vm.items.single, 1);

      expect(vm.items.single.status, ScheduleItemStatus.pending);
      expect(vm.items.single.subtasks.map((subtask) => subtask.completed), [
        false,
        false,
      ]);
      expect(vm.error, 'Failed to update task');

      vm.dispose();
    });
  });
}

ScheduleViewData _aggregation({
  String id = 'agg',
  String taskTitle = '待办事项',
  DateTime? taskStartTime,
}) {
  final start = taskStartTime ?? DateTime(2026, 4, 26, 10);
  return ScheduleViewData(
    id: id,
    generatedAt: DateTime(2026, 4, 26, 8),
    timeRange: ScheduleViewTimeRange(
      from: DateTime(2026, 4, 26),
      to: DateTime(2026, 5, 3),
    ),
    timeline: [
      ScheduleViewTimelineDay(
        dayLabel: 'Today',
        dayDate: DateTime(start.year, start.month, start.day),
        items: [
          ScheduleViewPendingItem(
            cardId: 'task-1',
            itemId: 'schedule-task-1',
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

ScheduleViewData _aggregationWithSubtasks({
  List<ScheduleSubtask> subtasks = const [
    ScheduleSubtask(title: 'Collect documents'),
    ScheduleSubtask(title: 'Submit form'),
  ],
}) {
  return ScheduleViewData(
    id: 'agg_subtasks',
    generatedAt: DateTime(2026, 4, 26, 8),
    timeRange: ScheduleViewTimeRange(
      from: DateTime(2026, 4, 26),
      to: DateTime(2026, 5, 3),
    ),
    timeline: [
      ScheduleViewTimelineDay(
        dayLabel: 'Today',
        dayDate: DateTime(2026, 4, 26),
        items: [
          ScheduleViewPendingItem(
            cardId: 'task-1',
            itemId: 'schedule-task-1',
            title: 'Visa checklist',
            status: 'pending',
            startTime: DateTime(2026, 4, 26, 10),
            type: 'task',
            priority: 2,
            subtasks: subtasks,
          ),
        ],
      ),
    ],
  );
}

ScheduleViewData _eventAggregation() {
  return ScheduleViewData(
    id: 'event_agg',
    generatedAt: DateTime(2026, 4, 26, 8),
    timeRange: ScheduleViewTimeRange(
      from: DateTime(2026, 4, 26),
      to: DateTime(2026, 5, 3),
    ),
    timeline: [
      ScheduleViewTimelineDay(
        dayLabel: 'Today',
        dayDate: DateTime(2026, 4, 26),
        items: [
          ScheduleViewPendingItem(
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

ScheduleViewData _completedAggregation({String id = 'completed_agg'}) {
  return ScheduleViewData(
    id: id,
    generatedAt: DateTime(2026, 4, 26, 8),
    timeRange: ScheduleViewTimeRange(
      from: DateTime(2026, 4, 26),
      to: DateTime(2026, 5, 3),
    ),
    completed: [
      ScheduleViewCompletedItem(
        cardId: 'task-1',
        itemId: 'schedule-task-1',
        title: 'Submitted visa form',
        completedAt: DateTime(2026, 4, 26, 12),
      ),
    ],
  );
}

Future<void> _drainEventQueue() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
