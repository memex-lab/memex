import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_import_service.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/settings/widgets/data_import_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  testWidgets('processing dialog updates impact text as options change',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ImportProcessingOptionsDialog(result: _result),
        ),
      ),
    );

    expect(find.text(UserStorage.l10n.dataImportImpactNone), findsOneWidget);

    await tester
        .tap(find.text(UserStorage.l10n.dataImportProcessKnowledgeBase));
    await tester.pump();

    expect(
      find.text(UserStorage.l10n.dataImportImpactKnowledgeBase),
      findsOneWidget,
    );

    await tester
        .tap(find.text(UserStorage.l10n.dataImportProcessTimelineCards));
    await tester.pump();

    expect(find.text(UserStorage.l10n.dataImportImpactBoth), findsOneWidget);

    await tester
        .tap(find.text(UserStorage.l10n.dataImportProcessKnowledgeBase));
    await tester.pump();

    expect(
      find.text(UserStorage.l10n.dataImportImpactTimelineCards),
      findsOneWidget,
    );
  });
}

const _result = FileImportResult(
  sourceName: 'my-export',
  pkmRelativeDirectoryPath: 'Resources/Imported/my-export',
  workspaceRelativeDirectoryPath: 'PKM/Resources/Imported/my-export',
  absoluteDirectoryPath: '/tmp/workspace/PKM/Resources/Imported/my-export',
  files: [
    ImportedFileRecord(
      relativePath: 'Resources/Imported/my-export/a.md',
      sizeBytes: 4,
    ),
  ],
  renamedConflictCount: 0,
  skippedUnsafeArchiveEntries: 0,
);
