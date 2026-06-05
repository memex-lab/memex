import 'package:dart_agent_core/eval.dart';
import 'package:memex/domain/models/system_event.dart';

abstract class _Keys {
  static const authorError = 'author_error';
  static const pageAgentError = 'page_agent_error';
  static const renderError = 'render_error';
  static const surfaceExists = 'surface_exists';
  static const manifest = 'manifest';
  static const html = 'html';
  static const data = 'data';
  static const renderedHtml = 'rendered_html';
  static const pageAgentCount = 'page_agent_count';
  static const pageAgent = 'page_agent';
  static const manifestBeforePageAgent = 'manifest_before_page_agent';
  static const manifestAfterPageAgent = 'manifest_after_page_agent';
  static const htmlBeforePageAgent = 'html_before_page_agent';
  static const htmlAfterPageAgent = 'html_after_page_agent';
  static const sourceBeforePageAgent = 'source_before_page_agent';
  static const sourceAfterPageAgent = 'source_after_page_agent';
  static const dataAfterPageAgent = 'data_after_page_agent';
  static const renderedHtmlAfterPageAgent = 'rendered_html_after_page_agent';
}

bool _hasMeaningfulData(Object? value) {
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  if (value is Iterable) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  if (value is num || value is bool) return true;
  return true;
}

String _describeData(Object? value) {
  if (value == null) return 'null';
  if (value is String) return 'string(${value.length})';
  if (value is Iterable) return 'array(${value.length})';
  if (value is Map) return 'object(${value.length})';
  if (value is num) return 'number';
  if (value is bool) return 'boolean';
  return value.runtimeType.toString();
}

class DynamicSurfaceInstallGrader extends CodeGrader {
  final String? expectedSourcePath;

  DynamicSurfaceInstallGrader({
    this.expectedSourcePath,
  });

  @override
  String get name => 'dynamic_surface_install';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final s = outcome.environmentState;
    final data = s[_Keys.data];
    final manifest = (s[_Keys.manifest] as Map?)?.cast<String, dynamic>();
    final html = s[_Keys.html] as String? ?? '';
    final source = (manifest?['source'] as Map?)?.cast<String, dynamic>();
    final sourcePath = source?['path'] as String?;
    final parser = (manifest?['parser'] as Map?)?.cast<String, dynamic>();
    final render = (manifest?['render'] as Map?)?.cast<String, dynamic>();
    final authorError = s[_Keys.authorError] as String?;
    final renderError = s[_Keys.renderError] as String?;

    return [
      Assertion(
        description: 'author agent completed without exception',
        passed: authorError == null,
        actual: authorError ?? '<none>',
        expected: '<none>',
      ),
      Assertion(
        description: 'surface package exists',
        passed: s[_Keys.surfaceExists] == true,
        actual: 'surface_exists=${s[_Keys.surfaceExists]}',
        expected: 'surface_exists=true',
      ),
      Assertion(
        description: 'manifest uses a JavaScript parser contract',
        passed: parser?['type'] == 'javascript' &&
            parser?['script_path'] == 'parser.js' &&
            parser?['entry'] == 'parse',
        actual: '$parser',
        expected: 'parser.type=javascript script_path=parser.js entry=parse',
      ),
      Assertion(
        description: 'manifest points at an HTML template file',
        passed: render?['type'] == 'html' && render?['template_path'] != null,
        actual: '$render',
        expected: 'render.type=html with template_path',
      ),
      Assertion(
        description: 'source path is stored as a workspace-relative path',
        passed: sourcePath != null && !sourcePath.startsWith('/'),
        actual: '$source',
        expected: 'relative source.path',
      ),
      Assertion(
        description: 'source path does not point at native read-only sources',
        passed: sourcePath != null && !_isNativeReadOnlySourcePath(sourcePath),
        actual: sourcePath ?? '<null>',
        expected: 'not Facts/PKM/Cards/KnowledgeInsights or under them',
      ),
      if (expectedSourcePath != null)
        Assertion(
          description: 'source path points at the existing relevant data',
          passed: sourcePath == expectedSourcePath ||
              (sourcePath?.contains(expectedSourcePath!) ?? false),
          actual: sourcePath ?? '<null>',
          expected: expectedSourcePath!,
        ),
      Assertion(
        description: 'render succeeds',
        passed: renderError == null,
        actual: renderError ?? '<none>',
        expected: '<none>',
      ),
      Assertion(
        description: 'parser output contains meaningful data',
        passed: _hasMeaningfulData(data),
        actual: _describeData(data),
        expected: 'non-empty parser output',
      ),
      Assertion(
        description: 'HTML was installed through a file-backed template',
        passed: html.trim().isNotEmpty,
        actual: html.trim().isEmpty ? '<empty>' : html.substring(0, 80),
        expected: 'non-empty view.html',
      ),
    ];
  }

  bool _isNativeReadOnlySourcePath(String value) {
    final normalized = value.replaceAll('\\', '/');
    const roots = [
      'Facts',
      'PKM',
      'Cards',
      'KnowledgeInsights',
    ];
    return roots.any(
      (root) => normalized == root || normalized.startsWith('$root/'),
    );
  }
}

