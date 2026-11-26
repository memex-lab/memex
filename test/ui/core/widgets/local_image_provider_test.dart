import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      timeout: const Duration(seconds: 3),
    );

    final errorFuture = _resolveImageError(provider);
    await requestReceived.future.timeout(const Duration(seconds: 15));
    final error = await errorFuture.timeout(
      const Duration(seconds: 15),
    );

    expect(error, isA<TimeoutException>());
  });

  test('provider applies one timeout across response stages', () async {
    final previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = previousHttpOverrides);

    const timeout = Duration(seconds: 3);
    const headerDelay = Duration(milliseconds: 400);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      await Future<void>.delayed(headerDelay);
      request.response.bufferOutput = false;
      request.response.contentLength = 2;
      request.response.add(const [0x89]);
      await request.response.flush();
      // Send enough data to start the body phase, then leave it incomplete.
    });

    final provider = LocalImage.provider(
      'http://${server.address.host}:${server.port}/slow.png',
      timeout: timeout,
    );
    var receivedBytes = 0;
    final error = await _resolveImageError(provider,
            onChunk: (event) => receivedBytes = event.cumulativeBytesLoaded)
        .timeout(const Duration(seconds: 15));

    expect(receivedBytes, 1, reason: 'download reached the stalled body');
    expect(error, isA<TimeoutException>());
    // The body timeout must use the budget left after waiting for headers.
    // Compare the scheduled duration, independent of event-loop latency.
    expect((error as TimeoutException).duration,
        lessThanOrEqualTo(timeout - headerDelay));
  });
}

Future<Object> _resolveImageError(ImageProvider provider,
    {ImageChunkListener? onChunk}) {
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
    onChunk: onChunk,
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
