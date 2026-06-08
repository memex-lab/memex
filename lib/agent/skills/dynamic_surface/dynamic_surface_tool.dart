import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_path_resolver.dart';
import 'package:memex/agent/skills/dynamic_surface/dynamic_surface_permissions.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/data/services/dynamic_surface_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/dynamic_surface_model.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:path/path.dart' as path;

// Tool executable parameter names mirror JSON schema keys.
// ignore_for_file: non_constant_identifier_names

const String _manualRefreshOnlyTriggerEventType = 'manual_refresh_only';

const List<String> _pageAgentTriggerEventTypes = [
  _manualRefreshOnlyTriggerEventType,
  SystemEventTypes.userInputSubmitted,
  SystemEventTypes.cardCommentPosted,
  SystemEventTypes.cardUiConfigUpdated,
  SystemEventTypes.knowledgeInsightRefreshRequested,
  SystemEventTypes.scheduleAggregationRequested,
  SystemEventTypes.dynamicSurfaceRefreshRequested,
  SystemEventTypes.clarificationAnswered,
];

const String _pageAgentTriggerEventTypeDescription = '''
Single automatic trigger for the bound page agent.
- manual_refresh_only: disable automatic triggers. Manual refresh is always available.
- user_input_submitted: run after the user submits a new record/input.
- card_comment_posted: run after a Timeline card receives a comment.
- clarification_answered: run after the user answers a clarification.
- Other enum values are built-in feature events; choose them only when the page explicitly depends on that event.
''';

