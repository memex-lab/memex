import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/knowledge_insight_card.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/utils/result.dart';

void main() {
  setUp(EventBusService.instance.clearHandlers);
  tearDown(EventBusService.instance.clearHandlers);

  test('ensureHtmlRendered fills html once and is idempotent', () async {
    final router = _FakeInsightRouter();
    final viewModel = InsightViewModel(router: router);
    addTearDown(viewModel.dispose);
    viewModel.insights = [
      KnowledgeInsightCard(
        id: 'html-1',
        title: 'Chart',
        html: '',
        createdAt: 0,
        widgetType: 'html',
      ),
    ];

    await viewModel.ensureHtmlRendered(viewModel.insights!.first);
    await viewModel.ensureHtmlRendered(viewModel.insights!.first);

    expect(router.renderCount, 1);
    expect(viewModel.insights!.single.html, '<div>chart</div>');
  });

  test('ensureHtmlRendered skips native cards', () async {
    final router = _FakeInsightRouter();
    final viewModel = InsightViewModel(router: router);
    addTearDown(viewModel.dispose);
    final item = KnowledgeInsightCard(
      id: 'native-1',
      title: 'Quote',
      html: '',
      createdAt: 0,
      widgetType: 'native',
      widgetTemplate: 'highlight_card_v1',
    );

    await viewModel.ensureHtmlRendered(item);
    expect(router.renderCount, 0);
  });
}

class _FakeInsightRouter implements MemexRouter {
  int renderCount = 0;

  @override
  Future<Result<String>> renderInsightCardHtml(String insightId) async {
    renderCount += 1;
    return const Ok('<div>chart</div>');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
