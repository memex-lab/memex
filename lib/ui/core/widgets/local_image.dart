import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:shimmer/shimmer.dart';
import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/image_preview_cache_service.dart';
import 'package:memex/utils/logger.dart';

final Logger _logger = getLogger('LocalImage');

final Uint8List _transparentPng = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4e,
  0x47,
  0x0d,
  0x0a,
  0x1a,
  0x0a,
  0x00,
  0x00,
  0x00,
  0x0d,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1f,
  0x15,
  0xc4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0a,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9c,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0d,
  0x0a,
  0x2d,
  0xb4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4e,
  0x44,
  0xae,
  0x42,
  0x60,
  0x82,
]);

/// Image widget that handles local server URL and local file path
/// - If URL starts with http://127.0.0.1, parse as local file path and use Image.file
/// - If URL does not start with http (local path), use Image.file
/// - else use Image.network for remote images
class LocalImage extends StatefulWidget {
  static const AssetSafetyConfig previewSourceSafetyConfig =
      ImagePreviewCacheService.previewSourceSafetyConfig;

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
  static ImageProvider provider(String url, {Duration? timeout}) {
    // try parse local file path (from http://127.0.0.1 URL)
    final localFilePath = _parseLocalFilePath(url);

    // check if local file path
    final isLocalFile = localFilePath != null || !url.startsWith('http');

    if (isLocalFile) {
      final filePath = localFilePath ?? url;
      final safety = AssetSafetyService.instance.inspectFileSync(filePath);
      if (!safety.safeForPreview) {
        _logger.warning(
          'LocalImage.provider blocked unsafe preview for $filePath: ${safety.reason}',
        );
        return MemoryImage(_transparentPng);
      }
      return FileImage(File(filePath));
    } else {
      return TimeoutNetworkImage(
        url,
        timeout: timeout ?? const Duration(seconds: 20),
      );
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
  bool _previewUnavailable = false;
  String? _previewUnavailableReason;

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
    _previewUnavailable = false;
    _previewUnavailableReason = null;

    if (widget.url.isEmpty) {
      if (mounted) {
        setState(() {
          _imageFile = null;
          _isLoading = false;
          _previewUnavailable = false;
          _previewUnavailableReason = null;
        });
      }
      return;
    }

    // 1. parse/check path
    final localFilePath = LocalImage._parseLocalFilePath(widget.url);
    final isLocalFile = localFilePath != null || !widget.url.startsWith('http');

    String originalPath = '';

    if (isLocalFile) {
      originalPath = localFilePath ?? widget.url;
      final originalFile = File(originalPath);

      if (!originalFile.existsSync()) {
        // original file not found, cannot load
        if (mounted) {
          setState(() {
            _imageFile = File(
              originalPath,
            ); // still set so Image.file handles error
            _isLoading = false;
          });
        }
        return;
      }

      final safety = AssetSafetyService.instance.inspectFileSync(
        originalPath,
        config: LocalImage.previewSourceSafetyConfig,
      );
      if (!safety.safeForPreview) {
        _logger.warning(
          'Local image preview blocked for $originalPath: ${safety.reason}',
        );
        if (mounted) {
          setState(() {
            _imageFile = null;
            _isLoading = false;
            _previewUnavailable = true;
            _previewUnavailableReason = safety.reason;
          });
        }
        return;
      }
    } else {
      // for network image, use URL as key base for originalPath
      originalPath = widget.url;
    }

    try {
      final preview =
          await ImagePreviewCacheService.instance.getOrCreatePreview(
        source: originalPath,
        isLocalFile: isLocalFile,
      );

      if (mounted) {
        _logger.info('Preview ready for image: $originalPath');
        setState(() {
          _imageFile = preview.file;
          _isLoading = false;
        });
      }
    } on ImagePreviewUnavailable catch (e) {
      _logger.warning('Image preview unavailable for $originalPath: $e');
      if (mounted) {
        setState(() {
          _imageFile = null;
          _isLoading = false;
          _previewUnavailable = true;
          _previewUnavailableReason = e.reason;
        });
      }
    } catch (e) {
      _logger.severe('LocalImage processing error for image: $originalPath', e);
      if (mounted) {
        setState(() {
          _imageFile = null;
          _isLoading = false;
          _previewUnavailable = true;
          _previewUnavailableReason = 'safe preview generation failed';
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

  Widget _buildPreviewUnavailable() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(
        context,
        Exception(_previewUnavailableReason ?? 'Image preview unavailable'),
        StackTrace.current,
      );
    }

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: Colors.grey[100],
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[500],
        size: 28,
      ),
    );
  }

  /// Wrap user frameBuilder or provide default skeleton
  Widget Function(BuildContext, Widget, int?, bool)? _getFrameBuilder() {
    if (widget.frameBuilder != null) return widget.frameBuilder;

    // default: show skeleton until first frame loaded
    return (
      BuildContext context,
      Widget child,
      int? frame,
      bool wasSynchronouslyLoaded,
    ) {
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
          context,
          Exception('Image url is empty'),
          StackTrace.current,
        );
      }
      return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
    }

    if (_isLoading) {
      // while loading or checking cache, show skeleton
      return _buildSkeleton();
    }

    if (_previewUnavailable) {
      return _buildPreviewUnavailable();
    }

    // local file mode
    if (_imageFile != null) {
      if (!_imageFile!.existsSync()) {
        _logger.severe(
          'File not found when loading with Image.file: ${_imageFile!.path}',
        );
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
            stackTrace,
          );
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, error, stackTrace);
          }
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
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

/// Remote [ImageProvider] with a download timeout so a bad URL cannot hang
/// [DecorationImage] / [CircleAvatar] the way [NetworkImage] can.
class TimeoutNetworkImage extends ImageProvider<TimeoutNetworkImage> {
  const TimeoutNetworkImage(
    this.url, {
    this.scale = 1.0,
    this.timeout = const Duration(seconds: 20),
  });

  final String url;
  final double scale;
  final Duration timeout;

  @override
  Future<TimeoutNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<TimeoutNetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    TimeoutNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<TimeoutNetworkImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    TimeoutNetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    assert(key == this);

    final uri = Uri.parse(key.url);
    final client = HttpClient()
      ..connectionTimeout = key.timeout
      ..idleTimeout = key.timeout;

    try {
      final request = await client.getUrl(uri).timeout(key.timeout);
      final response = await request.close().timeout(key.timeout);
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>().timeout(key.timeout);
        throw NetworkImageLoadException(
          statusCode: response.statusCode,
          uri: uri,
        );
      }

      final bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(
            ImageChunkEvent(
              cumulativeBytesLoaded: cumulative,
              expectedTotalBytes: total,
            ),
          );
        },
      ).timeout(key.timeout);

      if (bytes.isEmpty) {
        throw Exception('TimeoutNetworkImage is an empty file: $uri');
      }

      return await decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (error) {
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
      client.close(force: true);
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TimeoutNetworkImage &&
        other.url == url &&
        other.scale == scale &&
        other.timeout == timeout;
  }

  @override
  int get hashCode => Object.hash(url, scale, timeout);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'TimeoutNetworkImage')}("$url", scale: ${scale.toStringAsFixed(1)}, timeout: $timeout)';
}
