import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:memex/utils/logger.dart';
import 'package:memex/data/services/whisper_service.dart';

/// A segment of speech detected by VAD, with its quick-transcribed text.
class _Segment {
  final Float32List samples;
  final String text;
  _Segment(this.samples, this.text);
}

/// Real-time streaming transcriber using VAD + SenseVoice.
///
/// Uses a **confirmed / pending** model for safe text replacement:
///
/// ```
/// ┌─────────────────────┬──────────────────────┐
/// │   confirmed (固定)    │   pending (可被替换)   │
/// │  calibrated, frozen  │  quick-transcribed   │
/// └─────────────────────┴──────────────────────┘
///                        ↑ calibration replaces here
///                          new segments append here →
/// ```
///
/// - confirmed text is immutable — never changes once set.
/// - pending segments accumulate at the tail; calibration consumes them from
///   the head, combines their audio, re-transcribes, and appends the result
///   to confirmed.
/// - New segments arriving during async calibration are safe — they sit after
///   the calibration snapshot in the pending list.
///
/// Calibration triggers when:
///   1. Pending audio duration >= [_calibrateMinSeconds], AND
///   2. There are >= 2 pending segments (single-segment calibration adds no
///      cross-segment context, so it would produce the same result).
class StreamingTranscriber {
  final Logger _logger = getLogger('StreamingTranscriber');

  /// Called whenever the full display text changes (confirmed + pending).
  final void Function(String fullText) onTextChanged;

  sherpa.VoiceActivityDetector? _vad;
  bool _isRunning = false;
  final List<double> _sampleBuffer = [];
  static const int _vadWindowSize = 512;

  /// Calibrate when pending audio reaches this duration.
  /// 6s is enough context for SenseVoice to benefit from cross-segment
  /// combination, while keeping calibration fast (~0.3-0.8s on-device).
  /// With maxSpeechDuration=5s, this typically fires after 2 segments.
  static const double _calibrateMinSeconds = 6.0;

  String _confirmedText = '';
  final List<_Segment> _pendingSegments = [];
  bool _isCalibrating = false;

  double get _pendingDurationSec {
    if (_pendingSegments.isEmpty) return 0;
    final totalSamples =
        _pendingSegments.fold<int>(0, (sum, s) => sum + s.samples.length);
    return totalSamples / 16000;
  }

  StreamingTranscriber({required this.onTextChanged});

  // ─── Init ───────────────────────────────────────────────────────────

  Future<void> init() async {
    WhisperService.instance.ensureInitialized();

    final vadModelPath = await _extractVadModel();
    _logger.info('Initializing VAD with model: $vadModelPath');

    final vadConfig = sherpa.VadModelConfig(
      sileroVad: sherpa.SileroVadModelConfig(
        model: vadModelPath,
        // VAD tuning — prioritize responsiveness, let calibration fix accuracy:
        // maxSpeech  5s   — worst-case ~5.4s before text appears; keeps UI
        //                    responsive. Calibration combines short segments
        //                    later for accuracy.
        // minSilence 0.4s — triggers on natural inter-sentence pauses (~400ms)
        //                    without splitting on breaths (~200ms).
        // minSpeech  0.25s— allow short utterances; calibration corrects.
        // threshold  0.45 — slightly sensitive to avoid clipping speech onset.
        threshold: 0.45,
        minSilenceDuration: 0.4,
        minSpeechDuration: 0.25,
        windowSize: 512,
        maxSpeechDuration: 5.0,
      ),
      sampleRate: 16000,
      numThreads: 1,
      debug: false,
    );

    _vad = sherpa.VoiceActivityDetector(
      config: vadConfig,
      bufferSizeInSeconds: 30,
    );
    _isRunning = true;
    _confirmedText = '';
    _pendingSegments.clear();
    _logger.info('StreamingTranscriber initialized');
  }

  Future<String> _extractVadModel() async {
    final dir = await getApplicationSupportDirectory();
    final vadFile = File('${dir.path}/silero_vad.onnx');
    if (!vadFile.existsSync()) {
      final data = await rootBundle.load('assets/silero_vad.onnx');
      await vadFile.writeAsBytes(data.buffer.asUint8List());
    }
    return vadFile.path;
  }

  // ─── Display ────────────────────────────────────────────────────────

  String get _displayText {
    final pendingText = _pendingSegments.map((s) => s.text).join(' ');
    if (_confirmedText.isEmpty) return pendingText;
    if (pendingText.isEmpty) return _confirmedText;
    return '$_confirmedText $pendingText';
  }

  void _notifyTextChanged() {
    if (_isRunning) onTextChanged(_displayText);
  }

