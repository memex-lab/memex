import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

typedef TempDirectoryProvider = Future<Directory> Function();
typedef NetworkImageFetcher = Future<http.Response> Function(Uri uri);

typedef ImageFileCompressor = Future<String?> Function({
  required String sourcePath,
  required String targetPath,
  required int maxWidth,
  required int maxHeight,
  required int quality,
});

class ImagePreviewUnavailable implements Exception {
  final String reason;

  const ImagePreviewUnavailable(this.reason);

  @override
  String toString() => reason;
}

class ImagePreviewFile {
  final File file;
  final String contentType;
  final bool cacheHit;

  const ImagePreviewFile({
    required this.file,
    required this.contentType,
    required this.cacheHit,
  });
}

class ImagePreviewCacheService {
  ImagePreviewCacheService({
    TempDirectoryProvider? tempDirectoryProvider,
    ImageFileCompressor? compressor,
    NetworkImageFetcher? networkImageFetcher,
  })  : _tempDirectoryProvider = tempDirectoryProvider ?? getTemporaryDirectory,
        _compressor = compressor ?? _defaultCompressor,
        _networkImageFetcher = networkImageFetcher ?? http.get;

  static final ImagePreviewCacheService instance = ImagePreviewCacheService();

  static const int maxPreviewSide = 768;
  static const int previewQuality = 80;
  static const String cacheDirectoryName = 'image_cache';
  static const String cacheFileSuffix = '_max768.jpg';
  static const AssetSafetyConfig previewSourceSafetyConfig = AssetSafetyConfig(
    maxPixelsForDecode: 48000000,
  );

  final TempDirectoryProvider _tempDirectoryProvider;
  final ImageFileCompressor _compressor;
  final NetworkImageFetcher _networkImageFetcher;
  final Lock _previewLock = Lock();
  final Logger _logger = getLogger('ImagePreviewCacheService');

  static Future<String?> _defaultCompressor({
    required String sourcePath,
    required String targetPath,
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
    );
    return result?.path;
  }

  static bool isPreviewableImagePath(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return AssetSafetyService.imageExtensions.contains(extension);
  }

  Future<File> cacheFileForSource(String source) async {
    final cacheDir = await _cacheDirectory();
    final filenameHash = md5.convert(utf8.encode(source)).toString();
    return File(path.join(cacheDir.path, '$filenameHash$cacheFileSuffix'));
  }

