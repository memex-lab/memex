import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/search_service.dart';
import 'package:memex/domain/models/system_event.dart';

void main() {
  group('SearchService FTS enqueue filtering', () {
    test('skips card updates when only comments change', () {
      final record = DataChangeRecord(
        op: DataChangeOp.update,
        ns: DataChangeNs.card,
        documentKey: '2026/05/29.md#ts_1',
        before: {
          'fact_id': '2026/05/29.md#ts_1',
          'title': 'Title',
          'tags': ['tag'],
          'fact': 'raw fact content',
          'comments': <dynamic>[],
        },
        after: {
          'fact_id': '2026/05/29.md#ts_1',
          'title': 'Title',
          'tags': ['tag'],
          'comments': [
            {'id': 'c1', 'content': 'new comment'},
          ],
          'fact': 'raw fact content',
        },
      );

      expect(
        SearchService.instance.shouldEnqueueFtsIndexUpdateForTesting(record),
        isFalse,
      );
    });

    test('enqueues card updates when fact changes', () {
      final record = DataChangeRecord(
        op: DataChangeOp.update,
        ns: DataChangeNs.card,
        documentKey: '2026/05/29.md#ts_1',
        before: {
          'title': 'Title',
          'tags': ['tag'],
          'fact': 'before fact',
        },
        after: {
          'title': 'Title',
          'tags': ['tag'],
          'fact': 'after fact',
        },
      );

      expect(
        SearchService.instance.shouldEnqueueFtsIndexUpdateForTesting(record),
        isTrue,
      );
    });

    test('enqueues card updates when indexed fields change', () {
      final record = DataChangeRecord(
        op: DataChangeOp.update,
        ns: DataChangeNs.card,
        documentKey: '2026/05/29.md#ts_1',
        before: {
          'title': 'Before',
          'tags': ['tag'],
        },
        after: {
          'title': 'After',
          'tags': ['tag'],
        },
      );

      expect(
        SearchService.instance.shouldEnqueueFtsIndexUpdateForTesting(record),
        isTrue,
      );
    });
  });

  group('FTS rebuild yielding', () {
    test('yields every eight indexed documents', () {
      expect(SearchService.instance.shouldYieldFtsRebuild(0), isFalse);
      expect(SearchService.instance.shouldYieldFtsRebuild(7), isFalse);
      expect(SearchService.instance.shouldYieldFtsRebuild(8), isTrue);
      expect(SearchService.instance.shouldYieldFtsRebuild(16), isTrue);
    });
  });
}
