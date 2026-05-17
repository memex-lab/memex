import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/settings/widgets/early_update_settings_card.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  Future<void> pumpCard(WidgetTester tester, AppUpdateService service) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: EarlyUpdateSettingsCard(
              service: service,
              forceVisible: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders defaults and persists Wi-Fi-only toggle', (
    tester,
  ) async {
    final service = FakeWidgetUpdateService();
    await pumpCard(tester, service);

    expect(
      find.text(UserStorage.l10n.earlyUpdateSettingsTitle),
      findsOneWidget,
    );
    expect(find.byType(Switch), findsNWidgets(3));

    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();

    final settings = await service.loadSettings();
    expect(settings.wifiOnlyDownloads, isFalse);
  });

  testWidgets('manual check reveals update and download opens installer', (
    tester,
  ) async {
    final service = FakeWidgetUpdateService(update: testUpdate);
    await pumpCard(tester, service);

    await tester.tap(find.text(UserStorage.l10n.earlyUpdateCheckNow));
    await tester.pumpAndSettle();

    expect(
      find.text(UserStorage.l10n.earlyUpdateFound('1.0.30', 113)),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.earlyUpdateDownloadAndInstall),
      findsOneWidget,
    );

    await tester.tap(find.text(UserStorage.l10n.earlyUpdateDownloadAndInstall));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.installStarted, isTrue);
    expect(
      find.text(UserStorage.l10n.earlyUpdateInstallStarted),
      findsOneWidget,
    );
  });

  testWidgets('can install cached update package and clear cache', (
    tester,
  ) async {
    final service = FakeWidgetUpdateService(
      update: testUpdate,
      cacheInfo: const AppUpdateCacheInfo(fileCount: 1, totalBytes: 4),
      downloadedUpdateAvailable: true,
    );
    await pumpCard(tester, service);

    await tester.tap(find.text(UserStorage.l10n.earlyUpdateCheckNow));
    await tester.pumpAndSettle();

    expect(
      find.text(UserStorage.l10n.earlyUpdateInstallDownloadedPackage),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.earlyUpdateClearDownloadedPackage),
      findsOneWidget,
    );

    await tester.tap(
      find.text(UserStorage.l10n.earlyUpdateClearDownloadedPackage),
    );
    await tester.pumpAndSettle();

    expect(service.cacheCleared, isTrue);
    expect(
      find.text(UserStorage.l10n.earlyUpdateClearDownloadedPackageSuccess),
      findsWidgets,
    );
    expect(
      find.text(UserStorage.l10n.earlyUpdateClearDownloadedPackage),
      findsNothing,
    );
  });
}

const testUpdate = AppUpdateInfo(
  releaseName: 'Memex Early',
  tagName: 'v1.0.30+113',
  versionName: '1.0.30',
  buildNumber: 113,
  assetName: 'memex_globalEarly_1.0.30_113.apk',
  sizeBytes: 4,
  downloadUrl: 'https://example.com/global.apk',
  releaseNotes: 'Release notes',
);

class FakeWidgetUpdateService extends AppUpdateService {
  FakeWidgetUpdateService({
    this.update,
    AppUpdateCacheInfo? cacheInfo,
    this.downloadedUpdateAvailable = false,
  }) : cacheInfo = cacheInfo ?? AppUpdateCacheInfo.empty,
       super(
         environment: const AppUpdateEnvironment(
           isAndroid: true,
           isEarlyChannel: true,
           flavorName: 'globalEarly',
         ),
       );

  final AppUpdateInfo? update;
  AppUpdateCacheInfo cacheInfo;
  bool downloadedUpdateAvailable;
  AppUpdateSettings settings = const AppUpdateSettings();
  bool installStarted = false;
  bool cacheCleared = false;

  @override
  bool get isSupported => true;

  @override
  Future<AppUpdateSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(AppUpdateSettings settings) async {
    this.settings = settings;
  }

  @override
  Future<AppUpdateCheckResult> checkForUpdate({
    bool manual = false,
    bool respectWifi = true,
  }) async {
    settings = settings.copyWith(lastCheckAt: DateTime(2026, 5, 15, 10));
    final found = update;
    return found == null
        ? const AppUpdateCheckResult.noUpdate()
        : AppUpdateCheckResult.updateAvailable(found);
  }

  @override
  Future<AppUpdateDownloadResult> downloadUpdate(
    AppUpdateInfo update, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    onProgress?.call(4, 4);
    cacheInfo = const AppUpdateCacheInfo(fileCount: 1, totalBytes: 4);
    downloadedUpdateAvailable = true;
    return AppUpdateDownloadResult(update: update, apkPath: '/tmp/memex.apk');
  }

  @override
  Future<AppUpdateInstallResult> installUpdate(String apkPath) async {
    installStarted = true;
    return const AppUpdateInstallResult(AppUpdateInstallStatus.started);
  }

  @override
  Future<bool> hasDownloadedUpdate(AppUpdateInfo update) async {
    return downloadedUpdateAvailable;
  }

  @override
  Future<AppUpdateCacheInfo> getDownloadedUpdateCacheInfo() async {
    return cacheInfo;
  }

  @override
  Future<int> clearDownloadedUpdates() async {
    cacheCleared = true;
    final deletedCount = cacheInfo.fileCount;
    cacheInfo = AppUpdateCacheInfo.empty;
    downloadedUpdateAvailable = false;
    return deletedCount;
  }
}