Tool buildInstallDynamicSurfaceTool({String? managedSurfaceId}) {
  return Tool(
    name: 'install_dynamic_surface',
    description: '''
Install or update a free-form Dynamic Surface page for Memex.

Use this when maintaining a user-defined page. You may author arbitrary
HTML/CSS/JavaScript, but you must also define parser.js so Memex can turn the
declared Markdown source into JSON without asking an LLM to read the files at
render time.

The source path, html_file_path, and parser_file_path must be absolute paths.
Write HTML and parser.js with the Write tool first, then pass their paths here.
This keeps tool calls small enough to avoid model output truncation. If
markdown_content is provided, the tool writes that Markdown file first, then
installs surface.yaml, view.html, and parser.js under
/_UserSettings/DynamicSurfaces/<surface_id>/, runs the parser once, renders the
page once, and reports the parser output shape.

The declared source must be page-owned Dynamic Surface data. The bound page
agent always sees the workspace root as `/`. Writes remain restricted to the
declared source.

When this tool is used by the Dynamic Surface authoring agent, it also creates
or updates the page's bound maintenance agent. A Dynamic Surface without a
maintenance agent is incomplete.
''',
    parameters: {
      'type': 'object',
      'properties': {
        'surface_id': {
          'type': 'string',
          'description': managedSurfaceId == null
              ? 'Stable id using only letters, numbers, underscores, or hyphens, e.g. project_board.'
              : 'Must be "$managedSurfaceId" for this page agent.',
        },
        'title': {
          'type': 'string',
          'description': 'Human-readable title for the Dynamic Surface.',
        },
        'source': {
          'type': 'object',
          'description':
              'Markdown data source. Use type=file when also providing markdown_content.',
          'properties': {
            'type': {
              'type': 'string',
              'enum': ['file', 'directory'],
            },
            'path': {
              'type': 'string',
              'description':
                  'Absolute path to page-owned Markdown data, e.g. /_UserSettings/DynamicSurfaceData/<surface_id>/data.md or /_UserSettings/DynamicSurfaceData/<surface_id>.',
            },
            'recursive': {
              'type': 'boolean',
              'description':
                  'For directory sources, whether to parse nested Markdown files.',
            },
          },
          'required': ['type', 'path'],
        },
        'html_file_path': {
          'type': 'string',
          'description':
              'Required absolute path to an HTML file already written with the Write tool. The HTML should read the parser output from {{memex_data_json}}.',
        },
        'parser_file_path': {
          'type': 'string',
          'description':
              'Required absolute path to a parser.js file already written with the Write tool. The script must define function parse(input) and return a JSON-serializable value. Memex supplies input.files with Markdown file content.',
        },
        'description': {
          'type': 'string',
          'description': 'Short description of what the surface does.',
        },
        'markdown_content': {
          'type': 'string',
          'description':
              'Optional Markdown content to write to source.path. Only allowed when source.type=file.',
        },
        'page_agent_trigger_event_type': {
          'type': 'string',
          'description': _pageAgentTriggerEventTypeDescription,
          'enum': _pageAgentTriggerEventTypes,
        },
        'page_agent_system_prompt': {
          'type': 'string',
          'description':
              'Optional replacement system prompt for the bound page agent when changing its work mechanism.',
        },
      },
      'required': [
        'surface_id',
        'title',
        'source',
        'html_file_path',
        'parser_file_path',
      ],
    },
    parameterMode: ToolParameterMode.object,
    executable: (Map args) async {
      final surfaceId = _requiredString(args, 'surface_id');
      final title = _requiredString(args, 'title');
      final source = _requiredMap(args, 'source');
      final htmlFilePath = _requiredString(args, 'html_file_path');
      final parserFilePath = _requiredString(args, 'parser_file_path');
      final description = _optionalString(args, 'description');
      final markdownContent = _optionalString(args, 'markdown_content');
      final pageAgentTriggerEventType =
          _optionalTriggerEventType(args, 'page_agent_trigger_event_type');
      final pageAgentSystemPrompt =
          _optionalString(args, 'page_agent_system_prompt');

      if (managedSurfaceId != null && surfaceId != managedSurfaceId) {
        throw ArgumentError(
          'This page agent may only update surface_id "$managedSurfaceId".',
        );
      }

      final context = AgentCallToolContext.current;
      if (context == null) {
        throw StateError(
          'install_dynamic_surface must be called within an agent execution context.',
        );
      }
      final userId = context.state.metadata['userId'] as String?;
      if (userId == null) {
        throw StateError('Missing userId in agent metadata.');
      }

      final workspacePath = FileSystemService.instance.getWorkspacePath(userId);
      final sourceMap = _normalizeSourceArgument(
        source,
        workingDirectory: workspacePath,
      );
      rejectWorkspacePathUnderNativeSource(
        userId: userId,
        workspaceRelativePath: sourceMap['path'] as String,
        argumentName: 'source.path',
      );
      final htmlContent = await _resolveHtmlContent(
        workingDirectory: workspacePath,
        htmlFilePath: htmlFilePath,
      );
      final parserContent = await _resolveParserContent(
        workingDirectory: workspacePath,
        parserFilePath: parserFilePath,
      );

      final service = DynamicSurfaceService(
        fileSystemService: FileSystemService.instance,
      );
      final result = await service.installAuthoredSurface(
        userId: userId,
        surfaceId: surfaceId,
        title: title,
        description: description,
        source: DynamicSurfaceSource.fromJson(sourceMap),
        parser: const DynamicSurfaceParserSpec(
          type: 'javascript',
          scriptPath: 'parser.js',
          entry: 'parse',
        ),
        parserContent: parserContent,
        htmlContent: htmlContent,
        markdownContent: markdownContent,
      );

      CustomAgentConfig? pageAgentConfig;
      String? pageAgentName;
      if (managedSurfaceId == null) {
        pageAgentConfig = await CustomAgentConfigService.instance
            .installDynamicSurfacePageAgent(
          userId: userId,
          surfaceId: surfaceId,
          displayName: title,
          triggerEventType:
              pageAgentTriggerEventType ?? SystemEventTypes.userInputSubmitted,
          systemPrompt: pageAgentSystemPrompt,
        );
        pageAgentName = pageAgentConfig.agentName;
      }

      EventBusService.instance.emitEvent(
        DynamicSurfaceUpdatedMessage(surfaceId: result.surface.id),
      );

      return AgentToolResult(
        content: TextPart(
          'Dynamic Surface installed: ${result.surface.id}\n'
          'Title: ${result.surface.title}\n'
          'Content type: ${result.contentType}\n'
          'Parser output: ${_describeParserOutput(result.data)}\n'
          '${pageAgentName == null ? '' : 'Bound page agent: $pageAgentName\n'}'
          'Page agent trigger: ${pageAgentConfig == null ? '<unchanged>' : _describeTrigger(pageAgentConfig.eventType)}\n'
          'Open Debugging -> Dynamic Surface Preview to inspect it.',
        ),
      );
    },
  );
}

