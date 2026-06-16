import 'dart:io';
import 'dart:typed_data';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/data/services/realtime_speech_transcriber.dart';
import 'package:memex/data/services/tencent_cloud_asr_service.dart';
import 'package:memex/data/services/whisper_service.dart';
import 'package:memex/data/services/xiaomi_mimo_asr_service.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/speech_recognition_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

class SpeechTranscriptionResult {
  final String? text;
  final ModelUsage? usage;
  final String model;

  const SpeechTranscriptionResult({
    required this.text,
    required this.usage,
    required this.model,
  });
}

class SpeechTranscriptionService {
  SpeechTranscriptionService({
    TencentCloudAsrService? tencentCloudAsrService,
    XiaomiMimoAsrService? xiaomiMimoAsrService,
  })  : _tencentCloudAsrService =
            tencentCloudAsrService ?? TencentCloudAsrService.instance,
        _xiaomiMimoAsrService =
            xiaomiMimoAsrService ?? XiaomiMimoAsrService.instance;

  SpeechTranscriptionService._()
      : _tencentCloudAsrService = TencentCloudAsrService.instance,
        _xiaomiMimoAsrService = XiaomiMimoAsrService.instance;

  static final SpeechTranscriptionService instance =
      SpeechTranscriptionService._();

  final TencentCloudAsrService _tencentCloudAsrService;
  final XiaomiMimoAsrService _xiaomiMimoAsrService;
  final Logger _logger = getLogger('SpeechTranscriptionService');

  Future<bool> isUsingLocalModel() async {
    final config = await UserStorage.getSpeechRecognitionConfig();
    return config.provider == SpeechRecognitionProvider.local;
  }

  Future<SpeechRecognitionConfig> getConfig() {
    return UserStorage.getSpeechRecognitionConfig();
  }

  /// Whether the local speech model needs to be downloaded before recording.
  /// Returns false when using cloud model (no local download needed).
  Future<bool> requiresLocalModelDownload() async {
    if (!await isUsingLocalModel()) return false;
    return !await WhisperService.instance.isModelDownloaded();
  }

  /// Whether real-time streaming transcription is available.
  Future<bool> supportsStreamingTranscription() async {
    final config = await getConfig();
    switch (config.provider) {
      case SpeechRecognitionProvider.local:
        return await WhisperService.instance.isModelDownloaded();
      case SpeechRecognitionProvider.tencentCloud:
        return config.tencentCloud.isConfigured;
      case SpeechRecognitionProvider.xiaomiMimo:
        return false;
    }
  }

  Future<RealtimeSpeechTranscriber?> createRealtimeTranscriber({
    required void Function(String fullText) onTextChanged,
  }) async {
    final config = await getConfig();
    switch (config.provider) {
      case SpeechRecognitionProvider.local:
        if (!await WhisperService.instance.isModelDownloaded()) return null;
        return LocalRealtimeSpeechTranscriber(onTextChanged: onTextChanged);
      case SpeechRecognitionProvider.tencentCloud:
        if (!config.tencentCloud.isConfigured) return null;
        return _tencentCloudAsrService.createRealtimeTranscriber(
          config: config.tencentCloud,
          onTextChanged: onTextChanged,
        );
      case SpeechRecognitionProvider.xiaomiMimo:
        return null;
    }
  }

  Future<String?> transcribeFile(
    String audioPath, {
    bool skipLengthCheck = false,
  }) async {
    final result = await transcribeFileWithMetadata(
      audioPath,
      skipLengthCheck: skipLengthCheck,
    );
    return result.text;
  }

  Future<SpeechTranscriptionResult> transcribeFileWithMetadata(
    String audioPath, {
    bool skipLengthCheck = false,
  }) async {
    final config = await UserStorage.getSpeechRecognitionConfig();

    switch (config.provider) {
      case SpeechRecognitionProvider.local:
        return _transcribeFileLocally(
          audioPath,
          skipLengthCheck: skipLengthCheck,
        );
      case SpeechRecognitionProvider.tencentCloud:
        return _transcribeFileWithTencentCloud(audioPath, config.tencentCloud);
      case SpeechRecognitionProvider.xiaomiMimo:
        return _transcribeFileWithXiaomiMimo(audioPath, config.xiaomiMimo);
    }
  }

  Future<String?> transcribeSamples(Float32List samples) async {
    final result = await transcribeSamplesWithMetadata(samples);
    return result.text;
  }

