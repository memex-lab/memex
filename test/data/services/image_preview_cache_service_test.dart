import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:memex/data/services/image_preview_cache_service.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('memex_preview_cache_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('copies small images into the shared max768 cache path', () async {
    final image = File('${tempDir.path}/small.png');
    image.writeAsBytesSync(_pngHeader(width: 320, height: 240));

    var compressorCalled = false;
    final service = ImagePreviewCacheService(
      tempDirectoryProvider: () async => tempDir,
      compressor: ({
        required sourcePath,
        required targetPath,
        required maxWidth,
        required maxHeight,
        required quality,
      }) async {
        compressorCalled = true;
        return null;
      },
    );

    final preview = await service.getOrCreatePreview(
      source: image.path,
      isLocalFile: true,
    );
    final cachedAgain = await service.getOrCreatePreview(
      source: image.path,
      isLocalFile: true,
    );

    expect(compressorCalled, isFalse);
    expect(
        preview.file.path, endsWith(ImagePreviewCacheService.cacheFileSuffix));
    expect(preview.file.path, cachedAgain.file.path);
    expect(preview.contentType, 'image/png');
    expect(cachedAgain.cacheHit, isTrue);
  });

  test('compresses large images into the shared max768 cache path', () async {
    final image = File('${tempDir.path}/large.png');
    image.writeAsBytesSync(_pngHeader(width: 1200, height: 900));

    var compressorCalls = 0;
    final service = ImagePreviewCacheService(
      tempDirectoryProvider: () async => tempDir,
      compressor: ({
        required sourcePath,
        required targetPath,
        required maxWidth,
        required maxHeight,
        required quality,
      }) async {
        compressorCalls++;
        expect(sourcePath, image.path);
        expect(maxWidth, ImagePreviewCacheService.maxPreviewSide);
        expect(maxHeight, ImagePreviewCacheService.maxPreviewSide);
        expect(quality, ImagePreviewCacheService.previewQuality);
        await File(targetPath).writeAsBytes(_jpegHeader());
        return targetPath;
      },
    );

    final preview = await service.getOrCreatePreview(
      source: image.path,
      isLocalFile: true,
    );
    final cachedAgain = await service.getOrCreatePreview(
      source: image.path,
      isLocalFile: true,
    );

    expect(compressorCalls, 1);
    expect(
        preview.file.path, endsWith(ImagePreviewCacheService.cacheFileSuffix));
    expect(preview.file.path, cachedAgain.file.path);
    expect(preview.contentType, 'image/jpeg');
    expect(cachedAgain.cacheHit, isTrue);
  });

  test(
      'a slow download does not block a local preview and duplicate work is shared',
      () async {
    final download = Completer<http.Response>();
    var downloads = 0;
    final service = ImagePreviewCacheService(
      tempDirectoryProvider: () async => tempDir,
      networkImageFetcher: (_) {
        downloads++;
        return download.future;
      },
    );
    final remote = service.getOrCreatePreview(
        source: 'https://example.test/photo.png', isLocalFile: false);
    final duplicate = service.getOrCreatePreview(
        source: 'https://example.test/photo.png', isLocalFile: false);
    expect(identical(remote, duplicate), isTrue);
    final local = File('${tempDir.path}/local.png');
    await local.writeAsBytes(_pngHeader(width: 100, height: 100));
    final localPreview =
        await service.getOrCreatePreview(source: local.path, isLocalFile: true);
    expect(localPreview.file.existsSync(), isTrue);
    expect(downloads, 1);
    download.complete(http.Response.bytes(
        _pngHeader(width: 100, height: 100), 200,
        headers: {'content-type': 'image/png'}));
    expect((await remote).file.existsSync(), isTrue);
  });

  test('clear waits for active work and new readers regenerate after clearing',
      () async {
    final image = File('${tempDir.path}/active.png');
    await image.writeAsBytes(_pngHeader(width: 1200, height: 900));
    final started = Completer<void>();
    final finish = Completer<void>();
    var compressions = 0;
    final service = ImagePreviewCacheService(
      tempDirectoryProvider: () async => tempDir,
      compressor: (
          {required sourcePath,
          required targetPath,
          required maxWidth,
          required maxHeight,
          required quality}) async {
        compressions++;
        if (compressions == 1) {
          started.complete();
          await finish.future;
        }
        await File(targetPath).writeAsBytes(_jpegHeader());
        return targetPath;
      },
    );
    final old =
        service.getOrCreatePreview(source: image.path, isLocalFile: true);
    await started.future;
    final clearing = service.clear();
    final fresh =
        service.getOrCreatePreview(source: image.path, isLocalFile: true);
    finish.complete();
    await old;
    await clearing;
    expect((await fresh).cacheHit, isFalse);
    expect(compressions, 2);
  });

  test('cached previews bypass busy workers and new generation stays bounded',
      () async {
    final gates = <String, Completer<void>>{};
    final bothStarted = Completer<void>();
    final thirdStarted = Completer<void>();
    var active = 0;
    var maxActive = 0;
    final service = ImagePreviewCacheService(
      tempDirectoryProvider: () async => tempDir,
      compressor: (
          {required sourcePath,
          required targetPath,
          required maxWidth,
          required maxHeight,
          required quality}) async {
        active++;
        if (active > maxActive) maxActive = active;
        final gate = Completer<void>();
        gates[sourcePath] = gate;
        if (gates.length == 2) bothStarted.complete();
        if (gates.length == 3) thirdStarted.complete();
        await gate.future;
        await File(targetPath).writeAsBytes(_jpegHeader());
        active--;
        return targetPath;
      },
    );
    final small = File('${tempDir.path}/ready.png');
    await small.writeAsBytes(_pngHeader(width: 100, height: 100));
    await service.getOrCreatePreview(source: small.path, isLocalFile: true);
    final jobs = <Future<ImagePreviewFile>>[];
    for (var i = 0; i < 3; i++) {
      final file = File('${tempDir.path}/large_$i.png');
      await file.writeAsBytes(_pngHeader(width: 1200, height: 900));
      jobs.add(
          service.getOrCreatePreview(source: file.path, isLocalFile: true));
    }
    await bothStarted.future;
    expect(gates.length, 2);
    expect(
        (await service.getOrCreatePreview(
                source: small.path, isLocalFile: true))
            .cacheHit,
        isTrue);
    gates.values.first.complete();
    await thirdStarted.future;
    for (final gate in gates.values) {
      if (!gate.isCompleted) gate.complete();
    }
    await Future.wait(jobs);
    expect(maxActive, 2);
  });

  test('a failed clear does not poison later preview requests', () async {
    var failDirectoryLookup = false;
    final service = ImagePreviewCacheService(tempDirectoryProvider: () async {
      if (failDirectoryLookup) throw const FileSystemException('unavailable');
      return tempDir;
    });
    failDirectoryLookup = true;
    await expectLater(service.clear(), throwsA(isA<FileSystemException>()));
    failDirectoryLookup = false;
    final image = File('${tempDir.path}/after_failed_clear.png');
    await image.writeAsBytes(_pngHeader(width: 100, height: 100));
    expect(
        (await service.getOrCreatePreview(
                source: image.path, isLocalFile: true))
            .file
            .existsSync(),
        isTrue);
  });

  test('clear removes every generated preview', () async {
    final image = File('${tempDir.path}/cached.png');
    await image.writeAsBytes(_pngHeader(width: 320, height: 240));
    final service = ImagePreviewCacheService(
      tempDirectoryProvider: () async => tempDir,
    );
    final preview = await service.getOrCreatePreview(
      source: image.path,
      isLocalFile: true,
    );

    await service.clear();

    expect(await preview.file.exists(), isFalse);
    expect(
      await Directory(
        '${tempDir.path}/${ImagePreviewCacheService.cacheDirectoryName}',
      ).exists(),
      isFalse,
    );

    final regenerated = await service.getOrCreatePreview(
      source: image.path,
      isLocalFile: true,
    );
    expect(regenerated.cacheHit, isFalse);
    expect(await regenerated.file.exists(), isTrue);
  });

  test('uses response content type for extensionless network images', () async {
    String? downloadedPath;
    final service = ImagePreviewCacheService(
      tempDirectoryProvider: () async => tempDir,
      networkImageFetcher: (uri) async {
        expect(uri.toString(), 'https://picsum.photos/300/300?random=10');
        return http.Response.bytes(
          _jpegHeader(),
          200,
          headers: {'content-type': 'image/jpeg; charset=binary'},
        );
      },
      compressor: ({
        required sourcePath,
        required targetPath,
        required maxWidth,
        required maxHeight,
        required quality,
      }) async {
        downloadedPath = sourcePath;
        await File(targetPath).writeAsBytes(_jpegHeader());
        return targetPath;
      },
    );

    final preview = await service.getOrCreatePreview(
      source: 'https://picsum.photos/300/300?random=10',
      isLocalFile: false,
    );

    expect(downloadedPath, endsWith('.jpg'));
    expect(preview.contentType, 'image/jpeg');
    expect(preview.file.existsSync(), isTrue);
    expect(File(downloadedPath!).existsSync(), isFalse);
  });

  test('rejects extensionless network responses without an image MIME type',
      () async {
    final service = ImagePreviewCacheService(
      tempDirectoryProvider: () async => tempDir,
      networkImageFetcher: (_) async => http.Response.bytes(
        _jpegHeader(),
        200,
        headers: {'content-type': 'application/octet-stream'},
      ),
    );

    expect(
      () => service.getOrCreatePreview(
        source: 'https://example.test/image',
        isLocalFile: false,
      ),
      throwsA(
        isA<ImagePreviewUnavailable>().having(
          (error) => error.reason,
          'reason',
          'unsupported network image type',
        ),
      ),
    );
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

List<int> _jpegHeader() => const [0xff, 0xd8, 0xff, 0xd9];

void _writeUint32Be(Uint8List bytes, int offset, int value) {
  bytes[offset] = (value >> 24) & 0xff;
  bytes[offset + 1] = (value >> 16) & 0xff;
  bytes[offset + 2] = (value >> 8) & 0xff;
  bytes[offset + 3] = value & 0xff;
}
