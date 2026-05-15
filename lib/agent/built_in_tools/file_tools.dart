import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/data/services/file_operation_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:path/path.dart' as p;

// Helper to access services
final _fileOpService = FileOperationService.instance;
final _fileSystem = FileSystemService.instance;

class FileToolFactory {
  final FilePermissionManager permissionManager;
  final String workingDirectory;

  FileToolFactory({
    required this.permissionManager,
    required this.workingDirectory,
  });

  String _resolvePath(String pathStr) {
    if (pathStr.startsWith(workingDirectory)) {
      return pathStr;
    }
    if (pathStr.startsWith('/')) {
      if (pathStr == '/') return workingDirectory;
      return p.join(workingDirectory, pathStr.substring(1));
    }
    return p.join(workingDirectory, pathStr);
  }

  Tool buildReadTool() {
    return Tool(
      name: 'Read',
      description: Prompts.fileToolReadDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'file_path': {
            'type': 'string',
            'description': 'The absolute path to the file to read'
          },
          'offset': {
            'type': 'integer',
            'description': 'The line number to start reading from (1-indexed)'
          },
          'limit': {
            'type': 'integer',
            'description': 'The number of lines to read'
          },
        },
        'required': ['file_path']
      },
      executable: (String file_path, int? offset, int? limit) {
        file_path = _resolvePath(file_path);
        permissionManager.checkPermission(file_path, FileAccessType.read);
        return _fileOpService.readFile(
          filePath: file_path,
          workingDirectory: workingDirectory,
          offset: offset ?? 1,
          limit: limit,
        );
      },
    );
  }

  Tool buildBatchReadTool() {
    return Tool(
      name: 'BatchRead',
      description: Prompts.fileToolBatchReadDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'file_patterns': {
            'type': 'array',
            'items': {'type': 'string'},
            'description':
                'List of absolute file paths or glob patterns to read'
          }
        },
        'required': ['file_patterns']
      },
      executable: (List<String> file_patterns) async {
        final uniqueFilePaths = <String>{};

        for (final pattern in file_patterns) {
          // Simple check for glob wildcards
          if (pattern.contains('*') ||
              pattern.contains('?') ||
              pattern.contains('[') ||
              pattern.contains('{')) {
            try {
              // Glob expansion creates paths, we need to check read permission for the result
              // But we can't check permission on the pattern itself easily without expanding first.
              // So execute glob, then filter results based on permission.
              final result = await _fileOpService.globFiles(
                pattern: pattern,
                workingDirectory: workingDirectory,
                filter: (p) => permissionManager.allowsRead(p),
              );
              // Handle globFiles result (may be "file not found" or include truncation hint)
              final fileNotFound = Prompts.fileToolBatchReadFileNotFound;
              final resultTruncated = Prompts.fileToolBatchReadResultTruncated;

              if (!result.startsWith(fileNotFound)) {
                final lines = result.split('\n');
                for (final line in lines) {
                  // Filter empty lines and truncation hint
                  if (line.trim().isNotEmpty &&
                      !line.startsWith(resultTruncated)) {
                    final rawPath = line.trim();
                    final path = _resolvePath(rawPath);
                    try {
                      if (permissionManager.allowsRead(path)) {
                        uniqueFilePaths.add(path);
                      }
                    } catch (_) {
                      // Silently ignore files we don't have permission to read
                    }
                  }
                }
              }
            } catch (e) {
              // Ignore error for this pattern, continue with others
            }
          } else {
            // Treat as direct file path
            try {
              final path = _resolvePath(pattern);
              if (permissionManager.allowsRead(path)) {
                uniqueFilePaths.add(path);
              }
            } catch (_) {
              // Ignore
            }
          }
        }

        if (uniqueFilePaths.isEmpty) {
          return Prompts.fileToolBatchReadNoFilesFound;
        }

        final buffer = StringBuffer();
        var filesReadCount = 0;

        for (final filePath in uniqueFilePaths) {
          buffer.writeln('=' * 20 + ' File: $filePath ' + '=' * 20);
          try {
            // Double check just in case, though we checked above
            permissionManager.checkPermission(filePath, FileAccessType.read);
            final content = await _fileOpService.readFile(
              filePath: filePath,
              workingDirectory: workingDirectory,
            );
            buffer.writeln(content);
            filesReadCount++;
          } catch (e) {
            buffer.writeln(Prompts.fileToolBatchReadFileError(e.toString()));
          }
          buffer.writeln(); // blank line between files
        }

        if (filesReadCount == 0) {
          return Prompts.fileToolBatchReadAllFailed(uniqueFilePaths.length);
        }

        return buffer.toString();
      },
    );
  }

  Tool buildWriteTool() {
    return Tool(
      name: 'Write',
      description: Prompts.fileToolWriteDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'file_path': {
            'type': 'string',
            'description':
                'The absolute path to the file to write (must be absolute, not relative)'
          },
          'content': {
            'type': 'string',
            'description': 'The content to write to the file'
          },
        },
        'required': ['file_path', 'content']
      },
      executable: (String file_path, String content) async {
        file_path = _resolvePath(file_path);
        permissionManager.checkPermission(file_path, FileAccessType.write);
        final result = await _fileOpService.writeFile(
          filePath: file_path,
          workingDirectory: workingDirectory,
          content: content,
        );

        // Log event
        try {
          final context = AgentCallToolContext.current!;
          final userId = context.state.metadata['userId'] as String?;
          final agentName = context.agent.name;
          if (userId != null) {
            final workspacePath = _fileSystem.getWorkspacePath(userId);
            final relativePath =
                _fileSystem.toRelativePath(file_path, rootPath: workspacePath);
            final isCreate = result.contains('File created successfully');
            if (isCreate) {
              await _fileSystem.eventLogService.logFileCreated(
                userId: userId,
                filePath: relativePath,
                description: 'Agent[$agentName] created file via Write tool',
              );
            } else {
              await _fileSystem.eventLogService.logFileModified(
                userId: userId,
                filePath: relativePath,
                description: 'Agent[$agentName] modified file via Write tool',
              );
            }
          }
        } catch (e) {
          // Event logging failure should not break tool
        }

        return result;
      },
    );
  }

  Tool buildEditTool() {
    return Tool(
      name: 'Edit',
      description: Prompts.fileToolEditDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'file_path': {
            'type': 'string',
            'description': 'The absolute path to the file to modify'
          },
          'old_string': {
            'type': 'string',
            'description':
                'The exact literal text to replace, preferably unescaped. For single replacements (default), include at least 3 lines of context BEFORE and AFTER the target text, matching whitespace and indentation precisely. If this string is not the exact literal text (i.e. you escaped it) or does not match exactly, the tool will fail.'
          },
          'new_string': {
            'type': 'string',
            'description':
                'The exact literal text to replace `old_string` with, preferably unescaped. Provide the EXACT text.'
          },
          'replace_all': {
            'type': 'boolean',
            'description':
                'Replace all occurences of old_string (default false)'
          },
        },
        'required': ['file_path', 'old_string', 'new_string']
      },
      executable: (String file_path, String old_string, String new_string,
          bool? replace_all) async {
        file_path = _resolvePath(file_path);
        permissionManager.checkPermission(file_path, FileAccessType.write);
        final result = await _fileOpService.editFile(
          filePath: file_path,
          workingDirectory: workingDirectory,
          oldString: old_string,
          newString: new_string,
          replaceAll: replace_all ?? false,
        );

        // Log event
        try {
          final userId =
              AgentCallToolContext.current?.state.metadata['userId'] as String?;
          if (userId != null) {
            final workspacePath = _fileSystem.getWorkspacePath(userId);
            final relativePath =
                _fileSystem.toRelativePath(file_path, rootPath: workspacePath);
            await _fileSystem.eventLogService.logFileModified(
              userId: userId,
              filePath: relativePath,
              description: 'Agent edited file via Edit tool',
            );
          }
        } catch (e) {
          // Event logging failure should not break tool
        }

        return result;
      },
    );
  }

  Tool buildMoveTool() {
    return Tool(
      name: 'Move',
      description: Prompts.fileToolMoveDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'source_path': {
            'type': 'string',
            'description': 'The absolute path to the file or directory to move'
          },
          'destination_path': {
            'type': 'string',
            'description': 'The absolute path to the destination location'
          },
          'overwrite': {
            'type': 'boolean',
            'description':
                'Whether to overwrite if destination exists (default false)'
          },
        },
        'required': ['source_path', 'destination_path']
      },
      executable:
          (String source_path, String destination_path, bool? overwrite) {
        // Must have Write Access to BOTH source (to delete it) and destination (to create it)
        source_path = _resolvePath(source_path);
        destination_path = _resolvePath(destination_path);
        permissionManager.checkPermission(source_path, FileAccessType.write);
        permissionManager.checkPermission(
            destination_path, FileAccessType.write);

        return _fileOpService.moveFile(
          sourcePath: source_path,
          destinationPath: destination_path,
          workingDirectory: workingDirectory,
          overwrite: overwrite ?? false,
        );
      },
    );
  }

  Tool buildRemoveTool() {
    return Tool(
      name: 'Remove',
      description: Prompts.fileToolRemoveDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description':
                'The absolute path to the file or directory to remove'
          },
          'confirm': {
            'type': 'boolean',
            'description': 'Must be set to true to confirm the removal'
          },
        },
        'required': ['path', 'confirm']
      },
      executable: (String path, bool confirm) async {
        path = _resolvePath(path);
        permissionManager.checkPermission(path, FileAccessType.write);
        final result = await _fileOpService.removeFile(
          filePath: path,
          workingDirectory: workingDirectory,
          confirm: confirm,
        );

        // Log event
        try {
          final userId =
              AgentCallToolContext.current?.state.metadata['userId'] as String?;
          if (userId != null) {
            final workspacePath = _fileSystem.getWorkspacePath(userId);
            final relativePath =
                _fileSystem.toRelativePath(path, rootPath: workspacePath);
            await _fileSystem.eventLogService.logFileDeleted(
              userId: userId,
              filePath: relativePath,
              description: 'Agent deleted file via Remove tool',
            );
          }
        } catch (e) {
          // Event logging failure should not break tool
        }

        return result;
      },
    );
  }

  Tool buildLSTool() {
    return Tool(
      name: 'LS',
      description: Prompts.fileToolLsDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description':
                'The absolute path to the directory to list (must be absolute, not relative)'
          },
          'ignore': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'List of glob patterns to ignore'
          },
          'depth': {
            'type': 'integer',
            'description': 'Depth to list files and directories, default is 3'
          },
        },
        'required': ['path']
      },
      executable: (String path, List? ignore, int? depth) {
        path = _resolvePath(path);
        permissionManager.checkPermission(path, FileAccessType.read);
        return _fileOpService.listDirectory(
          dirPath: path,
          workingDirectory: workingDirectory,
          ignore: ignore?.cast<String>(),
          depth: depth ?? 3,
          filter: (p) => permissionManager.allowsRead(p),
        );
      },
    );
  }

  Tool buildGlobTool() {
    return Tool(
      name: 'Glob',
      description: Prompts.fileToolGlobDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'pattern': {
            'type': 'string',
            'description': 'The glob pattern to match files against'
          },
          'path': {
            'type': 'string',
            'description':
                'The directory to search in. If not specified, the current working directory will be used. IMPORTANT: Omit this field to use the default directory. DO NOT enter "undefined" or "null" - simply omit it for the default behavior. Must be a valid directory path if provided.'
          },
        },
        'required': ['pattern']
      },
      executable: (String pattern, String? path) {
        if (path != null) {
          path = _resolvePath(path);
          permissionManager.checkPermission(path, FileAccessType.read);
        } else {
          permissionManager.checkPermission(
              workingDirectory, FileAccessType.read);
        }
        return _fileOpService.globFiles(
          pattern: pattern,
          searchPath: path,
          workingDirectory: workingDirectory,
          filter: (p) => permissionManager.allowsRead(p),
        );
      },
    );
  }

  Tool buildGrepTool() {
    return Tool(
      name: 'Grep',
      description: Prompts.fileToolGrepDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'pattern': {
            'type': 'string',
            'description':
                'The regular expression pattern to search for in file contents'
          },
          'path': {
            'type': 'string',
            'description':
                'File or directory to search in (rg PATH). Defaults to the root directory of the current working directory.'
          },
          'include': {
            'type': 'string',
            'description':
                'Glob pattern to filter files (e.g. "*.js", "*.{ts,tsx}") - maps to rg --glob'
          },
          'output_mode': {
            'type': 'string',
            'description':
                'Output mode: "content" shows matching lines (supports -A/-B/-C context, -n line numbers, head_limit), "files_with_matches" shows file paths (supports head_limit), "count" shows match counts (supports head_limit). Defaults to "files_with_matches".'
          },
          'B': {
            'type': 'integer',
            'description':
                'Number of lines to show before each match (rg -B). Requires output_mode: "content", ignored otherwise.'
          },
          'A': {
            'type': 'integer',
            'description':
                'Number of lines to show after each match (rg -A). Requires output_mode: "content", ignored otherwise.'
          },
          'C': {
            'type': 'integer',
            'description':
                'Number of lines to show before and after each match (rg -C). Requires output_mode: "content", ignored otherwise.'
          },
          'n': {
            'type': 'boolean',
            'description':
                'Show line numbers in output (rg -n). Requires output_mode: "content", ignored otherwise.'
          },
          'i': {
            'type': 'boolean',
            'description': 'Case insensitive search (rg -i)'
          },
          'type': {
            'type': 'string',
            'description':
                'File type to search (rg --type). Common types: js, py, rust, go, java, etc. More efficient than include for standard file types.'
          },
          'head_limit': {
            'type': 'integer',
            'description':
                'Limit output to first N lines/entries, equivalent to "| head -N". Works across all output modes: content (limits output lines), files_with_matches (limits file paths), count (limits count entries). When unspecified, shows all results from ripgrep.'
          },
          'multiline': {
            'type': 'boolean',
            'description':
                'Enable multiline mode where . matches newlines and patterns can span lines (rg -U --multiline-dotall). Default: false.'
          },
        },
        'required': ['pattern']
      },
      executable: (String pattern,
          String? path,
          String? include,
          String? output_mode,
          int? B,
          int? A,
          int? C,
          bool? n,
          bool? i,
          String? type,
          int? head_limit,
          bool? multiline) {
        // Check permission for the search path
        final searchPath = _resolvePath(path ?? workingDirectory);
        permissionManager.checkPermission(searchPath, FileAccessType.read);

        return _fileOpService.grepFiles(
          pattern: pattern,
          searchPath: path,
          workingDirectory: workingDirectory,
          include: include,
          outputMode: output_mode ?? 'files_with_matches',
          n: n ?? false,
          i: i ?? true,
          B: B,
          A: A,
          C: C,
          type: type,
          headLimit: head_limit,
          multiline: multiline ?? false,
          accessScope: permissionManager.buildSearchAccessScope(searchPath),
        );
      },
    );
  }
}
