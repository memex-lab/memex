import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/logger.dart';

/// Result of importing a media file. All paths are **relative** to
/// [FileSystemService.dataRoot]; use [FileSystemService.toAbsolutePath] for
/// display / playback.
class ImportedMedia {
  /// Relative path to the stored file, ready to persist in YAML/JSON.
  final String relativePath;

  /// Absolute path to the stored file, convenient for immediate UI preview.
  final String absolutePath;

  const ImportedMedia({
    required this.relativePath,
    required this.absolutePath,
  });
}

/// Central service for importing user-supplied media (images, audio, ...)
/// into the per-user media pool at `workspace/_<userId>/_System/media/`.
///
/// Files are renamed on import using a canonical scheme:
///   images:  `YYYYMMDD_<uuid>_<W>x<H>.<ext>`
///   audio:   `YYYYMMDD_<uuid>_<durationSec>.<ext>`
///   fallback (dimension/duration unavailable): `YYYYMMDD_<uuid>.<ext>`
///
/// Call sites store the returned relative path; any display code resolves it
/// via [FileSystemService.toAbsolutePath] — same contract existing avatar
/// paths already use, so legacy absolute / previously-relative paths keep
/// working without migration.
class MediaService {
  MediaService._();
  static final MediaService instance = MediaService._();

  final Logger _logger = getLogger('MediaService');
  final Uuid _uuid = const Uuid();

  FileSystemService get _fs => FileSystemService.instance;

  /// Copy an image from [sourcePath] into the user's media pool.
  ///
  /// Tries to read the pixel dimensions for the canonical filename; if the
  /// image can't be decoded the dimensions segment is dropped.
  Future<ImportedMedia> importImage({
    required String userId,
    required String sourcePath,
  }) async {
    final dimensions = await _probeImageDimensions(sourcePath);
    final suffix =
        dimensions == null ? null : '${dimensions.$1}x${dimensions.$2}';
    return _importFile(
      userId: userId,
      sourcePath: sourcePath,
      suffix: suffix,
    );
  }

  /// Copy an audio file from [sourcePath] into the user's media pool.
  ///
  /// [durationSeconds] is expected from the caller (recorder / picker already
  /// knows it). When null, the duration segment is omitted from the filename.
  Future<ImportedMedia> importAudio({
    required String userId,
    required String sourcePath,
    int? durationSeconds,
  }) async {
    final suffix = durationSeconds == null ? null : '$durationSeconds';
    return _importFile(
      userId: userId,
      sourcePath: sourcePath,
      suffix: suffix,
    );
  }

  Future<ImportedMedia> _importFile({
    required String userId,
    required String sourcePath,
    required String? suffix,
  }) async {
    final mediaDir = _fs.getMediaPath(userId);
    await Directory(mediaDir).create(recursive: true);

    final ext = p.extension(sourcePath).toLowerCase();
    final fileName = _buildFileName(suffix: suffix, extension: ext);
    final destPath = p.join(mediaDir, fileName);

    await File(sourcePath).copy(destPath);
    _logger.info('Imported media: $sourcePath -> $destPath');

    return ImportedMedia(
      relativePath: _fs.toRelativePath(destPath),
      absolutePath: destPath,
    );
  }

  /// Build `YYYYMMDD_<uuid>[_<suffix>]<ext>` using local time.
  String _buildFileName({required String? suffix, required String extension}) {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final datePart = '$y$m$d';
    final id = _uuid.v4();
    final base = suffix == null || suffix.isEmpty
        ? '${datePart}_$id'
        : '${datePart}_${id}_$suffix';
    return '$base$extension';
  }

  /// Read image header metadata for pixel dimensions.
  /// Returns `(width, height)` or `null` if metadata is unavailable.
  Future<(int, int)?> _probeImageDimensions(String imagePath) async {
    try {
      final safety = await AssetSafetyService.instance.inspectFile(imagePath);
      final width = safety.width;
      final height = safety.height;
      if (width == null || height == null) return null;
      return (width, height);
    } catch (e) {
      _logger.fine('Failed to probe image dimensions for $imagePath: $e');
      return null;
    }
  }
}
