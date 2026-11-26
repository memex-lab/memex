import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/data/services/character_history_acquaintance_service.dart';
import 'package:memex/data/services/character_initiative_service.dart';

import 'package:memex/config/app_flavor.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/ui/settings/view_models/debug_settings_viewmodel.dart';
import 'package:memex/utils/user_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/workspace_test_paths.dart';

void main() {
  test(
      'cold start serves migrated cards and queued search before chat and companion startup finish',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppFlavor.init('global');
    final root = await Directory.systemTemp.createTemp('memex-cold-start');
    final previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = WorkspaceTestPaths(root.path);
    addTearDown(() async {
      PathProviderPlatform.instance = previous;
      await _deleteTestRoot(root);
    });
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
    const user = 'reader';
    await UserStorage.saveUser(user);
    await UserStorage.setWorkspaceStorageToCustom(user, root.path);
    final fs = FileSystemService.detached(dataRoot: root.path);
    const id = '2026/05/18.md#ts_1';
    final daily = File('${fs.getFactsPath(user)}/2026/05/18.md');
    await daily.parent.create(recursive: true);
    await daily.writeAsString('## <id:ts_1> 09:08:07\n\nMorning walk');
    await fs.writeYamlFile(
        fs.getCardPath(user, id),
        const CardData(
          factId: id,
          timestamp: 0,
          status: 'completed',
          tags: [],
          uiConfigs: [],
        ).toJson());
    // Queue a real indexing job in the previous session's database.
    await AppDatabase.init(user);
    final task = await LocalTaskExecutor.instance
        .enqueueTask(userId: user, taskType: 'fts_index_update', payload: {
      'op': 'insert',
      'ns': 'card',
      'document_key': 'queued-card',
      'after': {'fact': 'orchidmarker'},
    });
    await AppDatabase.closeCurrent();
    final entered = Completer<void>();
    final release = Completer<void>();
    final router = MemexRouter.forTesting(
        reconcilePendingReplies: ({required userId}) async {
      entered.complete();
      await release.future;
    });
    addTearDown(() async {
      if (!release.isCompleted) release.complete();
      await router.changeLocalUser(null);
      await LocalAssetServer.stopServer();
    });
    await entered.future.timeout(const Duration(seconds: 10));
    var chatReplied = false;
    final chat = router.sendMessage('').first.then((event) {
      chatReplied = true;
      return event;
    });
    final cards =
        (await router.fetchTimelineCards().timeout(const Duration(seconds: 5)))
            .valueOrThrow;
    expect(cards.singleWhere((card) => card.id == id).rawText, 'Morning walk');
    final db = AppDatabase.instance;
    await Future.doWhile(() async {
      final row = await (db.select(db.tasks)..where((t) => t.id.equals(task)))
          .getSingle();
      if (row.status == 'completed') return false;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return true;
    }).timeout(const Duration(seconds: 10));
    expect(
        (await db.searchDao.searchCards('orchidmarker'))
            .map((row) => row['fact_id']),
        contains('queued-card'));
    expect(chatReplied, isFalse);
    release.complete();
    expect(
        await chat.timeout(const Duration(seconds: 5)), isA<ChatErrorEvent>());
    final scheduled = await db.customSelect(
      'SELECT type FROM tasks WHERE type IN (?, ?) ORDER BY rowid',
      variables: [
        Variable.withString(CharacterHistoryAcquaintanceService.taskType),
        Variable.withString(CharacterInitiativeService.taskType)
      ],
    ).get();
    expect(scheduled.map((row) => row.read<String>('type')), [
      CharacterHistoryAcquaintanceService.taskType,
      CharacterInitiativeService.taskType,
    ]);
  });

  test(
      'switching accounts reopens the selected timeline even for the same card ID',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppFlavor.init('global');
    final root = await Directory.systemTemp.createTemp('memex-router-switch');
    final previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = WorkspaceTestPaths(root.path);
    addTearDown(() async {
      PathProviderPlatform.instance = previous;
      await _deleteTestRoot(root);
    });
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
    const user = 'reader';
    const id = '2026/11/26.md#ts_1';
    final customRoot = await Directory('${root.path}/selected').create();
    await UserStorage.setWorkspaceStorageToCustom(user, customRoot.path);
    await UserStorage.saveUser(user);
    final router = MemexRouter();
    addTearDown(() async {
      await LocalTaskExecutor.instance.stopAndWaitForActiveTasks();
      await router.changeLocalUser(null);
      await LocalAssetServer.stopServer();
    });
    await router.ensureInitialized();
    const card = CardData(
        factId: id,
        timestamp: 1,
        status: 'completed',
        tags: [],
        uiConfigs: [],
        fact: 'An evening walk');
    await FileSystemService.instance.safeWriteCardFile(user, id, card);
    Future<List<String?>> visibleText() async =>
        (await router.fetchTimelineCards())
            .valueOrThrow
            .where((card) => card.id == id)
            .map((card) => card.rawText)
            .toList();
    expect(await visibleText(), ['An evening walk']);
    const other = 'another-reader';
    await UserStorage.setWorkspaceStorageToCustom(other, customRoot.path);
    final settings = DebugSettingsViewModel(
        dataController: MemexRouterDebugSettingsDataController(router));
    addTearDown(settings.dispose);
    final executor = LocalTaskExecutor.instance;
    final started = Completer<void>();
    final release = Completer<void>();
    executor.registerHandler('test_account_write', (owner, _, __) async {
      started.complete();
      await release.future;
      final saved = await FileSystemService.instance.safeWriteCardFile(
          owner, id, card.copyWith(fact: 'Finished before logout'));
      if (!saved) throw StateError('Old account write failed');
    });
    final taskId = await executor.enqueueTask(
        userId: user,
        taskType: 'test_account_write',
        payload: {},
        priority: 100);
    await started.future.timeout(const Duration(seconds: 10));
    final leaving = settings.clearToken();
    try {
      // Wait until the worker stops accepting new tasks. Its current task still
      // needs both the old identity and the old database to finish.
      await Future.doWhile(() async {
        if (!executor.isRunning) return false;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        return true;
      }).timeout(const Duration(seconds: 10));
      expect(await UserStorage.getUserId(), user);
      expect(AppDatabase.isInitialized, isTrue);
    } finally {
      release.complete();
      await leaving;
    }
    expect(await UserStorage.getUserId(), isNull);
    await UserStorage.saveUser(other);
    expect(await visibleText(), isEmpty);
    Future<Task?> oldTask() {
      final db = AppDatabase.instance;
      return (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingleOrNull();
    }

    expect(await oldTask(), isNull);
    final fs = FileSystemService.instance;
    await fs.safeWriteCardFile(
        other, id, card.copyWith(fact: 'Another journal', assets: []));
    expect(await visibleText(), ['Another journal']);
    await settings.clearToken();
    await UserStorage.saveUser(user);
    expect(await visibleText(), ['Finished before logout']);
    expect((await oldTask())?.status, 'completed');
    await router.sendMessage('').drain<void>();
  });
}

Future<void> _deleteTestRoot(Directory root) async {
  try {
    await root.delete(recursive: true);
  } on PathNotFoundException {
    if (await root.exists()) await root.delete(recursive: true);
  }
}