  /// Removes previews derived from workspace files or downloaded image URLs.
  ///
  /// Backup restore replaces the workspace wholesale, so path-based cache
  /// entries cannot be trusted afterward. Normal reads remain path-only and
  /// pay no file-version lookup cost.
  Future<void> clear() => _previewLock.synchronized(() async {
        final tempDir = await _tempDirectoryProvider();
        final cacheDir = Directory(path.join(tempDir.path, cacheDirectoryName));
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
        }
      });

  Future<ImagePreviewFile> getOrCreatePreview({
    required String source,
    required bool isLocalFile,
  }) async {
    if (source.isEmpty) {
      throw const ImagePreviewUnavailable('image source is empty');
    }

    if (isLocalFile) {
      final sourceFile = File(source);
      if (!await sourceFile.exists()) {
        throw ImagePreviewUnavailable('source image is missing: $source');
      }

      final safety = AssetSafetyService.instance.inspectFileSync(
        source,
        config: previewSourceSafetyConfig,
      );
      if (!safety.safeForPreview) {
        throw ImagePreviewUnavailable(safety.reason);
      }
    }

    final cacheFile = await cacheFileForSource(source);
    if (await cacheFile.exists()) {
      return ImagePreviewFile(
        file: cacheFile,
        contentType: await detectImageContentType(cacheFile.path),
        cacheHit: true,
      );
    }

    return _previewLock.synchronized(() async {
      if (!await cacheFile.parent.exists()) {
        await cacheFile.parent.create(recursive: true);
      }
      if (await cacheFile.exists()) {
        return ImagePreviewFile(
          file: cacheFile,
          contentType: await detectImageContentType(cacheFile.path),
          cacheHit: true,
        );
      }

      return _createPreviewFile(
        source: source,
        isLocalFile: isLocalFile,
        cacheFile: cacheFile,
      );
    });
  }

  Future<ImagePreviewFile> _createPreviewFile({
    required String source,
    required bool isLocalFile,
    required File cacheFile,
  }) async {
    String sourcePath = source;
    File? tempDownloadFile;

    try {
      if (!isLocalFile) {
        _logger.info('Downloading network image preview source: $source');
        final http.Response response;
        try {
          response = await _networkImageFetcher(Uri.parse(source))
              .timeout(const Duration(seconds: 20));
        } on TimeoutException {
          throw const ImagePreviewUnavailable('image download timed out');
        }
        if (response.statusCode != 200) {
          throw ImagePreviewUnavailable(
            'failed to download image: ${response.statusCode}',
          );
        }

        final cacheDir = await _cacheDirectory();
        final extension = _networkImageExtension(response, source);
        tempDownloadFile = File(
          path.join(
            cacheDir.path,
            'temp_${DateTime.now().microsecondsSinceEpoch}$extension',
          ),
        );
        await tempDownloadFile.writeAsBytes(response.bodyBytes);
        sourcePath = tempDownloadFile.path;
      }

      final sourceSafety = AssetSafetyService.instance.inspectFileSync(
        sourcePath,
        config: previewSourceSafetyConfig,
      );
      if (!sourceSafety.safeForPreview) {
        throw ImagePreviewUnavailable(sourceSafety.reason);
      }

      final shouldCopyOriginal = sourceSafety.width != null &&
          sourceSafety.height != null &&
          sourceSafety.width! <= maxPreviewSide &&
          sourceSafety.height! <= maxPreviewSide;

      String? resultPath;
      if (shouldCopyOriginal) {
        final copiedFile = await File(sourcePath).copy(cacheFile.path);
        resultPath = copiedFile.path;
      } else {
        resultPath = await _compressor(
          sourcePath: sourcePath,
          targetPath: cacheFile.path,
          maxWidth: maxPreviewSide,
          maxHeight: maxPreviewSide,
          quality: previewQuality,
        );
      }

      if (resultPath == null) {
        throw const ImagePreviewUnavailable('safe preview generation failed');
      }

      final resultSafety = AssetSafetyService.instance.inspectFileSync(
        resultPath,
      );
      if (!resultSafety.safeForPreview) {
        throw ImagePreviewUnavailable(resultSafety.reason);
      }

      final resultFile = File(resultPath);
      return ImagePreviewFile(
        file: resultFile,
        contentType: await detectImageContentType(resultFile.path),
        cacheHit: false,
      );
    } finally {
      if (tempDownloadFile != null && await tempDownloadFile.exists()) {
        await tempDownloadFile.delete();
      }
    }
  }

  static String _networkImageExtension(http.Response response, String source) {
    final mimeType =
        response.headers['content-type']?.split(';').first.trim().toLowerCase();
    final fromMime = switch (mimeType) {
      'image/jpeg' || 'image/jpg' => '.jpg',
      'image/png' => '.png',
      'image/gif' => '.gif',
      'image/webp' => '.webp',
      'image/bmp' => '.bmp',
      'image/heic' => '.heic',
      'image/heif' => '.heif',
      'image/tiff' => '.tiff',
      _ => null,
    };
    if (fromMime != null) return fromMime;

    final sourceExtension =
        path.extension(Uri.parse(source).path).toLowerCase();
    if (AssetSafetyService.imageExtensions.contains(sourceExtension)) {
      return sourceExtension;
    }
    throw const ImagePreviewUnavailable('unsupported network image type');
  }

  Future<Directory> _cacheDirectory() async {
    final tempDir = await _tempDirectoryProvider();
    final cacheDir = Directory(path.join(tempDir.path, cacheDirectoryName));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  static Future<String> detectImageContentType(String filePath) async {
    final file = File(filePath);
    final stream = file.openRead(0, 16);
    final chunks = await stream.toList();
    final bytes = chunks.expand((chunk) => chunk).toList(growable: false);

    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a) {
      return 'image/png';
    }
    if (bytes.length >= 6) {
      final signature = String.fromCharCodes(bytes.take(6));
      if (signature == 'GIF87a' || signature == 'GIF89a') {
        return 'image/gif';
      }
    }
    if (bytes.length >= 12) {
      final riff = String.fromCharCodes(bytes.sublist(0, 4));
      final webp = String.fromCharCodes(bytes.sublist(8, 12));
      if (riff == 'RIFF' && webp == 'WEBP') {
        return 'image/webp';
      }
    }

    return 'image/jpeg';
  }
}
