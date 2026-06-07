import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as path;

enum AssetSafetyType { image, audio, unsupported, missing }

class AssetSafetyConfig {
  final int maxPixelsForDecode;
  final int maxLongEdgeForAnalysis;
  final double maxAspectRatioForOcr;
  final int maxFileBytesForInlineBase64;
  final int maxUnknownImageBytesForPreview;
  final int maxImageBytesForAnalysis;
  final int maxAudioBytesForCloud;
  final int maxAudioSecondsForAutoTranscribe;

  const AssetSafetyConfig({
    this.maxPixelsForDecode = 24000000,
    this.maxLongEdgeForAnalysis = 12000,
    this.maxAspectRatioForOcr = 12,
    this.maxFileBytesForInlineBase64 = 8 * 1024 * 1024,
    this.maxUnknownImageBytesForPreview = 8 * 1024 * 1024,
    this.maxImageBytesForAnalysis = 30 * 1024 * 1024,
    this.maxAudioBytesForCloud = 20 * 1024 * 1024,
    this.maxAudioSecondsForAutoTranscribe = 300,
  });
}

class AssetSafetyReport {
  final String filePath;
  final AssetSafetyType type;
  final int fileSizeBytes;
  final int? width;
  final int? height;
  final int? durationSeconds;
  final bool safeForPreview;
  final bool safeForAnalysis;
  final bool safeForOcr;
  final bool safeForInlineBase64;
  final String reason;

  const AssetSafetyReport({
    required this.filePath,
    required this.type,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    required this.durationSeconds,
    required this.safeForPreview,
    required this.safeForAnalysis,
    required this.safeForOcr,
    required this.safeForInlineBase64,
    required this.reason,
  });

  bool get hasDimensions => width != null && height != null;

  double get aspectRatio {
    final w = width;
    final h = height;
    if (w == null || h == null || w <= 0 || h <= 0) return 0;
    final longEdge = math.max(w, h);
    final shortEdge = math.min(w, h);
    return longEdge / shortEdge;
  }

  int? get pixelCount {
    final w = width;
    final h = height;
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return w * h;
  }

  String get metadataSummary {
    final parts = <String>['size=${_formatBytes(fileSizeBytes)}'];
    if (width != null && height != null) {
      parts.add('dimensions=${width}x$height');
      parts.add('aspect=${aspectRatio.toStringAsFixed(2)}');
    }
    if (durationSeconds != null) {
      parts.add('duration=${durationSeconds}s');
    }
    return parts.join(', ');
  }

  String analysisSkipText(String assetName) {
    return 'Automatic analysis skipped for $assetName: $reason. '
        'The original file was preserved. $metadataSummary';
  }

  static String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${bytes}B';
  }
}

class AssetSafetyService {
  AssetSafetyService._();

  static final AssetSafetyService instance = AssetSafetyService._();

  final Logger _logger = getLogger('AssetSafetyService');

