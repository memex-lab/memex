/// On-device speech engines and the languages each one can actually cover.
///
/// SenseVoice is the existing model. It covers Chinese, English, Japanese,
/// Korean, and Cantonese. Whisper tiny is an optional second download from
/// the sherpa-onnx release `sherpa-onnx-whisper-tiny`, and it is what makes
/// German and the other European languages in [localSpeechLanguageOptions]
/// work offline.
class LocalSpeechEngines {
  static const senseVoice = 'sensevoice';
  static const whisperTiny = 'whisper_tiny';
  static const defaultEngine = senseVoice;

  static const values = <String>[senseVoice, whisperTiny];

  static String normalize(String? raw) {
    if (raw == whisperTiny) return whisperTiny;
    return senseVoice;
  }
}

class LocalSpeechLanguageOption {
  const LocalSpeechLanguageOption({
    required this.code,
    required this.endonym,
    required this.senseVoice,
    required this.whisper,
  });

  final String code;
  final String endonym;
  final bool senseVoice;
  final bool whisper;
}

const localSpeechLanguageAuto = 'auto';

const localSpeechLanguageOptions = <LocalSpeechLanguageOption>[
  LocalSpeechLanguageOption(
    code: localSpeechLanguageAuto,
    endonym: 'Auto',
    senseVoice: true,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'zh',
    endonym: '中文',
    senseVoice: true,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'en',
    endonym: 'English',
    senseVoice: true,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'ja',
    endonym: '日本語',
    senseVoice: true,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'ko',
    endonym: '한국어',
    senseVoice: true,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'yue',
    endonym: '粵語',
    senseVoice: true,
    whisper: false,
  ),
  LocalSpeechLanguageOption(
    code: 'de',
    endonym: 'Deutsch',
    senseVoice: false,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'fr',
    endonym: 'Français',
    senseVoice: false,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'es',
    endonym: 'Español',
    senseVoice: false,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'it',
    endonym: 'Italiano',
    senseVoice: false,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'pt',
    endonym: 'Português',
    senseVoice: false,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'nl',
    endonym: 'Nederlands',
    senseVoice: false,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'pl',
    endonym: 'Polski',
    senseVoice: false,
    whisper: true,
  ),
  LocalSpeechLanguageOption(
    code: 'ru',
    endonym: 'Русский',
    senseVoice: false,
    whisper: true,
  ),
];

class LocalSpeechLanguages {
  static String normalize(String? raw) {
    for (final option in localSpeechLanguageOptions) {
      if (option.code == raw) return option.code;
    }
    return localSpeechLanguageAuto;
  }

  static LocalSpeechLanguageOption optionFor(String? raw) {
    final code = normalize(raw);
    return localSpeechLanguageOptions
        .firstWhere((option) => option.code == code);
  }
}

class LocalSpeechPlan {
  const LocalSpeechPlan({
    required this.engine,
    required this.language,
    required this.supported,
    required this.modelLanguage,
  });

  final String engine;
  final String language;
  final bool supported;

  /// Value passed to sherpa. Empty means Whisper should detect the language.
  /// SenseVoice uses `auto` for that case.
  final String modelLanguage;
}

LocalSpeechPlan planLocalSpeech({
  required String engine,
  required String language,
}) {
  final normalizedEngine = LocalSpeechEngines.normalize(engine);
  final option = LocalSpeechLanguages.optionFor(language);
  final supported = normalizedEngine == LocalSpeechEngines.whisperTiny
      ? option.whisper
      : option.senseVoice;
  final modelLanguage = !supported
      ? ''
      : normalizedEngine == LocalSpeechEngines.whisperTiny
          ? (option.code == localSpeechLanguageAuto ? '' : option.code)
          : (option.code == localSpeechLanguageAuto
              ? localSpeechLanguageAuto
              : option.code);
  return LocalSpeechPlan(
    engine: normalizedEngine,
    language: option.code,
    supported: supported,
    modelLanguage: modelLanguage,
  );
}

class UnsupportedLocalSpeechLanguage implements Exception {
  UnsupportedLocalSpeechLanguage({
    required this.engine,
    required this.language,
  });

  final String engine;
  final String language;

  @override
  String toString() => 'UnsupportedLocalSpeechLanguage($engine, $language)';
}

/// Files inside the official `sherpa-onnx-whisper-tiny` package.
///
/// The int8 encoder is 12 MB and the int8 decoder is 86 MB in the sherpa
/// package listing, plus the token file. [unpackedSizeMb] is that disk size,
/// rounded up, so the download prompt does not understate the model.
class WhisperTinyPackage {
  static const dirName = 'sherpa-onnx-whisper-tiny';
  static const encoderFile = 'tiny-encoder.int8.onnx';
  static const decoderFile = 'tiny-decoder.int8.onnx';
  static const tokensFile = 'tiny-tokens.txt';
  static const archiveUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-tiny.tar.bz2';
  static const mirrorBase =
      'https://hf-mirror.com/csukuangfj/sherpa-onnx-whisper-tiny/resolve/main';
  static const unpackedSizeMb = 99;

  static bool keepArchiveEntry(String name) {
    final base = name.split('/').last;
    return base == encoderFile || base == decoderFile || base == tokensFile;
  }
}
