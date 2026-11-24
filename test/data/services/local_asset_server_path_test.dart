import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('memex_asset_path_');
  });

  tearDown(() async {
    await LocalAssetServer.stopServer();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('rejects encoded parent segments instead of reading outside assets',
      () async {
    const userId = 'alice';
    final secret = File(path.join(tempDir.path, 'secret.txt'));
    await secret.writeAsString('do-not-leak');

    final assetsDir = Directory(
      path.join(tempDir.path, 'workspace', '_$userId', 'Facts', 'assets'),
    );
    await assetsDir.create(recursive: true);
    final allowed = File(path.join(assetsDir.path, 'note.txt'));
    await allowed.writeAsString('allowed-body');

    final port = await LocalAssetServer.startServer(dataRoot: tempDir.path);
    final token = LocalAssetServer.accessToken!;

    final allowedResponse = await _rawHttpGet(
      port,
      '/assets/$userId/note.txt?token=$token',
    );
    expect(allowedResponse.statusCode, 200);
    expect(utf8.decode(allowedResponse.body), 'allowed-body');

    expect(
      safeAssetRelativePath(['assets', userId, '../../secret.txt']),
      isNull,
    );
    expect(
      safeAssetRelativePath(['assets', userId, 'note.txt'])?.filename,
      'note.txt',
    );

    final traversal = await _rawHttpGet(
      port,
      '/assets/$userId/..%2f..%2f..%2f..%2fsecret.txt?token=$token',
    );
    expect(traversal.statusCode, isNot(200));
    expect(utf8.decode(traversal.body), isNot(contains('do-not-leak')));

    final doubleEncoded = await _rawHttpGet(
      port,
      '/assets/$userId/%252e%252e/%252e%252e/secret.txt?token=$token',
    );
    expect(doubleEncoded.statusCode, isNot(200));
    expect(utf8.decode(doubleEncoded.body), isNot(contains('do-not-leak')));
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
  final header = ascii.decode(bytes.sublist(0, separatorIndex));
  final status = int.parse(header.split(' ').elementAt(1));
  return _RawHttpResponse(
    statusCode: status,
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
  final int statusCode;
  final List<int> body;

  const _RawHttpResponse({required this.statusCode, required this.body});
}
