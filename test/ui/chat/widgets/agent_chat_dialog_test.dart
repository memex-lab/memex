import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  group('AgentChatDialog layout metrics', () {
    test('resolves default sheet and full-screen heights', () {
      const viewport = Size(390, 800);

      expect(resolveAgentChatDialogHeight(viewport, isFullScreen: false), 600);
      expect(resolveAgentChatDialogHeight(viewport, isFullScreen: true), 800);
    });

    test('uses rounded sheet corners only outside full screen', () {
      expect(
        resolveAgentChatDialogBorderRadius(isFullScreen: false),
        const BorderRadius.vertical(top: Radius.circular(32)),
      );
      expect(
        resolveAgentChatDialogBorderRadius(isFullScreen: true),
        BorderRadius.zero,
      );
    });
  });

  group('AgentChatDialog full-screen affordance', () {
    testWidgets('starts as a bottom sheet with a full-screen action', (
      tester,
    ) async {
      await _pumpDialog(tester);

      expect(
        find.text('Start a conversation with Super Agent'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byTooltip(UserStorage.l10n.chatHistory), findsOneWidget);
      expect(
        find.byTooltip(UserStorage.l10n.enterFullScreenTooltip),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.open_in_full), findsOneWidget);
      expect(find.byTooltip(UserStorage.l10n.close), findsOneWidget);

      final container = tester.widget<AnimatedContainer>(
        find.byKey(const ValueKey('agent_chat_dialog_container')),
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(
        tester
            .getSize(find.byKey(const ValueKey('agent_chat_dialog_container')))
            .height,
        600,
      );
      expect(
        decoration.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(32)),
      );
    });

    testWidgets('expands to full screen and restores the sheet', (
      tester,
    ) async {
      await _pumpDialog(tester);

      await tester.tap(
        find.byKey(const ValueKey('agent_chat_fullscreen_toggle')),
      );
      await tester.pumpAndSettle();

      var container = tester.widget<AnimatedContainer>(
        find.byKey(const ValueKey('agent_chat_dialog_container')),
      );
      var decoration = container.decoration! as BoxDecoration;

      expect(
        tester
            .getSize(find.byKey(const ValueKey('agent_chat_dialog_container')))
            .height,
        800,
      );
      expect(decoration.borderRadius, BorderRadius.zero);
      expect(
        find.byTooltip(UserStorage.l10n.exitFullScreenTooltip),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.close_fullscreen), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('agent_chat_fullscreen_toggle')),
      );
      await tester.pumpAndSettle();

      container = tester.widget<AnimatedContainer>(
        find.byKey(const ValueKey('agent_chat_dialog_container')),
      );
      decoration = container.decoration! as BoxDecoration;

      expect(
        tester
            .getSize(find.byKey(const ValueKey('agent_chat_dialog_container')))
            .height,
        600,
      );
      expect(
        decoration.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(32)),
      );
      expect(
        find.byTooltip(UserStorage.l10n.enterFullScreenTooltip),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.open_in_full), findsOneWidget);
    });

    testWidgets(
      'keeps a long title inside the compact header on narrow screens',
      (tester) async {
        await _pumpDialog(
          tester,
          viewportSize: const Size(320, 800),
          title:
              'Super Agent with a very long workspace-specific conversation title',
        );

        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const ValueKey('agent_chat_fullscreen_toggle')),
          findsOneWidget,
        );
        expect(find.byTooltip(UserStorage.l10n.close), findsOneWidget);
      },
    );
  });
}

Future<void> _pumpDialog(
  WidgetTester tester, {
  Size viewportSize = const Size(390, 800),
  String title = 'Super Agent',
}) async {
  tester.view.physicalSize = viewportSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AgentChatDialog(
          agentName: 'memex_agent',
          title: title,
          inputHint: 'Ask Super Agent...',
          scene: 'assistant_home',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
