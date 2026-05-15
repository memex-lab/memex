import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

/// Keys to exclude from backup (Flutter internals, not user data).
const _excludePrefKeys = <String>{'flutter.'};

const _backupExtension = '.memex';
const _autoBackupPrefix = 'memex_auto';
const _safetyBackupPrefix = 'memex_safety';
const _autoBackupInterval = Duration(hours: 24);
const _autoBackupKeepRecent = 7;
const _autoBackupMaxBytes = 2 * 1024 * 1024 * 1024; // 2 GB
const _backupManifestFileName = 'manifest.json';
const _backupFormat = 'memex.backup';
const _currentBackupSchemaVersion = 1;

/// Android Storage Access Framework directory selected for backups.
class AndroidBackupDirectory {
  final String treeUri;
  final String displayName;

  const AndroidBackupDirectory({
    required this.treeUri,
    required this.displayName,
  });
}

/// A restorable .memex snapshot stored by the automatic backup system.
class BackupSnapshot {
  final String id;
  final String name;
  final DateTime createdAt;
  final int sizeBytes;
  final String? filePath;
  final String? documentUri;

  const BackupSnapshot({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.sizeBytes,
    this.filePath,
    this.documentUri,
  });

  bool get isAndroidDocument => documentUri != null;
  bool get isSafetySnapshot => name.startsWith(_safetyBackupPrefix);
}

class BackupManifest {
  final String format;
  final int formatVersion;
  final int backupSchemaVersion;
  final DateTime createdAt;
  final String? userId;
  final String appVersion;
  final String buildNumber;
  final String flavor;
  final String platform;
  final List<Map<String, dynamic>> entries;

  const BackupManifest({
    required this.format,
    this.formatVersion = 1,
    required this.backupSchemaVersion,
    required this.createdAt,
    this.userId,
    required this.appVersion,
    required this.buildNumber,
    required this.flavor,
    required this.platform,
    this.entries = const [],
  });

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    final formatVersion = (json['formatVersion'] as num?)?.toInt();
    final rawEntries = json['entries'];
    final appVersion = json['appVersion'] as String? ?? '';
    final buildNumber = json['buildNumber']?.toString();
    final splitVersion = buildNumber == null && appVersion.contains('+')
        ? appVersion.split('+')
        : const <String>[];
    return BackupManifest(
      format: json['format'] as String? ??
          (formatVersion == null ? '' : _backupFormat),
      formatVersion: formatVersion ?? 1,
      backupSchemaVersion:
          (json['backupSchemaVersion'] as num?)?.toInt() ?? formatVersion ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      userId: json['userId'] as String?,
      appVersion: splitVersion.isEmpty ? appVersion : splitVersion.first,
      buildNumber:
          buildNumber ?? (splitVersion.length > 1 ? splitVersion.last : ''),
      flavor: json['flavor'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      entries: rawEntries is List
          ? rawEntries
              .whereType<Map>()
              .map((entry) => entry.cast<String, dynamic>())
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'format': format,
        'formatVersion': formatVersion,
        'backupSchemaVersion': backupSchemaVersion,
        'createdAt': createdAt.toUtc().toIso8601String(),
        if (userId != null) 'userId': userId,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'flavor': flavor,
        'platform': platform,
        'entries': entries,
      };
}

class BackupFileInfo {
  final String path;
  final int sizeBytes;
  final BackupManifest? manifest;

  const BackupFileInfo({
    required this.path,
    required this.sizeBytes,
    required this.manifest,
  });

  bool get isLegacy => manifest == null;
}

class InvalidBackupFileException implements Exception {
  final String message;

  const InvalidBackupFileException(this.message);

  @override
  String toString() => message;
}

class UnsupportedBackupVersionException implements Exception {
  final int backupSchemaVersion;
  final int supportedSchemaVersion;

  const UnsupportedBackupVersionException({
    required this.backupSchemaVersion,
    required this.supportedSchemaVersion,
  });

