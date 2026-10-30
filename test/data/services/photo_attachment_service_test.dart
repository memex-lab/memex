import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/photo_attachment_service.dart';
import 'package:memex/utils/result.dart';
import '../../helpers/fake_photo_asset.dart';

void main() {
  test('shares a pending original export and retains its original filename',
      () async {
    final original = Completer<File?>();
    var exports = 0;
    final service = PhotoAttachmentService.forTesting(
        assetLoader: (id) async => FakePhotoAsset(
            id: id,
            fileLoader: (isOrigin) {
              exports++;
              expect(isOrigin, isTrue);
              return original.future;
            },
            titleLoader: () async => 'IMG_001.HEIC'));
    final first = service.prepareAsset('shared');
    final second = service.prepareAsset('shared');
    expect(identical(first, second), isTrue);
    original.complete(File('/tmp/exported.heic'));
    final result = (await first).valueOrThrow;
    expect(exports, 1);
    expect(result.path, '/tmp/exported.heic');
    expect(result.originalName, 'IMG_001.HEIC');
  });

  test('preserves fallback file behavior and handles missing filename metadata',
      () async {
    final requests = <bool>[];
    final service = PhotoAttachmentService.forTesting(
        assetLoader: (id) async => FakePhotoAsset(
            id: id,
            fileLoader: (isOrigin) async {
              requests.add(isOrigin);
              return isOrigin ? null : File('/tmp/fallback.jpg');
            },
            titleLoader: () async =>
                throw PlatformException(code: 'unavailable')));
    final result = (await service.prepareAsset('fallback')).valueOrThrow;
    expect(requests, [true, false]);
    expect(result.path, '/tmp/fallback.jpg');
    expect(result.originalName, 'fallback.jpg');
  });

  test(
      'a removed system photo returns an error instead of a thumbnail attachment',
      () async {
    final service =
        PhotoAttachmentService.forTesting(assetLoader: (_) async => null);
    expect((await service.prepareAsset('missing')).isError, isTrue);
  });
}
