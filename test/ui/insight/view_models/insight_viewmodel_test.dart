import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/user_stats_model.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('memex_insight_vm_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getApplicationDocumentsDirectory':
            case 'getApplicationSupportDirectory':
            case 'getTemporaryDirectory':
              return tempDir.path;
            default:
              return null;
          }
        });
  });

  setUp(() async {
    EventBusService.instance.clearHandlers();
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser('insight_vm_test_user');
    await UserStorage.setLocale(const Locale('en'));
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    EventBusService.instance.clearHandlers();
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'visible stats refresh notifies listeners on insight overview',
    () async {
      final firstSnapshot = _snapshot(totalInputs: 3);
      final secondSnapshot = _snapshot(totalInputs: 8);
      var calls = 0;
      final vm = _buildViewModel((_) async {
        calls += 1;
        return Ok(secondSnapshot);
      });
      vm.statsSnapshot = firstSnapshot;
      vm.selectedSection = InsightSection.insights;

      var notifications = 0;
      vm.addListener(() => notifications += 1);

      await vm.refreshStatsForVisibleInsightPage();

      expect(calls, 1);
      expect(vm.statsSnapshot, secondSnapshot);
      expect(vm.isStatsLoading, isFalse);
      expect(notifications, greaterThanOrEqualTo(2));

      vm.dispose();
    },
  );

  test('stats loading state is visible while refresh is in flight', () async {
    final completer = Completer<Result<UserStatsSnapshot>>();
    final vm = _buildViewModel((_) => completer.future);

    final states = <bool>[];
    vm.addListener(() => states.add(vm.isStatsLoading));

    final refresh = vm.refreshStatsForVisibleInsightPage();
    await Future<void>.delayed(Duration.zero);

    expect(vm.isStatsLoading, isTrue);
    expect(states, contains(true));

    completer.complete(Ok(_snapshot(totalInputs: 6)));
    await refresh;

    expect(vm.isStatsLoading, isFalse);
    expect(states.last, isFalse);

    vm.dispose();
  });

  test(
    'failed stats refresh keeps previous snapshot and exposes error',
    () async {
      final existing = _snapshot(totalInputs: 4);
      final vm = _buildViewModel(
        (_) async => Error<UserStatsSnapshot>(StateError('boom')),
      );
      vm.statsSnapshot = existing;

      await vm.refreshStatsForVisibleInsightPage();

      expect(vm.statsSnapshot, existing);
      expect(vm.statsErrorMessage, UserStorage.l10n.dataLoadFailedRetry);
      expect(vm.isStatsLoading, isFalse);

      vm.dispose();
    },
  );

  test(
    'failed first stats refresh leaves no snapshot and exits loading',
    () async {
      final vm = _buildViewModel(
        (_) async => Error<UserStatsSnapshot>(StateError('boom')),
      );
      vm.statsSnapshot = null;

      await vm.refreshStatsForVisibleInsightPage();

      expect(vm.statsSnapshot, isNull);
      expect(vm.statsErrorMessage, UserStorage.l10n.dataLoadFailedRetry);
      expect(vm.isStatsLoading, isFalse);

      vm.dispose();
    },
  );

  test('selecting the current stats preset does not reload', () async {
    var calls = 0;
    final vm = _buildViewModel((_) async {
      calls += 1;
      return Ok(_snapshot(totalInputs: calls));
    });
    vm.statsRange = UserStatsDateRange.lastDays(30);

    vm.setStatsPresetDays(30);
    await Future<void>.delayed(Duration.zero);

    expect(calls, 0);

    vm.dispose();
  });

  test(
    'selecting a different stats preset updates range and reloads',
    () async {
      var calls = 0;
      final vm = _buildViewModel((range) async {
        calls += 1;
        return Ok(_snapshot(totalInputs: calls, range: range));
      });
      vm.statsRange = UserStatsDateRange.lastDays(7);

      vm.setStatsPresetDays(30);
      await Future<void>.delayed(Duration.zero);

      expect(calls, 1);
      expect(vm.statsRange.dayCount, 30);
      expect(vm.statsSnapshot?.range.dayCount, 30);

      vm.dispose();
    },
  );

  test(
    'selecting a stats preset updates selection before fetch completes',
    () async {
      final completer = Completer<Result<UserStatsSnapshot>>();
      final vm = _buildViewModel((range) => completer.future);
      vm.statsRange = UserStatsDateRange.lastDays(7);

      vm.setStatsPresetDays(90);
      await Future<void>.delayed(Duration.zero);

      expect(vm.statsRange.dayCount, 90);
      expect(vm.isStatsLoading, isTrue);
      expect(vm.statsSnapshot, isNull);

      completer.complete(Ok(_snapshot(totalInputs: 9, range: vm.statsRange)));
      await Future<void>.delayed(Duration.zero);

      expect(vm.isStatsLoading, isFalse);
      expect(vm.statsSnapshot?.range.dayCount, 90);

      vm.dispose();
    },
  );

  test(
    'ignores stale stats responses when presets are changed quickly',
    () async {
      final completers = <int, Completer<Result<UserStatsSnapshot>>>{};
      final vm = _buildViewModel((range) {
        final completer = Completer<Result<UserStatsSnapshot>>();
        completers[range.dayCount] = completer;
        return completer.future;
      });
      vm.statsRange = UserStatsDateRange.lastDays(7);

      vm.setStatsPresetDays(30);
      await Future<void>.delayed(Duration.zero);
      vm.setStatsPresetDays(90);
      await Future<void>.delayed(Duration.zero);

      completers[90]!.complete(
        Ok(_snapshot(totalInputs: 90, range: UserStatsDateRange.lastDays(90))),
      );
      await Future<void>.delayed(Duration.zero);
      completers[30]!.complete(
        Ok(_snapshot(totalInputs: 30, range: UserStatsDateRange.lastDays(30))),
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.statsRange.dayCount, 90);
      expect(vm.statsSnapshot?.range.dayCount, 90);
      expect(vm.statsSnapshot?.summary.totalInputs, 90);
      expect(vm.isStatsLoading, isFalse);

      vm.dispose();
    },
  );
}

