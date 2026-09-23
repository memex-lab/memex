import 'dart:typed_data';

/// Outcome of the final PCM pass after a quick-recording long-press.
class QuickRecordingFinalizeResult {
  const QuickRecordingFinalizeResult({
    required this.text,
    this.error,
  });

  /// Transcript to use after finalization (may be prior streaming text).
  final String text;

  /// Set when [transcribeSamples] throws (e.g. network / provider failure).
  final Object? error;

  bool get hasText => text.isNotEmpty;
  bool get hasError => error != null;
}

/// Finalize quick-recording PCM into text via [transcribeSamples].
///
/// - Empty PCM never calls [transcribeSamples] and keeps [existingText].
/// - Non-empty PCM always calls [transcribeSamples].
/// - Non-empty transcripts replace [existingText]; empty transcripts do not
///   wipe streaming text that was already recognized.
/// - Transcription failures preserve [existingText] and surface [error].
Future<QuickRecordingFinalizeResult> finalizeQuickRecordingTranscript({
  required List<int> pcmBytes,
  required String existingText,
  required Future<String?> Function(Float32List samples) transcribeSamples,
}) async {
  if (pcmBytes.isEmpty) {
    return QuickRecordingFinalizeResult(text: existingText);
  }

  final aligned = Uint8List.fromList(pcmBytes);
  final int16Data = Int16List.view(aligned.buffer);
  final samples = Float32List(int16Data.length);
  for (var i = 0; i < int16Data.length; i++) {
    samples[i] = int16Data[i] / 32768.0;
  }

  try {
    final transcript = await transcribeSamples(samples);
    if (transcript != null && transcript.isNotEmpty) {
      return QuickRecordingFinalizeResult(text: transcript);
    }
    return QuickRecordingFinalizeResult(text: existingText);
  } catch (error) {
    return QuickRecordingFinalizeResult(text: existingText, error: error);
  }
}
