import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    EventBusService.instance.clearHandlers();
  });

  test('InsightViewModel does not start in a loading state', () {
    final vm = InsightViewModel(router: MemexRouter());
    addTearDown(vm.dispose);
    expect(vm.isLoading, isFalse);
    expect(vm.insights, isNull);
  });

  test('KnowledgeBaseViewModel does not start in a loading state', () {
    final vm = KnowledgeBaseViewModel(router: MemexRouter());
    addTearDown(vm.dispose);
    expect(vm.isLoading, isFalse);
    expect(vm.recentFiles, isEmpty);
  });
}
