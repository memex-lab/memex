import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/knowledge_insight_card.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/insight/widgets/insight_screen.dart';
import 'package:memex/utils/result.dart';
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

  testWidgets('uses a lazy ListView.builder for the insight feed', (
    tester,
  ) async {
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
          body: InsightScreen(viewModel: viewModel, isEmbedded: true),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Insight 0'), findsOneWidget);
  });

  testWidgets('failed HTML render stops until the user retries', (
    tester,
  ) async {
    final router = _FailingHtmlRouter();
    final viewModel = InsightViewModel(router: router)
      ..insights = [
        KnowledgeInsightCard(
          id: 'broken-html',
          title: 'Broken chart',
          html: '',
          createdAt: 0,
          widgetType: 'html',
        ),
      ];
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: InsightScreen(viewModel: viewModel, isEmbedded: true),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(UserStorage.l10n.reload), findsOneWidget);
    expect(router.renderCount, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(router.renderCount, 1);

    await tester.tap(find.text(UserStorage.l10n.reload));
    await tester.pump();
    await tester.pump();
    expect(router.renderCount, 2);
  });
}

class _FailingHtmlRouter implements MemexRouter {
  int renderCount = 0;

  @override
  Future<Result<String>> renderInsightCardHtml(String insightId) async {
    renderCount += 1;
    return Error<String>(Exception('missing template'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
