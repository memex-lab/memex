import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/data/services/image_preview_cache_service.dart';
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
            child: LocalImage(
                url: image.path,
                fit: BoxFit.cover,
                previewCacheService: ImagePreviewCacheService(
                    tempDirectoryProvider: () async => tempDir)),
          ),
        ),
      );

      await _pumpUntil(
          tester,
          () => find
              .byIcon(Icons.image_not_supported_outlined)
              .evaluate()
              .isNotEmpty);

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  test('preview source config allows high-pixel phone photos only', () {
    final phonePhoto = File('${tempDir.path}/phone_photo.png');
    phonePhoto.writeAsBytesSync(_pngHeader(width: 4217, height: 6325));

    final defaultReport =
        AssetSafetyService.instance.inspectFileSync(phonePhoto.path);
    final previewSourceReport = AssetSafetyService.instance.inspectFileSync(
      phonePhoto.path,
      config: LocalImage.previewSourceSafetyConfig,
    );

    expect(defaultReport.safeForPreview, isFalse);
    expect(defaultReport.reason, contains('pixel count'));
    expect(previewSourceReport.safeForPreview, isTrue);

    final extremeLong = File('${tempDir.path}/extreme_long.png');
    extremeLong.writeAsBytesSync(_pngHeader(width: 1000, height: 13000));
    final longReport = AssetSafetyService.instance.inspectFileSync(
      extremeLong.path,
      config: LocalImage.previewSourceSafetyConfig,
    );

    expect(longReport.safeForPreview, isFalse);
    expect(longReport.reason, contains('long edge'));
  });

  testWidgets(
    'shows a safe placeholder for unsafe downloaded network images',
    (tester) async {
      final service = ImagePreviewCacheService(
          tempDirectoryProvider: () async => tempDir,
          networkImageFetcher: (_) async => http.Response.bytes(
              _pngHeader(width: 1000, height: 13000), 200,
              headers: {'content-type': 'image/png'}));
      await tester.pumpWidget(MaterialApp(
          home: SizedBox(
              width: 160,
              height: 120,
              child: LocalImage(
                  url: 'https://example.test/long.png',
                  previewCacheService: service,
                  fit: BoxFit.cover))));
      await _pumpUntil(
          tester,
          () => find
              .byIcon(Icons.image_not_supported_outlined)
              .evaluate()
              .isNotEmpty);

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  test('provider resolves unsafe local images to a transparent placeholder',
      () async {
    final image = File('${tempDir.path}/long.png');
    image.writeAsBytesSync(_pngHeader(width: 1000, height: 13000));
    final info = await _resolve(LocalImage.provider(image.path));
    addTearDown(info.dispose);
    expect(info.image.width, 1);
    expect(info.image.height, 1);
    final pixels = await info.image.toByteData();
    expect(pixels!.getUint8(3), 0);
  });

  test('provider still decodes safe local image pixels', () async {
    final image = File('${tempDir.path}/safe.png');
    image.writeAsBytesSync(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='));
    final info = await _resolve(LocalImage.provider(image.path));
    addTearDown(info.dispose);
    expect(info.image.width, 1);
    final pixels = await info.image.toByteData();
    expect(pixels!.getUint8(3), greaterThan(0));
  });

  testWidgets('late failure from a recycled image cannot replace the new image',
      (tester) async {
    final oldFile = File('${tempDir.path}/old.png');
    oldFile.writeAsBytesSync(_pngHeader(width: 1000, height: 13000));
    final newFile = File('${tempDir.path}/new.png');
    newFile.writeAsBytesSync(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='));
    final inspection = Completer<AssetSafetyReport>();
    final started = Completer<void>();
    final service = ImagePreviewCacheService(
        tempDirectoryProvider: () async => tempDir,
        safetyInspector: (file, {required config}) {
          if (file == oldFile.path) {
            if (!started.isCompleted) started.complete();
            return inspection.future;
          }
          return AssetSafetyService.instance.inspectFile(file, config: config);
        });
    Widget page(String source) => MaterialApp(
        home: SizedBox(
            width: 160,
            height: 120,
            child: LocalImage(
                key: const ValueKey('recycled'),
                url: source,
                previewCacheService: service)));
    await tester.pumpWidget(page(oldFile.path));
    await _pumpUntil(tester, () => started.isCompleted);
    var oldFinished = false;
    unawaited(service
        .getOrCreatePreview(source: oldFile.path, isLocalFile: true)
        .then<void>((_) => oldFinished = true,
            onError: (Object _, StackTrace __) {
      oldFinished = true;
    }));
    await tester.pumpWidget(page(newFile.path));
    await _pumpUntil(tester, () => find.byType(Image).evaluate().isNotEmpty);
    final displayed = tester.widget<Image>(find.byType(Image)).image;
    inspection
        .complete(AssetSafetyService.instance.inspectFileSync(oldFile.path));
    await _pumpUntil(tester, () => oldFinished);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsNothing);
    expect(tester.widget<Image>(find.byType(Image)).image, displayed);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('slow source inspection leaves the page interactive',
      (tester) async {
    final image = File('${tempDir.path}/photo.png');
    image.writeAsBytesSync(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='));
    final inspection = Completer<AssetSafetyReport>();
    final started = Completer<void>();
    final service = ImagePreviewCacheService(
        tempDirectoryProvider: () async => tempDir,
        safetyInspector: (file, {required config}) {
          if (file == image.path) {
            if (!started.isCompleted) started.complete();
            return inspection.future;
          }
          return AssetSafetyService.instance.inspectFile(file, config: config);
        });
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
                    body: Column(children: [
                  SizedBox(
                      width: 160,
                      height: 120,
                      child: LocalImage(
                          url: image.path, previewCacheService: service)),
                  TextButton(
                      onPressed: () => setState(() => taps++),
                      child: Text('taps $taps')),
                ])))));
    await _pumpUntil(tester, () => started.isCompleted);
    expect(started.isCompleted, isTrue);
    await tester.tap(find.text('taps 0'));
    await tester.pump();
    expect(find.text('taps 1'), findsOneWidget);
    expect(inspection.isCompleted, isFalse);
    inspection
        .complete(AssetSafetyService.instance.inspectFileSync(image.path));
    await _pumpUntil(tester, () => find.byType(Image).evaluate().isNotEmpty);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('taps 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
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

Future<ImageInfo> _resolve(ImageProvider provider) {
  final result = Completer<ImageInfo>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late ImageStreamListener listener;
  listener = ImageStreamListener((info, _) {
    if (!result.isCompleted) result.complete(info);
  }, onError: (Object error, StackTrace? stack) {
    if (!result.isCompleted) result.completeError(error, stack);
  });
  stream.addListener(listener);
  return result.future.whenComplete(() => stream.removeListener(listener));
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() done) async {
  for (var attempt = 0; attempt < 100 && !done(); attempt++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
  }
  expect(done(), isTrue,
      reason: 'Asynchronous image load did not reach its expected state');
}
