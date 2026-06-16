import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/data/services/app_info_service.dart';
import 'package:memex/data/services/app_update_router.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:memex/data/services/update_manifest_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppFlavor.init('global');
  });

  test(
    'selects GitHub APK provider for Android Early manifest channel',
    () async {
      AppFlavor.init('globalEarly');
      final router = _routerFor(
        packageName: 'com.memexlab.memex.early',
        installerSource: 'com.android.packageinstaller',
        manifest: {'android_global_early': _githubApkChannel(latestBuild: 118)},
      );

      final result = await router.checkForUpdate(manual: true);

      expect(result.status, UnifiedAppUpdateStatus.updateAvailable);
      expect(result.providerKind.wireName, 'github_apk');
      expect(result.apkUpdate, isNotNull);
      expect(result.apkUpdate!.sha256, _hash('1'));
      expect(result.apkUpdate!.buildNumber, 118);
    },
  );

  test('returns no update when manifest build is not newer', () async {
    AppFlavor.init('globalEarly');
    final router = _routerFor(
      buildNumber: 118,
      packageName: 'com.memexlab.memex.early',
      installerSource: 'com.android.packageinstaller',
      manifest: {'android_global_early': _githubApkChannel(latestBuild: 118)},
    );

    final result = await router.checkForUpdate(manual: true);

    expect(result.status, UnifiedAppUpdateStatus.noUpdate);
    expect(result.providerKind.wireName, 'github_apk');
  });

  test('selects store redirect for stable Android store channel', () async {
    final router = _routerFor(
      packageName: 'com.memexlab.memex',
      installerSource: 'com.android.vending',
      manifest: {
        'android_global_stable': {
          'provider': 'google_play',
          'packageName': 'com.memexlab.memex',
          'latestBuild': 118,
          'minSupportedBuild': 117,
          'fallbackStoreUrl': 'market://details?id=com.memexlab.memex',
        },
      },
    );

    final result = await router.checkForUpdate(manual: true);

    expect(result.status, UnifiedAppUpdateStatus.updateAvailable);
    expect(result.providerKind.wireName, 'google_play');
    expect(result.apkUpdate, isNull);
    expect(
      result.actionUri.toString(),
      'market://details?id=com.memexlab.memex',
    );
  });

  test('does not route store-installed stable builds to GitHub APK', () async {
    final router = _routerFor(
      packageName: 'com.memexlab.memex',
      installerSource: 'com.android.vending',
      manifest: {
        'android_global_stable': {
          'provider': 'github_apk',
          'packageName': 'com.memexlab.memex',
          'latestBuild': 118,
          'minSupportedBuild': 117,
          'versionName': '1.0.35',
          'apkUrl': 'https://example.com/memex_global_1.0.35_118.apk',
          'sha256': _hash('1'),
          'sizeBytes': 4,
        },
      },
    );

    final result = await router.checkForUpdate(manual: true);

    expect(result.status, UnifiedAppUpdateStatus.unsupported);
    expect(result.apkUpdate, isNull);
  });

  test('surfaces manifest fallback failure without throwing', () async {
    final router = _routerFor(
      packageName: 'com.memexlab.memex',
      installerSource: 'com.android.vending',
      manifest: null,
      statusCode: 503,
    );

    final result = await router.checkForUpdate(manual: true);

    expect(result.status, UnifiedAppUpdateStatus.checkFailed);
    expect(result.usedBuiltInFallback, isTrue);
    expect(result.error, isNotNull);
  });
}

AppUpdateRouter _routerFor({
  int buildNumber = 117,
  required String packageName,
  required String installerSource,
  required Map<String, dynamic>? manifest,
  int statusCode = 200,
}) {
  final appInfoService = AppInfoService(
    environment: const AppInfoEnvironment(
      isAndroid: true,
      isIOS: false,
      platformName: 'android',
    ),
    platform: _FakeAppInfoPlatform(installerSource),
    packageLoader: () async => AppPackageMetadata(
      appName: 'Memex',
      packageName: packageName,
      versionName: '1.0.34',
      buildNumber: buildNumber,
    ),
  );
  final manifestService = UpdateManifestService(
    verifyManifestSha256: false,
    endpoints: const [
      UpdateManifestEndpoint(manifestUrl: 'https://example.com/manifest.json'),
    ],
    httpClient: MockClient((_) async {
      if (manifest == null) return http.Response('unavailable', statusCode);
      return http.Response(
        jsonEncode({
          'schemaVersion': 1,
          'generatedAt': '2026-06-16T00:00:00Z',
          'channels': manifest,
        }),
        statusCode,
      );
    }),
  );

  return AppUpdateRouter(
    appInfoService: appInfoService,
    manifestService: manifestService,
    apkUpdateService: AppUpdateService(
      environment: const AppUpdateEnvironment(
        isAndroid: true,
        isEarlyChannel: true,
        flavorName: 'globalEarly',
      ),
    ),
    clock: () => DateTime.utc(2026, 6, 16),
  );
}

Map<String, dynamic> _githubApkChannel({required int latestBuild}) {
  return {
    'provider': 'github_apk',
    'packageName': 'com.memexlab.memex.early',
    'latestBuild': latestBuild,
    'minSupportedBuild': 117,
    'versionName': '1.0.35',
    'apkUrl': 'https://example.com/memex_globalEarly_1.0.35_118.apk',
    'sha256': _hash('1'),
    'sizeBytes': 4,
  };
}

String _hash(String char) => List.filled(64, char).join();

class _FakeAppInfoPlatform implements AppInfoPlatform {
  const _FakeAppInfoPlatform(this.installerSource);

  final String installerSource;

  @override
  Future<String?> getInstallerSource() async => installerSource;
}
