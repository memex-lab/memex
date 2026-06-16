import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/app_update_router.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:memex/domain/models/app_build_info.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

abstract class AboutMemexViewModelContract implements Listenable {
  AppBuildInfo? get buildInfo;
  AppUpdateSettings? get settings;
  AppUpdateCacheInfo get cacheInfo;
  UnifiedAppUpdateCheckResult? get updateCheck;
  bool get loading;
  bool get checking;
  bool get performingUpdate;
  bool get clearingCache;
  int get downloadPercent;
  String? get statusText;

  Future<void> load();
  Future<void> checkNow();
  Future<void> performUpdateAction();
  Future<void> clearUpdateCache();
  Future<void> copyDiagnostics();
  Future<void> updateAutoCheckEnabled(bool value);
  Future<void> updateWifiOnlyDownloads(bool value);
  Future<void> updateAutoDownloadAndInstall(bool value);
}

typedef AppBuildInfoLoader = Future<Result<AppBuildInfo>> Function();
typedef AppUpdateSettingsLoader = Future<AppUpdateSettings> Function();
typedef AppUpdateSettingsSaver = Future<void> Function(
  AppUpdateSettings settings,
);
typedef AppUpdateCacheInfoLoader = Future<AppUpdateCacheInfo> Function();
typedef AppUpdateCacheClearer = Future<Result<int>> Function();
typedef AppUpdateChecker = Future<Result<UnifiedAppUpdateCheckResult>>
    Function({
  bool manual,
});
typedef AppUpdateActionPerformer = Future<Result<AppUpdateActionResult>>
    Function(
  UnifiedAppUpdateCheckResult check, {
  void Function(int receivedBytes, int totalBytes)? onProgress,
});

