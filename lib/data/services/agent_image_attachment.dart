import 'dart:convert';
import 'dart:io';

import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/image_exif_context.dart';
import 'package:memex/data/services/llm_image_codec.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as p;

final _logger = getLogger('AgentImageAttachment');

class AgentImageAttachment {
  const AgentImageAttachment({
    required this.relativePath,
    required this.fsFilename,
    required this.mimeType,
    required this.originalName,
    required this.exifInfo,
  });

  final String relativePath;

  /// Bare stored filename, used to build the `fs://<filename>` reference the
  /// agent sees (resolves to Facts/assets/<filename>, same as in-text fs:// refs).
  final String fsFilename;
  final String mimeType;
  final String? originalName;

  /// Pre-formatted EXIF metadata block (capture time, GPS coordinates, and
  /// reverse-geocoded address) for this image, or null when none is available.
  final String? exifInfo;

  String get fsUri => 'fs://$fsFilename';

  Map<String, dynamic> toTaskJson() => {
        'relative_path': relativePath,
        'fs_filename': fsFilename,
        'mime_type': mimeType,
        if (originalName != null) 'original_name': originalName,
        if (exifInfo != null) 'exif_info': exifInfo,
      };

  static AgentImageAttachment? fromTaskJson(Map<dynamic, dynamic> json) {
    final relativePath = json['relative_path']?.toString();
    final fsFilename = json['fs_filename']?.toString();
    final mimeType = json['mime_type']?.toString();
    if (relativePath == null ||
        relativePath.isEmpty ||
        fsFilename == null ||
        fsFilename.isEmpty ||
        mimeType == null ||
        mimeType.isEmpty) {
      return null;
    }
    return AgentImageAttachment(
      relativePath: relativePath,
      fsFilename: fsFilename,
      mimeType: mimeType,
      originalName: json['original_name']?.toString(),
      exifInfo: json['exif_info']?.toString(),
    );
  }
}

class InlineAgentImage {
  const InlineAgentImage({
    required this.base64Data,
    required this.mimeType,
  });

  final String base64Data;
  final String mimeType;
}

Future<AgentImageAttachment> prepareChatImageAttachment({
  required String userId,
  required String sourcePath,
  required String? originalName,
}) async {
  final fileService = FileSystemService.instance;
  final (fsFilename, relativePath) = await fileService.saveAssetFromFile(
    userId: userId,
    sourcePath: sourcePath,
    assetType: 'img',
  );
  final absolutePath = fileService.toAbsolutePath(relativePath);
  final originalMimeType = mimeTypeForImagePath(absolutePath);

  return prepareStoredImageAttachment(
    userId: userId,
    absolutePath: absolutePath,
    relativePath: relativePath,
    fsFilename: fsFilename,
    originalName: originalName,
    mimeType: originalMimeType,
  );
}

Future<AgentImageAttachment> prepareStoredImageAttachment({
  required String userId,
  required String absolutePath,
  required String relativePath,
  required String fsFilename,
  required String? originalName,
  required String mimeType,
}) async {
  // Read EXIF (capture time + GPS -> reverse-geocoded address) from the stored
  // original. Asset saving copies raw bytes, so EXIF survives; inline copies
  // intentionally strip it.
  final exifInfo = await buildImageExifInfo(userId, absolutePath);
  return AgentImageAttachment(
    relativePath: relativePath,
    fsFilename: fsFilename,
    mimeType: mimeType,
    originalName: originalName,
    exifInfo: exifInfo,
  );
}

Future<InlineAgentImage?> inlineImageForLlm({
  required String absolutePath,
  required String fallbackMimeType,
  String? logLabel,
}) async {
  final label = logLabel ?? absolutePath;
  final inlineLimit = const AssetSafetyConfig().maxFileBytesForInlineBase64;
  try {
    final safety = await AssetSafetyService.instance.inspectFile(absolutePath);
    if (!safety.safeForAnalysis) {
      _logger.warning(
        'Skipping inline image $label: ${safety.reason}',
      );
      return null;
    }

    final transcoded = await LlmImageCodec.transcodeForLlm(absolutePath);
    if (transcoded != null && transcoded.isNotEmpty) {
      if (transcoded.length > inlineLimit) {
        _logger.warning(
          'Skipping inline image $label: transcoded payload exceeds '
          '$inlineLimit bytes',
        );
        return null;
      }
      return InlineAgentImage(
        base64Data: base64Encode(transcoded),
        mimeType: LlmImageCodec.jpegMimeType,
      );
    }

    final originalBytes = await File(absolutePath).readAsBytes();
    if (!safety.safeForInlineBase64) {
      _logger.warning(
        'Transcode failed and original is not safe to inline, '
        'skipping inline for $label: ${safety.reason}',
      );
      return null;
    }
    if (!LlmImageCodec.isLlmSafeImageBytes(originalBytes)) {
      _logger.warning(
        'Transcode failed and original format is not LLM-safe, '
        'skipping inline for $label',
      );
      return null;
    }
    return InlineAgentImage(
      base64Data: base64Encode(originalBytes),
      mimeType: fallbackMimeType,
    );
  } catch (e) {
    _logger.warning('Failed to inline chat image $label: $e');
    return null;
  }
}

String buildAgentImageAttachmentReminder(
  int index,
  AgentImageAttachment image, {
  required bool imageLoaded,
}) {
  final buffer = StringBuffer()
    ..writeln('<system-reminder>')
    ..writeln('Attachment ${index + 1}: ${image.fsUri}');
  if (imageLoaded) {
    buffer.writeln(
      'The following image part is this attachment; do not call '
      'view_image for this fs:// id.',
    );
  } else {
    buffer.writeln(
      'This image attachment could not be loaded into this message. '
      'The saved asset reference still exists, but no image pixels are '
      'available here. Do not infer visual details from this attachment unless '
      'a later tool call successfully loads it.',
    );
  }
  if (image.originalName != null && image.originalName!.isNotEmpty) {
    buffer.writeln('original_name: ${image.originalName}');
  }
  buffer.writeln('mime_type: ${image.mimeType}');
  if (image.exifInfo != null && image.exifInfo!.isNotEmpty) {
    for (final line in image.exifInfo!.split('\n')) {
      buffer.writeln(line);
    }
  }
  buffer.writeln('</system-reminder>');
  return buffer.toString().trimRight();
}

String mimeTypeForImagePath(String filePath) {
  final ext = p.extension(filePath).toLowerCase();
  switch (ext) {
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.webp':
      return 'image/webp';
    case '.gif':
      return 'image/gif';
    case '.heic':
    case '.heif':
      return 'image/heic';
    case '.png':
    default:
      return 'image/png';
  }
}
