import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';
import 'package:memex/data/services/image_preview_cache_service.dart';
import 'package:memex/utils/logger.dart';

/// Local asset server: HTTP server for local file access in client mode.
/// WebView can access files via http://127.0.0.1:port
class LocalAssetServer {
  static final Logger _logger = getLogger('LocalAssetServer');
  static HttpServer? _server;
  static int? _serverPort;
  static bool _isStarting = false;
  static String? _dataRoot;
  static String? _accessToken;

  /// Generate random access token (validate requests from our app)
  static String _generateToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Get access token (for FileSystemService)
  static String? get accessToken => _accessToken;

  /// Start local asset server. [dataRoot] for file paths, [preferredPort] 0 = random. Returns port.
  static Future<int> startServer(
      {int preferredPort = 0, String? dataRoot}) async {
    // Save dataRoot for later use
    if (dataRoot != null) {
      _dataRoot = dataRoot;
    }
    if (_server != null && _serverPort != null) {
      return _serverPort!;
    }

    if (_isStarting) {
      // If already starting, wait for completion
      while (_isStarting) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_serverPort != null) {
        return _serverPort!;
      }
    }

    _isStarting = true;

    try {
      // Try specified port; on failure try next ports
      var port = preferredPort;
      // Port 0 = try once (OS assigns); specific port = try up to 10 times
      final maxAttempts = preferredPort == 0 ? 1 : 10;

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        try {
          final server = await HttpServer.bind(
            InternetAddress.loopbackIPv4,
            port,
            shared: false,
          );

          // Performance: no compression for local transfer
          server.autoCompress = false;
          server.defaultResponseHeaders.removeAll('server');

          _server = server;
          _serverPort = server.port;
          _accessToken = _generateToken();
          _isStarting = false;

          _logger.info(
            'Local asset server started, port: $_serverPort\n'
            'Performance: streaming/compression disabled (local access)',
          );
          _logger.fine(
              'Access URL: http://127.0.0.1:$_serverPort, token: $_accessToken');

          // starthandlerequest
          server.listen(
            _handleRequest,
            onError: (e, stack) async {
              _logger.severe('Server error: $e', e, stack);
              await stopServer();
            },
            onDone: () async {
              _logger.warning('Server closed unexpectedly');
              await stopServer();
            },
          );

          return _serverPort!;
        } on SocketException catch (e) {
          if (preferredPort != 0 &&
              (e.osError?.errorCode == 48 || e.osError?.errorCode == 98)) {
            // Port in use, try next
            port++;
            _logger.fine('Port $port in use, trying next: ${port + 1}');
            continue;
          }
          rethrow;
        }
      }

