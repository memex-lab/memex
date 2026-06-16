import 'package:memex/data/services/app_info_service.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:memex/data/services/update_manifest_service.dart';
import 'package:memex/domain/models/app_build_info.dart';
import 'package:memex/domain/models/update_manifest.dart';
import 'package:memex/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

enum UnifiedAppUpdateStatus {
  noUpdate,
  updateAvailable,
  unsupported,
  checkFailed,
}

class UnifiedAppUpdateCheckResult {
  const UnifiedAppUpdateCheckResult({
    required this.status,
    required this.buildInfo,
    required this.providerKind,
    required this.manifestSource,
    required this.checkedAt,
    this.channel,
    this.apkUpdate,
    this.actionUri,
    this.error,
    this.manifestGeneratedAt,
    this.usedManifestFallback = false,
    this.usedBuiltInFallback = false,
  });

  final UnifiedAppUpdateStatus status;
  final AppBuildInfo buildInfo;
  final UpdateProviderKind providerKind;
  final UpdateManifestChannel? channel;
  final AppUpdateInfo? apkUpdate;
  final Uri? actionUri;
  final String manifestSource;
  final DateTime checkedAt;
  final DateTime? manifestGeneratedAt;
  final Object? error;
  final bool usedManifestFallback;
  final bool usedBuiltInFallback;

  bool get hasUpdate => status == UnifiedAppUpdateStatus.updateAvailable;
  bool get canDownloadApk => apkUpdate != null;
  bool get canOpenExternalUpdate => actionUri != null && apkUpdate == null;
  bool get requiresUpdate =>
      channel?.requiresUpdateFor(buildInfo.buildNumber) ?? false;
  int? get latestBuild => channel?.latestBuild ?? apkUpdate?.buildNumber;
  String? get latestVersionName =>
      channel?.versionName ?? apkUpdate?.versionName;
}

enum AppUpdateActionStatus {
  openedExternal,
  installStarted,
  permissionRequired,
  unsupported,
}

class AppUpdateActionResult {
  const AppUpdateActionResult(this.status);

  final AppUpdateActionStatus status;
}

abstract class UnifiedUpdateProvider {
  const UnifiedUpdateProvider();

  UpdateProviderKind get kind;

  bool supports(AppBuildInfo buildInfo, UpdateManifestChannel channel);

  UnifiedAppUpdateCheckResult buildResult({
    required AppBuildInfo buildInfo,
    required UpdateManifestChannel channel,
    required UpdateManifestLoadResult manifestLoad,
    required DateTime checkedAt,
  });

  bool packageMatches(AppBuildInfo buildInfo, UpdateManifestChannel channel) {
    if (buildInfo.isAndroid) {
      final expected = channel.packageName;
      return expected == null || expected == buildInfo.packageName;
    }
    if (buildInfo.isIOS) {
      final expected = channel.bundleId;
      return expected == null || expected == buildInfo.packageName;
    }
    return false;
  }

  UnifiedAppUpdateCheckResult noUpdateResult({
    required AppBuildInfo buildInfo,
    required UpdateManifestChannel channel,
    required UpdateManifestLoadResult manifestLoad,
    required DateTime checkedAt,
  }) {
    return UnifiedAppUpdateCheckResult(
      status: UnifiedAppUpdateStatus.noUpdate,
      buildInfo: buildInfo,
      providerKind: kind,
      channel: channel,
      manifestSource: manifestLoad.sourceUrl,
      checkedAt: checkedAt,
      manifestGeneratedAt: manifestLoad.manifest.generatedAt,
      usedManifestFallback: manifestLoad.usedFallback,
      usedBuiltInFallback: manifestLoad.usedBuiltInFallback,
    );
  }
}

class AppleAppStoreUpdateProvider extends UnifiedUpdateProvider {
  const AppleAppStoreUpdateProvider();

  @override
  UpdateProviderKind get kind => UpdateProviderKind.appStore;

  @override
  bool supports(AppBuildInfo buildInfo, UpdateManifestChannel channel) {
    return buildInfo.isIOS &&
        channel.provider == kind &&
        packageMatches(buildInfo, channel);
  }

  @override
  UnifiedAppUpdateCheckResult buildResult({
    required AppBuildInfo buildInfo,
    required UpdateManifestChannel channel,
    required UpdateManifestLoadResult manifestLoad,
    required DateTime checkedAt,
  }) {
    if (!channel.isNewerThan(buildInfo.buildNumber)) {
      return noUpdateResult(
        buildInfo: buildInfo,
        channel: channel,
        manifestLoad: manifestLoad,
        checkedAt: checkedAt,
      );
    }
    return _externalResult(
      kind: kind,
      buildInfo: buildInfo,
      channel: channel,
      manifestLoad: manifestLoad,
      checkedAt: checkedAt,
    );
  }
}

