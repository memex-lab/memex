import 'dart:io';

import 'package:dart_agent_core/eval.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

import 'environment.dart';
import 'harness.dart';
import 'tasks.dart';

/// Card Agent capability eval. Loads `suites/capability/` via the
/// framework's `loadEvalSuiteFromDir`, runs the production
/// `processWithCardAgent` codepath end-to-end, and scores each trial
/// with the registered graders.
///
/// Run:
///
///     export OPENAI_BASE_URL='https://shark.ai/api/v1'
///     export OPENAI_API_KEY='sk-...'
///     export EVAL_MODEL='anthropic/claude-sonnet-4.6'  # optional
///     flutter test test/agent/eval/card_agent/card_agent_suite_test.dart -r expanded
///
/// Reports land in `.state_dir/.eval_reports/`, traces in
/// `.state_dir/.eval_traces/` (under the gitignored `.state_dir/` so eval
/// outputs never accidentally end up in commits).
bool get _hasLiveEnv =>
    (Platform.environment['OPENAI_BASE_URL'] ?? '').isNotEmpty &&
    (Platform.environment['OPENAI_API_KEY'] ?? '').isNotEmpty;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late CardAgentEvalRuntime runtime;

  setUpAll(() async {
    if (!_hasLiveEnv) return;
    runtime = await CardAgentEvalRuntime.setUp(
      baseUrl: Platform.environment['OPENAI_BASE_URL']!,
      apiKey: Platform.environment['OPENAI_API_KEY']!,
      modelId:
          Platform.environment['EVAL_MODEL'] ?? 'anthropic/claude-opus-4.7',
    );
  });

  tearDownAll(() async {
    if (!_hasLiveEnv) return;
    await runtime.tearDown();
  });

  test(
    'card_agent_capability suite',
    () async {
      final tracesDir = Directory('.state_dir/.eval_traces')
        ..createSync(recursive: true);
      final reportsDir = Directory('.state_dir/.eval_reports')
        ..createSync(recursive: true);
      final tracesFile = File(
        '${tracesDir.path}/card_agent_${DateTime.now().millisecondsSinceEpoch}.jsonl',
      );

      final suiteDir = Directory(defaultCardAgentSuiteDir());
      final suite = buildCardAgentSuite(suiteDir: suiteDir.path);

      final runner = EvalRunner(
        environment: CardAgentEvalEnvironment(suiteDir: suiteDir),
        harnessFactory: const CardAgentHarnessFactory(),
        exporters: [JsonlTraceExporter(tracesFile)],
        reportStore: FileReportStore(reportsDir),
      );

      final report = await runner.runSuite(
        runName: 'card_agent_${DateTime.now().millisecondsSinceEpoch}',
        suite: suite,
        concurrency: 6,
      );

      // ignore: avoid_print
      print(report.toMarkdownSummary());

      // For a capability suite we don't fail the test on a single trial
      // miss — capability is meant to track how good the agent is, not
      // whether it's perfect. We do fail if every trial errored
      // (harness / setup bug, not an agent quality issue).
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
