import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/migration_state_service.dart';
import 'package:path/path.dart' as p;

void main() {
  group('MigrationStateService', () {
    late Directory tempRoot;
    late String userId;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp(
        'memex_migration_state_test_',
      );
      await FileSystemService.init(tempRoot.path);
      userId = 'migration_state_${DateTime.now().microsecondsSinceEpoch}';
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('marks successful migrations and skips later runs', () async {
      var callCount = 0;

      final firstResult = await MigrationStateService.instance.runOnce(
        userId: userId,
        key: 'test_success_v1',
        migrate: () async {
          callCount++;
          return true;
        },
      );
      final secondResult = await MigrationStateService.instance.runOnce(
        userId: userId,
        key: 'test_success_v1',
        migrate: () async {
          callCount++;
          return true;
        },
      );

      expect(firstResult, isTrue);
      expect(secondResult, isTrue);
      expect(callCount, 1);
      expect(
        await MigrationStateService.instance.isCompleted(
          userId,
          'test_success_v1',
        ),
        isTrue,
      );

      final state = await _readState(userId);
      expect(state['test_success_v1'], isTrue);
      expect(state['updated_at'], isA<String>());
    });

    test('does not mark incomplete migrations', () async {
      var callCount = 0;

      final incompleteResult = await MigrationStateService.instance.runOnce(
        userId: userId,
        key: 'test_retry_v1',
        migrate: () async {
          callCount++;
          return false;
        },
      );
      final retryResult = await MigrationStateService.instance.runOnce(
        userId: userId,
        key: 'test_retry_v1',
        migrate: () async {
          callCount++;
          return true;
        },
      );

      expect(incompleteResult, isFalse);
      expect(retryResult, isTrue);
      expect(callCount, 2);
      expect(
        await MigrationStateService.instance.isCompleted(
          userId,
          'test_retry_v1',
        ),
        isTrue,
      );
    });
  });
}

Future<Map<String, dynamic>> _readState(String userId) async {
  final stateFile = File(p.join(
    FileSystemService.instance.getSystemPath(userId),
    MigrationStateService.stateFileName,
  ));
  if (!await stateFile.exists()) return const {};
  return Map<String, dynamic>.from(
    jsonDecode(await stateFile.readAsString()) as Map,
  );
}