class AndroidStoreRedirectProvider extends UnifiedUpdateProvider {
  const AndroidStoreRedirectProvider();

  @override
  UpdateProviderKind get kind => UpdateProviderKind.androidStore;

  @override
  bool supports(AppBuildInfo buildInfo, UpdateManifestChannel channel) {
    return buildInfo.isAndroid &&
        channel.provider == kind &&
        packageMatches(buildInfo, channel);
  }

  @override
  UnifiedAppUpdateCheckResult buildResult({
    required AppBuildInfo buildInfo,
    required UpdateManifestChannel channel,
    required UpdateManifestLoadResult manifestLoad,
    required DateTime checkedAt,
  }) {
    if (!channel.isNewerThan(buildInfo.buildNumber)) {
      return noUpdateResult(
        buildInfo: buildInfo,
        channel: channel,
        manifestLoad: manifestLoad,
        checkedAt: checkedAt,
      );
    }
    return _externalResult(
      kind: kind,
      buildInfo: buildInfo,
      channel: channel,
      manifestLoad: manifestLoad,
      checkedAt: checkedAt,
    );
  }
}

class GooglePlayUpdateProvider extends UnifiedUpdateProvider {
  const GooglePlayUpdateProvider();

  @override
  UpdateProviderKind get kind => UpdateProviderKind.googlePlay;

  @override
  bool supports(AppBuildInfo buildInfo, UpdateManifestChannel channel) {
    return buildInfo.isAndroid &&
        channel.provider == kind &&
        packageMatches(buildInfo, channel);
  }

  @override
  UnifiedAppUpdateCheckResult buildResult({
    required AppBuildInfo buildInfo,
    required UpdateManifestChannel channel,
    required UpdateManifestLoadResult manifestLoad,
    required DateTime checkedAt,
  }) {
    if (!channel.isNewerThan(buildInfo.buildNumber)) {
      return noUpdateResult(
        buildInfo: buildInfo,
        channel: channel,
        manifestLoad: manifestLoad,
        checkedAt: checkedAt,
      );
    }
    return _externalResult(
      kind: kind,
      buildInfo: buildInfo,
      channel: channel,
      manifestLoad: manifestLoad,
      checkedAt: checkedAt,
    );
  }
}

class GithubApkUpdateProvider extends UnifiedUpdateProvider {
  const GithubApkUpdateProvider();

  @override
  UpdateProviderKind get kind => UpdateProviderKind.githubApk;

  @override
  bool supports(AppBuildInfo buildInfo, UpdateManifestChannel channel) {
    return buildInfo.isAndroid &&
        channel.provider == kind &&
        packageMatches(buildInfo, channel) &&
        _allowsDirectApk(buildInfo, channel);
  }

  @override
  UnifiedAppUpdateCheckResult buildResult({
    required AppBuildInfo buildInfo,
    required UpdateManifestChannel channel,
    required UpdateManifestLoadResult manifestLoad,
    required DateTime checkedAt,
  }) {
    if (!channel.isNewerThan(buildInfo.buildNumber)) {
      return noUpdateResult(
        buildInfo: buildInfo,
        channel: channel,
        manifestLoad: manifestLoad,
        checkedAt: checkedAt,
      );
    }

    final apkUrl = channel.apkUrl!;
    final update = AppUpdateInfo(
      releaseName: 'Memex ${channel.versionName}+${channel.latestBuild}',
      tagName: channel.releaseNotesUrl ?? channel.versionName!,
      versionName: channel.versionName!,
      buildNumber: channel.latestBuild,
      assetName: _assetNameFromUrl(apkUrl, buildInfo, channel),
      sizeBytes: channel.sizeBytes!,
      downloadUrl: apkUrl,
      sha256: channel.sha256,
      releaseNotes: channel.releaseNotes ?? channel.releaseNotesUrl ?? '',
      publishedAt: manifestLoad.manifest.generatedAt,
    );

    return UnifiedAppUpdateCheckResult(
      status: UnifiedAppUpdateStatus.updateAvailable,
      buildInfo: buildInfo,
      providerKind: kind,
      channel: channel,
      apkUpdate: update,
      manifestSource: manifestLoad.sourceUrl,
      checkedAt: checkedAt,
      manifestGeneratedAt: manifestLoad.manifest.generatedAt,
      usedManifestFallback: manifestLoad.usedFallback,
      usedBuiltInFallback: manifestLoad.usedBuiltInFallback,
    );
  }

