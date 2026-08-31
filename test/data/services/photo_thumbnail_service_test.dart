import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/photo_thumbnail_service.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  AssetEntity asset(String id) => AssetEntity(
        id: id,
        typeInt: AssetType.image.index,
        width: 100,
        height: 100,
      );

  test('uses a cancellable single-result iOS delivery mode', () {
    final option = buildPhotoThumbnailOption(
      const ThumbnailSize.square(200),
      isApplePlatform: true,
    );

    expect(
      option.toMap()['deliveryMode'],
      DeliveryMode.highQualityFormat.index,
    );
    expect(option.toMap()['resizeMode'], ResizeMode.fast.index);
    expect(
      option.toMap()['resizeContentMode'],
      ResizeContentMode.fill.index,
    );
  });

  test('preheats only newly published Apple picker assets', () async {
    final calls = <({List<String> ids, ThumbnailOption option})>[];
    final preheater = PhotoThumbnailPreheater.forTesting(
      preloader: (assets, option) async {
        calls.add(
            (ids: assets.map((asset) => asset.id).toList(), option: option));
      },
    );

    await preheater.preheat([asset('first'), asset('second')]);
    await preheater.preheat([asset('second'), asset('third')]);

    expect(calls.map((call) => call.ids), [
      ['first', 'second'],
      ['third'],
    ]);
    expect(
      calls.first.option.toMap()['deliveryMode'],
      DeliveryMode.opportunistic.index,
    );
  });

  test('bounds concurrent native thumbnail requests', () async {
    final completers = <String, Completer<Uint8List?>>{};
    var active = 0;
    var maxActive = 0;
    final service = PhotoThumbnailService.forTesting(
      maxConcurrent: 2,
      loader: (asset, _, __) {
        active += 1;
        if (active > maxActive) maxActive = active;
        final completer = Completer<Uint8List?>();
        completers[asset.id] = completer;
        return completer.future.whenComplete(() => active -= 1);
      },
    );

    final first = service.request(asset('first'));
    final second = service.request(asset('second'));
    final third = service.request(asset('third'));
    await Future<void>.delayed(Duration.zero);

    expect(completers.keys, containsAll(['first', 'second']));
    expect(completers, isNot(contains('third')));
    expect(maxActive, 2);

    completers['first']!.complete(Uint8List.fromList([1]));
    await Future<void>.delayed(Duration.zero);
    expect(completers, contains('third'));

    completers['second']!.complete(Uint8List.fromList([2]));
    completers['third']!.complete(Uint8List.fromList([3]));
    expect(await first.future, [1]);
    expect(await second.future, [2]);
    expect(await third.future, [3]);
  });

  test('shares requests and cancels native work after the last release',
      () async {
    final completer = Completer<Uint8List?>();
    var loadCount = 0;
    var cancelCount = 0;
    final service = PhotoThumbnailService.forTesting(
      loader: (_, __, ___) {
        loadCount += 1;
        return completer.future;
      },
      canceller: (_) async => cancelCount += 1,
    );

    final first = service.request(asset('shared'));
    final second = service.request(asset('shared'));
    await Future<void>.delayed(Duration.zero);
    expect(loadCount, 1);

    first.cancel();
    expect(cancelCount, 0);
    second.cancel();
    await Future<void>.delayed(Duration.zero);
    expect(cancelCount, 1);
    expect(await second.future, isNull);

    completer.complete(null);
    await Future<void>.delayed(Duration.zero);
  });

  test('removes cancelled queued work before it reaches the loader', () async {
    final blocker = Completer<Uint8List?>();
    final loadedIds = <String>[];
    final service = PhotoThumbnailService.forTesting(
      maxConcurrent: 1,
      loader: (asset, _, __) {
        loadedIds.add(asset.id);
        return asset.id == 'active'
            ? blocker.future
            : Future.value(Uint8List.fromList([1]));
      },
    );

    final active = service.request(asset('active'));
    final queued = service.request(asset('queued'));
    queued.cancel();
    await Future<void>.delayed(Duration.zero);
    expect(await queued.future, isNull);

    blocker.complete(Uint8List.fromList([1]));
    await active.future;
    await Future<void>.delayed(Duration.zero);
    expect(loadedIds, ['active']);
  });

  test('serves successful thumbnail bytes from the LRU cache', () async {
    var loadCount = 0;
    final service = PhotoThumbnailService.forTesting(
      loader: (_, __, ___) async {
        loadCount += 1;
        return Uint8List.fromList([7]);
      },
    );

    expect(await service.request(asset('cached')).future, [7]);
    expect(await service.request(asset('cached')).future, [7]);
    expect(loadCount, 1);
  });
}
