import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/schedule_state.dart' show ScheduleSubtask;
import 'package:memex/domain/models/schedule_view_data.dart';
import 'package:memex/ui/schedule/models/schedule_item.dart';

void main() {
  group('ScheduleItem', () {
    test('copyWith creates a new instance with updated fields', () {
      final item = ScheduleItem(
        sourceFactId: 'test-1',
        title: 'Original Title',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 2,
        subtasks: const [ScheduleSubtask(title: 'Draft')],
      );

      final updated = item.copyWith(
        status: ScheduleItemStatus.completed,
        completedAt: DateTime(2026, 4, 23, 10, 30),
      );

      expect(updated.sourceFactId, 'test-1');
      expect(updated.title, 'Original Title');
      expect(updated.status, ScheduleItemStatus.completed);
      expect(updated.completedAt, isNotNull);
      expect(updated.priority, 2);
      expect(updated.subtasks.single.title, 'Draft');
      // Original should be unchanged
      expect(item.status, ScheduleItemStatus.pending);
    });

    test('copyWith preserves values when null is passed', () {
      final item = ScheduleItem(
        sourceFactId: 'test-1',
        title: 'Title',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
      );

      final updated = item.copyWith();

      expect(updated.sourceFactId, 'test-1');
      expect(updated.status, ScheduleItemStatus.pending);
      expect(updated.type, ScheduleItemType.event);
    });

    test('copyWith can clear completedAt when reopening a task', () {
      final item = ScheduleItem(
        sourceFactId: 'test-1',
        title: 'Title',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.completed,
        completedAt: DateTime(2026, 4, 26, 10),
      );

      final updated = item.copyWith(
        status: ScheduleItemStatus.pending,
        clearCompletedAt: true,
      );

      expect(updated.status, ScheduleItemStatus.pending);
      expect(updated.completedAt, isNull);
    });

    test('event item has correct defaults', () {
      final event = ScheduleItem(
        sourceFactId: 'event-1',
        title: 'Meeting',
        type: ScheduleItemType.event,
        startTime: DateTime(2026, 4, 23, 14, 0),
        endTime: DateTime(2026, 4, 23, 15, 0),
      );

      expect(event.status, ScheduleItemStatus.pending);
      expect(event.tags, isEmpty);
      expect(event.relatedEvents, isEmpty);
    });

    test('builds real UI items from schedule view data', () {
      final viewData = ScheduleViewData(
        id: 'schedule_state',
        generatedAt: DateTime.parse('2026-04-26T08:00:00+08:00'),
        timeRange: ScheduleViewTimeRange(
          from: DateTime(2026, 4, 26),
          to: DateTime(2026, 5, 3),
        ),
        hero: ScheduleViewHero(
          cardId: '2026/04/26.md#ts_100',
          title: '产品发布会',
          description: '本周最重要的外部日程',
          startTime: DateTime.parse('2026-04-26T14:00:00+08:00'),
          endTime: DateTime.parse('2026-04-26T16:00:00+08:00'),
          location: '总部大礼堂',
          priority: 3,
        ),
        timeline: [
          ScheduleViewTimelineDay(
            dayLabel: 'Today',
            dayDate: DateTime(2026, 4, 26),
            items: [
              const ScheduleViewPendingItem(
                cardId: '2026/04/26.md#ts_100',
                title: '产品发布会',
                status: 'pending',
                type: 'event',
                priority: 3,
              ),
              ScheduleViewPendingItem(
                cardId: '101',
                title: '上线检查清单',
                status: 'in_progress',
                startTime: DateTime.parse('2026-04-26T10:00:00+08:00'),
                type: 'task',
                priority: 2,
                subtasks: const [
                  ScheduleSubtask(title: '检查环境变量', completed: true),
                  ScheduleSubtask(title: '确认灰度开关'),
                ],
              ),
            ],
          ),
        ],
        completed: [
          ScheduleViewCompletedItem(
            cardId: '2026/04/25.md#ts_88',
            title: '完成彩排',
            completedAt: DateTime.parse('2026-04-25T19:30:00+08:00'),
          ),
        ],
      );
      final items = ScheduleItem.fromViewData(viewData);

      expect(items, hasLength(3));

      final launch = items.singleWhere(
        (item) => item.sourceFactId == '2026/04/26.md#ts_100',
      );
      expect(launch.type, ScheduleItemType.event);
      expect(launch.priority, 3);
      expect(launch.location, '总部大礼堂');
      expect(launch.description, '本周最重要的外部日程');

      final checklist = items.singleWhere((item) => item.sourceFactId == '101');
      expect(checklist.type, ScheduleItemType.todo);
      expect(checklist.status, ScheduleItemStatus.inProgress);
      expect(checklist.priority, 2);
      expect(checklist.subtasks, hasLength(2));
      expect(checklist.subtasks.first.completed, isTrue);

      final rehearsal = items.singleWhere(
        (item) => item.sourceFactId == '2026/04/25.md#ts_88',
      );
      expect(rehearsal.status, ScheduleItemStatus.completed);
      expect(rehearsal.completedAt?.toUtc(), DateTime.utc(2026, 4, 25, 11, 30));
    });

    test('keeps hero and timeline items separate when only source matches', () {
      final aggregation = ScheduleViewData(
        id: 'schedule_state',
        generatedAt: DateTime.parse('2026-04-26T08:00:00+08:00'),
        timeRange: ScheduleViewTimeRange(
          from: DateTime(2026, 4, 26),
          to: DateTime(2026, 5, 3),
        ),
        hero: ScheduleViewHero(
          cardId: 'deadline-1',
          title: '融资材料截止',
          description: '今天最需要守住的交付',
          startTime: DateTime.parse('2026-04-26T18:00:00+08:00'),
          location: '线上提交',
          priority: 3,
        ),
        timeline: [
          ScheduleViewTimelineDay(
            dayLabel: 'Today',
            dayDate: DateTime(2026, 4, 26),
            items: [
              const ScheduleViewPendingItem(
                cardId: 'deadline-1',
                itemId: 'pi_deadline_1',
                title: '融资材料截止',
                status: ' in-progress ',
                type: 'task',
                priority: 2,
              ),
            ],
          ),
        ],
      );

      final items = ScheduleItem.fromViewData(aggregation);
      final task = items.singleWhere((item) => item.itemId == 'pi_deadline_1');
      final hero = items.singleWhere((item) => item.itemId == 'deadline-1');

      expect(task.type, ScheduleItemType.todo);
      expect(task.sourceFactId, 'deadline-1');
      expect(task.status, ScheduleItemStatus.inProgress);
      expect(task.sourceType, 'task');
      expect(task.priority, 2);
      expect(hero.description, '今天最需要守住的交付');
      expect(hero.location, '线上提交');
      expect(hero.priority, 3);
    });

    test('completed section wins over duplicate pending timeline items', () {
      final aggregation = ScheduleViewData(
        id: 'schedule_state',
        generatedAt: DateTime.parse('2026-04-26T08:00:00+08:00'),
        timeRange: ScheduleViewTimeRange(
          from: DateTime(2026, 4, 26),
          to: DateTime(2026, 5, 3),
        ),
        timeline: [
          ScheduleViewTimelineDay(
            dayLabel: 'Today',
            dayDate: DateTime(2026, 4, 26),
            items: const [
              ScheduleViewPendingItem(
                cardId: 'task-done',
                title: '同步发布稿',
                status: 'overdue',
                type: 'task',
              ),
            ],
          ),
        ],
        completed: [
          ScheduleViewCompletedItem(
            cardId: 'task-done',
            title: '同步发布稿',
            completedAt: DateTime.parse('2026-04-26T11:20:00+08:00'),
          ),
        ],
      );

      final item = ScheduleItem.fromViewData(aggregation).single;

      expect(item.type, ScheduleItemType.todo);
      expect(item.status, ScheduleItemStatus.completed);
      expect(item.completedAt?.toUtc(), DateTime.utc(2026, 4, 26, 3, 20));
    });

    test('preserves distinct pending items from the same source fact', () {
      final aggregation = ScheduleViewData(
        id: 'schedule_state',
        generatedAt: DateTime.parse('2026-04-26T08:00:00+08:00'),
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
                itemId: 'pi_dentist',
                cardId: '2026/04/26.md#ts_1',
                title: 'Dentist at 10',
                type: 'event',
                startTime: DateTime(2026, 4, 26, 10),
              ),
              const ScheduleViewPendingItem(
                itemId: 'pi_milk',
                cardId: '2026/04/26.md#ts_1',
                title: 'Buy milk',
                type: 'task',
              ),
            ],
          ),
        ],
      );

      final items = ScheduleItem.fromViewData(aggregation);

      expect(items, hasLength(2));
      expect(items.map((item) => item.itemId), ['pi_milk', 'pi_dentist']);
      expect(
        items.map((item) => item.sourceFactId).toSet(),
        {'2026/04/26.md#ts_1'},
      );
    });

    test('derives task status from subtask progress conservatively', () {
      final pending = ScheduleItem.deriveTodoStatus(const [
        ScheduleSubtask(title: 'A'),
        ScheduleSubtask(title: 'B'),
      ], fallback: ScheduleItemStatus.overdue);
      final partial = ScheduleItem.deriveTodoStatus(const [
        ScheduleSubtask(title: 'A', completed: true),
        ScheduleSubtask(title: 'B'),
      ], fallback: ScheduleItemStatus.pending);
      final completed = ScheduleItem.deriveTodoStatus(const [
        ScheduleSubtask(title: 'A', completed: true),
        ScheduleSubtask(title: 'B', completed: true),
      ], fallback: ScheduleItemStatus.pending);
      final parentCompletedWins = ScheduleItem.deriveTodoStatus(const [
        ScheduleSubtask(title: 'A'),
      ], fallback: ScheduleItemStatus.completed);

      expect(pending, ScheduleItemStatus.overdue);
      expect(partial, ScheduleItemStatus.inProgress);
      expect(completed, ScheduleItemStatus.completed);
      expect(parentCompletedWins, ScheduleItemStatus.completed);
    });

    test('assigns stable fallback ids and sorts undated items by title', () {
      final aggregation = ScheduleViewData(
        id: 'agg_missing_ids',
        generatedAt: DateTime(2026, 4, 26, 8),
        timeRange: ScheduleViewTimeRange(
          from: DateTime(2026, 4, 26),
          to: DateTime(2026, 5, 3),
        ),
        timeline: [
          const ScheduleViewTimelineDay(
            dayLabel: 'Today',
            items: [
              ScheduleViewPendingItem(
                cardId: '',
                title: 'B task',
                status: 'pending',
                type: 'task',
              ),
              ScheduleViewPendingItem(
                cardId: '',
                title: 'A event',
                status: 'pending',
                type: 'event',
              ),
            ],
          ),
        ],
      );

      final items = ScheduleItem.fromViewData(aggregation);

      expect(items.map((item) => item.sourceFactId), [
        'schedule_item_1',
        'schedule_item_0',
      ]);
      expect(items.map((item) => item.title), ['A event', 'B task']);
    });
  });

  group('ScheduleItemStatus', () {
    test('has correct enum values', () {
      expect(ScheduleItemStatus.values.length, 4);
      expect(ScheduleItemStatus.pending.name, 'pending');
      expect(ScheduleItemStatus.completed.name, 'completed');
      expect(ScheduleItemStatus.inProgress.name, 'inProgress');
      expect(ScheduleItemStatus.overdue.name, 'overdue');
    });
  });

  group('RelatedEvent', () {
    test('stores all fields correctly', () {
      final related = RelatedEvent(
        id: 're-1',
        title: 'Created card',
        type: 'card',
        timestamp: DateTime(2026, 4, 23, 10, 0),
      );

      expect(related.id, 're-1');
      expect(related.title, 'Created card');
      expect(related.type, 'card');
      expect(related.timestamp.hour, 10);
    });
  });
}
