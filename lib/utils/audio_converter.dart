import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';

/// Converts audio files to WAV 16kHz mono using platform native APIs.
/// iOS: AVAssetExportSession + AVAudioConverter
/// Android: MediaExtractor + MediaCodec
class AudioConverter {
  static const _channel = MethodChannel('com.memexlab.memex/audio_converter');
  static final Logger _logger = getLogger('AudioConverter');

  /// Convert any audio file to WAV 16kHz mono.
  /// Returns the path to the converted WAV file, or null on failure.
  static Future<String?> toWav16kMono(String inputPath) async {
    // If already a WAV file, check if it needs conversion
    if (inputPath.toLowerCase().endsWith('.wav')) {
      return inputPath; // Assume WAV files are already in correct format
    }

    try {
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${dir.path}/converted_$timestamp.wav';

      final result = await _channel.invokeMethod<String>('convertToWav', {
        'inputPath': inputPath,
        'outputPath': outputPath,
      });

      if (result != null && File(result).existsSync()) {
        _logger.info('Audio converted: $inputPath -> $result');
        return result;
      }
      _logger.warning('Audio conversion returned null');
      return null;
    } catch (e) {
      _logger.severe('Audio conversion failed: $e');
      return null;
    }
  }
}