class AboutMemexViewModel extends ChangeNotifier
    implements AboutMemexViewModelContract {
  AboutMemexViewModel({
    MemexRouter? router,
    AppBuildInfoLoader? getAppBuildInfo,
    AppUpdateSettingsLoader? getAppUpdateSettings,
    AppUpdateSettingsSaver? saveAppUpdateSettings,
    AppUpdateCacheInfoLoader? getAppUpdateCacheInfo,
    AppUpdateCacheClearer? clearAppUpdateCache,
    AppUpdateChecker? checkAppUpdate,
    AppUpdateActionPerformer? performAppUpdateAction,
  })  : assert(
          router != null ||
              (getAppBuildInfo != null &&
                  getAppUpdateSettings != null &&
                  saveAppUpdateSettings != null &&
                  getAppUpdateCacheInfo != null &&
                  clearAppUpdateCache != null &&
                  checkAppUpdate != null &&
                  performAppUpdateAction != null),
          'Provide a router or all test dependencies',
        ),
        _getAppBuildInfo = getAppBuildInfo ?? router!.getAppBuildInfo,
        _getAppUpdateSettings =
            getAppUpdateSettings ?? router!.getAppUpdateSettings,
        _saveAppUpdateSettings =
            saveAppUpdateSettings ?? router!.saveAppUpdateSettings,
        _getAppUpdateCacheInfo =
            getAppUpdateCacheInfo ?? router!.getAppUpdateCacheInfo,
        _clearAppUpdateCache =
            clearAppUpdateCache ?? router!.clearAppUpdateCache,
        _checkAppUpdate = checkAppUpdate ?? router!.checkAppUpdate,
        _performAppUpdateAction =
            performAppUpdateAction ?? router!.performAppUpdateAction;

  final AppBuildInfoLoader _getAppBuildInfo;
  final AppUpdateSettingsLoader _getAppUpdateSettings;
  final AppUpdateSettingsSaver _saveAppUpdateSettings;
  final AppUpdateCacheInfoLoader _getAppUpdateCacheInfo;
  final AppUpdateCacheClearer _clearAppUpdateCache;
  final AppUpdateChecker _checkAppUpdate;
  final AppUpdateActionPerformer _performAppUpdateAction;

  @override
  AppBuildInfo? buildInfo;

  @override
  AppUpdateSettings? settings;

  @override
  AppUpdateCacheInfo cacheInfo = AppUpdateCacheInfo.empty;

  @override
  UnifiedAppUpdateCheckResult? updateCheck;

  @override
  bool loading = false;

  @override
  bool checking = false;

  @override
  bool performingUpdate = false;

  @override
  bool clearingCache = false;

  @override
  int downloadPercent = 0;

  @override
  String? statusText;

  bool get _busy => loading || checking || performingUpdate || clearingCache;

  @override
  Future<void> load() async {
    if (loading) return;
    loading = true;
    notifyListeners();

    final buildResult = await _getAppBuildInfo();
    buildResult.when(
      onOk: (value) => buildInfo = value,
      onError: (error, _) =>
          statusText = UserStorage.l10n.appUpdateCheckFailed(error),
    );

    try {
      settings = await _getAppUpdateSettings();
      cacheInfo = await _getAppUpdateCacheInfo();
    } catch (e) {
      statusText = UserStorage.l10n.appUpdateCheckFailed(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> checkNow() async {
    if (_busy) return;
    checking = true;
    statusText = UserStorage.l10n.appUpdateChecking;
    notifyListeners();

    final result = await _checkAppUpdate(manual: true);
    result.when(
      onOk: (value) {
        updateCheck = value;
        statusText = _statusTextForCheck(value);
      },
      onError: (error, _) =>
          statusText = UserStorage.l10n.appUpdateCheckFailed(error),
    );

    try {
      settings = await _getAppUpdateSettings();
      cacheInfo = await _getAppUpdateCacheInfo();
    } catch (_) {
      // The check result is the user-facing state; cache refresh is best effort.
    }

    checking = false;
    notifyListeners();
  }

  @override
  Future<void> performUpdateAction() async {
    final check = updateCheck;
    if (check == null || !check.hasUpdate || _busy) return;

    performingUpdate = true;
    downloadPercent = 0;
    statusText = check.canDownloadApk
        ? UserStorage.l10n.appUpdateDownloadingPercent(0)
        : UserStorage.l10n.appUpdateOpeningStore;
    notifyListeners();

    final result = await _performAppUpdateAction(
      check,
      onProgress: (receivedBytes, totalBytes) {
        if (totalBytes <= 0) return;
        downloadPercent =
            ((receivedBytes / totalBytes) * 100).clamp(0, 100).round();
        statusText = UserStorage.l10n.appUpdateDownloadingPercent(
          downloadPercent,
        );
        notifyListeners();
      },
    );

    result.when(
      onOk: (value) {
        statusText = switch (value.status) {
          AppUpdateActionStatus.openedExternal =>
            UserStorage.l10n.appUpdateStoreOpened,
          AppUpdateActionStatus.installStarted =>
            UserStorage.l10n.earlyUpdateInstallStarted,
          AppUpdateActionStatus.permissionRequired =>
            UserStorage.l10n.earlyUpdateInstallPermissionRequired,
          AppUpdateActionStatus.unsupported =>
            UserStorage.l10n.appUpdateUnsupportedProvider,
        };
      },
      onError: (error, _) {
        statusText = switch (error) {
          AppUpdateWifiRequiredException() =>
            UserStorage.l10n.earlyUpdateSkippedMobile,
          AppUpdateDownloadInProgressException() =>
            UserStorage.l10n.earlyUpdateDownloadInProgress,
          _ => UserStorage.l10n.appUpdateCheckFailed(error),
        };
      },
    );

    try {
      cacheInfo = await _getAppUpdateCacheInfo();
    } catch (_) {
      // Best effort.
    }
    performingUpdate = false;
    notifyListeners();
  }

  @override
  Future<void> clearUpdateCache() async {
    if (_busy) return;
    clearingCache = true;
    notifyListeners();

    final result = await _clearAppUpdateCache();
    result.when(
      onOk: (_) {
        cacheInfo = AppUpdateCacheInfo.empty;
        statusText = UserStorage.l10n.appUpdateCacheCleared;
      },
      onError: (error, _) =>
          statusText = UserStorage.l10n.appUpdateCheckFailed(error),
    );

    clearingCache = false;
    notifyListeners();
  }

  @override
  Future<void> copyDiagnostics() async {
    final info = buildInfo;
    if (info == null) return;

    try {
      final check = updateCheck;
      await Clipboard.setData(
        ClipboardData(
          text: info.diagnostics(
            updateProvider: check?.providerKind.wireName,
            updateChannel: check?.channel?.key,
            manifestSource: check?.manifestSource,
            manifestGeneratedAt: check?.manifestGeneratedAt,
          ),
        ),
      );
      statusText = UserStorage.l10n.appUpdateDiagnosticsCopied;
    } catch (e) {
      statusText = UserStorage.l10n.appUpdateDiagnosticsCopyFailed(e);
    }
    notifyListeners();
  }

  @override
  Future<void> updateAutoCheckEnabled(bool value) async {
    final current = settings;
    if (current == null || _busy) return;
    final updated = current.copyWith(autoCheckEnabled: value);
    await _saveAppUpdateSettings(updated);
    settings = updated;
    notifyListeners();
  }

  @override
  Future<void> updateWifiOnlyDownloads(bool value) async {
    final current = settings;
    if (current == null || _busy) return;
    final updated = current.copyWith(wifiOnlyDownloads: value);
    await _saveAppUpdateSettings(updated);
    settings = updated;
    notifyListeners();
  }

  @override
  Future<void> updateAutoDownloadAndInstall(bool value) async {
    final current = settings;
    if (current == null || _busy) return;
    final updated = current.copyWith(autoDownloadAndInstall: value);
    await _saveAppUpdateSettings(updated);
    settings = updated;
    notifyListeners();
  }

  String _statusTextForCheck(UnifiedAppUpdateCheckResult check) {
    return switch (check.status) {
      UnifiedAppUpdateStatus.noUpdate => UserStorage.l10n.appUpdateNoUpdate,
      UnifiedAppUpdateStatus.unsupported =>
        UserStorage.l10n.appUpdateUnsupportedProvider,
      UnifiedAppUpdateStatus.checkFailed =>
        UserStorage.l10n.appUpdateCheckFailed(
          check.error ?? 'manifest unavailable',
        ),
      UnifiedAppUpdateStatus.updateAvailable => check.canDownloadApk
          ? UserStorage.l10n.appUpdateApkFound(
              check.latestVersionName ?? '-',
              check.latestBuild ?? 0,
            )
          : UserStorage.l10n.appUpdateStoreFound(
              check.latestVersionName ?? '-',
              check.latestBuild ?? 0,
            ),
    };
  }
}
