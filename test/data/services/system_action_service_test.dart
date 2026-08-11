import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const nativeChannel = MethodChannel('com.memexlab.memex/system_actions');
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_id': 'system-action-user'});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nativeChannel, null);
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
      },
    );

    test('hard rejection removes actions from fact visibility', () async {
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
    });

    test('applies a valid event through the native bridge and completes it',
        () async {
      MethodCall? received;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(nativeChannel, (call) async {
        received = call;
        return true;
      });
      await SystemActionService.instance.createAction(
        id: 'pending-native-calendar',
        type: 'calendar',
        data: const {
          'title': 'Team review',
          'start_time': '2026-08-01 15:30:00',
          'end_time': '2026-08-01 16:30:00',
        },
      );
      final action = await SystemActionService.instance.getAction(
        'pending-native-calendar',
      );

      final applied = await SystemActionService.instance.applyToDevice(action!);

      expect(applied, isTrue);
      expect(received!.method, 'addCalendarEvent');
      expect(
        (await SystemActionService.instance.getAction(action.id))!.status,
        'completed',
      );
      expect(await SystemActionService.instance.getPending(), isEmpty);
    });

    test('rejects malformed action data before calling the native bridge',
        () async {
      var nativeCallCount = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(nativeChannel, (call) async {
        nativeCallCount += 1;
        return true;
      });
      await SystemActionService.instance.createAction(
        id: 'invalid-native-calendar',
        type: 'calendar',
        data: const {
          'title': 'Invalid meeting',
          'start_time': 'not-a-date',
        },
      );
      final action = await SystemActionService.instance.getAction(
        'invalid-native-calendar',
      );

      final applied = await SystemActionService.instance.applyToDevice(action!);

      expect(applied, isFalse);
      expect(nativeCallCount, 0);
      expect(
        (await SystemActionService.instance.getAction(action.id))!.status,
        'pending',
      );
    });
  });
}
