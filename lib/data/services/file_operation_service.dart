import 'dart:io';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'api_exception.dart';
import 'base_file_service.dart';
import 'file_operation_utils.dart';

/// Callback signature for file change notifications.
/// [filePath] is the absolute path; [changeType] is 'created', 'modified', 'deleted', or 'moved'.
/// For 'moved', [oldFilePath] is the original path.
typedef FileChangedCallback = void Function(String filePath, String changeType,
    {String? oldFilePath});

/// File operation service: wraps server file ops; params and results match server.
class FileOperationService {
  static FileOperationService? _instance;
  static FileOperationService get instance {
    _instance ??= FileOperationService._();
    return _instance!;
  }

  final BaseFileService _baseService;
  final Logger _logger = getLogger('FileOperationService');

  /// Track ongoing operations per file to prevent concurrent writes
  final Map<String, Future<void>> _fileLocks = {};

  /// Optional callback invoked after successful write/edit/move/remove operations.
  FileChangedCallback? onFileChanged;

  FileOperationService._({BaseFileService? baseService})
      : _baseService = baseService ?? BaseFileService();

  @visibleForTesting
  FileOperationService.forTesting({BaseFileService? baseService})
      : _baseService = baseService ?? BaseFileService();

  /// Execute operation with file lock to prevent concurrent writes to the same file
  ///
  /// This method ensures that operations on the same file are serialized
  /// while operations on different files can still run in parallel.
  Future<T> _withFileLock<T>(
      String filePath, Future<T> Function() operation) async {
    final normalizedPath = path.normalize(path.absolute(filePath));

    // Wait for existing operation on this file
    while (_fileLocks.containsKey(normalizedPath)) {
      await _fileLocks[normalizedPath]!;
    }

    // Create new operation future
    final completer = Completer<void>();
    _fileLocks[normalizedPath] = completer.future;

    try {
      return await operation();
    } finally {
      completer.complete();
      _fileLocks.remove(normalizedPath);
    }
  }

  /// Resolves a path provided by the AI/User to a real system path.
  ///
  /// Logic:
  /// 1. If [workingDirectory] is null, return [pathStr] as is.
  /// 2. If [pathStr] starts with [workingDirectory], return [pathStr] as is (already resolved).
  /// 3. Otherwise, treat [pathStr] as relative to [workingDirectory].
  ///    - If [pathStr] starts with '/', strip it first.
  ///    - Join [workingDirectory] and the relative path.
  String _resolvePath(String pathStr, String? workingDirectory) {
    if (workingDirectory == null) {
      return pathStr;
    }
    if (pathStr.startsWith(workingDirectory)) {
      return pathStr;
    }

    if (pathStr.startsWith('/')) {
      if (pathStr == '/') return workingDirectory;
      return path.join(workingDirectory, pathStr.substring(1));
    }

    return pathStr;
  }

  /// Masks the [workingDirectory] in the result string with '/'.
  String _maskResult(String result, String? workingDirectory) {
    if (workingDirectory == null) {
      return result;
    }
    // Handle the case where workingDirectory does not end with a separator
    // to avoid double slashes (e.g. /path/to/dir/file -> //file)
    if (!workingDirectory.endsWith(path.separator) &&
        !workingDirectory.endsWith('/')) {
      result = result.replaceAll('$workingDirectory/', '/');
    }
    return result.replaceAll(workingDirectory, '/');
  }

  // ==================== Read ====================

  /// Read file content (maps to server Read). [filePath] must be absolute.
  /// [limit] null = to end or max 2000 lines. Returns text with line numbers (cat -n).
  Future<String> readFile({
    required String filePath,
    String? workingDirectory,
    int offset = 1,
    int? limit,
  }) async {
    // Resolve path first
    filePath = _resolvePath(filePath, workingDirectory);

    const maxLinesToRead = 2000;
    const maxLineLength = 2000;

    // Validate path is absolute
    if (!path.isAbsolute(filePath)) {
      throw ApiException('file_path must be an absolute path');
    }

    // Check path is under working directory
    if (workingDirectory != null &&
        !isUnderDirectory(filePath, workingDirectory)) {
      throw ApiException(
        _maskResult(
            'file_path $filePath is outside of the working directory $workingDirectory',
            workingDirectory),
      );
    }

    // Checkfilewhether exists
    if (!await _baseService.exists(filePath)) {
      throw ApiException(
          _maskResult('File $filePath does not exist', workingDirectory));
    }

    if (await _baseService.isDirectory(filePath)) {
      throw ApiException(_maskResult(
          '$filePath is a directory, not a file', workingDirectory));
    }

    // Read file content
    final content = await _baseService.readFile(filePath);

    if (content.isEmpty) {
      return '<system-reminder>File is empty</system-reminder>';
    }

    final lines = content.split('\n');
    final totalLines = lines.length;

    // Convert offset 1-based to 0-based
    final startIdx = (offset - 1).clamp(0, totalLines);

    // Determine end index
    final endIdx = limit != null
        ? (startIdx + limit).clamp(startIdx, totalLines)
        : (startIdx + maxLinesToRead).clamp(startIdx, totalLines);

    // Extract lines
    final selectedLines = lines.sublist(startIdx, endIdx);

    // Truncate long lines
    final truncatedLines = selectedLines.map((line) {
      if (line.length > maxLineLength) {
        return '${line.substring(0, maxLineLength)}...[truncated]';
      }
      return line;
    }).toList();

    final resultContent = truncatedLines.join('\n');

    // Add line numbers
    final numberedContent = addLineNumbers(resultContent, startLine: offset);

    // Check output size
    const maxOutputSize = 0.25 * 1024 * 1024; // 0.25MB
    if (numberedContent.length > maxOutputSize) {
      throw ApiException(
        'Output size (${numberedContent.length ~/ 1024}KB) exceeds maximum allowed size '
        '(${maxOutputSize ~/ 1024}KB). Please use offset and limit parameters to read specific portions.',
      );
    }

    return numberedContent;
  }

