import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memex/data/services/transcription_isolate.dart';
import 'package:memex/data/services/whisper_service.dart';
import 'package:memex/domain/models/local_speech.dart';
import 'package:memex/domain/models/vocal_tone.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AppDirs extends PathProviderPlatform {
  _AppDirs(this.root);
  final Directory root;

  @override
  Future<String?> getApplicationSupportPath() async => root.path;
}

class _DelayedRecognizer extends TranscriptionIsolate {
  final started = Completer<void>();
  final loaded = Completer<void>();

  @override
  bool get isReady => loaded.isCompleted;

  @override
  Future<void> start({
    required String modelPath,
    required String tokensPath,
    String provider = 'cpu',
    String engine = LocalSpeechEngines.senseVoice,
    String language = 'auto',
    String? decoderPath,
  }) async {
    started.complete();
    await loaded.future;
  }

  @override
  Future<LocalRecognition?> transcribeDetailed(Float32List samples) async =>
      LocalRecognition(text: samples.single.toString());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late Directory model;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('whisper-test-');
    model = Directory('${root.path}/${WhisperTinyPackage.dirName}');
    final previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _AppDirs(root);
    SharedPreferences.setMockInitialValues({
      'local_speech_engine': LocalSpeechEngines.whisperTiny,
      'local_speech_language': 'de',
    });
    addTearDown(() async {
      PathProviderPlatform.instance = previous;
      await root.delete(recursive: true);
    });
  });

  test('mirror error leaves an incomplete installation retryable', () async {
    final service = WhisperService.instance;
    Future<void> download(http.Client Function() client) => http.runWithClient(
          () =>
              service.downloadModel(useChineseMirror: true, onProgress: (_) {}),
          client,
        );

    var requests = 0;
    await expectLater(
      download(() => MockClient((_) async {
            requests++;
            return http.Response('Service unavailable', 503);
          })),
      throwsA(isA<HttpException>()),
    );
    expect(requests, 1);
    expect(await service.isModelDownloaded(), isFalse);
    expect(root.listSync(), isEmpty);

    // Old versions also left HTTP error bodies under all three final names.
    await model.create();
    for (final name in WhisperTinyPackage.fileSizes.keys) {
      await File('${model.path}/$name').writeAsString('Service unavailable');
    }
    expect(await service.isModelDownloaded(), isFalse);
    await expectLater(
      download(() => MockClient((_) async => http.Response('truncated', 200))),
      throwsFormatException,
    );
    expect(await service.isModelDownloaded(), isFalse);

    // Stream synthetic files of the advertised lengths with bounded memory.
    final chunk = Uint8List(64 * 1024);
    Stream<List<int>> payload(int size) async* {
      while (size >= chunk.length) {
        yield chunk;
        size -= chunk.length;
      }
      if (size > 0) yield Uint8List.sublistView(chunk, 0, size);
    }

    await download(() => MockClient.streaming((request, _) async {
          expect(await service.isModelDownloaded(), isFalse);
          final size =
              WhisperTinyPackage.fileSizes[request.url.pathSegments.last]!;
          return http.StreamedResponse(payload(size), 200, contentLength: size);
        }));
    expect(await service.isModelDownloaded(), isTrue);
    expect(root.listSync().map((entry) => entry.path), [model.path]);
  });

  test('overlapping cold transcriptions share startup and return both results',
      () async {
    await model.create();
    for (final entry in WhisperTinyPackage.fileSizes.entries) {
      final file =
          await File('${model.path}/${entry.key}').open(mode: FileMode.write);
      await file.truncate(entry.value);
      await file.close();
    }
    final recognizer = _DelayedRecognizer();
    var instances = 0;
    final service = WhisperService.withIsolateFactory(() {
      instances++;
      return recognizer;
    });
    addTearDown(service.dispose);

    final first = service.transcribeSamples(Float32List.fromList([1]));
    await recognizer.started.future;
    final second = service.transcribeSamplesDetailed(Float32List.fromList([2]));
    await pumpEventQueue();
    expect(instances, 1);
    recognizer.loaded.complete();

    expect(await first, '1.0');
    expect((await second)?.text, '2.0');
  });
}
