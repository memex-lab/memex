import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/knowledge_insight_card.dart';
import 'package:memex/domain/models/user_stats_model.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/insight/widgets/insight_screen.dart';
import 'package:memex/ui/insight/widgets/user_stats_page.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser('stats_widget_user');
    await UserStorage.setLocale(const Locale('en'));
    tempDir = await Directory.systemTemp.createTemp('memex_stats_widget_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('shows stats overview card and opens stats section', (
    tester,
  ) async {
    final vm = _buildViewModel();

    await tester.pumpWidget(
      _wrap(InsightScreen(viewModel: vm, isEmbedded: true)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('user_stats_overview_card')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('user_stats_overview_card')),
        matching: find.text('Activity stats'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('user_stats_overview_card')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('user_stats_page')), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('user_stats_page')),
      const Offset(0, -520),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Daily rhythm'), findsOneWidget);

    vm.dispose();
  });

  testWidgets('reloads fresh stats when opening stats section', (tester) async {
    final vm = _buildViewModel(statsReloadSnapshot: _singleInputSnapshot());
    vm.statsSnapshot = UserStatsSnapshot.empty(vm.statsRange);

    await tester.pumpWidget(
      _wrap(InsightScreen(viewModel: vm, isEmbedded: true)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('user_stats_overview_card')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byKey(const ValueKey('user_stats_page')), findsOneWidget);
    expect(
      find.text(
        'In this period you recorded 1 time(s), generated 0 card(s), and completed 0 todo(s).',
      ),
      findsOneWidget,
    );

    vm.dispose();
  });

  testWidgets('refreshes overview stats when insight tab becomes visible', (
    tester,
  ) async {
    final statsCompleter = Completer<Result<UserStatsSnapshot>>();
    final vm = _buildViewModelWithFetcher((_) => statsCompleter.future);
    vm.statsSnapshot = null;

    await tester.pumpWidget(
      _wrap(InsightScreen(viewModel: vm, isEmbedded: true)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('user_stats_overview_card')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('user_stats_overview_card')),
        matching: find.text('Activity stats'),
      ),
      findsNothing,
    );

    final refresh = vm.refreshStatsForVisibleInsightPage();
    await tester.pump();

    statsCompleter.complete(Ok(_snapshot()));
    await refresh;
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('user_stats_overview_card')),
        matching: find.text('Activity stats'),
      ),
      findsOneWidget,
    );

    vm.dispose();
  });

  testWidgets('keeps populated overview visible while stats refresh', (
    tester,
  ) async {
    final vm = _buildViewModel();
    vm.isStatsLoading = true;

    await tester.pumpWidget(
      _wrap(InsightScreen(viewModel: vm, isEmbedded: true)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('user_stats_overview_card')),
        matching: find.text('Activity stats'),
      ),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    vm.dispose();
  });

  testWidgets('switches metric and opens day detail sheet', (tester) async {
    var selectedMetric = UserStatsMetric.inputs;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return UserStatsPage(
              snapshot: _snapshot(),
              isLoading: false,
              errorMessage: null,
              selectedDays: 3,
              selectedMetric: selectedMetric,
              onMetricChanged: (metric) => setState(() {
                selectedMetric = metric;
              }),
              onPresetSelected: (_) {},
              onReload: () {},
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('stats_metric_cards')),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('stats_metric_cards')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(selectedMetric, UserStatsMetric.cards);

    final dayKey = find.byKey(const ValueKey('stats_day_2026-05-20'));
    await tester.scrollUntilVisible(
      dayKey,
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(dayKey);
    await tester.pumpAndSettle();

    expect(find.text('Day details'), findsOneWidget);
    expect(find.text('Weekly review'), findsOneWidget);
    expect(find.text('Clean desk'), findsOneWidget);
  });

  testWidgets('groups ninety-day rhythm chart into seven-day buckets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(
        UserStatsPage(
          snapshot: _ninetyDaySnapshot(),
          isLoading: false,
          errorMessage: null,
          selectedDays: 90,
          selectedMetric: UserStatsMetric.inputs,
          onMetricChanged: (_) {},
          onPresetSelected: (_) {},
          onReload: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('stats_bucket_2026-03-01_2026-03-07')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('stats_bucket_2026-03-01_2026-03-07')),
    );
    await tester.drag(
      find.byKey(const ValueKey('user_stats_page')),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('stats_bucket_2026-03-01_2026-03-07')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('stats_day_2026-03-01')), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('stats_bucket_2026-03-01_2026-03-07')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Day details'), findsOneWidget);
    expect(find.text('Mar 1, 2026 - Mar 7, 2026'), findsOneWidget);
    expect(find.text('Weekly pattern'), findsOneWidget);
    expect(find.text('Planning note'), findsOneWidget);
  });

  testWidgets('updates selected range immediately while preset reloads', (
    tester,
  ) async {
    final statsCompleter = Completer<Result<UserStatsSnapshot>>();
    final vm = _buildViewModelWithFetcher((range) {
      if (range.dayCount == 90) return statsCompleter.future;
      return Future.value(Ok(_snapshot()));
    });
    vm.statsRange = UserStatsDateRange(
      start: DateTime(2026, 5, 18),
      end: DateTime(2026, 5, 20),
    );
    vm.statsSnapshot = _snapshot();

    await tester.pumpWidget(
      _wrap(InsightScreen(viewModel: vm, isEmbedded: true)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('user_stats_overview_card')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('stats_range_90')));
    await tester.pump();

    final selectedChip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('stats_range_90')),
    );
    expect(selectedChip.selected, isTrue);
    expect(find.byKey(const ValueKey('stats_range_loading')), findsOneWidget);

    statsCompleter.complete(Ok(_ninetyDaySnapshot()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('stats_bucket_2026-03-01_2026-03-07')),
      220,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const ValueKey('stats_range_loading')), findsNothing);
    expect(
      find.byKey(const ValueKey('stats_bucket_2026-03-01_2026-03-07')),
      findsOneWidget,
    );

    vm.dispose();
  });
}