  // ==================== Write ====================

  /// Write file (maps to server Write). [filePath] must be absolute. Returns result message.
  Future<String> writeFile({
    required String filePath,
    String? workingDirectory,
    required String content,
  }) async {
    // Resolve path first
    filePath = _resolvePath(filePath, workingDirectory);

    return _withFileLock(filePath, () async {
      const maxLinesToRender = 16000;
      const truncatedMessage =
          '<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with Grep in order to find the line numbers of what you are looking for.</NOTE>';

      // Validate path is absolute
      if (!path.isAbsolute(filePath)) {
        throw ApiException('file_path must be an absolute path');
      }

      // Check under working directory
      if (workingDirectory != null &&
          !isUnderDirectory(filePath, workingDirectory)) {
        throw ApiException(
          _maskResult(
              'file_path $filePath is outside of the working directory $workingDirectory',
              workingDirectory),
        );
      }

      // Create vs update
      final fileExists = await _baseService.exists(filePath);
      final operation = fileExists ? 'update' : 'create';

      // Write file
      await _baseService.writeFile(filePath, content);

      // Notify file change
      onFileChanged?.call(
          filePath, operation == 'create' ? 'created' : 'modified');

      // Build result message
      if (operation == 'create') {
        return _maskResult(
            'File created successfully at: $filePath\n', workingDirectory);
      } else {
        final result = _maskResult(
            'The file $filePath has been updated. Here\'s the result of running `cat -n` on a snippet of the edited file:\n',
            workingDirectory);
        final lines = content.split('\n');
        final contentToShow = lines.length <= maxLinesToRender
            ? content
            : lines.sublist(0, maxLinesToRender).join('\n') + truncatedMessage;
        return result + addLineNumbers(contentToShow, startLine: 1);
      }
    });
  }

  // ==================== Edit ====================

  /// Edit file (maps to server Edit). [filePath] absolute; [oldString]/[newString] replace; [replaceAll] for all matches.
  Future<String> editFile({
    required String filePath,
    String? workingDirectory,
    required String oldString,
    required String newString,
    bool replaceAll = false,
  }) async {
    // Resolve path first
    filePath = _resolvePath(filePath, workingDirectory);

    return _withFileLock(filePath, () async {
      // Validate input
      if (oldString == newString) {
        throw ApiException(
            'old_string and new_string are identical. No changes to make.');
      }

      // Validate path is absolute
      if (!path.isAbsolute(filePath)) {
        throw ApiException('file_path must be an absolute path');
      }

      // Check under working directory
      if (workingDirectory != null &&
          !isUnderDirectory(filePath, workingDirectory)) {
        throw ApiException(
          _maskResult(
              'file_path $filePath is outside of the working directory $workingDirectory',
              workingDirectory),
        );
      }

      String originFileContent;

      // Handle create
      if (oldString.isEmpty) {
        if (await _baseService.exists(filePath)) {
          throw ApiException(
            _maskResult(
                'File $filePath already exists. Use Edit with a non-empty old_string to edit existing files.',
                workingDirectory),
          );
        }

        await _baseService.writeFile(filePath, newString);
        onFileChanged?.call(filePath, 'created');
        originFileContent = '';
      } else {
        // Handle edit
        if (!await _baseService.exists(filePath)) {
          throw ApiException(
            _maskResult(
                'File $filePath does not exist. Use an empty old_string to create a new file.',
                workingDirectory),
          );
        }

        // Read file
        final content = await _baseService.readFile(filePath);

        // Checkold_stringwhether exists
        if (!content.contains(oldString)) {
          throw ApiException(_maskResult(
              'old_string not found in file $filePath', workingDirectory));
        }

        // Checkmultiplematch
        final matches = oldString.allMatches(content).length;
        if (matches > 1 && !replaceAll) {
          throw ApiException(
            'old_string appears $matches times in the file. '
            'Please include more context to uniquely identify the instance to change or set replace_all to true.',
          );
        }

        // Apply edit
        final updatedContent = replaceAll
            ? content.replaceAll(oldString, newString)
            : content.replaceFirst(oldString, newString);

        if (updatedContent == content) {
          throw ApiException(
              'Failed to apply edit. Original and edited file match exactly.');
        }

        await _baseService.writeFile(filePath, updatedContent);
        onFileChanged?.call(filePath, 'modified');
        originFileContent = content;
      }

      // Build snippet info (for update only)
      String result;
      if (oldString.isEmpty) {
        result =
            '''The file ${_maskResult(filePath, workingDirectory)} has been updated. Here's the result of running `cat -n` on a snippet of the edited file:
${addLineNumbers(newString, startLine: 1)}''';
      } else {
        final snippetInfo = _getSnippet(
          initialText: originFileContent,
          oldStr: oldString,
          newStr: newString,
        );

        final snippet = snippetInfo['snippet'] as String;
        final startLine = snippetInfo['start_line'] as int;

        result =
            '''The file ${_maskResult(filePath, workingDirectory)} has been updated. Here's the result of running `cat -n` on a snippet of the edited file:
${addLineNumbers(snippet, startLine: startLine)}''';
      }

      return result;
    });
  }