  @override
  String toString() {
    return 'Backup schema $backupSchemaVersion is newer than supported schema '
        '$supportedSchemaVersion. Please update Memex before restoring.';
  }
}

/// Service for creating and restoring full app backups as .memex (zip) files.
class BackupService {
  static final Logger _logger = getLogger('BackupService');
  static final Lock _autoBackupLock = Lock();
  static const backupMimeType = 'application/x-memex-backup';
  static const currentBackupSchemaVersion = _currentBackupSchemaVersion;

  static const MethodChannel _backupStorageChannel = MethodChannel(
    'com.memexlab.memex/backup_storage',
  );

  static bool isSelectableBackupFile(String filePath) {
    final lowerPath = _normalizeFilePath(filePath).toLowerCase();
    return lowerPath.endsWith('.memex') || lowerPath.endsWith('.zip');
  }

  static bool isMemexBackupFile(String filePath) {
    return _normalizeFilePath(filePath).toLowerCase().endsWith('.memex');
  }

  /// Create a backup zip containing:
  /// - workspace/ directory (Facts, Cards, PKM, KnowledgeInsights, etc.)
  /// - Drift SQLite DB file
  /// - settings.json (selected SharedPreferences keys)
  /// - manifest.json with entry checksums
  ///
  /// Returns the path to the generated .memex file.
  static Future<String> createBackup({
    void Function(String status)? onProgress,
    String? outputDirectory,
    String filePrefix = 'memex_backup',
  }) async {
    final userId = await UserStorage.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final fs = FileSystemService.instance;
    final workspacePath = fs.getWorkspacePath(userId);
    final appDir = await getApplicationDocumentsDirectory();
    final createdAt = DateTime.now();
    final fileName = '${filePrefix}_${_timestampForFile(createdAt)}'
        '$_backupExtension';

    final targetDir = outputDirectory == null
        ? await getTemporaryDirectory()
        : Directory(outputDirectory);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final outputPath = path.join(targetDir.path, fileName);
    final tempOutputPath = outputDirectory == null
        ? outputPath
        : path.join(targetDir.path, '.$fileName.tmp');

    final archive = Archive();
    final manifestEntries = <Map<String, dynamic>>[];

    // 1. Add workspace files
    onProgress?.call('Packing workspace...');
    await _addDirectoryToArchive(
      archive,
      workspacePath,
      'workspace',
      manifestEntries: manifestEntries,
      excludedRootPaths: [
        path.join(workspacePath, 'Backups'),
        if (outputDirectory != null) outputDirectory,
      ],
    );

    // 2. Add Drift DB file
    onProgress?.call('Packing database...');
    final dbName = 'memex_local_$userId.sqlite';
    // drift_flutter stores DB in app support directory on iOS, app documents on Android
    final possibleDbPaths = [
      path.join(appDir.path, dbName),
      path.join((await getApplicationSupportDirectory()).path, dbName),
    ];
    for (final dbPath in possibleDbPaths) {
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        final bytes = await dbFile.readAsBytes();
        _addBytesToArchive(
          archive,
          'db/$dbName',
          bytes,
          manifestEntries: manifestEntries,
        );
        _logger.info('Added DB file: $dbPath (${bytes.length} bytes)');
        break;
      }
    }

    // 3. Add SharedPreferences settings — backup ALL non-internal keys
    onProgress?.call('Packing settings...');
    final prefs = await SharedPreferences.getInstance();
    final settings = <String, dynamic>{};
    for (final key in prefs.getKeys()) {
      // Skip Flutter internal keys
      if (_excludePrefKeys.any((prefix) => key.startsWith(prefix))) continue;
      final value = prefs.get(key);
      if (value != null) {
        settings[key] = value;
      }
    }
    _addBytesToArchive(
      archive,
      'settings.json',
      utf8.encode(jsonEncode(settings)),
      manifestEntries: manifestEntries,
    );

    // 4. Add manifest last so it covers every payload entry.
    final manifest = await _createManifest(
      createdAt: createdAt,
      userId: userId,
      entries: manifestEntries,
    );
    _addBytesToArchive(
      archive,
      _backupManifestFileName,
      utf8.encode(jsonEncode(manifest.toJson())),
    );

