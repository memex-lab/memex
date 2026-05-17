import 'dart:convert';
import 'dart:io';

import 'package:memex/agent/insight_agent/knowledge_insight_run_context.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('buildKnowledgeInsightRunContext', () {
    late Directory tempRoot;
    const userId = 'insight_context_user';

    setUp(() async {
      tempRoot =
          await Directory.systemTemp.createTemp('memex_insight_context_');
      await FileSystemService.init(tempRoot.path);
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('summarizes durable sources for fresh insight execution', () async {
      final fileSystem = FileSystemService.instance;
      await _writeFactFile(
        userId: userId,
        date: DateTime(2026, 5, 14),
        entries: const [
          (
            id: 'ts_1',
            time: '09:00:00',
            content: 'Started testing insight refresh.'
          ),
        ],
      );
      await _writeFactFile(
        userId: userId,
        date: DateTime(2026, 5, 16),
        entries: const [
          (
            id: 'ts_1',
            time: '08:15:00',
            content: 'Finished a long project review.'
          ),
          (
            id: 'ts_2',
            time: '21:30:00',
            content: 'Noticed repeated agent tool calls.'
          ),
        ],
      );

      await _writePkmFile(
        userId,
        'Projects/Agent Notes.md',
        '# Agent Notes\n\nUse durable state as source of truth.',
      );

      await fileSystem.writeKnowledgeInsightCard(userId, 'unpinned_card', {
        'id': 'unpinned_card',
        'title': 'Unpinned trend',
        'template_id': 'metric_card',
        'insight': 'This card should be truncated only if it is very long.',
        'pinned': false,
        'sort_order': 1,
        'related_facts': ['2026/05/14.md#ts_1'],
      });
      await fileSystem.writeKnowledgeInsightCard(userId, 'pinned_card', {
        'id': 'pinned_card',
        'title': 'Pinned profile',
        'template_id': 'metric_card',
        'insight': 'Pinned cards should be shown first in the compact index.',
        'pinned': true,
        'sort_order': 99,
        'related_facts': ['2026/05/16.md#ts_2'],
      });

      final context = await buildKnowledgeInsightRunContext(
        userId: userId,
        runId: 'task_123',
        now: DateTime.utc(2026, 5, 16, 12),
        latestFactLimit: 2,
        existingCardLimit: 1,
        recentPkmLimit: 2,
      );

      final payload = _decodeContextPayload(context);
      final sources = payload['durable_sources'] as Map<String, dynamic>;

      expect(payload['run_id'], 'task_123');
      expect(payload['fresh_execution_state'], isTrue);
      expect(sources['facts_total_count'], 3);
      expect(sources['latest_fact_ids_recent_first'], [
        '2026/05/16.md#ts_2',
        '2026/05/16.md#ts_1',
      ]);
      expect(sources['existing_insight_cards_total_count'], 2);
      expect(sources['existing_insight_cards'], [
        containsPair('id', 'pinned_card'),
      ]);
      expect(
        (sources['recent_pkm_files'] as List).single,
        containsPair('path', p.join('Projects', 'Agent Notes.md')),
      );
      expect(
        payload['execution_policy'],
        contains(contains('Do not rely on prior LLM conversation history')),
      );
    });
  });
}

Future<void> _writeFactFile({
  required String userId,
  required DateTime date,
  required List<({String id, String time, String content})> entries,
}) async {
  final fileSystem = FileSystemService.instance;
  final file = File(fileSystem.getDailyFactPath(userId, date));
  await file.parent.create(recursive: true);

  final buffer = StringBuffer();
  for (final entry in entries) {
    buffer.writeln('## <id:${entry.id}> ${entry.time} "{}"');
    buffer.writeln(entry.content);
    buffer.writeln();
  }
  await file.writeAsString(buffer.toString());
}

Future<void> _writePkmFile(
  String userId,
  String relativePath,
  String content,
) async {
  final fileSystem = FileSystemService.instance;
  final file = File(p.join(fileSystem.getPkmPath(userId), relativePath));
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
}

Map<String, dynamic> _decodeContextPayload(String context) {
  const openTag = '<insight_run_context>';
  const closeTag = '</insight_run_context>';
  final start = context.indexOf(openTag);
  final end = context.indexOf(closeTag);
  expect(start, isNot(-1));
  expect(end, greaterThan(start));
  return jsonDecode(
    context.substring(start + openTag.length, end).trim(),
  ) as Map<String, dynamic>;
}
