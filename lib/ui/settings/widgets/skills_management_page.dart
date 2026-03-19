import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

/// Skills directory browser & downloader.
/// Root is `_UserSettings/skills/` under the user workspace.
class SkillsManagementPage extends StatefulWidget {
  const SkillsManagementPage({super.key});

  @override
  State<SkillsManagementPage> createState() => _SkillsManagementPageState();
}

class _SkillsManagementPageState extends State<SkillsManagementPage> {
  final List<String> _pathStack = [];
  List<FileSystemEntity> _entries = [];
  bool _isLoading = true;
  String? _skillsRoot;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return;
    final settingsPath = FileSystemService.instance.getUserSettingsPath(userId);
    final root = path.join(settingsPath, 'skills');
    final dir = Directory(root);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _skillsRoot = root;
    _pathStack.add(root);
    await _loadEntries();
  }

  String get _currentDir => _pathStack.last;

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final dir = Directory(_currentDir);
      final list = await dir.list().toList();
      list.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir != bIsDir) return aIsDir ? -1 : 1;
        return path.basename(a.path).compareTo(path.basename(b.path));
      });
      if (mounted) {
        setState(() {
          _entries = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _entries = [];
          _isLoading = false;
        });
      }
    }
  }

  void _enterDirectory(String dirPath) {
    _pathStack.add(dirPath);
    _loadEntries();
  }

  bool get _canGoBack => _pathStack.length > 1;

  void _goBack() {
    if (!_canGoBack) return;
    _pathStack.removeLast();
    _loadEntries();
  }

  String get _displayPath {
    if (_skillsRoot == null) return '';
    final rel = path.relative(_currentDir, from: _skillsRoot!);
    return rel == '.' ? '/' : '/$rel';
  }

  // ── Delete ──────────────────────────────────────────────────────────────

  Future<void> _deleteEntry(FileSystemEntity entity) async {
    final l10n = UserStorage.l10n;
    final name = path.basename(entity.path);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirm),
        content: Text(l10n.deleteConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteConfirm,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await entity.delete(recursive: true);
      if (mounted) {
        ToastHelper.showSuccess(context, l10n.deleteSuccess);
      }
      await _loadEntries();
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, l10n.deleteFailed(e));
      }
    }
  }

  // ── New Folder ──────────────────────────────────────────────────────────

  Future<void> _showNewFolderDialog() async {
    final l10n = UserStorage.l10n;
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newFolder),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.folderName,
              border: const OutlineInputBorder(),
            ),
            validator: (v) => _validateName(v, l10n),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, ctrl.text.trim());
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      await Directory(path.join(_currentDir, name)).create(recursive: true);
      if (mounted) ToastHelper.showSuccess(context, l10n.createSuccess);
      await _loadEntries();
    } catch (e) {
      if (mounted) ToastHelper.showError(context, l10n.createFailed(e));
    }
  }

  // ── New File ────────────────────────────────────────────────────────────

  Future<void> _showNewFileDialog() async {
    final l10n = UserStorage.l10n;
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newFile),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.fileName,
              border: const OutlineInputBorder(),
            ),
            validator: (v) => _validateName(v, l10n),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, ctrl.text.trim());
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      final filePath = path.join(_currentDir, name);
      await File(filePath).create(recursive: true);
      if (mounted) ToastHelper.showSuccess(context, l10n.createSuccess);
      await _loadEntries();
      // Open the newly created file for editing.
      if (mounted) _openFileEditor(filePath);
    } catch (e) {
      if (mounted) ToastHelper.showError(context, l10n.createFailed(e));
    }
  }

  String? _validateName(String? v, dynamic l10n) {
    if (v == null || v.trim().isEmpty) return l10n.nameRequired;
    if (v.contains('/') || v.contains('..')) return l10n.nameInvalid;
    return null;
  }

  // ── File View / Edit ────────────────────────────────────────────────────

  void _openFileEditor(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FileEditorPage(filePath: filePath),
      ),
    );
  }

  // ── Download ────────────────────────────────────────────────────────────

  Future<void> _showDownloadDialog() async {
    final l10n = UserStorage.l10n;
    final urlCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.downloadSkill),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.downloadToCurrentDir(_displayPath),
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: urlCtrl,
                decoration: InputDecoration(
                  hintText: l10n.urlHint,
                  labelText: 'URL',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.invalidUrl;
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme) return l10n.invalidUrl;
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, urlCtrl.text.trim());
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;
    await _downloadAndExtract(url);
  }

  Future<void> _downloadAndExtract(String url) async {
    final l10n = UserStorage.l10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.downloading)),
          ],
        ),
      ),
    );

    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data!;
      final archive = ZipDecoder().decodeBytes(bytes);

      // Detect whether all entries share a common top-level directory.
      final commonRoot = _detectCommonRoot(archive);
      String extractBase = _currentDir;

      if (commonRoot == null) {
        // No common root in zip — create a wrapper directory.
        final folderName = _deriveZipName(url, response.headers);
        extractBase = path.join(_currentDir, folderName);
        await Directory(extractBase).create(recursive: true);
      }

      for (final file in archive) {
        final filePath = path.join(extractBase, file.name);
        if (file.isFile) {
          final outFile = File(filePath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ToastHelper.showSuccess(context, l10n.downloadSuccess);
      }
      await _loadEntries();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ToastHelper.showError(context, l10n.downloadFailed(e));
      }
    }
  }

  /// Returns the common top-level directory name if all archive entries share
  /// one (e.g. `my-skill`), or null if entries are at the root level.
  String? _detectCommonRoot(Archive archive) {
    String? commonRoot;
    for (final file in archive) {
      var name = file.name;
      // Strip trailing slash for directory entries.
      if (name.endsWith('/')) name = name.substring(0, name.length - 1);
      final slashIdx = name.indexOf('/');
      // A top-level entry with no sub-path (e.g. the root dir itself) — skip.
      if (slashIdx < 0) continue;
      final topDir = name.substring(0, slashIdx);
      if (commonRoot == null) {
        commonRoot = topDir;
      } else if (topDir != commonRoot) {
        return null;
      }
    }
    return commonRoot;
  }

  /// Derive folder name from the HTTP response, mimicking how macOS Archive
  /// Utility names the wrapper directory: use the zip filename from the
  /// Content-Disposition header, strip `.zip`.
  String _deriveZipName(String url, Headers headers) {
    // 1. Content-Disposition header — the authoritative source.
    final cd = headers.value('content-disposition');
    if (cd != null) {
      final match = RegExp(r'filename[*]?=["\s]*([^";]+)').firstMatch(cd);
      if (match != null) {
        var name = match.group(1)!.trim();
        if (name.toLowerCase().endsWith('.zip')) {
          name = name.substring(0, name.length - 4);
        }
        if (name.isNotEmpty) return name;
      }
    }

    // 2. URL last path segment if it looks like a .zip filename.
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final lastSeg = uri.pathSegments.lastOrNull ?? '';
      if (lastSeg.toLowerCase().endsWith('.zip')) {
        return lastSeg.substring(0, lastSeg.length - 4);
      }
    }

    // 3. Fallback.
    return 'skill';
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: _canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              )
            : null,
        title: Text(l10n.skillsManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: l10n.newFolder,
            onPressed: _showNewFolderDialog,
          ),
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: l10n.newFile,
            onPressed: _showNewFileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: l10n.downloadSkill,
            onPressed: _showDownloadDialog,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb path bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              _displayPath,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: AgentLogoLoading())
                : _entries.isEmpty
                    ? Center(child: Text(l10n.skillsManagementEmpty))
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entity = _entries[index];
                          final isDir = entity is Directory;
                          final name = path.basename(entity.path);
                          return ListTile(
                            leading: Icon(
                              isDir ? Icons.folder : Icons.insert_drive_file,
                              color: isDir
                                  ? Colors.amber.shade700
                                  : Colors.blueGrey,
                            ),
                            title: Text(name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 20, color: Colors.red),
                              onPressed: () => _deleteEntry(entity),
                            ),
                            onTap: isDir
                                ? () => _enterDirectory(entity.path)
                                : () => _openFileEditor(entity.path),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// File editor page (view & edit)
// ─────────────────────────────────────────────────────────────────────────────

class _FileEditorPage extends StatefulWidget {
  final String filePath;
  const _FileEditorPage({required this.filePath});

  @override
  State<_FileEditorPage> createState() => _FileEditorPageState();
}

class _FileEditorPageState extends State<_FileEditorPage> {
  late TextEditingController _contentCtrl;
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final content = await File(widget.filePath).readAsString();
      _contentCtrl.text = content;
    } catch (_) {
      _contentCtrl.text = '';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    final l10n = UserStorage.l10n;
    try {
      await File(widget.filePath).writeAsString(_contentCtrl.text);
      _hasChanges = false;
      if (mounted) ToastHelper.showSuccess(context, l10n.saveSuccess);
    } catch (e) {
      if (mounted) ToastHelper.showError(context, l10n.saveFailed(e));
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    final fileName = path.basename(widget.filePath);
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: AgentLogoLoading())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.fileContent,
                  alignLabelWithHint: true,
                ),
                onChanged: (_) {
                  if (!_hasChanges) setState(() => _hasChanges = true);
                },
              ),
            ),
    );
  }
}
