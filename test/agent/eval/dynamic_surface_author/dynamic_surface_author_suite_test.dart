import 'dart:io';

import 'package:dart_agent_core/eval.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

import 'environment.dart';
import 'harness.dart';
import 'tasks.dart';

bool get _hasLiveEnv =>
    (Platform.environment['SHARK_OPENAI_BASE_URL'] ?? '').isNotEmpty &&
    (Platform.environment['SHARK_OPENAI_API_KEY'] ?? '').isNotEmpty;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late DynamicSurfaceAuthorEvalRuntime runtime;

  setUpAll(() async {
    if (!_hasLiveEnv) return;
    runtime = await DynamicSurfaceAuthorEvalRuntime.setUp(
      baseUrl: Platform.environment['SHARK_OPENAI_BASE_URL']!,
      apiKey: Platform.environment['SHARK_OPENAI_API_KEY']!,
      modelId:
          Platform.environment['EVAL_MODEL'] ?? 'anthropic/claude-sonnet-4.6',
    );
  });

  tearDownAll(() async {
    if (!_hasLiveEnv) return;
    await runtime.tearDown();
  });

  test(
    'dynamic_surface_author capability suite',
    () async {
      final tracesDir = Directory('.state_dir/.eval_traces')
        ..createSync(recursive: true);
      final reportsDir = Directory('.state_dir/.eval_reports')
        ..createSync(recursive: true);
      final tracesFile = File(
        '${tracesDir.path}/dynamic_surface_author_${DateTime.now().millisecondsSinceEpoch}.jsonl',
      );

      final suiteDir = Directory(defaultDynamicSurfaceAuthorSuiteDir());
      final suite = buildDynamicSurfaceAuthorSuite(suiteDir: suiteDir.path);

      final runner = EvalRunner(
        environment: DynamicSurfaceAuthorEvalEnvironment(suiteDir: suiteDir),
        harnessFactory: const DynamicSurfaceAuthorHarnessFactory(),
        exporters: [JsonlTraceExporter(tracesFile)],
        reportStore: FileReportStore(reportsDir),
      );

      final report = await runner.runSuite(
        runName:
            'dynamic_surface_author_${DateTime.now().millisecondsSinceEpoch}',
        suite: suite,
        concurrency: 1,
      );

      // ignore: avoid_print
      print(report.toMarkdownSummary());

      expect(report.trials, isNotEmpty);
      final allErrored =
          report.trials.every((r) => r.trial.status == TrialStatus.errored);
      expect(
        allErrored,
        isFalse,
        reason: 'every trial errored; likely a harness or setup issue',
      );
      expect(
        report.taskPassRate,
        1.0,
        reason: 'dynamic_surface_author suite has failed tasks',
      );
    },
    skip: _hasLiveEnv
        ? false
        : 'SHARK_OPENAI_BASE_URL / SHARK_OPENAI_API_KEY not set',
    timeout: const Timeout(Duration(minutes: 40)),
    tags: const ['live'],
  );
}
