import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:crypto/crypto.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/logger.dart';

final Logger _logger = getLogger('LocalImage');

/// Image widget that handles local server URL and local file path
/// - If URL starts with http://127.0.0.1, parse as local file path and use Image.file
/// - If URL does not start with http (local path), use Image.file
/// - else use Image.network for remote images
class LocalImage extends StatefulWidget {
  /// Image URL
  final String url;

  /// Box fit
  final BoxFit? fit;

  /// Image width
  final double? width;

  /// Image height
  final double? height;

  /// Alignment
  final AlignmentGeometry alignment;

  /// Repeat mode
  final ImageRepeat repeat;

  /// Center slice (for nine-patch)
  final Rect? centerSlice;

  /// Match text direction
  final bool matchTextDirection;

  /// Gapless playback
  final bool gaplessPlayback;

  /// Anti-alias
  final bool isAntiAlias;

  /// Filter quality
  final FilterQuality filterQuality;

  /// Error builder
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Frame builder
  final ImageFrameBuilder? frameBuilder;

  /// Semantic label
  final String? semanticLabel;

  /// Exclude from semantics
  final bool excludeFromSemantics;

  /// Cache width
  final int? cacheWidth;

  /// Cache height
  final int? cacheHeight;

  /// Color
  final Color? color;

  /// Color blend mode
  final BlendMode? colorBlendMode;

  const LocalImage({
    super.key,
    required this.url,
    this.fit,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    this.errorBuilder,
    this.frameBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.cacheWidth,
    this.cacheHeight,
    this.color,
    this.colorBlendMode,
  });

  /// Parse file path from local server URL
  /// URL format: http://127.0.0.1:port/assets/{userId}/{filename}?token=xxx
  /// file path format: {dataRoot}/workspace/_{userId}/Facts/assets/{filename}
  static String? _parseLocalFilePath(String url) {
    if (!url.startsWith('http://127.0.0.1')) {
      return null;
    }

    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // path format: /assets/{userId}/{filename}
      if (pathSegments.length < 3 || pathSegments[0] != 'assets') {
        return null;
      }

      // pathSegments from Uri.pathSegments are already decoded, so do NOT call Uri.decodeComponent
      // again here, otherwise any literal '%' in the segment will trigger an
      // "Illegal percent encoding" error.
      final userId = pathSegments[1];
      final filename = pathSegments.sublist(2).join(Platform.pathSeparator);

      // Get FileSystemService instance
      try {
        final fileSystemService = FileSystemService.instance;
        final dataRoot = fileSystemService.dataRoot;

        // build file path: {dataRoot}/workspace/_{userId}/Facts/assets/{filename}
        final workspacePath = path.join(dataRoot, 'workspace', '_$userId');
        final assetsPath = path.join(workspacePath, 'Facts', 'assets');
        final filePath = path.join(assetsPath, filename);
        return filePath;
      } catch (e) {
        // FileSystemService not initialized or other error, return null
        _logger.info(
          'LocalImage._parseLocalFilePath: FileSystemService failed for url=$url, error=$e',
        );
        return null;
      }
    } catch (e) {
      _logger.info(
        'LocalImage._parseLocalFilePath: parse failed for url=$url, error=$e',
      );
      return null;
    }
  }

  /// Get ImageProvider (for DecorationImage, CircleAvatar, etc.)
  static ImageProvider provider(String url) {
    // try parse local file path (from http://127.0.0.1 URL)
    final localFilePath = _parseLocalFilePath(url);

    // check if local file path
    final isLocalFile = localFilePath != null || !url.startsWith('http');

    if (isLocalFile) {
      // use local file load
      // TODO: Cannot easily use compression cache here because ImageProvider is sync,
      // while compression is async. May need custom ImageProvider for compressed images.
      // For now return raw image provider.
      return FileImage(File(localFilePath ?? url));
    } else {
      // use network load
      return NetworkImage(url);
    }
  }

  @override
  State<LocalImage> createState() => _LocalImageState();

  /// Extract width/height from URL in _1920x1080 format; ignore suffix like _max768.jpg
  static Size? extractDimensionsFromUrl(String url) {
    // match _1920x1080_ followed by any chars or .png etc.
    final regex = RegExp(r'_(\d+)x(\d+)(?:_|\[|\.|$)');
    final match = regex.firstMatch(url);
    if (match != null) {
      final width = double.tryParse(match.group(1)!);
      final height = double.tryParse(match.group(2)!);
      if (width != null && height != null && height > 0) {
        return Size(width, height);
      }
    }
    return null;
  }
}

