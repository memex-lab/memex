import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/app_action_service.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/main.dart';
import 'package:memex/ui/character/view_models/persona_avatar_viewmodel.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'a quick note link opens the recording dialog on an idle home screen',
      (tester) async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
    final router = MemexRouter();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider.value(value: router),
        ChangeNotifierProvider(
            create: (_) => TimelineViewModel.forTest(autoLoad: false)),
        ChangeNotifierProvider(create: (_) => InsightViewModel(router: router)),
        ChangeNotifierProvider(
            create: (_) => PersonaAvatarViewModel(router: router)),
        ChangeNotifierProvider(
            create: (_) => KnowledgeBaseViewModel(router: router)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: TickerMode(enabled: false, child: MainScreen()),
      ),
    ));
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    AppActionService.instance.handleDeepLink('memex://quick_note');
    await tester.idle();
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(find.byKey(const ValueKey('super-agent-session-loading')),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