  bool _allowsDirectApk(AppBuildInfo buildInfo, UpdateManifestChannel channel) {
    if (buildInfo.isEarly || buildInfo.isDev || buildInfo.isDirectInstall) {
      return true;
    }
    final packageName = buildInfo.packageName.toLowerCase();
    return packageName.contains('.early') ||
        packageName.contains('.dev') ||
        channel.key.contains('_early') ||
        channel.key.contains('_dev');
  }

  String _assetNameFromUrl(
    String apkUrl,
    AppBuildInfo buildInfo,
    UpdateManifestChannel channel,
  ) {
    final uri = Uri.tryParse(apkUrl);
    final pathSegments = uri?.pathSegments ?? const <String>[];
    if (pathSegments.isNotEmpty) {
      final candidate = Uri.decodeComponent(pathSegments.last);
      if (candidate.toLowerCase().endsWith('.apk')) return candidate;
    }
    return 'memex_${buildInfo.flavorName}_${channel.versionName}_${channel.latestBuild}.apk';
  }
}

class NoopUpdateProvider extends UnifiedUpdateProvider {
  const NoopUpdateProvider();

  @override
  UpdateProviderKind get kind => UpdateProviderKind.noop;

  @override
  bool supports(AppBuildInfo buildInfo, UpdateManifestChannel channel) {
    return channel.provider == kind;
  }

  @override
  UnifiedAppUpdateCheckResult buildResult({
    required AppBuildInfo buildInfo,
    required UpdateManifestChannel channel,
    required UpdateManifestLoadResult manifestLoad,
    required DateTime checkedAt,
  }) {
    return noUpdateResult(
      buildInfo: buildInfo,
      channel: channel,
      manifestLoad: manifestLoad,
      checkedAt: checkedAt,
    );
  }
}

UnifiedAppUpdateCheckResult _externalResult({
  required UpdateProviderKind kind,
  required AppBuildInfo buildInfo,
  required UpdateManifestChannel channel,
  required UpdateManifestLoadResult manifestLoad,
  required DateTime checkedAt,
}) {
  return UnifiedAppUpdateCheckResult(
    status: UnifiedAppUpdateStatus.updateAvailable,
    buildInfo: buildInfo,
    providerKind: kind,
    channel: channel,
    actionUri: channel.primaryActionUri,
    manifestSource: manifestLoad.sourceUrl,
    checkedAt: checkedAt,
    manifestGeneratedAt: manifestLoad.manifest.generatedAt,
    usedManifestFallback: manifestLoad.usedFallback,
    usedBuiltInFallback: manifestLoad.usedBuiltInFallback,
  );
}

typedef AppUpdateRouterClock = DateTime Function();

class AppUpdateRouter {
  AppUpdateRouter({
    AppInfoService? appInfoService,
    UpdateManifestService? manifestService,
    AppUpdateService? apkUpdateService,
    List<UnifiedUpdateProvider>? providers,
    AppUpdateRouterClock? clock,
  }) : _appInfoService = appInfoService ?? AppInfoService.instance,
       _manifestService = manifestService ?? UpdateManifestService.instance,
       _apkUpdateService = apkUpdateService ?? AppUpdateService.instance,
       _providers =
           providers ??
           const [
             AppleAppStoreUpdateProvider(),
             AndroidStoreRedirectProvider(),
             GooglePlayUpdateProvider(),
             GithubApkUpdateProvider(),
             NoopUpdateProvider(),
           ],
       _clock = clock ?? DateTime.now;

  static final AppUpdateRouter instance = AppUpdateRouter();

  final AppInfoService _appInfoService;
  final UpdateManifestService _manifestService;
  final AppUpdateService _apkUpdateService;
  final List<UnifiedUpdateProvider> _providers;
  final AppUpdateRouterClock _clock;
  final _logger = getLogger('AppUpdateRouter');

  Future<bool> shouldRunAutoCheck() async {
    final buildInfo = await _appInfoService.loadBuildInfo();
    if (buildInfo.isDev) return false;
    final settings = await _apkUpdateService.loadSettings();
    return settings.shouldAutoCheck(now: _clock());
  }

  Future<AppUpdateSettings> loadSettings() {
    return _apkUpdateService.loadSettings();
  }

  Future<void> saveSettings(AppUpdateSettings settings) {
    return _apkUpdateService.saveSettings(settings);
  }

  Future<AppUpdateCacheInfo> getDownloadedUpdateCacheInfo() {
    return _apkUpdateService.getDownloadedUpdateCacheInfo();
  }

  Future<int> clearDownloadedUpdates() {
    return _apkUpdateService.clearDownloadedUpdates();
  }

