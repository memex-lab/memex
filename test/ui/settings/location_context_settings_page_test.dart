import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/location_context_config.dart';
import 'package:memex/ui/settings/widgets/location_context_settings_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpLocationSettingsPage(
    WidgetTester tester, {
    String language = 'en',
    LocationContextConfig config = const LocationContextConfig(),
    CurrentLocationContextLoader? loadCurrentContext,
  }) async {
    SharedPreferences.setMockInitialValues({
      'language': language,
      'location_context_config': jsonEncode(config.toJson()),
    });
    await UserStorage.initL10n();

    await tester.pumpWidget(
      MaterialApp(
        home: LocationContextSettingsPage(
          loadCurrentContext: loadCurrentContext,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollToTestButton(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Test current location'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('updates location context settings from the page', (
    WidgetTester tester,
  ) async {
    await pumpLocationSettingsPage(
      tester,
      config: const LocationContextConfig(
        enabled: false,
        provider: GeocodingProvider.openStreetMap,
        granularity: LocationContextGranularity.neighborhood,
        ttlMinutes: 15,
      ),
    );

    expect(find.text('Location Context'), findsOneWidget);
    expect(find.text('Attach current location to chat'), findsOneWidget);
    expect(find.text('OpenStreetMap / Nominatim'), findsOneWidget);
    expect(find.text('Amap API Key'), findsNothing);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    var config = await UserStorage.getLocationContextConfig();
    expect(config.enabled, isTrue);

    await tester.tap(find.text('OpenStreetMap / Nominatim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Amap').last);
    await tester.pumpAndSettle();

    expect(find.text('Amap API Key'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'test-amap-key');
    await tester.pumpAndSettle();

    config = await UserStorage.getLocationContextConfig();
    expect(config.provider, GeocodingProvider.amap);
    expect(config.amapApiKey, 'test-amap-key');

    await tester.tap(find.text('Amap'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OpenStreetMap / Nominatim').last);
    await tester.pumpAndSettle();

    expect(find.text('Amap API Key'), findsNothing);
    config = await UserStorage.getLocationContextConfig();
    expect(config.provider, GeocodingProvider.openStreetMap);
    expect(config.amapApiKey, 'test-amap-key');

    await tester.tap(find.text('Neighborhood'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Street').last);
    await tester.pumpAndSettle();

    config = await UserStorage.getLocationContextConfig();
    expect(config.granularity, LocationContextGranularity.street);

    await tester.tap(find.text('15 minutes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 minutes').last);
    await tester.pumpAndSettle();

    config = await UserStorage.getLocationContextConfig();
    expect(config.ttlMinutes, 30);
  });

  testWidgets('renders localized Chinese labels', (WidgetTester tester) async {
    await pumpLocationSettingsPage(tester, language: 'zh');

    expect(find.text('位置上下文'), findsOneWidget);
    expect(find.text('为对话附加当前位置'), findsOneWidget);
    expect(find.text('逆地理编码服务商'), findsOneWidget);
    expect(find.text('上下文粒度'), findsOneWidget);
  });

  testWidgets('test button displays a fresh reverse-geocoded location', (
    WidgetTester tester,
  ) async {
    var receivedForceRefresh = false;
    final now = DateTime.utc(2026, 5, 15, 10);
    await pumpLocationSettingsPage(
      tester,
      config: const LocationContextConfig(
        granularity: LocationContextGranularity.neighborhood,
      ),
      loadCurrentContext: ({bool forceRefresh = false}) async {
        receivedForceRefresh = forceRefresh;
        return CurrentLocationContext(
          status: 'fresh',
          latitude: 31.230416,
          longitude: 121.473701,
          accuracyMeters: 8.5,
          source: 'device_gps + reverse_geocode',
          updatedAt: now,
          granularity: LocationContextGranularity.neighborhood,
          address: GeocodedAddress(
            city: 'Shanghai',
            district: 'Huangpu',
            neighborhood: 'People Square',
            street: 'Xizang Middle Road',
            fullAddress: 'People Square, Huangpu, Shanghai',
            provider: 'amap',
            updatedAt: now,
            confidence: 'high',
          ),
        );
      },
    );

    await scrollToTestButton(tester);
    await tester.tap(find.text('Test current location'));
    await tester.pumpAndSettle();

    expect(receivedForceRefresh, isTrue);
    expect(find.textContaining('GPS: fresh'), findsOneWidget);
    expect(find.textContaining('Reverse geocode: OK'), findsOneWidget);
    expect(find.textContaining('Agent context: injected'), findsOneWidget);
    expect(
      find.textContaining('Shanghai · Huangpu · People Square'),
      findsOneWidget,
    );
    expect(
      find.textContaining('People Square, Huangpu, Shanghai'),
      findsOneWidget,
    );
    expect(find.textContaining('31.230416, 121.473701'), findsOneWidget);
  });

  testWidgets('test button displays unavailable status without crashing', (
    WidgetTester tester,
  ) async {
    await pumpLocationSettingsPage(
      tester,
      loadCurrentContext: ({bool forceRefresh = false}) async {
        return CurrentLocationContext(
          status: 'unavailable',
          source: 'device_gps',
          updatedAt: DateTime.utc(2026, 5, 15, 10),
          granularity: LocationContextGranularity.neighborhood,
          reason: 'location permission denied',
        );
      },
    );

    await scrollToTestButton(tester);
    await tester.tap(find.text('Test current location'));
    await tester.pumpAndSettle();

    expect(find.textContaining('GPS: unavailable'), findsOneWidget);
    expect(find.textContaining('Reverse geocode: unavailable'), findsOneWidget);
    expect(
      find.textContaining('Reason: location permission denied'),
      findsOneWidget,
    );
  });

  testWidgets('test button explains GPS-only reverse geocode failure', (
    WidgetTester tester,
  ) async {
    await pumpLocationSettingsPage(
      tester,
      config: const LocationContextConfig(
        enabled: true,
        provider: GeocodingProvider.amap,
        granularity: LocationContextGranularity.neighborhood,
      ),
      loadCurrentContext: ({bool forceRefresh = false}) async {
        return CurrentLocationContext(
          status: 'fresh',
          latitude: 31.230416,
          longitude: 121.473701,
          accuracyMeters: 8.5,
          source: 'device_gps',
          updatedAt: DateTime.utc(2026, 5, 15, 10),
          granularity: LocationContextGranularity.neighborhood,
          reason: 'reverse geocode unavailable (amap): amap api key is empty',
        );
      },
    );

    await scrollToTestButton(tester);
    await tester.tap(find.text('Test current location'));
    await tester.pumpAndSettle();

    expect(find.textContaining('GPS: fresh'), findsOneWidget);
    expect(find.textContaining('Provider: Amap'), findsOneWidget);
    expect(find.textContaining('Reverse geocode: unavailable'), findsOneWidget);
    expect(find.textContaining('Agent context: not injected'), findsOneWidget);
    expect(
      find.textContaining('Coordinates: 31.230416, 121.473701'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Reason: reverse geocode unavailable (amap)'),
      findsOneWidget,
    );
  });

  testWidgets('test button displays a localized failure message', (
    WidgetTester tester,
  ) async {
    await pumpLocationSettingsPage(
      tester,
      loadCurrentContext: ({bool forceRefresh = false}) async {
        throw StateError('mock location failure');
      },
    );

    await scrollToTestButton(tester);
    await tester.tap(find.text('Test current location'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Failed: Bad state: mock location failure'),
      findsOneWidget,
    );
  });
}
