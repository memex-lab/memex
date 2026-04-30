import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as path;
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/utils/exif_utils.dart';
import 'package:memex/utils/image_utils.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/llm_call_record_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/agent/built_in_tools/asset_analysis_tool.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final Logger _logger = getLogger('AnalyzeAssetsHandler');

class AnalyzeAssetsPayload {
  final String factId;
  final List<String> assetPaths;

  AnalyzeAssetsPayload({required this.factId, required this.assetPaths});

  factory AnalyzeAssetsPayload.fromJson(Map<String, dynamic> json) {
    return AnalyzeAssetsPayload(
      factId: json['fact_id'] as String,
      assetPaths: (json['asset_paths'] as List).cast<String>(),
    );
  }
}

class ExifData {
  final DateTime? datetimeOriginal;
  final List<double>? gpsCoordinates;
  final String? address;

  ExifData({this.datetimeOriginal, this.gpsCoordinates, this.address});

  Map<String, dynamic> toJson() {
    return {
      'datetime_original': datetimeOriginal?.toIso8601String(),
      'gps_coordinates': gpsCoordinates,
      'address': address,
    };
  }
}

class AssetAnalysisResult {
  final String factId;
  final String name;
  final String path;
  final int index;
  final String analysis;
  final ExifData? exifData;

  AssetAnalysisResult({
    required this.factId,
    required this.name,
    required this.path,
    required this.index,
    required this.analysis,
    this.exifData,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'index': index,
      'analysis': analysis,
      'exif_data': exifData?.toJson(),
    };
  }
}

/// Handler for Analyze Assets
Future<void> handleAnalyzeAssetsImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext context,
) async {
  _logger.info(
    'Executing handleAnalyzeAssets for task ${context.taskId}, bizId: ${context.bizId}',
  );

  final data = AnalyzeAssetsPayload.fromJson(payload);

  if (data.assetPaths.isEmpty) {
    _logger.info('No assets to analyze for task ${context.taskId}, skipping.');
    await _updateTaskResult(userId, context.taskId, []);
    return;
  }

  final assetAnalyses = await analyzeAssetsForFact(
    userId: userId,
    factId: data.factId,
    assetPaths: data.assetPaths,
  );

  await _updateTaskResult(userId, context.taskId, assetAnalyses);
}

/// Analyze all assets for a fact and persist `{asset}.analysis.txt` files.
///
/// This is used both by the normal submit-input pipeline and by historical
/// reprocessing when old media descriptions need to be regenerated.
Future<List<AssetAnalysisResult>> analyzeAssetsForFact({
  required String userId,
  required String factId,
  required List<String> assetPaths,
}) async {
  if (assetPaths.isEmpty) {
    return const [];
  }

  final fileSystem = FileSystemService.instance;

  // Skip LLM analysis if not configured — card agent will use rule-based matching.
  final llmConfig = await UserStorage.getAgentLLMConfig(
    AgentDefinitions.analyzeAssets,
    defaultClientKey: LLMConfig.defaultClientKey,
  );
  if (!llmConfig.isValid) {
    _logger.info('No LLM configured — skipping asset analysis for $factId');
    return const [];
  }

  // 1. Get LLM Resources (Default to Gemini Flash for Asset Analysis)
  final resources = await UserStorage.getAgentLLMResources(
    AgentDefinitions.analyzeAssets,
    defaultClientKey: LLMConfig.defaultClientKey,
  );

  final futures = <Future<AssetAnalysisResult?>>[];

  for (var i = 0; i < assetPaths.length; i++) {
    futures.add(
      _analyzeSingleAsset(
        userId: userId,
        factId: factId,
        originalAssetPath: assetPaths[i],
        index: i,
        fileSystem: fileSystem,
        client: resources.client,
        modelConfig: resources.modelConfig,
      ),
    );
  }

  final results = await Future.wait(futures);
  final assetAnalyses = results.whereType<AssetAnalysisResult>().toList();

  // Sort by index to maintain order
  assetAnalyses.sort((a, b) => a.index.compareTo(b.index));

  return assetAnalyses;
}

