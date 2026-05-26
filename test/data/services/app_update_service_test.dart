import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:path/path.dart' as p;
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
      packageVersionLoader: () async =>
          AppPackageVersion(versionName: '1.0.29', buildNumber: currentBuild),
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
    test(
      'still checks releases on mobile data when Wi-Fi-only is enabled',
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
      },
    );

    test(
      'blocks APK download on mobile data when Wi-Fi-only is enabled',
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
      },
    );

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

    test(
      'downloads APK and delegates install to Android platform channel',
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
      },
    );

    test('reuses a complete downloaded APK without fetching again', () async {
      final apk = File(p.join(tempDir.path, _testUpdate.assetName));
      await apk.writeAsBytes([1, 2, 3, 4]);
      platform.wifiConnected = false;
      final service = buildService(
        client: MockClient((_) async => throw StateError('should not fetch')),
      );
      final progress = <int>[];

      final download = await service.downloadUpdate(
        _testUpdate,
        onProgress: (received, _) => progress.add(received),
      );

      expect(download.reusedExistingFile, isTrue);
      expect(download.apkPath, apk.path);
      expect(progress, contains(4));
      expect(await File(download.apkPath).readAsBytes(), [1, 2, 3, 4]);
    });

    test('coalesces concurrent downloads of the same APK', () async {
      final responseCompleter = Completer<http.StreamedResponse>();
      final client = ControlledDownloadClient((request) {
        expect(request.url.toString(), _testUpdate.downloadUrl);
        return responseCompleter.future;
      });
      final service = buildService(client: client);
      final firstProgress = <int>[];
      final secondProgress = <int>[];

      final first = service.downloadUpdate(
        _testUpdate,
        onProgress: (received, _) => firstProgress.add(received),
      );
      final second = service.downloadUpdate(
        _testUpdate,
        onProgress: (received, _) => secondProgress.add(received),
      );

      await waitFor(() => client.requestCount == 1);
      expect(client.requestCount, 1);
      expect(service.isDownloadingUpdate(_testUpdate), isTrue);

      responseCompleter.complete(
        http.StreamedResponse(
          Stream.fromIterable([
            [1, 2],
            [3, 4],
          ]),
          200,
          contentLength: 4,
        ),
      );

      final downloads = await Future.wait([first, second]);

      expect(downloads[0].apkPath, downloads[1].apkPath);
      expect(client.requestCount, 1);
      expect(service.hasActiveDownload, isFalse);
      expect(firstProgress, contains(4));
      expect(secondProgress, contains(4));
      expect(await File(downloads[0].apkPath).readAsBytes(), [1, 2, 3, 4]);
    });

    test('does not clear update cache while a download is active', () async {
      final responseCompleter = Completer<http.StreamedResponse>();
      final service = buildService(
        client: ControlledDownloadClient((_) => responseCompleter.future),
      );

      final download = service.downloadUpdate(_testUpdate);
      await Future<void>.delayed(Duration.zero);

      expect(service.hasActiveDownload, isTrue);
      await expectLater(
        service.clearDownloadedUpdates(),
        throwsA(isA<AppUpdateDownloadInProgressException>()),
      );

      responseCompleter.complete(
        http.StreamedResponse(
          Stream.value([1, 2, 3, 4]),
          200,
          contentLength: 4,
        ),
      );
      await download;

      expect(await service.clearDownloadedUpdates(), 1);
    });

    test(
      'deletes corrupt partial APK when downloaded size mismatches',
      () async {
        final service = buildService(
          client: ControlledDownloadClient((_) async {
            return http.StreamedResponse(
              Stream.value([1, 2]),
              200,
              contentLength: 2,
            );
          }),
        );

        await expectLater(
          service.downloadUpdate(_testUpdate),
          throwsA(isA<AppUpdateInvalidPackageException>()),
        );

        expect(
          await File(p.join(tempDir.path, _testUpdate.assetName)).exists(),
          isFalse,
        );
        expect(
          await File(
            '${p.join(tempDir.path, _testUpdate.assetName)}.part',
          ).exists(),
          isFalse,
        );
      },
    );

    test(
      'redownloads when cached APK size does not match asset size',
      () async {
        final apk = File(p.join(tempDir.path, _testUpdate.assetName));
        await apk.writeAsBytes([9]);
        var fetched = false;
        final service = buildService(
          client: MockClient((request) async {
            fetched = true;
            expect(request.url.toString(), _testUpdate.downloadUrl);
            return http.Response.bytes(
              [1, 2, 3, 4],
              200,
              headers: {'content-length': '4'},
            );
          }),
        );

        final download = await service.downloadUpdate(_testUpdate);

        expect(fetched, isTrue);
        expect(download.reusedExistingFile, isFalse);
        expect(await File(download.apkPath).readAsBytes(), [1, 2, 3, 4]);
      },
    );

    test('reports and clears downloaded update cache files', () async {
      await File(
        p.join(tempDir.path, 'memex_globalEarly_1.0.30_113.apk'),
      ).writeAsBytes([1]);
      await File(
        p.join(tempDir.path, 'memex_globalEarly_1.0.30_113.apk.part'),
      ).writeAsBytes([2, 3]);
      await File(p.join(tempDir.path, 'notes.txt')).writeAsString('keep');
      final service = buildService();

      final before = await service.getDownloadedUpdateCacheInfo();
      final deleted = await service.clearDownloadedUpdates();
      final after = await service.getDownloadedUpdateCacheInfo();

      expect(before.fileCount, 2);
      expect(before.totalBytes, 3);
      expect(deleted, 2);
      expect(after.hasFiles, isFalse);
      expect(await File(p.join(tempDir.path, 'notes.txt')).exists(), isTrue);
    });

    test(
      'opens unknown-app settings when install permission is missing',
      () async {
        final apk = File(p.join(tempDir.path, _testUpdate.assetName));
        await apk.writeAsBytes([1, 2, 3, 4]);
        platform.canInstall = false;
        final service = buildService();

        final result = await service.installUpdate(apk.path);

        expect(result.status, AppUpdateInstallStatus.permissionRequired);
        expect(platform.openedInstallSettings, isTrue);
        expect(platform.installedApkPath, isNull);
      },
    );

    test('coalesces concurrent install requests for the same APK', () async {
      final apk = File(p.join(tempDir.path, _testUpdate.assetName));
      await apk.writeAsBytes([1, 2, 3, 4]);
      platform.installCompleter = Completer<void>();
      final service = buildService();

      final first = service.installUpdate(apk.path);
      final second = service.installUpdate(apk.path);
      await waitFor(() => platform.installCallCount == 1);

      expect(platform.installCallCount, 1);
      platform.installCompleter!.complete();

      expect((await first).status, AppUpdateInstallStatus.started);
      expect((await second).status, AppUpdateInstallStatus.started);
      expect(platform.installedApkPath, apk.path);
    });

    test(
      'fails install before platform call when APK file is missing',
      () async {
        final service = buildService();

        await expectLater(
          service.installUpdate(p.join(tempDir.path, 'missing.apk')),
          throwsA(isA<AppUpdateInvalidPackageException>()),
        );

        expect(platform.canInstallCheckCount, 0);
        expect(platform.installCallCount, 0);
        expect(platform.installedApkPath, isNull);
      },
    );
  });
}

