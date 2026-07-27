import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/sandbox_user_clone_service.dart';
import 'package:memex/domain/models/reprocess_cards_options.dart';
import 'package:memex/ui/settings/view_models/debug_settings_viewmodel.dart';
import 'package:memex/ui/settings/widgets/reprocess_cards_dialog.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  test('createReprocessCardsTask starts Super Agent reprocess', () async {
    await UserStorage.saveUser('debug-viewmodel-user');
    final dataController = _RecordingDebugSettingsDataController();
    final viewModel = DebugSettingsViewModel(dataController: dataController);

    final created = await viewModel.createReprocessCardsTask(
      const ReprocessCardsDebugOptions(limit: 5, reanalyzeAssets: true),
    );

    expect(created, isTrue);
    expect(viewModel.isReprocessingCards, isFalse);
    expect(dataController.superAgentReprocesses, hasLength(1));
    expect(dataController.enqueuedTasks, isEmpty);

    final options = dataController.superAgentReprocesses.single;
    expect(options.limit, 5);
    expect(options.reanalyzeAssets, isTrue);
    expect(options.scope, ReprocessCardsScope.cardsOnly);
  });

  test('createReprocessCardsTask requires a user and resets loading', () async {
    final dataController = _RecordingDebugSettingsDataController();
    final viewModel = DebugSettingsViewModel(dataController: dataController);

    await expectLater(
      viewModel.createReprocessCardsTask(const ReprocessCardsDebugOptions()),
      throwsA(isA<DebugSettingsUserNotFoundException>()),
    );

    expect(viewModel.isReprocessingCards, isFalse);
    expect(dataController.enqueuedTasks, isEmpty);
    expect(dataController.superAgentReprocesses, isEmpty);
  });

  test('related follow-up prompt only names available agent capabilities', () {
    const options = ReprocessCardsDebugOptions(
      scope: ReprocessCardsScope.cardsAndRelatedFollowUps,
    );

    final message = options.toSuperAgentMessage();

    expect(message, contains('related PKM or knowledge insight'));
    expect(message.toLowerCase(), isNot(contains('schedule')));
  });

  test('date range task options format payload consistently', () {
    final payload = DebugDateRangeTaskOptions(
      dateFrom: DateTime(2026, 6, 1),
      dateTo: DateTime(2026, 6, 16),
      limit: 25,
    ).toTaskPayload();

    expect(payload['date_from'], '2026-06-01');
    expect(payload['date_to'], '2026-06-16');
    expect(payload['limit'], 25);
    expect(
      DebugDateRangeTaskOptions.formatDate(DateTime(2026, 1, 9)),
      '2026-01-09',
    );
  });

  test('clearToken clears user and resets router state', () async {
    await UserStorage.saveUser('debug-viewmodel-user');
    final dataController = _RecordingDebugSettingsDataController();
    final viewModel = DebugSettingsViewModel(dataController: dataController);

    await viewModel.clearToken();

    expect(await UserStorage.getUserId(), isNull);
    expect(dataController.resetForLogoutCount, 1);
  });

  test('clearData requires user and clears local data', () async {
    await UserStorage.saveUser('debug-viewmodel-user');
    final dataController = _RecordingDebugSettingsDataController();
    final viewModel = DebugSettingsViewModel(dataController: dataController);

    final cleared = await viewModel.clearData();

    expect(cleared, isTrue);
    expect(viewModel.isClearingData, isFalse);
    expect(dataController.clearDataCount, 1);
  });

  test('cloneToTestUser clones, switches user, and resets router state',
      () async {
    await UserStorage.saveUser('debug-viewmodel-user');
    final dataController = _RecordingDebugSettingsDataController(
      cloneResult: const SandboxUserCloneResult(
        sourceUserId: 'debug-viewmodel-user',
        targetUserId: 'test_clone',
        sourceWorkspacePath: '/source',
        targetWorkspacePath: '/target',
        copiedFiles: 2,
        copiedDirectories: 1,
        skippedPaths: [],
      ),
    );
    final viewModel = DebugSettingsViewModel(dataController: dataController);

    final result = await viewModel.cloneToTestUser(
      targetUserId: 'test_clone',
      overwriteTarget: true,
    );

    expect(result?.targetUserId, 'test_clone');
    expect(await UserStorage.getUserId(), 'test_clone');
    expect(viewModel.isCloningTestUser, isFalse);
    expect(dataController.cloneRequests, hasLength(1));
    expect(dataController.cloneRequests.single.targetUserId, 'test_clone');
    expect(dataController.cloneRequests.single.overwriteTarget, isTrue);
    expect(dataController.resetForLogoutCount, 1);
  });

  test('clearFailedAgentContexts returns cleared count', () async {
    final dataController = _RecordingDebugSettingsDataController(
      clearedFailedAgentContexts: 3,
    );
    final viewModel = DebugSettingsViewModel(dataController: dataController);

    final clearedCount = await viewModel.clearFailedAgentContexts();

    expect(clearedCount, 3);
    expect(viewModel.isClearingFailedAgentContexts, isFalse);
    expect(dataController.clearFailedAgentContextsCount, 1);
  });

  test('creates comments reprocess task', () async {
    await UserStorage.saveUser('debug-viewmodel-user');
    final dataController = _RecordingDebugSettingsDataController();
    final viewModel = DebugSettingsViewModel(dataController: dataController);
    final options = DebugDateRangeTaskOptions(
      dateFrom: DateTime(2026, 6, 1),
      dateTo: DateTime(2026, 6, 16),
    );

    expect(await viewModel.createReprocessCommentsTask(options), isTrue);

    expect(dataController.enqueuedTasks, hasLength(1));
    expect(
      dataController.enqueuedTasks.single.taskType,
      'reprocess_comments_task',
    );
    expect(
      dataController.enqueuedTasks.single.bizId,
      startsWith('reprocess_comments_'),
    );
    expect(
      dataController.enqueuedTasks.single.payload['date_to'],
      '2026-06-16',
    );
  });

  test('rebuildSearchIndex delegates to data controller', () async {
    final dataController = _RecordingDebugSettingsDataController();
    final viewModel = DebugSettingsViewModel(dataController: dataController);

    final rebuilt = await viewModel.rebuildSearchIndex();

    expect(rebuilt, isTrue);
    expect(viewModel.isRebuildingSearchIndex, isFalse);
    expect(dataController.rebuildAllFtsIndexesCount, 1);
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

class _CloneRequest {
  const _CloneRequest({
    required this.targetUserId,
    required this.overwriteTarget,
  });

  final String targetUserId;
  final bool overwriteTarget;
}

class _RecordingDebugSettingsDataController
    implements DebugSettingsDataController {
  _RecordingDebugSettingsDataController({
    this.clearedFailedAgentContexts = 0,
    this.cloneResult = const SandboxUserCloneResult(
      sourceUserId: 'debug-viewmodel-user',
      targetUserId: 'test',
      sourceWorkspacePath: '/source',
      targetWorkspacePath: '/target',
      copiedFiles: 0,
      copiedDirectories: 0,
      skippedPaths: [],
    ),
  });

  final enqueuedTasks = <_QueuedDebugTask>[];
  final superAgentReprocesses = <ReprocessCardsDebugOptions>[];
  final cloneRequests = <_CloneRequest>[];
  final int clearedFailedAgentContexts;
  final SandboxUserCloneResult cloneResult;
  int clearDataCount = 0;
  int clearFailedAgentContextsCount = 0;
  int rebuildAllFtsIndexesCount = 0;
  int resetForLogoutCount = 0;

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
  Future<void> clearData() async {
    clearDataCount++;
  }

  @override
  Future<int> clearFailedAgentConversationContexts() async {
    clearFailedAgentContextsCount++;
    return clearedFailedAgentContexts;
  }

  @override
  Future<SandboxUserCloneResult> cloneToTestUser({
    required String targetUserId,
    required bool overwriteTarget,
  }) async {
    cloneRequests.add(
      _CloneRequest(
        targetUserId: targetUserId,
        overwriteTarget: overwriteTarget,
      ),
    );
    return cloneResult;
  }

  @override
  Future<void> rebuildAllFtsIndexes() async {
    rebuildAllFtsIndexesCount++;
  }

  @override
  void resetForLogout() {
    resetForLogoutCount++;
  }
}
