import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

/// File logging: one log file per day, auto-clean logs older than 15 days. Uses IOSink for performance.
class FileLoggerService {
  static FileLoggerService? _instance;
  static FileLoggerService get instance {
    _instance ??= FileLoggerService._();
    return _instance!;
  }

  FileLoggerService._();

  Directory? _logDirectory;
  static const int _retentionDays = 15;
  static const String _logDirName = 'logs';

  // keep file handle open for performance
  IOSink? _sink;
  String? _currentSinkDate;
  final _lock = Lock();
  DateTime _lastFlushTime = DateTime.now();

  /// Initialize logging
  Future<void> initialize() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      _logDirectory = Directory('${appDocDir.path}/$_logDirName');
      if (!await _logDirectory!.exists()) {
        await _logDirectory!.create(recursive: true);
      }
      // clean old logs on startup
      _cleanOldLogs();
    } catch (e) {
      // if init fails, use debugPrint as fallback
      debugPrint('Failed to initialize FileLoggerService: $e');
    }
  }

  /// Get today's date string
  String _getTodayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Get today's log file path
  String _getLogFilePath(String date) {
    if (_logDirectory == null) return '';
    return '${_logDirectory!.path}/app_$date.log';
  }

  /// Ensure sink is open and points to correct date file. Must be called within lock.
  Future<void> _ensureSinkOpen() async {
    if (_logDirectory == null) return;

    final today = _getTodayDate();

    // if sink not open or date changed, reopen
    if (_sink == null || _currentSinkDate != today) {
      await _closeCurrentSink();
      _openNewSink(today);
    }
  }

  Future<void> _closeCurrentSink() async {
    try {
      await _sink?.flush();
      await _sink?.close();
    } catch (e) {
      // Ignore close errors
    }
    _sink = null;
  }

  void _openNewSink(String date) {
    _currentSinkDate = date;
    final logFile = File(_getLogFilePath(date));
    // Buffer writes for performance, but we force flush on severe logs
    _sink = logFile.openWrite(mode: FileMode.append);
    _lastFlushTime = DateTime.now(); // Reset flush timer

    // Clean logs occasionally
    _cleanOldLogs();
  }

  /// Write log to file
  Future<void> writeLog(LogRecord record) async {
    if (_logDirectory == null) return;

    // 1. Prepare content (no lock needed)
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(record.time);
    final level = record.level.name.toUpperCase().padRight(5);
    final message = record.message;
    final error = record.error != null ? ' | Error: ${record.error}' : '';
    final stackTrace =
        record.stackTrace != null ? '\n${record.stackTrace}' : '';
    final logLine = '[$timestamp] $level: $message$error$stackTrace';

    // 2. Critical section: file operations
    // Serialize access to the sink because IOSink.flush() prohibits concurrent usage.
    await _lock.synchronized(() async {
      try {
        await _ensureSinkOpen();

        // write to buffer
        _sink?.writeln(logLine);

        // on severe error or every 5s, flush to disk
        final now = DateTime.now();
        if (record.level >= Level.SEVERE ||
            now.difference(_lastFlushTime).inSeconds >= 5) {
          await _sink?.flush();
          _lastFlushTime = now;
        }
      } catch (e) {
        // Handle "Bad state: StreamSink is bound to a stream" or "closed"
        debugPrint('Failed to write log to file: $e');

        // Attempt recovery: Close and force null so next write tries to re-open
        try {
          // We are already inside the lock, so we can safely modify _sink
          _sink = null;
        } catch (_) {}
      }
    });
  }

  /// Remove log files older than retention days
  Future<void> _cleanOldLogs() async {
    if (_logDirectory == null) {
      return;
    }

    try {
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: _retentionDays));

      final files = _logDirectory!.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.log')) {
          try {
            // extract date from filename: app_2025-12-25.log -> 2025-12-25
            final fileName = file.path.split('/').last;
            if (fileName.startsWith('app_') && fileName.endsWith('.log')) {
              final dateStr = fileName.substring(4, fileName.length - 4);
              final fileDate = DateFormat('yyyy-MM-dd').parse(dateStr);

              if (fileDate.isBefore(cutoffDate)) {
                await file.delete();
              }
            }
          } catch (e) {
            // if parse fails, skip file
            debugPrint(
                'Failed to parse log file date: ${file.path}, error: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to clean old logs: $e');
    }
  }

  /// Manually trigger cleanup (e.g. on app startup)
  Future<void> cleanOldLogs() => _cleanOldLogs();

  /// Close file stream (call on app exit; not guaranteed on Flutter)
  Future<void> dispose() async {
    await _lock.synchronized(() async {
      await _sink?.flush();
      await _sink?.close();
      _sink = null;
    });
  }

  /// Get all log files (path and name)
  Future<List<File>> getAllLogFiles() async {
    if (_logDirectory == null) {
      return [];
    }

    try {
      // flush buffer so we read latest content
      await _lock.synchronized(() async {
        await _sink?.flush();
      });

      final files = _logDirectory!.listSync();
      final logFiles = <File>[];

      for (var file in files) {
        if (file is File && file.path.endsWith('.log')) {
          logFiles.add(file);
        }
      }

      // sort by filename (newest first)
      logFiles.sort((a, b) => b.path.compareTo(a.path));

      return logFiles;
    } catch (e) {
      debugPrint('Failed to get log files: $e');
      return [];
    }
  }

  /// Get log directory path
  String? getLogDirectoryPath() {
    return _logDirectory?.path;
  }
}
