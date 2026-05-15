import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/location_context_config.dart';

void main() {
  group('LocationContextConfig', () {
    test('defaults to disabled until the user opts in', () {
      expect(const LocationContextConfig().enabled, isFalse);
      expect(LocationContextConfig.fromJson(const {}).enabled, isFalse);
    });
  });

  group('GeocodedAddress', () {
    test('summary respects configured granularity', () {
      final address = GeocodedAddress(
        province: '上海市',
        city: '上海市',
        district: '徐汇区',
        neighborhood: '衡复风貌区',
        street: '武康路',
        fullAddress: '上海市徐汇区武康路',
        provider: 'amap',
        updatedAt: DateTime(2026),
      );

      expect(address.summary(LocationContextGranularity.city), '上海市');
      expect(
        address.summary(LocationContextGranularity.neighborhood),
        '上海市 · 徐汇区 · 衡复风貌区',
      );
      expect(
        address.summary(LocationContextGranularity.street),
        '上海市 · 徐汇区 · 衡复风貌区 · 武康路',
      );
      expect(address.summary(LocationContextGranularity.full), '上海市徐汇区武康路');
    });
  });

  group('CurrentLocationContext', () {
    test('fresh reminder tells the agent to prefer current location', () {
      final context = CurrentLocationContext(
        status: 'fresh',
        latitude: 31.212345,
        longitude: 121.456789,
        source: 'device_gps + reverse_geocode',
        updatedAt: DateTime(2026),
        granularity: LocationContextGranularity.neighborhood,
        address: GeocodedAddress(
          city: '上海市',
          district: '徐汇区',
          neighborhood: '衡复风貌区',
          provider: 'amap',
          updatedAt: DateTime(2026),
        ),
      );

      final reminder = context.toSystemReminderContent();

      expect(reminder, contains('current_location_context'));
      expect(reminder, contains('location_summary: 上海市 · 徐汇区 · 衡复风貌区'));
      expect(reminder, contains('Prefer current_location_context'));
      expect(reminder, contains('do not invent a missing city'));
    });

    test('fresh GPS-only context is not injected into agent prompts', () {
      final context = CurrentLocationContext(
        status: 'fresh',
        latitude: 31.212345,
        longitude: 121.456789,
        source: 'device_gps',
        updatedAt: DateTime(2026),
        granularity: LocationContextGranularity.neighborhood,
        reason: 'reverse geocode unavailable (amap): amap api key is empty',
      );

      expect(context.toAgentSystemReminderContent(), isNull);
    });
  });
}
