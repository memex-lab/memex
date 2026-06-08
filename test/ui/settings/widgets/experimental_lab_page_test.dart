import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/settings/widgets/experimental_lab_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'zh'});
    await UserStorage.initL10n();
  });

  testWidgets('renders labs shell with custom pages entry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ExperimentalLabPage(router: MemexRouter()),
      ),
    );

    expect(find.text(UserStorage.l10n.experimentalLab), findsOneWidget);
    expect(
        find.text(UserStorage.l10n.experimentalLabDescription), findsOneWidget);
    expect(find.text(UserStorage.l10n.customPages), findsOneWidget);
  });
}
