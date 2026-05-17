import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:memex/config/app_flavor.dart';
import 'package:memex/utils/logger.dart';

class AppUpdateSettings {
  final bool autoCheckEnabled;
  final bool wifiOnlyDownloads;
  final bool autoDownloadAndInstall;
  final DateTime? lastCheckAt;

  const AppUpdateSettings({
    this.autoCheckEnabled = true,
    this.wifiOnlyDownloads = true,
    this.autoDownloadAndInstall = false,
    this.lastCheckAt,
  });

  factory AppUpdateSettings.fromJson(Map<String, dynamic> json) {
    return AppUpdateSettings(
      autoCheckEnabled: json['auto_check_enabled'] as bool? ?? true,
      wifiOnlyDownloads: json['wifi_only_downloads'] as bool? ?? true,
      autoDownloadAndInstall:
          json['auto_download_and_install'] as bool? ?? false,
      lastCheckAt: DateTime.tryParse(json['last_check_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'auto_check_enabled': autoCheckEnabled,
    'wifi_only_downloads': wifiOnlyDownloads,
    'auto_download_and_install': autoDownloadAndInstall,
    if (lastCheckAt != null) 'last_check_at': lastCheckAt!.toIso8601String(),
  };

  AppUpdateSettings copyWith({
    bool? autoCheckEnabled,
    bool? wifiOnlyDownloads,
    bool? autoDownloadAndInstall,
    DateTime? lastCheckAt,
    bool clearLastCheckAt = false,
  }) {
    return AppUpdateSettings(
      autoCheckEnabled: autoCheckEnabled ?? this.autoCheckEnabled,
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      autoDownloadAndInstall:
          autoDownloadAndInstall ?? this.autoDownloadAndInstall,
      lastCheckAt: clearLastCheckAt ? null : (lastCheckAt ?? this.lastCheckAt),
    );
  }

  bool shouldAutoCheck({
    required DateTime now,
    Duration minInterval = const Duration(hours: 12),
  }) {
    if (!autoCheckEnabled) return false;
    final checkedAt = lastCheckAt;
    if (checkedAt == null) return true;
    return now.difference(checkedAt) >= minInterval;
  }
}

class AppPackageVersion {
  final String versionName;
  final int buildNumber;

  const AppPackageVersion({
    required this.versionName,
    required this.buildNumber,
  });
}

class AppUpdateInfo {
  final String releaseName;
  final String tagName;
  final String versionName;
  final int buildNumber;
  final String assetName;
  final int sizeBytes;
  final String downloadUrl;
  final String releaseNotes;
  final DateTime? publishedAt;

  const AppUpdateInfo({
    required this.releaseName,
    required this.tagName,
    required this.versionName,
    required this.buildNumber,
    required this.assetName,
    required this.sizeBytes,
    required this.downloadUrl,
    required this.releaseNotes,
    this.publishedAt,
  });

  String get displayVersion => '$versionName+$buildNumber';
}

enum AppUpdateCheckStatus {
  unsupported,
  skippedNotWifi,
  noUpdate,
  updateAvailable,
}

class AppUpdateCheckResult {
  final AppUpdateCheckStatus status;
  final AppUpdateInfo? update;

  const AppUpdateCheckResult._(this.status, [this.update]);

  const AppUpdateCheckResult.unsupported()
    : this._(AppUpdateCheckStatus.unsupported);

  const AppUpdateCheckResult.skippedNotWifi()
    : this._(AppUpdateCheckStatus.skippedNotWifi);

  const AppUpdateCheckResult.noUpdate() : this._(AppUpdateCheckStatus.noUpdate);

  const AppUpdateCheckResult.updateAvailable(AppUpdateInfo update)
    : this._(AppUpdateCheckStatus.updateAvailable, update);
}

class AppUpdateDownloadResult {
  final AppUpdateInfo update;
  final String apkPath;
  final bool reusedExistingFile;

  const AppUpdateDownloadResult({
    required this.update,
    required this.apkPath,
    this.reusedExistingFile = false,
  });
}

class AppUpdateCacheInfo {
  final int fileCount;
  final int totalBytes;

  const AppUpdateCacheInfo({required this.fileCount, required this.totalBytes});

  static const empty = AppUpdateCacheInfo(fileCount: 0, totalBytes: 0);

  bool get hasFiles => fileCount > 0;
}

enum AppUpdateInstallStatus { started, permissionRequired, unsupported }

class AppUpdateInstallResult {
  final AppUpdateInstallStatus status;

  const AppUpdateInstallResult(this.status);
}

class AppUpdateWifiRequiredException implements Exception {
  const AppUpdateWifiRequiredException();

  @override
  String toString() => 'Wi-Fi is required to download this update.';
}

class AppUpdateEnvironment {
  final bool isAndroid;
  final bool isEarlyChannel;
  final String flavorName;

  const AppUpdateEnvironment({
    required this.isAndroid,
    required this.isEarlyChannel,
    required this.flavorName,
  });

  factory AppUpdateEnvironment.current() {
    final flavorName = switch ((AppFlavor.current, AppFlavor.channel)) {
      (AppFlavorType.cn, AppChannelType.early) => 'cnEarly',
      (AppFlavorType.global, AppChannelType.early) => 'globalEarly',
      (AppFlavorType.cn, AppChannelType.dev) => 'cnDev',
      (AppFlavorType.global, AppChannelType.dev) => 'globalDev',
      (AppFlavorType.cn, AppChannelType.stable) => 'cn',
      _ => 'global',
    };

    return AppUpdateEnvironment(
      isAndroid: Platform.isAndroid,
      isEarlyChannel: AppFlavor.isEarly,
      flavorName: flavorName,
    );
  }
}

abstract class AppUpdatePlatform {
  Future<bool> isWifiConnected();
  Future<bool> canInstallApk();
  Future<void> openInstallPermissionSettings();
  Future<void> installApk(String apkPath);
}

class MethodChannelAppUpdatePlatform implements AppUpdatePlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.memexlab.memex/app_update',
  );

  const MethodChannelAppUpdatePlatform();

  @override
  Future<bool> isWifiConnected() async {
    final result = await _channel.invokeMethod<bool>('isWifiConnected');
    return result ?? false;
  }

  @override
  Future<bool> canInstallApk() async {
    final result = await _channel.invokeMethod<bool>('canInstallApk');
    return result ?? false;
  }

  @override
  Future<void> openInstallPermissionSettings() {
    return _channel.invokeMethod<void>('openInstallPermissionSettings');
  }

  @override
  Future<void> installApk(String apkPath) {
    return _channel.invokeMethod<void>('installApk', {'apkPath': apkPath});
  }
}

class AppUpdateSettingsStore {
  static const String _key = 'early_update_settings';