      throw Exception('No available port to start local asset server');
    } catch (e, stackTrace) {
      _isStarting = false;
      _logger.severe('Failed to start local asset server: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Check server status; restart if down
  static Future<void> checkAndRestartIfNeeded({String? dataRoot}) async {
    if (_isStarting) return;

    // Update dataRoot if provided
    if (dataRoot != null) {
      _dataRoot = dataRoot;
    }

    bool needsRestart = false;

    if (_server == null) {
      needsRestart = true;
    } else if (_dataRoot == null) {
      // If server is running but dataRoot is missing, we need to restart/re-init
      _logger.warning('Server running without dataRoot, restarting...');
      needsRestart = true;
    } else {
      // Try connecting to port to ensure it is listening
      try {
        final socket = await Socket.connect(
            InternetAddress.loopbackIPv4, _serverPort!,
            timeout: const Duration(milliseconds: 500));
        socket.destroy();
      } catch (e) {
        _logger.warning('Local asset server port unreachable, restarting: $e');
        needsRestart = true;
      }
    }

    if (needsRestart) {
      _logger.info('Restarting local asset server...');
      await stopServer();
      // dataRoot already saved, no need to pass again
      await startServer(preferredPort: 0, dataRoot: _dataRoot);
    }
  }

  /// handle HTTP request
  static Future<void> _handleRequest(HttpRequest request) async {
    try {
      // Security: allow local access only
      final connectionInfo = request.connectionInfo;
      if (connectionInfo != null) {
        final remoteAddress = connectionInfo.remoteAddress;
        if (!_isLocalAccess(remoteAddress)) {
          _logger.warning(
            'Rejected non-local access: ${remoteAddress.address}:${connectionInfo.remotePort}',
          );
          request.response
            ..statusCode = HttpStatus.forbidden
            ..write('Access denied: Only local access is allowed')
            ..close();
          return;
        }
      }

      // Security: validate access token (ensure request from our app)
      final requestToken = request.uri.queryParameters['token'];
      if (_accessToken == null || requestToken != _accessToken) {
        _logger.warning(
          'Unauthorized: token mismatch or missing (request token: $requestToken)',
        );
        request.response
          ..statusCode = HttpStatus.forbidden
          ..write('Access denied: Invalid or missing token')
          ..close();
        return;
      }

      // Get request path (strip leading /)
      var requestPath = request.uri.path;
      if (requestPath.startsWith('/')) {
        requestPath = requestPath.substring(1);
      }

      // Log only in fine/debug to reduce overhead
      _logger.fine('Request received: ${request.method} ${request.uri.path}');

      if (request.method == 'GET') {
        // findfile
        // Path format: assets/{userId}/{filename}. Decode each path segment.
        final pathParts = requestPath.split('/');
        if (pathParts.length >= 3 && pathParts[0] == 'assets') {
          final userId = Uri.decodeComponent(pathParts[1]);
          final filename =
              pathParts.sublist(2).map(Uri.decodeComponent).join('/');

          // buildfile path
          // pathformat: {dataRoot}/workspace/_{userId}/Facts/assets/{filename}
          if (_dataRoot == null) {
            _logger.warning('dataRoot not set, cannot handle file request');
            request.response
              ..statusCode = HttpStatus.internalServerError
              ..write('Server not properly initialized')
              ..close();
            return;
          }

          final workspacePath = path.join(_dataRoot!, 'workspace', '_$userId');
          final assetsPath = path.join(workspacePath, 'Facts', 'assets');
          final filePath = path.join(assetsPath, filename);

          _logger.fine('Attempting to serve file: $filePath');

          // Checkfilewhether exists
          final file = File(filePath);
          if (!await file.exists()) {
            _logger.warning('File not found: $filePath');
            request.response
              ..statusCode = HttpStatus.notFound
              ..write('File not found: $requestPath')
              ..close();
            return;
          }

          // Read file (stream to reduce memory)
          try {
            final extension = path.extension(filename).toLowerCase();

            File responseFile = file;
            String? previewContentType;
            if (ImagePreviewCacheService.isPreviewableImagePath(filePath)) {
              try {
                final preview =
                    await ImagePreviewCacheService.instance.getOrCreatePreview(
                  source: filePath,
                  isLocalFile: true,
                );
                responseFile = preview.file;
                previewContentType = preview.contentType;
                _logger.fine(
                  'Serving image preview for $filePath from ${responseFile.path}',
                );
              } on ImagePreviewUnavailable catch (e) {
                _logger.warning(
                  'Image preview unavailable for $filePath: ${e.reason}',
                );
                request.response
                  ..statusCode = HttpStatus.unprocessableEntity
                  ..write('Image preview unavailable: ${e.reason}')
                  ..close();
                return;
              }
            }

            final fileLength = await responseFile.length();

            // Set Content-Type by extension, or by preview file signature.
            String contentType;
            if (previewContentType != null) {
              contentType = previewContentType;
            } else {
              switch (extension) {
                case '.jpg':
                case '.jpeg':
                  contentType = 'image/jpeg';
                  break;
                case '.png':
                  contentType = 'image/png';
                  break;
                case '.gif':
                  contentType = 'image/gif';
                  break;
                case '.webp':
                  contentType = 'image/webp';
                  break;
                case '.mp3':
                  contentType = 'audio/mpeg';
                  break;
                case '.m4a':
                  contentType = 'audio/mp4';
                  break;
                case '.wav':
                  contentType = 'audio/wav';
                  break;
                case '.ogg':
                  contentType = 'audio/ogg';
                  break;
                default:
                  contentType = 'application/octet-stream';
              }
            }

            // Stream file content to response
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.parse(contentType)
              ..headers.contentLength = fileLength
              ..headers.set('Cache-Control', 'public, max-age=31536000');

            // Stream file to avoid loading into memory
            await responseFile.openRead().pipe(request.response);

            _logger.fine(
              'Served file: ${responseFile.path} ($fileLength bytes)',
            );
            return;
          } catch (e) {
            _logger.warning('Failed to read file: $filePath, error: $e');
            request.response
              ..statusCode = HttpStatus.internalServerError
              ..write('Failed to read file: $e')
              ..close();
            return;
          }
        }

        // return 404
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Invalid path: $requestPath')
          ..close();
      } else {
        // Method not supported
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Method not allowed')
          ..close();
      }
    } catch (e, stackTrace) {
      _logger.warning('Failed to handle request: $e', e, stackTrace);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Internal server error: $e')
        ..close();
    }
  }

  /// Stop server
  static Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      _serverPort = null;
      _accessToken = null;
      _logger.info('Local asset server stopped');
    }
  }

  /// Get server port
  static int? get port => _serverPort;

  /// Whether server is running
  static bool get isRunning => _server != null;

  /// Check if local access (127.0.0.1, ::1)
  static bool _isLocalAccess(InternetAddress address) {
    return address.isLoopback ||
        address.address == '127.0.0.1' ||
        address.address == '::1' ||
        address.address.startsWith('127.') ||
        address.address.startsWith('::ffff:127.');
  }
}
