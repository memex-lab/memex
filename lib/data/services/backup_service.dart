import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/data/services/agent_background_coordinator.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_service.dart';
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
const _backupStoreWithoutCompressionThreshold = 16 * 1024 * 1024; // 16 MB
const _backupManifestFileName = 'manifest.json';
const _backupFormat = 'memex.backup';
const _currentBackupSchemaVersion = 1;
const _backupStoreWithoutCompressionExtensions = <String>{
  '.7z',
  '.aac',
  '.avi',
  '.bz2',
  '.gif',
  '.gz',
  '.heic',
  '.heif',
  '.jpeg',
  '.jpg',
  '.m4a',
  '.m4v',
  '.mkv',
  '.mov',
  '.mp3',
  '.mp4',
  '.ogg',
  '.opus',
  '.pdf',
  '.png',
  '.rar',
  '.webm',
  '.webp',
  '.zip',
};

/// Android Storage Access Framework directory selected for backups.
class AndroidBackupDirectory {
  final String treeUri;
  final String displayName;

  const AndroidBackupDirectory({
    required this.treeUri,
    required this.displayName,
  });
}

enum BackupLocationKind { fileSystem, androidTree, iosICloud, iosAppDocuments }

/// Current automatic backup location, split into a concise label and the
/// underlying path/URI for copyable details.
class BackupLocationInfo {
  final BackupLocationKind kind;
  final String label;
  final String detail;

  const BackupLocationInfo({
    required this.kind,
    required this.label,
    required this.detail,
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
  bool get isAutoSnapshot => name.startsWith(_autoBackupPrefix);
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

    // 1. Prepare source metadata on the main isolate. The expensive file
    // reads and zip compression run below in a background isolate.
    onProgress?.call('Packing workspace...');

    final dbName = 'memex_local_$userId.sqlite';
    // drift_flutter stores DB in app support directory on iOS, app documents on Android
    final possibleDbPaths = [
      path.join(appDir.path, dbName),
      path.join((await getApplicationSupportDirectory()).path, dbName),
    ];

    // 2. Add SharedPreferences settings — backup ALL non-internal keys
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

    var appVersion = 'unknown';
    var buildNumber = '';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } catch (_) {}

    // 3. Write zip in a background isolate. Automatic path writes use temp +
    // rename in the same dir.
    onProgress?.call('Compressing...');
    final archiveResult = await Isolate.run(
      () => _writeBackupArchive(
        workspacePath: workspacePath,
        excludedWorkspaceRootPaths: [
          path.join(workspacePath, 'Backups'),
          if (outputDirectory != null) outputDirectory,
        ],
        dbPaths: possibleDbPaths,
        dbName: dbName,
        settingsBytes: utf8.encode(jsonEncode(settings)),
        tempOutputPath: tempOutputPath,
        createdAt: createdAt,
        userId: userId,
        appVersion: appVersion,
        buildNumber: buildNumber,
        flavor: AppFlavor.name,
        platform: Platform.operatingSystem,
      ),
    );

    if (outputDirectory != null) {
      final tempFile = File(tempOutputPath);
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
      await tempFile.rename(outputPath);
    }

    _logger.info(
      'Backup created: $outputPath '
      '(${archiveResult.sizeBytes} bytes, ${archiveResult.fileCount} files)',
    );
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
    Directory? stagingRoot;

    try {
      onProgress?.call('Inspecting backup...');
      final backupInfo = await inspectBackup(backupFilePath);
      final normalizedPath = backupInfo.path;

      onProgress?.call('Preparing restore...');
      stagingRoot = await _createRestoreStagingDirectory();
      final stagingWorkspacePath = path.join(stagingRoot.path, 'workspace');
      final stagingDbPath = path.join(stagingRoot.path, 'db');
      final stagedRestore = await Isolate.run(
        () => _stageBackupRestoreArchive(
          backupFilePath: normalizedPath,
          stagingWorkspacePath: stagingWorkspacePath,
          stagingDbPath: stagingDbPath,
        ),
      );
      _logger.info(
        'Staged restore from $normalizedPath '
        '(${stagedRestore.workspaceFileCount} workspace files, '
        '${stagedRestore.dbFileCount} DB files)',
      );

      // 1. Restore settings FIRST to get the correct userId and data root.
      onProgress?.call('Restoring settings...');
      await _restoreSettings(stagedRestore.settings);
      _logger.info('Restored ${stagedRestore.settings.length} settings');

      // Use the restored userId (from backup settings) for workspace and DB paths
      final restoredUserId = await UserStorage.getUserId() ?? currentUserId;
      final dataRoot = await UserStorage.resolveDataRoot(restoredUserId);
      await FileSystemService.init(dataRoot);
      final fs = FileSystemService.instance;
      final workspacePath = fs.getWorkspacePath(restoredUserId);
      final appDir = await getApplicationDocumentsDirectory();
      final supportDir = await getApplicationSupportDirectory();

      // Stop background writers before replacing the workspace and SQLite file.
      onProgress?.call('Stopping background work...');
      await AgentBackgroundCoordinator.instance.stop();
      await LocalTaskExecutor.instance.stop();

      // 2. Close current DB before replacing DB files.
      onProgress?.call('Restoring database...');
      if (AppDatabase.isInitialized) {
        databaseClosedForRestore = true;
        await AppDatabase.instance.close();
      }

      // 3. Apply staged workspace and DB files in a background isolate.
      onProgress?.call('Restoring workspace...');
      await Isolate.run(
        () => _applyStagedBackupRestore(
          stagingWorkspacePath: stagingWorkspacePath,
          stagingDbPath: stagingDbPath,
          workspacePath: workspacePath,
          appDocumentsPath: appDir.path,
          appSupportPath: supportDir.path,
        ),
      );

      // Re-init DB
      await AppDatabase.init(restoredUserId);
      await PersonaChatService.instance.initialize(
        restoredUserId,
        AppDatabase.instance,
      );
      databaseClosedForRestore = false;

      // 4. Rebuild card cache
      onProgress?.call('Rebuilding cache...');
      await fs.rebuildCardCache(restoredUserId);

      _logger.info('Backup restored successfully');
      EventBusService.instance.emitEvent(
        BackupRestoredMessage(
          userId: restoredUserId,
          sourcePath: normalizedPath,
        ),
      );
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
    } finally {
      final dir = stagingRoot;
      if (dir != null && await dir.exists()) {
        try {
          await dir.delete(recursive: true);
        } catch (e) {
          _logger.warning('Failed to delete restore staging dir: $e');
        }
      }
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

      final shouldSkip = !force &&
          ((lastBackupAt != null &&
                  now.difference(lastBackupAt) < _autoBackupInterval) ||
              lastFingerprint == fingerprint);

      if (shouldSkip) {
        await pruneAutoBackups(now: now);
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
            await BackupService.pruneAutoBackups(emitEvent: false);
          }
          _emitBackupSnapshotsChanged('created', snapshotId: snapshot.id);
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
      await BackupService.pruneAutoBackups(emitEvent: false);
    }
    _emitBackupSnapshotsChanged('created', snapshotId: snapshot.id);
    return snapshot;
  }

