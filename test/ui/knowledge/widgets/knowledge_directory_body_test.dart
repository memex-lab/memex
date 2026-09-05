import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_directory_page.dart';

void main() {
  testWidgets('directory rows are built through ListView.builder',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 200,
          child: KnowledgeDirectoryBody(
            folders: [
              for (var i = 0; i < 20; i++) {'name': 'Folder $i', 'path': '$i'},
            ],
            files: const [],
            folderBuilder: (item) => SizedBox(
              height: 80,
              child: Text(item['name'] as String),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Folder 0'), findsOneWidget);
    expect(find.text('Folder 19'), findsNothing);
  });
}