  /// Get edit snippet helper (maps to server get_snippet)
  Map<String, dynamic> _getSnippet({
    required String initialText,
    required String oldStr,
    required String newStr,
  }) {
    const nLinesSnippet = 4;

    final before =
        initialText.contains(oldStr) ? initialText.split(oldStr)[0] : '';
    final replacementLine = before.split('\n').length - 1;
    final newFileLines = initialText.replaceAll(oldStr, newStr).split('\n');

    // Compute snippet start/end line numbers
    final startLine =
        (replacementLine - nLinesSnippet).clamp(0, newFileLines.length);
    final endLine =
        (replacementLine + nLinesSnippet + newStr.split('\n').length)
            .clamp(startLine, newFileLines.length);

    // Get snippet
    final snippetLines = newFileLines.sublist(
      startLine,
      (endLine + 1).clamp(startLine, newFileLines.length),
    );
    final snippet = snippetLines.join('\n');

    return {
      'snippet': snippet,
      'start_line': startLine + 1,
    };
  }

  // ==================== Move ====================

  /// Move/rename file or directory (maps to server Move). Paths must be absolute.
  Future<String> moveFile({
    required String sourcePath,
    required String destinationPath,
    String? workingDirectory,
    bool overwrite = false,
  }) async {
    // Resolve paths first
    sourcePath = _resolvePath(sourcePath, workingDirectory);
    destinationPath = _resolvePath(destinationPath, workingDirectory);

    // Lock both source and destination to prevent concurrent conflicts
    return _withFileLock(sourcePath, () async {
      return _withFileLock(destinationPath, () async {
        // Validate paths are absolute
        if (!path.isAbsolute(sourcePath)) {
          throw ApiException('source_path must be an absolute path');
        }

        if (!path.isAbsolute(destinationPath)) {
          throw ApiException('destination_path must be an absolute path');
        }

        // Check source under working directory
        if (workingDirectory != null &&
            !isUnderDirectory(sourcePath, workingDirectory)) {
          throw ApiException(
            _maskResult(
                'source_path $sourcePath is outside of the working directory $workingDirectory',
                workingDirectory),
          );
        }

        // Check destination under working directory
        if (workingDirectory != null &&
            !isUnderDirectory(destinationPath, workingDirectory)) {
          throw ApiException(
            _maskResult(
                'destination_path $destinationPath is outside of the working directory $workingDirectory',
                workingDirectory),
          );
        }

        // Checksource pathwhether exists
        if (!await _baseService.exists(sourcePath)) {
          throw ApiException(_maskResult(
              'Source path $sourcePath does not exist', workingDirectory));
        }

        // Determine operation type
        final isDirectory = await _baseService.isDirectory(sourcePath);
        final operationType = isDirectory ? 'directory' : 'file';

        // Resolve destination (Unix mv semantics)
        String actualDestination = destinationPath;

        if (await _baseService.exists(destinationPath)) {
          if (await _baseService.isDirectory(destinationPath)) {
            // If dest is dir, move source into it
            final sourceName = path.basename(sourcePath);
            actualDestination = path.join(destinationPath, sourceName);

            // Check actual target under working directory
            if (workingDirectory != null &&
                !isUnderDirectory(actualDestination, workingDirectory)) {
              throw ApiException(
                _maskResult(
                    'actual_destination $actualDestination is outside of the working directory $workingDirectory',
                    workingDirectory),
              );
            }

            // Check if final target already exists in target dir
            if (await _baseService.exists(actualDestination)) {
              if (!overwrite) {
                throw ApiException(
                  _maskResult(
                      'Destination $actualDestination already exists inside directory $destinationPath. '
                      'Set overwrite=true to replace it.',
                      workingDirectory),
                );
              } else {
                // Remove existing file/dir
                await _baseService.remove(actualDestination, recursive: true);
              }
            }
          } else {
            // Target is file; check overwrite
            if (!overwrite) {
              throw ApiException(
                _maskResult(
                    'Destination path $destinationPath already exists. '
                    'Set overwrite=true to replace it.',
                    workingDirectory),
              );
            } else {
              await _baseService.remove(destinationPath);
            }
          }
        } else {
          // Target missing, create parent dir
          final destParent = path.dirname(destinationPath);
          if (destParent.isNotEmpty) {
            final parentDir = Directory(destParent);
            if (!await parentDir.exists()) {
              await parentDir.create(recursive: true);
            }
          }
        }

        // Perform move
        await _baseService.move(
          sourcePath,
          actualDestination,
          overwrite: overwrite,
        );

        // Notify file change
        onFileChanged?.call(actualDestination, 'moved',
            oldFilePath: sourcePath);

        // Rename vs move
        final sourceParent = path.dirname(sourcePath);
        final destParent = path.dirname(actualDestination);

        if (sourceParent == destParent) {
          return _maskResult(
              'Successfully renamed $operationType from:\n  $sourcePath\nto:\n  $actualDestination',
              workingDirectory);
        } else {
          return _maskResult(
              'Successfully moved $operationType from:\n  $sourcePath\nto:\n  $actualDestination',
              workingDirectory);
        }
      });
    });
  }

