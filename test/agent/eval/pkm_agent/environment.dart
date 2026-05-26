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

import 'graders.dart' show JudgeResources;

/// Marker key used to look up the LLM-as-judge resources from
/// `EvalContext.servicesMap`. We register the judge client + model config
/// once per run and let LLM graders pull them out by type rather than
/// re-resolving `UserStorage` from inside `Grader.grade()`.
class JudgeLLMResources implements JudgeResources {
  @override
  final LLMClient client;
  @override
  final ModelConfig modelConfig;
  const JudgeLLMResources({required this.client, required this.modelConfig});
}

/// Process-wide initialization for the PKM Agent eval. Mirrors
/// `CardAgentEvalRuntime` — `FileSystemService` / `SharedPreferences` are
/// app-singletons, so we initialize them **once** for the whole eval run
/// and let each trial scope itself by `userId`.
class PkmAgentEvalRuntime {
  final Directory dataRoot;
  final JudgeLLMResources judge;

  PkmAgentEvalRuntime._(this.dataRoot, this.judge);

  static Future<PkmAgentEvalRuntime> setUp({
    required String baseUrl,
    required String apiKey,
    required String modelId,
    String? judgeModelId,
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
        await Directory.systemTemp.createTemp('memex_pkm_eval_root_');
    await FileSystemService.init(dataRoot.path);

    // Build a separate judge LLM client. We resolve through UserStorage so
    // the same auth/transport layer applies, and override the model id so
    // judge != trial-under-test (Anthropic Step 5: avoid having a model
    // judge its own outputs to dampen bias). Default judge is the strongest
    // model we have available so it can reliably score the (weaker) trial
    // model's output.
    final trialResources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.pkmAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final judgeModel = ModelConfig(
      model: judgeModelId ?? 'anthropic/claude-opus-4.7',
      temperature: 0.0,
      maxTokens: 600,
    );
    final judge = JudgeLLMResources(
      client: trialResources.client,
      modelConfig: judgeModel,
    );

    return PkmAgentEvalRuntime._(dataRoot, judge);
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

/// Per-trial environment. Assumes [PkmAgentEvalRuntime.setUp] has been
/// called once before `runSuite`.
class PkmAgentEvalEnvironment implements EvalEnvironment {
  final Directory suiteDir;
  final JudgeLLMResources judge;

  PkmAgentEvalEnvironment({required this.suiteDir, required this.judge});

  @override
  Future<EvalContext> prepare({
    required Trial trial,
    required EvalTask task,
  }) async {
    final userId =
        '${trial.taskId}_${trial.trialIndex}_${DateTime.now().microsecondsSinceEpoch}';
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.pkmAgent,
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
        JudgeResources: judge,
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
