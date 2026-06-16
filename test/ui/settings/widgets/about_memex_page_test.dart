import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/app_update_router.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:memex/domain/models/app_build_info.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/settings/view_models/about_memex_viewmodel.dart';
import 'package:memex/ui/settings/widgets/about_memex_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? clipboardText;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        clipboardText = args['text'] as String?;
        return null;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('loads and renders app build information', (tester) async {
    final viewModel = FakeAboutMemexViewModel();

    await pumpAboutPage(tester, viewModel);

    expect(viewModel.loadCalled, isTrue);
    expect(find.text(UserStorage.l10n.aboutMemexTitle), findsOneWidget);
    expect(find.text('1.0.34'), findsWidgets);
    expect(find.text('117'), findsOneWidget);
    expect(find.text('globalEarly'), findsOneWidget);
    expect(find.text('Direct install'), findsOneWidget);
  });

  testWidgets('manual update check shows failure status', (tester) async {
    final viewModel = FakeAboutMemexViewModel();
    await pumpAboutPage(tester, viewModel);

    final checkButton = find.widgetWithText(
      OutlinedButton,
      UserStorage.l10n.appUpdateCheckNow,
    );
    await tester.ensureVisible(checkButton);
    await tester.pumpAndSettle();
    await tester.tap(checkButton);
    await tester.pump();

    expect(viewModel.checkNowCalled, isTrue);
    expect(
      find.text(UserStorage.l10n.appUpdateCheckFailed('network down')),
      findsOneWidget,
    );
  });

  testWidgets('copies safe diagnostics to clipboard', (tester) async {
    final viewModel = FakeAboutMemexViewModel();
    await pumpAboutPage(tester, viewModel);

    final copyButton = find.widgetWithText(
      OutlinedButton,
      UserStorage.l10n.appUpdateCopyDiagnostics,
    );
    await tester.ensureVisible(copyButton);
    await tester.pumpAndSettle();
    await tester.tap(copyButton);
    await tester.pump();

    expect(viewModel.copyDiagnosticsCalled, isTrue);
    expect(
      find.text(UserStorage.l10n.appUpdateDiagnosticsCopied),
      findsOneWidget,
    );
    expect(clipboardText, contains('packageName=com.memexlab.memex.early'));
    expect(
      clipboardText,
      contains('installerSource=com.android.packageinstaller'),
    );
    expect(clipboardText, isNot(contains('userId')));
  });
}

Future<void> pumpAboutPage(
  WidgetTester tester,
  FakeAboutMemexViewModel viewModel,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AboutMemexPage(viewModel: viewModel),
    ),
  );
  await tester.pumpAndSettle();
}

class FakeAboutMemexViewModel extends ChangeNotifier
    implements AboutMemexViewModelContract {
  bool loadCalled = false;
  bool checkNowCalled = false;
  bool copyDiagnosticsCalled = false;

  @override
  AppBuildInfo? buildInfo = const AppBuildInfo(
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

  @override
  AppUpdateSettings? settings = const AppUpdateSettings();

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

  @override
  Future<void> load() async {
    loadCalled = true;
  }

  @override
  Future<void> checkNow() async {
    checkNowCalled = true;
    statusText = UserStorage.l10n.appUpdateCheckFailed('network down');
    notifyListeners();
  }

  @override
  Future<void> copyDiagnostics() async {
    copyDiagnosticsCalled = true;
    await Clipboard.setData(ClipboardData(text: buildInfo!.diagnostics()));
    statusText = UserStorage.l10n.appUpdateDiagnosticsCopied;
    notifyListeners();
  }

  @override
  Future<void> clearUpdateCache() async {}

  @override
  Future<void> performUpdateAction() async {}

  @override
  Future<void> updateAutoCheckEnabled(bool value) async {
    settings = settings!.copyWith(autoCheckEnabled: value);
    notifyListeners();
  }

  @override
  Future<void> updateAutoDownloadAndInstall(bool value) async {
    settings = settings!.copyWith(autoDownloadAndInstall: value);
    notifyListeners();
  }

  @override
  Future<void> updateWifiOnlyDownloads(bool value) async {
    settings = settings!.copyWith(wifiOnlyDownloads: value);
    notifyListeners();
  }
}
