import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('memex_local_image_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets(
    'shows a safe placeholder instead of rendering unsafe long image',
    (tester) async {
      final image = File('${tempDir.path}/long.png');
      image.writeAsBytesSync(_pngHeader(width: 1000, height: 13000));

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 160,
            height: 120,
            child: LocalImage(url: image.path, fit: BoxFit.cover),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  testWidgets(
    'shows a safe placeholder for unsafe downloaded network images',
    (tester) async {
      late HttpServer server;
      await tester.runAsync<void>(() async {
        server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        server.listen((request) {
          request.response.headers.contentType = ContentType(
            'image',
            'png',
          );
          request.response.add(_pngHeader(width: 1000, height: 13000));
          request.response.close();
        });
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 160,
            height: 120,
            child: LocalImage(
              url: 'http://${server.address.host}:${server.port}/long.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

      await tester.runAsync<void>(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.runAsync<void>(() async {
        await server.close(force: true);
      });

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  test('provider returns memory placeholder for unsafe local images', () {
    final image = File('${tempDir.path}/long.png');
    image.writeAsBytesSync(_pngHeader(width: 1000, height: 13000));

    final provider = LocalImage.provider(image.path);

    expect(provider, isA<MemoryImage>());
  });

  test('provider keeps safe local images as file-backed providers', () {
    final image = File('${tempDir.path}/safe.png');
    image.writeAsBytesSync(_pngHeader(width: 320, height: 240));

    final provider = LocalImage.provider(image.path);

    expect(provider, isA<FileImage>());
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
