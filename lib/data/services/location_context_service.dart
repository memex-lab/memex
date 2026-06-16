import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:memex/data/services/geocoding_service.dart';
import 'package:memex/domain/models/input_location.dart';
import 'package:memex/domain/models/location_context_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

typedef LocationServiceEnabledReader = Future<bool> Function();
typedef LocationPermissionReader = Future<LocationPermission> Function();
typedef DevicePositionReader = Future<Position> Function(
    LocationSettings settings);
typedef LastKnownDevicePositionReader = Future<Position?> Function();

class LocationContextService {
  static final LocationContextService instance =
      LocationContextService._internal();
  LocationContextService._internal({
    LocationServiceEnabledReader? isLocationServiceEnabled,
    LocationPermissionReader? checkPermission,
    LocationPermissionReader? requestPermission,
    DevicePositionReader? getCurrentPosition,
    LastKnownDevicePositionReader? getLastKnownPosition,
  })  : _isLocationServiceEnabled =
            isLocationServiceEnabled ?? Geolocator.isLocationServiceEnabled,
        _checkPermission = checkPermission ?? Geolocator.checkPermission,
        _requestPermission = requestPermission ?? Geolocator.requestPermission,
        _getCurrentPosition = getCurrentPosition ??
            ((settings) =>
                Geolocator.getCurrentPosition(locationSettings: settings)),
        _getLastKnownPosition =
            getLastKnownPosition ?? Geolocator.getLastKnownPosition;

  @visibleForTesting
  factory LocationContextService.forTesting({
    LocationServiceEnabledReader? isLocationServiceEnabled,
    LocationPermissionReader? checkPermission,
    LocationPermissionReader? requestPermission,
    DevicePositionReader? getCurrentPosition,
    LastKnownDevicePositionReader? getLastKnownPosition,
  }) {
    return LocationContextService._internal(
      isLocationServiceEnabled: isLocationServiceEnabled,
      checkPermission: checkPermission,
      requestPermission: requestPermission,
      getCurrentPosition: getCurrentPosition,
      getLastKnownPosition: getLastKnownPosition,
    );
  }

  static const Duration _maxLastKnownPositionAge = Duration(minutes: 2);
  static const Duration _inputLocationTimeout = Duration(seconds: 6);

  final _logger = getLogger('LocationContextService');
  final LocationServiceEnabledReader _isLocationServiceEnabled;
  final LocationPermissionReader _checkPermission;
  final LocationPermissionReader _requestPermission;
  final DevicePositionReader _getCurrentPosition;
  final LastKnownDevicePositionReader _getLastKnownPosition;
  CurrentLocationContext? _cachedContext;
  String? _cachedConfigSignature;

  Future<InputLocation?> captureInputLocation({
    Duration timeout = _inputLocationTimeout,
  }) {
    return _captureInputLocation(timeout).timeout(
      timeout + const Duration(seconds: 1),
      onTimeout: () {
        _logger.warning('Timed out while capturing input location');
        return _recentLastKnownInputLocation();
      },
    );
  }

