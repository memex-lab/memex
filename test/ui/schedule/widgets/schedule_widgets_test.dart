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
              itemStatuses: const {'task-clean': ScheduleItemStatus.completed},
              onTapCardId: tappedCards.add,
              onToggleTask: toggledTasks.add,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Visa renewal'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('schedule_overview_lens')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('schedule_lens_day_0')), findsNothing);
        expect(find.byKey(const ValueKey('schedule_lens_done')), findsNothing);
        expect(
          find.text('A heavy week with travel prep and home tasks.'),
          findsOneWidget,
        );
        expect(find.text('Deadline pressure'), findsOneWidget);

        await tester.ensureVisible(
          find.text('Two fixed events overlap with the cleaning window.'),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Two fixed events overlap with the cleaning window.'),
          findsOneWidget,
        );

        await tester.ensureVisible(find.text('Clean the apartment'));
        await tester.pumpAndSettle();
        expect(find.text('Clean the apartment'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('schedule_task_toggle_task-clean')),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.check), findsWidgets);

        await tester.tap(
          find.byKey(const ValueKey('schedule_task_toggle_task-clean')),
        );
        await tester.pump();

        expect(toggledTasks, ['task-clean']);

        expect(find.text('Dentist appointment'), findsOneWidget);
        await tester.tap(find.text('Dentist appointment'));
        await tester.pump();

        expect(tappedCards, contains('event-dentist'));

        await tester.scrollUntilVisible(
          find.text('Done grocery order'),
          240,
        );
        await tester.pumpAndSettle();
        expect(find.text('Done grocery order'), findsOneWidget);
      },
    );

    testWidgets('omits anchor lens and keeps same-day times compact', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildHost(MagazineNarrativeTab(aggregation: _complexAggregation())),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('schedule_overview_lens')),
        findsNothing,
      );

      await tester.ensureVisible(find.text('Clean the apartment'));
      await tester.pumpAndSettle();

      expect(find.text('Clean the apartment'), findsOneWidget);
      expect(find.text('Dentist appointment'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(
        find.text(
          DateFormat.MMMd(
            UserStorage.l10n.localeName,
          ).add_Hm().format(DateTime(2026, 5, 15, 10)),
        ),
        findsNothing,
      );
    });

    testWidgets('recomputes relative day labels from day dates', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildHost(
          MagazineNarrativeTab(
            referenceDate: DateTime(2026, 5, 16, 8),
            aggregation: ScheduleAggregationModel(
              id: 'agg_relative_labels',
              generatedAt: DateTime(2026, 5, 15, 18),
              timeRange: TimeRange(
                from: DateTime(2026, 5, 15),
                to: DateTime(2026, 5, 22),
              ),
              timeline: [
                TimelineDay(
                  dayLabel: 'Tomorrow',
                  dayDate: DateTime(2026, 5, 16),
                  items: [
                    TimelineItem(
                      cardId: 'event-today',
                      title: 'Today event',
                      startTime: DateTime(2026, 5, 16, 10),
                    ),
                  ],
                ),
                TimelineDay(
                  dayLabel: 'Today',
                  dayDate: DateTime(2026, 5, 17),
                  items: [
                    TimelineItem(
                      cardId: 'event-tomorrow',
                      title: 'Tomorrow event',
                      startTime: DateTime(2026, 5, 17, 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('TOMORROW'), findsOneWidget);
    });

    testWidgets('renders stale relative, custom, and undated section labels', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(420, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final staleFutureDate = DateTime(2026, 5, 20);
      final staleFutureLabel = DateFormat.MMMEd(
        UserStorage.l10n.localeName,
      ).format(staleFutureDate).toUpperCase();
      final undatedItemLabel = DateFormat.MMMd(
        UserStorage.l10n.localeName,
      ).add_Hm().format(DateTime(2026, 5, 22, 16));

      await tester.pumpWidget(
        buildHost(
          MagazineNarrativeTab(
            referenceDate: DateTime(2026, 5, 16, 8),
            aggregation: ScheduleAggregationModel(
              id: 'agg_mixed_day_labels',
              generatedAt: DateTime(2026, 5, 15, 18),
              timeRange: TimeRange(
                from: DateTime(2026, 5, 15),
                to: DateTime(2026, 5, 23),
              ),
              timeline: [
                TimelineDay(
                  dayLabel: 'Tomorrow',
                  dayDate: staleFutureDate,
                  items: [
                    TimelineItem(
                      cardId: 'event-future-relative',
                      title: 'Future stale relative label',
                      startTime: DateTime(2026, 5, 20, 10),
                    ),
                  ],
                ),
                TimelineDay(
                  dayLabel: 'Launch day',
                  dayDate: DateTime(2026, 5, 21),
                  items: [
                    TimelineItem(
                      cardId: 'event-custom',
                      title: 'Custom label event',
                      startTime: DateTime(2026, 5, 21, 11),
                    ),
                  ],
                ),
                TimelineDay(
                  dayLabel: '',
                  items: [
                    TimelineItem(
                      cardId: 'event-undated-section',
                      title: 'Undated section event',
                      startTime: DateTime(2026, 5, 22, 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(staleFutureLabel), findsOneWidget);
      expect(find.text('TOMORROW'), findsNothing);
      expect(find.text('LAUNCH DAY'), findsOneWidget);
      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text(undatedItemLabel), findsOneWidget);
    });

    testWidgets('handles narrow screens with long hero metadata', (
      tester,
    ) async {
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
    testWidgets('formats generated and item times from offset timestamps', (
      tester,
    ) async {
      final generatedAt = DateTime.parse('2026-05-14T17:39:22+08:00').toLocal();
      final itemStart = DateTime.parse('2026-05-15T10:00:00+08:00').toLocal();
      final generatedLabel = DateFormat.Md(
        UserStorage.l10n.localeName,
      ).add_Hm().format(generatedAt);
      final itemLabel = DateFormat.Md(
        UserStorage.l10n.localeName,
      ).add_Hm().format(itemStart);

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
      expect(
        find.text(UserStorage.l10n.scheduleBriefingConflictCount(1)),
        findsOneWidget,
      );
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
