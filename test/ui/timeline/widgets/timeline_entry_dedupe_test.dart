import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/ui/timeline/widgets/timeline_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  testWidgets(
    'renders one processing entry after duplicate submission upsert',
    (tester) async {
      final cards = upsertTimelineCardById(
        [
          _card(
            '2026/05/18.md#ts_1',
            content: 'stale processing copy',
            status: 'processing',
          ),
          _card('2026/05/18.md#ts_0', content: 'older neighbor'),
        ],
        _card(
          '2026/05/18.md#ts_1',
          content: 'fresh processing copy',
          status: 'processing',
        ),
      );

      await tester.pumpWidget(_FeedHost(cards: cards));
      await tester.pump();

      expect(find.byType(TimelineEntryItem), findsNWidgets(2));
      expect(find.byKey(const ValueKey('2026/05/18.md#ts_1')), findsOneWidget);
      expect(find.text('fresh processing copy'), findsOneWidget);
      expect(find.text('stale processing copy'), findsNothing);
      expect(find.text('older neighbor'), findsOneWidget);
    },
  );

  testWidgets('renders one completed entry after duplicate processing update', (
    tester,
  ) async {
    final cards = replaceTimelineCardById(
      [
        _card(
          '2026/05/18.md#ts_1',
          content: 'processing copy A',
          status: 'processing',
        ),
        _card(
          '2026/05/18.md#ts_1',
          content: 'processing copy B',
          status: 'processing',
        ),
      ],
      _card(
        '2026/05/18.md#ts_1',
        content: 'completed result',
        status: 'completed',
      ),
    );

    await tester.pumpWidget(_FeedHost(cards: cards));
    await tester.pump();

    expect(find.byType(TimelineEntryItem), findsOneWidget);
    expect(find.byKey(const ValueKey('2026/05/18.md#ts_1')), findsOneWidget);
    expect(find.text('completed result'), findsOneWidget);
    expect(find.text('processing copy A'), findsNothing);
    expect(find.text('processing copy B'), findsNothing);
  });
}

class _FeedHost extends StatelessWidget {
  const _FeedHost({required this.cards});

  final List<TimelineCardModel> cards;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(
          children: [
            for (final card in cards)
              TimelineEntryItem(
                key: ValueKey(card.id),
                card: card,
                attachments: const [],
                onTap: () {},
              ),
          ],
        ),
      ),
    );
  }
}

TimelineCardModel _card(
  String id, {
  required String content,
  String status = 'completed',
}) {
  return TimelineCardModel(
    id: id,
    timestamp: DateTime(2026, 5, 18, 12),
    tags: const [],
    status: status,
    title: content,
    uiConfigs: [
      UiConfig(templateId: 'classic_card', data: {'content': content}),
    ],
  );
}
