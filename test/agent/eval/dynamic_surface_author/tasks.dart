import 'dart:io';

import 'package:dart_agent_core/eval.dart';
import 'package:memex/domain/models/system_event.dart';

import 'graders.dart';

GraderRegistry buildDynamicSurfaceAuthorGraderRegistry() {
  final reg = GraderRegistry();

  reg.register(
    'dynamic_surface_install',
    (cfg) => DynamicSurfaceInstallGrader(
      expectedSourcePath: cfg['expected_source_path'] as String?,
    ),
  );
  reg.register(
    'dynamic_surface_content',
    (cfg) => DynamicSurfaceContentGrader(
      initialSubstrings:
          (cfg['initial_substrings'] as List?)?.cast<String>() ?? const [],
      maintainedSubstrings:
          (cfg['maintained_substrings'] as List?)?.cast<String>() ?? const [],
      initialConcepts: _contentConcepts(cfg['initial_concepts']),
      maintainedConcepts: _contentConcepts(cfg['maintained_concepts']),
    ),
  );
  reg.register(
    'dynamic_surface_html_contract',
    (_) => DynamicSurfaceHtmlContractGrader(),
  );
  reg.register(
    'dynamic_surface_page_agent',
    (cfg) => DynamicSurfacePageAgentGrader(
      expectedTrigger: cfg['expected_trigger'] as String? ??
          SystemEventTypes.userInputSubmitted,
    ),
  );
  reg.register(
    'dynamic_surface_page_agent_maintenance',
    (_) => DynamicSurfaceMaintainedByPageAgentGrader(),
  );

  return reg;
}

List<ContentConcept> _contentConcepts(Object? raw) {
  return (raw as List?)
          ?.map(ContentConcept.fromConfig)
          .toList(growable: false) ??
      const <ContentConcept>[];
}

String defaultDynamicSurfaceAuthorSuiteDir() =>
    'test/agent/eval/dynamic_surface_author/suites/capability';

EvalSuite buildDynamicSurfaceAuthorSuite({String? suiteDir}) {
  final dir = Directory(suiteDir ?? defaultDynamicSurfaceAuthorSuiteDir());
  return loadEvalSuiteFromDir(
    dir,
    graderRegistry: buildDynamicSurfaceAuthorGraderRegistry(),
  );
}
