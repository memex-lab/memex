import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:memex/agent/skills/manage_system_action/system_action_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/ui/card_attachments/card_attachment_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/card_attachments/widgets/system_action_card.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  Widget buildHost(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('SystemActionCard', () {
    testWidgets(
        'SuperAgent record proposal appears on its source and writes only after Add',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      late Directory root;
      await tester.runAsync(() async {
        root = await Directory.systemTemp.createTemp('record_device_ui_');
        await FileSystemService.init(root.path);
      });
      const native = MethodChannel('com.memexlab.memex/system_actions');
      const permissions =
          MethodChannel('flutter.baseflow.com/permissions/methods');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      var writes = 0;
      messenger.setMockMethodCallHandler(native, (call) async {
        expect(call.method, 'addCalendarEvent');
        expect((call.arguments as Map)['title'], '陪妈妈复查');
        writes++;
        return true;
      });
      messenger.setMockMethodCallHandler(permissions, (call) async => 1);
      addTearDown(() async {
        messenger.setMockMethodCallHandler(native, null);
        messenger.setMockMethodCallHandler(permissions, null);
        await db.close();
        await root.delete(recursive: true);
      });
      const factId = '2026/09/17.md#ts_3';
      await tester.runAsync(() async {
        final fs = FileSystemService.instance;
        await fs.writeYamlFile(
            fs.getCardPath('record-user', factId),
            const CardData(
                    factId: factId,
                    timestamp: 1789603200,
                    status: 'completed',
                    tags: [],
                    uiConfigs: [],
                    fact: '2099年9月18日下午三点带妈妈复查。')
                .toJson());
        // The real SuperAgent skill is invoked without any Character setup.
        final tool = SystemActionSkill(userId: 'record-user').tools!.first;
        await Function.apply(tool.executable!, [
          '陪妈妈复查',
          '2099-09-18 15:00:00',
          null,
          null,
          null,
          factId,
        ]);
      });
      final attachments =
          await CardAttachmentService.instance.getAttachments(factId);
      expect(attachments, hasLength(1));
      expect(writes, 0);
      await tester.pumpWidget(
          buildHost(CardAttachmentFactory.build(attachments.single)));
      await tester.pumpAndSettle();
      expect(find.text('陪妈妈复查'), findsOneWidget);
      expect(find.text(UserStorage.l10n.addToCalendar), findsOneWidget);
      await tester.tap(find.text(UserStorage.l10n.addToCalendar));
      await tester.pumpAndSettle();
      expect(writes, 1);
      expect(find.text(UserStorage.l10n.addToCalendar), findsNothing);
      expect(
          (await db.select(db.systemActions).get()).single.status, 'completed');
    });

    testWidgets(
        'iOS editor cancel stays pending without permission or error; save completes',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      const native = MethodChannel('com.memexlab.memex/system_actions');
      const permissions =
          MethodChannel('flutter.baseflow.com/permissions/methods');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      var launches = 0;
      var permissionCalls = 0;
      messenger.setMockMethodCallHandler(native, (call) async {
        launches++;
        return launches == 1 ? 'cancelled' : true;
      });
      messenger.setMockMethodCallHandler(permissions, (call) async {
        permissionCalls++;
        return 0;
      });
      addTearDown(() async {
        debugDefaultTargetPlatformOverride = null;
        messenger.setMockMethodCallHandler(native, null);
        messenger.setMockMethodCallHandler(permissions, null);
        await db.close();
      });
      final service = SystemActionService.instance;
      await service.createAction(id: 'editor-test', type: 'calendar', data: {
        'title': '复查',
        'start_time': '2099-09-18 15:00:00',
      });
      final action = (await service.getAction('editor-test'))!;
      await tester.pumpWidget(
          buildHost(SystemActionCard(action: action, service: service)));
      expect(find.text(UserStorage.l10n.calendarEditorExplanation),
          findsOneWidget);
      await tester.tap(find.text(UserStorage.l10n.reviewInCalendar));
      await tester.pumpAndSettle();
      expect(permissionCalls, 0);
      expect((await service.getAction('editor-test'))!.status, 'pending');
      expect(find.text(UserStorage.l10n.writeToSystemFailed), findsNothing);
      expect(find.text(UserStorage.l10n.reviewInCalendar), findsOneWidget);
      await tester.tap(find.text(UserStorage.l10n.reviewInCalendar));
      await tester.pumpAndSettle();
      expect(launches, 2);
      expect((await service.getAction('editor-test'))!.status, 'completed');
      expect(find.text(UserStorage.l10n.reviewInCalendar), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('renders dismissed actions as still actionable on source cards',
        (tester) async {
      await tester.pumpWidget(
        buildHost(
          SystemActionCard(
            action: _action(status: 'dismissed'),
            service: SystemActionService.instance,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('天津小白院领证Party调研'), findsOneWidget);
      expect(find.text(UserStorage.l10n.addToCalendar), findsOneWidget);
      expect(find.text(UserStorage.l10n.ignore), findsOneWidget);
    });

    testWidgets('keeps rejected actions hidden', (tester) async {
      await tester.pumpWidget(
        buildHost(
          SystemActionCard(
            action: _action(status: 'rejected'),
            service: SystemActionService.instance,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('天津小白院领证Party调研'), findsNothing);
      expect(find.text(UserStorage.l10n.addToCalendar), findsNothing);
    });

    testWidgets('does not offer a native write for an unsupported action type',
        (tester) async {
      await tester.pumpWidget(
        buildHost(
          SystemActionCard(
            action: _action(status: 'pending', actionType: 'unsupported'),
            service: SystemActionService.instance,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(UserStorage.l10n.unknownAction), findsWidgets);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('loads a pending artifact with visible confirmation controls',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      addTearDown(db.close);
      await SystemActionService.instance.createAction(
        id: 'pending-reminder',
        type: 'reminder',
        data: const {
          'title': 'Watch the market open',
          'due_date': '2026-07-27 21:30:00',
        },
      );

      await tester.pumpWidget(
        buildHost(
          const SystemActionArtifactCard(
            actionId: 'pending-reminder',
            actionKind: 'reminder',
            fallbackTitle: 'Watch the market open',
            fallbackSummary: '2026-07-27 21:30',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Watch the market open'), findsOneWidget);
      expect(
        find.text(UserStorage.l10n.systemActionPendingExplanation),
        findsOneWidget,
      );
      expect(find.text(UserStorage.l10n.addToReminders), findsOneWidget);
      expect(find.text(UserStorage.l10n.ignore), findsOneWidget);
    });
  });
}

SystemAction _action({
  required String status,
  String actionType = 'calendar',
}) {
  return SystemAction(
    id: 'action-$status',
    actionType: actionType,
    actionData: jsonEncode({
      'title': '天津小白院领证Party调研',
      'start_time': '2026-06-06 09:00:00',
      'location': '天津',
    }),
    status: status,
    factId: '2026/05/25.md#ts_7',
    createdAt: 0,
    updatedAt: 0,
  );
}
