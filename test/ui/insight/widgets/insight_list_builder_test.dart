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
    await UserStorage.saveUser('insight_list_test_user');
    await UserStorage.setLocale(const Locale('en'));
  });

  tearDown(EventBusService.instance.clearHandlers);

  testWidgets('uses a lazy ListView.builder for the insight feed',
      (tester) async {
    final viewModel = InsightViewModel(router: MemexRouter())
      ..isLoading = false
      ..insights = [
        for (var i = 0; i < 8; i++)
          KnowledgeInsightCard(
            id: 'insight-$i',
            title: 'Insight $i',
            html: '',
            createdAt: i,
            widgetType: 'native',
            widgetTemplate: 'highlight_card_v1',
            widgetData: {'quote_content': 'Insight $i'},
          ),
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

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Insight 0'), findsOneWidget);
  });
}
