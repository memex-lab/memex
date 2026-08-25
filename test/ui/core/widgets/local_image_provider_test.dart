import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('provider does not use NetworkImage for remote URLs', () {
    final provider = LocalImage.provider('https://example.invalid/x.png');

    expect(provider, isNot(isA<NetworkImage>()));
  });

  test('provider reports an error instead of hanging on a stalled download',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) {
      // Accept the request but never send headers or a body.
    });

    final provider = LocalImage.provider(
      'http://${server.address.host}:${server.port}/hang.png',
      timeout: const Duration(milliseconds: 50),
    );

    expect(provider, isNot(isA<NetworkImage>()));

    final error = await _resolveImageError(provider).timeout(
      const Duration(seconds: 1),
    );

    expect(error, isNotNull);
  });
}

Future<Object> _resolveImageError(ImageProvider provider) {
  final completer = Completer<Object>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (ImageInfo image, bool synchronousCall) {
      image.dispose();
      if (!completer.isCompleted) {
        completer.completeError(StateError('image loaded unexpectedly'));
      }
    },
    onError: (Object error, StackTrace? stackTrace) {
      if (!completer.isCompleted) {
        completer.complete(error);
      }
    },
  );
  stream.addListener(listener);
  return completer.future.whenComplete(() {
    stream.removeListener(listener);
  });
}
