import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_path_resolver.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/skills/dynamic_surface/dynamic_surface_permissions.dart';
import 'package:memex/agent/skills/dynamic_surface/dynamic_surface_tool.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:path/path.dart' as p;

void main() {
  test('install tool can be constrained to one managed surface id', () {
    final tool = buildInstallDynamicSurfaceTool(
      managedSurfaceId: 'project_board',
    );

    final parameters = Map<String, dynamic>.from(tool.parameters as Map);
    final properties = Map<String, dynamic>.from(
      parameters['properties'] as Map,
    );

    expect(tool.name, 'install_dynamic_surface');
    expect(
      properties['surface_id']['description'] as String,
      contains('project_board'),
    );
    expect(parameters['required'], contains('surface_id'));
    expect(parameters['required'], contains('html_file_path'));
    expect(parameters['required'], contains('parser_file_path'));
    expect(tool.parameterMode, ToolParameterMode.object);
    expect(properties, contains('html_file_path'));
    expect(properties, contains('parser_file_path'));
    expect(properties, isNot(contains('html_content')));
    expect(properties, isNot(contains('data_spec')));
    expect(properties, contains('page_agent_trigger_event_type'));
    expect(
      properties['page_agent_trigger_event_type']['enum'],
      contains('manual_refresh_only'),
    );
    expect(
      properties['page_agent_trigger_event_type']['enum'],
      isNot(contains('')),
    );
    expect(
      properties['page_agent_trigger_event_type']['enum'],
      isNot(contains('data_changed')),
    );
    expect(properties, isNot(contains('page_agent_working_directory')));
    expect(properties, contains('page_agent_system_prompt'));
    expect(tool.description, contains('page-owned'));
    expect(tool.description, contains('Dynamic Surface data'));
    expect(tool.description, isNot(contains('Do not use /Facts, /PKM')));
    expect(
      properties['source']['properties']['path']['description'] as String,
      contains('page-owned Markdown data'),
    );
    expect(
      properties['source']['properties']['path']['description'] as String,
      isNot(contains('Do not use /Facts, /PKM')),
    );
  });

  test('authoring tools expose surface context and page-agent configuration',
      () {
    final uninstallTool = buildUninstallDynamicSurfaceTool();
    final contextTool = buildReadDynamicSurfaceContextTool();
    final configTool = buildConfigureDynamicSurfacePageAgentTool();

    expect(uninstallTool.name, 'uninstall_dynamic_surface');
    expect(contextTool.name, 'read_dynamic_surface_context');
    expect(configTool.name, 'configure_dynamic_surface_page_agent');

    final configParams =
        Map<String, dynamic>.from(configTool.parameters as Map);
    final configProperties = Map<String, dynamic>.from(
      configParams['properties'] as Map,
    );
    expect(configProperties, contains('trigger_event_type'));
    expect(
      configProperties['trigger_event_type']['enum'],
      contains('manual_refresh_only'),
    );
    expect(
      configProperties['trigger_event_type']['enum'],
      isNot(contains('')),
    );
    expect(
      configProperties['trigger_event_type']['enum'],
      isNot(contains('data_changed')),
    );
    expect(configProperties, isNot(contains('working_directory')));
    expect(configProperties, contains('system_prompt'));
  });

  test('agent path resolver maps agent absolute paths under working directory',
      () {
    final workingDirectory = p.normalize('/tmp/memex-workspace');

    expect(
      AgentPathResolver.resolve(
        '/PKM/Projects.md',
        workingDirectory: workingDirectory,
      ),
      p.join(workingDirectory, 'PKM/Projects.md'),
    );
    expect(
      AgentPathResolver.toRelative(
        '/_UserSettings/DynamicSurfaceDrafts/demo/view.html',
        workingDirectory: workingDirectory,
      ),
      p.normalize('_UserSettings/DynamicSurfaceDrafts/demo/view.html'),
    );
    expect(
      AgentPathResolver.toRelative(
        '/',
        workingDirectory: workingDirectory,
        allowRoot: true,
      ),
      '',
    );
    expect(
      () => AgentPathResolver.toRelative(
        '/',
        workingDirectory: workingDirectory,
      ),
      throwsArgumentError,
    );
  });

  test('managed surface write rules reject native sources and constrain writes',
      () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'memex_dynamic_surface_permissions_',
    );
    final fileSystem = FileSystemService.detached(dataRoot: tempDir.path);
    const userId = 'dynamic_surface_permissions_user';
    try {
      await fileSystem.writeDynamicSurfaceManifest(userId, 'daily_report', {
        'id': 'daily_report',
        'title': 'Daily Report',
        'source': {
          'type': 'directory',
          'path': 'Facts',
          'recursive': true,
        },
        'parser': {
          'type': 'javascript',
          'script_path': 'parser.js',
          'entry': 'parse',
        },
        'render': {
          'type': 'html',
          'template_path': 'view.html',
        },
      });

      expect(
        () => buildManagedDynamicSurfaceWriteRules(
          userId: userId,
          surfaceId: 'daily_report',
          fileSystemService: fileSystem,
        ),
        throwsArgumentError,
      );

      expect(
        () => rejectWorkspacePathUnderNativeSource(
          userId: userId,
          workspaceRelativePath: 'PKM/Projects/Launch.md',
          argumentName: 'source.path',
          fileSystemService: fileSystem,
        ),
        throwsArgumentError,
      );

      await fileSystem.writeDynamicSurfaceManifest(userId, 'project_board', {
        'id': 'project_board',
        'title': 'Project Board',
        'source': {
          'type': 'directory',
          'path': 'PKM/Projects',
          'recursive': true,
        },
        'parser': {
          'type': 'javascript',
          'script_path': 'parser.js',
          'entry': 'parse',
        },
        'render': {
          'type': 'html',
          'template_path': 'view.html',
        },
      });

      expect(
        () => buildManagedDynamicSurfaceWriteRules(
          userId: userId,
          surfaceId: 'project_board',
          fileSystemService: fileSystem,
        ),
        throwsArgumentError,
      );

      await fileSystem.writeDynamicSurfaceManifest(userId, 'reading_list', {
        'id': 'reading_list',
        'title': 'Reading List',
        'source': {
          'type': 'file',
          'path': '_UserSettings/DynamicSurfaceData/reading_list/data.md',
        },
        'parser': {
          'type': 'javascript',
          'script_path': 'parser.js',
          'entry': 'parse',
        },
        'render': {
          'type': 'html',
          'template_path': 'view.html',
        },
      });

      final fileRules = await buildManagedDynamicSurfaceWriteRules(
        userId: userId,
        surfaceId: 'reading_list',
        fileSystemService: fileSystem,
      );
      final fileManager = FilePermissionManager(
        userId,
        [
          PermissionRule(
            rootPath: fileSystem.getWorkspacePath(userId),
            access: FileAccessType.read,
          ),
          ...?fileRules,
        ],
        withDefaultRules: false,
      );
      final sourceFile = p.join(
        fileSystem.getWorkspacePath(userId),
        '_UserSettings',
        'DynamicSurfaceData',
        'reading_list',
        'data.md',
      );
      final siblingFile = p.join(
        fileSystem.getWorkspacePath(userId),
        '_UserSettings',
        'DynamicSurfaceData',
        'reading_list',
        'validate.js',
      );

      expect(
        () => fileManager.checkPermission(sourceFile, FileAccessType.write),
        returnsNormally,
      );
      expect(
        () => fileManager.checkPermission(siblingFile, FileAccessType.write),
        throwsA(isA<PermissionDeniedException>()),
      );
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
