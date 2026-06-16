import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/app_update_router.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:memex/domain/models/app_build_info.dart';
import 'package:memex/domain/models/update_manifest.dart';
import 'package:memex/ui/settings/view_models/about_memex_viewmodel.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  group('AboutMemexViewModel', () {
    test('load populates build info, settings, and cache info', () async {
      final harness = _AboutMemexHarness();
      final viewModel = harness.createViewModel();

      await viewModel.load();

      expect(viewModel.loading, isFalse);
      expect(viewModel.buildInfo, harness.buildInfo);
      expect(viewModel.settings, harness.settings);
      expect(viewModel.cacheInfo.fileCount, 2);
      expect(viewModel.statusText, isNull);
    });

    test('checkNow stores result and refreshes status text', () async {
      final harness = _AboutMemexHarness(
        checkResult: _checkResult(
          status: UnifiedAppUpdateStatus.noUpdate,
        ),
      );
      final viewModel = harness.createViewModel();

      await viewModel.checkNow();

      expect(harness.manualCheckRequested, isTrue);
      expect(viewModel.checking, isFalse);
      expect(viewModel.updateCheck!.status, UnifiedAppUpdateStatus.noUpdate);
      expect(viewModel.statusText, UserStorage.l10n.appUpdateNoUpdate);
      expect(viewModel.cacheInfo.fileCount, 2);
    });

    test('performUpdateAction reports progress and refreshes cache', () async {
      final harness = _AboutMemexHarness();
      final viewModel = harness.createViewModel();
      viewModel.updateCheck = _checkResult(
        status: UnifiedAppUpdateStatus.updateAvailable,
        apkUpdate: _apkUpdate(),
      );

      await viewModel.performUpdateAction();

      expect(harness.performCalled, isTrue);
      expect(viewModel.performingUpdate, isFalse);
      expect(viewModel.downloadPercent, 50);
      expect(viewModel.statusText, UserStorage.l10n.earlyUpdateInstallStarted);
      expect(viewModel.cacheInfo.fileCount, 2);
    });

    test('settings toggles save and publish the updated value', () async {
      final harness = _AboutMemexHarness();
      final viewModel = harness.createViewModel();
      viewModel.settings = harness.settings;

      await viewModel.updateAutoCheckEnabled(false);
      await viewModel.updateWifiOnlyDownloads(false);
      await viewModel.updateAutoDownloadAndInstall(true);

      expect(harness.savedSettings, hasLength(3));
      expect(viewModel.settings!.autoCheckEnabled, isFalse);
      expect(viewModel.settings!.wifiOnlyDownloads, isFalse);
      expect(viewModel.settings!.autoDownloadAndInstall, isTrue);
    });

    test('clearUpdateCache clears cache and updates status', () async {
      final harness = _AboutMemexHarness();
      final viewModel = harness.createViewModel();
      viewModel.cacheInfo = const AppUpdateCacheInfo(
        fileCount: 2,
        totalBytes: 128,
      );

      await viewModel.clearUpdateCache();

      expect(harness.clearCacheCalled, isTrue);
      expect(viewModel.clearingCache, isFalse);
      expect(viewModel.cacheInfo, AppUpdateCacheInfo.empty);
      expect(viewModel.statusText, UserStorage.l10n.appUpdateCacheCleared);
    });
  });
}

class _AboutMemexHarness {
  _AboutMemexHarness({
    UnifiedAppUpdateCheckResult? checkResult,
  }) : checkResult = checkResult ?? _checkResult();

  final AppBuildInfo buildInfo = _buildInfo();
  final AppUpdateSettings settings = const AppUpdateSettings(
    autoCheckEnabled: true,
    wifiOnlyDownloads: true,
    autoDownloadAndInstall: false,
  );
  final UnifiedAppUpdateCheckResult checkResult;
  final savedSettings = <AppUpdateSettings>[];
  bool manualCheckRequested = false;
  bool performCalled = false;
  bool clearCacheCalled = false;

  AboutMemexViewModel createViewModel() {
    return AboutMemexViewModel(
      getAppBuildInfo: () async => Ok(buildInfo),
      getAppUpdateSettings: () async => settings,
      saveAppUpdateSettings: (settings) async {
        savedSettings.add(settings);
      },
      getAppUpdateCacheInfo: () async => const AppUpdateCacheInfo(
        fileCount: 2,
        totalBytes: 128,
      ),
      clearAppUpdateCache: () async {
        clearCacheCalled = true;
        return const Ok(2);
      },
      checkAppUpdate: ({bool manual = false}) async {
        manualCheckRequested = manual;
        return Ok(checkResult);
      },
      performAppUpdateAction: (check, {onProgress}) async {
        performCalled = true;
        onProgress?.call(4, 8);
        return const Ok(
          AppUpdateActionResult(AppUpdateActionStatus.installStarted),
        );
      },
    );
  }
}

AppBuildInfo _buildInfo() {
  return const AppBuildInfo(
    appName: 'Memex',
    packageName: 'com.memexlab.memex.early',
    versionName: '1.0.34',
    buildNumber: 117,
    flavorName: 'globalEarly',
    regionName: 'global',
    channelName: 'early',
    platformName: 'android',
    installerSource: 'com.android.packageinstaller',
  );
}

UnifiedAppUpdateCheckResult _checkResult({
  UnifiedAppUpdateStatus status = UnifiedAppUpdateStatus.updateAvailable,
  AppUpdateInfo? apkUpdate,
}) {
  return UnifiedAppUpdateCheckResult(
    status: status,
    buildInfo: _buildInfo(),
    providerKind: UpdateProviderKind.githubApk,
    manifestSource: 'https://example.com/manifest.json',
    checkedAt: DateTime.utc(2026, 6, 16),
    apkUpdate: apkUpdate,
  );
}

AppUpdateInfo _apkUpdate() {
  return const AppUpdateInfo(
    releaseName: 'Memex 1.0.35',
    tagName: 'v1.0.35',
    versionName: '1.0.35',
    buildNumber: 118,
    assetName: 'memex.apk',
    sizeBytes: 8,
    downloadUrl: 'https://example.com/memex.apk',
    sha256: null,
    releaseNotes: 'Update notes',
  );
}