class DynamicSurfaceContentGrader extends CodeGrader {
  final List<String> initialSubstrings;
  final List<String> maintainedSubstrings;
  final List<ContentConcept> initialConcepts;
  final List<ContentConcept> maintainedConcepts;

  DynamicSurfaceContentGrader({
    this.initialSubstrings = const [],
    this.maintainedSubstrings = const [],
    this.initialConcepts = const [],
    this.maintainedConcepts = const [],
  });

  @override
  String get name => 'dynamic_surface_content';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final s = outcome.environmentState;
    final initialBlob = [
      s[_Keys.renderedHtml] as String? ?? '',
      '${s[_Keys.data] ?? ''}',
    ].join('\n');
    final maintainedBlob = [
      s[_Keys.renderedHtmlAfterPageAgent] as String? ?? '',
      '${s[_Keys.dataAfterPageAgent] ?? ''}',
      ((s[_Keys.sourceAfterPageAgent] as Map?)?.values ?? const <String>[])
          .join('\n'),
    ].join('\n');

    return [
      for (final needle in initialSubstrings)
        Assertion(
          description: 'initial rendered/data contains "$needle"',
          passed: initialBlob.contains(needle),
          actual: _preview(initialBlob),
          expected: 'contains "$needle"',
        ),
      for (final needle in maintainedSubstrings)
        Assertion(
          description: 'maintained rendered/data contains "$needle"',
          passed: maintainedBlob.contains(needle),
          actual: _preview(maintainedBlob),
          expected: 'contains "$needle"',
        ),
      for (final concept in initialConcepts)
        _conceptAssertion(
          phase: 'initial',
          blob: initialBlob,
          concept: concept,
        ),
      for (final concept in maintainedConcepts)
        _conceptAssertion(
          phase: 'maintained',
          blob: maintainedBlob,
          concept: concept,
        ),
    ];
  }

  Assertion _conceptAssertion({
    required String phase,
    required String blob,
    required ContentConcept concept,
  }) {
    String? matched;
    for (final needle in concept.anyOf) {
      if (blob.contains(needle)) {
        matched = needle;
        break;
      }
    }
    return Assertion(
      description: '$phase rendered/data preserves "${concept.name}"',
      passed: matched != null,
      actual:
          'matched=${matched ?? '<none>'} any_of=${concept.anyOf} preview=${_preview(blob)}',
      expected: 'contains any accepted expression for "${concept.name}"',
    );
  }

  String _preview(String value) {
    if (value.length <= 240) return value;
    return value.substring(0, 240);
  }
}

class ContentConcept {
  final String name;
  final List<String> anyOf;

  const ContentConcept({
    required this.name,
    required this.anyOf,
  });

  factory ContentConcept.fromConfig(Object? raw) {
    if (raw is String) {
      return ContentConcept(name: raw, anyOf: [raw]);
    }
    if (raw is Map) {
      final map = raw.cast<String, dynamic>();
      final anyOf = (map['any_of'] as List?)
              ?.whereType<Object>()
              .map((v) => v.toString())
              .where((v) => v.isNotEmpty)
              .toList() ??
          const <String>[];
      final name = (map['name'] as String?) ??
          (anyOf.isNotEmpty ? anyOf.first : 'unnamed concept');
      if (anyOf.isNotEmpty) {
        return ContentConcept(name: name, anyOf: anyOf);
      }
      final contains = map['contains'] as String?;
      if (contains != null && contains.isNotEmpty) {
        return ContentConcept(name: name, anyOf: [contains]);
      }
      throw ArgumentError.value(raw, 'raw', 'concept must include any_of');
    }
    throw ArgumentError.value(raw, 'raw', 'unsupported content concept');
  }
}

