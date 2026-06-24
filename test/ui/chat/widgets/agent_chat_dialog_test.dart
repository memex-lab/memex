import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/data/services/demo_service.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await initializeDateFormatting('en');
    await UserStorage.initL10n();
  });

  group('AgentChatDialog layout metrics', () {
    test('resolves default sheet and full-screen heights', () {
      const viewport = Size(390, 800);

      expect(resolveAgentChatDialogHeight(viewport, isFullScreen: false), 600);
      expect(resolveAgentChatDialogHeight(viewport, isFullScreen: true), 800);
      expect(
        resolveAgentChatDialogHeight(
          viewport,
          isFullScreen: false,
          keyboardInset: 320,
        ),
        480,
      );
      expect(
        resolveAgentChatDialogHeight(
          viewport,
          isFullScreen: true,
          keyboardInset: 320,
        ),
        480,
      );
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

    test('uses keyboard inset whenever the keyboard is visible and editable',
        () {
      expect(
        resolveSuperAgentInputBottomInset(
          keyboardInset: 320,
          inputFocused: true,
          isStreaming: false,
        ),
        320,
      );
      expect(
        resolveSuperAgentInputBottomInset(
          keyboardInset: 320,
          inputFocused: true,
          isStreaming: true,
        ),
        320,
      );
      expect(
        resolveSuperAgentInputBottomInset(
          keyboardInset: 320,
          inputFocused: false,
          isStreaming: false,
        ),
        320,
      );
    });

    test('does not create an empty assistant bubble for final done chunks', () {
      expect(
        shouldCreateAIMessageForResponseChunk(text: '', isDone: true),
        isFalse,
      );
      expect(
        shouldCreateAIMessageForResponseChunk(text: '', isDone: false),
        isTrue,
      );
      expect(
        shouldCreateAIMessageForResponseChunk(text: 'Done', isDone: true),
        isTrue,
      );
    });

    test('snaps down when the keyboard inset shrinks', () {
      expect(
        resolveSuperAgentKeyboardInsetAnimationDuration(
          previousInset: 0,
          nextInset: 320,
        ),
        const Duration(milliseconds: 220),
      );
      expect(
        resolveSuperAgentKeyboardInsetAnimationDuration(
          previousInset: 320,
          nextInset: 0,
        ),
        Duration.zero,
      );
    });

    test('maps reversed chat list indexes around live status rows', () {
      expect(
        superAgentItemIndexForReversedList(
          listIndex: 0,
          itemCount: 10,
          extraItems: 0,
        ),
        9,
      );
      expect(
        superAgentItemIndexForReversedList(
          listIndex: 1,
          itemCount: 10,
          extraItems: 1,
        ),
        9,
      );
      expect(
        superAgentItemIndexForReversedList(
          listIndex: 10,
          itemCount: 10,
          extraItems: 1,
        ),
        0,
      );
    });

    test('formats chat time dividers like persona chat', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 9, 8);

      expect(formatSuperAgentTimeDivider(today), '09:08');
      expect(
        formatSuperAgentTimeDivider(
          today.subtract(const Duration(days: 1)),
        ),
        contains(UserStorage.l10n.yesterday),
      );
    });

    test('formats token usage without estimated cost', () {
      final text = formatSuperAgentTokenUsage(
        ChatTokenUsageEvent(
          promptTokens: 100,
          completionTokens: 25,
          cachedTokens: 40,
          totalTokens: 125,
          estimatedCost: 0.12345,
          effectivePromptTokens: 100,
          cachedTokensForRate: 40,
        ),
      );

      expect(text, 'Tokens: 125 (P:100 C:25 Cache:40.0%)');
      expect(text, isNot(contains('Est')));
      expect(text, isNot(contains(r'$')));
      expect(text, isNot(contains('0.12345')));
    });

    test('keeps photo suggestions available while the super agent is sending',
        () {
      expect(
        shouldShowSuperAgentPhotoSuggestions(
          isLoading: true,
          hasSuggestions: false,
        ),
        isTrue,
      );
      expect(
        shouldShowSuperAgentPhotoSuggestions(
          isLoading: false,
          hasSuggestions: true,
        ),
        isTrue,
      );
      expect(
        shouldShowSuperAgentPhotoSuggestions(
          isLoading: true,
          hasSuggestions: true,
        ),
        isTrue,
      );
    });

    test('queues a super agent send while another run is active', () {
      expect(
        shouldQueueSuperAgentSend(
          isStreaming: false,
          hasSessionId: true,
          hasChatSubscription: true,
        ),
        isFalse,
      );
      expect(
        shouldQueueSuperAgentSend(
          isStreaming: true,
          hasSessionId: false,
          hasChatSubscription: true,
        ),
        isFalse,
      );
      expect(
        shouldQueueSuperAgentSend(
          isStreaming: true,
          hasSessionId: true,
          hasChatSubscription: false,
        ),
        isFalse,
      );
      expect(
        shouldQueueSuperAgentSend(
          isStreaming: true,
          hasSessionId: true,
          hasChatSubscription: true,
        ),
        isTrue,
      );
    });

    test('keeps original filenames only for selected initial images', () {
      final selected = [
        XFile('/tmp/a.jpg'),
        XFile('/tmp/b.jpg'),
      ];

      expect(
        initialOriginalFilenamesForSelectedImages(selected, {
          '/tmp/a.jpg': 'camera-original.jpg',
          '/tmp/b.jpg': ' ',
          '/tmp/unused.jpg': 'unused.jpg',
        }),
        {'/tmp/a.jpg': 'camera-original.jpg'},
      );
    });

    test('uses demo send key only while spotlighting super agent publish', () {
      expect(superAgentDemoPublishTargetKey(null), isNull);
      expect(superAgentDemoPublishTargetKey(DemoStep.tapAddButton), isNull);
      expect(
        superAgentDemoPublishTargetKey(DemoStep.tapSend),
        same(DemoService.instance.sendButtonKey),
      );
    });

    test('toggles demo overlay suspension for routed detail pages', () {
      final demo = DemoService.instance;

      demo.resumeOverlay();
      expect(demo.isOverlaySuspended, isFalse);

      demo.suspendOverlay();
      expect(demo.isOverlaySuspended, isTrue);

      demo.resumeOverlay();
      expect(demo.isOverlaySuspended, isFalse);
    });
  });

  group('AgentChatDialog full-screen affordance', () {
    testWidgets('starts as a bottom sheet with a full-screen action', (
      tester,
    ) async {
      await _pumpDialog(tester);

      expect(find.text(UserStorage.l10n.aiInputHint), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byTooltip(UserStorage.l10n.chatHistory), findsNothing);
      expect(
        find.byTooltip(UserStorage.l10n.enterFullScreenTooltip),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.open_in_full), findsOneWidget);
      expect(find.byTooltip(UserStorage.l10n.close), findsOneWidget);
      expect(
        find.byKey(const ValueKey('super_agent_run_mode_chip')),
        findsNothing,
      );

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
      'keeps header actions inside the compact header on narrow screens',
      (tester) async {
        await _pumpDialog(
          tester,
          viewportSize: const Size(320, 800),
        );

        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const ValueKey('agent_chat_fullscreen_toggle')),
          findsOneWidget,
        );
        expect(find.byTooltip(UserStorage.l10n.close), findsOneWidget);
      },
    );

    testWidgets('super agent entry hides chat controls and uses send input', (
      tester,
    ) async {
      await _pumpDialog(tester);

      expect(find.byTooltip(UserStorage.l10n.chatHistory), findsNothing);
      expect(find.byIcon(Icons.mic), findsNothing);
      expect(
        find.byKey(const ValueKey('super_agent_camera_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('super_agent_gallery_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('super_agent_publish_button')),
        findsOneWidget,
      );
      expect(find.text(UserStorage.l10n.sendLabel), findsOneWidget);
    });

    testWidgets('keeps super agent header actions tight to the right edge', (
      tester,
    ) async {
      const viewportSize = Size(390, 800);
      await _pumpDialog(
        tester,
        viewportSize: viewportSize,
      );

      final dialogRect = tester.getRect(
        find.byKey(const ValueKey('agent_chat_dialog_container')),
      );
      final fullscreenButtonRect = tester.getRect(
        find.byKey(const ValueKey('agent_chat_fullscreen_toggle')),
      );
      final closeButtonFinder =
          find.byKey(const ValueKey('agent_chat_close_button'));
      final closeButtonRect = tester.getRect(closeButtonFinder);
      final closeIconRect = tester.getRect(
        find.descendant(
          of: closeButtonFinder,
          matching: find.byIcon(Icons.close),
        ),
      );

      expect(dialogRect.width, moreOrLessEquals(viewportSize.width));
      expect(closeButtonRect.size, const Size.square(36));
      expect(fullscreenButtonRect.size, const Size.square(36));
      expect(
        dialogRect.right - closeButtonRect.right,
        moreOrLessEquals(4),
      );
      expect(
        viewportSize.width - closeButtonRect.right,
        moreOrLessEquals(4),
      );
      expect(closeIconRect.right, greaterThan(dialogRect.right - 13));
      expect(closeIconRect.right, greaterThan(viewportSize.width - 13));
      expect(closeButtonRect.left - fullscreenButtonRect.right, 0);
    });
  });
}

Future<void> _pumpDialog(
  WidgetTester tester, {
  Size viewportSize = const Size(390, 800),
}) async {
  tester.view.physicalSize = viewportSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AgentChatDialog(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
