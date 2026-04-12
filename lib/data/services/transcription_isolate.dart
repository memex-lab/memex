import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Runs transcription in a background Isolate so the UI thread is never blocked.
///
/// Messages use only primitive types (Map/List/String/int/Float32List)
/// to ensure compatibility with AOT (release) builds.
class TranscriptionIsolate {
  static final _logger = Logger('TranscriptionIsolate');

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _mainReceivePort;
  int _nextId = 0;
  final _pending = <int, Completer<String?>>{};

  bool get isReady => _sendPort != null;

  /// Start the background isolate and initialize the recognizer.
  Future<void> start({
    required String modelPath,
    required String tokensPath,
    String provider = 'cpu',
  }) async {
    if (_isolate != null) return;

    final receivePort = ReceivePort();
    _mainReceivePort = receivePort;

    // Pass init config as a simple Map
    _isolate = await Isolate.spawn(
      _isolateEntry,
      {
        'modelPath': modelPath,
        'tokensPath': tokensPath,
        'provider': provider,
        'replyPort': receivePort.sendPort,
      },
    );

    final completer = Completer<void>();

    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        completer.complete();
      } else if (message is Map) {
        final id = message['id'] as int;
        final text = message['text'] as String?;
        _pending.remove(id)?.complete(text);
      }
    });

    await completer.future;
    _logger.info('Transcription isolate started');
  }

  /// Transcribe samples in the background isolate. Non-blocking.
  Future<String?> transcribe(Float32List samples) async {
    if (_sendPort == null) return null;
    final id = _nextId++;
    final completer = Completer<String?>();
    _pending[id] = completer;
    // Send as a simple Map with primitive types
    _sendPort!.send({'id': id, 'samples': samples});
    return completer.future;
  }

  /// Gracefully stop the isolate, allowing it to free native resources.
  void dispose() {
    // Send shutdown signal so the isolate can free the recognizer
    // before exiting — Isolate.kill would skip native cleanup.
    _sendPort?.send({'shutdown': true});
    _sendPort = null;

    // Close our receive port; the isolate will exit once its receivePort
    // is closed (no more listeners keeping it alive).
    _mainReceivePort?.close();
    _mainReceivePort = null;

    // Don't kill — let the isolate exit naturally after cleanup.
    // It will terminate when its event loop is empty.
    _isolate = null;

    for (final c in _pending.values) {
      c.complete(null);
    }
    _pending.clear();
  }

  /// Entry point for the background isolate.
  static void _isolateEntry(Map<String, dynamic> initConfig) {
    final modelPath = initConfig['modelPath'] as String;
    final tokensPath = initConfig['tokensPath'] as String;
    final provider = initConfig['provider'] as String;
    final replyPort = initConfig['replyPort'] as SendPort;

    // Initialize sherpa-onnx in this isolate
    sherpa.initBindings();

    final config = sherpa.OfflineRecognizerConfig(
      model: sherpa.OfflineModelConfig(
        senseVoice: sherpa.OfflineSenseVoiceModelConfig(
          model: modelPath,
          language: 'auto',
          useInverseTextNormalization: true,
        ),
        tokens: tokensPath,
        numThreads: 2,
        debug: false,
        provider: provider,
      ),
    );

    final recognizer = sherpa.OfflineRecognizer(config);

    // Send our receive port back to the main isolate
    final receivePort = ReceivePort();
    replyPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is Map) {
        // Shutdown signal: free native resources and exit
        if (message.containsKey('shutdown')) {
          recognizer.free();
          receivePort.close();
          return;
        }

        final id = message['id'] as int;
        final samples = message['samples'] as Float32List;
        final stream = recognizer.createStream();
        try {
          stream.acceptWaveform(samples: samples, sampleRate: 16000);
          recognizer.decode(stream);
          final text = recognizer.getResult(stream).text.trim();
          replyPort.send({
            'id': id,
            'text': text.isEmpty ? null : text,
          });
        } catch (e) {
          replyPort.send({'id': id, 'text': null});
        } finally {
          stream.free();
        }
      }
    });
  }
}
