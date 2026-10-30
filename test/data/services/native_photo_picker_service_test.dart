import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/native_photo_picker_service.dart';
import 'package:memex/domain/models/native_photo_selection.dart';
import 'package:memex/ui/chat/view_models/photo_attachments_viewmodel.dart';
import 'package:memex/utils/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(
      NativePhotoPickerService.channel, null));

  test('returns ordered selections including photos outside library permission',
      () async {
    messenger.setMockMethodCallHandler(NativePhotoPickerService.channel,
        (call) async {
      expect(call.method, 'pickImages');
      expect(call.arguments['maxAssets'], 9);
      return [
        {'id': 'first', 'assetId': 'library-id'},
        {'id': 'limited'}
      ];
    });
    final photos = (await NativePhotoPickerService.pick()).valueOrThrow;
    expect(photos.map((photo) => photo.id), ['first', 'limited']);
    expect(photos.last.assetId, isNull);
  });

  test('cancelling leaves selection empty', () async {
    messenger.setMockMethodCallHandler(
        NativePhotoPickerService.channel, (_) async => []);
    expect((await NativePhotoPickerService.pick()).valueOrThrow, isEmpty);
  });

  test('preview is available while export waits; failed export can retry',
      () async {
    final export = Completer<Map<String, Object>>();
    var attempts = 0;
    final released = <String>[];
    messenger.setMockMethodCallHandler(NativePhotoPickerService.channel,
        (call) async {
      switch (call.method) {
        case 'thumbnail':
          return Uint8List.fromList([1, 2, 3]);
        case 'prepareOriginal':
          attempts++;
          if (attempts == 1) return export.future;
          return {
            'path': '/tmp/original.HEIC',
            'originalName': 'IMG_0123.HEIC'
          };
        case 'release':
          released.add(call.arguments['id'] as String);
          return null;
      }
      throw StateError('Unexpected ${call.method}');
    });
    final vm = PhotoAttachmentsViewModel.forTesting(
        loader: (_) async =>
            throw StateError('Must not request a PhotoKit asset'));
    vm.addNativePhotos([const NativePhotoSelection(id: 'limited')]);
    await Future<void>.delayed(Duration.zero);
    expect(vm.items.single.preview, [1, 2, 3]);
    expect(vm.canSubmit, isFalse);
    export.completeError(PlatformException(code: 'offline'));
    await Future<void>.delayed(Duration.zero);
    expect(vm.items.single.failed, isTrue);
    vm.retry(vm.items.single);
    await Future<void>.delayed(Duration.zero);
    expect(vm.canSubmit, isTrue);
    expect(vm.items.single.prepared!.originalName, 'IMG_0123.HEIC');
    expect(vm.items.single.prepared!.path, '/tmp/original.HEIC');
    vm.clear();
    await Future<void>.delayed(Duration.zero);
    expect(released, ['limited']);
    vm.dispose();
  });

  test('deduplicates by library id and ignores removed late exports', () async {
    final export = Completer<Map<String, Object>>();
    final released = <String>[];
    messenger.setMockMethodCallHandler(NativePhotoPickerService.channel,
        (call) async {
      switch (call.method) {
        case 'thumbnail':
          return null;
        case 'prepareOriginal':
          return export.future;
        case 'release':
          released.add(call.arguments['id'] as String);
          return null;
      }
      return null;
    });
    final vm = PhotoAttachmentsViewModel.forTesting(
        loader: (_) async => throw StateError('Unexpected library export'));
    vm.addNativePhotos([
      const NativePhotoSelection(id: 'a', assetId: 'same'),
      const NativePhotoSelection(id: 'b', assetId: 'same'),
    ]);
    expect(vm.items, hasLength(1));
    vm.remove(vm.items.single);
    export.complete(
        {'path': '/tmp/original.heic', 'originalName': 'original.heic'});
    await Future<void>.delayed(Duration.zero);
    expect(vm.items, isEmpty);
    expect(released, containsAll(['a', 'b']));
    vm.dispose();
  });
}
