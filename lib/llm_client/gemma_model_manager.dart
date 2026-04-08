import 'dart:async';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Manages on-device Gemma model downloads and the LiteRT-LM engine lifecycle.
class GemmaModelManager {
  GemmaModelManager._();

  static final Logger _logger = Logger('GemmaModelManager');
  static const _channel = MethodChannel('com.memexlab.memex/litert_lm');
  static const _downloadChannel =
      EventChannel('com.memexlab.memex/litert_lm_download');

  static const _models = {
    'gemma-4-e2b': _GemmaModelInfo(
      filename: 'gemma-4-E2B-it.litertlm',
      url:
          'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm',
      sizeDescription: '~2.6 GB',
      expectedSizeBytes: 2580000000,
    ),
    'gemma-4-e4b': _GemmaModelInfo(
      filename: 'gemma-4-E4B-it.litertlm',
      url:
          'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm',
      sizeDescription: '~3.7 GB',
      expectedSizeBytes: 3650000000,
    ),
  };

  // Engine init state
  static String? _initializedModelId;
  static int? _initializedMaxTokens;
  static bool _initializedVision = false;
  static bool _initializedAudio = false;
  static Completer<void>? _initCompleter;

  static const int defaultMaxTokens = 10000;

  static Future<bool> isModelInstalled(String modelId) async {
    final info = _models[modelId];
    if (info == null) return false;
    try {
      return await _channel.invokeMethod<bool>(
            'isModelInstalled',
            {
              'filename': info.filename,
              'expectedSize': info.expectedSizeBytes,
            },
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static String? getModelSize(String modelId) =>
      _models[modelId]?.sizeDescription;

  static bool isKnownModel(String modelId) => _models.containsKey(modelId);

  static Future<String> getModelPath(String modelId) async {
    final info = _models[modelId]!;
    final storageDir =
        await _channel.invokeMethod<String>('getModelStorageDir');
    return '$storageDir/${info.filename}';
  }

  static Future<void> downloadModel(
    String modelId, {
    void Function(int progress)? onProgress,
  }) async {
    final info = _models[modelId];
    if (info == null) throw Exception('Unknown Gemma model: $modelId');

    final modelPath = await getModelPath(modelId);
    final completer = Completer<void>();

    final sub = _downloadChannel.receiveBroadcastStream({
      'url': info.url,
      'destPath': modelPath,
    }).listen(
      (event) {
        if (event is! Map) return;
        final progress = event['progress'] as int? ?? 0;
        onProgress?.call(progress);
        if (event['done'] == true && !completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (Object e) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Download failed: $e'));
        }
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      await completer.future;
    } finally {
      await sub.cancel();
    }
  }

  /// Initialize the native LiteRT-LM Engine.
  ///
  /// Backends are enabled strictly on demand: vision and audio are only
  /// activated when the current request actually contains image/audio content.
  /// If the running engine's config doesn't match exactly, it is fully torn
  /// down before a new one is created — ensuring no stale backend resources
  /// linger between requests.
  static Future<void> ensureEngineReady(
    String modelId, {
    bool useGpu = true,
    int? maxTokens,
    bool enableVision = false,
    bool enableAudio = false,
  }) async {
    final effectiveMaxTokens = maxTokens ?? defaultMaxTokens;

    // Exact match: reuse the running engine as-is.
    if (_initializedModelId == modelId &&
        _initializedMaxTokens == effectiveMaxTokens &&
        _initializedVision == enableVision &&
        _initializedAudio == enableAudio) {
      return;
    }

    if (_initializedModelId != null) {
      _logger.info('Engine config changed, reinitializing '
          '(vision: $_initializedVision→$enableVision, '
          'audio: $_initializedAudio→$enableAudio, '
          'maxTokens: $_initializedMaxTokens→$effectiveMaxTokens)');
      await closeEngine();
    }

    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();
    try {
      final modelPath = await getModelPath(modelId);
      _logger.info('Initializing LiteRT-LM Engine: $modelPath, '
          'maxTokens=$effectiveMaxTokens, vision=$enableVision, audio=$enableAudio');
      await _channel.invokeMethod('initEngine', {
        'modelPath': modelPath,
        'useGpu': useGpu,
        'maxTokens': effectiveMaxTokens,
        'enableVision': enableVision,
        'enableAudio': enableAudio,
      });
      _initializedModelId = modelId;
      _initializedMaxTokens = effectiveMaxTokens;
      _initializedVision = enableVision;
      _initializedAudio = enableAudio;
      _logger.info('LiteRT-LM Engine ready');
      _initCompleter!.complete();
    } catch (e, st) {
      _logger.severe('Engine init failed', e, st);
      _initCompleter!.completeError(e, st);
      rethrow;
    } finally {
      _initCompleter = null;
    }
  }

  static Future<void> closeEngine() async {
    try {
      await _channel.invokeMethod('closeEngine');
    } catch (_) {}
    _initializedModelId = null;
    _initializedMaxTokens = null;
    _initializedVision = false;
    _initializedAudio = false;
  }
}

class _GemmaModelInfo {
  final String filename;
  final String url;
  final String sizeDescription;
  final int expectedSizeBytes;

  const _GemmaModelInfo({
    required this.filename,
    required this.url,
    required this.sizeDescription,
    required this.expectedSizeBytes,
  });
}
