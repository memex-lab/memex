import 'package:memex/config/app_flavor.dart';

/// On-device speech recognition model profiles supported by [WhisperService].
enum LocalSpeechModelId {
  senseVoice,
  whisperSmall,
}

class LocalSpeechModelProfile {
  const LocalSpeechModelProfile({
    required this.id,
    required this.dirName,
    required this.approxSizeMB,
    required this.supportsChinaMirror,
    required this.archiveUrl,
    required this.requiredFileNames,
    this.directDownloadFiles = const {},
    this.chinaMirrorFiles = const {},
    this.whisperLanguage = '',
  });

  final LocalSpeechModelId id;
  final String dirName;
  final double approxSizeMB;
  final bool supportsChinaMirror;
  final String archiveUrl;
  final List<String> requiredFileNames;

  /// Individual file URLs for global direct download (Hugging Face).
  final Map<String, String> directDownloadFiles;

  /// Individual file URLs for the China mirror (hf-mirror.com).
  final Map<String, String> chinaMirrorFiles;

  /// Whisper language hint; empty lets multilingual Whisper auto-detect.
  final String whisperLanguage;

  bool get isWhisper => id == LocalSpeechModelId.whisperSmall;

  String? get encoderFileName =>
      isWhisper ? requiredFileNames.firstWhere((f) => f.contains('encoder')) : null;

  String? get decoderFileName =>
      isWhisper ? requiredFileNames.firstWhere((f) => f.contains('decoder')) : null;

  String? get tokensFileName =>
      requiredFileNames.firstWhere((f) => f.contains('tokens'));

  String? get senseVoiceModelFileName =>
      isWhisper ? null : requiredFileNames.firstWhere((f) => f.endsWith('.onnx'));

  static const senseVoice = LocalSpeechModelProfile(
    id: LocalSpeechModelId.senseVoice,
    dirName: 'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17',
    approxSizeMB: 230,
    supportsChinaMirror: true,
    archiveUrl:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2',
    requiredFileNames: ['model.int8.onnx', 'tokens.txt'],
    directDownloadFiles: {
      'model.int8.onnx':
          'https://huggingface.co/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/model.int8.onnx',
      'tokens.txt':
          'https://huggingface.co/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/tokens.txt',
    },
    chinaMirrorFiles: {
      'model.int8.onnx':
          'https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/model.int8.onnx',
      'tokens.txt':
          'https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/tokens.txt',
    },
  );

  static const whisperSmall = LocalSpeechModelProfile(
    id: LocalSpeechModelId.whisperSmall,
    dirName: 'sherpa-onnx-whisper-small',
    approxSizeMB: 610,
    supportsChinaMirror: true,
    archiveUrl:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-small.tar.bz2',
    requiredFileNames: [
      'small-encoder.int8.onnx',
      'small-decoder.int8.onnx',
      'small-tokens.txt',
    ],
    directDownloadFiles: {
      'small-encoder.int8.onnx':
          'https://huggingface.co/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-encoder.int8.onnx',
      'small-decoder.int8.onnx':
          'https://huggingface.co/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-decoder.int8.onnx',
      'small-tokens.txt':
          'https://huggingface.co/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-tokens.txt',
    },
    chinaMirrorFiles: {
      'small-encoder.int8.onnx':
          'https://hf-mirror.com/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-encoder.int8.onnx',
      'small-decoder.int8.onnx':
          'https://hf-mirror.com/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-decoder.int8.onnx',
      'small-tokens.txt':
          'https://hf-mirror.com/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-tokens.txt',
    },
    whisperLanguage: '',
  );

  static LocalSpeechModelProfile fromId(LocalSpeechModelId id) {
    return switch (id) {
      LocalSpeechModelId.senseVoice => senseVoice,
      LocalSpeechModelId.whisperSmall => whisperSmall,
    };
  }

  static LocalSpeechModelId fromStorageValue(String? value) {
    return switch (value) {
      'whisper_small' => LocalSpeechModelId.whisperSmall,
      'sense_voice' => LocalSpeechModelId.senseVoice,
      _ => defaultForFlavor(),
    };
  }

  String get storageValue => switch (id) {
        LocalSpeechModelId.senseVoice => 'sense_voice',
        LocalSpeechModelId.whisperSmall => 'whisper_small',
      };

  static List<LocalSpeechModelProfile> selectableProfiles() {
    if (AppFlavor.isCN) {
      return const [senseVoice, whisperSmall];
    }
    return const [whisperSmall, senseVoice];
  }

  static LocalSpeechModelId defaultForFlavor() {
    return AppFlavor.isCN
        ? LocalSpeechModelId.senseVoice
        : LocalSpeechModelId.whisperSmall;
  }

  String metadataModelName() => switch (id) {
        LocalSpeechModelId.senseVoice => 'sensevoice-local',
        LocalSpeechModelId.whisperSmall => 'whisper-small-local',
      };
}
