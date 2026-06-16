class AppBuildInfo {
  const AppBuildInfo({
    required this.appName,
    required this.packageName,
    required this.versionName,
    required this.buildNumber,
    required this.flavorName,
    required this.regionName,
    required this.channelName,
    required this.platformName,
    this.installerSource,
  });

  final String appName;
  final String packageName;
  final String versionName;
  final int buildNumber;
  final String flavorName;
  final String regionName;
  final String channelName;
  final String platformName;
  final String? installerSource;

  String get displayVersion => '$versionName+$buildNumber';

  String get updateChannelKey =>
      [platformName, regionName, channelName].join('_').toLowerCase();

  bool get isAndroid => platformName == 'android';
  bool get isIOS => platformName == 'ios';
  bool get isDev => channelName == 'dev';
  bool get isEarly => channelName == 'early';
  bool get isStable => channelName == 'stable';

  String get installerDisplayName {
    final source = installerSource?.trim();
    if (source == null || source.isEmpty) return 'Unknown';
    return switch (source) {
      'com.android.vending' => 'Google Play',
      'com.huawei.appmarket' => 'Huawei AppGallery',
      'com.tencent.android.qqdownloader' => 'Tencent App Store',
      'com.xiaomi.market' => 'Xiaomi GetApps',
      'com.oppo.market' => 'OPPO App Market',
      'com.bbk.appstore' => 'vivo App Store',
      'com.sec.android.app.samsungapps' => 'Samsung Galaxy Store',
      'com.android.packageinstaller' ||
      'com.google.android.packageinstaller' ||
      'com.android.shell' =>
        'Direct install',
      _ => source,
    };
  }

  bool get isDirectInstall {
    final source = installerSource?.trim();
    if (source == null || source.isEmpty) return false;
    return source == 'com.android.packageinstaller' ||
        source == 'com.google.android.packageinstaller' ||
        source == 'com.android.shell';
  }

  String diagnostics({
    String? updateProvider,
    String? updateChannel,
    String? manifestSource,
    DateTime? manifestGeneratedAt,
  }) {
    final lines = <String>[
      'appName=$appName',
      'packageName=$packageName',
      'version=$displayVersion',
      'platform=$platformName',
      'flavor=$flavorName',
      'region=$regionName',
      'channel=$channelName',
      'installerSource=${installerSource ?? 'unknown'}',
      'installerDisplayName=$installerDisplayName',
      'updateChannel=${updateChannel ?? updateChannelKey}',
      if (updateProvider != null) 'updateProvider=$updateProvider',
      if (manifestSource != null) 'manifestSource=$manifestSource',
      if (manifestGeneratedAt != null)
        'manifestGeneratedAt=${manifestGeneratedAt.toIso8601String()}',
    ];
    return lines.join('\n');
  }
}
