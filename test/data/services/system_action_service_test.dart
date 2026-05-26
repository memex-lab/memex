import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_id': 'system-action-user'});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SystemActionService', () {
    test(
      'action center dismiss hides pending actions without rejecting source visibility',
      () async {
        await SystemActionService.instance.createAction(
          id: 'pending-calendar',
          type: 'calendar',
          factId: '2026/05/25.md#ts_7',
          data: const {
            'title': '天津小白院领证Party调研',
            'start_time': '2026-06-06 09:00:00',
          },
        );

        final dismissedCount = await CardAttachmentService.instance
            .dismissAllPending(type: CardAttachmentType.systemAction);

        expect(dismissedCount, 1);
        expect(await SystemActionService.instance.getPending(), isEmpty);

        final visibleForFact = await SystemActionService.instance
            .getVisibleForFact('2026/05/25.md#ts_7');
        expect(visibleForFact, hasLength(1));
        expect(visibleForFact.single.status, 'dismissed');

        final visibleForSchedule =
            await SystemActionService.instance.getVisibleForSchedule();
        expect(visibleForSchedule.map((action) => action.id), [
          'pending-calendar',
        ]);
      },
    );

    test('hard rejection removes actions from fact and schedule visibility',
        () async {
      await SystemActionService.instance.createAction(
        id: 'rejected-calendar',
        type: 'calendar',
        factId: '2026/05/25.md#ts_7',
        data: const {
          'title': '旧的小白院日程',
          'start_time': '2026-06-06 09:00:00',
        },
      );
      await SystemActionService.instance.updateActionStatus(
        'rejected-calendar',
        'rejected',
      );

      expect(
        await SystemActionService.instance.getVisibleForFact(
          '2026/05/25.md#ts_7',
        ),
        isEmpty,
      );
      expect(
          await SystemActionService.instance.getVisibleForSchedule(), isEmpty);
    });

    test(
        'schedule visibility includes completed and dismissed calendar/reminder only',
        () async {
      await SystemActionService.instance.createAction(
        id: 'completed-calendar',
        type: 'calendar',
        data: const {
          'title': '已添加日程',
          'start_time': '2026-06-06 09:00:00',
        },
      );
      await SystemActionService.instance.updateActionStatus(
        'completed-calendar',
        'completed',
      );
      await SystemActionService.instance.createAction(
        id: 'dismissed-reminder',
        type: 'reminder',
        data: const {
          'title': '已清掉提醒',
          'due_date': '2026-06-07 12:00:00',
        },
      );
      await SystemActionService.instance.updateActionStatus(
        'dismissed-reminder',
        'dismissed',
      );
      await SystemActionService.instance.createAction(
        id: 'unsupported-action',
        type: 'note',
        data: const {'title': '不是日程动作'},
      );

      final visible =
          await SystemActionService.instance.getVisibleForSchedule();

      expect(
        visible.map((action) => action.id),
        ['completed-calendar', 'dismissed-reminder'],
      );
    });
  });
}
