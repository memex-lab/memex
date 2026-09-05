import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/ui/character/view_models/persona_avatar_viewmodel.dart';
import 'package:memex/ui/core/widgets/memex_brand_title.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/ui/timeline/widgets/timeline_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    EventBusService.instance.clearHandlers();
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  tearDown(EventBusService.instance.clearHandlers);

  testWidgets('chrome header stays mounted when the timeline list notifies',
      (tester) async {
    final timeline = TimelineViewModel.forTest(autoLoad: false);
    final insight = InsightViewModel(router: MemexRouter());
    final persona = PersonaAvatarViewModel(router: MemexRouter());
    addTearDown(timeline.dispose);
    addTearDown(insight.dispose);
    addTearDown(persona.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimelineScreen(
            viewModel: timeline,
            insightViewModel: insight,
            personaAvatarViewModel: persona,
            onInputTap: () {},
          ),
        ),
      ),
    );

    expect(find.byType(MemexBrandTitle), findsOneWidget);
    timeline.notifyListeners();
    await tester.pump();
    expect(find.byType(MemexBrandTitle), findsOneWidget);
  });
}