  Future<InputLocation?> _captureInputLocation(Duration timeout) async {
    try {
      final serviceEnabled = await _isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await _checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _requestPermission();
      }
      if (!_isUsablePermission(permission)) return null;

      final position = await _getCurrentPosition(
        LocationSettings(accuracy: LocationAccuracy.high, timeLimit: timeout),
      ).timeout(timeout);
      return _inputLocationFromPosition(position);
    } on TimeoutException {
      _logger.warning('Timed out while capturing input location');
      return _recentLastKnownInputLocation();
    } catch (e, stackTrace) {
      _logger.warning(
        'Failed to capture input location; continuing without GPS metadata',
        e,
        stackTrace,
      );
      return _recentLastKnownInputLocation();
    }
  }

  Future<InputLocation?> _recentLastKnownInputLocation() async {
    try {
      final position = await _getLastKnownPosition()
          .timeout(const Duration(milliseconds: 700));
      if (position == null) return null;

      final age = DateTime.now().difference(position.timestamp);
      if (age > _maxLastKnownPositionAge) {
        _logger.info(
          'Skipping stale last known input location from ${position.timestamp.toIso8601String()}',
        );
        return null;
      }

      return _inputLocationFromPosition(
        position,
        source: InputLocation.lastKnownDeviceGpsSource,
      );
    } catch (e, stackTrace) {
      _logger.warning(
        'Failed to use last known input location; continuing without GPS metadata',
        e,
        stackTrace,
      );
      return null;
    }
  }

  InputLocation _inputLocationFromPosition(
    Position position, {
    String source = InputLocation.deviceGpsSource,
  }) {
    return InputLocation(
      lat: position.latitude,
      lng: position.longitude,
      accuracyMeters: position.accuracy,
      capturedAt: position.timestamp,
      source: source,
    );
  }

  bool _isUsablePermission(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Device GPS is the only source for current location.
  /// IP-based fallback is intentionally not used because proxy/VPN/network
  /// routing can make it misleading for agent context.
  Future<CurrentLocationContext> getCurrentContext({
    bool forceRefresh = false,
  }) async {
    final config = await UserStorage.getLocationContextConfig();
    final now = DateTime.now();
    final configSignature = _configSignature(config);

    if (!config.enabled) {
      return CurrentLocationContext(
        status: 'disabled',
        source: 'device_gps',
        updatedAt: now,
        granularity: config.granularity,
        reason: 'location context is disabled in settings',
      );
    }

    final ttl = Duration(minutes: config.ttlMinutes.clamp(1, 1440));
    final cached = _cachedContext;
    if (!forceRefresh &&
        cached != null &&
        _cachedConfigSignature == configSignature &&
        now.difference(cached.updatedAt) <= _cacheWindow(cached, ttl)) {
      return cached;
    }

    try {
      final serviceEnabled = await _isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _unavailable(
          config,
          configSignature,
          'location service is disabled',
          status: 'unavailable',
        );
      }

      var permission = await _checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return _unavailable(
          config,
          configSignature,
          'location permission denied',
          status: 'unavailable',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        return _unavailable(
          config,
          configSignature,
          'location permission permanently denied',
          status: 'unavailable',
        );
      }

      final position = await _getCurrentPosition(
        const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );

      final geocodeResult =
          await GeocodingService.instance.reverseGeocodeWithStatus(
        position.latitude,
        position.longitude,
        config: config,
        timeout: const Duration(seconds: 4),
      );
      final address = geocodeResult.address;

      final context = CurrentLocationContext(
        status: 'fresh',
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        source: address == null ? 'device_gps' : 'device_gps + reverse_geocode',
        updatedAt: now,
        address: address,
        granularity: config.granularity,
        reason: address == null
            ? 'reverse geocode unavailable (${geocodeResult.provider.name}): ${geocodeResult.reason ?? geocodeResult.status}'
            : null,
      );
      _remember(context, configSignature);
      return context;
    } catch (e) {
      _logger.warning('Failed to build current location context: $e');
      final lastKnown = await _tryLastKnownPosition(config, configSignature);
      if (lastKnown != null) {
        return lastKnown;
      }
      return _unavailable(
        config,
        configSignature,
        'failed to get current device location',
        status: 'unavailable',
      );
    }
  }

  Future<CurrentLocationContext?> _tryLastKnownPosition(
    LocationContextConfig config,
    String configSignature,
  ) async {
    try {
      final position = await _getLastKnownPosition();
      if (position == null) return null;
      final now = DateTime.now();
      final age = now.difference(position.timestamp);
      if (age > _maxLastKnownPositionAge) {
        _logger.info(
          'Skipping stale last known location from ${position.timestamp.toIso8601String()}',
        );
        return null;
      }
      final geocodeResult =
          await GeocodingService.instance.reverseGeocodeWithStatus(
        position.latitude,
        position.longitude,
        config: config,
        timeout: const Duration(seconds: 4),
      );
      final address = geocodeResult.address;
      final context = CurrentLocationContext(
        status: 'fresh',
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        source: address == null
            ? 'last_known_device_gps'
            : 'last_known_device_gps + reverse_geocode',
        updatedAt: now,
        address: address,
        granularity: config.granularity,
        reason: [
          'using recent last known device location after current lookup failed',
          if (address == null)
            'reverse geocode unavailable (${geocodeResult.provider.name}): ${geocodeResult.reason ?? geocodeResult.status}',
        ].join('; '),
      );
      _remember(context, configSignature);
      return context;
    } catch (e) {
      _logger.warning('Failed to use last known location: $e');
      return null;
    }
  }

  CurrentLocationContext _unavailable(
    LocationContextConfig config,
    String configSignature,
    String reason, {
    required String status,
  }) {
    final context = CurrentLocationContext(
      status: status,
      source: 'device_gps',
      updatedAt: DateTime.now(),
      granularity: config.granularity,
      reason: reason,
    );
    _remember(context, configSignature);
    return context;
  }

  Duration _cacheWindow(CurrentLocationContext context, Duration freshTtl) {
    if (context.isFresh && context.address == null) {
      return const Duration(minutes: 2);
    }
    if (context.isFresh) return freshTtl;
    return const Duration(minutes: 2);
  }

  String _configSignature(LocationContextConfig config) {
    return [
      config.enabled,
      config.provider.name,
      config.amapApiKey.hashCode,
      config.granularity.name,
      config.ttlMinutes,
    ].join('|');
  }

  void _remember(CurrentLocationContext context, String configSignature) {
    _cachedContext = context;
    _cachedConfigSignature = configSignature;
  }
}