class DynamicSurfaceHtmlContractGrader extends CodeGrader {
  DynamicSurfaceHtmlContractGrader();

  @override
  String get name => 'dynamic_surface_html_contract';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final s = outcome.environmentState;
    final html = s[_Keys.html] as String? ?? '';
    final rendered = s[_Keys.renderedHtml] as String? ?? '';
    final data = s[_Keys.data];
    final renderedNeedles = _renderedDataNeedles(data).toList();
    final usesDataContract = html.contains('{{memex_data_json}}');
    final usesRemovedItemsContract = html.contains('{{memex_items_json}}');
    final containsRenderedItems =
        renderedNeedles.isNotEmpty && renderedNeedles.any(rendered.contains);

    return [
      Assertion(
        description: 'HTML reads parser output through memex_data_json',
        passed: usesDataContract,
        actual: 'uses_memex_data_json=$usesDataContract',
        expected: 'true',
      ),
      Assertion(
        description: 'HTML does not use removed memex_items_json contract',
        passed: !usesRemovedItemsContract,
        actual: 'uses_memex_items_json=$usesRemovedItemsContract',
        expected: 'false',
      ),
      Assertion(
        description: 'rendered HTML contains at least one parsed data value',
        passed: containsRenderedItems,
        actual:
            'needles=${renderedNeedles.take(5).toList()} contains=$containsRenderedItems',
        expected: 'rendered HTML contains one parsed value',
      ),
    ];
  }

  Iterable<String> _renderedDataNeedles(Object? data) sync* {
    if (data is String && data.trim().length >= 3) {
      yield data.trim();
      return;
    }
    if (data is num || data is bool) {
      yield data.toString();
      return;
    }
    if (data is List) {
      for (final item in data) {
        yield* _renderedDataNeedles(item);
      }
      return;
    }
    if (data is Map) {
      for (final entry in data.entries) {
        yield* _renderedDataNeedles(entry.value);
      }
    }
  }
}

class DynamicSurfacePageAgentGrader extends CodeGrader {
  final String expectedTrigger;

  DynamicSurfacePageAgentGrader({
    this.expectedTrigger = SystemEventTypes.userInputSubmitted,
  });

  @override
  String get name => 'dynamic_surface_page_agent';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final s = outcome.environmentState;
    final count = s[_Keys.pageAgentCount] as int? ?? 0;
    final agent = (s[_Keys.pageAgent] as Map?)?.cast<String, dynamic>();
    final systemPrompt = agent?['systemPrompt'] as String? ?? '';
    final lowerSystemPrompt = systemPrompt.toLowerCase();
    final managedSurfaceId = agent?['managedSurfaceId'] as String?;
    final actualSurfaceId = s['surface_id'] as String? ??
        context.metadata['expected_surface_id'] as String?;
    final mentionsContract = systemPrompt.contains('数据') ||
        lowerSystemPrompt.contains('markdown') ||
        lowerSystemPrompt.contains('parser.js') ||
        lowerSystemPrompt.contains('parser contract');

    return [
      Assertion(
        description: 'exactly one bound page maintenance agent exists',
        passed: count == 1,
        actual: 'page_agent_count=$count',
        expected: '1',
      ),
      Assertion(
        description: 'page agent is bound to this surface id',
        passed: managedSurfaceId == actualSurfaceId,
        actual: 'managedSurfaceId=$managedSurfaceId',
        expected: '$actualSurfaceId',
      ),
      Assertion(
        description: 'page agent uses the requested automatic trigger mode',
        passed: agent?['eventType'] == expectedTrigger,
        actual: '${agent?['eventType']}',
        expected:
            expectedTrigger.isEmpty ? '<manual refresh only>' : expectedTrigger,
      ),
      Assertion(
        description: 'page agent prompt mentions constrained surface updates',
        passed:
            systemPrompt.contains(managedSurfaceId ?? '') && mentionsContract,
        actual: systemPrompt.length > 240
            ? '${systemPrompt.substring(0, 240)}...'
            : systemPrompt,
        expected: 'prompt references surface id and Markdown/data contract',
      ),
    ];
  }
}

