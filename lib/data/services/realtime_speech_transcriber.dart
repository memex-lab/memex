import 'dart:async';
import 'dart:typed_data';

import 'package:memex/data/services/streaming_transcriber.dart';

abstract class RealtimeSpeechTranscriber {
  Future<void> init();

  void addAudioChunk(Uint8List pcmBytes);

  Future<String?> finish();

  void dispose();
}

class LocalRealtimeSpeechTranscriber implements RealtimeSpeechTranscriber {
  LocalRealtimeSpeechTranscriber({required void Function(String) onTextChanged})
      : _delegate = StreamingTranscriber(onTextChanged: onTextChanged);

  final StreamingTranscriber _delegate;

  @override
  Future<void> init() => _delegate.init();

  @override
  void addAudioChunk(Uint8List pcmBytes) {
    _delegate.addAudioChunk(pcmBytes);
  }

  @override
  Future<String?> finish() async => null;

  @override
  void dispose() {
    _delegate.dispose();
  }
}
