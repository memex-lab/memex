import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/settings/widgets/invalid_model_config_dialog.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  testWidgets('explains missing AI without agent or config key', (
    tester,
  ) async {
    var kept = false;
    var turnedOn = false;
    await tester.pumpWidget(
      MaterialApp(
        home: InvalidModelConfigDialog(
          onKeepRecording: () => kept = true,
          onTurnOnAi: () => turnedOn = true,
        ),
      ),
    );

    expect(find.text(UserStorage.l10n.invalidModelConfigPlain), findsOneWidget);
    expect(find.text(UserStorage.l10n.keepRecording), findsOneWidget);
    expect(find.text(UserStorage.l10n.turnOnAi), findsOneWidget);
    expect(find.textContaining('Chat'), findsNothing);
    expect(find.textContaining('chat_agent'), findsNothing);
    expect(find.textContaining('default'), findsNothing);
    expect(find.textContaining('key:'), findsNothing);

    await tester.tap(find.text(UserStorage.l10n.keepRecording));
    await tester.tap(find.text(UserStorage.l10n.turnOnAi));
    expect(kept, isTrue);
    expect(turnedOn, isTrue);
  });
}
