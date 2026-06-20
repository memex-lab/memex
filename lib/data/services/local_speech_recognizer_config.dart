import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:memex/domain/models/local_speech_model.dart';

/// Builds sherpa-onnx offline recognizer configs for supported local models.
class LocalSpeechRecognizerConfig {
  LocalSpeechRecognizerConfig._();

  static sherpa.OfflineRecognizerConfig build({
    required LocalSpeechModelProfile profile,
    required String modelDir,
    required String provider,
    int numThreads = 2,
  }) {
    final tokensPath = '$modelDir/${profile.tokensFileName}';

    if (profile.isWhisper) {
      return sherpa.OfflineRecognizerConfig(
        model: sherpa.OfflineModelConfig(
          whisper: sherpa.OfflineWhisperModelConfig(
            encoder: '$modelDir/${profile.encoderFileName}',
            decoder: '$modelDir/${profile.decoderFileName}',
            language: profile.whisperLanguage,
            task: 'transcribe',
          ),
          tokens: tokensPath,
          numThreads: numThreads,
          debug: false,
          provider: provider,
        ),
      );
    }

    return sherpa.OfflineRecognizerConfig(
      model: sherpa.OfflineModelConfig(
        senseVoice: sherpa.OfflineSenseVoiceModelConfig(
          model: '$modelDir/${profile.senseVoiceModelFileName}',
          language: 'auto',
          useInverseTextNormalization: true,
        ),
        tokens: tokensPath,
        numThreads: numThreads,
        debug: false,
        provider: provider,
      ),
    );
  }
}