  // ==================== Remove ====================

  /// Remove file or directory (maps to server Remove). [confirm] must be true.
  Future<String> removeFile({
    required String filePath,
    String? workingDirectory,
    required bool confirm,
  }) async {
    // Resolve path first
    filePath = _resolvePath(filePath, workingDirectory);

    return _withFileLock(filePath, () async {
      // Check confirmation
      if (!confirm) {
        throw ApiException(
          'Removal not confirmed. You must set confirm=true to proceed with removal. '
          'This is a safety measure to prevent accidental removals.',
        );
      }

      // Validate path is absolute
      if (!path.isAbsolute(filePath)) {
        throw ApiException('path must be an absolute path');
      }

      // Check under working directory
      if (workingDirectory != null &&
          !isUnderDirectory(filePath, workingDirectory)) {
        throw ApiException(
          _maskResult(
              'path $filePath is outside of the working directory $workingDirectory',
              workingDirectory),
        );
      }

      if (!await _baseService.exists(filePath)) {
        throw ApiException(
            _maskResult('Path $filePath does not exist', workingDirectory));
      }

      final isDirectory = await _baseService.isDirectory(filePath);
      final operationType = isDirectory ? 'directory' : 'file';

      // executedelete
      await _baseService.remove(filePath, recursive: true);

      // Notify file change
      onFileChanged?.call(filePath, 'deleted');

      return _maskResult(
          'Successfully removed $operationType: $filePath\n', workingDirectory);
    });
  }

  // ==================== LS ====================

  /// List directory (maps to server LS). [dirPath] absolute; [ignore] glob patterns. Returns formatted tree.
  Future<String> listDirectory({
    required String dirPath,
    String? workingDirectory,
    List<String>? ignore,
    int? depth,
    bool Function(String path)? filter,
  }) async {
    // Resolve path first
    dirPath = _resolvePath(dirPath, workingDirectory);

    const maxFiles = 1000;

    // Validate path is absolute
    if (!path.isAbsolute(dirPath)) {
      throw ApiException('path must be an absolute path');
    }

    // Check under working directory
    if (workingDirectory != null &&
        !isUnderDirectory(dirPath, workingDirectory)) {
      throw ApiException(
        _maskResult(
            'path $dirPath is outside of the working directory $workingDirectory',
            workingDirectory),
      );
    }

    if (!await _baseService.exists(dirPath)) {
      throw ApiException(
          _maskResult('Directory $dirPath does not exist', workingDirectory));
    }

    if (!await _baseService.isDirectory(dirPath)) {
      throw ApiException(
          _maskResult('$dirPath is not a directory', workingDirectory));
    }

    // Check filter on root
    if (filter != null && !filter(dirPath)) {
      // Root is filtered out
      return _maskResult('', workingDirectory);
    }

    // List directory recursively
    final resultList = await _listDirectoryRecursive(
      maxFiles,
      dirPath,
      dirPath,
      ignore ?? [],
      depth: depth,
      filter: filter,
    );
    resultList.sort();

    // Build tree
    final tree = buildTree(resultList);
    final treeStr = printTree(tree, dirPath);

    // return result
    if (resultList.isEmpty) {
      return _maskResult(
          '<system-reminder>Directory is empty</system-reminder>',
          workingDirectory);
    } else if (resultList.length < maxFiles) {
      return _maskResult(treeStr, workingDirectory);
    } else {
      final truncationMsg =
          '\nThere are more than $maxFiles files in the directory. '
          'Use the LS tool (passing a specific path), and other tools to explore nested directories. '
          'The first $maxFiles files and directories are included below:\n\n';
      return _maskResult(truncationMsg + treeStr, workingDirectory);
    }
  }

  /// list recursivelydirectory（maps to server list_directory）
  Future<List<String>> _listDirectoryRecursive(
    int maxFiles,
    String initialPath,
    String cwd,
    List<String> ignore, {
    int? depth,
    bool Function(String path)? filter,
  }) async {
    final results = <String>[];
    // Queue stores pairs of (path, current_depth)
    final queue = <MapEntry<String, int>>[MapEntry(initialPath, 0)];

    while (queue.isNotEmpty && results.length <= maxFiles) {
      final currentEntry = queue.removeAt(0);
      final currentPath = currentEntry.key;
      final currentDepth = currentEntry.value;

      // Check depth limit if specified (depth >= 0)
      if (depth != null && depth >= 0 && currentDepth > depth) {
        continue;
      }

      // Skip hidden dirs, common excludes, user ignore patterns
      if (_shouldSkip(currentPath, cwd, ignore)) {
        continue;
      }

      // Check custom filter
      if (filter != null && !filter(currentPath)) {
        continue;
      }

      // Add to result (except initial path itself)
      if (currentPath != initialPath) {
        final relPath = path.relative(currentPath, from: cwd);
        if (await _baseService.isDirectory(currentPath)) {
          results.add('$relPath${path.separator}');
        } else {
          results.add(relPath);
        }
      }

      // Depth limit: do not traverse subdirs
      if (depth != null && depth >= 0 && currentDepth >= depth) {
        continue;
      }

      // If directory, add children to queue
      if (await _baseService.isDirectory(currentPath)) {
        try {
          final children = await _baseService.listDirectory(
            currentPath,
            recursive: false,
            includeHidden: false,
          );

          for (final child in children) {
            final childPath =
                path.isAbsolute(child) ? child : path.join(currentPath, child);
            // Add children with depth + 1
            if (await _baseService.isDirectory(childPath)) {
              queue.add(MapEntry(childPath, currentDepth + 1));
            } else {
              // Files are also at depth + 1 relative to current directory
              // But we only add them if we haven't exceeded depth limit for files?
              // Usually depth 1 means: list contents of root (depth 0).
              // So root(0) -> child_file(1). If depth=1, we verify 1 <= 1. OK.
              // If depth=0, we only see root.

              if (depth == null || depth < 0 || (currentDepth + 1) <= depth) {
                if (!_shouldSkip(childPath, cwd, ignore)) {
                  // Check custom filter for child (file)
                  if (filter != null && !filter(childPath)) {
                    continue;
                  }
                  final relPath = path.relative(childPath, from: cwd);
                  results.add(relPath);
                }
              }
            }
          }
        } catch (e) {
          // Skip unreadable directory
          _logger.warning('Cannot read directory $currentPath: $e');
        }
      }
    }

    return results;
  }

