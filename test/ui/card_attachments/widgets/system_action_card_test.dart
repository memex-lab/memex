import 'dart:convert';

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
  });
}

SystemAction _action({required String status}) {
  return SystemAction(
    id: 'action-$status',
    actionType: 'calendar',
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
