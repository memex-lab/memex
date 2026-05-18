import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/backup_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late PathProviderPlatform originalPathProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
    await UserStorage.saveUser('backup-service-user');

    tempDir = await Directory.systemTemp.createTemp('memex_backup_service_');
    originalPathProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
    _mockPathProviderChannel(tempDir.path);
    await FileSystemService.init(tempDir.path);

    final workspace = Directory(
      FileSystemService.instance.getWorkspacePath('backup-service-user'),
    );
    await workspace.create(recursive: true);
    await File(
      p.join(workspace.path, 'Cards', 'card.md'),
    ).create(recursive: true);
    await File(
      p.join(workspace.path, 'Cards', 'card.md'),
    ).writeAsString('hello backup');
  });

  tearDown(() async {
    _clearPathProviderChannelMock();
    _clearBackupStorageChannelMock();
    PathProviderPlatform.instance = originalPathProvider;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('createBackup writes manifest and workspace content', () async {
    final outputDir = Directory(p.join(tempDir.path, 'Backups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: outputDir.path,
    );

    final archive = ZipDecoder().decodeBytes(
      await File(backupPath).readAsBytes(),
    );

    expect(
      archive.files.map((file) => file.name),
      containsAll([
        'manifest.json',
        'settings.json',
        'workspace/Cards/card.md',
      ]),
    );

    final manifest = archive.files.firstWhere(
      (file) => file.name == 'manifest.json',
    );
    final manifestJson = jsonDecode(utf8.decode(manifest.content));

    expect(manifestJson['formatVersion'], 1);
    expect(manifestJson['entries'], isNotEmpty);
  });

  test(
    'restore rejects a backup with a mismatched manifest checksum',
    () async {
      final outputDir = Directory(p.join(tempDir.path, 'Backups'));
      final backupPath = await BackupService.createBackup(
        outputDirectory: outputDir.path,
      );
      final archive = ZipDecoder().decodeBytes(
        await File(backupPath).readAsBytes(),
      );
      final corrupted = Archive();

      for (final file in archive.files) {
        if (!file.isFile) continue;
        final bytes = file.name == 'workspace/Cards/card.md'
            ? utf8.encode('tampered workspace note')
            : List<int>.from(file.content);
        corrupted.addFile(ArchiveFile(file.name, bytes.length, bytes));
      }

      final corruptedPath = p.join(outputDir.path, 'tampered.memex');
      await File(corruptedPath).writeAsBytes(ZipEncoder().encode(corrupted));

      await expectLater(
        BackupService.restoreBackup(corruptedPath),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Backup checksum mismatch'),
          ),
        ),
      );
    },
  );

  test(
    'automatic backup skips a second run within twenty-four hours',
    () async {
      await UserStorage.setAutoBackupEnabled('backup-service-user', true);

      final first = await BackupService.maybeCreateAutoBackup(
        trigger: 'test-first',
      );
      final second = await BackupService.maybeCreateAutoBackup(
        trigger: 'test-second',
      );

      expect(first, isNotNull);
      expect(second, isNull);
    },
  );

  test(
    'automatic backup retention keeps the newest seven daily snapshots',
    () async {
      final backupDir = await BackupService.resolveDefaultBackupDirectory();
      final now = DateTime(2026, 5, 15, 12);

      for (var i = 0; i < 9; i += 1) {
        final file = File(
          p.join(
            backupDir.path,
            'memex_auto_2026-05-${(i + 1).toString().padLeft(2, '0')}T00-00-00.memex',
          ),
        );
        await file.writeAsBytes([i]);
        await file.setLastModified(now.subtract(Duration(days: 9 - i)));
      }

      await BackupService.createStoredBackup();

      final files = await backupDir
          .list()
          .where(
            (entity) =>
                entity is File &&
                p.basename(entity.path).startsWith('memex_auto'),
          )
          .toList();

      expect(files.length, lessThanOrEqualTo(7));
    },
  );

  test('safety snapshots are kept outside automatic retention', () async {
    final backupDir = await BackupService.resolveDefaultBackupDirectory();

    for (var i = 0; i < 9; i += 1) {
      final file = File(
        p.join(
          backupDir.path,
          'memex_auto_2026-05-${(i + 1).toString().padLeft(2, '0')}T00-00-00.memex',
        ),
      );
      await file.writeAsBytes([i]);
    }

    final safety = await BackupService.createSafetySnapshot(
      reason: 'before_storage_switch',
    );
    await BackupService.createStoredBackup();

    expect(await File(safety.filePath!).exists(), isTrue);
    final safetyFiles = await backupDir
        .list()
        .where(
          (entity) =>
              entity is File &&
              p
                  .basename(entity.path)
                  .startsWith('memex_safety_before_storage_switch'),
        )
        .toList();

    expect(safetyFiles, isNotEmpty);
  });

  test('deleteStoredBackup removes only the selected local snapshot', () async {
    final backupDir = await BackupService.resolveDefaultBackupDirectory();
    final target = File(
      p.join(backupDir.path, 'memex_auto_2026-05-15T10-00-00.memex'),
    );
    final keepAuto = File(
      p.join(backupDir.path, 'memex_auto_2026-05-16T10-00-00.memex'),
    );
    final keepSafety = File(
      p.join(
        backupDir.path,
        'memex_safety_before_restore_2026-05-16T11-00-00.memex',
      ),
    );
    final ignoredText = File(p.join(backupDir.path, 'notes.txt'));

    await target.writeAsBytes([1]);
    await keepAuto.writeAsBytes([2]);
    await keepSafety.writeAsBytes([3]);
    await ignoredText.writeAsString('not a backup');

    final snapshots = await BackupService.listStoredBackups();
    final targetSnapshot = snapshots.firstWhere(
      (snapshot) => snapshot.name == p.basename(target.path),
    );

    await BackupService.deleteStoredBackup(targetSnapshot);

    expect(await target.exists(), isFalse);
    expect(await keepAuto.exists(), isTrue);
    expect(await keepSafety.exists(), isTrue);
    expect(await ignoredText.exists(), isTrue);

    final remainingNames = (await BackupService.listStoredBackups())
        .map((snapshot) => snapshot.name)
        .toSet();
    expect(remainingNames, isNot(contains(p.basename(target.path))));
    expect(remainingNames, contains(p.basename(keepAuto.path)));
    expect(remainingNames, contains(p.basename(keepSafety.path)));
  });

  test('deleteStoredBackup delegates Android document deletion', () async {
    final deletedUris = <String>[];
    _mockBackupStorageChannel((call) async {
      if (call.method == 'deleteDocument') {
        deletedUris.add((call.arguments as Map)['documentUri'] as String);
      }
      return null;
    });

    await BackupService.deleteStoredBackup(
      BackupSnapshot(
        id: 'content://backups/auto',
        name: 'memex_auto_2026-05-16T10-00-00.memex',
        createdAt: DateTime(2026, 5, 16, 10),
        sizeBytes: 12,
        documentUri: 'content://backups/auto',
      ),
    );

    expect(deletedUris, ['content://backups/auto']);
  });

  test('restore leaves stored backup history files untouched', () async {
    final backupDir = await BackupService.resolveDefaultBackupDirectory();
    final historyAuto = File(
      p.join(backupDir.path, 'memex_auto_2026-05-15T10-00-00.memex'),
    );
    final historySafety = File(
      p.join(
        backupDir.path,
        'memex_safety_before_restore_2026-05-16T11-00-00.memex',
      ),
    );
    await historyAuto.writeAsBytes([1, 2, 3]);
    await historySafety.writeAsBytes([4, 5, 6]);

    final exportedDir = Directory(p.join(tempDir.path, 'ExportedBackups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: exportedDir.path,
    );

    try {
      await BackupService.restoreBackup(backupPath);
    } finally {
      if (AppDatabase.isInitialized) {
        await AppDatabase.instance.close();
      }
    }

    expect(await historyAuto.exists(), isTrue);
    expect(await historySafety.exists(), isTrue);
    expect(await File(backupPath).exists(), isTrue);
  });

  group('inspectBackup', () {
    test('reads backup manifest metadata', () async {
      final file = await _writeBackup(
        tempDir,
        'backup.memex',
        manifest: {
          'format': 'memex.backup',
          'backupSchemaVersion': BackupService.currentBackupSchemaVersion,
          'createdAt': '2026-05-15T00:00:00.000Z',
          'appVersion': '1.0.30',
          'buildNumber': '113',
          'flavor': 'globalEarly',
          'platform': 'android',
        },
      );

      final info = await BackupService.inspectBackup(file.path);

      expect(info.isLegacy, isFalse);
      expect(info.manifest?.appVersion, '1.0.30');
      expect(info.manifest?.buildNumber, '113');
      expect(info.manifest?.flavor, 'globalEarly');
    });

    test('accepts legacy backup without manifest', () async {
      final file = await _writeBackup(tempDir, 'legacy.memex');

      final info = await BackupService.inspectBackup(file.path);

      expect(info.isLegacy, isTrue);
      expect(info.manifest, isNull);
    });

    test('rejects newer backup schema', () async {
      final file = await _writeBackup(
        tempDir,
        'newer.memex',
        manifest: {
          'format': 'memex.backup',
          'backupSchemaVersion': BackupService.currentBackupSchemaVersion + 1,
          'createdAt': '2026-05-15T00:00:00.000Z',
        },
      );

      expect(
        () => BackupService.inspectBackup(file.path),
        throwsA(isA<UnsupportedBackupVersionException>()),
      );
    });

    test('rejects non-backup extension', () async {
      final file = await _writeBackup(tempDir, 'backup.txt');

      expect(
        () => BackupService.inspectBackup(file.path),
        throwsA(isA<InvalidBackupFileException>()),
      );
    });

    test('rejects zip without backup markers', () async {
      final archive = Archive()
        ..addFile(ArchiveFile('notes.txt', 5, utf8.encode('hello')));
      final file = File('${tempDir.path}/random.memex');
      await file.writeAsBytes(ZipEncoder().encode(archive));

      expect(
        () => BackupService.inspectBackup(file.path),
        throwsA(isA<InvalidBackupFileException>()),
      );
    });
  });
}

void _mockPathProviderChannel(String rootPath) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async {
          switch (call.method) {
            case 'getTemporaryDirectory':
            case 'getApplicationDocumentsDirectory':
            case 'getApplicationSupportDirectory':
            case 'getExternalStorageDirectory':
              return rootPath;
            case 'getExternalStorageDirectories':
              return <String>[rootPath];
          }
          return null;
        },
      );
}

void _clearPathProviderChannelMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
}

void _mockBackupStorageChannel(
  Future<dynamic> Function(MethodCall call) handler,
) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.memexlab.memex/backup_storage'),
        handler,
      );
}

void _clearBackupStorageChannelMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.memexlab.memex/backup_storage'),
        null,
      );
}

class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String rootPath;

  FakePathProviderPlatform(this.rootPath);

  @override
  Future<String?> getTemporaryPath() async => rootPath;

  @override
  Future<String?> getApplicationSupportPath() async => rootPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => rootPath;

  @override
  Future<String?> getExternalStoragePath() async => rootPath;
}

Future<File> _writeBackup(
  Directory tempDir,
  String fileName, {
  Map<String, dynamic>? manifest,
}) async {
  final archive = Archive();
  if (manifest != null) {
    final manifestBytes = utf8.encode(jsonEncode(manifest));
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );
  }
  final settingsBytes = utf8.encode(jsonEncode({'userId': 'test-user'}));
  archive.addFile(
    ArchiveFile('settings.json', settingsBytes.length, settingsBytes),
  );

  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(ZipEncoder().encode(archive));
  return file;
}