  /// Check if path should be skipped (maps to server should_skip)
  bool _shouldSkip(String pathStr, String cwd, List<String> ignore) {
    final basename = path.basename(pathStr);

    // Skip hidden files/dirs (except root cwd)
    try {
      final absCwd = path.absolute(cwd);
      final absPath = path.absolute(pathStr);
      if (absPath != absCwd && basename.startsWith('.')) {
        return true;
      }
    } catch (e) {
      // If parse fails, continue
    }

    // Skip __pycache__
    if (pathStr.contains('__pycache__')) {
      return true;
    }

    // skip node_modules
    if (pathStr.contains('node_modules')) {
      return true;
    }

    // Honor ignore glob (match relative posix path and basename)
    if (ignore.isNotEmpty) {
      try {
        final rel = path.relative(pathStr, from: cwd);
        final relPosix = rel.replaceAll(path.separator, '/');
        for (final pattern in ignore) {
          if (pattern.isEmpty) continue;
          final pat = pattern.replaceAll(path.separator, '/');
          if (_fnmatch(relPosix, pat)) return true;
          if (_fnmatch(basename, pat)) return true;
        }
      } catch (e) {}
    }

    return false;
  }

  /// Simple glob match (maps to Python fnmatch). Supports * and ?.
  bool _fnmatch(String name, String pattern) {
    final regexPattern = pattern
        .replaceAllMapped(
          RegExp(r'[.+^${}()|[\]\\]'),
          (match) => '\\${match.group(0)}',
        )
        .replaceAll('?', '.')
        .replaceAll('*', '.*');
    final regex = RegExp('^$regexPattern\$');
    return regex.hasMatch(name);
  }

  // ==================== Glob ====================

  /// File pattern match (maps to server Glob). [pattern] e.g. "**/*.md". Returns matching paths (newline-sep, by mtime).
  Future<String> globFiles({
    required String pattern,
    String? searchPath,
    String? workingDirectory,
    bool Function(String path)? filter,
  }) async {
    // Resolve search path
    if (searchPath != null) {
      searchPath = _resolvePath(searchPath, workingDirectory);
    }

    // Pattern might also need resolution if it's an absolute path (virtual)
    if (pattern.startsWith('/')) {
      pattern = _resolvePath(pattern, workingDirectory);
    }

    final actualSearchPath = searchPath ?? workingDirectory;
    if (actualSearchPath == null) {
      throw ApiException(
          'search_path and working_directory cannot both be null');
    }
    // actualSearchPath is non-null here
    final searchPathStr = actualSearchPath;

    if (!path.isAbsolute(searchPathStr)) {
      throw ApiException('path must be an absolute path');
    }

    // Check under working directory
    if (workingDirectory != null &&
        !isUnderDirectory(searchPathStr, workingDirectory)) {
      throw ApiException(_maskResult(
          'path $searchPathStr is outside of the working directory $workingDirectory',
          workingDirectory));
    }

    if (!await _baseService.exists(searchPathStr)) {
      throw ApiException(_maskResult(
          'Directory $searchPathStr does not exist', workingDirectory));
    }

    if (!await _baseService.isDirectory(searchPathStr)) {
      throw ApiException(
          _maskResult('$searchPathStr is not a directory', workingDirectory));
    }

    // Convert glob to regex
    final regexPattern = _globToRegex(pattern);
    final regex = RegExp(regexPattern);

    // If pattern starts with **/, also match by basename (for current dir files)
    RegExp? basenameRegex;
    if (pattern.startsWith('**/')) {
      final basenamePattern = pattern.substring(3); // strip '**/'
      final basenameRegexPattern = _globToRegex(basenamePattern);
      basenameRegex = RegExp(basenameRegexPattern);
    }

    // Recursively search files
    final matchingFiles = <String>[];
    await _globSearchRecursive(
      searchPathStr,
      searchPathStr,
      regex,
      matchingFiles,
      basenameRegex: basenameRegex,
      filter: filter,
    );

    // Sort by modification time (newest first)
    final filesWithTime = await Future.wait(
      matchingFiles.map((file) async {
        try {
          final mtime = await _baseService.getModificationTime(file);
          return MapEntry(file, mtime);
        } catch (e) {
          return MapEntry(file, DateTime.fromMillisecondsSinceEpoch(0));
        }
      }),
    );

    filesWithTime.sort((a, b) => b.value.compareTo(a.value));
    final sortedFiles = filesWithTime.map((e) => e.key).toList();

    // Limit result count
    const limit = 100;
    final truncated = sortedFiles.length > limit;
    final limitedFiles = sortedFiles.length > limit
        ? sortedFiles.sublist(0, limit)
        : sortedFiles;

    if (limitedFiles.isEmpty) {
      return 'No files found';
    } else {
      final result = limitedFiles.join('\n');
      if (truncated) {
        return _maskResult(
            '$result\n(Results are truncated. Consider using a more specific path or pattern.)',
            workingDirectory);
      }
      return _maskResult(result, workingDirectory);
    }
  }

