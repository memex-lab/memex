import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
  group('MemexRouter initialization source ordering', () {
    test('task handlers are registered before LocalTaskExecutor starts', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      final handlerRegistration = source.indexOf(
        '_registerTaskHandlers(LocalTaskExecutor.instance);',
      );
      final executorStart = source.indexOf(
        'await LocalTaskExecutor.instance.start(userId: userId);',
      );

      expect(handlerRegistration, isNonNegative);
      expect(executorStart, isNonNegative);
      expect(handlerRegistration, lessThan(executorStart));
    });

    test('primary companion wake loop is restored after task startup', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();
      final executorStart = source.indexOf(
        'await LocalTaskExecutor.instance.start(userId: userId);',
      );
      final wakeRestore = source.indexOf(
        'CharacterInitiativeService.instance.ensureScheduled(',
      );

      expect(executorStart, isNonNegative);
      expect(wakeRestore, isNonNegative);
      expect(executorStart, lessThan(wakeRestore));
    });

    test('history acquaintance is scheduled before the initiative wake', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();
      final acquaintance = source.indexOf(
        'CharacterHistoryAcquaintanceService.instance.ensureScheduled(',
      );
      final initiative = source.indexOf(
        'CharacterInitiativeService.instance.ensureScheduled(',
      );

      expect(acquaintance, isNonNegative);
      expect(initiative, isNonNegative);
      expect(acquaintance, lessThan(initiative));
    });

    test('sendMessage waits for full router initialization before delegating',
        () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      final sendMessage = source.indexOf('Stream<ChatEvent> sendMessage(');
      final ensureInitialized = source.indexOf(
        'await _ensureFullyInitialized();',
        sendMessage,
      );
      final delegate = source.indexOf(
        'yield* ChatService.instance.sendMessage(',
        sendMessage,
      );

      expect(sendMessage, isNonNegative);
      expect(ensureInitialized, isNonNegative);
      expect(delegate, isNonNegative);
      expect(ensureInitialized, lessThan(delegate));
    });

    test('timeline init completes core before awaiting deferred work', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      final initCore = source.indexOf('Future<String?> _initCore() async {');
      final completeCore = source.indexOf('coreCompleter.complete();');
      final awaitDeferred = source.indexOf('await _initDeferred(');
      final customAgents = source.indexOf(
        'await CustomAgentConfigService.instance.registerAll(userId);',
      );
      final migrate = source.indexOf('await migrateCardsToFactAssets(userId);');

      expect(initCore, isNonNegative);
      expect(completeCore, isNonNegative);
      expect(awaitDeferred, isNonNegative);
      expect(completeCore, lessThan(awaitDeferred));
      expect(migrate, greaterThan(initCore));
      expect(customAgents, greaterThan(awaitDeferred));
    });

    test('fetchTimelineCards waits only for core initialization', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      final fetch = source.indexOf(
        'Future<Result<List<TimelineCardModel>>> fetchTimelineCards(',
      );
      final ensureCore = source.indexOf(
        'await _ensureInitialized();',
        fetch,
      );
      final ensureFull = source.indexOf(
        'await _ensureFullyInitialized();',
        fetch,
      );
      final nextMethod = source.indexOf(
        'Future<Result<Map<String, dynamic>>> fetchAggregatedTimeline(',
        fetch,
      );

      expect(fetch, isNonNegative);
      expect(ensureCore, isNonNegative);
      expect(ensureCore, lessThan(nextMethod));
      expect(ensureFull == -1 || ensureFull > nextMethod, isTrue);
    });
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
      await root.delete(recursive: true);
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
