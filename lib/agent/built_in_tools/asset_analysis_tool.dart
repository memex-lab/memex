import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:memex/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:memex/llm_client/gemma_model_manager.dart';

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
      // Gemma 4 (LiteRT-LM) only supports JPEG/PNG; other models accept WebP.
      // LiteRT-LM crashes when image produces too many patches (limit: 2520).
      // 2400x1080 → 2475 patches is dangerously close. Use 896px for Gemma 4.
      final isGemma4 = GemmaModelManager.isKnownModel(modelConfig.model);
      final compressFormat =
          isGemma4 ? CompressFormat.jpeg : CompressFormat.webp;
      final mimeType = isGemma4 ? 'image/jpeg' : 'image/webp';
      final targetSize = isGemma4 ? 896 : 2048;

      final compressedBytes = await _compressAndResizeImage(file.path,
          targetSize: targetSize,
          quality: 85,
          format: compressFormat,
          enforceMaxSide: isGemma4);

      if (compressedBytes == null) {
        throw Exception("Image compression failed");
      }

      _logger.info("Original size: ${(await file.length()) / 1024} KB, "
          "Compressed size: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB");

      // --- Step 2: Base64 encode ---
      final base64Image = await compute(base64Encode, compressedBytes);

      // --- Step 3: prepare prompt ---

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
      {int targetSize = 2048,
      int quality = 85,
      CompressFormat format = CompressFormat.webp,
      bool enforceMaxSide = false}) async {
    try {
      int outW = targetSize;
      int outH = targetSize;

      if (enforceMaxSide) {
        // For Gemma 4: enforce maximum side to avoid patch count overflow in LiteRT-LM.
        // flutter_image_compress minWidth/minHeight is a minimum constraint, not maximum,
        // so we calculate exact output dimensions first.
        final originalBytes = await File(path).readAsBytes();
        final codec = await ui.instantiateImageCodec(originalBytes);
        final frame = await codec.getNextFrame();
        final origW = frame.image.width;
        final origH = frame.image.height;
        frame.image.dispose();

        if (origW > targetSize || origH > targetSize) {
          if (origW >= origH) {
            outW = targetSize;
            outH = (origH * targetSize / origW).round();
          } else {
            outH = targetSize;
            outW = (origW * targetSize / origH).round();
          }
        } else {
          outW = origW;
          outH = origH;
        }
      }

      final result = await FlutterImageCompress.compressWithFile(
        path,
        minWidth: outW,
        minHeight: outH,
        quality: quality,
        format: format,
        autoCorrectionAngle: true,
        keepExif: false,
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
      final file = File(assetPath);

      // For Gemma 4 (LiteRT-LM), Kotlin side handles M4A→WAV conversion.
      // For other models, base64 encode with appropriate mimeType.
      final isGemma4 = GemmaModelManager.isKnownModel(modelConfig.model);

      const transcriptPrompt = "Generate a transcript of the speech.";

      List<UserContentPart> parts;
      if (isGemma4) {
        final bytes = await file.readAsBytes();
        final base64Audio = base64Encode(bytes);
        // Pass raw bytes — Kotlin converts to PCM WAV before sending to LiteRT-LM
        parts = [
          TextPart(transcriptPrompt),
          AudioPart(base64Audio, 'audio/m4a')
        ];
      } else {
        final bytes = await file.readAsBytes();
        String mimeType = 'audio/mp3';
        final ext = path.extension(assetPath).toLowerCase();
        switch (ext) {
          case '.wav':
            mimeType = 'audio/wav';
          case '.mp3':
          case '.m4a':
            mimeType = 'audio/mp3';
          case '.aiff':
          case '.aif':
            mimeType = 'audio/aiff';
          case '.aac':
            mimeType = 'audio/aac';
          case '.ogg':
            mimeType = 'audio/ogg';
          case '.flac':
            mimeType = 'audio/flac';
          case '.wma':
            throw Exception("Audio format $ext (WMA) is not supported.");
        }
        parts = [
          TextPart(transcriptPrompt),
          AudioPart(base64Encode(bytes), mimeType)
        ];
      }

      _logger.info("Calling API for audio transcription...");
      final response = await client.generate(
        [UserMessage(parts)],
        modelConfig: modelConfig,
      );

      final analysisResult = response.textOutput ?? "";
      _logger.info("Audio analysis completed. Result : $analysisResult");
      return (
        '#Asset $assetName analysis result\n: $analysisResult',
        response.usage,
        response.model,
      );
    } catch (e) {
      _logger.severe('Failed to analyze audio $assetPath: $e');
      rethrow;
    }
  }
}
