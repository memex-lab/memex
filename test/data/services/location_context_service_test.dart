import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:memex/data/services/location_context_service.dart';

void main() {
  group('LocationContextService.captureInputLocation', () {
    test('returns null when permission is denied', () async {
      var requestedPermission = false;
      var requestedPosition = false;
      final service = LocationContextService.forTesting(
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.denied,
        requestPermission: () async {
          requestedPermission = true;
          return LocationPermission.denied;
        },
        getCurrentPosition: (_) async {
          requestedPosition = true;
          return _position();
        },
        getLastKnownPosition: () async => null,
      );

      final location = await service.captureInputLocation(
        timeout: const Duration(milliseconds: 50),
      );

      expect(location, isNull);
      expect(requestedPermission, isTrue);
      expect(requestedPosition, isFalse);
    });

    test('falls back to fresh last known GPS when current position times out',
        () async {
      final service = LocationContextService.forTesting(
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.whileInUse,
        getCurrentPosition: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 250));
          return _position();
        },
        getLastKnownPosition: () async => _position(
          latitude: 31.212345,
          longitude: 121.456789,
          timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
        ),
      );

      final location = await service.captureInputLocation(
        timeout: const Duration(milliseconds: 20),
      );

      expect(location, isNotNull);
      expect(location!.lat, 31.212345);
      expect(location.lng, 121.456789);
      expect(location.source, 'last_known_device_gps');
    });

    test('returns null on timeout without a fresh last known position',
        () async {
      final service = LocationContextService.forTesting(
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.whileInUse,
        getCurrentPosition: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 250));
          return _position();
        },
        getLastKnownPosition: () async => null,
      );
      final stopwatch = Stopwatch()..start();

      final location = await service.captureInputLocation(
        timeout: const Duration(milliseconds: 20),
      );

      stopwatch.stop();
      expect(location, isNull);
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 200)));
    });

    test('ignores stale last known GPS when current position times out',
        () async {
      final service = LocationContextService.forTesting(
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.whileInUse,
        getCurrentPosition: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 250));
          return _position();
        },
        getLastKnownPosition: () async => _position(
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      );

      final location = await service.captureInputLocation(
        timeout: const Duration(milliseconds: 20),
      );

      expect(location, isNull);
    });
  });
}

Position _position({
  double latitude = 31.2,
  double longitude = 121.4,
  DateTime? timestamp,
}) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp ?? DateTime.utc(2026, 6, 16, 6),
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}
