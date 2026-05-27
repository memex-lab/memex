import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/get_schedule_view_data.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/schedule_state_service.dart';
import 'package:memex/domain/models/schedule_state.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _userId = 'schedule_view_data_test_user';

void main() {
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser(_userId);
    await UserStorage.setLocale(const Locale('en'));
    tempDir = await Directory.systemTemp.createTemp(
      'memex_get_schedule_view_data_',
    );
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('reads pending and completed directly from schedule_state', () async {
    await ScheduleStateService.instance.write(
      _userId,
      ScheduleState(
        generatedAt: DateTime.parse('2026-05-24T09:00:00'),
        pending: [
          SchedulePendingItem(
            id: 'pi_1',
            kind: SchedulePendingItem.kindTodo,
            title: 'State task',
            dueAt: DateTime.parse('2026-05-24T18:00:00'),
            sourceFactIds: const ['2026/05/24.md#ts_1'],
            subtasks: const [
              ScheduleSubtask(title: 'Draft', completed: true),
              ScheduleSubtask(title: 'Review', completed: false),
            ],
          ),
        ],
        completed: [
          ScheduleCompletedItem(
            id: 'pi_done',
            kind: SchedulePendingItem.kindTodo,
            title: 'Done task',
            closedAt: DateTime.parse('2026-05-23T12:00:00'),
            sourceFactIds: const ['2026/05/23.md#ts_done'],
          ),
        ],
        presentation: const SchedulePresentation(
          hero: SchedulePresentationHero(
            itemId: 'pi_1',
            title: 'Hero from state',
            description: 'State description',
          ),
          editorialIntro: 'State presentation wins.',
          quoteBlocks: [
            ScheduleQuoteBlock(
              title: 'Focus',
              content: 'Finish the review.',
              itemId: 'pi_1',
            ),
          ],
          timeline: [
            ScheduleTimelineDay(
              dayLabel: 'Today',
              dayDate: '2026-05-24',
              itemIds: ['missing_presentation_item_id'],
            ),
          ],
        ),
      ),
    );

    final viewData = await getScheduleViewData();

    expect(viewData!.id, 'schedule_state');
    expect(viewData.editorialIntro, 'State presentation wins.');
    expect(viewData.hero!.cardId, '2026/05/24.md#ts_1');
    expect(viewData.hero!.title, 'Hero from state');
    expect(viewData.quoteBlocks.single.relatedCardId, '2026/05/24.md#ts_1');
    expect(viewData.timeline.single.items.single.cardId, '2026/05/24.md#ts_1');
    expect(viewData.timeline.single.items.single.status, 'in_progress');
    expect(
      viewData.timeline.single.items.single.subtasks
          .map((subtask) => subtask.completed),
      [true, false],
    );
    expect(viewData.completed.single.cardId, '2026/05/23.md#ts_done');
  });
}
