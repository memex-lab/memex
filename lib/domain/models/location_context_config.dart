enum GeocodingProvider {
  openStreetMap,
  amap,
}

enum LocationContextGranularity {
  city,
  district,
  neighborhood,
  street,
  full,
}

class LocationContextConfig {
  final bool enabled;
  final GeocodingProvider provider;
  final String amapApiKey;
  final LocationContextGranularity granularity;
  final int ttlMinutes;

  const LocationContextConfig({
    this.enabled = true,
    this.provider = GeocodingProvider.openStreetMap,
    this.amapApiKey = '',
    this.granularity = LocationContextGranularity.neighborhood,
    this.ttlMinutes = 15,
  });

  factory LocationContextConfig.fromJson(Map<String, dynamic> json) {
    return LocationContextConfig(
      enabled: json['enabled'] as bool? ?? true,
      provider: GeocodingProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => GeocodingProvider.openStreetMap,
      ),
      amapApiKey: json['amapApiKey'] as String? ?? '',
      granularity: LocationContextGranularity.values.firstWhere(
        (e) => e.name == json['granularity'],
        orElse: () => LocationContextGranularity.neighborhood,
      ),
      ttlMinutes: (json['ttlMinutes'] as num?)?.toInt() ?? 15,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'provider': provider.name,
        'amapApiKey': amapApiKey,
        'granularity': granularity.name,
        'ttlMinutes': ttlMinutes,
      };

  LocationContextConfig copyWith({
    bool? enabled,
    GeocodingProvider? provider,
    String? amapApiKey,
    LocationContextGranularity? granularity,
    int? ttlMinutes,
  }) {
    return LocationContextConfig(
      enabled: enabled ?? this.enabled,
      provider: provider ?? this.provider,
      amapApiKey: amapApiKey ?? this.amapApiKey,
      granularity: granularity ?? this.granularity,
      ttlMinutes: ttlMinutes ?? this.ttlMinutes,
    );
  }
}

class GeocodedAddress {
  final String? country;
  final String? province;
  final String? city;
  final String? district;
  final String? neighborhood;
  final String? street;
  final String? fullAddress;
  final String provider;
  final DateTime updatedAt;
  final String confidence;

  const GeocodedAddress({
    this.country,
    this.province,
    this.city,
    this.district,
    this.neighborhood,
    this.street,
    this.fullAddress,
    required this.provider,
    required this.updatedAt,
    this.confidence = 'medium',
  });

  factory GeocodedAddress.fromJson(Map<String, dynamic> json) {
    return GeocodedAddress(
      country: json['country'] as String?,
      province: json['province'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      neighborhood: json['neighborhood'] as String?,
      street: json['street'] as String?,
      fullAddress: json['fullAddress'] as String?,
      provider: json['provider'] as String? ?? 'unknown',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      confidence: json['confidence'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() => {
        if (country != null) 'country': country,
        if (province != null) 'province': province,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (neighborhood != null) 'neighborhood': neighborhood,
        if (street != null) 'street': street,
        if (fullAddress != null) 'fullAddress': fullAddress,
        'provider': provider,
        'updatedAt': updatedAt.toIso8601String(),
        'confidence': confidence,
      };

  String summary(LocationContextGranularity granularity) {
    if (granularity == LocationContextGranularity.full &&
        fullAddress != null &&
        fullAddress!.trim().isNotEmpty) {
      return fullAddress!.trim();
    }

    final parts = <String>[];

    void add(String? value) {
      if (value != null && value.trim().isNotEmpty && !parts.contains(value)) {
        parts.add(value.trim());
      }
    }

    add(city ?? province);
    if (granularity.index >= LocationContextGranularity.district.index) {
      add(district);
    }
    if (granularity.index >= LocationContextGranularity.neighborhood.index) {
      add(neighborhood);
    }
    if (granularity.index >= LocationContextGranularity.street.index) {
      add(street);
    }
    if (parts.isEmpty) {
      return fullAddress ?? '';
    }
    return parts.join(' · ');
  }
}

class ReverseGeocodeResult {
  final GeocodedAddress? address;
  final GeocodingProvider provider;
  final String status;
  final String? reason;

  const ReverseGeocodeResult({
    required this.address,
    required this.provider,
    required this.status,
    this.reason,
  });

  bool get isSuccess => address != null;
}

class CurrentLocationContext {
  final String status;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final String source;
  final DateTime updatedAt;
  final GeocodedAddress? address;
  final LocationContextGranularity granularity;
  final String? reason;

  const CurrentLocationContext({
    required this.status,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    required this.source,
    required this.updatedAt,
    this.address,
    required this.granularity,
    this.reason,
  });

  bool get isFresh => status == 'fresh';

  String toSystemReminder() {
    return '<system-reminder>\n${toSystemReminderContent()}\n</system-reminder>';
  }

  String? toAgentSystemReminderContent() {
    if (isFresh && address == null) {
      return null;
    }
    return toSystemReminderContent();
  }

  String toSystemReminderContent() {
    if (!isFresh || latitude == null || longitude == null) {
      return '''current_location_context:
- status: $status
- source: $source
- updated_at: ${updatedAt.toIso8601String()}
${reason != null ? '- reason: $reason\n' : ''}instruction: The user's current location is unavailable or stale. Do not infer the user's current city from old chat history, old memories, photos, or historical records unless the user explicitly states it in this turn.
''';
    }

    final summary = address?.summary(granularity) ?? '';
    return '''current_location_context:
- status: fresh
- source: $source
- latitude: ${latitude!.toStringAsFixed(6)}
- longitude: ${longitude!.toStringAsFixed(6)}
${accuracyMeters != null ? '- accuracy_meters: ${accuracyMeters!.toStringAsFixed(1)}\n' : ''}${summary.isNotEmpty ? '- location_summary: $summary\n' : ''}${address?.city != null ? '- city: ${address!.city}\n' : ''}${address?.district != null ? '- district: ${address!.district}\n' : ''}${address?.neighborhood != null ? '- neighborhood: ${address!.neighborhood}\n' : ''}${address?.street != null ? '- street: ${address!.street}\n' : ''}${address?.fullAddress != null ? '- full_address_candidate: ${address!.fullAddress}\n' : ''}${address != null ? '- reverse_geocode_provider: ${address!.provider}\n- reverse_geocode_confidence: ${address!.confidence}\n' : ''}${reason != null ? '- note: $reason\n' : ''}- granularity: ${granularity.name}
- updated_at: ${updatedAt.toIso8601String()}
instruction: Prefer current_location_context over old chat history or long-term memory when location matters. Use only the administrative levels explicitly listed here; do not invent a missing city, district, neighborhood, street, or venue. Treat full_address_candidate as an approximate reverse-geocode candidate, not an exact venue unless the user confirms it. Use location only when it is relevant to the user's request.
''';
  }
}