InsightViewModel _buildViewModel(UserStatsFetcher fetcher) {
  return InsightViewModel(router: MemexRouter(), userStatsFetcher: fetcher)
    ..isLoading = false;
}

UserStatsSnapshot _snapshot({
  required int totalInputs,
  UserStatsDateRange? range,
}) {
  final resolvedRange =
      range ??
      UserStatsDateRange(
        start: DateTime(2026, 5, 18),
        end: DateTime(2026, 5, 20),
      );
  return UserStatsSnapshot(
    range: resolvedRange,
    summary: UserStatsSummary(
      totalInputs: totalInputs,
      totalWords: totalInputs * 5,
      totalCards: totalInputs ~/ 2,
      totalKnowledgeUnits: totalInputs ~/ 3,
      totalInsights: totalInputs ~/ 4,
      totalCompletedTodos: totalInputs ~/ 5,
      activeDays: totalInputs == 0 ? 0 : 1,
      currentStreakDays: totalInputs == 0 ? 0 : 1,
    ),
    daily: [
      UserStatsDailyPoint(
        date: resolvedRange.end,
        inputs: totalInputs,
        words: totalInputs * 5,
        cards: totalInputs ~/ 2,
        knowledgeUnits: totalInputs ~/ 3,
        insights: totalInputs ~/ 4,
        completedTodos: totalInputs ~/ 5,
      ),
    ],
    sourceBreakdown: UserStatsSourceBreakdown(
      textInputs: totalInputs,
      imageInputs: 0,
      audioInputs: 0,
    ),
    topTags: const [],
    dayDetails: {
      _dateKey(resolvedRange.end): UserStatsDayDetail(date: resolvedRange.end),
    },
  );
}

String _dateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