  /// Recursively search files matching glob pattern
  Future<void> _globSearchRecursive(
    String rootPath,
    String currentPath,
    RegExp patternRegex,
    List<String> results, {
    RegExp? basenameRegex,
    bool Function(String path)? filter,
  }) async {
    try {
      final dir = Directory(currentPath);
      await for (final entity in dir.list(recursive: false)) {
        final stat = await entity.stat();

        if (stat.type == FileSystemEntityType.directory) {
          // Check custom filter for directory
          if (filter != null && !filter(entity.path)) {
            continue;
          }
          // Skip hidden directories
          final name = path.basename(entity.path);
          if (!name.startsWith('.')) {
            await _globSearchRecursive(
                rootPath, entity.path, patternRegex, results,
                basenameRegex: basenameRegex, filter: filter);
          }
        } else if (stat.type == FileSystemEntityType.file) {
          // Check custom filter for file
          if (filter != null && !filter(entity.path)) {
            continue;
          }
          // Skip hidden files
          final name = path.basename(entity.path);
          if (name.startsWith('.')) {
            continue;
          }

          // Relative path for glob match
          final relativePath = path.relative(entity.path, from: rootPath);
          final posixPath = relativePath.replaceAll(path.separator, '/');

          bool matchesPattern = patternRegex.hasMatch(posixPath);
          // If basenameRegex (e.g. **/*.x), also match by basename
          if (!matchesPattern && basenameRegex != null) {
            final basename = path.basename(entity.path);
            matchesPattern = basenameRegex.hasMatch(basename);
          }

          if (matchesPattern) {
            results.add(entity.path);
          }
        }
      }
    } catch (e) {
      _logger.warning('Cannot access directory $currentPath: $e');
    }
  }

  /// Convert glob pattern to regex. * = any except /; ** = any including /
  String _globToRegex(String globPattern) {
    // Escape special chars except * and ?
    String regex = globPattern.replaceAllMapped(
      RegExp(r'[.+^${}()|[\]\\]'),
      (match) => '\\${match.group(0)}',
    );

    // Use placeholders for ** patterns to avoid corruption by later * and ? replacements.
    regex = regex.replaceAll('**/', '\x00STARSTAR_SLASH\x00');
    regex = regex.replaceAll('/**', '\x00SLASH_STARSTAR\x00');
    regex = regex.replaceAll(RegExp(r'\*\*'), '\x00STARSTAR\x00');

    // Single glob wildcards: ? = one non-slash char, * = zero or more non-slash chars.
    regex = regex.replaceAll('?', '[^/]');
    regex = regex.replaceAll('*', '[^/]*');

    // Restore ** placeholders to their regex equivalents.
    regex = regex.replaceAll('\x00STARSTAR_SLASH\x00', '(?:[^/]+/)*');
    regex = regex.replaceAll('\x00SLASH_STARSTAR\x00', '(?:/[^/]+)*');
    regex = regex.replaceAll('\x00STARSTAR\x00', '.*');

    return '^$regex\$';
  }

  // ==================== Grep ====================

  /// Search in files (maps to server Grep). Returns search result.
  Future<String> grepFiles({
    required String pattern,
    String? searchPath,
    String? workingDirectory,
    String? include,
    String outputMode = 'files_with_matches',
    int? B,
    int? A,
    int? C,
    bool n = false,
    bool i = true,
    String? type,
    int? headLimit,
    bool multiline = false,
    bool r = true,
    bool Function(String path)? filter,
  }) async {
    // Resolve search path
    if (searchPath != null) {
      searchPath = _resolvePath(searchPath, workingDirectory);
    }

    final actualSearchPath = searchPath ?? workingDirectory;
    if (actualSearchPath == null) {
      throw ApiException(
          'search_path and working_directory cannot both be null');
    }
    // actualSearchPath is non-null here
    final searchPathStr = actualSearchPath;

    if (!path.isAbsolute(searchPathStr)) {
      throw ApiException('path must be an absolute path');
    }

    // Check under working directory
    if (workingDirectory != null &&
        !isUnderDirectory(searchPathStr, workingDirectory)) {
      throw ApiException(_maskResult(
          'path $searchPathStr is outside of the working directory $workingDirectory',
          workingDirectory));
    }

    if (!await _baseService.exists(searchPathStr)) {
      throw ApiException(
          _maskResult('path $searchPathStr does not exist', workingDirectory));
    }

    RegExp regex;
    try {
      regex = RegExp(
        pattern,
        multiLine: multiline,
        caseSensitive: !i,
        dotAll: multiline,
      );
    } catch (e) {
      throw ApiException(
          _maskResult('Invalid regex pattern: $e', workingDirectory));
    }

    // buildfiletypefiltermap
    final typeExtensions = _getFileTypeExtensions(type);

    String result;
    switch (outputMode) {
      case 'files_with_matches':
        result = await _grepFilesWithMatches(
          searchPathStr,
          regex,
          include,
          typeExtensions,
          headLimit,
          r: r,
          filter: filter,
        );
        break;
      case 'content':
        result = await _grepContent(
          searchPathStr,
          regex,
          include,
          typeExtensions,
          B,
          A,
          C,
          n,
          headLimit,
          r: r,
          filter: filter,
        );
        break;
      case 'count':
        result = await _grepCount(
          searchPathStr,
          regex,
          include,
          typeExtensions,
          headLimit,
          r: r,
          filter: filter,
        );
        break;
      default:
        throw ApiException(
            _maskResult('Invalid output mode: $outputMode', workingDirectory));
    }

    return _maskResult(result, workingDirectory);
  }

