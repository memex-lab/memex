import 'dart:convert';
import 'dart:io';

import 'package:memex/data/services/api_exception.dart';
import 'package:memex/data/services/dynamic_surface_parser_runner.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/dynamic_surface_model.dart';
import 'package:path/path.dart' as path;

class DynamicSurfaceService {
  DynamicSurfaceService({
    required FileSystemService fileSystemService,
    DynamicSurfaceParserRunner? parserRunner,
  })  : _fileSystemService = fileSystemService,
        _parserRunner = parserRunner ?? DynamicSurfaceParserRunner();

  final FileSystemService _fileSystemService;
  final DynamicSurfaceParserRunner _parserRunner;

  Future<List<DynamicSurfaceModel>> listSurfaces(String userId) async {
    final surfacesPath = _fileSystemService.getDynamicSurfacesPath(userId);
    final dir = Directory(surfacesPath);
    if (!await dir.exists()) {
      return const [];
    }

    final surfaces = <DynamicSurfaceModel>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final surfaceId = path.basename(entity.path);
      final surface = await getSurface(userId, surfaceId);
      if (surface != null) {
        surfaces.add(surface);
      }
    }
    surfaces.sort((a, b) => a.title.compareTo(b.title));
    return surfaces;
  }

  Future<DynamicSurfaceModel?> getSurface(
    String userId,
    String surfaceId,
  ) async {
    final manifest =
        await _fileSystemService.readDynamicSurfaceManifest(userId, surfaceId);
    if (manifest == null) {
      return null;
    }
    return DynamicSurfaceModel.fromJson(manifest);
  }

  Future<Object?> readSurfaceData(
    String userId,
    DynamicSurfaceModel surface,
  ) async {
    _validatePageOwnedSource(userId, surface.source);
    final files = await _readMarkdownFiles(userId, surface.source);
    final parserPath = _resolveSurfaceRelativePath(
      userId,
      surface.id,
      surface.parser.scriptPath,
      label: 'parser',
    );
    return _parserRunner.parse(
      scriptPath: parserPath,
      entry: surface.parser.entry,
      input: {
        'surface': surface.toJson(),
        'source': surface.source.toJson(),
        'files': files.map((file) => file.toJson()).toList(),
      },
    );
  }

  Future<DynamicSurfaceRenderResult> renderSurface(
    String userId,
    String surfaceId,
  ) async {
    final surface = await getSurface(userId, surfaceId);
    if (surface == null) {
      throw ApiException('Dynamic surface not found: $surfaceId');
    }

    final data = await readSurfaceData(userId, surface);
    final templatePath = _resolveSurfaceRelativePath(
      userId,
      surface.id,
      surface.render.templatePath,
      label: 'template',
    );
    final template = await File(templatePath).readAsString();
    final rendered = _renderTemplate(template, {
      'surface': surface.toJson(),
      'data': data,
      'memex_data_json': _jsonForScript(data),
    });

    final content = surface.render.type == 'html'
        ? await _fileSystemService.replaceFsInHtml(rendered, userId)
        : rendered;

    return DynamicSurfaceRenderResult(
      surface: surface,
      data: data,
      content: content,
      contentType: surface.render.type,
    );
  }

  Future<DynamicSurfaceValidationResult> validateSurface(
    String userId,
    String surfaceId,
  ) async {
    try {
      await renderSurface(userId, surfaceId);
      return DynamicSurfaceValidationResult.valid(surfaceId);
    } catch (e) {
      return DynamicSurfaceValidationResult.invalid(surfaceId, e.toString());
    }
  }

  Future<DynamicSurfaceRenderResult> installAuthoredSurface({
    required String userId,
    required String surfaceId,
    required String title,
    String? description,
    required DynamicSurfaceSource source,
    required DynamicSurfaceParserSpec parser,
    required String parserContent,
    required String htmlContent,
    String? markdownContent,
  }) async {
    _validateSurfaceId(surfaceId);
    if (title.trim().isEmpty) {
      throw ArgumentError('Dynamic surface title is required.');
    }
    if (htmlContent.trim().isEmpty) {
      throw ArgumentError('Dynamic surface HTML content is required.');
    }
    if (parserContent.trim().isEmpty) {
      throw ArgumentError('Dynamic surface parser content is required.');
    }
    _validatePageOwnedSource(userId, source);

    if (markdownContent != null) {
      if (!source.isFile) {
        throw ArgumentError(
          'markdownContent can only be written when source.type is file.',
        );
      }
      final markdownPath = _resolveWorkspaceRelativePath(userId, source.path);
      await File(markdownPath).parent.create(recursive: true);
      await File(markdownPath).writeAsString(markdownContent);
    }

    await _fileSystemService.writeDynamicSurfaceManifest(userId, surfaceId, {
      'id': surfaceId,
      'title': title,
      if (description != null && description.trim().isNotEmpty)
        'description': description,
      'source': source.toJson(),
      'parser': parser.toJson(),
      'render': {
        'type': 'html',
        'template_path': 'view.html',
      },
    });

    final surfacePath = _fileSystemService.getDynamicSurfacePath(
      userId,
      surfaceId,
    );
    await Directory(surfacePath).create(recursive: true);
    await File(path.join(surfacePath, 'view.html')).writeAsString(htmlContent);
    final parserFile = File(path.join(surfacePath, parser.scriptPath));
    await parserFile.parent.create(recursive: true);
    await parserFile.writeAsString(parserContent);

    return renderSurface(userId, surfaceId);
  }

  Future<DynamicSurfaceUninstallResult> uninstallSurface({
    required String userId,
    required String surfaceId,
    bool deleteSourceData = true,
    bool deleteDraft = true,
  }) async {
    _validateSurfaceId(surfaceId);
    final surface = await getSurface(userId, surfaceId);
    if (surface == null) {
      throw ApiException('Dynamic surface not found: $surfaceId');
    }

    String? deletedSourcePath;
    if (deleteSourceData) {
      _validatePageOwnedSource(userId, surface.source);
      final sourceDeletePath = _sourceDataPathForDeletion(userId, surface);
      if (await _deletePathIfExists(sourceDeletePath)) {
        deletedSourcePath = _workspaceRelativePath(userId, sourceDeletePath);
      }
    }

    final surfacePath = _fileSystemService.getDynamicSurfacePath(
      userId,
      surfaceId,
    );
    final deletedPackage = await _deletePathIfExists(surfacePath);

    var deletedDraft = false;
    if (deleteDraft) {
      final draftPath = path.join(
        _fileSystemService.getDynamicSurfaceDraftRootPath(userId),
        surfaceId,
      );
      deletedDraft = await _deletePathIfExists(draftPath);
    }

    return DynamicSurfaceUninstallResult(
      surfaceId: surfaceId,
      title: surface.title,
      deletedPackage: deletedPackage,
      deletedSourcePath: deletedSourcePath,
      deletedDraft: deletedDraft,
    );
  }

  /// Prompt fragment for agents that author free-form Dynamic Surfaces.
  String buildAuthoringGuide() {
    return '''
You may create a free-form Memex Dynamic Surface.

Hard contract:
- Write source Markdown under
  `/_UserSettings/DynamicSurfaceData/<surface_id>/`.
- Write parser.js. It must define `function parse(input)` and return a JSON
  serializable value.
- Memex calls parse with `{surface, source, files}`. Each file has
  `{path, name, content, updated_at, size_bytes}`.
- parser.js must not read files, use network APIs, import packages, or depend
  on an LLM at render time. Memex supplies all Markdown content through input.
- The parser output is the only data contract consumed by HTML.

Free surface:
- render.type may be html.
- render.template_path usually points to view.html inside the surface package.
- view.html can use HTML, CSS, and JavaScript.
- Memex injects the exact parser output through {{memex_data_json}}.
- Parser.js and view.html must agree on the JSON shape. Do not assume Memex
  wraps the output or extracts an item array.
- The page should render from injected JSON only; do not parse Markdown inside
  HTML and do not ask an LLM to populate lists or detail records.
''';
  }

  Future<List<_DynamicSurfaceMarkdownFile>> _readMarkdownFiles(
    String userId,
    DynamicSurfaceSource source,
  ) async {
    final sourcePath = _resolveWorkspaceRelativePath(userId, source.path);
    if (source.isFile) {
      return [await _readMarkdownFile(sourcePath, userId)];
    }

    final dir = Directory(sourcePath);
    if (!await dir.exists()) {
      throw ApiException(
        'Dynamic surface source directory not found: $sourcePath',
      );
    }

    final docs = <_DynamicSurfaceMarkdownFile>[];
    await for (final entity in dir.list(
      recursive: source.recursive,
      followLinks: false,
    )) {
      if (entity is! File || !entity.path.endsWith('.md')) {
        continue;
      }
      docs.add(await _readMarkdownFile(entity.path, userId));
    }
    docs.sort((a, b) => a.path.compareTo(b.path));
    return docs;
  }

  Future<_DynamicSurfaceMarkdownFile> _readMarkdownFile(
    String absolutePath,
    String userId,
  ) async {
    final file = File(absolutePath);
    final stat = await file.stat();
    final workspacePath = _fileSystemService.getWorkspacePath(userId);
    final relativePath = path.relative(absolutePath, from: workspacePath);
    return _DynamicSurfaceMarkdownFile(
      path: relativePath,
      name: path.basename(absolutePath),
      content: await file.readAsString(),
      updatedAt: stat.modified.toIso8601String(),
      sizeBytes: stat.size,
    );
  }

  String _resolveWorkspaceRelativePath(String userId, String relativePath) {
    final workspacePath = _fileSystemService.getWorkspacePath(userId);
    final resolved = path.normalize(path.join(workspacePath, relativePath));
    if (!_isUnderOrSame(resolved, workspacePath)) {
      throw ApiException(
        'Dynamic surface path escapes workspace: $relativePath',
      );
    }
    return resolved;
  }

  void _validatePageOwnedSource(
    String userId,
    DynamicSurfaceSource source,
  ) {
    final sourcePath = _resolveWorkspaceRelativePath(userId, source.path);
    final dataRoot = path
        .normalize(_fileSystemService.getDynamicSurfaceDataRootPath(userId));
    if (!_isUnderOrSame(sourcePath, dataRoot)) {
      throw ArgumentError(
        'Dynamic Surface source.path must be page-owned Markdown data under '
        '/_UserSettings/DynamicSurfaceData/<surface_id>.',
      );
    }
    final nativeRoots = [
      _fileSystemService.getFactsPath(userId),
      _fileSystemService.getPkmPath(userId),
      _fileSystemService.getCardsPath(userId),
      _fileSystemService.getKnowledgeInsightsPath(userId),
    ].map(path.normalize);
    if (nativeRoots.any((root) => _isUnderOrSame(sourcePath, root))) {
      throw ArgumentError(
        'Dynamic Surface source.path must be page-owned Markdown data under '
        '/_UserSettings/DynamicSurfaceData/<surface_id>, not a native Memex '
        'data directory.',
      );
    }
  }

  String _sourceDataPathForDeletion(
    String userId,
    DynamicSurfaceModel surface,
  ) {
    final sourcePath =
        _resolveWorkspaceRelativePath(userId, surface.source.path);
    final dataRoot = path
        .normalize(_fileSystemService.getDynamicSurfaceDataRootPath(userId));
    if (!_isUnderOrSame(sourcePath, dataRoot)) {
      throw ArgumentError(
        'Refusing to delete Dynamic Surface source outside DynamicSurfaceData: '
        '${surface.source.path}',
      );
    }

    final surfaceDataDir = path.normalize(path.join(dataRoot, surface.id));
    if (_isUnderOrSame(sourcePath, surfaceDataDir)) {
      return surfaceDataDir;
    }
    return sourcePath;
  }

  Future<bool> _deletePathIfExists(String targetPath) async {
    final file = File(targetPath);
    if (await file.exists()) {
      await file.delete();
      return true;
    }

    final dir = Directory(targetPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      return true;
    }
    return false;
  }

  String _workspaceRelativePath(String userId, String absolutePath) {
    return path.normalize(
      path.relative(absolutePath,
          from: _fileSystemService.getWorkspacePath(userId)),
    );
  }

  String _resolveSurfaceRelativePath(
    String userId,
    String surfaceId,
    String relativePath, {
    required String label,
  }) {
    final surfacePath =
        _fileSystemService.getDynamicSurfacePath(userId, surfaceId);
    final resolved = path.normalize(path.join(surfacePath, relativePath));
    if (!_isUnderOrSame(resolved, surfacePath)) {
      throw ApiException(
        'Dynamic surface $label escapes package: $relativePath',
      );
    }
    return resolved;
  }

  bool _isUnderOrSame(String child, String parent) {
    final relative = path.relative(child, from: parent);
    return relative == '.' || (!relative.startsWith('..') && relative != child);
  }

  void _validateSurfaceId(String surfaceId) {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(surfaceId)) {
      throw ArgumentError(
        'Dynamic surface id may only contain letters, numbers, "_" and "-".',
      );
    }
  }

  String _renderTemplate(String template, Map<String, dynamic> data) {
    return template.replaceAllMapped(
      RegExp(r'\{\{([\w.]+)\}\}'),
      (match) {
        final keyPath = match.group(1)!.split('.');
        dynamic value = data;
        for (final key in keyPath) {
          if (value is Map) {
            value = value[key];
          } else {
            value = null;
          }
          if (value == null) break;
        }
        if (value == null) return '';
        if (value is Map || value is List) return jsonEncode(value);
        return value.toString();
      },
    );
  }

  String _jsonForScript(Object? data) {
    return jsonEncode(data).replaceAll('</script>', '<\\/script>');
  }
}

