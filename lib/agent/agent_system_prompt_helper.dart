/// Agent System Prompt Helper
///
/// Load agent custom prompt config from workspace/_user_id/_UserSettings/prompts/.
/// Config file name is {agent_name}.conf, supporting:
///
/// 1. System Prompt:
///    - Override mode: replace the entire system_prompt
///    - Replace mode: replace specified strings in system_prompt (supports multiline)
///
/// 2. Tool:
///    - Match tools by name, override description and/or parameters
///
/// Config format: see doc comments in Python agent_system_prompt_helper.py.

import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'package:memex/data/services/file_system_service.dart';

final _logger = Logger('AgentSystemPromptHelper');

const _tagPrefix = '@@#CONF#';

class SystemPromptConfig {
  String? overrideContent;
  final List<(String, String)> replacements = []; // [(old, new)]
}

class ToolOverride {
  final String name;
  final String? description;
  final Map<String, dynamic>? parameters;

  ToolOverride({required this.name, this.description, this.parameters});
}

class AgentPromptConfig {
  final SystemPromptConfig systemPrompt = SystemPromptConfig();
  final Map<String, ToolOverride> toolOverrides = {};
}

/// Extract content from lines[start] up to (but not including) the endTag line.
/// Returns (content, nextLineIndex).
(String, int) _extractBlock(List<String> lines, int start, String endTag) {
  final blockLines = <String>[];
  var i = start;
  while (i < lines.length) {
    if (lines[i].trim() == endTag) {
      i++;
      break;
    }
    blockLines.add(lines[i]);
    i++;
  }
  final content = blockLines.join('\n');
  // trim leading/trailing blank lines
  final trimmed =
      content.replaceAll(RegExp(r'^\n+'), '').replaceAll(RegExp(r'\n+$'), '');
  return (trimmed, i);
}

AgentPromptConfig _parseConfig(String content) {
  final config = AgentPromptConfig();
  final lines = content.split('\n');
  var i = 0;
  final p = _tagPrefix;

  while (i < lines.length) {
    final line = lines[i].trim();

    if (line == '$p[system_prompt:override]') {
      i++;
      final (block, nextI) =
          _extractBlock(lines, i, '$p[/system_prompt:override]');
      i = nextI;
      config.systemPrompt.overrideContent = block;
    } else if (line == '$p[system_prompt:replace]') {
      i++;
      String? oldText;
      String? newText;
      while (i < lines.length) {
        final inner = lines[i].trim();
        if (inner == '$p[/system_prompt:replace]') {
          i++;
          break;
        } else if (inner == '$p[old]') {
          i++;
          final (block, nextI) = _extractBlock(lines, i, '$p[/old]');
          i = nextI;
          oldText = block;
        } else if (inner == '$p[new]') {
          i++;
          final (block, nextI) = _extractBlock(lines, i, '$p[/new]');
          i = nextI;
          newText = block;
        } else {
          i++;
        }
      }
      if (oldText != null && newText != null) {
        config.systemPrompt.replacements.add((oldText, newText));
      }
    } else if (line.startsWith('$p[tool:') &&
        line.endsWith(']') &&
        !line.startsWith('$p[/')) {
      final toolName = line.substring('$p[tool:'.length, line.length - 1);
      final endTag = '$p[/tool:$toolName]';
      i++;
      final (jsonBlock, nextI) = _extractBlock(lines, i, endTag);
      i = nextI;
      if (jsonBlock.isNotEmpty) {
        try {
          final data = jsonDecode(jsonBlock) as Map<String, dynamic>;
          config.toolOverrides[toolName] = ToolOverride(
            name: toolName,
            description: data['description'] as String?,
            parameters: data['parameters'] as Map<String, dynamic>?,
          );
        } catch (e) {
          _logger.warning(
              'Failed to parse tool override JSON for "$toolName": $e');
        }
      }
    } else {
      i++;
    }
  }

  return config;
}

String _getConfigPath(String userId, String agentName) {
  final settingsPath = FileSystemService.instance.getUserSettingsPath(userId);
  return path.join(settingsPath, 'prompts', '$agentName.conf');
}

Future<AgentPromptConfig?> loadAgentPromptConfig(
    String userId, String agentName) async {
  final configPath = _getConfigPath(userId, agentName);
  final file = File(configPath);
  if (!await file.exists()) return null;
  try {
    final content = await file.readAsString();
    return _parseConfig(content);
  } catch (e) {
    _logger.severe('Failed to load agent prompt config from $configPath: $e');
    return null;
  }
}

(SystemMessage?, List<Tool>, List<LLMMessage>) applyPromptConfig(
  AgentPromptConfig config,
  SystemMessage? systemMessage,
  List<Tool> tools,
  List<LLMMessage> requestMessages,
) {
  var newSystemMessage = systemMessage;
  var newTools = List<Tool>.from(tools);
  var newRequestMessages = List<LLMMessage>.from(requestMessages);

  final spConfig = config.systemPrompt;

  if (spConfig.overrideContent != null) {
    newSystemMessage = SystemMessage(spConfig.overrideContent!);
  } else if (spConfig.replacements.isNotEmpty) {
    if (newSystemMessage != null) {
      var newContent = newSystemMessage.content;
      for (final (oldStr, newStr) in spConfig.replacements) {
        newContent = newContent.replaceAll(oldStr, newStr);
      }
      newSystemMessage = SystemMessage(newContent);
    }
  }

  if (config.toolOverrides.isNotEmpty) {
    for (var idx = 0; idx < newTools.length; idx++) {
      final override = config.toolOverrides[newTools[idx].name];
      if (override != null) {
        newTools[idx] = Tool(
          name: newTools[idx].name,
          description: override.description ?? newTools[idx].description,
          parameters: override.parameters ?? newTools[idx].parameters,
          executable: newTools[idx].executable,
          namedParameters: newTools[idx].namedParameters,
        );
      }
    }
  }

  return (newSystemMessage, newTools, newRequestMessages);
}

