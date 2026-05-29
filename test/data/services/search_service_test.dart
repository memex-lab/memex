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
          'comments': <dynamic>[],
        },
        after: {
          'fact_id': '2026/05/29.md#ts_1',
          'title': 'Title',
          'tags': ['tag'],
          'comments': [
            {'id': 'c1', 'content': 'new comment'},
          ],
          'content': 'raw fact content',
          'asset_analyses': <String>[],
          'asset_ocr': <String>[],
        },
      );

      expect(
        SearchService.instance.shouldEnqueueFtsIndexUpdateForTesting(record),
        isFalse,
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
}
