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

class DynamicSurfaceAuthorEvalRuntime {
  final Directory dataRoot;

  DynamicSurfaceAuthorEvalRuntime._(this.dataRoot);

  static Future<DynamicSurfaceAuthorEvalRuntime> setUp({
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
        maxTokens: 65536,
        extra: const {},
      ),
    ]);
    AgentActivityService.setInstance(LocalAgentActivityService.instance);

    final dataRoot =
        await Directory.systemTemp.createTemp('memex_surface_author_eval_');
    await FileSystemService.init(dataRoot.path);
    return DynamicSurfaceAuthorEvalRuntime._(dataRoot);
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

class DynamicSurfaceAuthorEvalEnvironment implements EvalEnvironment {
  final Directory suiteDir;

  DynamicSurfaceAuthorEvalEnvironment({required this.suiteDir});

  @override
  Future<EvalContext> prepare({
    required Trial trial,
    required EvalTask task,
  }) async {
    final userId =
        '${trial.taskId}_${trial.trialIndex}_${DateTime.now().microsecondsSinceEpoch}';
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.dynamicSurfaceAuthorAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    return EvalContext(
      workspaceDir: Directory(FileSystemService.instance.getWorkspacePath(
        userId,
      )),
      clock: const SystemEvalClock(),
      llmClient: resources.client,
      controller: AgentController(),
      servicesMap: {ModelConfig: resources.modelConfig},
      metadata: {
        'user_id': userId,
        'suite_dir': suiteDir.path,
        'task_input_content': task.input['prompt'] as String? ?? '',
        'expected_surface_id': task.input['expected_surface_id'] as String?,
        'page_agent_expected_substring':
            task.input['page_agent_expected_substring'] as String?,
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
