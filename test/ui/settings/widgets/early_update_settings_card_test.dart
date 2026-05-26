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

  testWidgets('shows active background download and disables manual actions', (
    tester,
  ) async {
    final service = FakeWidgetUpdateService(
      update: testUpdate,
      cacheInfo: const AppUpdateCacheInfo(fileCount: 1, totalBytes: 2),
      activeDownload: true,
      activeProgress: const AppUpdateDownloadProgress(
        receivedBytes: 2,
        totalBytes: 4,
      ),
    );
    await pumpCard(tester, service);

    await tester.tap(find.text(UserStorage.l10n.earlyUpdateCheckNow));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text(UserStorage.l10n.earlyUpdateDownloadingPercent(50)),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.earlyUpdateDownloadInProgress),
      findsOneWidget,
    );

    final downloadButton = tester.widget<FilledButton>(
      find.widgetWithText(
        FilledButton,
        UserStorage.l10n.earlyUpdateDownloadInProgress,
      ),
    );
    expect(downloadButton.onPressed, isNull);

    final clearButton = tester.widget<OutlinedButton>(
      find.widgetWithText(
        OutlinedButton,
        UserStorage.l10n.earlyUpdateClearDownloadedPackage,
      ),
    );
    expect(clearButton.onPressed, isNull);
    expect(service.downloadCallCount, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('background download becomes installable after polling', (
    tester,
  ) async {
    final service = FakeWidgetUpdateService(
      update: testUpdate,
      activeDownload: true,
      activeProgress: const AppUpdateDownloadProgress(
        receivedBytes: 1,
        totalBytes: 4,
      ),
    );
    await pumpCard(tester, service);

    await tester.tap(find.text(UserStorage.l10n.earlyUpdateCheckNow));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text(UserStorage.l10n.earlyUpdateDownloadingPercent(25)),
      findsOneWidget,
    );

    service
      ..activeDownload = false
      ..activeProgress = null
      ..downloadedUpdateAvailable = true
      ..cacheInfo = const AppUpdateCacheInfo(fileCount: 1, totalBytes: 4);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(
      find.text(UserStorage.l10n.earlyUpdateDownloadReadyToInstall),
      findsOneWidget,
    );
    expect(
      find.text(UserStorage.l10n.earlyUpdateInstallDownloadedPackage),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
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
    this.activeDownload = false,
    this.activeProgress,
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
  bool activeDownload;
  AppUpdateDownloadProgress? activeProgress;
  AppUpdateSettings settings = const AppUpdateSettings();
  bool installStarted = false;
  bool cacheCleared = false;
  int downloadCallCount = 0;

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
    downloadCallCount += 1;
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
  bool get hasActiveDownload => activeDownload;

  @override
  bool isDownloadingUpdate(AppUpdateInfo update) {
    return activeDownload;
  }

  @override
  AppUpdateDownloadProgress? getActiveDownloadProgress(AppUpdateInfo update) {
    return activeProgress;
  }

  @override
  Future<AppUpdateCacheInfo> getDownloadedUpdateCacheInfo() async {
    return cacheInfo;
  }

  @override
  Future<int> clearDownloadedUpdates() async {
    if (activeDownload) {
      throw const AppUpdateDownloadInProgressException();
    }
    cacheCleared = true;
    final deletedCount = cacheInfo.fileCount;
    cacheInfo = AppUpdateCacheInfo.empty;
    downloadedUpdateAvailable = false;
    return deletedCount;
  }
}