  // ─── Audio input ────────────────────────────────────────────────────

  /// Feed a PCM audio chunk (16-bit LE, 16kHz, mono).
  void addAudioChunk(Uint8List pcmBytes) {
    if (!_isRunning || _vad == null) return;

    final aligned = Uint8List.fromList(pcmBytes);
    final int16Data = Int16List.view(aligned.buffer);
    for (int i = 0; i < int16Data.length; i++) {
      _sampleBuffer.add(int16Data[i] / 32768.0);
    }

    while (_sampleBuffer.length >= _vadWindowSize) {
      final window = Float32List.fromList(
        _sampleBuffer.sublist(0, _vadWindowSize),
      );
      _sampleBuffer.removeRange(0, _vadWindowSize);
      _vad!.acceptWaveform(window);
    }

    // TranscriptionIsolate processes requests FIFO — segment order preserved.
    while (!_vad!.isEmpty()) {
      final segment = _vad!.front();
      _vad!.pop();
      _logger.info('VAD segment: ${segment.samples.length} samples '
          '(${(segment.samples.length / 16000 * 1000).round()}ms)');
      _transcribeSegment(segment.samples);
    }
  }

  // ─── Quick transcription ────────────────────────────────────────────

  Future<void> _transcribeSegment(Float32List samples) async {
    if (samples.isEmpty) return;

    final text = await WhisperService.instance.transcribeSamples(samples);
    if (text == null || text.isEmpty || !_isRunning) return;

    _pendingSegments.add(_Segment(samples, text));
    _notifyTextChanged();

    _maybeCalibrate();
  }

  // ─── Calibration ───────────────────────────────────────────────────

  void _maybeCalibrate() {
    if (_isCalibrating) return;
    // Need >= 2 segments: calibrating a single segment can't add cross-segment
    // context, so it would waste an inference pass for the same result.
    if (_pendingSegments.length < 2) return;
    if (_pendingDurationSec < _calibrateMinSeconds) return;
    _runCalibration();
  }

  Future<void> _runCalibration() async {
    if (_isCalibrating || _pendingSegments.isEmpty) return;
    _isCalibrating = true;

    // Snapshot the current pending list. New segments arriving during async
    // calibration will be appended AFTER these — safe to remove by count.
    final snapshot = List<_Segment>.from(_pendingSegments);
    final snapshotCount = snapshot.length;

    // Combine audio samples
    final totalSamples =
        snapshot.fold<int>(0, (sum, s) => sum + s.samples.length);
    final combined = Float32List(totalSamples);
    int offset = 0;
    for (final seg in snapshot) {
      combined.setAll(offset, seg.samples);
      offset += seg.samples.length;
    }

    _logger.info('Calibrating $snapshotCount segments '
        '(${(totalSamples / 16000).toStringAsFixed(1)}s audio)...');

    try {
      final calibrated =
          await WhisperService.instance.transcribeSamples(combined);

      if (calibrated != null && calibrated.isNotEmpty && _isRunning) {
        // Append calibrated text to confirmed (immutable after this)
        final sep = _confirmedText.isNotEmpty ? ' ' : '';
        _confirmedText = '$_confirmedText$sep$calibrated';

        // Remove the snapshot segments from the front of pending.
        // New segments that arrived during calibration stay untouched at tail.
        if (_pendingSegments.length >= snapshotCount) {
          _pendingSegments.removeRange(0, snapshotCount);
        } else {
          _pendingSegments.clear();
        }

        _notifyTextChanged();
        _logger.info(
            'Calibration done — confirmed: ${_confirmedText.length} chars, '
            'remaining pending: ${_pendingSegments.length} segments');
      }
    } catch (e) {
      _logger.severe('Calibration failed: $e');
    } finally {
      _isCalibrating = false;

      // Check if more segments accumulated during calibration
      _maybeCalibrate();
    }
  }

  // ─── Cleanup ────────────────────────────────────────────────────────

  /// Flush remaining VAD segments and stop.
  ///
  /// Remaining pending segments are kept as-is (quick-transcribed text).
  /// The caller is expected to run a final full-audio calibration
  /// ([WhisperService.transcribeSamples] on the complete PCM buffer) which
  /// replaces the entire text — so spending inference on leftover segments
  /// here would be wasted work.
  void dispose() {
    _isRunning = false;
    if (_vad != null) {
      _vad!.free();
      _vad = null;
    }
    _sampleBuffer.clear();
    _pendingSegments.clear();
    _confirmedText = '';
    _logger.info('StreamingTranscriber disposed');
  }
}
