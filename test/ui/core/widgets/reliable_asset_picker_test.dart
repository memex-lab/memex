import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/photo_thumbnail_service.dart';
import 'package:memex/ui/core/widgets/reliable_asset_picker.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  testWidgets('shows loading, retries once, and offers a manual retry',
      (tester) async {
    var loadCount = 0;
    final png = Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
        'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
    );
    final service = PhotoThumbnailService.forTesting(
      loader: (_, __, ___) async {
        loadCount += 1;
        return loadCount < 3 ? null : png;
      },
    );
    final asset = AssetEntity(
      id: 'photo-1',
      typeInt: AssetType.image.index,
      width: 100,
      height: 100,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.square(
          dimension: 100,
          child: ReliableAssetThumbnail(asset: asset, service: service),
        ),
      ),
    );
    expect(find.byKey(reliableThumbnailLoadingKey), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 130));
    await tester.pump();
    expect(loadCount, 2);
    expect(find.byKey(reliableThumbnailFailureKey), findsOneWidget);

    await tester.tap(find.byKey(reliableThumbnailFailureKey));
    await tester.pumpAndSettle();
    expect(loadCount, 3);
    expect(find.byKey(reliableThumbnailImageKey), findsOneWidget);
  });

  testWidgets('cancels native work when a recycled grid cell is disposed',
      (tester) async {
    final loader = Completer<Uint8List?>();
    var cancelCount = 0;
    final service = PhotoThumbnailService.forTesting(
      loader: (_, __, ___) => loader.future,
      canceller: (_) async => cancelCount += 1,
    );
    final asset = AssetEntity(
      id: 'recycled-photo',
      typeInt: AssetType.image.index,
      width: 100,
      height: 100,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ReliableAssetThumbnail(asset: asset, service: service),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(cancelCount, 1);
    loader.complete(null);
    await tester.pump();
  });
}
