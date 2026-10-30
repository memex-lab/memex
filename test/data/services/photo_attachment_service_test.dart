import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/photo_attachment_service.dart';
import 'package:memex/utils/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.fluttercandies/photo_manager');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('shares a pending original export and retains its original filename',
      () async {
    final original = Completer<String>();
    var exports = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'fetchEntityProperties':
          return {'id': 'shared', 'type': 1, 'width': 100, 'height': 100};
        case 'getFullFile':
          exports++;
          expect(call.arguments['isOrigin'], isTrue);
          return original.future;
        case 'getTitleAsync':
          return 'IMG_001.HEIC';
      }
      return null;
    });
    final first = PhotoAttachmentService.prepare('shared');
    final second = PhotoAttachmentService.prepare('shared');
    expect(identical(first, second), isTrue);
    original.complete('/tmp/exported.heic');
    final result = (await first).valueOrThrow;
    expect(exports, 1);
    expect(result.path, '/tmp/exported.heic');
    expect(result.originalName, 'IMG_001.HEIC');
  });

  test('preserves fallback file behavior and handles missing filename metadata',
      () async {
    final requests = <bool>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'fetchEntityProperties':
          return {'id': 'fallback', 'type': 1, 'width': 100, 'height': 100};
        case 'getFullFile':
          final origin = call.arguments['isOrigin'] as bool;
          requests.add(origin);
          return origin ? null : '/tmp/fallback.jpg';
        case 'getTitleAsync':
          throw PlatformException(code: 'unavailable');
      }
      return null;
    });
    final result =
        (await PhotoAttachmentService.prepare('fallback')).valueOrThrow;
    expect(requests, [true, false]);
    expect(result.path, '/tmp/fallback.jpg');
    expect(result.originalName, 'fallback.jpg');
  });

  test(
      'a removed system photo returns an error instead of a thumbnail attachment',
      () async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    expect((await PhotoAttachmentService.prepare('missing')).isError, isTrue);
  });
}
