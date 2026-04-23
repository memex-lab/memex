import 'dart:io';
import 'dart:convert';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:memex/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:memex/data/services/speech_transcription_service.dart';

class AssetAnalysisTool {
  final Logger _logger = getLogger('AssetAnalysisTool');
  final LLMClient client;
  final ModelConfig modelConfig;

  AssetAnalysisTool({
    required this.client,
    required this.modelConfig,
  });

  /// The main tool method to analyze assets
  Future<String> tool({
    required String assetPath,
    required String prompt,
  }) async {
    final (result, _, _) = await toolWithUsage(
      assetPath: assetPath,
      prompt: prompt,
    );
    return result;
  }

  /// Analyze assets and return result with usage information
  Future<(String result, ModelUsage? usage, String model)> toolWithUsage({
    required String assetPath,
    required String prompt,
  }) async {
    final file = File(assetPath);
    if (!file.existsSync()) {
      _logger.warning("Asset file not found: $assetPath");
      throw Exception("Asset file not found: $assetPath");
    }

    final extension = path.extension(assetPath).toLowerCase();
    final assetName = path.basename(assetPath);

    // Image Extensions
    if ({'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.heic', '.heif'}
        .contains(extension)) {
      return _analyzeImageWithUsage(assetPath, assetName, prompt);
    }
    // Audio Extensions
    else if ({
      '.mp3',
      '.wav',
      '.flac',
      '.aac',
      '.ogg',
      '.aiff',
      '.aif',
      '.m4a',
      '.wma'
    }.contains(extension)) {
      return _analyzeAudioWithUsage(assetPath, assetName, prompt);
    }
    // TODO: Document support (PDF, Excel, PPT, Word, CSV) via MarkItDown or similar
    else {
      throw Exception("Unsupported file type: $extension for file $assetPath");
    }
  }

  Future<(String result, ModelUsage? usage, String model)>
      _analyzeImageWithUsage(
          String assetPath, String assetName, String prompt) async {
    _logger.info('Starting analysis flow for: $assetPath');

    try {
      final file = File(assetPath);
      if (!await file.exists()) {
        throw Exception("File not found: $assetPath");
      }

      // --- Step 1: compress and resize image ---
      // Target: convert to WebP, max side 2048, quality 85%
      final compressedBytes = await _compressAndResizeImage(file.path,
          targetSize: 2048, quality: 85);

      if (compressedBytes == null) {
        throw Exception("Image compression failed");
      }

      _logger.info("Original size: ${(await file.length()) / 1024} KB, "
          "Compressed size: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB");

      // --- Step 2: Base64 encode ---
      // Encoding on a background isolate is still good practice even with smaller bytes
      final base64Image = await compute(base64Encode, compressedBytes);

      // --- Step 3: prepare prompt ---
      // Note: MimeType is fixed as image/webp since we converted to WebP
      const mimeType = 'image/webp';

      final fullPrompt = """
  ## Requirements:
  $prompt

  Note: Do not exceed 500 words.
  """;

      _logger.info("Calling API...");
      final response = await client.generate(
        [
          SystemMessage("You are an image analysis expert."),
          UserMessage([
            TextPart(fullPrompt),
            ImagePart(base64Image, mimeType),
          ])
        ],
        modelConfig: modelConfig,
      );

      final analysisResult = response.textOutput ?? "";

      return (
        '#Asset $assetName analysis result\n: $analysisResult',
        response.usage,
        response.model,
      );
    } catch (e) {
      _logger.severe('Failed to analyze image $assetPath: $e');
      rethrow;
    }
  }

  Future<Uint8List?> _compressAndResizeImage(String path,
      {int targetSize = 2048, int quality = 85}) async {
    try {
      // compressWithFile reads path and returns Uint8List (bytes in memory),
      // no temp files, very efficient.
      final result = await FlutterImageCompress.compressWithFile(
        path,
        minWidth: targetSize, // limit width
        minHeight: targetSize, // limit height
        quality:
            quality, // 0-100, 85 is usually a good balance for visually lossless
        format: CompressFormat.webp, // output as WebP

        // Key: keep aspect ratio, auto-rotate (handles phone photo orientation)
        autoCorrectionAngle: true,
        keepExif:
            false, // AI analysis usually doesn't need Exif (GPS etc.), omitting reduces size
      );

      return result;
    } catch (e) {
      // Fallback: on rare compression failure we could return original bytes,
      // but original may not be WebP and caller would need to handle that.
      // Here we simply throw or log.
      _logger.severe('Failed to compress image $path: $e');
      return null;
    }
  }

  Future<(String result, ModelUsage? usage, String model)>
      _analyzeAudioWithUsage(
          String assetPath, String assetName, String prompt) async {
    _logger.info('Analyzing audio: $assetPath');

    try {
      final result = await SpeechTranscriptionService.instance
          .transcribeFileWithMetadata(assetPath);
      final transcript = result.text;
      if (transcript != null && transcript.trim().isNotEmpty) {
        _logger.info(
            'Audio transcribed via ${result.model}: ${transcript.substring(0, transcript.length.clamp(0, 100))}...');
        return (
          '#Asset $assetName analysis result\n: $transcript',
          result.usage,
          result.model,
        );
      }

      return (
        '#Asset $assetName analysis result\n: ',
        result.usage,
        result.model,
      );
    } catch (e) {
      _logger.severe('Failed to analyze audio $assetPath: $e');
      rethrow;
    }
  }
}