  Future<SpeechTranscriptionResult> transcribeSamplesWithMetadata(
    Float32List samples,
  ) async {
    final config = await UserStorage.getSpeechRecognitionConfig();

    switch (config.provider) {
      case SpeechRecognitionProvider.local:
        return _transcribeSamplesLocally(samples);
      case SpeechRecognitionProvider.tencentCloud:
        return _transcribeSamplesWithTencentCloud(
          samples,
          config.tencentCloud,
        );
      case SpeechRecognitionProvider.xiaomiMimo:
        return _transcribeSamplesWithXiaomiMimo(samples, config.xiaomiMimo);
    }
  }

  Future<SpeechTranscriptionResult> _transcribeFileLocally(
    String audioPath, {
    bool skipLengthCheck = false,
  }) async {
    final safety = await _inspectAudioForTranscription(audioPath);
    if (!safety.safeForAnalysis) {
      _logger.warning(
        'Skipping unsafe local audio transcription for $audioPath: ${safety.reason}',
      );
      return const SpeechTranscriptionResult(
        text: null,
        usage: null,
        model: 'asset-safety',
      );
    }
    final text = await WhisperService.instance.transcribe(
      audioPath,
      skipLengthCheck: skipLengthCheck,
    );
    return SpeechTranscriptionResult(
      text: text,
      usage: null,
      model: 'sensevoice-local',
    );
  }

  Future<SpeechTranscriptionResult> _transcribeSamplesLocally(
    Float32List samples,
  ) async {
    final text = await WhisperService.instance.transcribeSamples(samples);
    return SpeechTranscriptionResult(
      text: text,
      usage: null,
      model: 'sensevoice-local',
    );
  }

  Future<SpeechTranscriptionResult> _transcribeFileWithTencentCloud(
    String audioPath,
    TencentCloudAsrConfig config,
  ) async {
    final safety = await _inspectAudioForTranscription(audioPath);
    if (!safety.safeForAnalysis) {
      _logger.warning(
        'Skipping unsafe Tencent Cloud audio transcription for $audioPath: ${safety.reason}',
      );
      return const SpeechTranscriptionResult(
        text: null,
        usage: null,
        model: 'asset-safety',
      );
    }
    if (!config.isConfigured) {
      _logger.warning('Tencent Cloud ASR is selected but not configured.');
      return const SpeechTranscriptionResult(
        text: null,
        usage: null,
        model: 'tencent-cloud-asr-unconfigured',
      );
    }
    final text = await _tencentCloudAsrService.transcribeFile(
      audioPath,
      config: config,
    );
    return SpeechTranscriptionResult(
      text: text,
      usage: null,
      model: 'tencent-cloud-asr/${config.engineType}',
    );
  }

  Future<SpeechTranscriptionResult> _transcribeFileWithXiaomiMimo(
    String audioPath,
    XiaomiMimoAsrConfig config,
  ) async {
    final safety = await _inspectAudioForTranscription(audioPath);
    if (!safety.safeForAnalysis) {
      _logger.warning(
        'Skipping unsafe Xiaomi MiMo audio transcription for $audioPath: ${safety.reason}',
      );
      return const SpeechTranscriptionResult(
        text: null,
        usage: null,
        model: 'asset-safety',
      );
    }
    final resolvedConfig = await _resolveXiaomiMimoConfig(config);
    if (resolvedConfig == null) {
      _logger.warning('Xiaomi MiMo ASR is selected but not configured.');
      return const SpeechTranscriptionResult(
        text: null,
        usage: null,
        model: 'xiaomi-mimo-asr-unconfigured',
      );
    }
    final text = await _xiaomiMimoAsrService.transcribeFile(
      audioPath,
      config: resolvedConfig,
    );
    return SpeechTranscriptionResult(
      text: text,
      usage: null,
      model: 'xiaomi-mimo-asr/${resolvedConfig.model}',
    );
  }

