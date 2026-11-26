import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/repositories/card.dart';
import 'package:memex/data/repositories/get_timeline_cards.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/data/services/capture_card_status.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/utils/network_reachability.dart';
import 'package:memex/main.dart' show RootShell;
import 'package:memex/ui/user_setup/widgets/user_setup_screen.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_base_screen.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_file_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/data/services/search_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/ui/timeline/widgets/timeline_screen.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/character/view_models/persona_avatar_viewmodel.dart';
import 'package:memex/ui/core/widgets/local_image.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';
import 'package:memex/ui/settings/widgets/settings_page.dart';
import 'package:memex/utils/user_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/journal_model_fixture.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.root);
  final String root;
  @override
  Future<String?> getApplicationDocumentsPath() async => root;
  @override
  Future<String?> getApplicationSupportPath() async => root;
  @override
  Future<String?> getTemporaryPath() async =>
      (await Directory('$root/tmp').create(recursive: true)).path;
}

Future<void> waitFor(WidgetTester tester, Finder target) async {
  for (var i = 0; i < 100 && target.evaluate().isEmpty; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(target, findsWidgets);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const user = 'detail-reader';
  late Directory customRoot;
  late Directory appDir;
  late String id;
  late String photo;
  late TimelineViewModel timeline;
  late InsightViewModel insight;
  late PersonaAvatarViewModel persona;

  setUp(() async {
    final root = await Directory.systemTemp.createTemp('memex-detail-screen');
    addTearDown(() async {
      try {
        await root.delete(recursive: true);
      } on PathNotFoundException {
        if (await root.exists()) await root.delete(recursive: true);
      }
    });
    final paths = PathProviderPlatform.instance;
    appDir = await Directory('${root.path}/documents').create();
    customRoot = await Directory('${root.path}/selected').create();
    PathProviderPlatform.instance = _Paths(appDir.path);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (_) async => 0);
    for (final name in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events'
    ]) {
      messenger.setMockMethodCallHandler(
          MethodChannel(name), (_) async => null);
    }
    messenger.setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'), (call) async {
      if (call.method == 'create') {
        final player = call.arguments['playerId'];
        messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$player'),
            (_) async => null);
      }
      return null;
    });
    addTearDown(() => PathProviderPlatform.instance = paths);
    AppFlavor.init('global');
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
    await UserStorage.saveUser(user);
    await UserStorage.setWorkspaceStorageToCustom(user, customRoot.path);
    final router = MemexRouter();
    await router.ensureInitialized();
    await LocalTaskExecutor.instance.stopAndWaitForActiveTasks();
    addTearDown(() async {
      router.resetForLogout();
      await LocalAssetServer.stopServer();

      await AppDatabase.closeCurrent();
    });
    final fs = FileSystemService.instance;
    id = await fs.allocateCardFactId(user);
    final source = File('${root.path}/camera.png');
    await source.writeAsBytes(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='));
    final saved = await fs.saveAssetFromFile(
        userId: user, sourcePath: source.path, assetType: 'img');
    photo = saved.$1;
    await fs.updateCardFile(
        user,
        id,
        (c) => c.copyWith(
            fact: 'An evening walk',
            status: 'completed',
            assets: ['![image](fs://$photo)']));
    timeline = TimelineViewModel(router: router, autoLoad: false);
    insight = InsightViewModel(router: router);
    persona = PersonaAvatarViewModel(router: router);
    addTearDown(timeline.dispose);
    addTearDown(insight.dispose);
    addTearDown(persona.dispose);
    await timeline.load.execute();
  });

  testWidgets('post a comment in detail and read it after reopening the screen',
      (tester) async {
    Widget screen() => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
              body: TimelineScreen(
                  viewModel: timeline,
                  insightViewModel: insight,
                  personaAvatarViewModel: persona,
                  onInputTap: () {})),
        );
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    final autoTitle = find.text(UserStorage.l10n.enableCharacterCommentTitle);
    await tester.scrollUntilVisible(autoTitle, 200);
    await tester.tap(autoTitle);
    final tile =
        find.ancestor(of: autoTitle, matching: find.byType(SwitchListTile));
    Future<void> waitForDisabledSetting() async {
      for (var i = 0;
          i < 100 && tester.widget<SwitchListTile>(tile).value;
          i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump();
      }
      expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    }

    await waitForDisabledSetting();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.scrollUntilVisible(autoTitle, 200);
    await waitForDisabledSetting();
    final delete = find.text(UserStorage.l10n.deleteAccount);
    await tester.scrollUntilVisible(delete, 300);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    final confirm =
        find.widgetWithText(TextButton, UserStorage.l10n.deleteAccount);
    expect(tester.widget<TextButton>(confirm).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'wrong user');
    await tester.pump();
    expect(tester.widget<TextButton>(confirm).onPressed, isNull);
    await tester.enterText(find.byType(TextField), user);
    await tester.pump();
    expect(tester.widget<TextButton>(confirm).onPressed, isNotNull);
    await tester.tap(find.widgetWithText(TextButton, UserStorage.l10n.cancel));
    await tester.pumpAndSettle();
    expect(await UserStorage.getUserId(), user);
    await tester.pumpWidget(screen());
    final listing = find.byKey(ValueKey(id));
    await waitFor(tester, listing.hitTestable());
    await tester.tap(listing);
    await tester.pump();
    final compose = find.descendant(
        of: find.byType(TimelineCardDetailScreen),
        matching: find.text(UserStorage.l10n.saySomething));
    await waitFor(tester, compose);
    final image = find.descendant(
        of: find.byType(TimelineCardDetailScreen),
        matching: find.byWidgetPredicate((w) =>
            w is LocalImage && Uri.parse(w.url).pathSegments.last == photo));
    await waitFor(tester, image);
    expect(
        Uri.parse(tester.widget<LocalImage>(image.first).url).pathSegments.last,
        photo);
    await tester.tap(compose);
    await waitFor(tester, find.byType(TextField));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.enterText(find.byType(TextField), 'Take the river path');
    await tester.tap(find.byIcon(Icons.send_rounded));
    final posted = find.text('Take the river path', findRichText: true);
    for (var i = 0;
        i < 100 && find.byType(TextField).evaluate().isNotEmpty;
        i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(TextField), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await waitFor(tester, listing.hitTestable());
    await tester.tap(listing);
    await tester.pump();
    await waitFor(tester, compose);
    await tester.pump(const Duration(milliseconds: 400));
    await waitFor(tester, image);
    final body = find
        .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable))
        .first;
    await waitFor(tester, body);
    await tester.scrollUntilVisible(posted, 200, scrollable: body);
    expect(posted, findsWidgets);
  });
  testWidgets(
      'search the knowledge base and open the matching Markdown document',
      (tester) async {
    final fs = FileSystemService.instance;
    final doc = File('${fs.getPkmPath(user)}/Projects/field-notes.md');
    await tester.runAsync(() async {
      await doc.create(recursive: true);
      await doc.writeAsString(
          '# Field observations\n\nHawthorn blossoms beside the river.');
    });
    final vm = KnowledgeBaseViewModel(router: MemexRouter());
    addTearDown(vm.dispose);
    await tester
        .pumpWidget(MaterialApp(home: KnowledgeBaseScreen(viewModel: vm)));
    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'no-such-bloom');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 425));
    await waitFor(
        tester, find.text(UserStorage.l10n.noSearchResults('no-such-bloom')));
    await tester.enterText(find.byType(TextField), 'Hawthorn');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 425));
    final hit = find.text('field-notes.md');
    await waitFor(tester, hit);
    await tester.tap(hit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await waitFor(
        tester,
        find.descendant(
            of: find.byType(KnowledgeFilePage),
            matching: find.textContaining('Hawthorn blossoms beside the river.',
                findRichText: true)));
    await tester.pumpWidget(const SizedBox.shrink());
    SearchService.instance.reset();
  });
  testWidgets(
      'send a photo offline, replay the queued turn and read the same note and attachment in detail',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    chatNetworkReachabilityCheck = () async => false;
    addTearDown(() => chatNetworkReachabilityCheck = null);
    final source = File('${appDir.parent.path}/camera.png');
    const note = 'The river after rain';
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: AgentChatDialog(
        initialImages: [XFile(source.path)],
        photoSuggestionsForTesting: const [],
      )),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField).first, note);
    await tester.tap(find.byKey(const ValueKey('super_agent_publish_button')));
    final db = AppDatabase.instance;
    final turns = db.select(db.tasks)
      ..where((t) => t.type.equals('super_agent_chat_turn_task'));
    List<Task> rows = [];
    for (var i = 0; i < 150 && rows.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        rows = await turns.get();
      });
    }
    expect(rows.single.status, waitingNetworkTaskStatus);
    expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        isEmpty);
    final payload = jsonDecode(rows.single.payload!) as Map<String, dynamic>;
    expect(payload['message'], note);
    expect(payload['scene'], 'super_agent_home');
    final image = (payload['images'] as List).single;
    final fs = FileSystemService.instance;
    await tester.runAsync(() async {
      final bytes = await source.readAsBytes();
      await source.delete();
      expect(
          await File(fs.toAbsolutePath(image['relative_path'] as String))
              .readAsBytes(),
          bytes);
      final placeholder =
          await fs.readCardFile(user, payload['pre_minted_fact_id'] as String);
      expect(placeholder?.status, waitingForNetworkCardStatus);
    });
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    await tester.runAsync(() async {
      final target = payload['pre_minted_fact_id'] as String;
      final fixture =
          JournalModelFixture(target, note, image['fs_filename'] as String);
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen(fixture.respond);
      final executor = LocalTaskExecutor.instance;
      final previousCheck = executor.reachabilityCheck;
      try {
        await UserStorage.saveLLMConfigs([
          LLMConfig(
              key: LLMConfig.defaultClientKey,
              type: LLMConfig.typeChatCompletion,
              modelId: 'journal-test',
              apiKey: 'fixture',
              baseUrl: 'http://127.0.0.1:${server.port}/v1'),
        ]);
        executor.reachabilityCheck = () async => true;
        await HttpOverrides.runWithHttpOverrides(() async {
          await executor.start(userId: user);
          final deadline = DateTime.now().add(const Duration(seconds: 35));
          Task turn;
          do {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            turn = await turns.getSingle();
          } while (turn.status != 'completed' &&
              turn.status != 'failed' &&
              DateTime.now().isBefore(deadline));
          expect(turn.status, 'completed',
              reason: '${turn.error}; model calls ${fixture.calls}');
          expect(fixture.calls, contains('save_timeline_card'));
          final cards = await getTimelineCards();
          expect(cards.map((c) => c.id), contains(target),
              reason: fixture.toolResults.join('\n'));
          final card = cards.singleWhere((c) => c.id == target);
          expect(card.rawText, note);
          final detail = await getCardDetail(card.id);
          expect(detail.rawContent, note);
          expect(Uri.parse(detail.assets.single.url).pathSegments.last,
              image['fs_filename']);
        }, JournalHttpOverrides(server.port));
      } finally {
        await executor.stopAndWaitForActiveTasks();
        executor.reachabilityCheck = previousCheck;
        await server.close(force: true).timeout(const Duration(seconds: 5));
      }
    });
    // Drift may deliver stream cancellation in the widget binding's clock.
    // Keep both clocks moving until the disk connection has really closed.
    bool closed = false;
    final closing = AppDatabase.closeCurrent().then((_) => closed = true);
    for (var i = 0; i < 150 && !closed; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
    }
    expect(closed, isTrue, reason: 'journal database closed after replay');
    await closing;
  });

  testWidgets(
      'confirm account deletion keeps siblings, backups, and the selected folder',
      (tester) async {
    final workspace =
        Directory(FileSystemService.instance.getWorkspacePath(user));
    final sibling = File(
        '${FileSystemService.instance.getWorkspacePath("other")}/journal.md');
    final backup = File('${customRoot.path}/saved-backup.zip');
    final personal = File('${customRoot.path}/personal.txt');
    final otherDb = File('${appDir.path}/memex_local_other.sqlite');
    final database = File('${appDir.path}/memex_local_$user.sqlite');
    await tester.runAsync(() async {
      for (final file in [sibling, backup, personal, otherDb]) {
        await file.create(recursive: true);
        await file.writeAsString('keep');
      }
      await UserStorage.setWorkspaceStorageToCustom('other', customRoot.path);
      expect(await workspace.exists(), isTrue);
      expect(await database.exists(), isTrue);
    });
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    final delete = find.text(UserStorage.l10n.deleteAccount);
    await tester.scrollUntilVisible(delete, 300);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), user);
    await tester.pump();
    await tester
        .tap(find.widgetWithText(TextButton, UserStorage.l10n.deleteAccount));
    for (var i = 0; i < 150 && await UserStorage.getUserId() != null; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(await UserStorage.getUserId(), isNull);
    await tester.runAsync(() async {
      expect(await workspace.exists(), isFalse);
      for (final suffix in ['', '-wal', '-shm', '-journal']) {
        expect(await File('${database.path}$suffix').exists(), isFalse);
      }
      for (final file in [sibling, backup, personal, otherDb]) {
        expect(await file.readAsString(), 'keep');
      }
      expect(await UserStorage.resolveDataRoot('other'), customRoot.path);
    });
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RootShell(),
    ));
    await waitFor(tester, find.byType(UserSetupScreen));
  });
}
