import 'dart:io';

import 'package:dart_agent_core/eval.dart';

import 'graders.dart';

/// Registers the Card Agent graders so framework's `loadEvalSuiteFromDir`
/// can resolve them from `task.json` `{"name": "...", "config": {...}}`
/// entries.
GraderRegistry buildCardAgentGraderRegistry() {
  final reg = GraderRegistry();

  reg.register('card_completion', (_) => CardCompletionGrader());

  reg.register(
    'card_template_choice',
    (cfg) => CardTemplateChoiceGrader(
      expectedTemplateIds:
          (cfg['expected_template_ids'] as List).cast<String>().toSet(),
    ),
  );

  reg.register(
    'card_must_contain',
    (cfg) => CardMustContainGrader(
      substrings: (cfg['substrings'] as List).cast<String>(),
    ),
  );

  return reg;
}

/// Default suite path under `test/agent/eval/card_agent/`. Resolves
/// relative to the memex repo root when `flutter test` is invoked from
/// there.
String defaultCardAgentSuiteDir() =>
    'test/agent/eval/card_agent/suites/capability';

/// Loads the suite from disk via the framework loader. Use the optional
/// [suiteDir] override if you want to point at a different suite.
EvalSuite buildCardAgentSuite({String? suiteDir}) {
  final dir = Directory(suiteDir ?? defaultCardAgentSuiteDir());
  return loadEvalSuiteFromDir(
    dir,
    graderRegistry: buildCardAgentGraderRegistry(),
  );
}
