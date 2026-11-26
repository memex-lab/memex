import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/speech_transcription_service.dart';
import 'package:memex/domain/models/local_speech.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'use_local_speech_to_text': true,
      'local_speech_engine': LocalSpeechEngines.senseVoice,
      'local_speech_language': 'de',
    });
  });

  test('German on SenseVoice fails before any recognizer runs', () async {
    expect(
      SpeechTranscriptionService.instance.transcribeSamples(Float32List(16)),
      throwsA(
        isA<UnsupportedLocalSpeechLanguage>().having(
          (error) => error.language,
          'language',
          'de',
        ),
      ),
    );
  });

  test('a covered language does not ask for a download of the wrong model',
      () async {
    SharedPreferences.setMockInitialValues({
      'use_local_speech_to_text': true,
      'local_speech_engine': LocalSpeechEngines.senseVoice,
      'local_speech_language': 'de',
    });
    final service = SpeechTranscriptionService.instance;
    expect(await service.requiresLocalModelDownload(), isFalse);
    expect(await service.supportsStreamingTranscription(), isFalse);
  });
}