Future<AssetAnalysisResult?> _analyzeSingleAsset({
  required String userId,
  required String factId,
  required String originalAssetPath,
  required int index,
  required FileSystemService fileSystem,
  required LLMClient client,
  required ModelConfig modelConfig,
}) async {
  var assetPath = originalAssetPath;
  try {
    // Convert relative path to absolute path (handles iOS Application ID change after app restart)
    assetPath = fileSystem.toAbsolutePath(assetPath);
    final file = File(assetPath);
    if (!file.existsSync()) {
      _logger.warning(
        'Asset not found: $assetPath (original: $originalAssetPath)',
      );
      return null;
    }
    final assetName = path.basename(assetPath);

    final extension = path.extension(assetPath).toLowerCase();
    // Only process supported extensions (Image & Audio)
    // Images: .jpg, .jpeg, .png, .tiff, .tif, .heic, .heif, .webp, .gif, .bmp
    // Audio: .mp3, .wav, .flac, .aac, .ogg, .aiff, .aif, .m4a, .wma
    const imageExtensions = {
      '.jpg',
      '.jpeg',
      '.png',
      '.tiff',
      '.tif',
      '.heic',
      '.heif',
      '.webp',
      '.gif',
      '.bmp',
    };
    const audioExtensions = {
      '.mp3',
      '.wav',
      '.flac',
      '.aac',
      '.ogg',
      '.aiff',
      '.aif',
      '.m4a',
      '.wma',
    };

    final isImage = imageExtensions.contains(extension);
    final isAudio = audioExtensions.contains(extension);

    if (!isImage && !isAudio) {
      _logger.warning('Skipping unsupported asset: $assetPath');
      return null;
    }

    // 1. Extract EXIF Data (Images only)
    Map<String, dynamic> exif = {};
    String exifInfoText = "";
    ExifData? structuredExifData;

    if (isImage) {
      try {
        exif = await ExifUtils.extractExifData(assetPath);
      } catch (e) {
        _logger.warning('Failed to extract EXIF data for $assetPath: $e');
      }

      // Get image dimensions
      final dimensions = await ImageUtils.getImageDimensions(assetPath);
      final width = dimensions['width'] as int;
      final height = dimensions['height'] as int;
      final aspectRatio = dimensions['aspectRatio'] as double;

      // Process EXIF Info
      final infoLines = <String>[];
      DateTime? datetimeOriginal;
      List<double>? gpsCoordinates;
      String? address;

      // Add image dimensions to EXIF info
      if (width > 0 && height > 0) {
        infoLines.add('${Prompts.imageDimensions}: $width x $height');
        infoLines.add(
          '${Prompts.aspectRatio}: ${aspectRatio.toStringAsFixed(2)}',
        );
      }

      if (exif.isNotEmpty) {
        // Handle Timestamp
        if (exif.containsKey('datetime_original_str')) {
          infoLines.add(
            '${Prompts.captureTime}: ${exif['datetime_original_str']}',
          );
        }
        if (exif.containsKey('datetime_original')) {
          datetimeOriginal = exif['datetime_original'] as DateTime?;
        }

        // Handle GPS & Address
        if (exif.containsKey('gps_coordinates')) {
          try {
            final coords = exif['gps_coordinates'] as List;
            final lat = coords[0] as double;
            final lng = coords[1] as double;
            gpsCoordinates = [lat, lng];

            infoLines.add(
              'Gps Coordinates: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
            );

            address = await ExifUtils.reverseGeocode(lat, lng);
            if (address != null) {
              var addressLine = 'Nearest Address (from GPS): $address';

              // Check nearest user location
              final markAddress = await fileSystem.getNearestUserLocation(
                userId,
                lat,
                lng,
              );
              if (markAddress != null) {
                addressLine +=
                    ', very close to user marked location ($markAddress) (less than 50 meters)';
              }

              infoLines.add(addressLine);
              exif['address'] = address;
            }
          } catch (e) {
            _logger.warning('Reverse geocode failed: $e');
          }
        }
      }

      if (infoLines.isNotEmpty) {
        exifInfoText = "${Prompts.imageMetadata}：\n${infoLines.join('\n')}";
      }

      structuredExifData = ExifData(
        datetimeOriginal: datetimeOriginal,
        gpsCoordinates: gpsCoordinates,
        address: address,
      );
    }

    // 2. Analyze content using AssetAnalysisTool (For both Image & Audio)
    String analysisResult = "";
    ModelUsage? toolUsage;
    String toolModel = 'unknown';
    try {
      final tool = AssetAnalysisTool(client: client, modelConfig: modelConfig);

      // Build prompt with metadata for images
      String finalPrompt = Prompts.assetAnalysisPrompt(
        UserStorage.l10n.assetAnalysisLanguageInstruction,
      );
      if (isImage && structuredExifData != null) {
        final metadataLines = <String>[];
        if (structuredExifData.datetimeOriginal != null) {
          metadataLines.add(
            "${Prompts.captureTime}: ${structuredExifData.datetimeOriginal!.toLocal().toString().substring(0, 19)}",
          );
        }
        if (structuredExifData.address != null) {
          metadataLines.add(
            "${Prompts.captureLocation}: ${structuredExifData.address}",
          );
        }
        if (structuredExifData.gpsCoordinates != null &&
            structuredExifData.gpsCoordinates!.length >= 2) {
          metadataLines.add(
            "${Prompts.gpsCoordinates}: ${Prompts.latitude} ${structuredExifData.gpsCoordinates![0].toStringAsFixed(6)}, ${Prompts.longitude} ${structuredExifData.gpsCoordinates![1].toStringAsFixed(6)}",
          );
        }
        if (metadataLines.isNotEmpty) {
          finalPrompt +=
              "\n\n${Prompts.imageMetadata}${Prompts.metadataNote}：\n${metadataLines.join('\n')}";
        }
      }

      final (result, usage, model) = await tool.toolWithUsage(
        assetPath: assetPath,
        prompt: finalPrompt,
      );
      final toolResult = result;
      toolUsage = usage;
      toolModel = model;

      // Parse result: "#Asset {name} analysis result\n: {result}"
      // Matches backend logic of extraction
      if (toolResult.contains('analysis result\n:')) {
        final parts = toolResult.split('analysis result\n:');
        if (parts.length > 1) {
          analysisResult = parts[1].trim();
        }
      } else {
        analysisResult = toolResult;
      }
      _logger.info(
        "Asset analyzed: ${path.basename(assetPath)}, result: $toolResult",
      );

      // Record LLM call if usage is available
      if (toolUsage != null) {
        await LLMCallRecordService.instance.recordCall(
          userId: userId,
          scene: 'input',
          sceneId: factId,
          agentName: 'asset_analysis',
          handlerName: 'analyze_assets_handler',
          usage: toolUsage,
          model: toolModel,
          client: client,
          metadata: {
            'asset_path': assetPath,
            'asset_index': index + 1,
            'asset_type': isImage ? 'image' : 'audio',
          },
        );
      }
    } catch (e) {
      _logger.severe('Tool analysis failed for $assetPath: $e');
      throw Exception('Tool analysis failed for $assetPath: $e');
    }

    // 3. Combine EXIF info and Tool Analysis (matching backend logic)
    // Final analysis result = EXIF info + Tool Analysis
    String finalAnalysisResult = "";
    if (exifInfoText.isNotEmpty) {
      finalAnalysisResult = "$exifInfoText\n\n";
    }
    if (analysisResult.isNotEmpty) {
      if (finalAnalysisResult.isNotEmpty) {
        finalAnalysisResult += analysisResult;
      } else {
        finalAnalysisResult = analysisResult;
      }
    }

    // 4. Save to file (using original filename + .analysis.txt suffix)
    if (finalAnalysisResult.isNotEmpty) {
      try {
        final assetFilename = path.basename(assetPath);
        final analysisFilename = "$assetFilename.analysis.txt";
        final analysisFile = File(
          path.join(path.dirname(assetPath), analysisFilename),
        );
        await analysisFile.writeAsString(finalAnalysisResult);
        _logger.info(
          "Saved asset analysis (with EXIF info) to: ${analysisFile.path}",
        );

        // Log event
        try {
          final workspacePath = fileSystem.getWorkspacePath(userId);
          final relativePath = fileSystem.toRelativePath(
            analysisFile.path,
            rootPath: workspacePath,
          );
          await fileSystem.eventLogService.logFileCreated(
            userId: userId,
            filePath: relativePath,
            description: 'System created asset analysis file',
            metadata: {'fact_id': factId, 'asset': assetFilename},
          );
        } catch (e) {
          // Event logging failure should not break analysis
        }
      } catch (e) {
        _logger.severe('Failed to save asset analysis for $assetPath: $e');
        throw Exception('Failed to save asset analysis for $assetPath: $e');
      }
    }

    // 4b. On-device OCR for images — persist as {filename}.ocr.txt
    if (isImage) {
      try {
        final ocrText = await _performOnDeviceOcr(assetPath);
        if (ocrText.isNotEmpty) {
          final assetFilename = path.basename(assetPath);
          final ocrFilename = '$assetFilename.ocr.txt';
          final ocrFile = File(
            path.join(path.dirname(assetPath), ocrFilename),
          );
          await ocrFile.writeAsString(ocrText);
          _logger.info('Saved OCR result to: ${ocrFile.path}');
        }
      } catch (e) {
        // OCR failure should not break the overall asset analysis
        _logger.warning('On-device OCR failed for $assetPath: $e');
      }
    }

    // 5. Add to results (analysis field should include EXIF + tool analysis, matching backend)
    return AssetAnalysisResult(
      factId: factId,
      name: assetName,
      path: assetPath,
      index: index + 1,
      analysis:
          finalAnalysisResult.isNotEmpty ? finalAnalysisResult : analysisResult,
      exifData: structuredExifData,
    );
  } catch (e, stack) {
    _logger.severe('Failed to analyze asset: $assetPath', e, stack);
    rethrowIfNonRetryable(e);
  }
}

/// Run on-device OCR (Google ML Kit) on an image file and return the
/// concatenated recognized text. Returns empty string on failure or if no
/// text is found.
Future<String> _performOnDeviceOcr(String imagePath) async {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
  try {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await textRecognizer.processImage(inputImage);
    if (recognizedText.blocks.isEmpty) return '';
    // Join all block texts with newlines, preserving reading order
    return recognizedText.blocks.map((b) => b.text).join('\n');
  } finally {
    textRecognizer.close();
  }
}

Future<void> _updateTaskResult(
  String userId,
  String taskId,
  List<AssetAnalysisResult> results,
) async {
  final resultData = {
    'asset_analyses': results.map((e) => e.toJson()).toList(),
  };
  await LocalTaskExecutor.instance.updateTaskResult(
    taskId,
    jsonEncode(resultData),
  );
}
