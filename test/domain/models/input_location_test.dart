import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/input_location.dart';

void main() {
  group('InputLocation', () {
    test('serializes device GPS location with explicit coordinate metadata',
        () {
      final location = InputLocation(
        lat: 31.2123433,
        lng: 121.4567883,
        accuracyMeters: 5,
        capturedAt: DateTime.utc(2026, 6, 16, 3, 31, 49, 888),
      );

      final json = location.toJson();

      expect(json['lat'], 31.2123433);
      expect(json['lng'], 121.4567883);
      expect(json['accuracy_meters'], 5);
      expect(json['source'], InputLocation.deviceGpsSource);
      expect(json['coordinate_system'], InputLocation.wgs84CoordinateSystem);
      expect(
        json['captured_at'],
        matches(RegExp(
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.888[+-]\d{2}:\d{2}$')),
      );
    });

    test('round-trips source, coordinate system, and captured instant', () {
      final original = InputLocation(
        lat: 31.2,
        lng: 121.4,
        accuracyMeters: 12.5,
        capturedAt: DateTime.utc(2026, 6, 16, 3, 31, 49, 888),
        source: InputLocation.lastKnownDeviceGpsSource,
      );

      final parsed = InputLocation.fromJson(original.toJson());

      expect(parsed.lat, original.lat);
      expect(parsed.lng, original.lng);
      expect(parsed.accuracyMeters, original.accuracyMeters);
      expect(parsed.source, InputLocation.lastKnownDeviceGpsSource);
      expect(parsed.coordinateSystem, InputLocation.wgs84CoordinateSystem);
      expect(parsed.capturedAt.toUtc(), original.capturedAt.toUtc());
    });

    test('defaults legacy JSON source fields when omitted', () {
      final parsed = InputLocation.fromJson({
        'lat': 1,
        'lng': 2,
        'accuracy_meters': 3,
        'captured_at': '2026-06-16T12:00:00+08:00',
      });

      expect(parsed.source, InputLocation.deviceGpsSource);
      expect(parsed.coordinateSystem, InputLocation.wgs84CoordinateSystem);
      expect(parsed.capturedAt.toUtc(), DateTime.utc(2026, 6, 16, 4));
    });
  });
}
