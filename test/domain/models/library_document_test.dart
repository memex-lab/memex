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
}
