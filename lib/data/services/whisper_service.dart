import 'dart:io' show File, Directory, Platform, HttpException;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/audio_converter.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/transcription_isolate.dart';
import 'package:memex/domain/models/local_speech_model.dart';
import 'package:archive/archive.dart';

/// Service for on-device speech-to-text using sherpa-onnx.
///
/// Supports SenseVoice (CN-focused) and Whisper Small (multilingual).
class WhisperService {
  static final WhisperService _instance = WhisperService._();
  static WhisperService get instance => _instance;
  WhisperService._();

  final Logger _logger = getLogger('WhisperService');

  sherpa.OfflineRecognizer? _recognizer;
  TranscriptionIsolate? _bgIsolate;
  LocalSpeechModelId? _loadedModelId;

  /// Pick the best available execution provider for the current platform.
  static String get _provider {
    if (Platform.isIOS) return 'coreml';
    if (Platform.isAndroid) return 'nnapi';
    return 'cpu';
  }

  Future<LocalSpeechModelId> getSelectedModel() {
    return UserStorage.getLocalSpeechModel();
  }

  Future<LocalSpeechModelProfile> getSelectedProfile() async {
    return LocalSpeechModelProfile.fromId(await getSelectedModel());
  }

  Future<void> setSelectedModel(LocalSpeechModelId model) async {
    await UserStorage.setLocalSpeechModel(model);
    if (_loadedModelId != null && _loadedModelId != model) {
      dispose();
    }
  }