Tool buildUninstallDynamicSurfaceTool() {
  return Tool(
    name: 'uninstall_dynamic_surface',
    description: '''
Uninstall a Dynamic Surface page. This deletes the installed page package
under /_UserSettings/DynamicSurfaces/<surface_id>, optionally deletes the
declared page-owned Markdown source under
/_UserSettings/DynamicSurfaceData/<surface_id>, deletes the bound maintenance
agent config, deletes its skill directory, and reloads custom-agent event
subscriptions.

Use this when the user asks to remove, delete, or uninstall a user-defined
page. Do not use file tools to manually delete Dynamic Surface directories.
''',
    parameters: {
      'type': 'object',
      'properties': {
        'surface_id': {
          'type': 'string',
          'description': 'Dynamic Surface id to uninstall.',
        },
        'delete_source_data': {
          'type': 'boolean',
          'description':
              'Whether to delete the page-owned Markdown source data. Defaults to true for a full uninstall.',
        },
      },
      'required': ['surface_id'],
    },
    executable: (String surface_id, bool? delete_source_data) async {
      final userId = _currentUserId();
      final service = DynamicSurfaceService(
        fileSystemService: FileSystemService.instance,
      );
      final result = await service.uninstallSurface(
        userId: userId,
        surfaceId: surface_id,
        deleteSourceData: delete_source_data ?? true,
      );
      final deletedAgentName =
          await CustomAgentConfigService.instance.deleteDynamicSurfacePageAgent(
        userId: userId,
        surfaceId: surface_id,
      );

      EventBusService.instance.emitEvent(
        DynamicSurfaceUpdatedMessage(surfaceId: surface_id),
      );

      return AgentToolResult(
        content: TextPart(
          'Dynamic Surface uninstalled: ${result.surfaceId}\n'
          'Title: ${result.title}\n'
          'Deleted page package: ${result.deletedPackage ? 'yes' : 'no'}\n'
          'Deleted source data: ${result.deletedSourcePath ?? 'no'}\n'
          'Deleted draft: ${result.deletedDraft ? 'yes' : 'no'}\n'
          'Deleted page agent: ${deletedAgentName ?? 'not found'}',
        ),
      );
    },
  );
}

Tool buildReadDynamicSurfaceContextTool() {
  return Tool(
    name: 'read_dynamic_surface_context',
    description: '''
Read the current implementation context for a Dynamic Surface before iterating
it. Use this when the user asks to change an existing dynamic page or its bound
maintenance agent. The result includes surface.yaml, view.html, parser.js,
Markdown data source information, parsed data preview, and the bound custom
page agent config.
''',
    parameters: {
      'type': 'object',
      'properties': {
        'surface_id': {
          'type': 'string',
          'description': 'Dynamic Surface id to inspect.',
        },
      },
      'required': ['surface_id'],
    },
    executable: (String surface_id) async {
      final userId = _currentUserId();
      final fileSystem = FileSystemService.instance;
      final service = DynamicSurfaceService(fileSystemService: fileSystem);
      final surface = await service.getSurface(userId, surface_id);
      if (surface == null) {
        throw ArgumentError('Dynamic Surface not found: $surface_id');
      }

      final surfacePath = fileSystem.getDynamicSurfacePath(userId, surface_id);
      final manifestPath =
          fileSystem.getDynamicSurfaceManifestPath(userId, surface_id);
      final manifestContent = await _readIfExists(manifestPath);
      final htmlPath = path.join(surfacePath, surface.render.templatePath);
      final htmlContent = await _readIfExists(htmlPath);
      final parserPath = path.join(surfacePath, surface.parser.scriptPath);
      final parserContent = await _readIfExists(parserPath);
      final markdownContext = await _readMarkdownSourceContext(
        userId,
        surface.source,
        fileSystem,
      );
      final data = await service.readSurfaceData(userId, surface);
      final pageAgent = await _findPageAgentConfig(userId, surface_id);

      final context = {
        'surface_id': surface_id,
        'surface': surface.toJson(),
        'surface_yaml_path': manifestPath,
        'surface_yaml': _truncate(manifestContent, 12000),
        'html_template_path': htmlPath,
        'html_template': _truncate(htmlContent, 20000),
        'parser_script_path': parserPath,
        'parser_script': _truncate(parserContent, 20000),
        'markdown_source': markdownContext,
        'parsed_data': {
          'shape': _describeParserOutput(data),
          'preview_json': _previewJson(data, 8000),
        },
        'bound_page_agent': pageAgent?.toJson(),
      };

      return AgentToolResult(
        content: TextPart(const JsonEncoder.withIndent('  ').convert(context)),
      );
    },
  );
}

