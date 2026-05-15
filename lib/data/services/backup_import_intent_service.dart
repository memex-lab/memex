import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Receives Android ACTION_VIEW intents for .memex files.
///
/// ACTION_SEND is still handled by share_handler; this channel exists because
/// share_handler does not surface ACTION_VIEW document-open intents on Android.
class BackupImportIntentService {
  BackupImportIntentService._();

  static final BackupImportIntentService instance =
      BackupImportIntentService._();

  static const MethodChannel _methodChannel = MethodChannel(
    'com.memexlab.memex/backup_import',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.memexlab.memex/backup_import_events',
  );

  Stream<String>? _backupPathStream;

  Future<String?> consumeInitialBackupPath() async {
    if (!Platform.isAndroid) return null;
    final path = await _methodChannel.invokeMethod<String>(
      'getInitialBackupPath',
    );
    if (path != null && path.isNotEmpty) {
      await _methodChannel.invokeMethod<void>('clearInitialBackupPath');
      return path;
    }
    return null;
  }

  Stream<String> get backupPathStream {
    if (!Platform.isAndroid) return const Stream.empty();
    return _backupPathStream ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is String && event.isNotEmpty)
        .cast<String>();
  }
}
