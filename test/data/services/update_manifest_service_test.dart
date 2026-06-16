import 'dart:convert';
import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memex/data/services/update_manifest_service.dart';
import 'package:memex/domain/models/update_manifest.dart';

void main() {
  test('loads and verifies the primary official-site manifest', () async {
    final body = jsonEncode(_manifestJson());
    final expectedHash = sha256.convert(utf8.encode(body)).toString();
    final service = UpdateManifestService(
      endpoints: const [
        UpdateManifestEndpoint(
          manifestUrl: 'https://example.com/manifest.json',
          sha256Url: 'https://example.com/manifest.sha256',
        ),
      ],
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('.sha256')) {
          return http.Response('$expectedHash  manifest.json', 200);
        }
        return http.Response(body, 200);
      }),
      clock: () => DateTime.utc(2026, 6, 16),
    );

    final result = await service.loadManifest();

    expect(result.usedBuiltInFallback, isFalse);
    expect(result.sourceUrl, 'https://example.com/manifest.json');
    expect(
      result.manifest.channels['android_global_early']!.provider,
      UpdateProviderKind.githubApk,
    );
  });

  test('falls back to the next endpoint when primary manifest fails', () async {
    final body = jsonEncode(_manifestJson());
    final service = UpdateManifestService(
      verifyManifestSha256: false,
      endpoints: const [
        UpdateManifestEndpoint(
          manifestUrl: 'https://primary.test/manifest.json',
        ),
        UpdateManifestEndpoint(
          manifestUrl: 'https://fallback.test/manifest.json',
        ),
      ],
      httpClient: MockClient((request) async {
        if (request.url.host == 'primary.test') {
          return http.Response('nope', 503);
        }
        return http.Response(body, 200);
      }),
    );

    final result = await service.loadManifest();

    expect(result.usedFallback, isTrue);
    expect(result.usedBuiltInFallback, isFalse);
    expect(result.sourceUrl, 'https://fallback.test/manifest.json');
  });

  test('returns built-in no-op fallback when all endpoints fail', () async {
    final service = UpdateManifestService(
      endpoints: const [
        UpdateManifestEndpoint(
          manifestUrl: 'https://primary.test/manifest.json',
        ),
      ],
      httpClient: MockClient((_) async => http.Response('missing', 404)),
    );

    final result = await service.loadManifest();

    expect(result.usedBuiltInFallback, isTrue);
    expect(result.manifest.channels, isEmpty);
    expect(result.error, isNotNull);
  });

  test('times out hung manifest requests and returns built-in fallback',
      () async {
    final service = UpdateManifestService(
      requestTimeout: const Duration(milliseconds: 20),
      endpoints: const [
        UpdateManifestEndpoint(
          manifestUrl: 'https://primary.test/manifest.json',
        ),
      ],
      httpClient: MockClient((_) => Completer<http.Response>().future),
    );

    final stopwatch = Stopwatch()..start();
    final result = await service.loadManifest();
    stopwatch.stop();

    expect(result.usedBuiltInFallback, isTrue);
    expect(result.manifest.channels, isEmpty);
    expect(result.error, isA<TimeoutException>());
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
  });

  test('rejects malformed manifest build numbers and APK hash', () {
    expect(
      () => UpdateManifest.fromJson({
        'schemaVersion': 1,
        'channels': {
          'android_global_early': {
            'provider': 'github_apk',
            'latestBuild': '118',
            'minSupportedBuild': 117,
            'versionName': '1.0.35',
            'apkUrl': 'https://example.com/app.apk',
            'sha256': _hash('0'),
            'sizeBytes': 4,
          },
        },
      }),
      throwsFormatException,
    );

    expect(
      () => UpdateManifest.fromJson({
        'schemaVersion': 1,
        'channels': {
          'android_global_early': {
            'provider': 'github_apk',
            'latestBuild': 118,
            'minSupportedBuild': 117,
            'versionName': '1.0.35',
            'apkUrl': 'https://example.com/app.apk',
            'sha256': 'not-a-hash',
            'sizeBytes': 4,
          },
        },
      }),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _manifestJson() {
  return {
    'schemaVersion': 1,
    'generatedAt': '2026-06-16T00:00:00Z',
    'channels': {
      'android_global_early': {
        'provider': 'github_apk',
        'packageName': 'com.memexlab.memex.early',
        'latestBuild': 118,
        'minSupportedBuild': 117,
        'versionName': '1.0.35',
        'apkUrl': 'https://example.com/memex_globalEarly_1.0.35_118.apk',
        'sha256': _hash('0'),
        'sizeBytes': 4,
      },
    },
  };
}

String _hash(String char) => List.filled(64, char).join();
