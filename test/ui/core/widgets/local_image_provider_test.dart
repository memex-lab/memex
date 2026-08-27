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
    final previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = previousHttpOverrides);

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final requestReceived = Completer<void>();
    server.listen((request) {
      // Accept the request but never send headers or a body.
      requestReceived.complete();
    });

    final provider = LocalImage.provider(
      'http://${server.address.host}:${server.port}/hang.png',
      timeout: const Duration(milliseconds: 50),
    );

    expect(provider, isNot(isA<NetworkImage>()));

    final errorFuture = _resolveImageError(provider);
    await requestReceived.future.timeout(const Duration(seconds: 1));
    final error = await errorFuture.timeout(
      const Duration(seconds: 1),
    );

    expect(error, isA<TimeoutException>());
  });

  test('provider applies one timeout across response stages', () async {
    final previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = previousHttpOverrides);

    const timeout = Duration(milliseconds: 200);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      request.response.contentLength = 2;
      request.response.add(const [0x89]);
      await request.response.flush();
      // Send enough data to start the body phase, then leave it incomplete.
    });

    final provider = LocalImage.provider(
      'http://${server.address.host}:${server.port}/slow.png',
      timeout: timeout,
    );
    final stopwatch = Stopwatch()..start();
    final error = await _resolveImageError(provider).timeout(
      const Duration(seconds: 1),
    );

    expect(error, isA<TimeoutException>());
    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 300)));
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
