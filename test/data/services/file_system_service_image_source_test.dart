import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('memex_image_source_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    await LocalAssetServer.stopServer();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('converts fs asset references to local HTTP asset URLs', () async {
    final source = await FileSystemService.convertFsToLocalHttp(
      'fs://nested/img_20260706_ts_0_no_1_1080x1920.jpg',
      'alice',
    );

    final uri = Uri.parse(source);
    expect(uri.scheme, 'http');
    expect(uri.host, '127.0.0.1');
    expect(uri.pathSegments, [
      'assets',
      'alice',
      'nested',
      'img_20260706_ts_0_no_1_1080x1920.jpg',
    ]);
    expect(uri.queryParameters['token'], isNotEmpty);
  });
}
