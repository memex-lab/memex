import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memex/data/services/demo_service.dart';
import 'package:memex/ui/core/widgets/demo_overlay.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await initializeDateFormatting('en');
    await UserStorage.initL10n();
  });

  tearDown(() {
    DemoService.instance.resetForTesting();
  });

  testWidgets('recovers the spotlight when the target appears later', (
    tester,
  ) async {
    final demo = DemoService.instance;
    demo.setStepForTesting(DemoStep.tapAddButton);

    var showTarget = false;

    Widget buildApp() {
      return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              if (showTarget)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    key: demo.addButtonKey,
                    width: 64,
                    height: 64,
                  ),
                ),
              const DemoOverlay(),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text(UserStorage.l10n.demoTapAdd), findsNothing);

    showTarget = true;
    await tester.pumpWidget(buildApp());
    expect(demo.addButtonKey.currentContext, isNotNull);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text(UserStorage.l10n.demoTapAdd).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.text(UserStorage.l10n.demoTapAdd), findsOneWidget);
  });
}
