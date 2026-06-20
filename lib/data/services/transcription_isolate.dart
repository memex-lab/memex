import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:memex/data/services/local_speech_recognizer_config.dart';
import 'package:memex/domain/models/local_speech_model.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Runs transcription in a background Isolate so the UI thread is never blocked.
class TranscriptionIsolate {
  static final _logger = Logger('TranscriptionIsolate');

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _mainReceivePort;
  int _nextId = 0;
  final _pending = <int, Completer<String?>>{};

  bool get isReady => _sendPort != null;

  Future<void> start({
    required LocalSpeechModelProfile profile,
    required String modelDir,
    String provider = 'cpu',
  }) async {
    if (_isolate != null) return;

    final receivePort = ReceivePort();
    _mainReceivePort = receivePort;

    _isolate = await Isolate.spawn(
      _isolateEntry,
      {
        'profileId': profile.storageValue,
        'modelDir': modelDir,
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
    _logger.info('Transcription isolate started (${profile.storageValue})');
  }

  Future<String?> transcribe(Float32List samples) async {
    if (_sendPort == null) return null;
    final id = _nextId++;
    final completer = Completer<String?>();
    _pending[id] = completer;
    _sendPort!.send({'id': id, 'samples': samples});
    return completer.future;
  }

  void dispose() {
    _sendPort?.send({'shutdown': true});
    _sendPort = null;
    _mainReceivePort?.close();
    _mainReceivePort = null;
    _isolate = null;

    for (final c in _pending.values) {
      c.complete(null);
    }
    _pending.clear();
  }

  static void _isolateEntry(Map<String, dynamic> initConfig) {
    final profileId = initConfig['profileId'] as String;
    final modelDir = initConfig['modelDir'] as String;
    final provider = initConfig['provider'] as String;
    final replyPort = initConfig['replyPort'] as SendPort;

    sherpa.initBindings();

    final profile = LocalSpeechModelProfile.fromId(
      LocalSpeechModelProfile.fromStorageValue(profileId),
    );
    final config = LocalSpeechRecognizerConfig.build(
      profile: profile,
      modelDir: modelDir,
      provider: provider,
    );
    final recognizer = sherpa.OfflineRecognizer(config);

    final receivePort = ReceivePort();
    replyPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is Map) {
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
