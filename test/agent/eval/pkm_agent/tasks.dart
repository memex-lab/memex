import 'dart:io';

import 'package:dart_agent_core/eval.dart';

import 'graders.dart';

/// Registers the PKM Agent graders so framework's `loadEvalSuiteFromDir`
/// can resolve them from `task.json` `{"name": "...", "config": {...}}`
/// entries.
GraderRegistry buildPkmAgentGraderRegistry() {
  final reg = GraderRegistry();

  reg.register('pkm_completion', (_) => PkmCompletionGrader());

  reg.register(
    'pkm_routed_correctly',
    (cfg) => PkmRoutedCorrectlyGrader(
      expectedBuckets: (cfg['expected_buckets'] as List).cast<String>(),
      expectedFiles:
          (cfg['expected_files'] as List?)?.cast<String>() ?? const [],
    ),
  );

  reg.register(
    'pkm_read_before_write',
    (cfg) => PkmReadBeforeWriteGrader(
      requiredReadPath: cfg['required_read_path'] as String,
    ),
  );

  reg.register(
    'pkm_no_overwrite',
    (cfg) => PkmNoOverwriteGrader(
      seedMarker: cfg['seed_marker'] as String,
    ),
  );

  reg.register(
    'pkm_insight_quality',
    (_) => PkmInsightQualityGrader(),
  );

  reg.register(
    'pkm_append_coherence',
    (_) => PkmAppendCoherenceGrader(),
  );

  return reg;
}

/// Default suite path under `test/agent/eval/pkm_agent/`. Resolves
/// relative to the memex repo root when `flutter test` is invoked from
/// there.
String defaultPkmAgentSuiteDir() =>
    'test/agent/eval/pkm_agent/suites/capability';

/// Loads the suite from disk via the framework loader.
EvalSuite buildPkmAgentSuite({String? suiteDir}) {
  final dir = Directory(suiteDir ?? defaultPkmAgentSuiteDir());
  return loadEvalSuiteFromDir(
    dir,
    graderRegistry: buildPkmAgentGraderRegistry(),
  );
}