class DynamicSurfaceValidationResult {
  const DynamicSurfaceValidationResult._({
    required this.surfaceId,
    required this.isValid,
    this.errorMessage,
  });

  factory DynamicSurfaceValidationResult.valid(String surfaceId) {
    return DynamicSurfaceValidationResult._(
      surfaceId: surfaceId,
      isValid: true,
    );
  }

  factory DynamicSurfaceValidationResult.invalid(
    String surfaceId,
    String errorMessage,
  ) {
    return DynamicSurfaceValidationResult._(
      surfaceId: surfaceId,
      isValid: false,
      errorMessage: errorMessage,
    );
  }

  final String surfaceId;
  final bool isValid;
  final String? errorMessage;
}

class DynamicSurfaceUninstallResult {
  const DynamicSurfaceUninstallResult({
    required this.surfaceId,
    required this.title,
    required this.deletedPackage,
    required this.deletedSourcePath,
    required this.deletedDraft,
  });

  final String surfaceId;
  final String title;
  final bool deletedPackage;
  final String? deletedSourcePath;
  final bool deletedDraft;
}

class _DynamicSurfaceMarkdownFile {
  final String path;
  final String name;
  final String content;
  final String updatedAt;
  final int sizeBytes;

  const _DynamicSurfaceMarkdownFile({
    required this.path,
    required this.name,
    required this.content,
    required this.updatedAt,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'content': content,
        'updated_at': updatedAt,
        'size_bytes': sizeBytes,
      };
}
