import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/ui/chat/widgets/open_super_agent_dialog.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'language': 'en',
      'user_id': 'open-super-agent-test',
    });
    await UserStorage.initL10n();
  });

  test('returns cached latest Super Agent home session id', () async {
    await UserStorage.setLatestSuperAgentHomeSessionId('cached-session');

    await expectLater(
        latestSuperAgentSessionId(), completion('cached-session'));
  });

  testWidgets('waits for session lookup before building chat dialog', (
    tester,
  ) async {
    final sessionId = Completer<String?>();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: buildSuperAgentDialogSessionGate(
          sessionIdFuture: sessionId.future,
        ),
      ),
    );

    expect(find.byType(AgentChatDialog), findsNothing);

    sessionId.complete('session-1');
    await tester.pump();

    expect(find.byType(AgentChatDialog), findsOneWidget);
  });
}