  Future<String> _modelDirFor(LocalSpeechModelProfile profile) async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/${profile.dirName}';
  }

  Future<bool> isModelDownloaded([LocalSpeechModelId? model]) async {
    final profile =
        LocalSpeechModelProfile.fromId(model ?? await getSelectedModel());
    final dir = await _modelDirFor(profile);
    for (final name in profile.requiredFileNames) {
      if (!await _isValidModelFile('$dir/$name')) return false;
    }
    return true;
  }

  static const int _minOnnxBytes = 100000;
  static const int _minTokensBytes = 100;

  Future<bool> _isValidModelFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;
    final size = await file.length();
    if (path.endsWith('.txt')) return size >= _minTokensBytes;
    if (path.endsWith('.onnx')) return size >= _minOnnxBytes;
    return size > 0;
  }

  Future<bool> deleteDownloadedModel([LocalSpeechModelId? model]) async {
    final profile =
        LocalSpeechModelProfile.fromId(model ?? await getSelectedModel());
    if (_loadedModelId == profile.id) {
      dispose();
    }

    final dirPath = await _modelDirFor(profile);
    final dir = Directory(dirPath);
    if (!await dir.exists()) return false;

    await dir.delete(recursive: true);
    _logger.info('Deleted local speech model directory: $dirPath');
    return true;
  }

  Future<bool> deleteAllDownloadedModels() async {
    dispose();
    var deleted = false;
    for (final profile in [
      LocalSpeechModelProfile.senseVoice,
      LocalSpeechModelProfile.whisperSmall,
    ]) {
      final dirPath = await _modelDirFor(profile);
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        deleted = true;
        _logger.info('Deleted local speech model directory: $dirPath');
      }
    }
    return deleted;
  }

  Future<void> downloadModel({
    LocalSpeechModelId? model,
    required ValueChanged<double> onProgress,
    bool useChineseMirror = false,
  }) async {
    final profile =
        LocalSpeechModelProfile.fromId(model ?? await getSelectedModel());
    await setSelectedModel(profile.id);

    final dir = await _modelDirFor(profile);
    await Directory(dir).create(recursive: true);

    final directFiles = useChineseMirror
        ? profile.chinaMirrorFiles
        : profile.directDownloadFiles;

    if (directFiles.isNotEmpty) {
      await _downloadFileEntries(
        directFiles,
        dir,
        onProgress: onProgress,
      );
    } else if (useChineseMirror) {
      if (!profile.supportsChinaMirror) {
        throw StateError(
          'China mirror is not available for ${profile.storageValue}',
        );
      }
      await _downloadFileEntries(
        profile.chinaMirrorFiles,
        dir,
        onProgress: onProgress,
      );
    } else {
      _logger.info('Downloading ${profile.storageValue} from ${profile.archiveUrl}');
      final tmpFile = File('$dir/model.tar.bz2');
      await _downloadFile(
        profile.archiveUrl,
        tmpFile.path,
        onProgress: (p) => onProgress(p * 0.9),
      );

      _logger.info('Extracting ${profile.storageValue} archive...');
      onProgress(0.9);
      final bytes = await tmpFile.readAsBytes();
      final decompressed = BZip2Decoder().decodeBytes(bytes);
      final archive = TarDecoder().decodeBytes(decompressed);

      for (final file in archive) {
        if (!file.isFile) continue;
        final name = file.name.split('/').last;
        if (profile.requiredFileNames.contains(name)) {
          await File('$dir/$name').writeAsBytes(file.content as List<int>);
        }
      }
      if (tmpFile.existsSync()) await tmpFile.delete();
      onProgress(1.0);
    }

    for (final name in profile.requiredFileNames) {
      if (!await _isValidModelFile('$dir/$name')) {
        throw StateError('Missing or invalid downloaded file: $name');
      }
    }

    _logger.info('${profile.storageValue} downloaded to $dir');
  }

  Future<void> _downloadFileEntries(
    Map<String, String> files,
    String dir, {
    required ValueChanged<double> onProgress,
  }) async {
    final entries = files.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final start = i / entries.length;
      final span = 1 / entries.length;
      await _downloadFile(
        entry.value,
        '$dir/${entry.key}',
        onProgress: (p) => onProgress(start + p * span),
      );
    }
    onProgress(1.0);
  }

  Future<void> _downloadFile(
    String url,
    String savePath, {
    required ValueChanged<double> onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await http.Client().send(request);
    if (response.statusCode != 200) {
      throw HttpException(
        'Download failed (${response.statusCode}) for $url',
        uri: Uri.parse(url),
      );
    }

    final totalBytes = response.contentLength ?? 0;
    var receivedBytes = 0;
    final sink = File(savePath).openWrite();

    await for (final chunk in response.stream) {
      sink.add(chunk);
      receivedBytes += chunk.length;
      if (totalBytes > 0) {
        onProgress(receivedBytes / totalBytes);
      }
    }
    await sink.close();

    if (totalBytes > 0 && receivedBytes < totalBytes) {
      throw HttpException(
        'Incomplete download ($receivedBytes/$totalBytes bytes) for $url',
        uri: Uri.parse(url),
      );
    }
  }

  static Future<double> modelSizeMB([LocalSpeechModelId? model]) async {
    final id = model ?? await UserStorage.getLocalSpeechModel();
    return LocalSpeechModelProfile.fromId(id).approxSizeMB;
  }

  /// Max audio duration in seconds for transcription.
  static const int _maxAudioSeconds = 60;

  Future<String?> transcribe(
    String audioPath, {
    bool skipLengthCheck = false,
  }) async {
    try {
      if (!await isModelDownloaded()) {
        _logger.warning('Local speech model not downloaded yet');
        return null;
      }

      ensureInitialized();

      final wavPath = await AudioConverter.toWav16kMono(audioPath);
      if (wavPath == null) {
        _logger.severe('Audio conversion failed for: $audioPath');
        return null;
      }

      final wavFile = File(wavPath);
      final fileSize = await wavFile.length();
      if (!skipLengthCheck) {
        const maxSize = 16000 * 2 * _maxAudioSeconds + 44;
        if (fileSize > maxSize * 2) {
          _logger.warning(
            'Audio too long (${fileSize ~/ 1024}KB), max ~${_maxAudioSeconds}s. Skipping.',
          );
          if (wavPath != audioPath) {
            try {
              wavFile.deleteSync();
            } catch (_) {}
          }
          return null;
        }
      }

      _logger.info('Transcribing audio: $wavPath (${fileSize ~/ 1024}KB)');

      final waveData = sherpa.readWave(wavPath);
      const maxSamples = 16000 * _maxAudioSeconds;
      final samples = (!skipLengthCheck && waveData.samples.length > maxSamples)
          ? Float32List.fromList(waveData.samples.sublist(0, maxSamples))
          : waveData.samples;

      const chunkSeconds = 30;
      const chunkSamples = 16000 * chunkSeconds;

      if (samples.length <= chunkSamples) {
        final text = await transcribeSamples(samples);
        if (wavPath != audioPath) {
          try {
            File(wavPath).deleteSync();
          } catch (_) {}
        }
        final preview = text?.substring(0, text.length.clamp(0, 100));
        _logger.info('Transcription complete: $preview');
        return text;
      }

      final results = <String>[];
      for (var offset = 0; offset < samples.length; offset += chunkSamples) {
        final end = (offset + chunkSamples).clamp(0, samples.length);
        final chunk = Float32List.fromList(samples.sublist(offset, end));
        final text = await transcribeSamples(chunk);
        if (text != null && text.isNotEmpty) {
          results.add(text);
        }
      }

      if (wavPath != audioPath) {
        try {
          File(wavPath).deleteSync();
        } catch (_) {}
      }

      final fullText = results.join(' ').trim();
      _logger.info(
        'Transcription complete (${results.length} chunks): '
        '${fullText.substring(0, fullText.length.clamp(0, 100))}',
      );
      return fullText.isEmpty ? null : fullText;
    } catch (e) {
      _logger.severe('Transcription failed: $e');
      return null;
    }
  }

  void dispose() {
    _recognizer?.free();
    _recognizer = null;
    _bgIsolate?.dispose();
    _bgIsolate = null;
    _loadedModelId = null;
  }

  Future<String?> transcribeSamples(Float32List samples) async {
    try {
      if (!await isModelDownloaded()) return null;
      await _ensureBgIsolate();
      final text = await _bgIsolate!.transcribe(samples);
      if (text != null) {
        _logger.info(
          'Segment transcribed (bg): ${text.substring(0, text.length.clamp(0, 80))}',
        );
      }
      return text;
    } catch (e) {
      _logger.severe('Segment transcription failed: $e');
      return null;
    }
  }

  Future<void> _ensureBgIsolate() async {
    final profile = await getSelectedProfile();
    if (_bgIsolate != null &&
        _bgIsolate!.isReady &&
        _loadedModelId == profile.id) {
      return;
    }

    _recognizer?.free();
    _recognizer = null;
    _bgIsolate?.dispose();
    _bgIsolate = TranscriptionIsolate();
    final dir = await _modelDirFor(profile);
    await _bgIsolate!.start(
      profile: profile,
      modelDir: dir,
      provider: _provider,
    );
    _loadedModelId = profile.id;
  }

  void ensureInitialized() {
    sherpa.initBindings();
  }
}
