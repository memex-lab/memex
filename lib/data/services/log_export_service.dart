import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android-only helper for saving files to the public Downloads folder.
class LogExportService {
  LogExportService._();

  static const MethodChannel _channel =
      MethodChannel('com.memexlab.memex/log_export');

  static Future<String> saveToPublicDownloads({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final savedPath = await _channel.invokeMethod<String>(
      'saveToPublicDownloads',
      {
        'fileName': fileName,
        'bytes': bytes,
      },
    );

    if (savedPath == null || savedPath.isEmpty) {
      throw StateError('Failed to save log file to Downloads');
    }

    return savedPath;
  }

  static bool get isSupported => !kIsWeb && Platform.isAndroid;
}
