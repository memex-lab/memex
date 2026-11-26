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

    test('non-empty PCM always calls transcribe and returns its text',
        () async {
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
      expect(received, [closeTo(0.5, 0.0001), closeTo(-0.25, 0.0001)]);
      expect(result.text, 'cloud transcript');
      expect(result.error, isNull);
    });

    test('failed or empty final passes preserve every existing draft',
        () async {
      for (final text in ['', '  draft  ', '笔记 🎙️', 'line one\nline two']) {
        for (final outcome in ['empty', 'missing', 'failed']) {
          final failure = StateError('offline');
          var calls = 0;
          final result = await finalizeQuickRecordingTranscript(
            pcmBytes: _pcmForSamples([0.25, -0.25]),
            existingText: text,
            transcribeSamples: (_) async {
              calls++;
              if (outcome == 'failed') throw failure;
              return outcome == 'missing' ? null : '';
            },
          );
          expect(result.text, text, reason: outcome);
          expect(calls, 1, reason: outcome);
          expect(result.hasText, text.isNotEmpty);
          expect(result.error, outcome == 'failed' ? same(failure) : isNull);
          expect(result.hasError, outcome == 'failed');
        }
      }
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