  Future<AppUpdateSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      return const AppUpdateSettings();
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppUpdateSettings.fromJson(json);
    } catch (_) {
      return const AppUpdateSettings();
    }
  }

  Future<void> save(AppUpdateSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}

typedef PackageVersionLoader = Future<AppPackageVersion> Function();
typedef UpdateDirectoryProvider = Future<Directory> Function();
typedef Clock = DateTime Function();

class AppUpdateService {
  AppUpdateService({
    http.Client? httpClient,
    AppUpdatePlatform? platform,
    AppUpdateSettingsStore? settingsStore,
    AppUpdateEnvironment? environment,
    PackageVersionLoader? packageVersionLoader,
    UpdateDirectoryProvider? updateDirectoryProvider,
    Clock? clock,
  }) : _httpClient = httpClient ?? http.Client(),
       _platform = platform ?? const MethodChannelAppUpdatePlatform(),
       _settingsStore = settingsStore ?? AppUpdateSettingsStore(),
       _environment = environment ?? AppUpdateEnvironment.current(),
       _packageVersionLoader = packageVersionLoader ?? _loadPackageVersion,
       _updateDirectoryProvider =
           updateDirectoryProvider ?? _defaultUpdateDirectory,
       _clock = clock ?? DateTime.now;

  static final AppUpdateService instance = AppUpdateService();
  static const String releasesUrl =
      'https://api.github.com/repos/memex-lab/memex/releases?per_page=20';

