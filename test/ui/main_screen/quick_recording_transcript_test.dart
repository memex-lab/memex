import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/main_screen/quick_recording_transcript.dart';

void main() {
  group('finalizeQuickRecordingTranscript', () {
    test('empty PCM does not transcribe and keeps existing text', () async {
      var called = false;
      final result = await finalizeQuickRecordingTranscript(
        pcmBytes: const [],
        existingText: 'streaming',
        transcribeSamples: (_) async {
          called = true;
          return 'should-not-run';
        },
      );

      expect(called, isFalse);
      expect(result.text, 'streaming');
      expect(result.error, isNull);
    });

    test('non-empty PCM always calls transcribe and returns its text', () async {
      Float32List? received;
      final result = await finalizeQuickRecordingTranscript(
        pcmBytes: _pcmForSamples(const [0.5, -0.25]),
        existingText: 'streaming',
        transcribeSamples: (samples) async {
          received = samples;
          return 'cloud transcript';
        },
      );

      expect(received, isNotNull);
      expect(received!.length, 2);
      expect(result.text, 'cloud transcript');
      expect(result.error, isNull);
    });

    test('empty transcript keeps existing text for the caller toast path',
        () async {
      var called = false;
      final result = await finalizeQuickRecordingTranscript(
        pcmBytes: _pcmForSamples(const [0.1]),
        existingText: '',
        transcribeSamples: (_) async {
          called = true;
          return '';
        },
      );

      expect(called, isTrue);
      expect(result.text, isEmpty);
      expect(result.hasText, isFalse);
      expect(result.error, isNull);
    });

    test('empty transcript does not wipe non-empty streaming text', () async {
      final result = await finalizeQuickRecordingTranscript(
        pcmBytes: _pcmForSamples(const [0.1]),
        existingText: 'partial',
        transcribeSamples: (_) async => null,
      );

      expect(result.text, 'partial');
      expect(result.error, isNull);
    });

    test('transcribe failure preserves text and surfaces error', () async {
      final boom = Exception('network down');
      final result = await finalizeQuickRecordingTranscript(
        pcmBytes: _pcmForSamples(const [0.2]),
        existingText: '',
        transcribeSamples: (_) async => throw boom,
      );

      expect(result.text, isEmpty);
      expect(result.error, same(boom));
      expect(result.hasError, isTrue);
    });
  });
}

List<int> _pcmForSamples(List<double> samples) {
  final pcm = ByteData(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    final scaled = (samples[i] * 32767).round().clamp(-32768, 32767);
    pcm.setInt16(i * 2, scaled, Endian.little);
  }
  return pcm.buffer.asUint8List();
}
