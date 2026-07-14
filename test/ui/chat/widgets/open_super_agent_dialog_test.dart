import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/ui/chat/widgets/open_super_agent_dialog.dart';
import 'package:memex/utils/result.dart';
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

    var scannedSessions = false;

    await expectLater(
      latestSuperAgentSessionId(
        sessionExists: (_) async => const Ok(true),
        fetchSessions: () async {
          scannedSessions = true;
          return const Ok([]);
        },
      ),
      completion('cached-session'),
    );
    expect(scannedSessions, isFalse);
  });

  test('replaces a stale cached id with the latest home session', () async {
    await UserStorage.setLatestSuperAgentHomeSessionId('missing-session');

    final sessionId = await latestSuperAgentSessionId(
      sessionExists: (_) async => const Ok(false),
      fetchSessions: () async => const Ok([
        {
          'session_id': 'timeline-detail',
          'scene': 'assistant_timeline_card_detail',
        },
        {
          'session_id': 'restored-home',
          'scene': 'super_agent_home',
        },
      ]),
    );

    expect(sessionId, 'restored-home');
    expect(
      await UserStorage.getLatestSuperAgentHomeSessionId(),
      'restored-home',
    );
  });

  test('keeps the cached id when targeted validation temporarily fails',
      () async {
    await UserStorage.setLatestSuperAgentHomeSessionId('cached-session');

    var scannedSessions = false;
    final sessionId = await latestSuperAgentSessionId(
      sessionExists: (_) async => Error(Exception('temporary failure')),
      fetchSessions: () async {
        scannedSessions = true;
        return const Ok([]);
      },
    );

    expect(sessionId, 'cached-session');
    expect(scannedSessions, isFalse);
  });

  test('restores a legacy assistant session after app preferences are lost',
      () async {
    final sessionId = await latestSuperAgentSessionId(
      fetchSessions: () async => const Ok([
        {
          'session_id': 'card-detail',
          'scene': 'assistant_timeline_card_detail',
        },
        {
          'session_id': 'legacy-home',
          'scene': 'assistant',
        },
      ]),
    );

    expect(sessionId, 'legacy-home');
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
