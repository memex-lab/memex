import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/local_speech.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/settings/widgets/local_speech_settings_card.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  Future<void> pumpCard(
    WidgetTester tester, {
    required String engine,
    required String language,
    bool useLocal = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: LocalSpeechSettingsCard(
              useLocal: useLocal,
              engine: engine,
              language: language,
              onEngineChanged: (_) {},
              onLanguageChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('German on SenseVoice shows the language hint', (tester) async {
    await pumpCard(
      tester,
      engine: LocalSpeechEngines.senseVoice,
      language: 'de',
    );

    expect(find.byKey(const Key('local-speech-language-hint')), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.localSpeechLanguageUnsupported),
      findsOneWidget,
    );
    expect(find.text('Deutsch'), findsOneWidget);
  });

  testWidgets('German on the multilingual model hides the hint',
      (tester) async {
    await pumpCard(
      tester,
      engine: LocalSpeechEngines.whisperTiny,
      language: 'de',
    );

    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.byKey(const Key('local-speech-language-hint')), findsNothing);
  });

  testWidgets('cloud speech hides the on-device model picker', (tester) async {
    await pumpCard(
      tester,
      useLocal: false,
      engine: LocalSpeechEngines.senseVoice,
      language: 'de',
    );

    expect(find.byKey(const Key('local-speech-engine')), findsNothing);
  });
}
