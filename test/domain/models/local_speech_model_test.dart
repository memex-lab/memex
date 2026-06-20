import 'package:flutter_test/flutter_test.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/domain/models/local_speech_model.dart';

void main() {
  setUp(() {
    AppFlavor.init('globalDev');
  });

  test('default model is Whisper Small on global flavors', () {
    expect(
      LocalSpeechModelProfile.defaultForFlavor(),
      LocalSpeechModelId.whisperSmall,
    );
  });

  test('default model is SenseVoice on CN flavors', () {
    AppFlavor.init('cnDev');
    expect(
      LocalSpeechModelProfile.defaultForFlavor(),
      LocalSpeechModelId.senseVoice,
    );
  });

  test('storage round-trip preserves model id', () {
    for (final id in LocalSpeechModelId.values) {
      final profile = LocalSpeechModelProfile.fromId(id);
      expect(
        LocalSpeechModelProfile.fromStorageValue(profile.storageValue),
        id,
      );
    }
  });

  test('whisper profile exposes encoder decoder and tokens files', () {
    const profile = LocalSpeechModelProfile.whisperSmall;
    expect(profile.isWhisper, isTrue);
    expect(profile.encoderFileName, 'small-encoder.int8.onnx');
    expect(profile.decoderFileName, 'small-decoder.int8.onnx');
    expect(profile.tokensFileName, 'small-tokens.txt');
    expect(profile.requiredFileNames, hasLength(3));
    expect(profile.directDownloadFiles, hasLength(3));
    expect(profile.chinaMirrorFiles, hasLength(3));
  });

  test('sense voice profile exposes onnx model and tokens files', () {
    const profile = LocalSpeechModelProfile.senseVoice;
    expect(profile.isWhisper, isFalse);
    expect(profile.senseVoiceModelFileName, 'model.int8.onnx');
    expect(profile.tokensFileName, 'tokens.txt');
  });

  test('global flavor lists Whisper first', () {
    final profiles = LocalSpeechModelProfile.selectableProfiles();
    expect(profiles.first.id, LocalSpeechModelId.whisperSmall);
  });
}
