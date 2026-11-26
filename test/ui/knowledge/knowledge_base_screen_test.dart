import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/library_document.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_base_screen.dart';
import 'package:memex/utils/user_storage.dart';

import '../../helpers/bundled_test_fonts.dart';

void main() {
  setUpAll(loadBundledTestFonts);
  setUpAll(UserStorage.initL10n);
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
    expect(find.text('1/2 complete'), findsOneWidget);
    expect(find.text('Original documents'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Renovation'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Pin to home'), findsOneWidget);
    expect(find.text('Hide from home'), findsOneWidget);
  });
}
