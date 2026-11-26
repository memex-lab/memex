import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:memex/domain/models/local_speech.dart';
import 'package:memex/domain/models/vocal_tone.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Runs transcription in a background Isolate so the UI thread is never blocked.
///
/// Messages use only primitive types (Map/List/String/int/Float32List)
/// to ensure compatibility with AOT (release) builds.
class TranscriptionIsolate {
  static final _logger = Logger('TranscriptionIsolate');

  Completer<void>? _ready;
  SendPort? _sendPort;
  ReceivePort? _mainReceivePort;
  int _nextId = 0;
  final _pending = <int, Completer<LocalRecognition?>>{};

  bool get isReady => _sendPort != null;

  /// Start the background isolate and initialize the recognizer.
  Future<void> start({
    required String modelPath,
    required String tokensPath,
    String provider = 'cpu',
    String engine = LocalSpeechEngines.senseVoice,
    String language = 'auto',
    String? decoderPath,
  }) async {
    final existing = _ready;
    if (existing != null) return existing.future;

    final receivePort = ReceivePort();
    final ready = Completer<void>();
    _ready = ready;
    _mainReceivePort = receivePort;
    receivePort.listen((message) {
      if (_mainReceivePort != receivePort) {
        // Disposed before the handshake. Let the worker free its recognizer.
        if (message is SendPort) message.send({'shutdown': true});
        receivePort.close();
        return;
      }
      if (message is SendPort) {
        _sendPort = message;
        ready.complete();
      } else if (message is Map) {
        final id = message['id'] as int;
        _pending.remove(id)?.complete(
              LocalRecognition(
                text: message['text'] as String?,
                emotion: message['emotion'] as String? ?? '',
                event: message['event'] as String? ?? '',
                lang: message['lang'] as String? ?? '',
              ),
            );
      } else {
        // Isolate.spawn sends a list for an uncaught error and null on exit.
        if (!ready.isCompleted) {
          ready.completeError(
              StateError('Transcription worker stopped: $message'));
        }
        dispose();
        receivePort.close();
      }
    });

    unawaited(Isolate.spawn(
      _isolateEntry,
      {
        'modelPath': modelPath,
        'tokensPath': tokensPath,
        'provider': provider,
        'engine': engine,
        'language': language,
        'decoderPath': decoderPath,
        'replyPort': receivePort.sendPort,
      },
      onError: receivePort.sendPort,
      onExit: receivePort.sendPort,
    ).then<void>((_) {}, onError: (Object error, StackTrace stack) {
      receivePort.close();
      if (_mainReceivePort == receivePort) {
        ready.completeError(error, stack);
        dispose();
      }
    }));

    await ready.future;
    _logger.info('Transcription isolate started');
  }

  /// Transcribe samples in the background isolate. Non-blocking.
  Future<String?> transcribe(Float32List samples) async {
    final recognition = await transcribeDetailed(samples);
    return recognition?.text;
  }

  /// Transcript plus SenseVoice emotion and event tags, when the model has them.
  Future<LocalRecognition?> transcribeDetailed(Float32List samples) async {
    if (_sendPort == null) return null;
    final id = _nextId++;
    final completer = Completer<LocalRecognition?>();
    _pending[id] = completer;
    _sendPort!.send({'id': id, 'samples': samples});
    return completer.future;
  }

  /// Gracefully stop the isolate, allowing it to free native resources.
  void dispose() {
    final ready = _ready;
    if (ready != null && !ready.isCompleted) {
      ready.completeError(StateError('Transcription startup cancelled'));
      // Keep listening for the worker's port so we can send shutdown.
    } else {
      _sendPort?.send({'shutdown': true});
      _mainReceivePort?.close();
    }
    _ready = null;
    _mainReceivePort = null;
    _sendPort = null;

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
    final engine =
        initConfig['engine'] as String? ?? LocalSpeechEngines.senseVoice;
    final language = initConfig['language'] as String? ?? 'auto';
    final decoderPath = initConfig['decoderPath'] as String?;
    final replyPort = initConfig['replyPort'] as SendPort;

    // Initialize sherpa-onnx in this isolate
    sherpa.initBindings();

    final model = engine == LocalSpeechEngines.whisperTiny
        ? sherpa.OfflineModelConfig(
            whisper: sherpa.OfflineWhisperModelConfig(
              encoder: modelPath,
              decoder: decoderPath ?? '',
              language: language,
              task: 'transcribe',
            ),
            tokens: tokensPath,
            numThreads: 2,
            debug: false,
            provider: provider,
            modelType: 'whisper',
          )
        : sherpa.OfflineModelConfig(
            senseVoice: sherpa.OfflineSenseVoiceModelConfig(
              model: modelPath,
              language: language,
              useInverseTextNormalization: true,
            ),
            tokens: tokensPath,
            numThreads: 2,
            debug: false,
            provider: provider,
          );
    final config = sherpa.OfflineRecognizerConfig(model: model);

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
          final result = recognizer.getResult(stream);
          final text = result.text.trim();
          replyPort.send({
            'id': id,
            'text': text.isEmpty ? null : text,
            'emotion': result.emotion,
            'event': result.event,
            'lang': result.lang,
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