class _LocalImageState extends State<LocalImage> {
  File? _imageFile;
  bool _isLoading = true; // preload state for local images only

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant LocalImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.url.isEmpty) {
      if (mounted) {
        setState(() {
          _imageFile = null;
          _isLoading = false;
        });
      }
      return;
    }

    // 1. parse/check path
    final localFilePath = LocalImage._parseLocalFilePath(widget.url);
    final isLocalFile = localFilePath != null || !widget.url.startsWith('http');

    String originalPath = '';
    File? originalFile;

    if (isLocalFile) {
      originalPath = localFilePath ?? widget.url;
      originalFile = File(originalPath);

      if (!await originalFile.exists()) {
        // original file not found, cannot load
        if (mounted) {
          setState(() {
            _imageFile =
                File(originalPath); // still set so Image.file handles error
            _isLoading = false;
          });
        }
        return;
      }
    } else {
      // for network image, use URL as key base for originalPath
      originalPath = widget.url;
    }

    try {
      // 2. prepare cache directory
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory(path.join(tempDir.path, 'image_cache'));
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      // 3. generate cache key (MD5 to avoid filename length limit)
      // Use md5 instead of base64Url: on iOS sim/device full path is very long;
      // base64 would exceed APFS 255-byte filename limit and cause "Cannot retrieve length of file" error.
      final cacheKeyBase = originalPath;
      final filenameHash = md5.convert(utf8.encode(cacheKeyBase)).toString();
      final cacheFilename = '${filenameHash}_max768.jpg';
      final cacheFile = File(path.join(cacheDir.path, cacheFilename));

      // 4. check cache
      if (await cacheFile.exists()) {
        // cache hit
        if (mounted) {
          setState(() {
            _imageFile = cacheFile;
            _isLoading = false;
          });
        }
        return;
      }

      // 5. compress (download first if network image)
      String sourcePath = originalPath;
      File? tempDownloadFile;

      if (!isLocalFile) {
        // download network image to temp file
        _logger.info('Downloading network image: $originalPath');
        final response = await http.get(Uri.parse(originalPath));
        if (response.statusCode == 200) {
          tempDownloadFile = File(path.join(
              cacheDir.path, 'temp_${DateTime.now().millisecondsSinceEpoch}'));
          await tempDownloadFile.writeAsBytes(response.bodyBytes);
          sourcePath = tempDownloadFile.path;
        } else {
          throw Exception('Failed to download image: ${response.statusCode}');
        }
      }

      // check image size; if already <= 768, copy file to avoid re-compression quality loss
      String? resultPath;
      bool needCompress = true;

      try {
        final bytes = await File(sourcePath).readAsBytes();
        final decodedImage = await decodeImageFromList(bytes);
        if (decodedImage.width <= 768 && decodedImage.height <= 768) {
          needCompress = false;
        }
        decodedImage.dispose();
      } catch (e) {
        _logger.warning(
            'Failed to decode image to check size for $sourcePath', e);
      }

      if (needCompress) {
        // compress to max side 768
        final result = await FlutterImageCompress.compressAndGetFile(
          sourcePath,
          cacheFile.path,
          minWidth: 768,
          minHeight: 768,
          quality: 80,
        );
        resultPath = result?.path;
      } else {
        _logger
            .info('Image dimensions <= 768, skip compression: $originalPath');
        final copiedFile = await File(sourcePath).copy(cacheFile.path);
        resultPath = copiedFile.path;
      }

      // delete temp download file if any
      if (tempDownloadFile != null && await tempDownloadFile.exists()) {
        await tempDownloadFile.delete();
      }

      // 6. update status
      if (mounted) {
        if (resultPath != null) {
          _logger.info('Compression/Copy success for image: $originalPath');
          setState(() {
            _imageFile = File(resultPath!);
            _isLoading = false;
          });
        } else {
          _logger.warning(
              'Compression/Copy failed (null result) for image: $originalPath');
          setState(() {
            // on failure (null resultPath), fallback to original image (local) or URL (network)
            _imageFile = isLocalFile ? originalFile : null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      _logger.severe('LocalImage processing error for image: $originalPath', e);
      // on error, fallback
      if (mounted) {
        setState(() {
          _imageFile = isLocalFile ? originalFile : null;
          _isLoading = false;
        });
      }
    }
  }

  /// Build skeleton placeholder
  Widget _buildSkeleton() {
    Widget skeleton = Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        color: Colors.white,
      ),
    );

    // if width/height specified, return as-is (externally constrained)
    if (widget.width != null && widget.height != null) {
      return skeleton;
    }

    // try infer aspect ratio from filename
    final Size? dims = LocalImage.extractDimensionsFromUrl(widget.url);
    if (dims != null && dims.height > 0) {
      return AspectRatio(
        aspectRatio: dims.width / dims.height,
        child: skeleton,
      );
    }

    return skeleton;
  }

  /// Wrap user frameBuilder or provide default skeleton
  Widget Function(BuildContext, Widget, int?, bool)? _getFrameBuilder() {
    if (widget.frameBuilder != null) return widget.frameBuilder;

    // default: show skeleton until first frame loaded
    return (BuildContext context, Widget child, int? frame,
        bool wasSynchronouslyLoaded) {
      if (wasSynchronouslyLoaded || frame != null) {
        return child;
      }
      return _buildSkeleton();
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(
            context, Exception('Image url is empty'), StackTrace.current);
      }
      return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
    }

    if (_isLoading) {
      // while loading or checking cache, show skeleton
      return _buildSkeleton();
    }

    // local file mode
    if (_imageFile != null) {
      if (!_imageFile!.existsSync()) {
        _logger.severe(
            'File not found when loading with Image.file: ${_imageFile!.path}');
      }
      return Image.file(
        _imageFile!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        alignment: widget.alignment,
        repeat: widget.repeat,
        centerSlice: widget.centerSlice,
        matchTextDirection: widget.matchTextDirection,
        gaplessPlayback: widget.gaplessPlayback,
        isAntiAlias: widget.isAntiAlias,
        filterQuality: widget.filterQuality,
        errorBuilder: (context, error, stackTrace) {
          _logger.severe(
              'Image.file failed to load local image: ${_imageFile!.path} - error: $error',
              error,
              stackTrace);
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, error, stackTrace);
          }
          return const Center(
              child: Icon(Icons.broken_image, color: Colors.grey));
        },
        frameBuilder: _getFrameBuilder(),
        semanticLabel: widget.semanticLabel,
        excludeFromSemantics: widget.excludeFromSemantics,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
      );
    }

    // network image mode
    return Image.network(
      widget.url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: widget.gaplessPlayback,
      isAntiAlias: widget.isAntiAlias,
      filterQuality: widget.filterQuality,
      errorBuilder: widget.errorBuilder,
      frameBuilder: _getFrameBuilder(),
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
    );
  }
}
