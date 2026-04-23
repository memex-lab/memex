import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:memex/data/services/whisper_service.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
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
  SpeechTranscriptionService._();

  static final SpeechTranscriptionService instance =
      SpeechTranscriptionService._();

  final Logger _logger = getLogger('SpeechTranscriptionService');

  Future<bool> isUsingLocalModel() {
    return UserStorage.getUseLocalSpeechToText();
  }

  /// Whether the local speech model needs to be downloaded before recording.
  /// Returns false when using cloud model (no local download needed).
  Future<bool> requiresLocalModelDownload() async {
    if (!await isUsingLocalModel()) return false;
    return !await WhisperService.instance.isModelDownloaded();
  }

  /// Whether real-time streaming transcription is available.
  /// Only supported with the local model.
  Future<bool> supportsStreamingTranscription() async {
    if (!await isUsingLocalModel()) return false;
    return await WhisperService.instance.isModelDownloaded();
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
    final useLocal = await UserStorage.getUseLocalSpeechToText();

    if (useLocal) {
      return _transcribeFileLocally(audioPath,
          skipLengthCheck: skipLengthCheck);
    }

    return _transcribeFileWithCloud(audioPath);
  }

  Future<String?> transcribeSamples(Float32List samples) async {
    final result = await transcribeSamplesWithMetadata(samples);
    return result.text;
  }

  Future<SpeechTranscriptionResult> transcribeSamplesWithMetadata(
      Float32List samples) async {
    final useLocal = await UserStorage.getUseLocalSpeechToText();

    if (useLocal) {
      return _transcribeSamplesLocally(samples);
    }

    return _transcribeSamplesWithCloud(samples);
  }

  Future<SpeechTranscriptionResult> _transcribeFileLocally(
    String audioPath, {
    bool skipLengthCheck = false,
  }) async {
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
      Float32List samples) async {
    final text = await WhisperService.instance.transcribeSamples(samples);
    return SpeechTranscriptionResult(
      text: text,
      usage: null,
      model: 'sensevoice-local',
    );
  }

  Future<SpeechTranscriptionResult> _transcribeFileWithCloud(
    String audioPath,
  ) async {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found: $audioPath');
    }
    final bytes = await file.readAsBytes();
    final mimeType = _mimeTypeForPath(audioPath);
    return _transcribeAudioBytesWithCloud(
      bytes,
      mimeType: mimeType,
    );
  }

  Future<SpeechTranscriptionResult> _transcribeSamplesWithCloud(
    Float32List samples,
  ) async {
    final bytes = _samplesToWavBytes(samples);
    return _transcribeAudioBytesWithCloud(
      bytes,
      mimeType: 'audio/wav',
    );
  }

  Future<SpeechTranscriptionResult> _transcribeAudioBytesWithCloud(
    List<int> bytes, {
    required String mimeType,
  }) async {
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.analyzeAssets,
      defaultClientKey: LLMConfig.defaultClientKey,
    );

    const systemPrompt = '''You are a speech transcription engine.
Your job is to return only a transcript, never an explanation.''';
    const prompt = '''Transcribe the spoken audio exactly.
Return the result wrapped in XML tags as:
<transcript>...</transcript>
Rules:
- Output exactly one transcript block.
- Do not add any text before or after the transcript block.
- Do not add introductions, labels, translations, summaries, notes, or quotes.
- Preserve the spoken language as-is.
- If the audio contains no recognizable speech, return <transcript></transcript>.''';
    final response = await resources.client.generate(
      [
        SystemMessage(systemPrompt),
        UserMessage([
          TextPart(prompt),
          AudioPart(base64Encode(bytes), mimeType),
        ])
      ],
      modelConfig: resources.modelConfig,
    );

    return SpeechTranscriptionResult(
      text: _normalizeCloudTranscript(response.textOutput),
      usage: response.usage,
      model: response.model,
    );
  }

  String? _normalizeCloudTranscript(String? text) {
    final trimmed = text?.trim();
    if (trimmed == null || trimmed.isEmpty) return trimmed;

    final tagged = _extractTaggedTranscript(trimmed);
    if (tagged != null) {
      return _trimOuterQuotes(tagged);
    }

    if (_looksLikePlainTranscript(trimmed)) {
      return _trimOuterQuotes(trimmed);
    }

    _logger.warning(
        'Cloud speech transcription returned non-transcript text: $trimmed');
    return null;
  }

  String? _extractTaggedTranscript(String text) {
    final match = RegExp(
      r'<transcript>([\s\S]*?)</transcript>',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    return match.group(1)?.trim();
  }

  bool _looksLikePlainTranscript(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return true;

    if (normalized.contains('```')) return false;

    final nonEmptyLines = normalized
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (nonEmptyLines.isEmpty) return true;

    final firstLine = nonEmptyLines.first;
    final lowerFirstLine = firstLine.toLowerCase();
    const explanatoryFragments = [
      'here is',
      'below is',
      'the following',
      'transcript of the speech',
      'transcript:',
      'transcription:',
      'following is a transcript',
      '以下是',
      '文字稿',
      '转写结果',
      '识别结果',
      '语音识别',
      '语音转写',
    ];

    if (explanatoryFragments.any(lowerFirstLine.contains) &&
        nonEmptyLines.length > 1) {
      return false;
    }

    if (RegExp(r'^[-*•]\s').hasMatch(firstLine)) return false;

    return true;
  }

  String _trimOuterQuotes(String text) {
    var normalized = text.trim();
    if ((normalized.startsWith('"') && normalized.endsWith('"')) ||
        (normalized.startsWith("'") && normalized.endsWith("'")) ||
        (normalized.startsWith('“') && normalized.endsWith('”')) ||
        (normalized.startsWith('‘') && normalized.endsWith('’'))) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }
    return normalized;
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

  String _mimeTypeForPath(String audioPath) {
    switch (path.extension(audioPath).toLowerCase()) {
      case '.wav':
        return 'audio/wav';
      case '.mp3':
      case '.m4a':
        return 'audio/mp3';
      case '.aiff':
      case '.aif':
        return 'audio/aiff';
      case '.aac':
        return 'audio/aac';
      case '.ogg':
        return 'audio/ogg';
      case '.flac':
        return 'audio/flac';
      case '.wma':
        throw Exception('Audio format .wma is not supported.');
      default:
        return 'audio/mp3';
    }
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
