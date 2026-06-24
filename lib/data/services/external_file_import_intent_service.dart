import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Receives Android ACTION_VIEW intents for files opened with Memex.
///
/// ACTION_SEND is handled by share_handler; this channel covers document-open
/// intents from file managers, where share_handler does not emit media.
class ExternalFileImportIntentService {
  ExternalFileImportIntentService._();

  static final ExternalFileImportIntentService instance =
      ExternalFileImportIntentService._();

  static const MethodChannel _methodChannel = MethodChannel(
    'com.memexlab.memex/external_file_import',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.memexlab.memex/external_file_import_events',
  );

  Stream<List<String>>? _filePathStream;

  Future<List<String>?> consumeInitialFilePaths() async {
    if (!Platform.isAndroid) return null;
    final paths = await _methodChannel.invokeListMethod<String>(
      'getInitialFilePaths',
    );
    if (paths != null && paths.isNotEmpty) {
      await _methodChannel.invokeMethod<void>('clearInitialFilePaths');
      return paths.where((path) => path.isNotEmpty).toList(growable: false);
    }
    return null;
  }

  Stream<List<String>> get filePathStream {
    if (!Platform.isAndroid) return const Stream.empty();
    return _filePathStream ??= _eventChannel.receiveBroadcastStream().map(
      (event) {
        if (event is List) {
          return event
              .whereType<String>()
              .where((path) => path.isNotEmpty)
              .toList(growable: false);
        }
        if (event is String && event.isNotEmpty) {
          return [event];
        }
        return const <String>[];
      },
    ).where((paths) => paths.isNotEmpty);
  }
}