const _testUpdate = AppUpdateInfo(
  releaseName: 'Early',
  tagName: 'v1.0.30+113',
  versionName: '1.0.30',
  buildNumber: 113,
  assetName: 'memex_globalEarly_1.0.30_113.apk',
  sizeBytes: 4,
  downloadUrl: 'https://example.com/global.apk',
  releaseNotes: '',
);

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
      {'name': assetName, 'size': 1234, 'browser_download_url': downloadUrl},
    ],
  };
}

Future<void> waitFor(bool Function() condition) async {
  for (var i = 0; i < 20; i += 1) {
    if (condition()) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('Condition was not met before timeout.');
}

class FakeUpdatePlatform implements AppUpdatePlatform {
  bool wifiConnected = true;
  bool canInstall = true;
  bool openedInstallSettings = false;
  String? installedApkPath;
  int canInstallCheckCount = 0;
  int installCallCount = 0;
  Completer<void>? installCompleter;

  @override
  Future<bool> isWifiConnected() async => wifiConnected;

  @override
  Future<bool> canInstallApk() async {
    canInstallCheckCount += 1;
    return canInstall;
  }

  @override
  Future<void> openInstallPermissionSettings() async {
    openedInstallSettings = true;
  }

  @override
  Future<void> installApk(String apkPath) async {
    installCallCount += 1;
    installedApkPath = apkPath;
    final completer = installCompleter;
    if (completer != null) {
      await completer.future;
    }
  }
}

class ControlledDownloadClient extends http.BaseClient {
  ControlledDownloadClient(this.handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
      handler;
  int requestCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requestCount += 1;
    return handler(request);
  }
}
