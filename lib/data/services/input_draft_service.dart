import 'dart:convert';
import 'dart:io';

import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';

class InputDraft {
  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InputDraft({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty => text.trim().isEmpty;

  int get characterCount => text.runes.length;

  Map<String, dynamic> toJson() => {
        'version': 1,
        'id': id,
        'text': text,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory InputDraft.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return InputDraft(
      id: json['id'] as String? ?? 'active',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? now,
    );
  }
}

class InputDraftService {
  static final InputDraftService instance = InputDraftService._();

  final _logger = getLogger('InputDraftService');

  InputDraftService._();

  Future<InputDraft?> loadActiveDraft() async {
    try {
      final file = await _activeDraftFile();
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final draft = InputDraft.fromJson(json);
      return draft.isEmpty ? null : draft;
    } catch (e, st) {
      _logger.warning('Failed to load active input draft: $e', e, st);
      return null;
    }
  }

  Future<bool> hasActiveDraft() async {
    final draft = await loadActiveDraft();
    return draft != null && !draft.isEmpty;
  }

  Future<void> saveTextDraft(String text) async {
    if (text.trim().isEmpty) {
      await clearActiveDraft();
      return;
    }

    try {
      final previous = await loadActiveDraft();
      final now = DateTime.now();
      final draft = InputDraft(
        id: previous?.id ?? 'active',
        text: text,
        createdAt: previous?.createdAt ?? now,
        updatedAt: now,
      );

      final file = await _activeDraftFile();
      await file.parent.create(recursive: true);

      final tempFile = File('${file.path}.tmp');
      await tempFile.writeAsString(jsonEncode(draft.toJson()), flush: true);
      if (await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(file.path);
    } catch (e, st) {
      _logger.warning('Failed to save active input draft: $e', e, st);
    }
  }

  Future<void> clearActiveDraft() async {
    try {
      final file = await _activeDraftFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, st) {
      _logger.warning('Failed to clear active input draft: $e', e, st);
    }
  }

  Future<File> _activeDraftFile() async {
    final userId = await UserStorage.getUserId();
    final filePath = FileSystemService.instance.getActiveDraftPath(userId!);
    return File(filePath);
  }
}
