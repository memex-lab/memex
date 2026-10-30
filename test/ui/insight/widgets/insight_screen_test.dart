import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/knowledge_insight_card.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/insight/widgets/insight_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    EventBusService.instance.clearHandlers();
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser('insight_screen_test_user');
    await UserStorage.setLocale(const Locale('en'));
  });

  tearDown(() {
    EventBusService.instance.clearHandlers();
  });

  testWidgets('shows all insights without activity statistics navigation', (
    tester,
  ) async {
    final viewModel = InsightViewModel(router: MemexRouter())
      ..isLoading = false
      ..insights = [
        _insight(id: 'first', quote: 'First insight'),
        _insight(id: 'second', quote: 'Second insight'),
      ];
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: InsightScreen(
            viewModel: viewModel,
            isEmbedded: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('First insight'), findsOneWidget);
    expect(find.text('Second insight'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('user_stats_overview_card')),
      findsNothing,
    );
    expect(find.text('Activity stats'), findsNothing);
  });

  testWidgets('a failed pin does not say the insight was pinned', (
    tester,
  ) async {
    final viewModel = _FixedInsightActions(succeeds: false)
      ..isLoading = false
      ..insights = [_insight(id: 'first', quote: 'First insight')];
    addTearDown(viewModel.dispose);

    await _pumpInsight(tester, viewModel);
    await tester.tap(find.byIcon(Icons.push_pin_outlined));
    await tester.pump();
    await tester.pump();

    expect(find.text('Style pinned'), findsNothing);
    expect(find.textContaining('Operation failed'), findsOneWidget);
    expect(find.text('First insight'), findsOneWidget);
  });

  testWidgets('a failed delete keeps the insight on screen', (tester) async {
    final viewModel = _FixedInsightActions(succeeds: false)
      ..isLoading = false
      ..insights = [_insight(id: 'first', quote: 'First insight')];
    addTearDown(viewModel.dispose);

    await _pumpInsight(tester, viewModel);
    await tester.longPress(find.text('First insight'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    await tester.pump();

    expect(find.text('Insight card deleted'), findsNothing);
    expect(find.textContaining('Delete failed'), findsOneWidget);
    expect(find.text('First insight'), findsOneWidget);
  });
}

Future<void> _pumpInsight(WidgetTester tester, InsightViewModel viewModel) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: InsightScreen(
          viewModel: viewModel,
          isEmbedded: true,
        ),
      ),
    ),
  );
}

class _FixedInsightActions extends InsightViewModel {
  _FixedInsightActions({required this.succeeds}) : super(router: MemexRouter());

  final bool succeeds;

  @override
  Future<bool> togglePin(KnowledgeInsightCard item) async => succeeds;

  @override
  Future<bool> deleteCard(KnowledgeInsightCard item) async => succeeds;
}

KnowledgeInsightCard _insight({
  required String id,
  required String quote,
}) {
  return KnowledgeInsightCard(
    id: id,
    title: quote,
    html: '',
    createdAt: 0,
    isPinned: false,
    sortOrder: 0,
    tags: const [],
    widgetType: 'native',
    widgetTemplate: 'highlight_card_v1',
    widgetData: {'quote_content': quote},
  );
}
