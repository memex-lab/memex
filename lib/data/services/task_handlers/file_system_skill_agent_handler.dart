import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:memex/agent/agent_controller.util.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/flutter_js_runtime.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final Logger _logger = getLogger('FileSystemSkillAgentHandler');

const String _skillDirName = 'submit_summary';
const String _skillMdContent = '''
---
name: submit_summary
description: After user submits input, run the on_submit script to produce a short summary for the fact.
metadata:
  short-description: Run JS on submit
---

# submit_summary

When the user has just submitted input:

1. Run the script at `scripts/on_submit.js`.
2. Pass "fact_id" and "combined_text" as arguments to the script.
3. Return the script result to the user.
''';

const String _onSubmitJsContent = r'''
async function run(ctx) {
  const factId = (ctx.args && ctx.args.fact_id) || '';
  const text = (ctx.args && ctx.args.combined_text) || '';
  const preview = text.length > 2 ? text.slice(0, 2) + '...' : text;
  return {
    fact_id: factId,
    summary: 'Fact ' + factId + ': ' + preview,
    length: text.length,
  };
}
''';

/// Ensures the file-system skill directory and files exist under [skillsRoot].
/// Returns the absolute path to the skill root (e.g. .../skills).
Future<String> ensureSubmitSummarySkillDirectory(String skillsRoot) async {
  final submitDir = path.join(skillsRoot, _skillDirName);
  final scriptsDir = path.join(submitDir, 'scripts');
  await Directory(scriptsDir).create(recursive: true);

  final skillMd = File(path.join(submitDir, 'SKILL.md'));
  if (!skillMd.existsSync()) {
    await skillMd.writeAsString(_skillMdContent);
    _logger.info('Wrote SKILL.md for submit_summary');
  }

  final scriptFile = File(path.join(scriptsDir, 'on_submit.js'));
  if (!scriptFile.existsSync()) {
    await scriptFile.writeAsString(_onSubmitJsContent);
    _logger.info('Wrote scripts/on_submit.js for submit_summary');
  }

  return path.normalize(path.absolute(skillsRoot));
}

/// Task handler for `file_system_skill_agent_task`.
/// Runs an agent with file-system Skill (submit_summary) and RunJavaScript.
Future<void> handleFileSystemSkillAgentImpl(
  String userId,
  Map<String, dynamic> payload,
  TaskContext taskContext,
) async {
  final factId = payload['fact_id'] as String? ?? '';
  final combinedText = payload['combined_text'] as String? ?? '';

  _logger.info('FileSystemSkillAgent task started for fact $factId');

  final appDir = await getApplicationDocumentsDirectory();
  final skillsRoot = path.join(appDir.path, 'skills');
  final skillRootAbsolute = await ensureSubmitSummarySkillDirectory(skillsRoot);

  final resources = await UserStorage.getAgentLLMResources(
    AgentDefinitions.cardAgent,
    defaultClientKey: LLMConfig.defaultClientKey,
  );

  final permissionManager = FilePermissionManager(userId, [
    PermissionRule(rootPath: skillRootAbsolute, access: FileAccessType.read),
  ]);
  final fileToolFactory = FileToolFactory(
    permissionManager: permissionManager,
    workingDirectory: skillRootAbsolute,
  );

  final tools = [
    fileToolFactory.buildReadTool(),
    fileToolFactory.buildLSTool(),
  ];

  final controller = AgentController();
  addAgentLogger(controller);

  final sessionId =
      'file_system_skill_${userId}_${factId}_${DateTime.now().millisecondsSinceEpoch}';
  final state = AgentState.empty()..sessionId = sessionId;

  final agent = StatefulAgent(
    name: 'file_system_skill_agent',
    client: resources.client,
    modelConfig: resources.modelConfig,
    state: state,
    tools: tools,
    skillDirectoryPath: skillRootAbsolute,
    javaScriptRuntime: FlutterJavaScriptRuntime(),
    skills: null,
    systemPrompts: [
      'You are a helper. When the user describes a submitted input, use the submit_summary skill: read its SKILL.md, then run the script with RunJavaScript using the given fact_id and combined_text. Return the script result.',
    ],
    disableSubAgents: true,
    controller: controller,
  );

  final userMessage =
      'User just submitted input.\nfact_id: $factId\ncombined_text:\n$combinedText\n\nUse the submit_summary skill: read its SKILL.md, then run scripts/on_submit.js via RunJavaScript with an absolute script_path under the skill root and args as a JSON object string containing fact_id and combined_text (use the combined_text above). Return the script output.';

  final responses = await agent.run([UserMessage.text(userMessage)]);

  final last = responses.isNotEmpty ? responses.last : null;
  if (last is ModelMessage && last.textOutput != null) {
    _logger.info('FileSystemSkillAgent result: ${last.textOutput}');
  } else {
    _logger.info('FileSystemSkillAgent completed, last response: $last');
  }
}