  Future<AssetSafetyReport> _inspectAudioForTranscription(
    String audioPath,
  ) async {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found: $audioPath');
    }
    return AssetSafetyService.instance.inspectFile(audioPath);
  }

  Future<SpeechTranscriptionResult> _transcribeSamplesWithTencentCloud(
    Float32List samples,
    TencentCloudAsrConfig config,
  ) async {
    if (!config.isConfigured) {
      _logger.warning('Tencent Cloud ASR is selected but not configured.');
      return const SpeechTranscriptionResult(
        text: null,
        usage: null,
        model: 'tencent-cloud-asr-unconfigured',
      );
    }
    final bytes = _samplesToWavBytes(samples);
    final text = await _tencentCloudAsrService.transcribeBytes(
      bytes,
      config: config,
      voiceFormat: 'wav',
    );
    return SpeechTranscriptionResult(
      text: text,
      usage: null,
      model: 'tencent-cloud-asr/${config.engineType}',
    );
  }

  Future<SpeechTranscriptionResult> _transcribeSamplesWithXiaomiMimo(
    Float32List samples,
    XiaomiMimoAsrConfig config,
  ) async {
    final resolvedConfig = await _resolveXiaomiMimoConfig(config);
    if (resolvedConfig == null) {
      _logger.warning('Xiaomi MiMo ASR is selected but not configured.');
      return const SpeechTranscriptionResult(
        text: null,
        usage: null,
        model: 'xiaomi-mimo-asr-unconfigured',
      );
    }
    final bytes = _samplesToWavBytes(samples);
    final text = await _xiaomiMimoAsrService.transcribeBytes(
      bytes,
      config: resolvedConfig,
      mimeType: 'audio/wav',
    );
    return SpeechTranscriptionResult(
      text: text,
      usage: null,
      model: 'xiaomi-mimo-asr/${resolvedConfig.model}',
    );
  }

  Future<XiaomiMimoAsrConfig?> _resolveXiaomiMimoConfig(
    XiaomiMimoAsrConfig config,
  ) async {
    if (!config.usesLinkedConfig) {
      return config.hasDirectCredentials ? config : null;
    }

    final configs = await UserStorage.getLLMConfigs();
    LLMConfig? linkedConfig;
    for (final llmConfig in configs) {
      if (llmConfig.key == config.llmConfigKey &&
          llmConfig.type == LLMConfig.typeMimo &&
          llmConfig.isValid) {
        linkedConfig = llmConfig;
        break;
      }
    }
    if (linkedConfig == null) return null;

    return config.copyWith(
      apiKey: linkedConfig.apiKey,
      baseUrl: linkedConfig.baseUrl.isEmpty
          ? XiaomiMimoAsrConfig.defaultBaseUrl
          : linkedConfig.baseUrl,
    );
  }

  /// Save raw PCM 16-bit data (16kHz, mono) as a WAV file.
  Future<void> savePcmAsWav(String filePath, Uint8List pcmData) async {
    final file = File(filePath);
    final sink = file.openWrite();
    final dataSize = pcmData.length;
    final fileSize = 36 + dataSize;
    final header = ByteData(44);
    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // (space)
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // mono
    header.setUint32(24, 16000, Endian.little); // sample rate
    header.setUint32(28, 32000, Endian.little); // byte rate
    header.setUint16(32, 2, Endian.little); // block align
    header.setUint16(34, 16, Endian.little); // bits per sample
    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);
    sink.add(header.buffer.asUint8List());
    sink.add(pcmData);
    await sink.close();
  }

  List<int> _samplesToWavBytes(Float32List samples) {
    final pcm = Int16List(samples.length);
    for (int i = 0; i < samples.length; i++) {
      final scaled = (samples[i] * 32767).round().clamp(-32768, 32767);
      pcm[i] = scaled;
    }

    final pcmBytes = pcm.buffer.asUint8List();
    final dataSize = pcmBytes.length;
    final fileSize = 36 + dataSize;
    final header = ByteData(44);

    header.setUint8(0, 0x52);
    header.setUint8(1, 0x49);
    header.setUint8(2, 0x46);
    header.setUint8(3, 0x46);
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57);
    header.setUint8(9, 0x41);
    header.setUint8(10, 0x56);
    header.setUint8(11, 0x45);
    header.setUint8(12, 0x66);
    header.setUint8(13, 0x6D);
    header.setUint8(14, 0x74);
    header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, 16000, Endian.little);
    header.setUint32(28, 32000, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    header.setUint8(36, 0x64);
    header.setUint8(37, 0x61);
    header.setUint8(38, 0x74);
    header.setUint8(39, 0x61);
    header.setUint32(40, dataSize, Endian.little);

    return [...header.buffer.asUint8List(), ...pcmBytes];
  }
}