  final http.Client _httpClient;
  final AppUpdatePlatform _platform;
  final AppUpdateSettingsStore _settingsStore;
  final AppUpdateEnvironment _environment;
  final PackageVersionLoader _packageVersionLoader;
  final UpdateDirectoryProvider _updateDirectoryProvider;
  final Clock _clock;
  final _logger = getLogger('AppUpdateService');

  bool get isSupported => _environment.isAndroid && _environment.isEarlyChannel;

  Future<AppUpdateSettings> loadSettings() => _settingsStore.load();

  Future<void> saveSettings(AppUpdateSettings settings) {
    return _settingsStore.save(settings);
  }

  Future<bool> shouldRunAutoCheck() async {
    if (!isSupported) return false;
    final settings = await loadSettings();
    return settings.shouldAutoCheck(now: _clock());
  }

  Future<AppUpdateCheckResult> checkForUpdate({
    bool manual = false,
    bool respectWifi = false,
  }) async {
    if (!isSupported) {
      return const AppUpdateCheckResult.unsupported();
    }

    final settings = await loadSettings();
    if (respectWifi && settings.wifiOnlyDownloads) {
      final isWifi = await _platform.isWifiConnected();
      if (!isWifi) {
        if (manual) {
          await saveSettings(settings.copyWith(lastCheckAt: _clock()));
        }
        return const AppUpdateCheckResult.skippedNotWifi();
      }
    }

    final packageVersion = await _packageVersionLoader();
    final releases = await _fetchReleases();
    final update = selectBestUpdate(
      releases: releases,
      currentBuildNumber: packageVersion.buildNumber,
      flavorName: _environment.flavorName,
    );

    await saveSettings(settings.copyWith(lastCheckAt: _clock()));
    if (update == null) {
      return const AppUpdateCheckResult.noUpdate();
    }
    return AppUpdateCheckResult.updateAvailable(update);
  }

