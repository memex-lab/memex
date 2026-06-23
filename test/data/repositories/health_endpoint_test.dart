import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/health.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const userId = 'health_endpoint_user';
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser(userId);
    tempDir = await Directory.systemTemp.createTemp('memex_health_endpoint_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('persists health summary into daily fact yaml', () async {
    final success = await reportDailyHealthSummaryEndpoint({
      '2026-06-20': {
        'steps': 8000,
        'heart_rate_avg': 72,
      },
    });

    expect(success, isTrue);

    final result = await FileSystemService.instance.readDailyFactFile(
      userId,
      DateTime(2026, 6, 20),
    );
    expect(result.yamlData, isNotNull);
    expect(result.yamlData!['health'], isA<Map>());
    expect((result.yamlData!['health'] as Map)['steps'], 8000);
    expect(result.yamlData!['health_updated_at'], isNotNull);
  });

  test('returns false when every date fails validation', () async {
    final success = await reportDailyHealthSummaryEndpoint({
      'not-a-date': {'steps': 1},
    });

    expect(success, isFalse);
  });
}