Tool buildConfigureDynamicSurfacePageAgentTool() {
  return Tool(
    name: 'configure_dynamic_surface_page_agent',
    description: '''
Create or update the bound maintenance agent for an existing Dynamic Surface.
Use this from the Dynamic Surface authoring agent when the user wants to change
the page agent's trigger timing or work mechanism. Do not ask the maintenance
agent to modify itself.
''',
    parameters: {
      'type': 'object',
      'properties': {
        'surface_id': {
          'type': 'string',
          'description':
              'Dynamic Surface id whose page agent should be updated.',
        },
        'trigger_event_type': {
          'type': 'string',
          'enum': _pageAgentTriggerEventTypes,
          'description': _pageAgentTriggerEventTypeDescription,
        },
        'system_prompt': {
          'type': 'string',
          'description':
              'Optional replacement system prompt describing the page agent work mechanism.',
        },
      },
      'required': ['surface_id', 'trigger_event_type'],
    },
    executable: (
      String surface_id,
      String trigger_event_type,
      String? system_prompt,
    ) async {
      final userId = _currentUserId();
      final config = await CustomAgentConfigService.instance
          .installDynamicSurfacePageAgent(
        userId: userId,
        surfaceId: surface_id,
        triggerEventType: trigger_event_type,
        systemPrompt: system_prompt,
      );

      return AgentToolResult(
        content: TextPart(
          'Bound page agent configured: ${config.agentName}\n'
          'Surface: $surface_id\n'
          'Automatic trigger: ${_describeTrigger(config.eventType)}\n'
          'Page agent root: /\n'
          'Manual refresh remains enabled via ${SystemEventTypes.dynamicSurfaceRefreshRequested}.',
        ),
      );
    },
  );
}

String _currentUserId() {
  final context = AgentCallToolContext.current;
  if (context == null) {
    throw StateError('Dynamic Surface tool must be called within an agent.');
  }
  final userId = context.state.metadata['userId'] as String?;
  if (userId == null) {
    throw StateError('Missing userId in agent metadata.');
  }
  return userId;
}

String _requiredString(Map args, String key) {
  final value = args[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw ArgumentError('Missing required string argument: $key');
}

String? _optionalString(Map args, String key) {
  final value = args[key];
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : value;
  }
  throw ArgumentError('Argument "$key" must be a string.');
}

String? _optionalTriggerEventType(Map args, String key) {
  if (!args.containsKey(key) || args[key] == null) return null;
  final value = args[key];
  if (value is String) {
    final trimmed = value.trim();
    return trimmed == _manualRefreshOnlyTriggerEventType ? '' : trimmed;
  }
  throw ArgumentError('Argument "$key" must be a string.');
}

Map _requiredMap(Map args, String key) {
  final value = args[key];
  if (value is Map) return value;
  throw ArgumentError('Missing required object argument: $key');
}

Map<String, dynamic> _normalizeSourceArgument(
  Map source, {
  required String workingDirectory,
}) {
  final sourceMap = Map<String, dynamic>.from(source);
  sourceMap['path'] = _workspaceRelativePathArgument(
    _requiredString(sourceMap, 'path'),
    workingDirectory: workingDirectory,
    argumentName: 'source.path',
    allowRoot: false,
  );
  return sourceMap;
}

