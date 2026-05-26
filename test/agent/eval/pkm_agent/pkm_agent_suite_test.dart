import 'dart:io';

import 'package:dart_agent_core/eval.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

import 'environment.dart';
import 'harness.dart';
import 'tasks.dart';

/// PKM Agent capability eval. Loads `suites/capability/` via the
/// framework's `loadEvalSuiteFromDir`, runs the production
/// `PkmAgent.runWithContent` codepath end-to-end, and scores each trial
/// with the registered graders.
///
/// The eval intentionally uses two different models:
///   - `EVAL_MODEL` runs the agent under test (default: sonnet-4.6, the
///     production model). This is what we are actually grading.
///   - `EVAL_JUDGE_MODEL` runs the LLM-as-judge graders (default: opus-4.7).
///     A stronger model judging a weaker one is recommended by Anthropic
///     Step 5 — keeps judge bias from inflating the grade.
///
/// Run:
///
///     export OPENAI_BASE_URL='https://shark.ai/api/v1'
///     export OPENAI_API_KEY='sk-...'
///     # optional model overrides (defaults: sonnet-4.6 / opus-4.7)
///     export EVAL_MODEL='anthropic/claude-sonnet-4.6'
///     export EVAL_JUDGE_MODEL='anthropic/claude-opus-4.7'
///     flutter test test/agent/eval/pkm_agent/pkm_agent_suite_test.dart -r expanded
///
/// Reports land in `.state_dir/.eval_reports/`, traces in
/// `.state_dir/.eval_traces/` (under the gitignored `.state_dir/` so eval
/// outputs never accidentally end up in commits).
bool get _hasLiveEnv =>
    (Platform.environment['OPENAI_BASE_URL'] ?? '').isNotEmpty &&
    (Platform.environment['OPENAI_API_KEY'] ?? '').isNotEmpty;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late PkmAgentEvalRuntime runtime;

  setUpAll(() async {
    if (!_hasLiveEnv) return;
    runtime = await PkmAgentEvalRuntime.setUp(
      baseUrl: Platform.environment['OPENAI_BASE_URL']!,
      apiKey: Platform.environment['OPENAI_API_KEY']!,
      modelId:
          Platform.environment['EVAL_MODEL'] ?? 'anthropic/claude-sonnet-4.6',
      judgeModelId: Platform.environment['EVAL_JUDGE_MODEL'],
    );
  });

  tearDownAll(() async {
    if (!_hasLiveEnv) return;
    await runtime.tearDown();
  });

  test(
    'pkm_agent_capability suite',
    () async {
      final tracesDir = Directory('.state_dir/.eval_traces')
        ..createSync(recursive: true);
      final reportsDir = Directory('.state_dir/.eval_reports')
        ..createSync(recursive: true);
      final tracesFile = File(
        '${tracesDir.path}/pkm_agent_${DateTime.now().millisecondsSinceEpoch}.jsonl',
      );

      final suiteDir = Directory(defaultPkmAgentSuiteDir());
      final suite = buildPkmAgentSuite(suiteDir: suiteDir.path);

      final runner = EvalRunner(
        environment:
            PkmAgentEvalEnvironment(suiteDir: suiteDir, judge: runtime.judge),
        harnessFactory: const PkmAgentHarnessFactory(),
        exporters: [JsonlTraceExporter(tracesFile)],
        reportStore: FileReportStore(reportsDir),
      );

      final report = await runner.runSuite(
        runName: 'pkm_agent_${DateTime.now().millisecondsSinceEpoch}',
        suite: suite,
        concurrency: 4,
      );

      // ignore: avoid_print
      print(report.toMarkdownSummary());

      expect(report.trials, isNotEmpty);
      final allErrored =
          report.trials.every((r) => r.trial.status == TrialStatus.errored);
      expect(allErrored, isFalse,
          reason: 'every trial errored — likely a setup / harness bug, '
              'not an agent quality issue');
    },
    skip: _hasLiveEnv
        ? false
        : 'OPENAI_BASE_URL / OPENAI_API_KEY not set — skipping live eval',
    timeout: const Timeout(Duration(minutes: 30)),
    tags: const ['live'],
  );
}