  /// Apply the automatic backup retention policy without creating a new backup.
  ///
  /// Only snapshots created by the automatic system are removed. Safety
  /// snapshots and manually exported files are intentionally left alone.
  static Future<int> pruneAutoBackups({
    DateTime? now,
    bool emitEvent = true,
  }) async {
    final userId = await UserStorage.getUserId();
    if (userId == null || userId.isEmpty) return 0;

    final cleanupNow = now ?? DateTime.now();
    final retentionDays = await UserStorage.getAutoBackupRetentionDays(userId);
    final maxBytes = await UserStorage.getAutoBackupMaxBytes(userId);
    var deleted = 0;

    try {
      final defaultDir = await resolveDefaultBackupDirectory();
      deleted += await _pruneFileBackups(
        defaultDir,
        now: cleanupNow,
        retentionDays: retentionDays,
        maxBytes: maxBytes,
      );
    } catch (e, st) {
      _logger.warning('Failed to prune default backups: $e', e, st);
    }

    if (Platform.isAndroid) {
      final treeUri = await UserStorage.getAndroidBackupTreeUri(userId);
      if (treeUri != null && treeUri.isNotEmpty) {
        try {
          deleted += await _pruneAndroidTreeBackups(
            treeUri,
            now: cleanupNow,
            retentionDays: retentionDays,
            maxBytes: maxBytes,
          );
        } catch (e, st) {
          _logger.warning('Failed to prune Android backups: $e', e, st);
        }
      }
    }

    if (deleted > 0 && emitEvent) {
      _emitBackupSnapshotsChanged('pruned');
    }
    return deleted;
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

  /// Delete a stored automatic/safety backup snapshot.
  static Future<void> deleteStoredBackup(BackupSnapshot snapshot) async {
    if (snapshot.isAndroidDocument) {
      await _deleteAndroidDocument(snapshot.documentUri!);
      _emitBackupSnapshotsChanged('deleted', snapshotId: snapshot.id);
      return;
    }

    final filePath = snapshot.filePath;
    if (filePath == null || filePath.isEmpty) {
      throw Exception('Backup snapshot has no deletable source');
    }

    final normalizedPath = _normalizeFilePath(filePath);
    if (!isMemexBackupFile(normalizedPath)) {
      throw const InvalidBackupFileException(
        'Invalid backup file. Please select a .memex file.',
      );
    }

    final file = File(normalizedPath);
    if (await file.exists()) {
      await file.delete();
    }
    _emitBackupSnapshotsChanged('deleted', snapshotId: snapshot.id);
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
    final info = await currentBackupLocationInfo();
    return info.label;
  }

  /// Current automatic backup location with full path/URI details.
  static Future<BackupLocationInfo> currentBackupLocationInfo() async {
    final userId = await UserStorage.getUserId();
    if (Platform.isAndroid && userId != null && userId.isNotEmpty) {
      final treeUri = await UserStorage.getAndroidBackupTreeUri(userId);
      final name = await UserStorage.getAndroidBackupTreeName(userId);
      if (treeUri != null && treeUri.isNotEmpty) {
        return BackupLocationInfo(
          kind: BackupLocationKind.androidTree,
          label: name != null && name.isNotEmpty ? name : treeUri,
          detail: treeUri,
        );
      }
    }

    if (Platform.isIOS) {
      final iCloudDocumentsPath =
          await UserStorage.resolveICloudDocumentsPath();
      if (iCloudDocumentsPath != null && iCloudDocumentsPath.isNotEmpty) {
        final backupDir = await _ensureBackupDirectory(iCloudDocumentsPath);
        return BackupLocationInfo(
          kind: BackupLocationKind.iosICloud,
          label: backupDir.path,
          detail: backupDir.path,
        );
      }

      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = await _ensureBackupDirectory(appDir.path);
      return BackupLocationInfo(
        kind: BackupLocationKind.iosAppDocuments,
        label: backupDir.path,
        detail: backupDir.path,
      );
    }

    final backupDir = await resolveDefaultBackupDirectory();
    return BackupLocationInfo(
      kind: BackupLocationKind.fileSystem,
      label: backupDir.path,
      detail: backupDir.path,
    );
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

    return _ensureBackupDirectory(rootPath);
  }

  static Future<Directory> _ensureBackupDirectory(String rootPath) async {
    final dir = Directory(path.join(rootPath, 'Backups'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> _createRestoreStagingDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final dir = Directory(
      path.join(
        tempDir.path,
        'memex_restore_${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    return dir.create(recursive: true);
  }

  static Future<void> _restoreSettings(Map<String, dynamic> settings) async {
    if (settings.isEmpty) return;

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
  }

  static void _emitBackupSnapshotsChanged(String reason, {String? snapshotId}) {
    EventBusService.instance.emitEvent(
      BackupSnapshotsChangedMessage(reason: reason, snapshotId: snapshotId),
    );
  }

  /// Get estimated backup size (workspace + DB).
  static Future<int> estimateBackupSize() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return 0;

    final stats = await _collectSourceStats(userId);
    return stats.totalSize;
  }

  static ArchiveFile? _findArchiveFile(Archive archive, String name) {
    for (final file in archive) {
      if (file.name == name) return file;
    }
    return null;
  }

  static List<int> _archiveFileBytes(ArchiveFile file) {
    return file.readBytes() ?? const <int>[];
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

  static Future<int> _pruneFileBackups(
    Directory dir, {
    required DateTime now,
    required int? retentionDays,
    required int maxBytes,
  }) async {
    final snapshots = (await _listFileBackups(dir))
        .where((snapshot) => snapshot.name.startsWith(_autoBackupPrefix))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    var kept = 0;
    var keptBytes = 0;
    var deleted = 0;
    for (final snapshot in snapshots) {
      final shouldKeep = _shouldKeepAutoBackup(
        snapshot: snapshot,
        now: now,
        retentionDays: retentionDays,
        maxBytes: maxBytes,
        keptCount: kept,
        keptBytes: keptBytes,
      );
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
          deleted += 1;
        }
      } catch (e) {
        _logger.warning('Failed to delete old backup $filePath: $e');
      }
    }
    return deleted;
  }

  static Future<int> _pruneAndroidTreeBackups(
    String treeUri, {
    required DateTime now,
    required int? retentionDays,
    required int maxBytes,
  }) async {
    final snapshots = (await _listAndroidTreeBackups(treeUri))
        .where((snapshot) => snapshot.name.startsWith(_autoBackupPrefix))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    var kept = 0;
    var keptBytes = 0;
    var deleted = 0;
    for (final snapshot in snapshots) {
      final shouldKeep = _shouldKeepAutoBackup(
        snapshot: snapshot,
        now: now,
        retentionDays: retentionDays,
        maxBytes: maxBytes,
        keptCount: kept,
        keptBytes: keptBytes,
      );
      if (shouldKeep) {
        kept += 1;
        keptBytes += snapshot.sizeBytes;
        continue;
      }

      final documentUri = snapshot.documentUri;
      if (documentUri == null) continue;
      try {
        await _deleteAndroidDocument(documentUri);
        deleted += 1;
      } catch (e) {
        _logger.warning('Failed to delete old Android backup $documentUri: $e');
      }
    }
    return deleted;
  }

  static bool _shouldKeepAutoBackup({
    required BackupSnapshot snapshot,
    required DateTime now,
    required int? retentionDays,
    required int maxBytes,
    required int keptCount,
    required int keptBytes,
  }) {
    if (keptCount == 0) return true;

    final cutoff = retentionDays == null
        ? null
        : now.subtract(Duration(days: retentionDays));
    final expiredByAge = cutoff != null && snapshot.createdAt.isBefore(cutoff);
    if (expiredByAge) return false;

    return keptBytes + snapshot.sizeBytes <= maxBytes;
  }

  static Future<void> _deleteAndroidDocument(String documentUri) async {
    await _backupStorageChannel.invokeMethod<void>('deleteDocument', {
      'documentUri': documentUri,
    });
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

    final stat = await file.stat();
    return Isolate.run(
      () => _inspectBackupFile(
        backupFilePath: normalizedPath,
        sizeBytes: stat.size,
      ),
    );
  }

  static BackupFileInfo _inspectBackupFile({
    required String backupFilePath,
    required int sizeBytes,
  }) {
    final archive = _decodeBackupFile(backupFilePath);
    ArchiveFile? manifestFile;
    try {
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
          path: backupFilePath,
          sizeBytes: sizeBytes,
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
        path: backupFilePath,
        sizeBytes: sizeBytes,
        manifest: manifest,
      );
    } finally {
      archive.clearSync();
    }
  }

  static bool _looksLikeLegacyBackup(Archive archive) {
    return archive.files.any(
      (file) =>
          file.name == 'settings.json' ||
          file.name.startsWith('workspace/') ||
          file.name.startsWith('db/'),
    );
  }

  static Archive _decodeBackupFile(String backupFilePath) {
    try {
      return ZipDecoder().decodeStream(InputFileStream(backupFilePath));
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

Future<_StagedRestoreResult> _stageBackupRestoreArchive({
  required String backupFilePath,
  required String stagingWorkspacePath,
  required String stagingDbPath,
}) async {
  final archive = BackupService._decodeBackupFile(backupFilePath);

  try {
    final manifestFile = BackupService._findArchiveFile(
      archive,
      _backupManifestFileName,
    );
    final manifest =
        manifestFile == null ? null : BackupService._readManifest(manifestFile);
    if (manifest != null) {
      _validateBackupManifestHeader(manifest);
    }

    final expectedShas = _manifestEntryShas(manifest);
    final verifiedEntries = <String>{};
    var looksLikeBackup = false;
    var workspaceFileCount = 0;
    var dbFileCount = 0;
    var settings = <String, dynamic>{};

    for (final file in archive) {
      if (!file.isFile) continue;

      if (file.name == 'settings.json') {
        looksLikeBackup = true;
        final bytes = BackupService._archiveFileBytes(file);
        _verifyEntrySha(
          file.name,
          sha256.convert(bytes).toString(),
          expectedShas,
          verifiedEntries,
        );
        final decoded = jsonDecode(utf8.decode(bytes));
        if (decoded is Map) {
          settings = decoded.cast<String, dynamic>();
        } else {
          throw const InvalidBackupFileException('Invalid backup settings.');
        }
        continue;
      }

      if (file.name.startsWith('workspace/')) {
        looksLikeBackup = true;
        final relativePath = file.name.substring('workspace/'.length);
        if (relativePath.isEmpty) continue;

        final targetPath = path.normalize(
          path.join(stagingWorkspacePath, relativePath),
        );
        if (!BackupService._isPathWithin(stagingWorkspacePath, targetPath)) {
          throw Exception('Unsafe backup entry path: ${file.name}');
        }

        await _extractArchiveFile(file, targetPath);
        await _verifyExtractedFileSha(
          file.name,
          targetPath,
          expectedShas,
          verifiedEntries,
        );
        workspaceFileCount += 1;
        continue;
      }

      if (file.name.startsWith('db/')) {
        looksLikeBackup = true;
        final relativePath = file.name.substring('db/'.length);
        if (relativePath.isEmpty ||
            path.basename(relativePath) != relativePath) {
          throw Exception('Unsafe backup entry path: ${file.name}');
        }

        final targetPath = path.normalize(
          path.join(stagingDbPath, relativePath),
        );
        if (!BackupService._isPathWithin(stagingDbPath, targetPath)) {
          throw Exception('Unsafe backup entry path: ${file.name}');
        }

        await _extractArchiveFile(file, targetPath);
        await _verifyExtractedFileSha(
          file.name,
          targetPath,
          expectedShas,
          verifiedEntries,
        );
        dbFileCount += 1;
      }
    }

    if (manifest == null && !looksLikeBackup) {
      throw const InvalidBackupFileException(
        'Invalid backup file. Please select a .memex file.',
      );
    }

    for (final entryPath in expectedShas.keys) {
      if (!verifiedEntries.contains(entryPath)) {
        throw Exception('Backup is missing manifest entry: $entryPath');
      }
    }

    return _StagedRestoreResult(
      settings: settings,
      workspaceFileCount: workspaceFileCount,
      dbFileCount: dbFileCount,
    );
  } finally {
    archive.clearSync();
  }
}

Future<void> _applyStagedBackupRestore({
  required String stagingWorkspacePath,
  required String stagingDbPath,
  required String workspacePath,
  required String appDocumentsPath,
  required String appSupportPath,
}) async {
  final stagingWorkspace = Directory(stagingWorkspacePath);
  final sourceRelPaths = <String>{};
  if (await stagingWorkspace.exists()) {
    await for (final entity in stagingWorkspace.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;

      final relativePath = path.relative(
        entity.path,
        from: stagingWorkspacePath,
      );
      final targetPath = path.normalize(path.join(workspacePath, relativePath));
      if (!BackupService._isPathWithin(workspacePath, targetPath)) {
        throw Exception('Unsafe staged workspace path: $relativePath');
      }
      sourceRelPaths.add(relativePath);
      var dir = path.dirname(relativePath);
      while (dir != '.' && dir.isNotEmpty) {
        sourceRelPaths.add(dir);
        dir = path.dirname(dir);
      }
      await _moveFileReplacing(entity, targetPath);
    }
  }

  await _removeStaleWorkspaceFiles(
    workspacePath: workspacePath,
    sourceRelPaths: sourceRelPaths,
  );

  final stagingDb = Directory(stagingDbPath);
  if (await stagingDb.exists()) {
    await for (final entity in stagingDb.list(followLinks: false)) {
      if (entity is! File) continue;

      final dbFileName = path.basename(entity.path);
      final possibleTargets = [
        path.join(appDocumentsPath, dbFileName),
        path.join(appSupportPath, dbFileName),
      ];
      var targetPath = possibleTargets.last;
      for (final candidate in possibleTargets) {
        if (await File(candidate).exists()) {
          targetPath = candidate;
          break;
        }
      }
      await _moveFileReplacing(entity, targetPath);
    }
  }
}

/// Delete workspace files that are not in the backup. `Backups/` is excluded
/// from archives, so it is preserved locally across restore.
Future<void> _removeStaleWorkspaceFiles({
  required String workspacePath,
  required Set<String> sourceRelPaths,
}) async {
  final destDir = Directory(workspacePath);
  if (!await destDir.exists()) return;

  final destEntities = <FileSystemEntity>[];
  await for (final entity
      in destDir.list(recursive: true, followLinks: false)) {
    destEntities.add(entity);
  }
  destEntities.sort((a, b) => b.path.length.compareTo(a.path.length));

  for (final entity in destEntities) {
    final relativePath = path.relative(entity.path, from: workspacePath);
    if (relativePath == '.' || relativePath.isEmpty) continue;
    final firstSegment = path.split(relativePath).first;
    if (firstSegment == 'Backups') continue;
    if (sourceRelPaths.contains(relativePath)) continue;

    try {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await entity.delete(recursive: true);
      }
    } catch (e) {
      BackupService._logger.warning(
        'Failed to remove stale restore path ${entity.path}: $e',
      );
    }
  }
}

void _validateBackupManifestHeader(BackupManifest manifest) {
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
}

Map<String, String> _manifestEntryShas(BackupManifest? manifest) {
  if (manifest == null) return const {};

  final result = <String, String>{};
  for (final entry in manifest.entries) {
    final entryPath = entry['path'] as String?;
    final expectedSha = entry['sha256'] as String?;
    if (entryPath == null || expectedSha == null) continue;
    result[entryPath] = expectedSha;
  }
  return result;
}

Future<void> _extractArchiveFile(ArchiveFile file, String targetPath) async {
  final targetDir = Directory(path.dirname(targetPath));
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }

  final output = OutputFileStream(targetPath);
  try {
    file.writeContent(output);
  } finally {
    output.closeSync();
  }
}

Future<void> _verifyExtractedFileSha(
  String entryPath,
  String targetPath,
  Map<String, String> expectedShas,
  Set<String> verifiedEntries,
) async {
  final expectedSha = expectedShas[entryPath];
  if (expectedSha == null) return;

  final actualSha = await _sha256FilePath(targetPath);
  _verifyEntrySha(entryPath, actualSha, expectedShas, verifiedEntries);
}

void _verifyEntrySha(
  String entryPath,
  String actualSha,
  Map<String, String> expectedShas,
  Set<String> verifiedEntries,
) {
  final expectedSha = expectedShas[entryPath];
  if (expectedSha == null) return;

  verifiedEntries.add(entryPath);
  if (actualSha != expectedSha) {
    throw Exception('Backup checksum mismatch: $entryPath');
  }
}

Future<String> _sha256FilePath(String filePath) async {
  final digest = await sha256.bind(File(filePath).openRead()).first;
  return digest.toString();
}

Future<void> _moveFileReplacing(File source, String targetPath) async {
  final targetDir = Directory(path.dirname(targetPath));
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }

  final targetFile = File(targetPath);
  if (await targetFile.exists()) {
    await targetFile.delete();
  }

  try {
    await source.rename(targetPath);
  } catch (_) {
    await source.openRead().pipe(targetFile.openWrite());
    if (await source.exists()) {
      await source.delete();
    }
  }
}

Future<_BackupArchiveResult> _writeBackupArchive({
  required String workspacePath,
  required List<String> excludedWorkspaceRootPaths,
  required List<String> dbPaths,
  required String dbName,
  required List<int> settingsBytes,
  required String tempOutputPath,
  required DateTime createdAt,
  required String userId,
  required String appVersion,
  required String buildNumber,
  required String flavor,
  required String platform,
}) async {
  final manifestEntries = <Map<String, dynamic>>[];
  final encoder = ZipFileEncoder();
  var fileCount = 0;

  try {
    encoder.create(tempOutputPath, level: ZipFileEncoder.gzip);

    fileCount += await _addDirectoryToBackupArchive(
      encoder,
      workspacePath,
      'workspace',
      manifestEntries: manifestEntries,
      excludedRootPaths: excludedWorkspaceRootPaths,
    );

    for (final dbPath in dbPaths) {
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) continue;
      await _addFileToBackupArchive(
        encoder,
        dbFile,
        'db/$dbName',
        manifestEntries,
      );
      fileCount += 1;
      break;
    }

    _addBytesToBackupArchive(
      encoder,
      'settings.json',
      settingsBytes,
      manifestEntries: manifestEntries,
    );
    fileCount += 1;

    final manifest = BackupManifest(
      format: _backupFormat,
      formatVersion: 1,
      backupSchemaVersion: _currentBackupSchemaVersion,
      createdAt: createdAt.toUtc(),
      userId: userId,
      appVersion: appVersion,
      buildNumber: buildNumber,
      flavor: flavor,
      platform: platform,
      entries: List<Map<String, dynamic>>.unmodifiable(manifestEntries),
    );
    _addBytesToBackupArchive(
      encoder,
      _backupManifestFileName,
      utf8.encode(jsonEncode(manifest.toJson())),
    );
    fileCount += 1;

    await encoder.close();
  } catch (_) {
    try {
      await encoder.close();
    } catch (_) {}
    final tempFile = File(tempOutputPath);
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
    rethrow;
  }

  final sizeBytes = await File(tempOutputPath).length();
  return _BackupArchiveResult(sizeBytes: sizeBytes, fileCount: fileCount);
}

Future<int> _addDirectoryToBackupArchive(
  ZipFileEncoder encoder,
  String dirPath,
  String archivePrefix, {
  required List<Map<String, dynamic>> manifestEntries,
  List<String> excludedRootPaths = const [],
}) async {
  final dir = Directory(dirPath);
  if (!await dir.exists()) return 0;

  var fileCount = 0;
  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (excludedRootPaths.any(
      (root) => BackupService._isPathWithin(root, entity.path),
    )) {
      continue;
    }

    final relativePath = path.relative(entity.path, from: dirPath);
    final archivePath = '$archivePrefix/$relativePath';
    try {
      await _addFileToBackupArchive(
        encoder,
        entity,
        archivePath,
        manifestEntries,
      );
      fileCount += 1;
    } catch (e) {
      BackupService._logger.warning('Skipping file ${entity.path}: $e');
    }
  }

