import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/backup_service.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/settings/widgets/backup_restore_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
    await UserStorage.saveUser('backup-test-user');
  });

  testWidgets('renders automatic backup settings and persists toggle', (
    tester,
  ) async {
    await _pumpBackupPage(tester);

    expect(find.text(UserStorage.l10n.automaticBackup), findsOneWidget);
    expect(find.text(UserStorage.l10n.createSnapshotNow), findsOneWidget);
    expect(await UserStorage.isAutoBackupEnabled('backup-test-user'), isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(await UserStorage.isAutoBackupEnabled('backup-test-user'), isTrue);
  });

  testWidgets(
    'shows stored automatic and safety snapshots with restore confirmation',
    (tester) async {
      const autoName = 'memex_auto_2026-05-15T10-00-00.memex';
      const safetyName =
          'memex_safety_before_restore_2026-05-15T10-05-00.memex';
      final autoSnapshot = BackupSnapshot(
        id: 'auto',
        name: autoName,
        createdAt: DateTime(2026, 5, 15, 10),
        sizeBytes: 3,
        filePath: '/tmp/$autoName',
      );
      final safetySnapshot = BackupSnapshot(
        id: 'safety',
        name: safetyName,
        createdAt: DateTime(2026, 5, 15, 10, 5),
        sizeBytes: 3,
        filePath: '/tmp/$safetyName',
      );

      await _pumpBackupPage(
        tester,
        listStoredBackups: () async => [safetySnapshot, autoSnapshot],
      );
      await _scrollUntilVisible(tester, find.text(autoName));

      expect(find.text(autoName), findsOneWidget);
      expect(find.text(safetyName), findsOneWidget);
      expect(find.byTooltip(UserStorage.l10n.restoreThisBackup), findsWidgets);

      await tester.ensureVisible(find.text(autoName));
      await tester.pump();
      await tester.tap(
        find.byTooltip(UserStorage.l10n.restoreThisBackup).first,
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(UserStorage.l10n.confirmRestore), findsOneWidget);
      expect(find.text(UserStorage.l10n.confirmRestoreMessage), findsOneWidget);
    },
  );

  testWidgets('manual snapshot button refreshes list and status', (
    tester,
  ) async {
    final snapshots = <BackupSnapshot>[];
    final snapshot = BackupSnapshot(
      id: 'manual',
      name: 'memex_auto_2026-05-15T11-00-00.memex',
      createdAt: DateTime(2026, 5, 15, 11),
      sizeBytes: 8,
      filePath: '/tmp/memex_auto_2026-05-15T11-00-00.memex',
    );

    await _pumpBackupPage(
      tester,
      listStoredBackups: () async => List<BackupSnapshot>.of(snapshots),
      createAutoBackup: ({
        String trigger = 'automatic',
        bool force = false,
        void Function(String status)? onProgress,
      }) async {
        expect(trigger, 'manual');
        expect(force, isTrue);
        onProgress?.call('Compressing...');
        snapshots.add(snapshot);
        return snapshot;
      },
    );

    await tester.tap(find.text(UserStorage.l10n.createSnapshotNow));
    await _scrollUntilVisible(tester, find.text(snapshot.name));

    expect(find.text(snapshot.name), findsOneWidget);
    await _scrollUntilVisible(
      tester,
      find.text(UserStorage.l10n.autoBackupCreated(snapshot.name)),
    );
    expect(
      find.text(UserStorage.l10n.autoBackupCreated(snapshot.name)),
      findsOneWidget,
    );
  });

  testWidgets('shows Android backup location picker menu', (tester) async {
    await _pumpBackupPage(tester, isAndroid: true);

    final locationButton = find.widgetWithText(
      OutlinedButton,
      UserStorage.l10n.backupLocationMenu,
    );
    expect(locationButton, findsOneWidget);

    await tester.tap(locationButton);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(UserStorage.l10n.defaultBackupLocation), findsOneWidget);
    expect(find.text(UserStorage.l10n.chooseBackupLocation), findsOneWidget);
  });
}

Future<void> _pumpBackupPage(
  WidgetTester tester, {
  bool isAndroid = false,
  Future<List<BackupSnapshot>> Function()? listStoredBackups,
  AutoBackupCreator? createAutoBackup,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BackupRestorePage(
        isAndroidOverride: isAndroid,
        estimateBackupSize: () async => 0,
        currentBackupLocationLabel: () async => '/tmp/Backups',
        listStoredBackups: listStoredBackups ?? () async => const [],
        createAutoBackup: createAutoBackup,
      ),
    ),
  );
  await tester.pump();
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pump();
}

Future<void> _scrollUntilVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump(const Duration(milliseconds: 100));
}
