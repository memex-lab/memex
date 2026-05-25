import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dart_agent_core/eval.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Process-wide initialization for the Card Agent eval.
///
/// `FileSystemService` and `SharedPreferences` are designed as
/// app-singletons — calling `init()` mid-run swaps them under everyone's
/// feet. So we initialize them **once** for the whole eval run, and have
/// each trial scope itself by `userId` (FileSystemService partitions
/// per-user workspaces under one shared `dataRoot`).
class CardAgentEvalRuntime {
  final Directory dataRoot;

  CardAgentEvalRuntime._(this.dataRoot);

  static Future<CardAgentEvalRuntime> setUp({
    required String baseUrl,
    required String apiKey,
    required String modelId,
  }) async {
    _setupConsoleLogging();

    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    await UserStorage.saveLLMConfigs([
      LLMConfig(
        key: LLMConfig.defaultClientKey,
        type: LLMConfig.typeChatCompletion,
        modelId: modelId,
        apiKey: apiKey,
        baseUrl: baseUrl,
        maxTokens: 4096,
        extra: const {},
      ),
    ]);
    AgentActivityService.setInstance(LocalAgentActivityService.instance);

    final dataRoot =
        await Directory.systemTemp.createTemp('memex_card_eval_root_');
    await FileSystemService.init(dataRoot.path);
    return CardAgentEvalRuntime._(dataRoot);
  }

  Future<void> tearDown() async {
    if (await dataRoot.exists()) {
      await dataRoot.delete(recursive: true);
    }
  }

  static bool _loggingSet = false;
  static void _setupConsoleLogging() {
    if (_loggingSet) return;
    _loggingSet = true;
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((r) {
      // ignore: avoid_print
      print('[${r.level.name}] ${r.loggerName}: ${r.message}');
      if (r.error != null) {
        // ignore: avoid_print
        print('  error: ${r.error}');
      }
    });
  }
}

/// Per-trial environment. Assumes [CardAgentEvalRuntime.setUp] has been
/// called once before `runSuite`. `prepare`/`dispose` only deal with this
/// trial's own resources (a unique `userId` and the LLM client) — no
/// global singletons are touched.
///
/// [suiteDir] is the absolute path of the loaded suite directory (the
/// one passed to `loadEvalSuiteFromDir`). It's used by the harness to
/// resolve each task's `fixture_dir` (which is declared relative to the
/// suite root in `task.json`).
class CardAgentEvalEnvironment implements EvalEnvironment {
  final Directory suiteDir;

  CardAgentEvalEnvironment({required this.suiteDir});

  @override
  Future<EvalContext> prepare({
    required Trial trial,
    required EvalTask task,
  }) async {
    final userId =
        '${trial.taskId}_${trial.trialIndex}_${DateTime.now().microsecondsSinceEpoch}';
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.cardAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    return EvalContext(
      workspaceDir: Directory(
        FileSystemService.instance.getWorkspacePath(userId),
      ),
      clock: const SystemEvalClock(),
      llmClient: resources.client,
      controller: AgentController(),
      servicesMap: {
        ModelConfig: resources.modelConfig,
      },
      metadata: {
        'user_id': userId,
        'suite_dir': suiteDir.path,
      },
    );
  }

  @override
  Future<void> dispose(EvalContext ctx) async {
    final dir = ctx.workspaceDir;
    if (dir != null && await dir.exists()) {
      await dir.delete(recursive: true);
    }
    ctx.controller.close();
  }
}