/// Create a systemCallback to pass to StatefulAgent.
/// user_id is captured by closure; agent_name is taken from agent.name at callback time.
///
/// Usage: StatefulAgent(..., systemCallback: createSystemCallback(userId))
SystemCallback createSystemCallback(String userId) {
  return (StatefulAgent agent, SystemMessage? systemMessage, List<Tool> tools,
      List<LLMMessage> requestMessages) async {
    final config = await loadAgentPromptConfig(userId, agent.name);
    if (config == null) {
      return (systemMessage, tools, requestMessages);
    }
    return applyPromptConfig(config, systemMessage, tools, requestMessages);
  };
}

/// Create a systemCallback that also masks [workingDirectory] from all paths
/// visible to the model (system prompt, skill instructions, RunJavaScript tool).
///
/// This keeps the model's view consistent with file tools that already strip
/// the workingDirectory prefix, so the model always sees virtual paths like
/// `/skills/my_skill/SKILL.md` instead of real absolute paths.
///
/// Usage: StatefulAgent(..., systemCallback: createSystemCallbackWithWorkingDirectory(userId, workingDirectory))
SystemCallback createSystemCallbackWithWorkingDirectory(
  String userId,
  String workingDirectory,
) {
  // Ensure workingDirectory doesn't end with '/' for consistent replacement.
  final wd = workingDirectory.endsWith('/')
      ? workingDirectory.substring(0, workingDirectory.length - 1)
      : workingDirectory;

  return (StatefulAgent agent, SystemMessage? systemMessage, List<Tool> tools,
      List<LLMMessage> requestMessages) async {
    // 1. Apply user prompt config first (same as createSystemCallback).
    final config = await loadAgentPromptConfig(userId, agent.name);
    if (config != null) {
      (systemMessage, tools, requestMessages) =
          applyPromptConfig(config, systemMessage, tools, requestMessages);
    }

    // 2. Mask workingDirectory in system message (skill paths appear here).
    if (systemMessage != null) {
      final masked = _maskWorkingDirectory(systemMessage.content, wd);
      if (masked != systemMessage.content) {
        systemMessage = SystemMessage(masked);
      }
    }

    // 3. Mask workingDirectory in request messages (skill injection messages).
    requestMessages = _maskMessagesWorkingDirectory(requestMessages, wd);

    // 4. Wrap RunJavaScript tool to resolve virtual paths back to absolute.
    tools = _wrapRunJavaScriptTool(tools, wd);

    return (systemMessage, tools, requestMessages);
  };
}

/// Replace `workingDirectory` prefix with `/` in a string, matching the
/// convention used by FileOperationService._maskResult.
String _maskWorkingDirectory(String text, String wd) {
  // Replace "wd/" with "/" first to avoid double slashes, then "wd" with "/".
  var result = text.replaceAll('$wd/', '/');
  result = result.replaceAll(wd, '/');
  return result;
}

/// Mask workingDirectory in all UserMessage text parts within request messages.
List<LLMMessage> _maskMessagesWorkingDirectory(
  List<LLMMessage> messages,
  String wd,
) {
  var changed = false;
  final result = <LLMMessage>[];

  for (final msg in messages) {
    if (msg is UserMessage) {
      var msgChanged = false;
      final newContents = <UserContentPart>[];
      for (final part in msg.contents) {
        if (part is TextPart) {
          final masked = _maskWorkingDirectory(part.text, wd);
          if (masked != part.text) {
            newContents.add(TextPart(masked));
            msgChanged = true;
          } else {
            newContents.add(part);
          }
        } else {
          newContents.add(part);
        }
      }
      if (msgChanged) {
        result.add(UserMessage(newContents,
            timestamp: msg.timestamp, metadata: msg.metadata));
        changed = true;
      } else {
        result.add(msg);
      }
    } else {
      result.add(msg);
    }
  }

  return changed ? result : messages;
}

/// Wrap the RunJavaScript tool so that virtual paths (as seen by the model)
/// are resolved back to absolute paths before execution.
List<Tool> _wrapRunJavaScriptTool(List<Tool> tools, String wd) {
  final idx = tools.indexWhere((t) => t.name == 'RunJavaScript');
  if (idx == -1) return tools;

  final original = tools[idx];
  final originalExec = original.executable;
  if (originalExec == null) return tools;

  final wrapped = Tool(
    name: original.name,
    description: original.description,
    parameters: original.parameters,
    namedParameters: original.namedParameters,
    executable: (String script_path, String? args, int? timeout_ms) {
      // Resolve virtual path to absolute, same logic as FileToolFactory._resolvePath.
      if (!script_path.startsWith(wd)) {
        if (script_path.startsWith('/')) {
          script_path =
              script_path == '/' ? wd : path.join(wd, script_path.substring(1));
        } else {
          script_path = path.join(wd, script_path);
        }
      }
      return Function.apply(originalExec, [script_path, args, timeout_ms]);
    },
  );

  final newTools = List<Tool>.from(tools);
  newTools[idx] = wrapped;
  return newTools;
}
