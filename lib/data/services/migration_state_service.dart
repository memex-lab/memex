import 'dart:convert';
import 'dart:io';

import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';

class MigrationStateService {
  MigrationStateService._();

  static final MigrationStateService instance = MigrationStateService._();
  static const String stateFileName = 'migration_state.json';

  final _logger = getLogger('MigrationStateService');
  final Map<String, Lock> _locks = {};

  Future<bool> isCompleted(String userId, String key) async {
    final state = await _readState(userId);
    return state[key] == true;
  }

  Future<bool> runOnce({
    required String userId,
    required String key,
    required Future<bool> Function() migrate,
  }) async {
    return _lockFor(userId).synchronized(() async {
      final state = await _readState(userId);
      if (state[key] == true) return true;

      final completed = await migrate();
      if (!completed) return false;

      state[key] = true;
      await _writeState(userId, state);
      return true;
    });
  }

  Future<void> markCompleted(String userId, String key) async {
    await _lockFor(userId).synchronized(() async {
      final state = await _readState(userId);
      state[key] = true;
      await _writeState(userId, state);
    });
  }

  Lock _lockFor(String userId) {
    return _locks.putIfAbsent(userId, () => Lock());
  }

  Future<Map<String, dynamic>> _readState(String userId) async {
    final file = File(_statePath(userId));
    if (!await file.exists()) return <String, dynamic>{};
    try {
      final data = jsonDecode(await file.readAsString());
      if (data is Map) return Map<String, dynamic>.from(data);
    } catch (e) {
      _logger.warning('Failed to parse $stateFileName: $e');
    }
    return <String, dynamic>{};
  }

  Future<void> _writeState(
    String userId,
    Map<String, dynamic> state,
  ) async {
    final path = _statePath(userId);
    final dir = Directory(p.dirname(path));
    if (!await dir.exists()) await dir.create(recursive: true);

    state['updated_at'] = DateTime.now().toIso8601String();
    const encoder = JsonEncoder.withIndent('  ');
    final tmpFile = File('$path.tmp');
    await tmpFile.writeAsString('${encoder.convert(state)}\n');
    await tmpFile.rename(path);
  }

  String _statePath(String userId) {
    return p.join(
      FileSystemService.instance.getSystemPath(userId),
      stateFileName,
    );
  }
}
