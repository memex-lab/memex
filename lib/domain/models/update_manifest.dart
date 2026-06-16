import 'dart:convert';

import 'package:memex/domain/models/app_build_info.dart';

enum UpdateProviderKind {
  appStore('app_store'),
  androidStore('android_store'),
  googlePlay('google_play'),
  githubApk('github_apk'),
  noop('noop');

  const UpdateProviderKind(this.wireName);

  final String wireName;

  static UpdateProviderKind parse(String value) {
    for (final kind in values) {
      if (kind.wireName == value) return kind;
    }
    throw FormatException('Unsupported update provider: $value');
  }
}

class UpdateManifest {
  const UpdateManifest({
    required this.schemaVersion,
    required this.channels,
    this.generatedAt,
    this.expiresAt,
  });

  static const supportedSchemaVersion = 1;

  final int schemaVersion;
  final DateTime? generatedAt;
  final DateTime? expiresAt;
  final Map<String, UpdateManifestChannel> channels;

  factory UpdateManifest.empty() {
    return const UpdateManifest(
      schemaVersion: supportedSchemaVersion,
      channels: {},
    );
  }

  factory UpdateManifest.fromJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Manifest root must be an object');
    }
    return UpdateManifest.fromJson(decoded);
  }

  factory UpdateManifest.fromJson(Map<String, dynamic> json) {
    final schemaVersion = _requiredInt(json, 'schemaVersion');
    if (schemaVersion != supportedSchemaVersion) {
      throw FormatException(
        'Unsupported manifest schemaVersion: $schemaVersion',
      );
    }

    final rawChannels = json['channels'];
    if (rawChannels is! Map) {
      throw const FormatException('Manifest channels must be an object');
    }

    final channels = <String, UpdateManifestChannel>{};
    for (final entry in rawChannels.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is! Map) {
        throw FormatException('Manifest channel $key must be an object');
      }
      channels[key.toLowerCase()] = UpdateManifestChannel.fromJson(
        key: key.toLowerCase(),
        json: Map<String, dynamic>.from(value),
      );
    }

    return UpdateManifest(
      schemaVersion: schemaVersion,
      generatedAt: _optionalDate(json['generatedAt']),
      expiresAt: _optionalDate(json['expiresAt']),
      channels: Map.unmodifiable(channels),
    );
  }

  UpdateManifestChannel? channelFor(AppBuildInfo buildInfo) {
    return channels[buildInfo.updateChannelKey];
  }
}

class UpdateManifestChannel {
  const UpdateManifestChannel({
    required this.key,
    required this.provider,
    required this.latestBuild,
    required this.minSupportedBuild,
    this.packageName,
    this.bundleId,
    this.country,
    this.versionName,
    this.storeUrl,
    this.fallbackStoreUrl,
    this.apkUrl,
    this.sha256,
    this.sizeBytes,
    this.releaseNotes,
    this.releaseNotesUrl,
  });

  final String key;
  final UpdateProviderKind provider;
  final int latestBuild;
  final int minSupportedBuild;
  final String? packageName;
  final String? bundleId;
  final String? country;
  final String? versionName;
  final String? storeUrl;
  final String? fallbackStoreUrl;
  final String? apkUrl;
  final String? sha256;
  final int? sizeBytes;
  final String? releaseNotes;
  final String? releaseNotesUrl;

  factory UpdateManifestChannel.fromJson({
    required String key,
    required Map<String, dynamic> json,
  }) {
    final provider = UpdateProviderKind.parse(
      _requiredString(json, 'provider'),
    );
    final latestBuild = _requiredInt(json, 'latestBuild', channelKey: key);
    final minSupportedBuild = _requiredInt(
      json,
      'minSupportedBuild',
      channelKey: key,
    );

    final channel = UpdateManifestChannel(
      key: key,
      provider: provider,
      latestBuild: latestBuild,
      minSupportedBuild: minSupportedBuild,
      packageName: _optionalString(json['packageName']),
      bundleId: _optionalString(json['bundleId']),
      country: _optionalString(json['country']),
      versionName: _optionalString(json['versionName']),
      storeUrl: _optionalString(json['storeUrl']),
      fallbackStoreUrl: _optionalString(json['fallbackStoreUrl']),
      apkUrl: _optionalString(json['apkUrl'] ?? json['downloadUrl']),
      sha256: _optionalString(json['sha256'])?.toLowerCase(),
      sizeBytes: _optionalInt(json['sizeBytes'], channelKey: key),
      releaseNotes: _optionalString(json['releaseNotes']),
      releaseNotesUrl: _optionalString(json['releaseNotesUrl']),
    );
    channel._validateProviderFields();
    return channel;
  }

  Uri? get primaryActionUri {
    final value = switch (provider) {
      UpdateProviderKind.githubApk => apkUrl,
      UpdateProviderKind.appStore => storeUrl ?? fallbackStoreUrl,
      UpdateProviderKind.androidStore ||
      UpdateProviderKind.googlePlay => storeUrl ?? fallbackStoreUrl,
      UpdateProviderKind.noop => null,
    };
    return value == null ? null : Uri.tryParse(value);
  }

  bool isNewerThan(int currentBuildNumber) => latestBuild > currentBuildNumber;

  bool requiresUpdateFor(int currentBuildNumber) {
    return minSupportedBuild > 0 && currentBuildNumber < minSupportedBuild;
  }

  void _validateProviderFields() {
    if (latestBuild < 0 || minSupportedBuild < 0) {
      throw FormatException('Manifest channel $key build numbers must be >= 0');
    }

    switch (provider) {
      case UpdateProviderKind.githubApk:
        _requireNonEmpty(apkUrl, 'apkUrl');
        _requireNonEmpty(versionName, 'versionName');
        final size = sizeBytes;
        if (size == null || size <= 0) {
          throw FormatException(
            'Manifest channel $key requires positive sizeBytes',
          );
        }
        final hash = sha256;
        if (hash == null || !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash)) {
          throw FormatException(
            'Manifest channel $key requires a 64-character sha256',
          );
        }
      case UpdateProviderKind.appStore:
        _requireNonEmpty(storeUrl ?? fallbackStoreUrl, 'storeUrl');
      case UpdateProviderKind.androidStore:
      case UpdateProviderKind.googlePlay:
        _requireNonEmpty(storeUrl ?? fallbackStoreUrl, 'fallbackStoreUrl');
      case UpdateProviderKind.noop:
        break;
    }
  }

  void _requireNonEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      throw FormatException('Manifest channel $key requires $fieldName');
    }
  }
}

int _requiredInt(Map<String, dynamic> json, String key, {String? channelKey}) {
  final value = json[key];
  if (value is int) return value;
  final label = channelKey == null ? key : '$channelKey.$key';
  throw FormatException('Manifest field $label must be an integer');
}

int? _optionalInt(Object? value, {String? channelKey}) {
  if (value == null) return null;
  if (value is int) return value;
  final label = channelKey == null ? 'sizeBytes' : '$channelKey.sizeBytes';
  throw FormatException('Manifest field $label must be an integer');
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _optionalString(json[key]);
  if (value == null || value.isEmpty) {
    throw FormatException('Manifest field $key must be a non-empty string');
  }
  return value;
}

String? _optionalString(Object? value) {
  if (value == null) return null;
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? _optionalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