InsightViewModel _buildViewModel({UserStatsSnapshot? statsReloadSnapshot}) {
  return _buildViewModelWithFetcher(
    (_) async => Ok(statsReloadSnapshot ?? _snapshot()),
  );
}

InsightViewModel _buildViewModelWithFetcher(UserStatsFetcher userStatsFetcher) {
  final vm = InsightViewModel(
    router: MemexRouter(),
    userStatsFetcher: userStatsFetcher,
  );
  vm.isLoading = false;
  vm.insights = [
    KnowledgeInsightCard(
      id: 'dummy',
      title: 'Dummy',
      html: '',
      createdAt: 0,
      isPinned: false,
      sortOrder: 0,
      tags: const [],
      widgetType: 'native',
      widgetTemplate: 'highlight_card_v1',
      widgetData: const {'quote_content': 'A small insight'},
    ),
  ];
  vm.statsSnapshot = _snapshot();
  vm.isStatsLoading = false;
  return vm;
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

UserStatsSnapshot _snapshot() {
  final range = UserStatsDateRange(
    start: DateTime(2026, 5, 18),
    end: DateTime(2026, 5, 20),
  );
  final daily = [
    UserStatsDailyPoint(
      date: DateTime(2026, 5, 18),
      inputs: 2,
      words: 18,
      cards: 1,
      knowledgeUnits: 1,
      insights: 0,
      completedTodos: 0,
    ),
    UserStatsDailyPoint(
      date: DateTime(2026, 5, 19),
      inputs: 1,
      words: 8,
      cards: 1,
      knowledgeUnits: 0,
      insights: 1,
      completedTodos: 0,
    ),
    UserStatsDailyPoint(
      date: DateTime(2026, 5, 20),
      inputs: 1,
      words: 5,
      cards: 2,
      knowledgeUnits: 1,
      insights: 1,
      completedTodos: 1,
    ),
  ];
  return UserStatsSnapshot(
    range: range,
    summary: const UserStatsSummary(
      totalInputs: 4,
      totalWords: 31,
      totalCards: 4,
      totalKnowledgeUnits: 2,
      totalInsights: 2,
      totalCompletedTodos: 1,
      activeDays: 3,
      currentStreakDays: 3,
    ),
    daily: daily,
    sourceBreakdown: const UserStatsSourceBreakdown(
      textInputs: 3,
      imageInputs: 1,
      audioInputs: 1,
    ),
    topTags: const [
      UserStatsTopTag(label: 'work', count: 2),
      UserStatsTopTag(label: 'health', count: 1),
    ],
    dayDetails: {
      '2026-05-18': UserStatsDayDetail(
        date: DateTime(2026, 5, 18),
        cardTitles: const ['Morning note'],
        knowledgePaths: const ['PKM/Areas/work.md'],
      ),
      '2026-05-19': UserStatsDayDetail(
        date: DateTime(2026, 5, 19),
        insightTitles: const ['Pattern found'],
      ),
      '2026-05-20': UserStatsDayDetail(
        date: DateTime(2026, 5, 20),
        cardTitles: const ['Weekly review'],
        knowledgePaths: const ['PKM/Projects/app.md'],
        insightTitles: const ['Better cadence'],
        completedTodoTitles: const ['Clean desk'],
      ),
    },
  );
}

UserStatsSnapshot _singleInputSnapshot() {
  final today = DateTime.now();
  final range = UserStatsDateRange.lastDays(7, now: today);
  final daily = List.generate(range.dayCount, (index) {
    final date = range.start.add(Duration(days: index));
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    return UserStatsDailyPoint(
      date: date,
      inputs: isToday ? 1 : 0,
      words: isToday ? 3 : 0,
      cards: 0,
      knowledgeUnits: 0,
      insights: 0,
      completedTodos: 0,
    );
  });

  return UserStatsSnapshot(
    range: range,
    summary: const UserStatsSummary(
      totalInputs: 1,
      totalWords: 3,
      totalCards: 0,
      totalKnowledgeUnits: 0,
      totalInsights: 0,
      totalCompletedTodos: 0,
      activeDays: 1,
      currentStreakDays: 1,
    ),
    daily: daily,
    sourceBreakdown: const UserStatsSourceBreakdown(
      textInputs: 1,
      imageInputs: 0,
      audioInputs: 0,
    ),
    topTags: const [],
    dayDetails: {
      for (final point in daily)
        _dateKey(point.date): UserStatsDayDetail(date: point.date),
    },
  );
}

UserStatsSnapshot _ninetyDaySnapshot() {
  final range = UserStatsDateRange(
    start: DateTime(2026, 3, 1),
    end: DateTime(2026, 5, 29),
  );
  final daily = List.generate(range.dayCount, (index) {
    final value = index + 1;
    return UserStatsDailyPoint(
      date: range.start.add(Duration(days: index)),
      inputs: value,
      words: value * 2,
      cards: 1,
      knowledgeUnits: index.isEven ? 1 : 0,
      insights: index == 0 ? 1 : 0,
      completedTodos: index == 1 ? 1 : 0,
    );
  });

  return UserStatsSnapshot(
    range: range,
    summary: UserStatsSummary(
      totalInputs: daily.fold(0, (sum, point) => sum + point.inputs),
      totalWords: daily.fold(0, (sum, point) => sum + point.words),
      totalCards: daily.fold(0, (sum, point) => sum + point.cards),
      totalKnowledgeUnits: daily.fold(
        0,
        (sum, point) => sum + point.knowledgeUnits,
      ),
      totalInsights: daily.fold(0, (sum, point) => sum + point.insights),
      totalCompletedTodos: daily.fold(
        0,
        (sum, point) => sum + point.completedTodos,
      ),
      activeDays: daily.where((point) => point.isActive).length,
      currentStreakDays: daily.where((point) => point.isActive).length,
    ),
    daily: daily,
    sourceBreakdown: const UserStatsSourceBreakdown(
      textInputs: 90,
      imageInputs: 0,
      audioInputs: 0,
    ),
    topTags: const [],
    dayDetails: {
      for (var index = 0; index < daily.length; index++)
        _dateKey(daily[index].date): UserStatsDayDetail(
          date: daily[index].date,
          cardTitles: index == 0 ? const ['Weekly pattern'] : const [],
          knowledgePaths: const [],
          insightTitles: index == 1 ? const ['Planning note'] : const [],
          completedTodoTitles: const [],
        ),
    },
  );
}

String _dateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
