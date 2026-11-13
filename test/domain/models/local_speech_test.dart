import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/local_speech.dart';

void main() {
  test('SenseVoice keeps auto and refuses German', () {
    final auto = planLocalSpeech(
      engine: LocalSpeechEngines.senseVoice,
      language: 'auto',
    );
    expect(auto.supported, isTrue);
    expect(auto.modelLanguage, 'auto');

    final german = planLocalSpeech(
      engine: LocalSpeechEngines.senseVoice,
      language: 'de',
    );
    expect(german.supported, isFalse);
    expect(german.modelLanguage, isEmpty);
  });

  test('Whisper tiny accepts German and leaves auto detection empty', () {
    final german = planLocalSpeech(
      engine: LocalSpeechEngines.whisperTiny,
      language: 'de',
    );
    expect(german.supported, isTrue);
    expect(german.modelLanguage, 'de');

    final auto = planLocalSpeech(
      engine: LocalSpeechEngines.whisperTiny,
      language: 'auto',
    );
    expect(auto.supported, isTrue);
    expect(auto.modelLanguage, isEmpty);
  });

  test('Cantonese stays on SenseVoice', () {
    final senseVoice = planLocalSpeech(
      engine: LocalSpeechEngines.senseVoice,
      language: 'yue',
    );
    expect(senseVoice.supported, isTrue);
    expect(senseVoice.modelLanguage, 'yue');

    final whisper = planLocalSpeech(
      engine: LocalSpeechEngines.whisperTiny,
      language: 'yue',
    );
    expect(whisper.supported, isFalse);
  });

  test('unknown engine and language fall back to SenseVoice auto', () {
    expect(LocalSpeechEngines.normalize('nope'), LocalSpeechEngines.senseVoice);
    expect(LocalSpeechLanguages.normalize('klingon'), 'auto');
    final plan = planLocalSpeech(engine: 'nope', language: 'klingon');
    expect(plan.engine, LocalSpeechEngines.senseVoice);
    expect(plan.language, 'auto');
    expect(plan.supported, isTrue);
  });

  test('Whisper package keeps only the int8 files from the sherpa archive', () {
    expect(
      WhisperTinyPackage.archiveUrl,
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-tiny.tar.bz2',
    );
    expect(
      WhisperTinyPackage.keepArchiveEntry(
        'sherpa-onnx-whisper-tiny/tiny-encoder.int8.onnx',
      ),
      isTrue,
    );
    expect(
      WhisperTinyPackage.keepArchiveEntry(
        'sherpa-onnx-whisper-tiny/tiny-decoder.int8.onnx',
      ),
      isTrue,
    );
    expect(
      WhisperTinyPackage.keepArchiveEntry(
        'sherpa-onnx-whisper-tiny/tiny-decoder.onnx',
      ),
      isFalse,
    );
    expect(
      WhisperTinyPackage.keepArchiveEntry(
        'sherpa-onnx-whisper-tiny/tiny-encoder.onnx',
      ),
      isFalse,
    );
  });
}
