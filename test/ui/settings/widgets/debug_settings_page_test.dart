import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/sandbox_user_clone_service.dart';
import 'package:memex/domain/models/reprocess_cards_options.dart';
import 'package:memex/ui/settings/widgets/debug_settings_page.dart';
import 'package:memex/ui/settings/widgets/debug_settings_screen.dart';
import 'package:memex/ui/settings/widgets/reprocess_cards_dialog.dart';
import 'package:memex/ui/settings/widgets/settings_search_screen.dart';
import 'package:memex/ui/settings/view_models/debug_settings_viewmodel.dart';
import 'package:memex/ui/settings/view_models/settings_search_viewmodel.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  testWidgets('clears failed agent contexts from debugging page', (
    tester,
  ) async {
    var clearCount = 0;

    await _pumpDebugPage(
      tester,
      onClearFailedAgentContexts: () async {
        clearCount += 1;
      },
    );

    final clearButton = find.text(UserStorage.l10n.clearFailedAgentContexts);
    await tester.scrollUntilVisible(
      clearButton,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(clearButton, findsOneWidget);

    await tester.tap(clearButton);
    await tester.pump();

    expect(clearCount, 1);
  });

  testWidgets('disables clear failed contexts while loading', (tester) async {
    var clearCount = 0;

    await _pumpDebugPage(
      tester,
      isClearingFailedAgentContexts: true,
      onClearFailedAgentContexts: () async {
        clearCount += 1;
      },
    );

    final clearButton = find.text(UserStorage.l10n.clearFailedAgentContexts);
    await tester.scrollUntilVisible(
      clearButton,
      250,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(clearButton);
    await tester.pump();

    expect(clearCount, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'search result Debug reprocess cards opens dialog and creates task',
    (tester) async {
      final dataController = _RecordingDebugSettingsDataController();
      await UserStorage.saveUser('debug-search-user');

      await tester.pumpWidget(
        MaterialApp(
          home: DebugSettingsActionScope(
            dataController: dataController,
            child: SettingsSearchScreen(
              viewModel: SettingsSearchViewModel.forTesting(),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'debug');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Debug').first);
      await tester.pumpAndSettle();

      expect(find.text('Debugging'), findsOneWidget);

      final reprocessCards = find.text(UserStorage.l10n.reprocessCards);
      await tester.scrollUntilVisible(
        reprocessCards,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(reprocessCards);
      await tester.pumpAndSettle();

      expect(find.byType(ReprocessCardsDialog), findsOneWidget);

      await tester.tap(find.text(UserStorage.l10n.startProcessing));
      await tester.pumpAndSettle();

      expect(dataController.enqueuedTasks, isEmpty);
      expect(dataController.superAgentReprocesses, hasLength(1));
      expect(
        dataController.superAgentReprocesses.single.scope,
        ReprocessCardsScope.cardsOnly,
      );
      expect(
        find.text(UserStorage.l10n.reprocessCardsTaskCreated),
        findsOneWidget,
      );
    },
  );

  testWidgets('reprocess cards dialog defaults to card-only mode', (
    tester,
  ) async {
    ReprocessCardsDebugOptions? submitted;

    await _pumpReprocessCardsLauncher(
      tester,
      onSubmitted: (options) {
        submitted = options;
      },
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text(UserStorage.l10n.reprocessCardsCardOnly), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.reprocessCardsRerunDownstream),
      findsOneWidget,
    );

    await tester.tap(find.text(UserStorage.l10n.startProcessing));
    await tester.pumpAndSettle();

    expect(submitted, isNotNull);
    expect(submitted!.scope, ReprocessCardsScope.cardsOnly);
    expect(
      submitted!.toTaskPayload(),
      containsPair(
        ReprocessCardsPayloadKeys.scope,
        ReprocessCardsScope.cardsOnly.payloadValue,
      ),
    );
  });

  testWidgets('reprocess cards dialog submits related follow-up scope', (
    tester,
  ) async {
    ReprocessCardsDebugOptions? submitted;

    await _pumpReprocessCardsLauncher(
      tester,
      onSubmitted: (options) {
        submitted = options;
      },
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('reprocess_cards_limit_field')),
      '3',
    );
    await tester.tap(
      find.byKey(const Key('reprocess_cards_reanalyze_assets_switch')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('reprocess_cards_mode_related_follow_ups')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.byKey(const Key('reprocess_cards_mode_related_follow_ups')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserStorage.l10n.startProcessing));
    await tester.pumpAndSettle();

    final payload = submitted!.toTaskPayload();
    expect(
      payload[ReprocessCardsPayloadKeys.scope],
      ReprocessCardsScope.cardsAndRelatedFollowUps.payloadValue,
    );
    expect(payload['limit'], 3);
    expect(payload['reanalyze_assets'], isTrue);
  });
}

class _QueuedDebugTask {
  const _QueuedDebugTask({
    required this.taskType,
    required this.payload,
    this.bizId,
  });

  final String taskType;
  final Map<String, dynamic> payload;
  final String? bizId;
}

class _RecordingDebugSettingsDataController
    implements DebugSettingsDataController {
  final enqueuedTasks = <_QueuedDebugTask>[];
  final superAgentReprocesses = <ReprocessCardsDebugOptions>[];

  @override
  Future<void> enqueueTask({
    required String taskType,
    required Map<String, dynamic> payload,
    String? bizId,
  }) async {
    enqueuedTasks.add(
      _QueuedDebugTask(
        taskType: taskType,
        payload: Map<String, dynamic>.from(payload),
        bizId: bizId,
      ),
    );
  }

  @override
  Future<void> startSuperAgentReprocess({
    required ReprocessCardsDebugOptions options,
  }) async {
    superAgentReprocesses.add(options);
  }

  @override
  Future<void> clearData() async {}

  @override
  Future<int> clearFailedAgentConversationContexts() async => 0;

  @override
  Future<SandboxUserCloneResult> cloneToTestUser({
    required String targetUserId,
    required bool overwriteTarget,
  }) async {
    return SandboxUserCloneResult(
      sourceUserId: 'debug-widget-user',
      targetUserId: targetUserId,
      sourceWorkspacePath: '/source',
      targetWorkspacePath: '/target',
      copiedFiles: 0,
      copiedDirectories: 0,
      skippedPaths: const [],
    );
  }

  @override
  Future<void> rebuildAllFtsIndexes() async {}

  @override
  Future<void> changeLocalUser(String? userId) async {}
}

Future<void> _pumpDebugPage(
  WidgetTester tester, {
  Future<void> Function()? onClearFailedAgentContexts,
  bool isClearingFailedAgentContexts = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: DebugSettingsPage(
        onClearToken: () async {},
        onClearData: () async {},
        onClearFailedAgentContexts: onClearFailedAgentContexts ?? () async {},
        onCloneToTestUser: () async {},
        onReprocessCards: () async {},
        onReprocessComments: () async {},
        onRebuildSearchIndex: () async {},
        isClearingData: false,
        isClearingFailedAgentContexts: isClearingFailedAgentContexts,
        isCloningTestUser: false,
        isReprocessingCards: false,
        isReprocessingComments: false,
        isRebuildingSearchIndex: false,
      ),
    ),
  );
}

Future<void> _pumpReprocessCardsLauncher(
  WidgetTester tester, {
  required void Function(ReprocessCardsDebugOptions options) onSubmitted,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final options = await showReprocessCardsDialog(context);
            if (options != null) onSubmitted(options);
          },
          child: const Text('Open'),
        ),
      ),
    ),
  );
}