String _workspaceRelativePathArgument(
  String value, {
  required String workingDirectory,
  required String argumentName,
  bool allowRoot = false,
}) {
  return AgentPathResolver.toRelative(
    value,
    workingDirectory: workingDirectory,
    allowRoot: allowRoot,
    argumentName: argumentName,
  );
}

Future<String> _resolveHtmlContent({
  required String workingDirectory,
  required String htmlFilePath,
}) async {
  AgentPathResolver.toRelative(
    htmlFilePath,
    workingDirectory: workingDirectory,
    allowRoot: false,
    argumentName: 'html_file_path',
  );
  final resolvedPath = AgentPathResolver.resolve(
    htmlFilePath,
    workingDirectory: workingDirectory,
  );
  final file = File(resolvedPath);
  if (!await file.exists()) {
    throw ArgumentError('HTML file not found: $htmlFilePath');
  }
  return file.readAsString();
}

Future<String> _resolveParserContent({
  required String workingDirectory,
  required String parserFilePath,
}) async {
  AgentPathResolver.toRelative(
    parserFilePath,
    workingDirectory: workingDirectory,
    allowRoot: false,
    argumentName: 'parser_file_path',
  );
  final resolvedPath = AgentPathResolver.resolve(
    parserFilePath,
    workingDirectory: workingDirectory,
  );
  final file = File(resolvedPath);
  if (!await file.exists()) {
    throw ArgumentError('Parser file not found: $parserFilePath');
  }
  if (!resolvedPath.toLowerCase().endsWith('.js')) {
    throw ArgumentError('parser_file_path must point to a .js file.');
  }
  return file.readAsString();
}

Future<String> _readIfExists(String absolutePath) async {
  final file = File(absolutePath);
  if (!await file.exists()) return '';
  return file.readAsString();
}

Future<Map<String, dynamic>> _readMarkdownSourceContext(
  String userId,
  DynamicSurfaceSource source,
  FileSystemService fileSystem,
) async {
  final workspacePath = fileSystem.getWorkspacePath(userId);
  final sourcePath = path.normalize(source.path);
  final resolved = path.normalize(path.join(workspacePath, sourcePath));
  if (source.isFile) {
    return {
      'type': 'file',
      'path': sourcePath,
      'content': _truncate(await _readIfExists(resolved), 20000),
    };
  }

  final dir = Directory(resolved);
  if (!await dir.exists()) {
    return {'type': 'directory', 'path': sourcePath, 'files': const []};
  }
  final files = <Map<String, dynamic>>[];
  await for (final entity in dir.list(
    recursive: source.recursive,
    followLinks: false,
  )) {
    if (entity is! File || !entity.path.endsWith('.md')) continue;
    final relative = path.relative(entity.path, from: workspacePath);
    files.add({
      'path': relative,
      'content_preview': _truncate(await entity.readAsString(), 4000),
    });
    if (files.length >= 10) break;
  }
  return {
    'type': 'directory',
    'path': sourcePath,
    'recursive': source.recursive,
    'files': files,
  };
}

Future<CustomAgentConfig?> _findPageAgentConfig(
  String userId,
  String surfaceId,
) async {
  final configs = await CustomAgentConfigService.instance.loadAll(userId);
  for (final config in configs) {
    if (config.managedSurfaceId == surfaceId) return config;
  }
  return null;
}

String _describeParserOutput(Object? data) {
  if (data is List) return 'array(${data.length})';
  if (data is Map) return 'object(${data.length} keys)';
  if (data == null) return 'null';
  if (data is String) return 'string(${data.length} chars)';
  if (data is num) return 'number';
  if (data is bool) return 'boolean';
  return data.runtimeType.toString();
}

String _previewJson(Object? data, int maxChars) {
  final encoded = const JsonEncoder.withIndent('  ').convert(data);
  return _truncate(encoded, maxChars);
}

String _describeTrigger(String eventType) {
  return eventType.trim().isEmpty ? 'manual refresh only' : eventType;
}

String _truncate(String value, int maxChars) {
  if (value.length <= maxChars) return value;
  return '${value.substring(0, maxChars)}\n...[truncated ${value.length - maxChars} chars]';
}