  Future<AppUpdateDownloadResult> downloadUpdate(
    AppUpdateInfo update, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    final dir = await _updateDirectoryProvider();
    final fileName = _safeFileName(update.assetName);
    final targetFile = File(path.join(dir.path, fileName));
    if (await _isReusableDownloadedApk(targetFile, update)) {
      final cachedBytes = await targetFile.length();
      final totalBytes = update.sizeBytes > 0 ? update.sizeBytes : cachedBytes;
      onProgress?.call(totalBytes, totalBytes);
      _logger.info(
        'Reusing downloaded APK for ${update.displayVersion}: '
        '${targetFile.path}',
      );
      return AppUpdateDownloadResult(
        update: update,
        apkPath: targetFile.path,
        reusedExistingFile: true,
      );
    }

    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    final settings = await loadSettings();
    if (settings.wifiOnlyDownloads && !await _platform.isWifiConnected()) {
      throw const AppUpdateWifiRequiredException();
    }

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final tempFile = File('${targetFile.path}.part');
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    final request = http.Request('GET', Uri.parse(update.downloadUrl));
    request.headers.addAll(_githubHeaders);
    final response = await _httpClient.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'APK download failed: HTTP ${response.statusCode}',
        uri: Uri.parse(update.downloadUrl),
      );
    }

    final totalBytes = response.contentLength ?? update.sizeBytes;
    var receivedBytes = 0;
    final sink = tempFile.openWrite();
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        onProgress?.call(receivedBytes, totalBytes);
      }
    } finally {
      await sink.close();
    }

    if (await targetFile.exists()) {
      await targetFile.delete();
    }
    await tempFile.rename(targetFile.path);

    return AppUpdateDownloadResult(update: update, apkPath: targetFile.path);
  }

  Future<bool> hasDownloadedUpdate(AppUpdateInfo update) async {
    final dir = await _updateDirectoryProvider();
    final fileName = _safeFileName(update.assetName);
    final targetFile = File(path.join(dir.path, fileName));
    return _isReusableDownloadedApk(targetFile, update);
  }

  Future<AppUpdateCacheInfo> getDownloadedUpdateCacheInfo() async {
    final dir = await _updateDirectoryProvider();
    if (!await dir.exists()) {
      return AppUpdateCacheInfo.empty;
    }

    var fileCount = 0;
    var totalBytes = 0;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File || !_isUpdateCacheFile(entity)) continue;
      final stat = await entity.stat();
      if (stat.type != FileSystemEntityType.file) continue;
      fileCount += 1;
      totalBytes += stat.size;
    }
    return AppUpdateCacheInfo(fileCount: fileCount, totalBytes: totalBytes);
  }

  Future<int> clearDownloadedUpdates() async {
    final dir = await _updateDirectoryProvider();
    if (!await dir.exists()) {
      return 0;
    }

    var deletedCount = 0;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File || !_isUpdateCacheFile(entity)) continue;
      await entity.delete();
      deletedCount += 1;
    }
    return deletedCount;
  }

  Future<AppUpdateInstallResult> installUpdate(String apkPath) async {
    if (!isSupported) {
      return const AppUpdateInstallResult(AppUpdateInstallStatus.unsupported);
    }

    final canInstall = await _platform.canInstallApk();
    if (!canInstall) {
      await _platform.openInstallPermissionSettings();
      return const AppUpdateInstallResult(
        AppUpdateInstallStatus.permissionRequired,
      );
    }

    await _platform.installApk(apkPath);
    return const AppUpdateInstallResult(AppUpdateInstallStatus.started);
  }

  Future<List<Map<String, dynamic>>> _fetchReleases() async {
    final response = await _httpClient.get(
      Uri.parse(releasesUrl),
      headers: _githubHeaders,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'GitHub releases request failed: HTTP ${response.statusCode}',
        uri: Uri.parse(releasesUrl),
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('GitHub releases response is not a list');
    }

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  AppUpdateInfo? selectBestUpdate({
    required List<Map<String, dynamic>> releases,
    required int currentBuildNumber,
    required String flavorName,
  }) {
    final candidates = <AppUpdateInfo>[];

    for (final release in releases) {
      if (release['draft'] == true || release['prerelease'] != true) {
        continue;
      }

      final tagName = release['tag_name'] as String? ?? '';
      final assets = release['assets'];
      if (assets is! List) continue;

      for (final rawAsset in assets.whereType<Map>()) {
        final asset = Map<String, dynamic>.from(rawAsset);
        final name = asset['name'] as String? ?? '';
        final downloadUrl = asset['browser_download_url'] as String? ?? '';
        if (!name.toLowerCase().endsWith('.apk')) continue;
        if (!_assetMatchesFlavor(name, flavorName)) continue;
        if (downloadUrl.isEmpty) continue;

        final releaseNotes = release['body'] as String? ?? '';
        final buildNumber =
            _parseBuildNumber(name) ??
            _parseBuildNumber(releaseNotes) ??
            _parseBuildNumber(tagName);
        if (buildNumber == null || buildNumber <= currentBuildNumber) {
          continue;
        }

        candidates.add(
          AppUpdateInfo(
            releaseName: release['name'] as String? ?? name,
            tagName: tagName,
            versionName:
                _parseVersionName(name) ??
                _parseVersionName(releaseNotes) ??
                _parseVersionName(tagName) ??
                (tagName.isEmpty ? null : tagName) ??
                name,
            buildNumber: buildNumber,
            assetName: name,
            sizeBytes: (asset['size'] as num?)?.toInt() ?? 0,
            downloadUrl: downloadUrl,
            releaseNotes: releaseNotes,
            publishedAt: DateTime.tryParse(
              release['published_at'] as String? ?? '',
            ),
          ),
        );
      }
    }

    candidates.sort((a, b) => b.buildNumber.compareTo(a.buildNumber));
    final selected = candidates.isEmpty ? null : candidates.first;
    if (selected == null) {
      _logger.fine('No early update found for $flavorName');
    }
    return selected;
  }

  static Future<AppPackageVersion> _loadPackageVersion() async {
    final info = await PackageInfo.fromPlatform();
    return AppPackageVersion(
      versionName: info.version,
      buildNumber: int.tryParse(info.buildNumber) ?? 0,
    );
  }

  static Future<Directory> _defaultUpdateDirectory() async {
    final cacheDir = await getApplicationCacheDirectory();
    return Directory(path.join(cacheDir.path, 'updates'));
  }

  Future<bool> _isReusableDownloadedApk(File file, AppUpdateInfo update) async {
    try {
      if (!await file.exists()) return false;
      if (!file.path.toLowerCase().endsWith('.apk')) return false;

      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file || stat.size <= 0) {
        return false;
      }

      if (update.sizeBytes > 0 && stat.size != update.sizeBytes) {
        _logger.info(
          'Discarding cached APK with unexpected size for '
          '${update.displayVersion}: expected ${update.sizeBytes}, '
          'found ${stat.size}',
        );
        return false;
      }
      return true;
    } catch (e, st) {
      _logger.warning('Failed to inspect cached APK: ${file.path}', e, st);
      return false;
    }
  }

  static bool _isUpdateCacheFile(File file) {
    final lowerPath = file.path.toLowerCase();
    return lowerPath.endsWith('.apk') || lowerPath.endsWith('.apk.part');
  }

  static Map<String, String> get _githubHeaders => const {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'Memex-Early-Updater',
  };

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static bool _assetMatchesFlavor(String assetName, String flavorName) {
    final normalizedName = _normalize(assetName);
    final normalizedFlavor = _normalize(flavorName);
    if (normalizedName.contains(normalizedFlavor)) return true;

    if (normalizedFlavor == 'globalearly') {
      return normalizedName.contains('early') &&
          !normalizedName.contains('cnearly');
    }
    return false;
  }

  static int? _parseBuildNumber(String value) {
    final versionLineMatch = RegExp(
      r'Version:\s*[^\s+]+\+(\d+)',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (versionLineMatch != null) {
      return int.tryParse(versionLineMatch.group(1)!);
    }

    final assetMatch = RegExp(
      r'_(\d+)\.apk$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (assetMatch != null) {
      return int.tryParse(assetMatch.group(1)!);
    }

    final tagMatch = RegExp(r'[+_-](\d+)$').firstMatch(value.trim());
    if (tagMatch != null) {
      return int.tryParse(tagMatch.group(1)!);
    }
    return null;
  }

  static String? _parseVersionName(String value) {
    final versionLineMatch = RegExp(
      r'Version:\s*([^\s+]+)\+\d+',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (versionLineMatch != null) {
      return versionLineMatch.group(1);
    }

    final assetMatch = RegExp(
      r'memex_[^_]+_([^_]+)_\d+\.apk$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (assetMatch != null) {
      return assetMatch.group(1);
    }

    final tagMatch = RegExp(
      r'v?(\d+(?:\.\d+){1,3})(?:[+_-]\d+)?',
    ).firstMatch(value);
    return tagMatch?.group(1);
  }

  static String _safeFileName(String value) {
    final fallback = value.trim().isEmpty ? 'memex_early_update.apk' : value;
    return fallback.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }
}
