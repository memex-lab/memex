import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/settings/widgets/ai_service_setup_page.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'zh'});
    await UserStorage.initL10n();
  });

  testWidgets('renders Memex model service setup copy with pinned auth area', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      const AiServiceSetupPage(),
    );

    expect(find.text('Memex'), findsOneWidget);
    expect(find.text(UserStorage.l10n.aiServiceTitle), findsOneWidget);
    expect(
        find.text(UserStorage.l10n.aiServiceLongDescription), findsOneWidget);
    expect(
        find.text(UserStorage.l10n.aiServiceCustomModelTitle), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.aiServiceCustomModelDescription),
      findsOneWidget,
    );
    expect(find.text(UserStorage.l10n.memexUsername), findsOneWidget);
    expect(find.text(UserStorage.l10n.memexPassword), findsOneWidget);
  });

  testWidgets('custom model action opens model configuration', (tester) async {
    await _pumpPage(
      tester,
      const AiServiceSetupPage(),
    );

    final customModelAction =
        find.text(UserStorage.l10n.advancedModelConfiguration);
    await tester.scrollUntilVisible(
      customModelAction,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(customModelAction);
    await tester.pumpAndSettle();

    expect(find.byType(ModelConfigListPage), findsOneWidget);
  });

  testWidgets('onboarding skip completes without saving credentials', (
    tester,
  ) async {
    var completed = false;

    await _pumpPage(
      tester,
      AiServiceSetupPage(
        onboardingMode: true,
        onComplete: () => completed = true,
      ),
    );

    await tester.tap(find.text(UserStorage.l10n.skipForNow));
    await tester.pump();

    expect(completed, isTrue);
  });
}

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(430, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(MaterialApp(home: page));
  await tester.pumpAndSettle();
}
