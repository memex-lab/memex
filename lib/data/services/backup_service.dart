import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/db/app_database.dart';

/// Keys to exclude from backup (Flutter internals, not user data).
const _excludePrefKeys = <String>{
  'flutter.',
};

/// Service for creating and restoring full app backups as .memex (zip) files.
class BackupService {
  static final Logger _logger = getLogger('BackupService');

  /// Create a backup zip containing:
  /// - workspace/ directory (Facts, Cards, PKM, KnowledgeInsights, etc.)
  /// - Drift SQLite DB file
  /// - settings.json (selected SharedPreferences keys)
  ///
  /// Returns the path to the generated .memex file.
  static Future<String> createBackup({
    void Function(String status)? onProgress,
  }) async {
    final userId = await UserStorage.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final fs = FileSystemService.instance;
    final workspacePath = fs.getWorkspacePath(userId);
    final appDir = await getApplicationDocumentsDirectory();

    // Temp output path
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
    final tempDir = await getTemporaryDirectory();
    final outputPath = path.join(tempDir.path, 'memex_backup_$timestamp.memex');

    final archive = Archive();

    // 1. Add workspace files
    onProgress?.call('Packing workspace...');
    await _addDirectoryToArchive(archive, workspacePath, 'workspace');

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
        archive.addFile(ArchiveFile('db/$dbName', bytes.length, bytes));
        _logger.info('Added DB file: $dbPath (${bytes.length} bytes)');
        break;
      }
    }

    // 3. Add SharedPreferences settings — backup ALL keys
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
    final settingsJson = utf8.encode(jsonEncode(settings));
    archive.addFile(
        ArchiveFile('settings.json', settingsJson.length, settingsJson));

    // 4. Write zip
    onProgress?.call('Compressing...');
    final zipData = ZipEncoder().encode(archive);
    await File(outputPath).writeAsBytes(zipData);

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
    final userId = await UserStorage.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final fs = FileSystemService.instance;
    final workspacePath = fs.getWorkspacePath(userId);
    final appDir = await getApplicationDocumentsDirectory();

    try {
      onProgress?.call('Reading backup...');
      final bytes = await File(backupFilePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 1. Restore workspace files
      onProgress?.call('Restoring workspace...');
      for (final file in archive) {
        if (file.name.startsWith('workspace/') && !file.isFile) continue;
        if (!file.name.startsWith('workspace/')) continue;

        final relativePath = file.name.substring('workspace/'.length);
        if (relativePath.isEmpty) continue;

        final targetPath = path.join(workspacePath, relativePath);
        final targetDir = Directory(path.dirname(targetPath));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        await File(targetPath).writeAsBytes(file.content as List<int>);
      }

      // 2. Restore DB
      onProgress?.call('Restoring database...');
      // Close current DB first
      if (AppDatabase.isInitialized) {
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
          await File(targetPath).writeAsBytes(file.content as List<int>);
          _logger.info('Restored DB to: $targetPath');
        }
      }

      // Re-init DB
      await AppDatabase.init(userId);

      // 3. Restore settings
      onProgress?.call('Restoring settings...');
      for (final file in archive) {
        if (file.name == 'settings.json' && file.isFile) {
          final jsonStr = utf8.decode(file.content as List<int>);
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
            }
          }
          _logger.info('Restored ${settings.length} settings');
        }
      }

      // 4. Rebuild card cache
      onProgress?.call('Rebuilding cache...');
      await fs.rebuildCardCache(userId);

      _logger.info('Backup restored successfully');
      return true;
    } catch (e, stack) {
      _logger.severe('Restore failed: $e', e, stack);
      // Try to re-init DB even on failure
      try {
        await AppDatabase.init(userId);
      } catch (_) {}
      rethrow;
    }
  }

  /// Recursively add a directory to the archive.
  static Future<void> _addDirectoryToArchive(
    Archive archive,
    String dirPath,
    String archivePrefix,
  ) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final relativePath = path.relative(entity.path, from: dirPath);
        final archivePath = '$archivePrefix/$relativePath';
        try {
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
        } catch (e) {
          _logger.warning('Skipping file ${entity.path}: $e');
        }
      }
    }
  }

  /// Get estimated backup size (workspace + DB).
  static Future<int> estimateBackupSize() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return 0;

    final fs = FileSystemService.instance;
    final workspacePath = fs.getWorkspacePath(userId);
    int totalSize = 0;

    final dir = Directory(workspacePath);
    if (await dir.exists()) {
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            totalSize += await entity.length();
          } catch (_) {}
        }
      }
    }

    return totalSize;
  }
}
