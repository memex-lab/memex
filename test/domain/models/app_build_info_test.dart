import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/app_build_info.dart';

void main() {
  group('AppBuildInfo', () {
    test('formats version, update channel, and known installer names', () {
      const info = AppBuildInfo(
        appName: 'Memex',
        packageName: 'com.memexlab.memex.early',
        versionName: '1.0.34',
        buildNumber: 117,
        flavorName: 'globalEarly',
        regionName: 'global',
        channelName: 'early',
        platformName: 'android',
        installerSource: 'com.android.vending',
      );

      expect(info.displayVersion, '1.0.34+117');
      expect(info.updateChannelKey, 'android_global_early');
      expect(info.isAndroid, isTrue);
      expect(info.isIOS, isFalse);
      expect(info.isEarly, isTrue);
      expect(info.installerDisplayName, 'Google Play');
      expect(info.isDirectInstall, isFalse);
    });

    test('detects direct installs and trims unknown installer sources', () {
      const info = AppBuildInfo(
        appName: 'Memex',
        packageName: 'com.memexlab.memex.dev',
        versionName: '1.0.34',
        buildNumber: 117,
        flavorName: 'globalDev',
        regionName: 'global',
        channelName: 'dev',
        platformName: 'android',
        installerSource: ' com.android.shell ',
      );

      expect(info.installerDisplayName, 'Direct install');
      expect(info.isDirectInstall, isTrue);
    });

    test('diagnostics contain only safe app and update fields', () {
      const info = AppBuildInfo(
        appName: 'Memex',
        packageName: 'com.memexlab.memex',
        versionName: '1.0.34',
        buildNumber: 117,
        flavorName: 'global',
        regionName: 'global',
        channelName: 'stable',
        platformName: 'android',
        installerSource: null,
      );

      final diagnostics = info.diagnostics(
        updateProvider: 'google_play',
        updateChannel: 'android_global_stable',
        manifestSource: 'https://example.com/manifest.json',
        manifestGeneratedAt: DateTime.utc(2026, 6, 16),
      );

      expect(diagnostics, contains('appName=Memex'));
      expect(diagnostics, contains('installerSource=unknown'));
      expect(diagnostics, contains('installerDisplayName=Unknown'));
      expect(diagnostics, contains('updateProvider=google_play'));
      expect(diagnostics,
          contains('manifestGeneratedAt=2026-06-16T00:00:00.000Z'));
      expect(diagnostics, isNot(contains('userId')));
      expect(diagnostics, isNot(contains('workspace')));
    });
  });
}