    // 5. Write zip. Automatic path writes use temp + rename in the same dir.
    onProgress?.call('Compressing...');
    final zipData = ZipEncoder().encode(archive);
    final tempFile = File(tempOutputPath);
    await tempFile.writeAsBytes(zipData, flush: true);

    if (outputDirectory != null) {
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
      await tempFile.rename(outputPath);
    }

    _logger.info('Backup created: $outputPath (${zipData.length} bytes)');
    return outputPath;
  }

  /// Restore from a .memex backup file.
  /// Overwrites workspace, DB, and settings.
  /// Returns true on success.
  static Future<bool> restoreBackup(
    String backupFilePath, {
    void Function(String status)? onProgress,
  }) async {
    final currentUserId = await UserStorage.getUserId();
    if (currentUserId == null) throw Exception('No user logged in');
    var databaseClosedForRestore = false;

    try {
      await inspectBackup(backupFilePath);

      onProgress?.call('Reading backup...');
      final bytes = await File(
        _normalizeFilePath(backupFilePath),
      ).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      _validateManifest(archive);

      // 1. Restore settings FIRST to get the correct userId from backup
      onProgress?.call('Restoring settings...');
      for (final file in archive) {
        if (file.name == 'settings.json' && file.isFile) {
          final jsonStr = utf8.decode(_archiveFileBytes(file));
          final settings = jsonDecode(jsonStr) as Map<String, dynamic>;
          final prefs = await SharedPreferences.getInstance();
          for (final entry in settings.entries) {
            final value = entry.value;
            if (value is String) {
              await prefs.setString(entry.key, value);
            } else if (value is int) {
              await prefs.setInt(entry.key, value);
            } else if (value is double) {
              await prefs.setDouble(entry.key, value);
            } else if (value is bool) {
              await prefs.setBool(entry.key, value);
            } else if (value is List && value.every((item) => item is String)) {
              await prefs.setStringList(entry.key, value.cast<String>());
            }
          }
          _logger.info('Restored ${settings.length} settings');
        }
      }

      // Use the restored userId (from backup settings) for workspace and DB paths
      final restoredUserId = await UserStorage.getUserId() ?? currentUserId;
      final fs = FileSystemService.instance;
      final workspacePath = fs.getWorkspacePath(restoredUserId);
      final appDir = await getApplicationDocumentsDirectory();

      // 2. Restore workspace files
      onProgress?.call('Restoring workspace...');
      for (final file in archive) {
        if (!file.isFile || !file.name.startsWith('workspace/')) continue;

        final relativePath = file.name.substring('workspace/'.length);
        if (relativePath.isEmpty) continue;

        final targetPath = path.normalize(
          path.join(workspacePath, relativePath),
        );
        if (!_isPathWithin(workspacePath, targetPath)) {
          throw Exception('Unsafe backup entry path: ${file.name}');
        }

        final targetDir = Directory(path.dirname(targetPath));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        await File(targetPath).writeAsBytes(_archiveFileBytes(file));
      }

      // 3. Restore DB
      onProgress?.call('Restoring database...');
      // Close current DB first
      if (AppDatabase.isInitialized) {
        databaseClosedForRestore = true;
        await AppDatabase.instance.close();
      }

      for (final file in archive) {
        if (file.name.startsWith('db/') && file.isFile) {
          final dbFileName = path.basename(file.name);
          // Try both possible locations
          final supportDir = await getApplicationSupportDirectory();
          final possibleTargets = [
            path.join(appDir.path, dbFileName),
            path.join(supportDir.path, dbFileName),
          ];
          // Write to whichever location already has the file, or support dir
          String targetPath = possibleTargets.last;
          for (final p in possibleTargets) {
            if (await File(p).exists()) {
              targetPath = p;
              break;
            }
          }
          await File(targetPath).writeAsBytes(_archiveFileBytes(file));
          _logger.info('Restored DB to: $targetPath');
        }
      }

      // Re-init DB
      await AppDatabase.init(restoredUserId);
      databaseClosedForRestore = false;

      // 4. Rebuild card cache
      onProgress?.call('Rebuilding cache...');
      await fs.rebuildCardCache(restoredUserId);

      _logger.info('Backup restored successfully');
      return true;
    } catch (e, stack) {
      _logger.severe('Restore failed: $e', e, stack);
      if (databaseClosedForRestore) {
        // Try to re-init DB if restore failed after closing it.
        try {
          final userId = await UserStorage.getUserId();
          if (userId != null) await AppDatabase.init(userId);
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// Run the automatic backup policy: at most once every 24 hours and only
  /// when the source data fingerprint changed since the previous run.
  static Future<BackupSnapshot?> maybeCreateAutoBackup({
    String trigger = 'automatic',
    bool force = false,
    void Function(String status)? onProgress,
  }) async {
    return _autoBackupLock.synchronized(() async {
      final userId = await UserStorage.getUserId();
      if (userId == null || userId.isEmpty) return null;

      final enabled = await UserStorage.isAutoBackupEnabled(userId);
      if (!enabled && !force) return null;

      final now = DateTime.now();
      final fingerprint = await _calculateSourceFingerprint(userId);
      final lastBackupAt = await UserStorage.getLastAutoBackupAt(userId);
      final lastFingerprint = await UserStorage.getLastAutoBackupFingerprint(
        userId,
      );

      if (!force &&
          lastBackupAt != null &&
          now.difference(lastBackupAt) < _autoBackupInterval) {
        return null;
      }
      if (!force && lastFingerprint == fingerprint) {
        return null;
      }

      final snapshot = await createStoredBackup(
        filePrefix: _autoBackupPrefix,
        onProgress: onProgress,
      );
      await UserStorage.setLastAutoBackupMetadata(
        userId,
        createdAt: snapshot.createdAt,
        fingerprint: fingerprint,
      );
      _logger.info('Auto backup created from $trigger: ${snapshot.name}');
      return snapshot;
    });
  }

  /// Create a safety snapshot before destructive operations.
  static Future<BackupSnapshot> createSafetySnapshot({
    required String reason,
    void Function(String status)? onProgress,
  }) {
    final sanitizedReason =
        reason.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_').toLowerCase();
    return createStoredBackup(
      filePrefix: '${_safetyBackupPrefix}_$sanitizedReason',
      onProgress: onProgress,
      pruneAutoBackups: false,
    );
  }

  /// Create a backup in the configured automatic backup location.
  static Future<BackupSnapshot> createStoredBackup({
    String filePrefix = _autoBackupPrefix,
    void Function(String status)? onProgress,
    bool pruneAutoBackups = true,
  }) async {
    final userId = await UserStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('No user logged in');
    }

    if (Platform.isAndroid) {
      final treeUri = await UserStorage.getAndroidBackupTreeUri(userId);
      if (treeUri != null && treeUri.isNotEmpty) {
        final tempPath = await createBackup(
          onProgress: onProgress,
          filePrefix: filePrefix,
        );
        try {
          final fileName = path.basename(tempPath);
          final info = await _writeFileToAndroidTree(
            treeUri: treeUri,
            sourcePath: tempPath,
            fileName: fileName,
          );
          final snapshot = _snapshotFromAndroidInfo(info);
          if (pruneAutoBackups) {
            await _pruneAndroidTreeBackups(treeUri);
          }
          return snapshot;
        } finally {
          final tempFile = File(tempPath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      }
    }

    final backupDir = await resolveDefaultBackupDirectory();
    final backupPath = await createBackup(
      onProgress: onProgress,
      outputDirectory: backupDir.path,
      filePrefix: filePrefix,
    );
    final file = File(backupPath);
    final stat = await file.stat();
    final snapshot = BackupSnapshot(
      id: backupPath,
      name: path.basename(backupPath),
      createdAt: stat.modified,
      sizeBytes: stat.size,
      filePath: backupPath,
    );
    if (pruneAutoBackups) {
      await _pruneFileBackups(backupDir);
    }
    return snapshot;
  }

  /// Restore a stored snapshot. Android SAF snapshots are copied to a temp file
  /// first because [restoreBackup] consumes local file paths.
  static Future<bool> restoreStoredBackup(
    BackupSnapshot snapshot, {
    void Function(String status)? onProgress,
  }) async {
    var sourcePath = snapshot.filePath;
    var deleteTempAfterRestore = false;

    if (snapshot.isAndroidDocument) {
      sourcePath = await _copyAndroidDocumentToTempFile(
        documentUri: snapshot.documentUri!,
        fileName: snapshot.name,
      );
      deleteTempAfterRestore = true;
    }

    if (sourcePath == null) {
      throw Exception('Backup snapshot has no readable source');
    }

    try {
      return await restoreBackup(sourcePath, onProgress: onProgress);
    } finally {
      if (deleteTempAfterRestore) {
        final tempFile = File(sourcePath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    }
  }

  /// List automatic/safety backups from both the platform default directory and
  /// the user's Android SAF directory, if configured.
  static Future<List<BackupSnapshot>> listStoredBackups() async {
    final snapshots = <BackupSnapshot>[];

    try {
      final defaultDir = await resolveDefaultBackupDirectory();
      snapshots.addAll(await _listFileBackups(defaultDir));
    } catch (e, st) {
      _logger.warning('Failed to list default backups: $e', e, st);
    }

    final userId = await UserStorage.getUserId();
    if (Platform.isAndroid && userId != null && userId.isNotEmpty) {
      final treeUri = await UserStorage.getAndroidBackupTreeUri(userId);
      if (treeUri != null && treeUri.isNotEmpty) {
        try {
          snapshots.addAll(await _listAndroidTreeBackups(treeUri));
        } catch (e, st) {
          _logger.warning('Failed to list Android SAF backups: $e', e, st);
        }
      }
    }

    snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return snapshots;
  }

  /// Pick and persist an Android backup directory via Storage Access Framework.
  static Future<AndroidBackupDirectory?> pickAndroidBackupDirectory() async {
    if (!Platform.isAndroid) return null;

    final result = await _backupStorageChannel.invokeMapMethod<String, dynamic>(
      'pickBackupDirectory',
    );
    if (result == null) return null;

    final treeUri = result['treeUri'] as String?;
    if (treeUri == null || treeUri.isEmpty) return null;

    final displayName = result['displayName'] as String? ?? 'Selected folder';
    final userId = await UserStorage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      await UserStorage.setAndroidBackupTree(
        userId: userId,
        treeUri: treeUri,
        displayName: displayName,
      );
    }
    return AndroidBackupDirectory(treeUri: treeUri, displayName: displayName);
  }

  /// Use the app-managed platform default backup directory.
  static Future<void> useDefaultBackupDirectory() async {
    if (!Platform.isAndroid) return;
    final userId = await UserStorage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      await UserStorage.clearAndroidBackupTree(userId);
    }
  }

  /// Human-readable current automatic backup location.
  static Future<String> currentBackupLocationLabel() async {
    final userId = await UserStorage.getUserId();
    if (Platform.isAndroid && userId != null && userId.isNotEmpty) {
      final name = await UserStorage.getAndroidBackupTreeName(userId);
      if (name != null && name.isNotEmpty) return name;
    }
    return (await resolveDefaultBackupDirectory()).path;
  }

  /// Resolve the app-managed default backup directory.
  static Future<Directory> resolveDefaultBackupDirectory() async {
    String rootPath;

    if (Platform.isIOS) {
      rootPath = await UserStorage.resolveICloudDocumentsPath() ??
          (await getApplicationDocumentsDirectory()).path;
    } else if (Platform.isAndroid) {
      rootPath = (await getExternalStorageDirectory())?.path ??
          (await getApplicationDocumentsDirectory()).path;
    } else {
      rootPath = (await getApplicationDocumentsDirectory()).path;
    }

    final dir = Directory(path.join(rootPath, 'Backups'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get estimated backup size (workspace + DB).
  static Future<int> estimateBackupSize() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return 0;

    final stats = await _collectSourceStats(userId);
    return stats.totalSize;
  }

  /// Recursively add a directory to the archive.
  static Future<void> _addDirectoryToArchive(
    Archive archive,
    String dirPath,
    String archivePrefix, {
    required List<Map<String, dynamic>> manifestEntries,
    List<String> excludedRootPaths = const [],
  }) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (excludedRootPaths.any((root) => _isPathWithin(root, entity.path))) {
        continue;
      }

      final relativePath = path.relative(entity.path, from: dirPath);
      final archivePath = '$archivePrefix/$relativePath';
      try {
        final bytes = await entity.readAsBytes();
        _addBytesToArchive(
          archive,
          archivePath,
          bytes,
          manifestEntries: manifestEntries,
        );
      } catch (e) {
        _logger.warning('Skipping file ${entity.path}: $e');
      }
    }
  }

  static void _addBytesToArchive(
    Archive archive,
    String archivePath,
    List<int> bytes, {
    List<Map<String, dynamic>>? manifestEntries,
  }) {
    archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
    manifestEntries?.add({
      'path': archivePath,
      'size': bytes.length,
      'sha256': sha256.convert(bytes).toString(),
    });
  }

  static void _validateManifest(Archive archive) {
    final manifestFile = _findArchiveFile(archive, _backupManifestFileName);
    if (manifestFile == null) {
      _logger.warning('Backup has no manifest.json; treating as legacy backup');
      return;
    }

    final manifestJson = utf8.decode(_archiveFileBytes(manifestFile));
    final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
    final entries = manifest['entries'];
    if (entries is! List) return;

    for (final entry in entries) {
      if (entry is! Map) continue;
      final entryPath = entry['path'] as String?;
      final expectedSha = entry['sha256'] as String?;
      if (entryPath == null || expectedSha == null) continue;

      final file = _findArchiveFile(archive, entryPath);
      if (file == null || !file.isFile) {
        throw Exception('Backup is missing manifest entry: $entryPath');
      }
      final actualSha = sha256.convert(_archiveFileBytes(file)).toString();
      if (actualSha != expectedSha) {
        throw Exception('Backup checksum mismatch: $entryPath');
      }
    }
  }

  static ArchiveFile? _findArchiveFile(Archive archive, String name) {
    for (final file in archive) {
      if (file.name == name) return file;
    }
    return null;
  }

  static List<int> _archiveFileBytes(ArchiveFile file) {
    return List<int>.from(file.content as List);
  }

  static String _timestampForFile(DateTime time) {
    return time.toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
  }

  static bool _isPathWithin(String parentPath, String childPath) {
    final parent = path.normalize(path.absolute(parentPath));
    final child = path.normalize(path.absolute(childPath));
    return child == parent || path.isWithin(parent, child);
  }

  static Future<_BackupSourceStats> _collectSourceStats(String userId) async {
    final fs = FileSystemService.instance;
    final workspacePath = fs.getWorkspacePath(userId);
    var totalSize = 0;
    var fileCount = 0;
    var latestModifiedMs = 0;

    final workspaceDir = Directory(workspacePath);
    if (await workspaceDir.exists()) {
      await for (final entity in workspaceDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            totalSize += stat.size;
            fileCount += 1;
            latestModifiedMs =
                latestModifiedMs > stat.modified.millisecondsSinceEpoch
                    ? latestModifiedMs
                    : stat.modified.millisecondsSinceEpoch;
          } catch (_) {}
        }
      }
    }

    final dbName = 'memex_local_$userId.sqlite';
    final appDir = await getApplicationDocumentsDirectory();
    final supportDir = await getApplicationSupportDirectory();
    for (final dbPath in [
      path.join(appDir.path, dbName),
      path.join(supportDir.path, dbName),
    ]) {
      final file = File(dbPath);
      if (await file.exists()) {
        final stat = await file.stat();
        totalSize += stat.size;
        fileCount += 1;
        latestModifiedMs =
            latestModifiedMs > stat.modified.millisecondsSinceEpoch
                ? latestModifiedMs
                : stat.modified.millisecondsSinceEpoch;
        break;
      }
    }

    return _BackupSourceStats(
      totalSize: totalSize,
      fileCount: fileCount,
      latestModifiedMs: latestModifiedMs,
    );
  }

  static Future<String> _calculateSourceFingerprint(String userId) async {
    final stats = await _collectSourceStats(userId);
    return '${stats.fileCount}:${stats.totalSize}:${stats.latestModifiedMs}';
  }

  static Future<List<BackupSnapshot>> _listFileBackups(Directory dir) async {
    if (!await dir.exists()) return [];

    final snapshots = <BackupSnapshot>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = path.basename(entity.path);
      if (!name.endsWith(_backupExtension)) continue;

      try {
        final stat = await entity.stat();
        snapshots.add(
          BackupSnapshot(
            id: entity.path,
            name: name,
            createdAt: stat.modified,
            sizeBytes: stat.size,
            filePath: entity.path,
          ),
        );
      } catch (e) {
        _logger.warning('Failed to inspect backup ${entity.path}: $e');
      }
    }
    snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return snapshots;
  }

  static Future<List<BackupSnapshot>> _listAndroidTreeBackups(
    String treeUri,
  ) async {
    final result = await _backupStorageChannel.invokeListMethod<dynamic>(
      'listBackupFiles',
      {'treeUri': treeUri},
    );
    if (result == null) return [];

    return result
        .whereType<Map>()
        .map((item) => _snapshotFromAndroidInfo(item.cast<String, dynamic>()))
        .where((snapshot) => snapshot.name.endsWith(_backupExtension))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static BackupSnapshot _snapshotFromAndroidInfo(Map<String, dynamic> info) {
    final documentUri = info['documentUri'] as String?;
    final name = info['name'] as String? ?? 'backup$_backupExtension';
    final modifiedMs = (info['lastModified'] as num?)?.toInt();
    final sizeBytes = (info['size'] as num?)?.toInt() ?? 0;

    return BackupSnapshot(
      id: documentUri ?? name,
      name: name,
      createdAt: modifiedMs == null || modifiedMs <= 0
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(modifiedMs),
      sizeBytes: sizeBytes,
      documentUri: documentUri,
    );
  }

  static Future<Map<String, dynamic>> _writeFileToAndroidTree({
    required String treeUri,
    required String sourcePath,
    required String fileName,
  }) async {
    final result = await _backupStorageChannel.invokeMapMethod<String, dynamic>(
      'writeFileToTree',
      {'treeUri': treeUri, 'sourcePath': sourcePath, 'fileName': fileName},
    );
    if (result == null) {
      throw Exception('Android backup write returned no result');
    }
    return result;
  }

  static Future<String> _copyAndroidDocumentToTempFile({
    required String documentUri,
    required String fileName,
  }) async {
    final result = await _backupStorageChannel.invokeMethod<String>(
      'copyDocumentToCache',
      {'documentUri': documentUri, 'fileName': fileName},
    );
    if (result == null || result.isEmpty) {
      throw Exception('Android backup copy returned no file path');
    }
    return result;
  }

  static Future<void> _pruneFileBackups(Directory dir) async {
    final snapshots = (await _listFileBackups(dir))
        .where((snapshot) => snapshot.name.startsWith(_autoBackupPrefix))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    var kept = 0;
    var keptBytes = 0;
    for (final snapshot in snapshots) {
      final shouldKeep = kept < _autoBackupKeepRecent &&
          keptBytes + snapshot.sizeBytes <= _autoBackupMaxBytes;
      if (shouldKeep) {
        kept += 1;
        keptBytes += snapshot.sizeBytes;
        continue;
      }

      final filePath = snapshot.filePath;
      if (filePath == null) continue;
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        _logger.warning('Failed to delete old backup $filePath: $e');
      }
    }
  }

  static Future<void> _pruneAndroidTreeBackups(String treeUri) async {
    final snapshots = (await _listAndroidTreeBackups(treeUri))
        .where((snapshot) => snapshot.name.startsWith(_autoBackupPrefix))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    var kept = 0;
    var keptBytes = 0;
    for (final snapshot in snapshots) {
      final shouldKeep = kept < _autoBackupKeepRecent &&
          keptBytes + snapshot.sizeBytes <= _autoBackupMaxBytes;
      if (shouldKeep) {
        kept += 1;
        keptBytes += snapshot.sizeBytes;
        continue;
      }

      final documentUri = snapshot.documentUri;
      if (documentUri == null) continue;
      try {
        await _backupStorageChannel.invokeMethod<void>('deleteDocument', {
          'documentUri': documentUri,
        });
      } catch (e) {
        _logger.warning('Failed to delete old Android backup $documentUri: $e');
      }
    }
  }

  static Future<BackupFileInfo> inspectBackup(String backupFilePath) async {
    final normalizedPath = _normalizeFilePath(backupFilePath);
    if (!isSelectableBackupFile(normalizedPath)) {
      throw const InvalidBackupFileException(
        'Invalid backup file. Please select a .memex file.',
      );
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      throw InvalidBackupFileException(
        'Backup file does not exist: $normalizedPath',
      );
    }

    final bytes = await file.readAsBytes();
    final archive = _decodeBackup(bytes);
    ArchiveFile? manifestFile;
    for (final file in archive.files) {
      if (file.isFile && file.name == _backupManifestFileName) {
        manifestFile = file;
        break;
      }
    }

    if (manifestFile == null) {
      if (!_looksLikeLegacyBackup(archive)) {
        throw const InvalidBackupFileException(
          'Invalid backup file. Please select a .memex file.',
        );
      }
      return BackupFileInfo(
        path: normalizedPath,
        sizeBytes: bytes.length,
        manifest: null,
      );
    }

    final manifest = _readManifest(manifestFile);
    if (manifest.format != _backupFormat) {
      throw InvalidBackupFileException(
        'Unsupported backup format: ${manifest.format}',
      );
    }
    if (manifest.backupSchemaVersion > _currentBackupSchemaVersion) {
      throw UnsupportedBackupVersionException(
        backupSchemaVersion: manifest.backupSchemaVersion,
        supportedSchemaVersion: _currentBackupSchemaVersion,
      );
    }

    return BackupFileInfo(
      path: normalizedPath,
      sizeBytes: bytes.length,
      manifest: manifest,
    );
  }

  static bool _looksLikeLegacyBackup(Archive archive) {
    return archive.files.any(
      (file) =>
          file.name == 'settings.json' ||
          file.name.startsWith('workspace/') ||
          file.name.startsWith('db/'),
    );
  }

  static Future<BackupManifest> _createManifest({
    required DateTime createdAt,
    required String userId,
    required List<Map<String, dynamic>> entries,
  }) async {
    var appVersion = 'unknown';
    var buildNumber = '';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } catch (_) {}

    return BackupManifest(
      format: _backupFormat,
      formatVersion: 1,
      backupSchemaVersion: _currentBackupSchemaVersion,
      createdAt: createdAt.toUtc(),
      userId: userId,
      appVersion: appVersion,
      buildNumber: buildNumber,
      flavor: AppFlavor.name,
      platform: Platform.operatingSystem,
      entries: List<Map<String, dynamic>>.unmodifiable(entries),
    );
  }

  static Archive _decodeBackup(List<int> bytes) {
    try {
      return ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const InvalidBackupFileException(
        'Invalid backup file. Please select a .memex file.',
      );
    }
  }

  static BackupManifest _readManifest(ArchiveFile manifestFile) {
    try {
      final jsonStr = utf8.decode(_archiveFileBytes(manifestFile));
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return BackupManifest.fromJson(json);
    } catch (_) {
      throw const InvalidBackupFileException('Invalid backup manifest.');
    }
  }

  static String _normalizeFilePath(String filePath) {
    if (filePath.startsWith('file://')) {
      try {
        return Uri.parse(filePath).toFilePath();
      } catch (_) {
        return filePath.replaceFirst('file://', '');
      }
    }
    return filePath;
  }
}

class _BackupSourceStats {
  final int totalSize;
  final int fileCount;
  final int latestModifiedMs;

  const _BackupSourceStats({
    required this.totalSize,
    required this.fileCount,
    required this.latestModifiedMs,
  });
}
