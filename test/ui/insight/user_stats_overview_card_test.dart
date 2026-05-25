import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/user_stats_model.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/insight/widgets/user_stats_overview_card.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser('stats_overview_card_test_user');
    await UserStorage.setLocale(const Locale('en'));
    tempDir =
        await Directory.systemTemp.createTemp('memex_stats_overview_card_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('shows loading skeleton and disables tap before first snapshot', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        UserStatsOverviewCard(
          snapshot: null,
          isLoading: true,
          onTap: () => taps += 1,
        ),
      ),
    );

    expect(
        find.byKey(const ValueKey('user_stats_overview_card')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('user_stats_overview_card')),
        matching: find.text('Activity stats'),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('user_stats_overview_card')));
    await tester.pump();

    expect(taps, 0);
  });

  testWidgets('renders zero stats snapshot as real content', (tester) async {
    var taps = 0;
    final range = UserStatsDateRange(
      start: DateTime(2026, 5, 18),
      end: DateTime(2026, 5, 20),
    );

    await tester.pumpWidget(
      _wrap(
        UserStatsOverviewCard(
          snapshot: UserStatsSnapshot.empty(range),
          isLoading: false,
          onTap: () => taps += 1,
        ),
      ),
    );

    expect(find.text('Activity stats'), findsOneWidget);
    expect(find.text('0'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('user_stats_overview_card')));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('keeps old content tappable while a refresh is running', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        UserStatsOverviewCard(
          snapshot: _snapshot(),
          isLoading: true,
          onTap: () => taps += 1,
        ),
      ),
    );

    expect(find.text('Activity stats'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('user_stats_overview_card')));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('handles snapshots without daily chart points', (tester) async {
    await tester.pumpWidget(
      _wrap(
        UserStatsOverviewCard(
          snapshot: _snapshot(daily: const []),
          isLoading: false,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Activity stats'), findsOneWidget);
    expect(
      find.text(
        'In this period you recorded 5 time(s), generated 2 card(s), and completed 1 todo(s).',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

UserStatsSnapshot _snapshot({
  List<UserStatsDailyPoint>? daily,
}) {
  final range = UserStatsDateRange(
    start: DateTime(2026, 5, 18),
    end: DateTime(2026, 5, 20),
  );
  return UserStatsSnapshot(
    range: range,
    summary: const UserStatsSummary(
      totalInputs: 5,
      totalWords: 42,
      totalCards: 2,
      totalKnowledgeUnits: 1,
      totalInsights: 1,
      totalCompletedTodos: 1,
      activeDays: 2,
      currentStreakDays: 2,
    ),
    daily: daily ??
        [
          UserStatsDailyPoint(
            date: DateTime(2026, 5, 18),
            inputs: 0,
            words: 0,
            cards: 0,
            knowledgeUnits: 0,
            insights: 0,
            completedTodos: 0,
          ),
          UserStatsDailyPoint(
            date: DateTime(2026, 5, 19),
            inputs: 3,
            words: 24,
            cards: 1,
            knowledgeUnits: 1,
            insights: 0,
            completedTodos: 0,
          ),
          UserStatsDailyPoint(
            date: DateTime(2026, 5, 20),
            inputs: 2,
            words: 18,
            cards: 1,
            knowledgeUnits: 0,
            insights: 1,
            completedTodos: 1,
          ),
        ],
    sourceBreakdown: const UserStatsSourceBreakdown(
      textInputs: 4,
      imageInputs: 1,
      audioInputs: 0,
    ),
    topTags: const [],
    dayDetails: const {},
  );
}
