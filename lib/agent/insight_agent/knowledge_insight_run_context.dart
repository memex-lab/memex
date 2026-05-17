import 'dart:convert';

import 'package:memex/data/services/file_system_service.dart';

const int defaultInsightLatestFactLimit = 80;
const int defaultInsightExistingCardLimit = 80;
const int defaultInsightRecentPkmLimit = 40;

/// Builds a compact, deterministic context packet for a fresh knowledge insight
/// run. The agent still reads source files through tools, but this packet gives
/// it a stable map of where to start after active LLM history has been cleared.
Future<String> buildKnowledgeInsightRunContext({
  required String userId,
  required String runId,
  DateTime? now,
  int latestFactLimit = defaultInsightLatestFactLimit,
  int existingCardLimit = defaultInsightExistingCardLimit,
  int recentPkmLimit = defaultInsightRecentPkmLimit,
}) async {
  final fileSystem = FileSystemService.instance;
  final generatedAt = now ?? DateTime.now();

  final existingCards = await fileSystem.listKnowledgeInsightCards(userId);
  final allFactIds = await fileSystem.listAllFacts(userId);
  final recentPkmFiles = await fileSystem.getRecentPkmFiles(
    userId,
    limit: recentPkmLimit,
  );

  final latestFactIds = allFactIds.reversed.take(latestFactLimit).toList();
  final compactCards = _compactInsightCards(existingCards, existingCardLimit);
  final compactPkmFiles = recentPkmFiles.map(_compactPkmFile).toList();

  final payload = {
    'run_id': runId,
    'generated_at': generatedAt.toIso8601String(),
    'fresh_execution_state': true,
    'durable_sources': {
      'facts_total_count': allFactIds.length,
      'latest_fact_ids_recent_first': latestFactIds,
      'latest_fact_ids_limit': latestFactLimit,
      'existing_insight_cards_total_count': existingCards.length,
      'existing_insight_cards': compactCards,
      'existing_insight_cards_limit': existingCardLimit,
      'recent_pkm_files': compactPkmFiles,
      'recent_pkm_files_limit': recentPkmLimit,
    },
    'execution_policy': [
      'This is a fresh knowledge-insight execution. Do not rely on prior LLM conversation history.',
      'Use durable workspace data as the source of truth: Facts, Cards, PKM, KnowledgeInsights, and injected user memory context.',
      'Start from latest_fact_ids_recent_first for incremental refresh, then broaden to /Facts and /PKM when the evidence is sparse or a global profile card needs updating.',
      'Always call get_exists_knowledge_insight_cards before saving updates so pinned cards and existing IDs are respected.',
      'Use Read, BatchRead, Grep, Glob, and LS to inspect source evidence before creating or updating cards.',
      'Every added card must include related_facts that point to concrete fact IDs from durable data.',
    ],
  };

  return '<insight_run_context>\n'
      '${const JsonEncoder.withIndent('  ').convert(payload)}\n'
      '</insight_run_context>';
}

List<Map<String, dynamic>> _compactInsightCards(
  List<Map<String, dynamic>> cards,
  int limit,
) {
  final sorted = List<Map<String, dynamic>>.from(cards);
  sorted.sort((a, b) {
    final pinnedCompare = _boolValue(
      b['pinned'],
    ).compareTo(_boolValue(a['pinned']));
    if (pinnedCompare != 0) return pinnedCompare;
    final sortA = _numValue(a['sort_order']);
    final sortB = _numValue(b['sort_order']);
    final sortCompare = sortA.compareTo(sortB);
    if (sortCompare != 0) return sortCompare;
    return _stringValue(a['id']).compareTo(_stringValue(b['id']));
  });

  return sorted.take(limit).map((card) {
    final compact = <String, dynamic>{
      if (card['id'] != null) 'id': card['id'],
      if (card['title'] != null) 'title': card['title'],
      if (card['template_id'] != null) 'template_id': card['template_id'],
      if (card['pinned'] != null) 'pinned': card['pinned'],
      if (card['sort_order'] != null) 'sort_order': card['sort_order'],
      if (card['updated_at'] != null) 'updated_at': card['updated_at'],
      if (card['tags'] != null) 'tags': card['tags'],
      if (card['related_facts'] != null)
        'related_facts': _compactList(card['related_facts']),
    };
    final insight = _stringValue(card['insight']);
    if (insight.isNotEmpty) {
      compact['insight'] = _truncate(insight, 320);
    }
    return compact;
  }).toList();
}

Map<String, dynamic> _compactPkmFile(Map<String, dynamic> file) {
  return {
    if (file['path'] != null) 'path': file['path'],
    if (file['name'] != null) 'name': file['name'],
    if (file['modified'] != null) 'modified': file['modified'],
    if (file['size'] != null) 'size': file['size'],
  };
}

List<dynamic> _compactList(dynamic value, {int limit = 12}) {
  if (value is! List) return const [];
  return value.take(limit).toList();
}

int _boolValue(dynamic value) => value == true ? 1 : 0;

num _numValue(dynamic value) => value is num ? value : 0;

String _stringValue(dynamic value) => value?.toString() ?? '';

String _truncate(String value, int maxLength) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength)}...';
}
