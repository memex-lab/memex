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