class DynamicSurfaceMaintainedByPageAgentGrader extends CodeGrader {
  DynamicSurfaceMaintainedByPageAgentGrader();

  @override
  String get name => 'dynamic_surface_page_agent_maintenance';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final s = outcome.environmentState;
    final hasPageAgentEvent =
        (s[_Keys.sourceBeforePageAgent] as Map?)?.isNotEmpty == true ||
            (s[_Keys.sourceAfterPageAgent] as Map?)?.isNotEmpty == true;
    if (!hasPageAgentEvent) return const [];

    final pageAgentError = s[_Keys.pageAgentError] as String?;
    final before =
        (s[_Keys.sourceBeforePageAgent] as Map?)?.cast<String, String>() ??
            const {};
    final after =
        (s[_Keys.sourceAfterPageAgent] as Map?)?.cast<String, String>() ??
            const {};
    final dataAfter = s[_Keys.dataAfterPageAgent];
    final renderedAfter = s[_Keys.renderedHtmlAfterPageAgent] as String? ?? '';
    final manifestBefore = s[_Keys.manifestBeforePageAgent] as Map?;
    final manifestAfter = s[_Keys.manifestAfterPageAgent] as Map?;
    final htmlBefore = s[_Keys.htmlBeforePageAgent] as String?;
    final htmlAfter = s[_Keys.htmlAfterPageAgent] as String?;
    final changed = before.length != after.length ||
        before.keys.any((k) => before[k] != after[k]) ||
        after.keys.any((k) => before[k] != after[k]);
    final requiredSubstring =
        context.metadata['page_agent_expected_substring'] as String?;
    final containsExpected = requiredSubstring == null ||
        _containsCaseInsensitive(after.values, requiredSubstring) ||
        renderedAfter.toLowerCase().contains(requiredSubstring.toLowerCase());

    return [
      Assertion(
        description: 'page agent completed without exception',
        passed: pageAgentError == null,
        actual: pageAgentError ?? '<none>',
        expected: '<none>',
      ),
      Assertion(
        description: 'page agent did not rewrite surface manifest',
        passed: _stringify(manifestBefore) == _stringify(manifestAfter),
        actual:
            'before=${_previewText(_stringify(manifestBefore))} after=${_previewText(_stringify(manifestAfter))}',
        expected: 'manifest unchanged',
      ),
      Assertion(
        description: 'page agent did not rewrite surface HTML',
        passed: htmlBefore == htmlAfter,
        actual:
            'before_len=${htmlBefore?.length} after_len=${htmlAfter?.length}',
        expected: 'html unchanged',
      ),
      Assertion(
        description: 'page agent changed declared source content',
        passed: changed,
        actual: 'changed=$changed before=${before.keys} after=${after.keys}',
        expected: 'changed=true',
      ),
      Assertion(
        description: 'page agent preserved parseable rendered data',
        passed:
            _hasMeaningfulData(dataAfter) && renderedAfter.trim().isNotEmpty,
        actual:
            'data=${_describeData(dataAfter)} rendered_len=${renderedAfter.length}',
        expected: 'non-empty parser output and rendered HTML',
      ),
      Assertion(
        description: 'page agent incorporated the event into surface data',
        passed: containsExpected,
        actual: 'required=$requiredSubstring source=${_preview(after.values)}',
        expected: requiredSubstring == null ? '<none>' : 'contains substring',
      ),
    ];
  }

  String _preview(Iterable<String> values) {
    final joined = values.join('\n');
    if (joined.length <= 240) return joined;
    return joined.substring(0, 240);
  }

  String _previewText(String text) {
    if (text.length <= 240) return text;
    return text.substring(0, 240);
  }

  bool _containsCaseInsensitive(Iterable<String> values, String needle) {
    final normalizedNeedle = needle.toLowerCase();
    return values.any((body) => body.toLowerCase().contains(normalizedNeedle));
  }

  String _stringify(Object? value) => value == null ? '<null>' : '$value';
}