  Future<UnifiedAppUpdateCheckResult> checkForUpdate({
    bool manual = false,
  }) async {
    final buildInfo = await _appInfoService.loadBuildInfo();
    final checkedAt = _clock();
    if (!manual && buildInfo.isDev) {
      return _checkFailed(
        buildInfo: buildInfo,
        checkedAt: checkedAt,
        error: 'Dev builds do not run automatic update checks.',
      );
    }

    try {
      final manifestLoad = await _manifestService.loadManifest();
      if (manifestLoad.usedBuiltInFallback) {
        await _recordLastCheckAt();
        return _checkFailed(
          buildInfo: buildInfo,
          checkedAt: checkedAt,
          error: manifestLoad.error ?? 'No update manifest is available.',
          manifestSource: manifestLoad.sourceUrl,
          usedManifestFallback: true,
          usedBuiltInFallback: true,
        );
      }

      final channel = manifestLoad.manifest.channelFor(buildInfo);
      if (channel == null) {
        await _recordLastCheckAt();
        return UnifiedAppUpdateCheckResult(
          status: UnifiedAppUpdateStatus.noUpdate,
          buildInfo: buildInfo,
          providerKind: UpdateProviderKind.noop,
          manifestSource: manifestLoad.sourceUrl,
          checkedAt: checkedAt,
          manifestGeneratedAt: manifestLoad.manifest.generatedAt,
          usedManifestFallback: manifestLoad.usedFallback,
        );
      }

      final provider = selectProvider(buildInfo, channel);
      if (provider == null) {
        await _recordLastCheckAt();
        return UnifiedAppUpdateCheckResult(
          status: UnifiedAppUpdateStatus.unsupported,
          buildInfo: buildInfo,
          providerKind: channel.provider,
          channel: channel,
          manifestSource: manifestLoad.sourceUrl,
          checkedAt: checkedAt,
          manifestGeneratedAt: manifestLoad.manifest.generatedAt,
          usedManifestFallback: manifestLoad.usedFallback,
        );
      }

      final result = provider.buildResult(
        buildInfo: buildInfo,
        channel: channel,
        manifestLoad: manifestLoad,
        checkedAt: checkedAt,
      );
      await _recordLastCheckAt();
      return result;
    } catch (e, st) {
      _logger.warning('Unified app update check failed', e, st);
      await _recordLastCheckAt();
      return _checkFailed(buildInfo: buildInfo, checkedAt: checkedAt, error: e);
    }
  }

  UnifiedUpdateProvider? selectProvider(
    AppBuildInfo buildInfo,
    UpdateManifestChannel channel,
  ) {
    for (final provider in _providers) {
      if (provider.supports(buildInfo, channel)) return provider;
    }
    return null;
  }

  Future<AppUpdateActionResult> performUpdateAction(
    UnifiedAppUpdateCheckResult check, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    final apkUpdate = check.apkUpdate;
    if (apkUpdate != null) {
      final download = await _apkUpdateService.downloadUpdate(
        apkUpdate,
        onProgress: onProgress,
      );
      final install = await _apkUpdateService.installUpdate(download.apkPath);
      return switch (install.status) {
        AppUpdateInstallStatus.started => const AppUpdateActionResult(
          AppUpdateActionStatus.installStarted,
        ),
        AppUpdateInstallStatus.permissionRequired =>
          const AppUpdateActionResult(AppUpdateActionStatus.permissionRequired),
        AppUpdateInstallStatus.unsupported => const AppUpdateActionResult(
          AppUpdateActionStatus.unsupported,
        ),
      };
    }

    final actionUri = check.actionUri;
    if (actionUri != null) {
      final launched = await launchUrl(
        actionUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        return const AppUpdateActionResult(
          AppUpdateActionStatus.openedExternal,
        );
      }
    }

    return const AppUpdateActionResult(AppUpdateActionStatus.unsupported);
  }

  Future<void> _recordLastCheckAt() async {
    final settings = await _apkUpdateService.loadSettings();
    await _apkUpdateService.saveSettings(
      settings.copyWith(lastCheckAt: _clock()),
    );
  }

  UnifiedAppUpdateCheckResult _checkFailed({
    required AppBuildInfo buildInfo,
    required DateTime checkedAt,
    required Object error,
    String manifestSource = 'unavailable',
    bool usedManifestFallback = false,
    bool usedBuiltInFallback = false,
  }) {
    return UnifiedAppUpdateCheckResult(
      status: UnifiedAppUpdateStatus.checkFailed,
      buildInfo: buildInfo,
      providerKind: UpdateProviderKind.noop,
      manifestSource: manifestSource,
      checkedAt: checkedAt,
      error: error,
      usedManifestFallback: usedManifestFallback,
      usedBuiltInFallback: usedBuiltInFallback,
    );
  }
}
