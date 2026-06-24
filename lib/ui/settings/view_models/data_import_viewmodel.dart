import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/file_import_service.dart';
import 'package:memex/utils/result.dart';

typedef ImportFilePicker = Future<List<String>?> Function();

class ImportProcessingOptions {
  const ImportProcessingOptions({
    this.processKnowledgeBase = false,
    this.processTimelineCards = false,
  });

  final bool processKnowledgeBase;
  final bool processTimelineCards;

  bool get hasProcessing => processKnowledgeBase || processTimelineCards;

  ImportProcessingOptions copyWith({
    bool? processKnowledgeBase,
    bool? processTimelineCards,
  }) {
    return ImportProcessingOptions(
      processKnowledgeBase: processKnowledgeBase ?? this.processKnowledgeBase,
      processTimelineCards: processTimelineCards ?? this.processTimelineCards,
    );
  }
}

class DataImportViewModel extends ChangeNotifier {
  DataImportViewModel({
    required MemexRouter router,
    ImportFilePicker? pickFiles,
  })  : _router = router,
        _pickFiles = pickFiles ?? _defaultPickFiles;

  final MemexRouter _router;
  final ImportFilePicker _pickFiles;

  bool isImporting = false;
  bool isQueueingProcessing = false;
  String statusText = '';
  String? errorMessage;
  FileImportResult? lastImportResult;

  Future<FileImportResult?> pickAndImport() async {
    if (isImporting) return null;

    final paths = await _pickFiles();
    if (paths == null || paths.isEmpty) {
      return null;
    }

    isImporting = true;
    statusText = '';
    errorMessage = null;
    notifyListeners();

    final result = await _router.importFilesToUserSettingsImported(
      paths,
      onProgress: (status) {
        statusText = status;
        notifyListeners();
      },
    );

    return result.when(
      onOk: (value) {
        isImporting = false;
        statusText = '';
        lastImportResult = value;
        notifyListeners();
        return value;
      },
      onError: (error, _) {
        isImporting = false;
        statusText = '';
        errorMessage = error.toString();
        notifyListeners();
        return null;
      },
    );
  }

  Future<bool> startSuperAgentProcessing(
    FileImportResult result,
    ImportProcessingOptions options,
  ) async {
    if (!options.hasProcessing || isQueueingProcessing) {
      return false;
    }

    isQueueingProcessing = true;
    errorMessage = null;
    notifyListeners();

    try {
      final sessionId = await _latestSuperAgentSessionId();
      unawaited(
        _router
            .sendMessage(
              buildSuperAgentImportMessage(result, options),
              sessionId: sessionId,
              agentName: 'memex_agent',
              scene: 'super_agent_home',
              sceneId: 'import_files',
              refs: [
                {
                  'type': 'imported_files',
                  'title': 'Imported files: ${result.sourceName}',
                  'content': buildSuperAgentImportReference(result, options),
                },
              ],
              runMode: 'auto',
            )
            .drain<void>()
            .catchError((_) {}),
      );
      await Future<void>.delayed(Duration.zero);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isQueueingProcessing = false;
      notifyListeners();
    }
  }

  Future<String?> _latestSuperAgentSessionId() async {
    final result = await _router.fetchChatSessions(
      agentName: 'memex_agent',
      limit: 30,
    );
    return result.when(
      onOk: (sessions) {
        for (final session in sessions) {
          if (session['scene'] == 'super_agent_home') {
            return session['session_id']?.toString();
          }
        }
        return null;
      },
      onError: (_, __) => null,
    );
  }

  static Future<List<String>?> _defaultPickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: false,
      withReadStream: false,
    );
    if (result == null) return null;
    return result.files
        .map((file) => file.path)
        .whereType<String>()
        .where((path) => path.trim().isNotEmpty)
        .toList(growable: false);
  }
}

String buildSuperAgentImportReference(
  FileImportResult result,
  ImportProcessingOptions options,
) {
  final path = _workspacePathForAgent(result);
  final requested = _requestedProcessing(options);
  return [
    'Imported source folder: $path',
    'Source name: ${result.sourceName}',
    'Imported files: ${result.importedFileCount}',
    'Skipped unsafe archive entries: ${result.skippedUnsafeArchiveEntries}',
    'Requested processing: $requested',
  ].join('\n');
}

String buildSuperAgentImportMessage(
  FileImportResult result,
  ImportProcessingOptions options,
) {
  final path = _workspacePathForAgent(result);
  final requested = _requestedProcessing(options);
  final workerGuidance = _workerGuidance(options);

  return '''
I imported external files into my local Memex workspace.

Imported source folder: `$path`
Source name: `${result.sourceName}`
Imported files: ${result.importedFileCount}
Skipped unsafe archive entries: ${result.skippedUnsafeArchiveEntries}

Requested processing: $requested

Please inspect the imported source folder yourself before deciding what the data means. Do not move, delete, or rewrite the imported source folder unless I explicitly ask.

For non-plain-text documents, look for `<original filename>.extracted-text-for-agent.md` beside the original file. Use it as a reading aid, and treat the original file as the source of truth.

For image assets, look for `<original filename>.asset-reference-for-agent.md` beside the original file. It maps the imported image to a canonical Memex `fs://...` asset reference.

$workerGuidance

Important boundaries:
- If the imported folder is large, inspect and process it in chunks. Do not read every file or load all full file contents into one turn, because that can exceed the context window.
''';
}

String _workspacePathForAgent(FileImportResult result) {
  final normalized =
      result.workspaceRelativeDirectoryPath.replaceAll('\\', '/');
  return normalized.startsWith('/') ? normalized : '/$normalized';
}

String _requestedProcessing(ImportProcessingOptions options) {
  if (options.processKnowledgeBase && options.processTimelineCards) {
    return 'process into Timeline Cards and organize into the knowledge base';
  }
  if (options.processKnowledgeBase) {
    return 'organize useful information into the knowledge base only';
  }
  if (options.processTimelineCards) {
    return 'create Timeline Cards only';
  }
  return 'none';
}

String _workerGuidance(ImportProcessingOptions options) {
  if (options.processKnowledgeBase && options.processTimelineCards) {
    return '''
Plan the import as one coherent job. Create Timeline Cards for records worth preserving in the timeline, and organize useful imported information into the knowledge base.
Coordinate the two directions so PKM references real card fact_ids only when those cards exist.''';
  }

  if (options.processTimelineCards) {
    return '''
Focus only on records that should become Timeline Cards. Do not request PKM organization for this import.''';
  }

  if (options.processKnowledgeBase) {
    return '''
Focus only on knowledge-base organization. Do not create Timeline Cards unless you need to ask me first.''';
  }

  return 'No processing was requested.';
}
