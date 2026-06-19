import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/log_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.memexlab.memex/log_export');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('saveToPublicDownloads returns public Downloads path', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'saveToPublicDownloads');
      return '/storage/emulated/0/Download/app_2026-06-19.log';
    });

    final path = await LogExportService.saveToPublicDownloads(
      fileName: 'app_2026-06-19.log',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    expect(path, '/storage/emulated/0/Download/app_2026-06-19.log');
  });
}
