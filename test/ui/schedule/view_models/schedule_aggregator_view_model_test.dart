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
        loadAggregation: () async =>
            _aggregation(id: 'agg_today', taskTitle: '写测试', taskStartTime: now),
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
      'toggleCompletion writes the real task ui_config optimistically',
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
      },
    );

    test(
      'toggleCompletion updates every persisted subtask for grouped tasks',
      () async {
        Map<String, dynamic>? updatedData;
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(),
          fetchCardDetail: (_) async => _cardDetailWithTaskConfig(
            subtasks: [
              {'title': 'Collect documents', 'completed': false},
              {'title': 'Submit form', 'completed': false, 'note': 'keep me'},
            ],
          ),
          updateCardUiConfig: (_, __, data) async {
            updatedData = data;
            return true;
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

        expect(updatedData?['is_completed'], isTrue);
        expect(updatedData?['subtasks'], [
          {'title': 'Collect documents', 'completed': true},
          {'title': 'Submit form', 'completed': true, 'note': 'keep me'},
        ]);
        expect(vm.error, isNull);

        vm.dispose();
      },
    );

    test(
      'toggleCompletion reverts grouped tasks when card subtasks are stale',
      () async {
        var didUpdate = false;
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(),
          fetchCardDetail: (_) async => _cardDetailWithTaskConfig(
            subtasks: [
              {'title': 'Collect documents', 'completed': false},
            ],
          ),
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
        expect(vm.items.single.subtasks.map((subtask) => subtask.completed), [
          false,
          false,
        ]);
        expect(vm.error, 'Failed to update task');

        vm.dispose();
      },
    );

    test(
      'toggleCompletion reverts optimistic state when write fails',
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
      },
    );

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

    test(
      'toggleSubtask writes one subtask and derives partial status',
      () async {
        String? updatedCardId;
        Map<String, dynamic>? updatedData;
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(),
          fetchCardDetail: (_) async => _cardDetailWithTaskConfig(
            subtasks: [
              {'title': 'Collect documents', 'completed': false},
              {'title': 'Submit form', 'completed': false},
            ],
          ),
          updateCardUiConfig: (cardId, _, data) async {
            updatedCardId = cardId;
            updatedData = data;
            return true;
          },
          listenToEvents: false,
        );

        await vm.loadAggregation();
        final item = vm.items.single;

        final toggle = vm.toggleSubtask(item, 0);
        expect(vm.items.single.status, ScheduleItemStatus.inProgress);
        expect(vm.items.single.subtasks.first.completed, isTrue);
        await toggle;

        expect(updatedCardId, 'task-1');
        expect(updatedData?['is_completed'], isFalse);
        expect(updatedData?['subtasks'], [
          {'title': 'Collect documents', 'completed': true},
          {'title': 'Submit form', 'completed': false},
        ]);
        expect(vm.error, isNull);

        vm.dispose();
      },
    );

    test(
      'toggleSubtask marks parent completed when last subtask is done',
      () async {
        Map<String, dynamic>? updatedData;
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(
            subtasks: const [
              ScheduleSubtask(title: 'Collect documents', completed: true),
              ScheduleSubtask(title: 'Submit form'),
            ],
          ),
          fetchCardDetail: (_) async => _cardDetailWithTaskConfig(
            subtasks: [
              {'title': 'Collect documents', 'completed': true},
              {'title': 'Submit form', 'completed': false},
            ],
          ),
          updateCardUiConfig: (_, __, data) async {
            updatedData = data;
            return true;
          },
          listenToEvents: false,
        );

        await vm.loadAggregation();
        await vm.toggleSubtask(vm.items.single, 1);

        expect(vm.items.single.status, ScheduleItemStatus.completed);
        expect(updatedData?['is_completed'], isTrue);
        expect(updatedData?['subtasks'], [
          {'title': 'Collect documents', 'completed': true},
          {'title': 'Submit form', 'completed': true},
        ]);

        vm.dispose();
      },
    );

    test(
      'toggleSubtask ignores invalid indexes without reading the card',
      () async {
        var didFetch = false;
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(),
          fetchCardDetail: (_) async {
            didFetch = true;
            return _cardDetailWithTaskConfig();
          },
          listenToEvents: false,
        );

        await vm.loadAggregation();
        await vm.toggleSubtask(vm.items.single, 99);

        expect(didFetch, isFalse);
        expect(vm.items.single.status, ScheduleItemStatus.pending);

        vm.dispose();
      },
    );

    test(
      'toggleSubtask reverts optimistic state for stale card detail',
      () async {
        final vm = ScheduleAggregatorViewModel(
          loadAggregation: () async => _aggregationWithSubtasks(),
          fetchCardDetail: (_) async => _cardDetailWithTaskConfig(
            subtasks: [
              {'title': 'Collect documents', 'completed': false},
            ],
          ),
          updateCardUiConfig: (_, __, ___) async => true,
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
      },
    );

    test(
      'toggleCompletion reverts when the card has no task ui_config',
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
      },
    );
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
    timeRange: TimeRange(from: DateTime(2026, 4, 26), to: DateTime(2026, 5, 3)),
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

ScheduleAggregationModel _aggregationWithSubtasks({
  List<ScheduleSubtask> subtasks = const [
    ScheduleSubtask(title: 'Collect documents'),
    ScheduleSubtask(title: 'Submit form'),
  ],
}) {
  return ScheduleAggregationModel(
    id: 'agg_subtasks',
    generatedAt: DateTime(2026, 4, 26, 8),
    timeRange: TimeRange(from: DateTime(2026, 4, 26), to: DateTime(2026, 5, 3)),
    timeline: [
      TimelineDay(
        dayLabel: 'Today',
        dayDate: DateTime(2026, 4, 26),
        items: [
          TimelineItem(
            cardId: 'task-1',
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

ScheduleAggregationModel _eventAggregation() {
  return ScheduleAggregationModel(
    id: 'event_agg',
    generatedAt: DateTime(2026, 4, 26, 8),
    timeRange: TimeRange(from: DateTime(2026, 4, 26), to: DateTime(2026, 5, 3)),
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

CardDetailModel _cardDetailWithTaskConfig({
  List<Map<String, dynamic>>? subtasks,
}) {
  return CardDetailModel.fromJson(<String, dynamic>{
    'id': 'task-1',
    'title': '待办事项',
    'timestamp': 1777188000,
    'ui_configs': <Map<String, dynamic>>[
      <String, dynamic>{'template_id': 'event', 'data': <String, dynamic>{}},
      <String, dynamic>{
        'template_id': 'task',
        'data': <String, dynamic>{
          'is_completed': false,
          if (subtasks != null) 'subtasks': subtasks,
        },
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
      <String, dynamic>{'template_id': 'event', 'data': <String, dynamic>{}},
    ],
  });
}

Future<void> _drainEventQueue() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
