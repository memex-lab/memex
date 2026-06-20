import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/whisper_service.dart';
import 'package:memex/domain/models/local_speech_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory testSupportDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    testSupportDir =
        await Directory.systemTemp.createTemp('memex_whisper_service_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      switch (call.method) {
        case 'getApplicationSupportDirectory':
          return testSupportDir.path;
        default:
          return null;
      }
    });
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await WhisperService.instance.deleteAllDownloadedModels();
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await testSupportDir.exists()) {
      await testSupportDir.delete(recursive: true);
    }
  });

  test('isModelDownloaded returns false for placeholder files', () async {
    final profile = LocalSpeechModelProfile.whisperSmall;
    final modelDir = Directory('${testSupportDir.path}/${profile.dirName}');
    await modelDir.create(recursive: true);
    for (final name in profile.requiredFileNames) {
      await File('${modelDir.path}/$name').writeAsBytes([1, 2, 3]);
    }

    await UserStorage.setLocalSpeechModel(LocalSpeechModelId.whisperSmall);
    expect(await WhisperService.instance.isModelDownloaded(), isFalse);
  });

  test('isModelDownloaded returns true when required files are present', () async {
    final profile = LocalSpeechModelProfile.whisperSmall;
    final modelDir = Directory('${testSupportDir.path}/${profile.dirName}');
    await modelDir.create(recursive: true);
    for (final name in profile.requiredFileNames) {
      final bytes = name.endsWith('.txt') ? 200 : 200000;
      await File('${modelDir.path}/$name')
          .writeAsBytes(List.filled(bytes, 1));
    }

    await UserStorage.setLocalSpeechModel(LocalSpeechModelId.whisperSmall);
    expect(await WhisperService.instance.isModelDownloaded(), isTrue);
  });
}
