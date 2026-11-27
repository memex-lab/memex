import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/library_document.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_base_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_folder_grid.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_directory_page.dart';

import '../../helpers/bundled_test_fonts.dart';

void main() {
  setUpAll(loadBundledTestFonts);
  setUpAll(UserStorage.initL10n);
  testWidgets('empty library keeps the four default folder cards',
      (tester) async {
    final vm = KnowledgeBaseViewModel(router: MemexRouter());
    addTearDown(vm.dispose);
    await tester
        .pumpWidget(MaterialApp(home: KnowledgeBaseScreen(viewModel: vm)));
    for (final label in ['PROJECTS', 'AREAS', 'RESOURCES', 'ARCHIVES']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('a populated shortcut opens its real nested directory',
      (tester) async {
    final vm = KnowledgeBaseViewModel(router: MemexRouter())
      ..documents = [
        LibraryDocument.fromMarkdown('Areas/Family/Trip/day.md', '# Day one', 1)
      ];
    addTearDown(vm.dispose);
    await tester
        .pumpWidget(MaterialApp(home: KnowledgeBaseScreen(viewModel: vm)));
    final grid = find.byType(KnowledgeFolderGrid);
    final folder = find.descendant(of: grid, matching: find.text('Family'));
    expect(find.descendant(of: grid, matching: find.text('Day one')),
        findsOneWidget);
    expect(find.text('ARCHIVES'), findsOneWidget);
    await tester.tap(folder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(
        tester
            .widget<KnowledgeDirectoryPage>(find.byType(KnowledgeDirectoryPage))
            .path,
        'Areas/Family');
  });

  testWidgets('shows document progress, opens topic and offers home controls',
      (tester) async {
    final vm = KnowledgeBaseViewModel(router: MemexRouter())
      ..documents = [
        LibraryDocument.fromMarkdown('Projects/Home/plan.md',
            '# Renovation\n- [x] Doors\n- [ ] Lights', 1)
      ];
    addTearDown(vm.dispose);
    await tester
        .pumpWidget(MaterialApp(home: KnowledgeBaseScreen(viewModel: vm)));
    expect(find.text('PROJECTS'), findsNothing);
    await tester.scrollUntilVisible(find.text('1/2 complete'), 250,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('1/2 complete'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Original documents'), 150,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Original documents'), findsOneWidget);
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Renovation'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Pin to home'), findsOneWidget);
    expect(find.text('Hide from home'), findsOneWidget);
  });
}
