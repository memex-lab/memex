class InputLocation {
  static const String deviceGpsSource = 'device_gps';
  static const String lastKnownDeviceGpsSource = 'last_known_device_gps';
  static const String wgs84CoordinateSystem = 'WGS84';

  final double lat;
  final double lng;
  final double accuracyMeters;
  final String source;
  final String coordinateSystem;
  final DateTime capturedAt;

  const InputLocation({
    required this.lat,
    required this.lng,
    required this.accuracyMeters,
    required this.capturedAt,
    this.source = deviceGpsSource,
    this.coordinateSystem = wgs84CoordinateSystem,
  });

  factory InputLocation.fromJson(Map<String, dynamic> json) {
    return InputLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      accuracyMeters: (json['accuracy_meters'] as num).toDouble(),
      source: json['source']?.toString() ?? deviceGpsSource,
      coordinateSystem:
          json['coordinate_system']?.toString() ?? wgs84CoordinateSystem,
      capturedAt: DateTime.parse(json['captured_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'accuracy_meters': accuracyMeters,
        'source': source,
        'coordinate_system': coordinateSystem,
        'captured_at': _toIso8601WithOffset(capturedAt),
      };

  static String _toIso8601WithOffset(DateTime value) {
    final local = value.toLocal();
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final absOffset = offset.abs();
    final offsetHours = absOffset.inHours.toString().padLeft(2, '0');
    final offsetMinutes = (absOffset.inMinutes % 60).toString().padLeft(2, '0');

    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}T'
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}'
        '${local.millisecond == 0 ? '' : '.${local.millisecond.toString().padLeft(3, '0')}'}'
        '$sign$offsetHours:$offsetMinutes';
  }
}
