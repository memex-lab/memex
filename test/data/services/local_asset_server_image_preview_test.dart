import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/image_preview_cache_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:path/path.dart' as path;

const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  File? cacheFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync(
      'memex_local_asset_preview_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
      if (call.method == 'getTemporaryDirectory') return tempDir.path;
      return null;
    });
  });

  tearDown(() async {
    await LocalAssetServer.stopServer();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    if (cacheFile != null && await cacheFile!.exists()) {
      await cacheFile!.delete();
    }
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('serves shared max768 image cache for asset HTTP requests', () async {
    const userId = 'alice';
    final assetsDir = Directory(
      path.join(tempDir.path, 'workspace', '_$userId', 'Facts', 'assets'),
    );
    await assetsDir.create(recursive: true);

    final sourceImage = File(path.join(assetsDir.path, 'safe.png'));
    await sourceImage.writeAsBytes(_pngHeader(width: 320, height: 240));

    cacheFile = await ImagePreviewCacheService.instance.cacheFileForSource(
      sourceImage.path,
    );
    const cachedPreviewBytes = [0xff, 0xd8, 0xff, 0xd9];
    await cacheFile!.writeAsBytes(cachedPreviewBytes);

    final port = await LocalAssetServer.startServer(dataRoot: tempDir.path);
    final response = await _rawHttpGet(
      port,
      '/assets/$userId/safe.png?token=${LocalAssetServer.accessToken!}',
    );

    expect(response.headers.toLowerCase(), contains('http/1.1 200 ok'));
    expect(
        response.headers.toLowerCase(), contains('content-type: image/jpeg'));
    expect(response.body, cachedPreviewBytes);
  });
}

Future<_RawHttpResponse> _rawHttpGet(int port, String requestPath) async {
  final socket = await Socket.connect(InternetAddress.loopbackIPv4, port);
  socket.write(
    'GET $requestPath HTTP/1.1\r\n'
    'Host: 127.0.0.1:$port\r\n'
    'Connection: close\r\n'
    '\r\n',
  );

  final bytes = <int>[];
  await for (final chunk in socket) {
    bytes.addAll(chunk);
  }

  final separator = ascii.encode('\r\n\r\n');
  final separatorIndex = _indexOfBytes(bytes, separator);
  expect(separatorIndex, isNonNegative);

  return _RawHttpResponse(
    headers: ascii.decode(bytes.sublist(0, separatorIndex)),
    body: bytes.sublist(separatorIndex + separator.length),
  );
}

int _indexOfBytes(List<int> bytes, List<int> pattern) {
  for (var i = 0; i <= bytes.length - pattern.length; i++) {
    var matches = true;
    for (var j = 0; j < pattern.length; j++) {
      if (bytes[i + j] != pattern[j]) {
        matches = false;
        break;
      }
    }
    if (matches) return i;
  }
  return -1;
}

class _RawHttpResponse {
  final String headers;
  final List<int> body;

  const _RawHttpResponse({
    required this.headers,
    required this.body,
  });
}

List<int> _pngHeader({required int width, required int height}) {
  final bytes = Uint8List(33);
  bytes.setAll(0, const [
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
  ]);
  _writeUint32Be(bytes, 16, width);
  _writeUint32Be(bytes, 20, height);
  bytes.setAll(24, const [
    0x08,
    0x02,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ]);
  return bytes;
}

void _writeUint32Be(Uint8List bytes, int offset, int value) {
  bytes[offset] = (value >> 24) & 0xff;
  bytes[offset + 1] = (value >> 16) & 0xff;
  bytes[offset + 2] = (value >> 8) & 0xff;
  bytes[offset + 3] = value & 0xff;
}