  /// Files with matches (files_with_matches mode)
  Future<String> _grepFilesWithMatches(String searchPath, RegExp pattern,
      String? includeGlob, Set<String>? typeExtensions, int? headLimit,
      {bool r = true, bool Function(String path)? filter}) async {
    final matchingFiles = <String>[];

    await _grepWalkFiles(
      searchPath,
      pattern,
      includeGlob,
      typeExtensions,
      (filePath, lines) async {
        for (final line in lines) {
          if (pattern.hasMatch(line)) {
            matchingFiles.add(filePath);
            return false;
          }
        }
        return false;
      },
      r: r,
      filter: filter,
    );

    // Sort by modification time (newest first)
    final filesWithTime = await Future.wait(
      matchingFiles.map((file) async {
        try {
          final mtime = await _baseService.getModificationTime(file);
          return MapEntry(file, mtime);
        } catch (e) {
          return MapEntry(file, DateTime.fromMillisecondsSinceEpoch(0));
        }
      }),
    );

    filesWithTime.sort((a, b) => b.value.compareTo(a.value));
    var sortedFiles = filesWithTime.map((e) => e.key).toList();

    const maxResults = 100;
    final truncated = sortedFiles.length > maxResults;
    sortedFiles = sortedFiles.take(maxResults).toList();

    if (headLimit != null && headLimit > 0) {
      sortedFiles = sortedFiles.take(headLimit).toList();
    }

    if (sortedFiles.isEmpty) {
      return 'No files found';
    } else {
      final result =
          'Found ${sortedFiles.length} file${sortedFiles.length > 1 ? 's' : ''}\n${sortedFiles.join('\n')}';
      if (truncated && headLimit == null) {
        return '$result\n(Results are truncated. Consider using a more specific path or pattern.)';
      }
      return result;
    }
  }

  /// Grep content (content mode)
  Future<String> _grepContent(
      String searchPath,
      RegExp pattern,
      String? includeGlob,
      Set<String>? typeExtensions,
      int? B,
      int? A,
      int? C,
      bool showLineNumbers,
      int? headLimit,
      {bool r = true,
      bool Function(String path)? filter}) async {
    final outputLines = <String>[];
    final contextBefore = C ?? B ?? 0;
    final contextAfter = C ?? A ?? 0;

    await _grepWalkFiles(
      searchPath,
      pattern,
      includeGlob,
      typeExtensions,
      (filePath, lines) async {
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (pattern.hasMatch(line)) {
            // Context lines before
            final startIdx = (i - contextBefore).clamp(0, lines.length);
            for (int j = startIdx; j < i; j++) {
              if (headLimit != null && outputLines.length >= headLimit) {
                break;
              }
              final filePrefix = '$filePath:';
              final linePrefix = showLineNumbers ? '${j + 1}-' : '';
              outputLines.add('$filePrefix$linePrefix${lines[j]}');
            }

            // Match line
            if (headLimit != null && outputLines.length >= headLimit) {
              break;
            }
            final filePrefix = '$filePath:';
            final linePrefix = showLineNumbers ? '${i + 1}:' : '';
            outputLines.add('$filePrefix$linePrefix$line');

            // Context lines after
            final endIdx = (i + 1 + contextAfter).clamp(i + 1, lines.length);
            for (int j = i + 1; j < endIdx; j++) {
              if (headLimit != null && outputLines.length >= headLimit) {
                break;
              }
              final filePrefix = '$filePath:';
              final linePrefix = showLineNumbers ? '${j + 1}-' : '';
              outputLines.add('$filePrefix$linePrefix${lines[j]}');
            }
          }
        }
        return false;
      },
      r: r,
      filter: filter,
    );

    if (headLimit != null && headLimit > 0) {
      outputLines.removeRange(headLimit, outputLines.length);
    }

