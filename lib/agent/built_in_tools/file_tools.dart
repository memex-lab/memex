// ignore_for_file: non_constant_identifier_names

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/super_agent/pending_tool_image_buffer.dart';
import 'package:memex/data/services/agent_image_attachment.dart';
import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/data/services/api_exception.dart';
import 'package:memex/data/services/file_operation_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/image_exif_context.dart';
import 'package:path/path.dart' as p;

// Helper to access services
final _fileOpService = FileOperationService.instance;
FileSystemService get _fileSystem => FileSystemService.instance;

typedef ViewImageExifInfoBuilder = Future<String?> Function(
  String userId,
  String imagePath,
);

class FileToolFactory {
  final FilePermissionManager permissionManager;
  final String workingDirectory;
  final ViewImageExifInfoBuilder _viewImageExifInfoBuilder;

  FileToolFactory({
    required this.permissionManager,
    required this.workingDirectory,
    ViewImageExifInfoBuilder? viewImageExifInfoBuilder,
  }) : _viewImageExifInfoBuilder =
            viewImageExifInfoBuilder ?? buildImageExifInfo;

  static const _viewImageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.heic',
    '.heif',
    '.tiff',
    '.tif',
  };

  static String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${bytes}B';
  }

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

  /// Resolve the image argument for `view_image`.
  ///
  /// Accepts `fs://<filename>` references (the canonical form used in card
  /// media and in-text attachments), mapping them to the asset pool at
  /// `Facts/assets/<filename>` under the working directory. Other forms fall
  /// back to [_resolvePath] for backward compatibility.
  String _resolveImagePath(String pathStr) {
    if (pathStr.startsWith('fs://')) {
      final filename = pathStr.substring(5);
      return p.join(workingDirectory, 'Facts', 'assets', filename);
    }
    return _resolvePath(pathStr);
  }

  Tool buildViewImageTool() {
    return Tool(
      name: 'view_image',
      description: 'View a local image file. '
          'Use this when you need to view an image that is not already in your '
          'context. Provide the image by its `fs://<filename>` reference (the '
          'same form used in card media and in-text attachments).',
      parameters: {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description':
                'The image to view, given as its `fs://<filename>` reference (for example fs://img_20260612_ts_0_no_1_800x600.jpg).',
          },
        },
        'required': ['path'],
      },
      executable: (String path) async {
        final imagePath = _resolveImagePath(path);

        final extension = p.extension(imagePath).toLowerCase();
        if (!_viewImageExtensions.contains(extension)) {
          throw ArgumentError('Unsupported image type: $extension');
        }

        final originalSize = await _fileOpService.validateReadableFile(
          filePath: imagePath,
          workingDirectory: workingDirectory,
        );

        final safety = await AssetSafetyService.instance.inspectFile(imagePath);
        if (!safety.safeForAnalysis) {
          return 'Image was not attached: ${safety.analysisSkipText(p.basename(imagePath))}';
        }

        final inlineImage = await inlineImageForLlm(
          absolutePath: imagePath,
          fallbackMimeType: mimeTypeForImagePath(imagePath),
          logLabel: _displayPath(imagePath),
        );
        if (inlineImage == null || inlineImage.base64Data.isEmpty) {
          throw Exception('Image compression failed.');
        }

        final sessionId = AgentCallToolContext.current?.state.sessionId ?? '';
        final userId =
            AgentCallToolContext.current?.state.metadata['userId'] as String?;
        String? exifInfo;
        if (userId != null && userId.isNotEmpty) {
          exifInfo = await _viewImageExifInfoBuilder(userId, imagePath);
        }

        final message = StringBuffer()
          ..writeln(
            'Image loaded from `${_displayPath(imagePath)}`. Inspect it now.',
          );
        if (exifInfo != null && exifInfo.isNotEmpty) {
          message
            ..writeln()
            ..write(exifInfo);
        }

        PendingToolImageBuffer.instance.add(
          sessionId,
          ImagePart(inlineImage.base64Data, inlineImage.mimeType),
          message: message.toString(),
        );

        return 'Image attached to the next message (${_formatBytes(originalSize)}).'
            '${exifInfo == null || exifInfo.isEmpty ? '' : ' EXIF metadata is included.'}';
      },
    );
  }

  String _displayPath(String absolutePath) {
    if (absolutePath.startsWith(workingDirectory)) {
      final relative = p.relative(absolutePath, from: workingDirectory);
      return relative == '.' ? '/' : '/$relative';
    }
    return absolutePath;
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
        if (!permissionManager.allowsRead(file_path)) {
          throw ApiException('File ${_displayPath(file_path)} does not exist');
        }
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
          buffer.writeln(
              '${'=' * 20} File: ${_displayPath(filePath)} ${'=' * 20}');
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
        final denied = await gateMutatingToolCall(
          toolName: 'Write',
          summary: file_path,
          details: {'size': '${content.length} chars'},
        );
        if (denied != null) return denied;
        final result = await _fileOpService.writeFile(
          filePath: file_path,
          workingDirectory: workingDirectory,
          content: content,
        );

        String? artifactPath;
        var artifactIsUpdate = false;

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
            artifactPath = relativePath;
            artifactIsUpdate = !isCreate;
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

        if (artifactPath == null) return result;
        return AgentToolResult(
          content: TextPart(result),
          metadata: {
            'artifact': {
              'type': 'file',
              'path': artifactPath,
              'updated': artifactIsUpdate,
              'snippet': content.length > 160
                  ? '${content.substring(0, 160)}…'
                  : content,
            },
          },
        );
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
        final denied = await gateMutatingToolCall(
          toolName: 'Edit',
          summary: file_path,
        );
        if (denied != null) return denied;
        final result = await _fileOpService.editFile(
          filePath: file_path,
          workingDirectory: workingDirectory,
          oldString: old_string,
          newString: new_string,
          replaceAll: replace_all ?? false,
        );

        String? artifactPath;

        // Log event
        try {
          final userId =
              AgentCallToolContext.current?.state.metadata['userId'] as String?;
          if (userId != null) {
            final workspacePath = _fileSystem.getWorkspacePath(userId);
            final relativePath =
                _fileSystem.toRelativePath(file_path, rootPath: workspacePath);
            artifactPath = relativePath;
            await _fileSystem.eventLogService.logFileModified(
              userId: userId,
              filePath: relativePath,
              description: 'Agent edited file via Edit tool',
            );
          }
        } catch (e) {
          // Event logging failure should not break tool
        }

        if (artifactPath == null) return result;
        return AgentToolResult(
          content: TextPart(result),
          metadata: {
            'artifact': {
              'type': 'file',
              'path': artifactPath,
              'updated': true,
              'snippet': new_string.length > 160
                  ? '${new_string.substring(0, 160)}…'
                  : new_string,
            },
          },
        );
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
          (String source_path, String destination_path, bool? overwrite) async {
        // Must have Write Access to BOTH source (to delete it) and destination (to create it)
        source_path = _resolvePath(source_path);
        destination_path = _resolvePath(destination_path);
        permissionManager.checkPermission(source_path, FileAccessType.write);
        permissionManager.checkPermission(
            destination_path, FileAccessType.write);
        final denied = await gateMutatingToolCall(
          toolName: 'Move',
          summary: '$source_path → $destination_path',
        );
        if (denied != null) return denied;

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
        final denied = await gateMutatingToolCall(
          toolName: 'Remove',
          summary: path,
        );
        if (denied != null) return denied;
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
        },
        'required': ['path']
      },
      executable: (String path, List? ignore) {
        path = _resolvePath(path);
        if (!permissionManager.canTraverseForRead(path)) {
          throw ApiException(
            'Directory ${_displayPath(path)} does not exist',
          );
        }
        return _fileOpService.listDirectory(
          dirPath: path,
          workingDirectory: workingDirectory,
          ignore: ignore?.cast<String>(),
          depth: 1,
          filter: (p) => permissionManager.allowsRead(p),
          traversalFilter: (p) => permissionManager.canTraverseForRead(p),
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
        final searchRoot = path != null ? _resolvePath(path) : workingDirectory;
        if (!permissionManager.canTraverseForRead(searchRoot)) {
          if (path != null) {
            throw ApiException(
              'Directory ${_displayPath(searchRoot)} does not exist',
            );
          }
          return 'No files found';
        }
        if (path != null) {
          path = _resolvePath(path);
        }
        return _fileOpService.globFiles(
          pattern: pattern,
          searchPath: path,
          workingDirectory: workingDirectory,
          filter: (p) => permissionManager.allowsRead(p),
          traversalFilter: (p) => permissionManager.canTraverseForRead(p),
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
        final searchPath = _resolvePath(path ?? workingDirectory);
        if (!permissionManager.canTraverseForRead(searchPath)) {
          if (path != null) {
            throw ApiException(
              'path ${_displayPath(searchPath)} does not exist',
            );
          }
          return output_mode == 'files_with_matches' || output_mode == null
              ? 'No files found'
              : 'No matches found';
        }

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
