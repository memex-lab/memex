import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/library_document.dart';

void main() {
  test(
      'ranks pinned and actionable documents, hides dismissed paths and caps at three',
      () {
    final list = [
      for (final name in ['one', 'two', 'three', 'four', 'five'])
        LibraryDocument.fromMarkdown(
            'Resources/Home/$name.md', 'A factual note #kitchen', 4),
      LibraryDocument.fromMarkdown('Projects/plan.md',
          '# Plan\n- [ ] Doors\n- [x] Windows\n<!-- fact_id: id -->', 1)
    ];
    final result =
        LibraryDocument.highlights(list, [list[2].path], [list.first.path]);
    expect(result, hasLength(3));
    expect(result.first, list[2]);
    expect(result[1], list.last);
    expect(result, isNot(contains(list.first)));
    expect(list[2].topics, {'Home', 'kitchen'});
    expect(list.last.sources, {'id'});
    expect(list.last.openTasks, 1);
  });

  test(
      'ranks real folders by visits, distinct source records, file count and recency',
      () {
    LibraryDocument doc(String path, {int time = 1, String source = ''}) =>
        LibraryDocument.fromMarkdown(path, '# Title\n$source', time);
    final docs = [
      doc('Areas/Life/Family/a.md', source: '<!-- fact_id: a -->'),
      doc('Areas/Life/b.md', source: '<!-- fact_id: a -->'),
      doc('Projects/Trip/main.md',
          source: '<!-- fact_id: b --><!-- fact_id: c -->'),
      doc('My notes/one.md'),
      doc('Archives/Life/x.md', time: 2),
      doc('Resources/Z/y.md'),
      doc('Areas/loose.md'),
      doc('loose.md'),
    ];
    final recent = LibraryFolder.frequent(docs, [
      'My notes/one.md',
      'My notes/',
      'Areas/Life/Family/',
      'Resources/Z/gone.md'
    ]);
    expect(recent.map((f) => f.path),
        ['My notes', 'Areas/Life', 'Projects/Trip', 'Archives/Life']);
    expect(recent[1].documentCount, 2);
    expect(
        LibraryFolder.frequent(docs.reversed.toList(), []).map((f) => f.path),
        ['Projects/Trip', 'Areas/Life', 'Archives/Life', 'My notes']);
  });
}
