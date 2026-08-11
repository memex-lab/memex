import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
