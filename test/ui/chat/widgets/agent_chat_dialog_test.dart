import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/data/services/demo_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/core/widgets/local_image.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_file_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
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
      expect(
        resolveAgentChatDialogHeight(
          viewport,
          isFullScreen: false,
          keyboardInset: 320,
          topSafeInset: 44,
        ),
        436,
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

    test('requests older history near the top or when content is too short',
        () {
      expect(
        shouldRequestOlderSuperAgentHistory(
          hasMoreHistory: true,
          isLoading: false,
          pixels: 0,
          maxScrollExtent: 0,
        ),
        isTrue,
      );
      expect(
        shouldRequestOlderSuperAgentHistory(
          hasMoreHistory: true,
          isLoading: false,
          pixels: 80,
          maxScrollExtent: 100,
        ),
        isTrue,
      );
      expect(
        shouldRequestOlderSuperAgentHistory(
          hasMoreHistory: true,
          isLoading: false,
          pixels: 60,
          maxScrollExtent: 100,
        ),
        isFalse,
      );
      expect(
        shouldRequestOlderSuperAgentHistory(
          hasMoreHistory: true,
          isLoading: true,
          pixels: 100,
          maxScrollExtent: 100,
        ),
        isFalse,
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

    test('shows standalone thinking only before process or reply appears', () {
      expect(
        shouldShowSuperAgentThinkingRow(
          isLoadingAgent: false,
          primaryItem: UserMessageItem('hello'),
        ),
        isFalse,
      );
      expect(
        shouldShowSuperAgentThinkingRow(
          isLoadingAgent: true,
          primaryItem: UserMessageItem('hello'),
        ),
        isTrue,
      );
      expect(
        shouldShowSuperAgentThinkingRow(
          isLoadingAgent: true,
          primaryItem: ProcessItem(),
        ),
        isFalse,
      );
      expect(
        shouldShowSuperAgentThinkingRow(
          isLoadingAgent: true,
          primaryItem: AIMessageItem('reply', isStreaming: true),
        ),
        isFalse,
      );
    });

    test('uses final process state instead of historical tool errors', () {
      final failedTool = ToolCallItem(
        'read-1',
        'read',
        '{}',
        result: 'temporary failure',
        isError: true,
      );
      final completedProcess = ProcessItem(isFinished: true)
        ..children.add(failedTool);
      final attentionProcess = ProcessItem(
        isFinished: true,
        needsAttention: true,
      )..children.add(failedTool);

      expect(
        superAgentProcessVisualState(completedProcess),
        SuperAgentProcessVisualState.done,
      );
      expect(
        superAgentProcessVisualState(attentionProcess),
        SuperAgentProcessVisualState.needsAttention,
      );
      expect(completedProcess.hasToolError, isTrue);
    });

    test('shows the photo suggestion status until suggestions resolve', () {
      expect(
        shouldShowSuperAgentPhotoSuggestionStatus(
          isLoading: true,
          hasSuggestions: false,
          hasLoadedSuggestions: false,
        ),
        isTrue,
      );
      expect(
        shouldShowSuperAgentPhotoSuggestionStatus(
          isLoading: false,
          hasSuggestions: true,
          hasLoadedSuggestions: true,
        ),
        isFalse,
      );
      expect(
        shouldShowSuperAgentPhotoSuggestionStatus(
          isLoading: false,
          hasSuggestions: false,
          hasLoadedSuggestions: true,
        ),
        isFalse,
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

    test(
        'explains notification permission only for first eligible Android send',
        () {
      expect(
        shouldExplainMemexAgentNotificationPermission(
          platform: TargetPlatform.android,
          isDemoActive: false,
          alreadyPrompted: false,
          notificationStatus: PermissionStatus.denied,
        ),
        isTrue,
      );
      expect(
        shouldExplainMemexAgentNotificationPermission(
          platform: TargetPlatform.iOS,
          isDemoActive: false,
          alreadyPrompted: false,
          notificationStatus: PermissionStatus.denied,
        ),
        isFalse,
      );
      expect(
        shouldExplainMemexAgentNotificationPermission(
          platform: TargetPlatform.android,
          isDemoActive: true,
          alreadyPrompted: false,
          notificationStatus: PermissionStatus.denied,
        ),
        isFalse,
      );
      expect(
        shouldExplainMemexAgentNotificationPermission(
          platform: TargetPlatform.android,
          isDemoActive: false,
          alreadyPrompted: true,
          notificationStatus: PermissionStatus.denied,
        ),
        isFalse,
      );
      expect(
        shouldExplainMemexAgentNotificationPermission(
          platform: TargetPlatform.android,
          isDemoActive: false,
          alreadyPrompted: false,
          notificationStatus: PermissionStatus.granted,
        ),
        isFalse,
      );
      expect(
        shouldExplainMemexAgentNotificationPermission(
          platform: TargetPlatform.android,
          isDemoActive: false,
          alreadyPrompted: false,
          notificationStatus: PermissionStatus.permanentlyDenied,
        ),
        isFalse,
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

    test('keeps artifacts attached to the assistant reply item', () {
      final artifact = ArtifactItem(
        ChatArtifact.schedule(title: 'Schedule presentation', updated: true),
      );
      final reply =
          AIMessageItem('Done', turnId: 'turn-1', artifacts: [artifact]);

      expect(reply.artifacts, [artifact]);
      expect(reply.artifacts.single.artifact.title, 'Schedule presentation');
    });

    test('coalesces artifact revisions without changing card order', () {
      final current = <ArtifactItem>[
        ArtifactItem(
          ChatArtifact.timelineCard(
            cardId: 'xinjiang',
            title: 'Draft',
            updated: false,
          ),
        ),
        ArtifactItem(
          ChatArtifact.schedule(title: 'Schedule', updated: false),
        ),
      ];

      mergeArtifactItems(current, [
        ArtifactItem(
          ChatArtifact.timelineCard(
            cardId: 'xinjiang',
            title: 'Final',
            updated: true,
          ),
        ),
      ]);

      expect(current, hasLength(2));
      expect(current.first.artifact.title, 'Final');
      expect(current.last.artifact.kind, ChatArtifact.kindSchedule);
    });

    test('attaches pending artifacts only to the same assistant turn', () {
      expect(
        shouldAttachArtifactsToAssistantReply(
          turnId: 'turn-1',
          primaryItem: AIMessageItem('Done', turnId: 'turn-1'),
        ),
        isTrue,
      );
      expect(
        shouldAttachArtifactsToAssistantReply(
          turnId: 'turn-2',
          primaryItem: AIMessageItem('Done', turnId: 'turn-1'),
        ),
        isFalse,
      );
      expect(
        shouldAttachArtifactsToAssistantReply(
          turnId: 'turn-1',
          primaryItem: UserMessageItem('next request'),
        ),
        isFalse,
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

    testWidgets('keeps the keyboard sheet below the top safe area', (
      tester,
    ) async {
      const viewportSize = Size(390, 800);
      const topSafeInset = 44.0;
      const keyboardInset = 320.0;
      await _pumpDialog(
        tester,
        viewportSize: viewportSize,
        mediaQueryData: const MediaQueryData(
          size: viewportSize,
          viewPadding: EdgeInsets.only(top: topSafeInset),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
      );

      final dialogRect = tester.getRect(
        find.byKey(const ValueKey('agent_chat_dialog_container')),
      );
      expect(dialogRect.top, topSafeInset);
      expect(dialogRect.bottom, viewportSize.height - keyboardInset);
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

    testWidgets('does not show a loading logo while opening a session', (
      tester,
    ) async {
      await _pumpDialogFrame(
        tester,
        dialog: const AgentChatDialog(initialSessionId: 'session-1'),
      );

      expect(find.byType(AgentLogoLoading), findsNothing);
    });

    testWidgets('reserves the photo suggestion slot on the first frame', (
      tester,
    ) async {
      await _pumpDialogFrame(tester);

      final slotFinder = find.byKey(superAgentPhotoSuggestionSlotKey);

      expect(slotFinder, findsOneWidget);
      expect(
        tester.getSize(slotFinder).height,
        superAgentPhotoSuggestionSlotHeight,
      );
      expect(
        find.text(UserStorage.l10n.agentChat.findingRecentPhotos),
        findsOneWidget,
      );
    });

    testWidgets('renders selected images through the cached image widget', (
      tester,
    ) async {
      await _pumpDialogFrame(
        tester,
        dialog: AgentChatDialog(
          initialImages: [XFile('/tmp/memex-selected-image.jpg')],
        ),
      );

      expect(find.byType(LocalImage), findsOneWidget);
    });

    testWidgets('keeps process thinking and token usage inside details', (
      tester,
    ) async {
      final usage = ChatTokenUsageEvent(
        promptTokens: 100,
        completionTokens: 25,
        cachedTokens: 40,
        totalTokens: 125,
        estimatedCost: 0.0,
        effectivePromptTokens: 100,
        cachedTokensForRate: 40,
      );
      final process = ProcessItem()
        ..children.add(ThinkingItem('Inspecting the plan'));

      await _pumpDialogFrame(
        tester,
        dialog: AgentChatDialog(
          initialItems: [process],
          initialIsLoadingAgent: true,
          initialTokenUsage: usage,
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      final tokenText = formatSuperAgentTokenUsage(usage);
      expect(find.text(UserStorage.l10n.agentChat.thinking), findsNothing);
      expect(find.text('Inspecting the plan'), findsNothing);
      expect(find.text(tokenText), findsNothing);

      await tester.tap(find.byKey(const ValueKey('agent_chat_process_toggle')));
      await tester.pump();

      expect(find.text(UserStorage.l10n.agentChat.thinking), findsOneWidget);
      expect(find.text('Inspecting the plan'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('agent_chat_token_usage_debug')),
        findsOneWidget,
      );
      expect(find.text(tokenText), findsOneWidget);
    });

    testWidgets('shows completed process despite intermediate tool errors', (
      tester,
    ) async {
      final failedTool = ToolCallItem(
        'read-1',
        'read',
        '{}',
        result: 'temporary failure',
        isError: true,
      );
      final process = ProcessItem(isFinished: true)..children.add(failedTool);

      await _pumpDialogFrame(
        tester,
        dialog: AgentChatDialog(initialItems: [process]),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.text(UserStorage.l10n.agentChat.completedActions(1)),
        findsOneWidget,
      );
      expect(find.text(UserStorage.l10n.agentChat.actionNeedsAttention),
          findsNothing);
      expect(find.text(UserStorage.l10n.agentChat.issue), findsNothing);
    });

    test('resolves persisted user image paths as local files', () async {
      final tempDir = Directory.systemTemp.createTempSync(
        'memex_user_message_image_',
      );
      try {
        await FileSystemService.init(tempDir.path);
        const relativePath = 'workspace/_alice/Facts/assets/photo.jpg';

        expect(
          superAgentUserMessageImageSourceForLocalDisplay(relativePath),
          p.join(tempDir.path, relativePath),
        );
        expect(
          superAgentUserMessageImageSourceForLocalDisplay(
            'https://example.com/photo.jpg',
          ),
          'https://example.com/photo.jpg',
        );
      } finally {
        await LocalAssetServer.stopServer();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
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

    testWidgets('renders a legacy schedule artifact without a dead link', (
      tester,
    ) async {
      await _pumpDialog(
        tester,
        dialog: AgentChatDialog(
          initialItems: [
            AIMessageItem(
              'I updated your schedule.',
              artifacts: [
                ArtifactItem(
                  ChatArtifact.schedule(
                    title: 'Schedule presentation',
                    summary: 'Pending schedule items: 3',
                    updated: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('I updated your schedule.'), findsOneWidget);
      expect(find.text('${UserStorage.l10n.agentChat.result} · 1'),
          findsOneWidget);
      expect(find.text(UserStorage.l10n.schedule), findsOneWidget);
      expect(find.text('Schedule presentation'), findsOneWidget);
      expect(find.text('Pending schedule items: 3'), findsOneWidget);
      expect(find.text(UserStorage.l10n.artifactOpen), findsNothing);
    });

    testWidgets('renders a system action with inline confirmation controls', (
      tester,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      addTearDown(db.close);
      await SystemActionService.instance.createAction(
        id: 'calendar-action-1',
        type: 'calendar',
        data: const {
          'title': 'Team review',
          'start_time': '2026-08-01 15:30:00',
        },
      );

      await _pumpDialog(
        tester,
        dialog: AgentChatDialog(
          initialItems: [
            AIMessageItem(
              'Ready for confirmation.',
              artifacts: [
                ArtifactItem(
                  ChatArtifact.systemAction(
                    actionId: 'calendar-action-1',
                    systemActionKind: 'calendar',
                    title: 'Team review',
                    summary: '2026-08-01 15:30',
                    updated: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      expect(
        find.text(UserStorage.l10n.discoveredCalendarEvent),
        findsOneWidget,
      );
      expect(
        find.text(UserStorage.l10n.agentChat.calendarEventCreated),
        findsNothing,
      );
      expect(find.text('Team review'), findsOneWidget);
      expect(
        find.text(UserStorage.l10n.systemActionPendingExplanation),
        findsOneWidget,
      );
      expect(find.text(UserStorage.l10n.addToCalendar), findsOneWidget);
      expect(find.text(UserStorage.l10n.ignore), findsOneWidget);
    });

    testWidgets('opens knowledge file artifacts with normalized PKM path', (
      tester,
    ) async {
      await _pumpDialog(
        tester,
        dialog: AgentChatDialog(
          initialItems: [
            AIMessageItem(
              'I updated the knowledge file.',
              artifacts: [
                ArtifactItem(
                  ChatArtifact.knowledgeFile(
                    path: 'PKM/Projects/memex.md',
                    title: 'memex.md',
                    summary: '# Memex',
                    updated: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('I updated the knowledge file.'), findsOneWidget);
      expect(find.text('${UserStorage.l10n.agentChat.result} · 1'),
          findsOneWidget);
      expect(
        find.text(UserStorage.l10n.agentChat.documentUpdated),
        findsOneWidget,
      );
      expect(find.text('memex.md'), findsOneWidget);
      expect(find.text('PKM/Projects/memex.md'), findsOneWidget);
      expect(find.text(UserStorage.l10n.artifactOpen), findsOneWidget);

      await tester.tap(find.text(UserStorage.l10n.artifactOpen));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final page = tester.widget<KnowledgeFilePage>(
        find.byType(KnowledgeFilePage),
      );
      expect(page.filePath, 'Projects/memex.md');
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
  Widget dialog = const AgentChatDialog(),
  MediaQueryData? mediaQueryData,
}) async {
  await _pumpDialogFrame(
    tester,
    viewportSize: viewportSize,
    dialog: dialog,
    mediaQueryData: mediaQueryData,
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpDialogFrame(
  WidgetTester tester, {
  Size viewportSize = const Size(390, 800),
  Widget dialog = const AgentChatDialog(),
  MediaQueryData? mediaQueryData,
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
        body: mediaQueryData == null
            ? dialog
            : MediaQuery(data: mediaQueryData, child: dialog),
      ),
    ),
  );
  await tester.pump();
}
