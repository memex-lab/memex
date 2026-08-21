import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/backup_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
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
    try {
      await tempDir.delete(recursive: true);
    } on PathNotFoundException {
      // Some restore paths can remove the fake temp root before tearDown runs.
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

  test('createBackup excludes device-local notification prompt state',
      () async {
    await UserStorage.setMemexAgentNotificationPermissionPrompted();
    final outputDir = Directory(p.join(tempDir.path, 'Backups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: outputDir.path,
    );

    final archive = ZipDecoder().decodeBytes(
      await File(backupPath).readAsBytes(),
    );
    final settingsFile = archive.files.firstWhere(
      (file) => file.name == 'settings.json',
    );
    final settings = (jsonDecode(utf8.decode(settingsFile.content)) as Map)
        .cast<String, dynamic>();

    expect(settings['language'], 'en');
    expect(
      settings,
      isNot(
        contains(
          'memex_agent_notification_permission_prompted_backup-service-user',
        ),
      ),
    );
  });

  test('createBackup still compresses small text files', () async {
    final outputDir = Directory(p.join(tempDir.path, 'Backups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: outputDir.path,
    );

    final archive = ZipDecoder().decodeBytes(
      await File(backupPath).readAsBytes(),
    );
    final archivedCard = archive.files.firstWhere(
      (file) => file.name == 'workspace/Cards/card.md',
    );

    expect(archivedCard.compression, CompressionType.deflate);
    expect(utf8.decode(archivedCard.content), 'hello backup');
  });

  test('createBackup stores compressed media without recompressing', () async {
    final workspace = Directory(
      FileSystemService.instance.getWorkspacePath('backup-service-user'),
    );
    final mediaFile = File(p.join(workspace.path, 'Assets', 'clip.mp4'));
    await mediaFile.create(recursive: true);
    await mediaFile.writeAsBytes(List<int>.generate(1024, (index) => index));

    final outputDir = Directory(p.join(tempDir.path, 'Backups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: outputDir.path,
    );

    final archive = ZipDecoder().decodeBytes(
      await File(backupPath).readAsBytes(),
    );
    final archivedMedia = archive.files.firstWhere(
      (file) => file.name == 'workspace/Assets/clip.mp4',
    );

    expect(archivedMedia.compression, CompressionType.none);
    expect(archivedMedia.content, await mediaFile.readAsBytes());
  });

  test('createBackup stores large files without recompressing', () async {
    final workspace = Directory(
      FileSystemService.instance.getWorkspacePath('backup-service-user'),
    );
    final largeFile = File(p.join(workspace.path, 'Cards', 'large.bin'));
    const largeFileSize = 16 * 1024 * 1024 + 1;
    await _writeDeterministicBinaryFile(
      largeFile,
      sizeBytes: largeFileSize,
      seed: 99,
    );

    final outputDir = Directory(p.join(tempDir.path, 'Backups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: outputDir.path,
    );

    final archive = ZipDecoder().decodeBytes(
      await File(backupPath).readAsBytes(),
    );
    final archivedLargeFile = archive.files.firstWhere(
      (file) => file.name == 'workspace/Cards/large.bin',
    );
    final manifest = archive.files.firstWhere(
      (file) => file.name == 'manifest.json',
    );
    final manifestJson = jsonDecode(utf8.decode(manifest.content));
    final entries = (manifestJson['entries'] as List)
        .whereType<Map>()
        .map((entry) => entry.cast<String, dynamic>());
    final largeEntry = entries.firstWhere(
      (entry) => entry['path'] == 'workspace/Cards/large.bin',
    );

    expect(archivedLargeFile.compression, CompressionType.none);
    expect(archivedLargeFile.size, largeFileSize);
    expect(largeEntry['size'], largeFileSize);
    expect(largeEntry['sha256'], await _sha256File(largeFile));
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

  test('automatic backup retention preference defaults and persists', () async {
    expect(
      await UserStorage.getAutoBackupRetentionDays('backup-service-user'),
      UserStorage.defaultAutoBackupRetentionDays,
    );

    await UserStorage.setAutoBackupRetentionDays('backup-service-user', 14);
    expect(
      await UserStorage.getAutoBackupRetentionDays('backup-service-user'),
      14,
    );

    await UserStorage.setAutoBackupRetentionDays('backup-service-user', null);
    expect(
      await UserStorage.getAutoBackupRetentionDays('backup-service-user'),
      isNull,
    );

    expect(
      () => UserStorage.setAutoBackupRetentionDays('backup-service-user', 0),
      throwsArgumentError,
    );

    expect(
      await UserStorage.getAutoBackupMaxBytes('backup-service-user'),
      UserStorage.defaultAutoBackupMaxBytes,
    );

    await UserStorage.setAutoBackupMaxBytes('backup-service-user', 1024);
    expect(
        await UserStorage.getAutoBackupMaxBytes('backup-service-user'), 1024);

    expect(
      () => UserStorage.setAutoBackupMaxBytes('backup-service-user', 0),
      throwsArgumentError,
    );
  });

  test(
    'automatic backup retention deletes only expired automatic snapshots',
    () async {
      final backupDir = await BackupService.resolveDefaultBackupDirectory();
      final now = DateTime(2026, 5, 15, 12);
      await UserStorage.setAutoBackupRetentionDays('backup-service-user', 7);

      final recent = await _writeStoredBackupFile(
        backupDir,
        'memex_auto_recent.memex',
        modified: now.subtract(const Duration(days: 6)),
      );
      final boundary = await _writeStoredBackupFile(
        backupDir,
        'memex_auto_boundary.memex',
        modified: now.subtract(const Duration(days: 7)),
      );
      final expired = await _writeStoredBackupFile(
        backupDir,
        'memex_auto_expired.memex',
        modified: now.subtract(const Duration(days: 8)),
      );
      final safety = await _writeStoredBackupFile(
        backupDir,
        'memex_safety_before_restore.memex',
        modified: now.subtract(const Duration(days: 60)),
      );

      final deleted = await BackupService.pruneAutoBackups(now: now);

      expect(deleted, 1);
      expect(await recent.exists(), isTrue);
      expect(await boundary.exists(), isTrue);
      expect(await expired.exists(), isFalse);
      expect(await safety.exists(), isTrue);
    },
  );

  test('automatic backup pruning always keeps the newest snapshot', () async {
    final backupDir = await BackupService.resolveDefaultBackupDirectory();
    final now = DateTime(2026, 5, 15, 12);
    await UserStorage.setAutoBackupRetentionDays('backup-service-user', 7);

    final oldest = await _writeStoredBackupFile(
      backupDir,
      'memex_auto_oldest.memex',
      modified: now.subtract(const Duration(days: 30)),
    );
    final newest = await _writeStoredBackupFile(
      backupDir,
      'memex_auto_newest.memex',
      modified: now.subtract(const Duration(days: 20)),
    );

    final deleted = await BackupService.pruneAutoBackups(now: now);

    expect(deleted, 1);
    expect(await newest.exists(), isTrue);
    expect(await oldest.exists(), isFalse);
  });

  test('automatic backup retention still caps forever history by total size',
      () async {
    final backupDir = await BackupService.resolveDefaultBackupDirectory();
    final now = DateTime(2026, 5, 15, 12);
    await UserStorage.setAutoBackupRetentionDays('backup-service-user', null);
    await UserStorage.setAutoBackupMaxBytes('backup-service-user', 3);

    for (var i = 0; i < 5; i += 1) {
      await _writeStoredBackupFile(
        backupDir,
        'memex_auto_${i.toString().padLeft(2, '0')}.memex',
        modified: now.subtract(Duration(minutes: i)),
        sizeBytes: 1,
      );
    }

    final deleted = await BackupService.pruneAutoBackups(now: now);
    final remainingNames = await _storedBackupNames(backupDir);

    expect(deleted, 2);
    expect(remainingNames.length, 3);
    expect(remainingNames, contains('memex_auto_00.memex'));
    expect(remainingNames, contains('memex_auto_02.memex'));
    expect(remainingNames, isNot(contains('memex_auto_03.memex')));
    expect(remainingNames, isNot(contains('memex_auto_04.memex')));
  });

  test('automatic backup skip still prunes expired snapshots', () async {
    await UserStorage.setAutoBackupEnabled('backup-service-user', true);
    await UserStorage.setAutoBackupRetentionDays('backup-service-user', 7);
    await UserStorage.setLastAutoBackupMetadata(
      'backup-service-user',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      fingerprint: 'previous',
    );

    final backupDir = await BackupService.resolveDefaultBackupDirectory();
    final keep = await _writeStoredBackupFile(
      backupDir,
      'memex_auto_recent_skip.memex',
      modified: DateTime.now().subtract(const Duration(days: 1)),
    );
    final expired = await _writeStoredBackupFile(
      backupDir,
      'memex_auto_expired_skip.memex',
      modified: DateTime.now().subtract(const Duration(days: 8)),
    );

    final snapshot = await BackupService.maybeCreateAutoBackup(
      trigger: 'skip-prune-test',
    );

    expect(snapshot, isNull);
    expect(await keep.exists(), isTrue);
    expect(await expired.exists(), isFalse);
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

  test('restore stages and applies workspace files from backup', () async {
    final exportedDir = Directory(p.join(tempDir.path, 'ExportedBackups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: exportedDir.path,
    );

    final workspace = Directory(
      FileSystemService.instance.getWorkspacePath('backup-service-user'),
    );
    final cardFile = File(p.join(workspace.path, 'Cards', 'card.md'));
    await cardFile.writeAsString('local changes after backup');

    try {
      await BackupService.restoreBackup(backupPath);
    } finally {
      if (AppDatabase.isInitialized) {
        await AppDatabase.instance.close();
      }
    }

    expect(await cardFile.readAsString(), 'hello backup');
  });

  test('restore ignores device-local state contained in an old backup',
      () async {
    final settings = {
      'user_id': 'backup-service-user',
      'language': 'zh',
      'memex_agent_notification_permission_prompted_backup-service-user': true,
    };
    final settingsBytes = utf8.encode(jsonEncode(settings));
    final archive = Archive()
      ..addFile(
        ArchiveFile('settings.json', settingsBytes.length, settingsBytes),
      );
    final backupPath = p.join(tempDir.path, 'legacy-settings.memex');
    await File(backupPath).writeAsBytes(ZipEncoder().encode(archive));

    try {
      await BackupService.restoreBackup(backupPath);
    } finally {
      if (AppDatabase.isInitialized) {
        await AppDatabase.instance.close();
      }
    }

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language'), 'zh');
    expect(
      await UserStorage.hasPromptedMemexAgentNotificationPermission(),
      isFalse,
    );
  });

  test('restore resumes a task executor that was running beforehand', () async {
    final exportedDir = Directory(p.join(tempDir.path, 'ExportedBackups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: exportedDir.path,
    );
    await AppDatabase.init('backup-service-user');
    final executor = LocalTaskExecutor.instance;
    await executor.start(userId: 'backup-service-user');

    try {
      await BackupService.restoreBackup(backupPath);
      expect(executor.isRunning, isTrue);
      expect(executor.currentUserId, 'backup-service-user');
    } finally {
      await executor.stop();
      if (AppDatabase.isInitialized) {
        await AppDatabase.instance.close();
      }
    }
  });

  test('restore removes workspace files that are not in the backup', () async {
    final exportedDir = Directory(p.join(tempDir.path, 'ExportedBackups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: exportedDir.path,
    );

    final workspace = Directory(
      FileSystemService.instance.getWorkspacePath('backup-service-user'),
    );
    final extraFile = File(p.join(workspace.path, 'Cards', 'extra.md'));
    await extraFile.create(recursive: true);
    await extraFile.writeAsString('should not survive restore');
    final localBackup = File(
      p.join(workspace.path, 'Backups', 'keep-me.memex'),
    );
    await localBackup.create(recursive: true);
    await localBackup.writeAsBytes([9, 9, 9]);

    try {
      await BackupService.restoreBackup(backupPath);
    } finally {
      if (AppDatabase.isInitialized) {
        await AppDatabase.instance.close();
      }
    }

    expect(await extraFile.exists(), isFalse);
    expect(await localBackup.exists(), isTrue);
    expect(
      await File(p.join(workspace.path, 'Cards', 'card.md')).readAsString(),
      'hello backup',
    );
  });

  test('restore removes stale workspace links without touching their target',
      () async {
    final exportedDir = Directory(p.join(tempDir.path, 'ExportedBackups'));
    final backupPath = await BackupService.createBackup(
      outputDirectory: exportedDir.path,
    );
    final workspace = Directory(
      FileSystemService.instance.getWorkspacePath('backup-service-user'),
    );
    final externalFile = File(p.join(tempDir.path, 'outside.txt'));
    await externalFile.writeAsString('outside');
    final staleLink = Link(p.join(workspace.path, 'Cards', 'outside-link'));
    await staleLink.create(externalFile.path);

    try {
      await BackupService.restoreBackup(backupPath);
    } finally {
      if (AppDatabase.isInitialized) {
        await AppDatabase.instance.close();
      }
    }

    expect(await staleLink.exists(), isFalse);
    expect(await externalFile.readAsString(), 'outside');
  });

  test(
    'restore keeps the main isolate responsive while extracting a larger backup',
    () async {
      final workspace = Directory(
        FileSystemService.instance.getWorkspacePath('backup-service-user'),
      );
      final largeFilesDir = Directory(p.join(workspace.path, 'Cards', 'Large'));
      const largeFileCount = 32;
      const largeFileSize = 768 * 1024;

      for (var i = 0; i < largeFileCount; i += 1) {
        await _writeDeterministicBinaryFile(
          File(p.join(largeFilesDir.path, 'payload_$i.bin')),
          sizeBytes: largeFileSize,
          seed: i + 1,
        );
      }

      final exportedDir = Directory(p.join(tempDir.path, 'ExportedBackups'));
      final backupPath = await BackupService.createBackup(
        outputDirectory: exportedDir.path,
      );

      final mutatedFile = File(p.join(largeFilesDir.path, 'payload_0.bin'));
      await mutatedFile.writeAsString('local mutation after backup');

      var mainIsolateTicks = 0;
      final timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
        mainIsolateTicks += 1;
      });
      final stopwatch = Stopwatch()..start();
      try {
        await BackupService.restoreBackup(backupPath).timeout(
          const Duration(seconds: 30),
        );
      } finally {
        timer.cancel();
        stopwatch.stop();
        if (AppDatabase.isInitialized) {
          await AppDatabase.instance.close();
        }
      }

      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 20)));
      expect(
        mainIsolateTicks,
        greaterThan(5),
        reason: 'Restore should yield to the main isolate during extraction.',
      );
      expect(await mutatedFile.length(), largeFileSize);
      expect(
        await mutatedFile.openRead(0, 64).expand((bytes) => bytes).toList(),
        _deterministicBytes(length: 64, seed: 1),
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );

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

Future<File> _writeStoredBackupFile(
  Directory backupDir,
  String fileName, {
  required DateTime modified,
  int sizeBytes = 1,
}) async {
  final file = File(p.join(backupDir.path, fileName));
  await file.writeAsBytes(List<int>.filled(sizeBytes, 1));
  await file.setLastModified(modified);
  return file;
}

Future<Set<String>> _storedBackupNames(Directory backupDir) async {
  return backupDir
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.memex'))
      .map((entity) => p.basename(entity.path))
      .toSet();
}

Future<void> _writeDeterministicBinaryFile(
  File file, {
  required int sizeBytes,
  required int seed,
}) async {
  await file.parent.create(recursive: true);
  final sink = file.openWrite();
  var remaining = sizeBytes;
  var state = seed;

  while (remaining > 0) {
    final chunkLength = remaining < 64 * 1024 ? remaining : 64 * 1024;
    final chunk = _deterministicBytes(
      length: chunkLength,
      seed: state,
      nextState: (value) => state = value,
    );
    sink.add(chunk);
    remaining -= chunkLength;
  }

  await sink.close();
}

List<int> _deterministicBytes({
  required int length,
  required int seed,
  void Function(int value)? nextState,
}) {
  var state = seed;
  final bytes = List<int>.filled(length, 0);
  for (var i = 0; i < bytes.length; i += 1) {
    state = (state * 1103515245 + 12345) & 0x7fffffff;
    bytes[i] = state & 0xff;
  }
  nextState?.call(state);
  return bytes;
}

Future<String> _sha256File(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
}
