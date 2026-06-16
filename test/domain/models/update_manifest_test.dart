import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/app_build_info.dart';
import 'package:memex/domain/models/update_manifest.dart';

void main() {
  group('UpdateManifest', () {
    test('parses channels case-insensitively and resolves build channel', () {
      final manifest = UpdateManifest.fromJson({
        'schemaVersion': 1,
        'generatedAt': '2026-06-16T00:00:00Z',
        'expiresAt': '2026-06-17T00:00:00Z',
        'channels': {
          'ANDROID_GLOBAL_EARLY': _githubApkChannel(latestBuild: 118),
        },
      });
      const buildInfo = AppBuildInfo(
        appName: 'Memex',
        packageName: 'com.memexlab.memex.early',
        versionName: '1.0.34',
        buildNumber: 117,
        flavorName: 'globalEarly',
        regionName: 'global',
        channelName: 'early',
        platformName: 'android',
      );

      final channel = manifest.channelFor(buildInfo);

      expect(manifest.generatedAt, DateTime.utc(2026, 6, 16));
      expect(manifest.expiresAt, DateTime.utc(2026, 6, 17));
      expect(channel, isNotNull);
      expect(channel!.key, 'android_global_early');
      expect(channel.provider, UpdateProviderKind.githubApk);
      expect(
          channel.primaryActionUri.toString(), 'https://example.com/app.apk');
      expect(channel.isNewerThan(117), isTrue);
      expect(channel.isNewerThan(118), isFalse);
      expect(channel.requiresUpdateFor(116), isTrue);
      expect(channel.requiresUpdateFor(117), isFalse);
    });

    test('parses from JSON string and normalizes APK hash', () {
      final manifest = UpdateManifest.fromJsonString(
        jsonEncode({
          'schemaVersion': 1,
          'channels': {
            'android_global_early': _githubApkChannel(
              latestBuild: 118,
              sha256: _hash('A'),
            ),
          },
        }),
      );

      expect(
        manifest.channels['android_global_early']!.sha256,
        _hash('a'),
      );
    });

    test('validates provider-specific required fields', () {
      expect(
        () => UpdateManifestChannel.fromJson(
          key: 'android_global_early',
          json: {
            'provider': 'github_apk',
            'latestBuild': 118,
            'minSupportedBuild': 117,
            'versionName': '1.0.35',
            'apkUrl': 'https://example.com/app.apk',
            'sha256': _hash('0'),
            'sizeBytes': 0,
          },
        ),
        throwsFormatException,
      );

      expect(
        () => UpdateManifestChannel.fromJson(
          key: 'ios_global_stable',
          json: {
            'provider': 'app_store',
            'latestBuild': 118,
            'minSupportedBuild': 117,
          },
        ),
        throwsFormatException,
      );
    });

    test('rejects unsupported schema and non-object root', () {
      expect(
        () => UpdateManifest.fromJson({'schemaVersion': 2, 'channels': {}}),
        throwsFormatException,
      );
      expect(
        () => UpdateManifest.fromJsonString('[1,2,3]'),
        throwsFormatException,
      );
    });
  });
}

Map<String, dynamic> _githubApkChannel({
  required int latestBuild,
  String? sha256,
}) {
  return {
    'provider': 'github_apk',
    'packageName': 'com.memexlab.memex.early',
    'latestBuild': latestBuild,
    'minSupportedBuild': 117,
    'versionName': '1.0.35',
    'apkUrl': 'https://example.com/app.apk',
    'sha256': sha256 ?? _hash('0'),
    'sizeBytes': 4,
  };
}

String _hash(String char) => List.filled(64, char).join();
