import 'dart:io';

import 'package:flutter/services.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/domain/models/app_build_info.dart';
import 'package:memex/utils/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppPackageMetadata {
  const AppPackageMetadata({
    required this.appName,
    required this.packageName,
    required this.versionName,
    required this.buildNumber,
  });

  final String appName;
  final String packageName;
  final String versionName;
  final int buildNumber;
}

class AppInfoEnvironment {
  const AppInfoEnvironment({
    required this.isAndroid,
    required this.isIOS,
    required this.platformName,
  });

  factory AppInfoEnvironment.current() {
    if (Platform.isAndroid) {
      return const AppInfoEnvironment(
        isAndroid: true,
        isIOS: false,
        platformName: 'android',
      );
    }
    if (Platform.isIOS) {
      return const AppInfoEnvironment(
        isAndroid: false,
        isIOS: true,
        platformName: 'ios',
      );
    }
    return const AppInfoEnvironment(
      isAndroid: false,
      isIOS: false,
      platformName: 'unknown',
    );
  }

  final bool isAndroid;
  final bool isIOS;
  final String platformName;
}

abstract class AppInfoPlatform {
  Future<String?> getInstallerSource();
}

class MethodChannelAppInfoPlatform implements AppInfoPlatform {
  const MethodChannelAppInfoPlatform();

  static const MethodChannel _channel = MethodChannel(
    'com.memexlab.memex/app_info',
  );

  @override
  Future<String?> getInstallerSource() {
    return _channel.invokeMethod<String>('getInstallerSource');
  }
}

typedef AppPackageMetadataLoader = Future<AppPackageMetadata> Function();

class AppInfoService {
  AppInfoService({
    AppInfoEnvironment? environment,
    AppInfoPlatform? platform,
    AppPackageMetadataLoader? packageLoader,
  }) : _environment = environment ?? AppInfoEnvironment.current(),
       _platform = platform ?? const MethodChannelAppInfoPlatform(),
       _packageLoader = packageLoader ?? _loadPackageMetadata;

  static final AppInfoService instance = AppInfoService();

  final AppInfoEnvironment _environment;
  final AppInfoPlatform _platform;
  final AppPackageMetadataLoader _packageLoader;
  final _logger = getLogger('AppInfoService');

  Future<AppBuildInfo> loadBuildInfo() async {
    final package = await _packageLoader();
    return AppBuildInfo(
      appName: package.appName,
      packageName: package.packageName,
      versionName: package.versionName,
      buildNumber: package.buildNumber,
      flavorName: AppFlavor.name,
      regionName: _regionName,
      channelName: _channelName,
      platformName: _environment.platformName,
      installerSource: await _loadInstallerSource(),
    );
  }

  Future<String?> _loadInstallerSource() async {
    if (!_environment.isAndroid) return null;
    try {
      final source = await _platform.getInstallerSource();
      final trimmed = source?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    } on MissingPluginException catch (e, st) {
      _logger.fine('Installer source channel is unavailable', e, st);
      return null;
    } catch (e, st) {
      _logger.warning('Failed to load Android installer source', e, st);
      return null;
    }
  }

  static Future<AppPackageMetadata> _loadPackageMetadata() async {
    final info = await PackageInfo.fromPlatform();
    return AppPackageMetadata(
      appName: info.appName,
      packageName: info.packageName,
      versionName: info.version,
      buildNumber: int.tryParse(info.buildNumber) ?? 0,
    );
  }

  String get _regionName => switch (AppFlavor.current) {
    AppFlavorType.cn => 'cn',
    AppFlavorType.global => 'global',
  };

  String get _channelName => switch (AppFlavor.channel) {
    AppChannelType.stable => 'stable',
    AppChannelType.early => 'early',
    AppChannelType.dev => 'dev',
  };
}
