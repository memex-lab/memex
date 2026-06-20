import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/domain/models/local_speech_model.dart';
import 'package:memex/ui/core/widgets/speech_model_download_flow.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    AppFlavor.init('globalDev');
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  testWidgets('download dialog shows both speech model options', (tester) async {
  await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(),
        ),
      ),
    );

    final context = tester.element(find.byType(Scaffold));
    SpeechModelDownloadFlow.showDownloadDialog(context);
    await tester.pumpAndSettle();

    expect(find.text('Download Speech Model'), findsOneWidget);
    expect(find.text('SenseVoice'), findsOneWidget);
    expect(find.text('Whisper Small'), findsOneWidget);
    expect(
      find.textContaining('Multilingual model including German'),
      findsOneWidget,
    );
    expect(find.text('GitHub (Recommended)'), findsOneWidget);
    expect(
      find.textContaining('Outside China, tap GitHub'),
      findsOneWidget,
    );
  });

  testWidgets('global dialog preselects Whisper Small', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox()),
      ),
    );

    final context = tester.element(find.byType(Scaffold));
    SpeechModelDownloadFlow.showDownloadDialog(context);
    await tester.pumpAndSettle();

    expect(
      LocalSpeechModelProfile.defaultForFlavor(),
      LocalSpeechModelId.whisperSmall,
    );
    expect(find.byIcon(Icons.radio_button_checked), findsWidgets);
  });
}
