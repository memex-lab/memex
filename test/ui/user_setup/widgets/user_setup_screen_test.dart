import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/ui/user_setup/widgets/user_setup_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
    AppFlavor.init('globalDev');
  });

  testWidgets('shows EN, DE, and Chinese language options', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserSetupScreen(onUserCreated: () {}),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('EN'), findsOneWidget);
    expect(find.text('DE'), findsOneWidget);
    expect(find.text('中文'), findsOneWidget);
  });
}
