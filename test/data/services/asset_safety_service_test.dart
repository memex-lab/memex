import 'dart:io';
import 'dart:typed_data';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/submit_input.dart';
import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/data/services/media_service.dart';
import 'package:memex/data/services/photo_suggestion_service.dart';
import 'package:memex/data/services/speech_transcription_service.dart';
import 'package:memex/data/services/task_handlers/analyze_assets_handler.dart';
import 'package:memex/data/services/task_handlers/custom_agent_task_handler.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('memex_asset_safety_');
  });

  tearDown(() async {
    await LocalAssetServer.stopServer();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'reads safe image dimensions from headers without full decode',
    () async {
      final image = File('${tempDir.path}/safe.png');
      await image.writeAsBytes(_pngHeader(width: 800, height: 600));

      final report = await AssetSafetyService.instance.inspectFile(image.path);

      expect(report.type, AssetSafetyType.image);
      expect(report.width, 800);
      expect(report.height, 600);
      expect(report.safeForPreview, isTrue);
      expect(report.safeForAnalysis, isTrue);
      expect(report.safeForOcr, isTrue);
    },
  );

  test('marks long image unsafe while preserving metadata', () async {
    final image = File('${tempDir.path}/long.png');
    await image.writeAsBytes(_pngHeader(width: 1000, height: 13000));

    final report = await AssetSafetyService.instance.inspectFile(image.path);

    expect(report.width, 1000);
    expect(report.height, 13000);
    expect(report.safeForPreview, isFalse);
    expect(report.safeForAnalysis, isFalse);
    expect(report.safeForOcr, isFalse);
    expect(report.safeForInlineBase64, isFalse);
    expect(report.reason, contains('long edge'));
  });

  test('marks oversized audio unsafe for cloud transcription', () async {
    final audio = File('${tempDir.path}/audio_20260602_ts_1_no_1_301.m4a');
    await audio.create();
    await _resizeFile(audio, 21 * 1024 * 1024);

    final report = await AssetSafetyService.instance.inspectFile(audio.path);

    expect(report.type, AssetSafetyType.audio);
    expect(report.durationSeconds, 301);
    expect(report.safeForPreview, isTrue);
    expect(report.safeForAnalysis, isFalse);
    expect(report.safeForInlineBase64, isFalse);
    expect(report.reason, contains('file size'));
    expect(report.reason, contains('duration'));
  });

  test('keeps narrow safe image analyzable while skipping OCR only', () async {
    final image = File('${tempDir.path}/receipt_strip.png');
    await image.writeAsBytes(_pngHeader(width: 100, height: 1300));

    final report = await AssetSafetyService.instance.inspectFile(image.path);

    expect(report.safeForPreview, isTrue);
    expect(report.safeForAnalysis, isTrue);
    expect(report.safeForOcr, isFalse);
    expect(report.safeForInlineBase64, isTrue);
    expect(report.reason, contains('aspect ratio'));
  });

  test('blocks unknown large image from preview and analysis', () async {
    final image = File('${tempDir.path}/unknown_heic.heic');
    await image.create();
    await _resizeFile(image, 9 * 1024 * 1024);

    final report = await AssetSafetyService.instance.inspectFile(image.path);

    expect(report.type, AssetSafetyType.image);
    expect(report.width, isNull);
    expect(report.height, isNull);
    expect(report.safeForPreview, isFalse);
    expect(report.safeForAnalysis, isFalse);
    expect(report.safeForOcr, isFalse);
    expect(report.safeForInlineBase64, isFalse);
    expect(report.reason, contains('dimensions are unavailable'));
  });

  test('marks small audio safe for analysis and inline agent use', () async {
    final audio = File('${tempDir.path}/audio_20260602_ts_1_no_1_60.m4a');
    await audio.create();
    await _resizeFile(audio, 4 * 1024 * 1024);

    final report = await AssetSafetyService.instance.inspectFile(audio.path);

    expect(report.type, AssetSafetyType.audio);
    expect(report.durationSeconds, 60);
    expect(report.safeForAnalysis, isTrue);
    expect(report.safeForInlineBase64, isTrue);
    expect(report.reason, 'asset is within safety limits');
  });

  test('blocks audio with unknown duration from automatic analysis', () async {
    final audio = File('${tempDir.path}/shared_audio.m4a');
    await audio.create();
    await _resizeFile(audio, 4 * 1024 * 1024);

    final report = await AssetSafetyService.instance.inspectFile(audio.path);

    expect(report.type, AssetSafetyType.audio);
    expect(report.durationSeconds, isNull);
    expect(report.safeForAnalysis, isFalse);
    expect(report.safeForInlineBase64, isFalse);
    expect(report.reason, contains('duration is unavailable'));
  });

  test('cloud transcription skips unsafe audio before LLM lookup', () async {
    SharedPreferences.setMockInitialValues({
      'use_local_speech_to_text': false,
    });
    final audio = File('${tempDir.path}/audio_20260602_ts_1_no_1_301.m4a');
    await audio.create();
    await _resizeFile(audio, 21 * 1024 * 1024);

    final result = await SpeechTranscriptionService.instance
        .transcribeFileWithMetadata(audio.path);

    expect(result.model, 'asset-safety');
    expect(result.text, isNull);
    expect(result.usage, isNull);
  });

  test('local transcription also skips unsafe audio before model lookup',
      () async {
    SharedPreferences.setMockInitialValues({
      'use_local_speech_to_text': true,
    });
    final audio = File('${tempDir.path}/audio_20260602_ts_1_no_1_301.m4a');
    await audio.create();
    await _resizeFile(audio, 21 * 1024 * 1024);

    final result = await SpeechTranscriptionService.instance
        .transcribeFileWithMetadata(audio.path, skipLengthCheck: true);

    expect(result.model, 'asset-safety');
    expect(result.text, isNull);
    expect(result.usage, isNull);
  });

  test(
    'saveAssetFromFile keeps long image and records dimensions safely',
    () async {
      await FileSystemService.init(tempDir.path);
      final source = File('${tempDir.path}/source_long.png');
      await source.writeAsBytes(_pngHeader(width: 1000, height: 13000));

      final (filename, relativePath) =
          await FileSystemService.instance.saveAssetFromFile(
        userId: 'asset-user',
        sourcePath: source.path,
        assetType: 'img',
        index: 1,
        factId: '2026/06/02.md#ts_1',
      );

      expect(filename, contains('1000x13000'));
      final copied = File(
        FileSystemService.instance.toAbsolutePath(relativePath),
      );
      expect(await copied.exists(), isTrue);
      expect(await copied.readAsBytes(), await source.readAsBytes());
    },
  );

  test(
    'audio asset analysis writes skip file and preserves original asset',
    () async {
      await FileSystemService.init(tempDir.path);
      final source = File('${tempDir.path}/source_audio.m4a');
      await source.create();
      await _resizeFile(source, 21 * 1024 * 1024);

      final (filename, relativePath) =
          await FileSystemService.instance.saveAssetFromFile(
        userId: 'audio-analysis-user',
        sourcePath: source.path,
        assetType: 'audio',
        index: 1,
        factId: '2026/06/02.md#ts_1',
        extraInfo: '301',
      );

      final copied = File(
        FileSystemService.instance.toAbsolutePath(relativePath),
      );
      expect(await copied.exists(), isTrue);
      expect(await copied.length(), await source.length());

      final results = await analyzeAssetsForFact(
        userId: 'audio-analysis-user',
        factId: '2026/06/02.md#ts_1',
        assetPaths: [relativePath],
      );

      expect(results, hasLength(1));
      expect(results.single.analysis, contains('Automatic analysis skipped'));
      expect(results.single.analysis, contains('audio duration 301s'));
      expect(await copied.exists(), isTrue);
      expect(
        await File('${copied.path}.analysis.txt').readAsString(),
        contains('original file was preserved'),
      );
      expect(filename, contains('_301.'));
    },
  );

  test('MediaService imports image using safe header dimensions', () async {
    await FileSystemService.init(tempDir.path);
    final source = File('${tempDir.path}/media_long.png');
    await source.writeAsBytes(_pngHeader(width: 1000, height: 13000));

    final imported = await MediaService.instance.importImage(
      userId: 'media-user',
      sourcePath: source.path,
    );

    expect(imported.absolutePath, contains('1000x13000'));
    expect(await File(imported.absolutePath).exists(), isTrue);
    expect(
      FileSystemService.instance.toAbsolutePath(imported.relativePath),
      imported.absolutePath,
    );
  });

  test(
    'unsafe asset analysis writes skip file without requiring llm config',
    () async {
      await FileSystemService.init(tempDir.path);
      final source = File('${tempDir.path}/source_long.png');
      await source.writeAsBytes(_pngHeader(width: 1000, height: 13000));

      final (filename, relativePath) =
          await FileSystemService.instance.saveAssetFromFile(
        userId: 'analysis-user',
        sourcePath: source.path,
        assetType: 'img',
        index: 1,
        factId: '2026/06/02.md#ts_1',
      );

      final results = await analyzeAssetsForFact(
        userId: 'analysis-user',
        factId: '2026/06/02.md#ts_1',
        assetPaths: [relativePath],
      );

      expect(results, hasLength(1));
      expect(results.single.analysis, contains('Automatic analysis skipped'));
      expect(results.single.analysis, contains('original file was preserved'));

      final assetsPath = FileSystemService.instance.getAssetsPath(
        'analysis-user',
      );
      final analysisFile = File('$assetsPath/$filename.analysis.txt');
      expect(await analysisFile.exists(), isTrue);
      expect(await analysisFile.readAsString(), contains('long edge'));
    },
  );

  test(
    'submitInput preserves unsafe image and downstream analysis skips it',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_id': 'submit-user',
        'language': 'en',
      });
      await UserStorage.initL10n();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      addTearDown(db.close);

      await FileSystemService.init(tempDir.path);
      final source = File('${tempDir.path}/shared_long.png');
      source.writeAsBytesSync(_pngHeader(width: 1000, height: 13000));

      final submitted = await submitInput('submit-user', [
        {'type': 'text', 'text': 'I want to save this long screenshot.'},
        {
          'type': 'image_url',
          'image_url': {'filePath': source.path},
        },
      ]);
      final factId = submitted['fact_id'] as String;

      final factFile = File(
        FileSystemService.instance.getDailyFactPath(
          'submit-user',
          DateTime.now(),
        ),
      );
      final factContent = await factFile.readAsString();
      final match = RegExp(
        r'!\[image\]\(fs://([^)]+)\)',
      ).firstMatch(factContent);
      expect(match, isNotNull);

      final filename = match!.group(1)!;
      final assetPath =
          '${FileSystemService.instance.getAssetsPath('submit-user')}/$filename';
      expect(await File(assetPath).exists(), isTrue);

      final results = await analyzeAssetsForFact(
        userId: 'submit-user',
        factId: factId,
        assetPaths: [FileSystemService.instance.toRelativePath(assetPath)],
      );

      expect(results, hasLength(1));
      expect(results.single.analysis, contains('Automatic analysis skipped'));
      expect(
        await File('$assetPath.analysis.txt').readAsString(),
        contains('original file was preserved'),
      );
    },
  );

  test('custom agent skips unsafe inline audio parts', () async {
    await FileSystemService.init(tempDir.path);
    final assetsPath = FileSystemService.instance.getAssetsPath('agent-user');
    await Directory(assetsPath).create(recursive: true);
    const filename = 'audio_20260602_ts_1_no_1_30.m4a';
    final audio = File('$assetsPath/$filename');
    await audio.create();
    await _resizeFile(audio, 9 * 1024 * 1024);

    final parts = await buildAssetPartsFromXmlForTesting(
      'agent-user',
      '<event>[audio](fs://$filename)</event>',
    );

    expect(parts.whereType<AudioPart>(), isEmpty);
  });

  test('custom agent skips unsafe inline image parts', () async {
    await FileSystemService.init(tempDir.path);
    final assetsPath = FileSystemService.instance.getAssetsPath('agent-user');
    await Directory(assetsPath).create(recursive: true);
    const filename = 'unsafe_inline.png';
    await File('$assetsPath/$filename').writeAsBytes(
      _pngHeader(width: 1000, height: 13000),
    );

    final parts = await buildAssetPartsFromXmlForTesting(
      'agent-user',
      '<event>![image](fs://$filename)</event>',
    );

    expect(parts.whereType<ImagePart>(), isEmpty);
    expect(parts.whereType<AudioPart>(), isEmpty);
  });

  test('custom agent keeps safe inline image parts available', () async {
    await FileSystemService.init(tempDir.path);
    final assetsPath = FileSystemService.instance.getAssetsPath('agent-user');
    await Directory(assetsPath).create(recursive: true);
    const filename = 'safe_inline.png';
    await File('$assetsPath/$filename').writeAsBytes(
      _pngHeader(width: 320, height: 240),
    );

    final parts = await buildAssetPartsFromXmlForTesting(
      'agent-user',
      '<event>![image](fs://$filename)</event>',
    );

    expect(parts.whereType<ImagePart>(), hasLength(1));
    expect(parts.whereType<AudioPart>(), isEmpty);
  });

  test('photo suggestion skips unsafe image before MLKit processing', () async {
    final image = File('${tempDir.path}/unsafe_photo_suggestion.png');
    image.writeAsBytesSync(_pngHeader(width: 1000, height: 13000));

    final result = await PhotoSuggestionService.processImageOCRForTesting(
      XFile(image.path),
    );

    expect(result.ocrBlocks, isEmpty);
    expect(result.labels, isEmpty);
    expect(result.modifiedTime, (await image.stat()).modified);
  });
}

List<int> _pngHeader({required int width, required int height}) {
  final bytes = Uint8List(33);
  bytes.setAll(0, const [
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
    0x00,
    0x00,
    0x00,
    0x0d,
    0x49,
    0x48,
    0x44,
    0x52,
  ]);
  _writeUint32Be(bytes, 16, width);
  _writeUint32Be(bytes, 20, height);
  bytes.setAll(24, const [
    0x08,
    0x02,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ]);
  return bytes;
}

void _writeUint32Be(Uint8List bytes, int offset, int value) {
  bytes[offset] = (value >> 24) & 0xff;
  bytes[offset + 1] = (value >> 16) & 0xff;
  bytes[offset + 2] = (value >> 8) & 0xff;
  bytes[offset + 3] = value & 0xff;
}

Future<void> _resizeFile(File file, int length) async {
  final raf = await file.open(mode: FileMode.write);
  try {
    await raf.truncate(length);
  } finally {
    await raf.close();
  }
}
