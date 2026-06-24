import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_base_screen.dart';
import 'package:memex/utils/user_storage.dart';

void main() {
  setUpAll(() async {
    await UserStorage.initL10n();
  });

  test('root listing helpers keep non-PARA folders and root files', () {
    final folders = additionalRootFoldersFromListing({
      'items': [
        {
          'name': 'Projects',
          'path': 'Projects',
          'is_directory': true,
        },
        {
          'name': 'Projects (Projekte)',
          'path': 'Projects (Projekte)',
          'is_directory': true,
        },
        {
          'name': 'Inbox',
          'path': 'Inbox',
          'is_directory': true,
        },
        {
          'name': 'Loose note.md',
          'path': 'Loose note.md',
          'is_directory': false,
        },
      ],
    });

    expect(
      folders.map((folder) => folder['path']),
      ['Inbox', 'Projects (Projekte)'],
    );

    final files = rootFilesFromListing({
      'items': [
        {
          'name': 'Projects',
          'path': 'Projects',
          'is_directory': true,
        },
        {
          'name': 'Loose note.md',
          'path': 'Loose note.md',
          'is_directory': false,
        },
      ],
    });

    expect(
      files.map((file) => file['path']),
      ['Loose note.md'],
    );
  });

  testWidgets(
      'renders additional root folders and files below fixed PARA cards',
      (tester) async {
    final viewModel = KnowledgeBaseViewModel(router: MemexRouter())
      ..categoryCounts = {
        'Projects': 0,
        'Areas': 0,
        'Resources': 0,
        'Archives': 0,
        'Projects (Projekte)': 2,
      }
      ..additionalRootFolders = [
        {
          'name': 'Projects (Projekte)',
          'path': 'Projects (Projekte)',
          'is_directory': true,
          'item_count': 2,
        },
      ]
      ..rootLevelFiles = [
        {
          'name': 'Loose note.md',
          'path': 'Loose note.md',
          'is_directory': false,
          'is_ai_generated': false,
        },
      ];

    await tester.pumpWidget(
      MaterialApp(
        home: KnowledgeBaseScreen(viewModel: viewModel),
      ),
    );

    expect(find.text('PROJECTS'), findsOneWidget);
    expect(find.text('Projects (Projekte)'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget);
    expect(find.text('Loose note.md'), findsOneWidget);
  });
}
