import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/geocoding_service.dart';
import 'package:memex/domain/models/location_context_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Amap reverse geocoding returns a structured address when key is set',
      () async {
    final apiKey = Platform.environment['AMAP_GEOCODING_TEST_KEY'];
    if (apiKey == null || apiKey.trim().isEmpty) {
      markTestSkipped('Set AMAP_GEOCODING_TEST_KEY to run this live test.');
      return;
    }

    final result = await GeocodingService.instance.reverseGeocodeWithStatus(
      31.230416,
      121.473701,
      config: LocationContextConfig(
        provider: GeocodingProvider.amap,
        amapApiKey: apiKey,
        granularity: LocationContextGranularity.neighborhood,
      ),
      timeout: const Duration(seconds: 8),
    );

    expect(result.isSuccess, isTrue, reason: result.reason);
    expect(result.provider, GeocodingProvider.amap);

    final address = result.address!;
    expect(address.provider, 'amap');
    expect(address.fullAddress, isNotNull);
    expect(address.fullAddress!.trim(), isNotEmpty);
    expect(address.city ?? address.province, contains('上海'));
  });
}