    if (outputLines.isEmpty) {
      return 'No matches found';
    } else {
      final result = outputLines.join('\n');
      if (headLimit != null && outputLines.length >= headLimit) {
        return '$result\n(Output limited to first $headLimit lines)';
      }
      return result;
    }
  }

  /// Grep count (count mode)
  Future<String> _grepCount(String searchPath, RegExp pattern,
      String? includeGlob, Set<String>? typeExtensions, int? headLimit,
      {bool r = true, bool Function(String path)? filter}) async {
    final countResults = <String>[];

    await _grepWalkFiles(
      searchPath,
      pattern,
      includeGlob,
      typeExtensions,
      (filePath, lines) async {
        int count = 0;
        for (final line in lines) {
          if (pattern.hasMatch(line)) {
            count++;
          }
        }
        if (count > 0) {
          countResults.add('$filePath:$count');
        }
        return false;
      },
      r: r,
      filter: filter,
    );

    if (headLimit != null && headLimit > 0) {
      countResults.removeRange(headLimit, countResults.length);
    }

    if (countResults.isEmpty) {
      return 'No matches found';
    } else {
      final result = countResults.join('\n');
      if (headLimit != null && countResults.length >= headLimit) {
        return '$result\n(Output limited to first $headLimit entries)';
      }
      return result;
    }
  }

  /// Walk files and run search callback
  Future<void> _grepWalkFiles(
      String searchPath,
      RegExp pattern,
      String? includeGlob,
      Set<String>? typeExtensions,
      Future<bool> Function(String filePath, List<String> lines) callback,
      {bool r = true,
      bool Function(String path)? filter}) async {
    if (await _baseService.isFile(searchPath)) {
      if (filter != null && !filter(searchPath)) {
        return;
      }
      final fileName = path.basename(searchPath);

      if (includeGlob != null) {
        final globRegex = RegExp(_globToRegex(includeGlob));
        if (!globRegex.hasMatch(fileName)) {
          return;
        }
      }

      if (typeExtensions != null) {
        final ext = path.extension(fileName).toLowerCase();
        if (ext.isNotEmpty && !typeExtensions.contains(ext.substring(1))) {
          return;
        }
      }

      try {
        final content = await _baseService.readFile(searchPath);
        final lines = content.split('\n');
        await callback(searchPath, lines);
      } catch (e) {
        return;
      }
      return;
    }

    await _grepWalkFilesRecursive(
      searchPath,
      searchPath,
      pattern,
      includeGlob,
      typeExtensions,
      callback,
      r: r,
      filter: filter,
    );
  }

  /// Recursively walk files and run search callback
  Future<void> _grepWalkFilesRecursive(
      String rootPath,
      String currentPath,
      RegExp pattern,
      String? includeGlob,
      Set<String>? typeExtensions,
      Future<bool> Function(String filePath, List<String> lines) callback,
      {bool r = true,
      bool Function(String path)? filter}) async {
    try {
      final dir = Directory(currentPath);
      await for (final entity in dir.list(recursive: false)) {
        try {
          final stat = await entity.stat();

          if (stat.type == FileSystemEntityType.directory) {
            if (filter != null && !filter(entity.path)) {
              continue;
            }
            final dirName = path.basename(entity.path);
            if (!dirName.startsWith('.') && r) {
              await _grepWalkFilesRecursive(
                rootPath,
                entity.path,
                pattern,
                includeGlob,
                typeExtensions,
                callback,
                r: r,
                filter: filter,
              );
            }
            continue;
          }

          if (stat.type != FileSystemEntityType.file) {
            continue;
          }

          final filePath = entity.path;
          if (filter != null && !filter(filePath)) {
            continue;
          }
          final fileName = path.basename(filePath);

          // Skip hidden files
          if (fileName.startsWith('.')) {
            continue;
          }

          if (includeGlob != null) {
            final relativePath = path.relative(filePath, from: rootPath);
            final posixPath = relativePath.replaceAll(path.separator, '/');
            final globRegex = RegExp(_globToRegex(includeGlob));
            if (!globRegex.hasMatch(posixPath) &&
                !globRegex.hasMatch(fileName)) {
              continue;
            }
          }

          if (typeExtensions != null) {
            final ext = path.extension(fileName).toLowerCase();
            if (ext.isNotEmpty && !typeExtensions.contains(ext.substring(1))) {
              continue;
            }
          }

          try {
            final content = await _baseService.readFile(filePath);
            final lines = content.split('\n');

            final shouldStop = await callback(filePath, lines);
            if (shouldStop) {
              return;
            }
          } catch (e) {
            continue;
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      _logger.warning('Cannot access directory $currentPath: $e');
    }
  }

  /// Get file type -> extension set (maps to ripgrep --type)
  Set<String>? _getFileTypeExtensions(String? type) {
    if (type == null) {
      return null;
    }
    const typeMap = {
      'js': ['js', 'jsx', 'mjs', 'cjs'],
      'py': ['py', 'pyw', 'pyi'],
      'rust': ['rs'],
      'go': ['go'],
      'java': ['java'],
      'md': ['md', 'markdown'],
      'txt': ['txt'],
      'json': ['json'],
      'yaml': ['yaml', 'yml'],
      'xml': ['xml'],
      'html': ['html', 'htm'],
      'css': ['css'],
      'ts': ['ts', 'tsx'],
      'sh': ['sh', 'bash'],
      'c': ['c', 'h'],
      'cpp': ['cpp', 'cxx', 'cc', 'hpp'],
    };

    final extensions = typeMap[type.toLowerCase()];
    if (extensions == null) {
      return {type.toLowerCase()}; // unknown type: use name as extension
    }
    return extensions.toSet();
  }
}