  return fileCount;
}

Future<void> _addFileToBackupArchive(
  ZipFileEncoder encoder,
  File file,
  String archivePath,
  List<Map<String, dynamic>> manifestEntries,
) async {
  final stat = await file.stat();
  final digest = await _sha256FilePath(file.path);
  await _addFileStreamToBackupArchive(
    encoder,
    file,
    archivePath,
    stat,
    storeWithoutCompression: _shouldStoreFileWithoutCompression(
      file.path,
      stat.size,
    ),
  );
  manifestEntries.add({
    'path': archivePath,
    'size': stat.size,
    'sha256': digest,
  });
}

Future<void> _addFileStreamToBackupArchive(
  ZipFileEncoder encoder,
  File file,
  String archivePath,
  FileStat stat, {
  required bool storeWithoutCompression,
}) async {
  final fileStream = InputFileStream(file.path);
  final archiveFile = ArchiveFile.stream(archivePath, fileStream)
    ..lastModTime = stat.modified.millisecondsSinceEpoch ~/ 1000
    ..mode = stat.mode;
  if (storeWithoutCompression) {
    archiveFile.compression = CompressionType.none;
  }

  try {
    encoder.addArchiveFile(archiveFile);
  } finally {
    await fileStream.close();
  }
}

bool _shouldStoreFileWithoutCompression(String filePath, int fileSize) {
  if (fileSize >= _backupStoreWithoutCompressionThreshold) return true;
  final extension = path.extension(filePath).toLowerCase();
  return _backupStoreWithoutCompressionExtensions.contains(extension);
}

void _addBytesToBackupArchive(
  ZipFileEncoder encoder,
  String archivePath,
  List<int> bytes, {
  List<Map<String, dynamic>>? manifestEntries,
}) {
  encoder.addArchiveFile(ArchiveFile(archivePath, bytes.length, bytes));
  manifestEntries?.add({
    'path': archivePath,
    'size': bytes.length,
    'sha256': sha256.convert(bytes).toString(),
  });
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

class _BackupArchiveResult {
  final int sizeBytes;
  final int fileCount;

  const _BackupArchiveResult({
    required this.sizeBytes,
    required this.fileCount,
  });
}

class _StagedRestoreResult {
  final Map<String, dynamic> settings;
  final int workspaceFileCount;
  final int dbFileCount;

  const _StagedRestoreResult({
    required this.settings,
    required this.workspaceFileCount,
    required this.dbFileCount,
  });
}
