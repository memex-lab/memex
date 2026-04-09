import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/audio_converter.dart';
import 'package:archive/archive.dart';

/// Service for on-device speech-to-text using sherpa-onnx + SenseVoice.
///
/// Handles model download, caching, and transcription.
class WhisperService {
  static final WhisperService _instance = WhisperService._();
  static WhisperService get instance => _instance;
  WhisperService._();

  final Logger _logger = getLogger('WhisperService');

  static const _modelDirName =
      'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17';
  static const _modelFileName = 'model.int8.onnx';
  static const _tokensFileName = 'tokens.txt';

  /// Download URLs
  static const _downloadUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2';
  static const _downloadUrlChina =
      'https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/model.int8.onnx';
  static const _tokensUrlChina =
      'https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/tokens.txt';

  sherpa.OfflineRecognizer? _recognizer;

  /// Model directory path.
  Future<String> _modelDir() async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/$_modelDirName';
  }

  /// Whether the model files exist locally.
  Future<bool> isModelDownloaded() async {
    final dir = await _modelDir();
    final model = File('$dir/$_modelFileName');
    final tokens = File('$dir/$_tokensFileName');
    return model.existsSync() && tokens.existsSync();
  }

  /// Download model files with progress callback.
  /// [onProgress] receives values from 0.0 to 1.0.
  /// [useChineseMirror] downloads individual files from hf-mirror.com.
  Future<void> downloadModel({
    required ValueChanged<double> onProgress,
    bool useChineseMirror = false,
  }) async {
    final dir = await _modelDir();
    await Directory(dir).create(recursive: true);

    if (useChineseMirror) {
      // Download individual files from Chinese mirror
      await _downloadFile(
        _downloadUrlChina,
        '$dir/$_modelFileName',
        onProgress: (p) => onProgress(p * 0.95), // 95% for model
      );
      await _downloadFile(
        _tokensUrlChina,
        '$dir/$_tokensFileName',
        onProgress: (p) => onProgress(0.95 + p * 0.05), // last 5% for tokens
      );
    } else {
      // Download tar.bz2 archive from GitHub
      _logger.info('Downloading SenseVoice model from $_downloadUrl');
      final tmpFile = File('$dir/model.tar.bz2');
      await _downloadFile(
        _downloadUrl,
        tmpFile.path,
        onProgress: (p) => onProgress(p * 0.9),
      );

      // Extract
      _logger.info('Extracting model archive...');
      onProgress(0.9);
      final bytes = await tmpFile.readAsBytes();
      final decompressed = BZip2Decoder().decodeBytes(bytes);
      final archive = TarDecoder().decodeBytes(decompressed);

      for (final file in archive) {
        if (file.isFile) {
          final name = file.name.split('/').last;
          if (name == _modelFileName || name == _tokensFileName) {
            final outFile = File('$dir/$name');
            await outFile.writeAsBytes(file.content as List<int>);
          }
        }
      }
      // Clean up archive
      if (tmpFile.existsSync()) await tmpFile.delete();
      onProgress(1.0);
    }

    _logger.info('SenseVoice model downloaded to $dir');
  }

  Future<void> _downloadFile(
    String url,
    String savePath, {
    required ValueChanged<double> onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await http.Client().send(request);
    final totalBytes = response.contentLength ?? 0;
    int receivedBytes = 0;
    final sink = File(savePath).openWrite();

    await for (final chunk in response.stream) {
      sink.add(chunk);
      receivedBytes += chunk.length;
      if (totalBytes > 0) {
        onProgress(receivedBytes / totalBytes);
      }
    }
    await sink.close();
  }

  /// Get or create the recognizer instance.
  Future<sherpa.OfflineRecognizer> _getRecognizer() async {
    if (_recognizer != null) return _recognizer!;

    // Initialize sherpa-onnx bindings (must be called once before any usage)
    sherpa.initBindings();

    final dir = await _modelDir();
    final config = sherpa.OfflineRecognizerConfig(
      model: sherpa.OfflineModelConfig(
        senseVoice: sherpa.OfflineSenseVoiceModelConfig(
          model: '$dir/$_modelFileName',
          language: 'auto',
          useInverseTextNormalization: true,
        ),
        tokens: '$dir/$_tokensFileName',
        numThreads: 2,
        debug: false,
      ),
    );

    _recognizer = sherpa.OfflineRecognizer(config);
    _logger.info('SenseVoice recognizer initialized');
    return _recognizer!;
  }

  /// Max audio duration in seconds for transcription.
  /// Longer audio will be truncated to avoid OOM.
  static const int _maxAudioSeconds = 60;

  /// Transcribe an audio file to text.
  /// Supports WAV directly; other formats (m4a, mp3, etc.) are auto-converted.
  /// Audio longer than 60 seconds is truncated.
  Future<String?> transcribe(String audioPath) async {
    try {
      if (!await isModelDownloaded()) {
        _logger.warning('SenseVoice model not downloaded yet');
        return null;
      }

      // Convert to WAV 16kHz mono if needed
      final wavPath = await AudioConverter.toWav16kMono(audioPath);
      if (wavPath == null) {
        _logger.severe('Audio conversion failed for: $audioPath');
        return null;
      }

      // Check file size — reject very large files to avoid OOM
      // 16kHz × 2 bytes × 60s = ~1.92MB + 44 bytes header
      final wavFile = File(wavPath);
      final fileSize = await wavFile.length();
      final maxSize = 16000 * 2 * _maxAudioSeconds + 44;
      if (fileSize > maxSize * 2) {
        _logger.warning(
            'Audio too long (${fileSize ~/ 1024}KB), max ~${_maxAudioSeconds}s. Skipping.');
        if (wavPath != audioPath) {
          try {
            wavFile.deleteSync();
          } catch (_) {}
        }
        return null;
      }

      _logger.info('Transcribing audio: $wavPath (${fileSize ~/ 1024}KB)');
      final recognizer = await _getRecognizer();

      final waveData = sherpa.readWave(wavPath);

      // Truncate samples to max duration to prevent OOM
      final maxSamples = 16000 * _maxAudioSeconds;
      final samples = waveData.samples.length > maxSamples
          ? Float32List.fromList(waveData.samples.sublist(0, maxSamples))
          : waveData.samples;

      final stream = recognizer.createStream();
      stream.acceptWaveform(
        samples: samples,
        sampleRate: waveData.sampleRate,
      );
      recognizer.decode(stream);

      final text = recognizer.getResult(stream).text.trim();
      stream.free();

      // Clean up converted temp file
      if (wavPath != audioPath) {
        try {
          File(wavPath).deleteSync();
        } catch (_) {}
      }

      _logger.info(
          'Transcription complete: ${text.substring(0, text.length.clamp(0, 100))}');
      return text.isEmpty ? null : text;
    } catch (e) {
      _logger.severe('Transcription failed: $e');
      return null;
    }
  }

  /// Dispose the recognizer to free memory.
  void dispose() {
    _recognizer?.free();
    _recognizer = null;
  }

  /// Model download size in MB (approximate, int8 model).
  static const double modelSizeMB = 230;
}
