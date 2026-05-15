import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/core/cards/templates/system/schedule_briefing_card.dart';
import 'package:memex/ui/schedule/models/schedule_item.dart';
import 'package:memex/ui/schedule/widgets/tabs/magazine_narrative_tab.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  Widget buildHost(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('MagazineNarrativeTab', () {
    testWidgets(
        'renders complex LLM schedule output and task toggle affordance',
        (tester) async {
      final tappedCards = <String>[];
      final toggledTasks = <String>[];

      await tester.pumpWidget(
        buildHost(
          MagazineNarrativeTab(
            aggregation: _complexAggregation(),
            itemStatuses: const {
              'task-clean': ScheduleItemStatus.completed,
            },
            onTapCardId: tappedCards.add,
            onToggleTask: toggledTasks.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Visa renewal'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('schedule_overview_lens')), findsOneWidget);
      expect(find.byKey(const ValueKey('schedule_lens_day_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('schedule_lens_conflicts')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('schedule_lens_done')), findsOneWidget);

      Future<void> tapLens(Key key) async {
        final finder = find.byKey(key);
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tapLens(const ValueKey('schedule_lens_done'));
      expect(find.text('Done grocery order'), findsOneWidget);

      await tapLens(const ValueKey('schedule_lens_conflicts'));
      expect(find.text('Two fixed events overlap with the cleaning window.'),
          findsOneWidget);

      await tapLens(const ValueKey('schedule_lens_day_0'));
      expect(find.text('Clean the apartment'), findsOneWidget);
      expect(find.byKey(const ValueKey('schedule_task_toggle_task-clean')),
          findsOneWidget);
      expect(find.byIcon(Icons.check), findsWidgets);

      await tester
          .tap(find.byKey(const ValueKey('schedule_task_toggle_task-clean')));
      await tester.pump();

      expect(toggledTasks, ['task-clean']);

      expect(find.text('Dentist appointment'), findsOneWidget);
      await tester.tap(find.text('Dentist appointment'));
      await tester.pump();

      expect(tappedCards, contains('event-dentist'));

      await tapLens(const ValueKey('schedule_lens_done'));
      expect(find.text('Done grocery order'), findsOneWidget);
    });

    testWidgets('overview lens jumps to timeline days', (tester) async {
      await tester.pumpWidget(
        buildHost(
          MagazineNarrativeTab(
            aggregation: _complexAggregation(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('schedule_lens_day_0')));
      await tester.pumpAndSettle();

      expect(find.text('Clean the apartment'), findsOneWidget);
      expect(find.text('Dentist appointment'), findsOneWidget);
    });

    testWidgets('handles narrow screens with long hero metadata',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildHost(
          MagazineNarrativeTab(
            aggregation: _complexAggregation(longText: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.text(
          'Very long cross-city visa renewal preparation and paperwork deadline',
        ),
        findsOneWidget,
      );
    });
  });

  group('ScheduleBriefingCard', () {
    testWidgets('formats generated and item times from offset timestamps',
        (tester) async {
      final generatedAt = DateTime.parse('2026-05-14T17:39:22+08:00').toLocal();
      final itemStart = DateTime.parse('2026-05-15T10:00:00+08:00').toLocal();
      final generatedLabel = DateFormat.Md(UserStorage.l10n.localeName)
          .add_Hm()
          .format(generatedAt);
      final itemLabel =
          DateFormat.Md(UserStorage.l10n.localeName).add_Hm().format(itemStart);

      await tester.pumpWidget(
        buildHost(
          const SingleChildScrollView(
            child: ScheduleBriefingCard(
              data: {
                'generated_at': '2026-05-14T17:39:22+08:00',
                'hero_title': 'Clean the apartment before guest visit',
                'summary': 'One task and one fixed meeting need attention.',
                'completed_count': 2,
                'conflict_count': 1,
                'items': [
                  {
                    'title': 'Clean the apartment',
                    'start_time': '2026-05-15T10:00:00+08:00',
                  },
                ],
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(UserStorage.l10n.scheduleBriefingUpdated(generatedLabel)),
        findsOneWidget,
      );
      expect(find.text(itemLabel), findsOneWidget);
      expect(find.textContaining('+08:00'), findsNothing);
      expect(find.textContaining('2026-05-15T10:00'), findsNothing);
      expect(find.text(UserStorage.l10n.scheduleBriefingConflictCount(1)),
          findsOneWidget);
    });
  });
}

ScheduleAggregationModel _complexAggregation({bool longText = false}) {
  final location = longText
      ? 'Very long cross-city conference room name with building, floor, wing, and entrance instructions'
      : 'Clinic room 4';

  return ScheduleAggregationModel(
    id: 'agg_complex',
    generatedAt: DateTime(2026, 5, 14, 18),
    timeRange: TimeRange(
      from: DateTime(2026, 5, 14),
      to: DateTime(2026, 5, 21),
    ),
    heroItem: HeroItem(
      cardId: 'event-visa',
      title: longText
          ? 'Very long cross-city visa renewal preparation and paperwork deadline'
          : 'Visa renewal',
      description: 'Bring photos, passport, and printed forms.',
      startTime: DateTime(2026, 5, 15, 9, 30),
      endTime: DateTime(2026, 5, 15, 11),
      location: location,
      priority: 3,
    ),
    editorialIntro: 'A heavy week with travel prep and home tasks.',
    quoteBlocks: [
      QuoteBlock(
        title: 'Deadline pressure',
        content: 'Handle documents before the afternoon meeting.',
        priority: 'high',
      ),
    ],
    conflicts: [
      Conflict(
        description: 'Two fixed events overlap with the cleaning window.',
        itemIds: ['task-clean', 'event-dentist'],
      ),
    ],
    timeline: [
      TimelineDay(
        dayLabel: 'Friday',
        dayDate: DateTime(2026, 5, 15),
        items: [
          TimelineItem(
            cardId: 'task-clean',
            title: 'Clean the apartment',
            type: 'task',
            status: 'pending',
            startTime: DateTime(2026, 5, 15, 10),
            priority: 3,
            description:
                'Prepare living room and kitchen before guests arrive.',
          ),
          TimelineItem(
            cardId: 'event-dentist',
            title: 'Dentist appointment',
            type: 'event',
            status: 'pending',
            startTime: DateTime(2026, 5, 15, 10, 30),
            description: 'Allow travel time after the appointment.',
          ),
        ],
      ),
    ],
    completed: [
      CompletedItem(
        cardId: 'task-grocery',
        title: 'Done grocery order',
        completedAt: DateTime(2026, 5, 14, 21, 15),
      ),
    ],
  );
}
