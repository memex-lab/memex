import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/main_screen/widgets/ai_core_button.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'user_id': 'ai-core-button-test',
      'language': 'en',
    });
    await UserStorage.initL10n();
  });

  testWidgets('exposes add label and speech long-press hint to semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: AICoreButton(
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(AICoreButton));
    expect(
      semantics,
      matchesSemantics(
        label: UserStorage.l10n.addTooltip,
        isButton: true,
        onLongPressHint: UserStorage.l10n.speechProviderSettings,
        hasTapAction: true,
        hasLongPressAction: true,
      ),
    );
  });
}
