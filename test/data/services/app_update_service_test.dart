import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late FakeUpdatePlatform platform;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('memex_update_test_');
    platform = FakeUpdatePlatform();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  AppUpdateService buildService({
    http.Client? client,
    int currentBuild = 112,
    String flavorName = 'globalEarly',
    bool isSupported = true,
  }) {
    return AppUpdateService(
      httpClient: client ?? MockClient((_) async => http.Response('[]', 200)),
      platform: platform,
      environment: AppUpdateEnvironment(
        isAndroid: isSupported,
        isEarlyChannel: isSupported,
        flavorName: flavorName,
      ),
      packageVersionLoader: () async => AppPackageVersion(
        versionName: '1.0.29',
        buildNumber: currentBuild,
      ),
      updateDirectoryProvider: () async => tempDir,
      clock: () => DateTime(2026, 5, 15, 10),
    );
  }

  group('AppUpdateSettingsStore', () {
    test('loads conservative defaults', () async {
      final store = AppUpdateSettingsStore();
      final settings = await store.load();

      expect(settings.autoCheckEnabled, isTrue);
      expect(settings.wifiOnlyDownloads, isTrue);
      expect(settings.autoDownloadAndInstall, isFalse);
      expect(settings.lastCheckAt, isNull);
    });

    test('persists toggles and last check time', () async {
      final store = AppUpdateSettingsStore();
      final saved = AppUpdateSettings(
        autoCheckEnabled: false,
        wifiOnlyDownloads: false,
        autoDownloadAndInstall: true,
        lastCheckAt: DateTime.utc(2026, 5, 15, 2, 30),
      );

      await store.save(saved);
      final loaded = await store.load();

      expect(loaded.autoCheckEnabled, isFalse);
      expect(loaded.wifiOnlyDownloads, isFalse);
      expect(loaded.autoDownloadAndInstall, isTrue);
      expect(loaded.lastCheckAt, DateTime.utc(2026, 5, 15, 2, 30));
    });
  });

  group('release selection', () {
    test('chooses the newest matching pre-release APK above current build', () {
      final service = buildService();

      final update = service.selectBestUpdate(
        currentBuildNumber: 112,
        flavorName: 'globalEarly',
        releases: [
          release(
            prerelease: false,
            assetName: 'memex_globalEarly_1.0.31_114.apk',
            downloadUrl: 'https://example.com/stable.apk',
          ),
          release(
            assetName: 'memex_cnEarly_1.0.31_114.apk',
            downloadUrl: 'https://example.com/cn.apk',
          ),
          release(
            assetName: 'memex_globalEarly_1.0.30_113.apk',
            downloadUrl: 'https://example.com/global.apk',
          ),
        ],
      );

      expect(update, isNotNull);
      expect(update!.versionName, '1.0.30');
      expect(update.buildNumber, 113);
      expect(update.downloadUrl, 'https://example.com/global.apk');
    });

    test('returns null when matching APK is not newer', () {
      final service = buildService();

      final update = service.selectBestUpdate(
        currentBuildNumber: 113,
        flavorName: 'globalEarly',
        releases: [
          release(
            assetName: 'memex_globalEarly_1.0.30_113.apk',
            downloadUrl: 'https://example.com/global.apk',
          ),
        ],
      );

      expect(update, isNull);
    });

    test('uses release notes version for Flutter default APK asset names', () {
      final service = buildService();

      final update = service.selectBestUpdate(
        currentBuildNumber: 112,
        flavorName: 'globalEarly',
        releases: [
          release(
            assetName: 'app-globalearly-release.apk',
            downloadUrl: 'https://example.com/global.apk',
            body:
                'Android Early build\n\n- Version: 1.0.30-early.20260515.abcdef0+113',
          ),
        ],
      );

      expect(update, isNotNull);
      expect(update!.versionName, '1.0.30-early.20260515.abcdef0');
      expect(update.buildNumber, 113);
    });
  });

  group('check/download/install flow', () {
    test('still checks releases on mobile data when Wi-Fi-only is enabled',
        () async {
      platform.wifiConnected = false;
      final service = buildService(
        client: MockClient((_) async {
          return http.Response(
            jsonEncode([
              release(
                assetName: 'memex_globalEarly_1.0.30_113.apk',
                downloadUrl: 'https://example.com/global.apk',
              ),
            ]),
            200,
          );
        }),
      );

      final result = await service.checkForUpdate(manual: true);

      expect(result.status, AppUpdateCheckStatus.updateAvailable);
      final settings = await service.loadSettings();
      expect(settings.lastCheckAt, DateTime(2026, 5, 15, 10));
    });

    test('blocks APK download on mobile data when Wi-Fi-only is enabled',
        () async {
      platform.wifiConnected = false;
      final service = buildService(
        client: MockClient((_) async => throw StateError('should not fetch')),
      );
      const update = AppUpdateInfo(
        releaseName: 'Early',
        tagName: 'v1.0.30+113',
        versionName: '1.0.30',
        buildNumber: 113,
        assetName: 'memex_globalEarly_1.0.30_113.apk',
        sizeBytes: 4,
        downloadUrl: 'https://example.com/global.apk',
        releaseNotes: '',
      );

      expect(
        () => service.downloadUpdate(update),
        throwsA(isA<AppUpdateWifiRequiredException>()),
      );
    });

    test('detects an available update from GitHub pre-releases', () async {
      final service = buildService(
        client: MockClient((request) async {
          expect(request.url.toString(), AppUpdateService.releasesUrl);
          return http.Response(
            jsonEncode([
              release(
                assetName: 'memex_globalEarly_1.0.30_113.apk',
                downloadUrl: 'https://example.com/global.apk',
              ),
            ]),
            200,
          );
        }),
      );

      final result = await service.checkForUpdate(manual: true);

      expect(result.status, AppUpdateCheckStatus.updateAvailable);
      expect(result.update!.displayVersion, '1.0.30+113');
      final settings = await service.loadSettings();
      expect(settings.lastCheckAt, DateTime(2026, 5, 15, 10));
    });

    test('downloads APK and delegates install to Android platform channel',
        () async {
      final service = buildService(
        client: MockClient((request) async {
          expect(request.url.toString(), 'https://example.com/global.apk');
          return http.Response.bytes(
            [1, 2, 3, 4],
            200,
            headers: {'content-length': '4'},
          );
        }),
      );
      const update = AppUpdateInfo(
        releaseName: 'Early',
        tagName: 'v1.0.30+113',
        versionName: '1.0.30',
        buildNumber: 113,
        assetName: 'memex_globalEarly_1.0.30_113.apk',
        sizeBytes: 4,
        downloadUrl: 'https://example.com/global.apk',
        releaseNotes: '',
      );
      final progress = <int>[];

      final download = await service.downloadUpdate(
        update,
        onProgress: (received, total) => progress.add(received),
      );
      final install = await service.installUpdate(download.apkPath);

      expect(await File(download.apkPath).readAsBytes(), [1, 2, 3, 4]);
      expect(progress, contains(4));
      expect(install.status, AppUpdateInstallStatus.started);
      expect(platform.installedApkPath, download.apkPath);
    });

    test('opens unknown-app settings when install permission is missing',
        () async {
      platform.canInstall = false;
      final service = buildService();

      final result = await service.installUpdate('/tmp/memex.apk');

      expect(result.status, AppUpdateInstallStatus.permissionRequired);
      expect(platform.openedInstallSettings, isTrue);
      expect(platform.installedApkPath, isNull);
    });
  });
}

Map<String, dynamic> release({
  bool prerelease = true,
  String assetName = 'memex_globalEarly_1.0.30_113.apk',
  String downloadUrl = 'https://example.com/memex.apk',
  String body = 'Release notes',
}) {
  return {
    'name': 'Memex Early',
    'tag_name': 'v1.0.30+113',
    'draft': false,
    'prerelease': prerelease,
    'body': body,
    'published_at': '2026-05-15T00:00:00Z',
    'assets': [
      {
        'name': assetName,
        'size': 1234,
        'browser_download_url': downloadUrl,
      }
    ],
  };
}

class FakeUpdatePlatform implements AppUpdatePlatform {
  bool wifiConnected = true;
  bool canInstall = true;
  bool openedInstallSettings = false;
  String? installedApkPath;

  @override
  Future<bool> isWifiConnected() async => wifiConnected;

  @override
  Future<bool> canInstallApk() async => canInstall;

  @override
  Future<void> openInstallPermissionSettings() async {
    openedInstallSettings = true;
  }

  @override
  Future<void> installApk(String apkPath) async {
    installedApkPath = apkPath;
  }
}