  static const imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.heic',
    '.heif',
    '.tiff',
    '.tif',
  };

  static const audioExtensions = {
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

  Future<AssetSafetyReport> inspectFile(
    String filePath, {
    AssetSafetyConfig config = const AssetSafetyConfig(),
  }) async {
    return inspectFileSync(filePath, config: config);
  }

  AssetSafetyReport inspectFileSync(
    String filePath, {
    AssetSafetyConfig config = const AssetSafetyConfig(),
  }) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return AssetSafetyReport(
        filePath: filePath,
        type: AssetSafetyType.missing,
        fileSizeBytes: 0,
        width: null,
        height: null,
        durationSeconds: null,
        safeForPreview: false,
        safeForAnalysis: false,
        safeForOcr: false,
        safeForInlineBase64: false,
        reason: 'file is missing',
      );
    }

    final fileSize = file.lengthSync();
    final extension = path.extension(filePath).toLowerCase();
    if (imageExtensions.contains(extension)) {
      return _inspectImage(filePath, fileSize, config);
    }
    if (audioExtensions.contains(extension)) {
      return _inspectAudio(filePath, fileSize, config);
    }

    return AssetSafetyReport(
      filePath: filePath,
      type: AssetSafetyType.unsupported,
      fileSizeBytes: fileSize,
      width: null,
      height: null,
      durationSeconds: null,
      safeForPreview: false,
      safeForAnalysis: false,
      safeForOcr: false,
      safeForInlineBase64: fileSize <= config.maxFileBytesForInlineBase64,
      reason: 'unsupported asset type',
    );
  }

  AssetSafetyReport _inspectImage(
    String filePath,
    int fileSize,
    AssetSafetyConfig config,
  ) {
    final metadata = _readImageMetadata(filePath);
    final width = metadata?.width;
    final height = metadata?.height;
    final reasons = <String>[];

    bool safeForPreview;
    bool safeForAnalysis;
    bool safeForOcr;

    if (width != null && height != null && width > 0 && height > 0) {
      final pixels = width * height;
      final longEdge = math.max(width, height);
      final shortEdge = math.min(width, height);
      final aspectRatio = longEdge / shortEdge;

      if (pixels > config.maxPixelsForDecode) {
        reasons.add(
          'image pixel count $pixels exceeds ${config.maxPixelsForDecode}',
        );
      }
      if (longEdge > config.maxLongEdgeForAnalysis) {
        reasons.add(
          'image long edge $longEdge exceeds ${config.maxLongEdgeForAnalysis}',
        );
      }
      if (fileSize > config.maxImageBytesForAnalysis) {
        reasons.add(
          'image file size ${AssetSafetyReport._formatBytes(fileSize)} exceeds ${AssetSafetyReport._formatBytes(config.maxImageBytesForAnalysis)}',
        );
      }

      final safeForDecode = reasons.isEmpty;
      safeForPreview = safeForDecode;
      safeForAnalysis = safeForDecode;
      safeForOcr = safeForDecode && aspectRatio <= config.maxAspectRatioForOcr;
      if (safeForDecode && !safeForOcr) {
        reasons.add(
          'image aspect ratio ${aspectRatio.toStringAsFixed(2)} exceeds OCR limit ${config.maxAspectRatioForOcr.toStringAsFixed(2)}',
        );
      }
    } else {
      safeForPreview = fileSize <= config.maxUnknownImageBytesForPreview;
      safeForAnalysis = safeForPreview;
      safeForOcr = false;
      if (safeForPreview) {
        reasons.add('image dimensions are unavailable; OCR skipped');
      } else {
        reasons.add(
          'image dimensions are unavailable and file size ${AssetSafetyReport._formatBytes(fileSize)} exceeds ${AssetSafetyReport._formatBytes(config.maxUnknownImageBytesForPreview)}',
        );
      }
    }

    final inlineSafe =
        fileSize <= config.maxFileBytesForInlineBase64 &&
        safeForPreview &&
        safeForAnalysis;

    return AssetSafetyReport(
      filePath: filePath,
      type: AssetSafetyType.image,
      fileSizeBytes: fileSize,
      width: width,
      height: height,
      durationSeconds: null,
      safeForPreview: safeForPreview,
      safeForAnalysis: safeForAnalysis,
      safeForOcr: safeForOcr,
      safeForInlineBase64: inlineSafe,
      reason: reasons.isEmpty
          ? 'asset is within safety limits'
          : reasons.join('; '),
    );
  }

  AssetSafetyReport _inspectAudio(
    String filePath,
    int fileSize,
    AssetSafetyConfig config,
  ) {
    final durationSeconds = _durationSecondsFromFileName(filePath);
    final reasons = <String>[];
    if (durationSeconds == null) {
      reasons.add('audio duration is unavailable');
    }
    if (fileSize > config.maxAudioBytesForCloud) {
      reasons.add(
        'audio file size ${AssetSafetyReport._formatBytes(fileSize)} exceeds ${AssetSafetyReport._formatBytes(config.maxAudioBytesForCloud)}',
      );
    }
    if (durationSeconds != null &&
        durationSeconds > config.maxAudioSecondsForAutoTranscribe) {
      reasons.add(
        'audio duration ${durationSeconds}s exceeds ${config.maxAudioSecondsForAutoTranscribe}s',
      );
    }

    final safeForAnalysis = reasons.isEmpty;
    final inlineSafe =
        fileSize <= config.maxFileBytesForInlineBase64 &&
        durationSeconds != null &&
        durationSeconds <= config.maxAudioSecondsForAutoTranscribe;

    return AssetSafetyReport(
      filePath: filePath,
      type: AssetSafetyType.audio,
      fileSizeBytes: fileSize,
      width: null,
      height: null,
      durationSeconds: durationSeconds,
      safeForPreview: true,
      safeForAnalysis: safeForAnalysis,
      safeForOcr: false,
      safeForInlineBase64: inlineSafe,
      reason: reasons.isEmpty
          ? 'asset is within safety limits'
          : reasons.join('; '),
    );
  }

  _ImageMetadata? _readImageMetadata(String filePath) {
    RandomAccessFile? raf;
    try {
      final file = File(filePath);
      raf = file.openSync();
      final length = raf.lengthSync();
      final bytesToRead = math.min(length, 1024 * 1024);
      final header = raf.readSync(bytesToRead);
      return _parseImageMetadata(Uint8List.fromList(header));
    } catch (e) {
      _logger.fine('Failed to read image metadata for $filePath: $e');
      return null;
    } finally {
      try {
        raf?.closeSync();
      } catch (_) {}
    }
  }

  _ImageMetadata? _parseImageMetadata(Uint8List bytes) {
    if (_isPng(bytes)) return _parsePng(bytes);
    if (_isJpeg(bytes)) return _parseJpeg(bytes);
    if (_isGif(bytes)) return _parseGif(bytes);
    if (_isBmp(bytes)) return _parseBmp(bytes);
    if (_isWebp(bytes)) return _parseWebp(bytes);
    return null;
  }

  bool _isPng(Uint8List bytes) {
    return bytes.length >= 24 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a;
  }

  _ImageMetadata? _parsePng(Uint8List bytes) {
    if (bytes.length < 24) return null;
    return _ImageMetadata(_readUint32Be(bytes, 16), _readUint32Be(bytes, 20));
  }

  bool _isJpeg(Uint8List bytes) {
    return bytes.length >= 4 && bytes[0] == 0xff && bytes[1] == 0xd8;
  }

  _ImageMetadata? _parseJpeg(Uint8List bytes) {
    var offset = 2;
    while (offset + 9 < bytes.length) {
      while (offset < bytes.length && bytes[offset] != 0xff) {
        offset++;
      }
      while (offset < bytes.length && bytes[offset] == 0xff) {
        offset++;
      }
      if (offset >= bytes.length) return null;

      final marker = bytes[offset++];
      if (marker == 0xd9 || marker == 0xda) return null;
      if (_isStandaloneJpegMarker(marker)) continue;
      if (offset + 2 > bytes.length) return null;

      final segmentLength = _readUint16Be(bytes, offset);
      if (segmentLength < 2 || offset + segmentLength > bytes.length) {
        return null;
      }

      if (_isJpegSofMarker(marker) && segmentLength >= 7) {
        final height = _readUint16Be(bytes, offset + 3);
        final width = _readUint16Be(bytes, offset + 5);
        return _ImageMetadata(width, height);
      }

      offset += segmentLength;
    }
    return null;
  }

  bool _isStandaloneJpegMarker(int marker) {
    return marker == 0x01 || (marker >= 0xd0 && marker <= 0xd7);
  }

  bool _isJpegSofMarker(int marker) {
    return marker == 0xc0 ||
        marker == 0xc1 ||
        marker == 0xc2 ||
        marker == 0xc3 ||
        marker == 0xc5 ||
        marker == 0xc6 ||
        marker == 0xc7 ||
        marker == 0xc9 ||
        marker == 0xca ||
        marker == 0xcb ||
        marker == 0xcd ||
        marker == 0xce ||
        marker == 0xcf;
  }

  bool _isGif(Uint8List bytes) {
    if (bytes.length < 10) return false;
    final header = String.fromCharCodes(bytes.sublist(0, 6));
    return header == 'GIF87a' || header == 'GIF89a';
  }

  _ImageMetadata? _parseGif(Uint8List bytes) {
    if (bytes.length < 10) return null;
    return _ImageMetadata(_readUint16Le(bytes, 6), _readUint16Le(bytes, 8));
  }

  bool _isBmp(Uint8List bytes) {
    return bytes.length >= 26 && bytes[0] == 0x42 && bytes[1] == 0x4d;
  }

  _ImageMetadata? _parseBmp(Uint8List bytes) {
    if (bytes.length < 26) return null;
    final width = _readInt32Le(bytes, 18).abs();
    final height = _readInt32Le(bytes, 22).abs();
    return _ImageMetadata(width, height);
  }

  bool _isWebp(Uint8List bytes) {
    if (bytes.length < 30) return false;
    return String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
  }

  _ImageMetadata? _parseWebp(Uint8List bytes) {
    var offset = 12;
    while (offset + 8 <= bytes.length) {
      final chunkType = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = _readUint32Le(bytes, offset + 4);
      final payload = offset + 8;
      if (payload + chunkSize > bytes.length) return null;

      if (chunkType == 'VP8X' && chunkSize >= 10) {
        final width = 1 + _readUint24Le(bytes, payload + 4);
        final height = 1 + _readUint24Le(bytes, payload + 7);
        return _ImageMetadata(width, height);
      }
      if (chunkType == 'VP8L' && chunkSize >= 5 && bytes[payload] == 0x2f) {
        final b1 = bytes[payload + 1];
        final b2 = bytes[payload + 2];
        final b3 = bytes[payload + 3];
        final b4 = bytes[payload + 4];
        final width = 1 + b1 + ((b2 & 0x3f) << 8);
        final height = 1 + ((b2 >> 6) | (b3 << 2) | ((b4 & 0x0f) << 10));
        return _ImageMetadata(width, height);
      }
      if (chunkType == 'VP8 ' && chunkSize >= 10) {
        final width = _readUint16Le(bytes, payload + 6) & 0x3fff;
        final height = _readUint16Le(bytes, payload + 8) & 0x3fff;
        return _ImageMetadata(width, height);
      }

      offset = payload + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }
    return null;
  }

  int? _durationSecondsFromFileName(String filePath) {
    final name = path.basename(filePath);
    final match = RegExp(r'_(\d+)(?=\.[^.]+$)').firstMatch(name);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  int _readUint16Be(Uint8List bytes, int offset) {
    return (bytes[offset] << 8) | bytes[offset + 1];
  }

  int _readUint16Le(Uint8List bytes, int offset) {
    return bytes[offset] | (bytes[offset + 1] << 8);
  }

  int _readUint24Le(Uint8List bytes, int offset) {
    return bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);
  }

  int _readUint32Be(Uint8List bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  int _readUint32Le(Uint8List bytes, int offset) {
    return bytes[offset] |
        (bytes[offset + 1] << 8) |
        (bytes[offset + 2] << 16) |
        (bytes[offset + 3] << 24);
  }

  int _readInt32Le(Uint8List bytes, int offset) {
    final value = _readUint32Le(bytes, offset);
    return value & 0x80000000 == 0 ? value : value - 0x100000000;
  }
}

class _ImageMetadata {
  final int width;
  final int height;

  const _ImageMetadata(this.width, this.height);
}
