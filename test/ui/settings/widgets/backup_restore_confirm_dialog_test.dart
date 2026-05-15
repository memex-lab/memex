import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/backup_service.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/settings/widgets/backup_restore_confirm_dialog.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  testWidgets('renders manifest metadata and confirms restore', (tester) async {
    bool? result;
    await _pumpDialogLauncher(
      tester,
      info: _manifestBackupInfo(sizeBytes: 1536),
      onResult: (value) => result = value,
    );

    await tester.tap(find.text('open dialog'));
    await tester.pumpAndSettle();

    expect(find.text(UserStorage.l10n.confirmRestore), findsOneWidget);
    expect(find.text(UserStorage.l10n.confirmRestoreMessage), findsOneWidget);
    expect(find.text(UserStorage.l10n.backupImportCreatedAt), findsOneWidget);
    expect(
      find.text(UserStorage.l10n.backupImportSourceVersion),
      findsOneWidget,
    );
    expect(find.text('1.0.30+113'), findsOneWidget);
    expect(find.text(UserStorage.l10n.backupImportFlavor), findsOneWidget);
    expect(find.text('globalEarly'), findsOneWidget);
    expect(find.text('1.5 KB'), findsOneWidget);

    await tester.tap(find.text(UserStorage.l10n.confirm));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('renders legacy backup details and cancels restore', (
    tester,
  ) async {
    bool? result;
    await _pumpDialogLauncher(
      tester,
      info: const BackupFileInfo(
        path: '/tmp/legacy.memex',
        sizeBytes: 1024 * 1024,
        manifest: null,
      ),
      onResult: (value) => result = value,
    );

    await tester.tap(find.text('open dialog'));
    await tester.pumpAndSettle();

    expect(find.text(UserStorage.l10n.backupLegacyFormat), findsOneWidget);
    expect(find.text('1.0 MB'), findsOneWidget);
    expect(find.text(UserStorage.l10n.backupImportFlavor), findsNothing);

    await tester.tap(find.text(UserStorage.l10n.cancel));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('keeps long metadata readable in a scrollable dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpDialogLauncher(
      tester,
      info: _manifestBackupInfo(
        sizeBytes: 5 * 1024 * 1024,
        flavor: 'globalEarly-channel-with-a-very-long-internal-build-label',
      ),
    );

    await tester.tap(find.text('open dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      find.text('globalEarly-channel-with-a-very-long-internal-build-label'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('formats byte and gigabyte sizes', (tester) async {
    await _pumpDialogLauncher(
      tester,
      info: _manifestBackupInfo(sizeBytes: 900),
    );

    await tester.tap(find.text('open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('900 B'), findsOneWidget);

    await tester.tap(find.text(UserStorage.l10n.cancel));
    await tester.pumpAndSettle();

    await _pumpDialogLauncher(
      tester,
      info: _manifestBackupInfo(sizeBytes: 2 * 1024 * 1024 * 1024),
    );

    await tester.tap(find.text('open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('2.0 GB'), findsOneWidget);
  });
}

Future<void> _pumpDialogLauncher(
  WidgetTester tester, {
  required BackupFileInfo info,
  ValueChanged<bool?>? onResult,
}) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) => BackupRestoreConfirmDialog(backupInfo: info),
                );
                onResult?.call(result);
              },
              child: const Text('open dialog'),
            );
          },
        ),
      ),
    ),
  );
}

BackupFileInfo _manifestBackupInfo({
  int sizeBytes = 1024,
  String flavor = 'globalEarly',
}) {
  return BackupFileInfo(
    path: '/tmp/backup.memex',
    sizeBytes: sizeBytes,
    manifest: BackupManifest(
      format: 'memex.backup',
      backupSchemaVersion: BackupService.currentBackupSchemaVersion,
      createdAt: DateTime.utc(2026, 5, 15, 2, 30),
      appVersion: '1.0.30',
      buildNumber: '113',
      flavor: flavor,
      platform: 'android',
    ),
  );
}
