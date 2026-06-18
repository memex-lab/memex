import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:convert';

class SaveTemplateTool {
  final Logger _logger = getLogger('SaveTemplateTool');
  FileSystemService get _fileService => FileSystemService.instance;

  Future<String> tool({
    required String templateId,
    required String description,
    required List<String> fields,
    required String htmlContent,
  }) async {
    final context = AgentCallToolContext.current;
    if (context == null) {
      throw StateError(
          "SaveTemplateTool must be called within an agent execution context.");
    }
    final metadata = context.state.metadata;
    final userId = metadata['userId'] as String?;

    if (userId == null) throw StateError("Missing userId in agent metadata.");

    _logger.info("Saving template: $templateId");

    try {
      // 1. Validate inputs
      if (templateId.isEmpty) throw ArgumentError("templateId is required");
      if (description.isEmpty) throw ArgumentError("description is required");
      if (fields.isEmpty) throw ArgumentError("fields is required");
      if (htmlContent.isEmpty) throw ArgumentError("htmlContent is required");
      if (htmlContent.trim().isEmpty) {
        throw ArgumentError("HTML content cannot be empty or whitespace");
      }

      // 2. Validate template variables
      final usedVariables = RegExp(r'\{\{(\w+)\}\}')
          .allMatches(htmlContent)
          .map((m) => m.group(1)!)
          .toSet();

      final invalidVariables = usedVariables
          .where((v) => !RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(v))
          .toList();
      if (invalidVariables.isNotEmpty) {
        throw ArgumentError(
            "Invalid variable names: ${invalidVariables.join(', ')}");
      }

      final fieldsSet = fields.toSet();
      final undefinedVariables = usedVariables.difference(fieldsSet);
      if (undefinedVariables.isNotEmpty) {
        throw ArgumentError(
            "Variables used in HTML but not declared in fields: ${undefinedVariables.join(', ')}");
      }

      // 3. Check for forbidden styles (outer border-radius)
      // Simple regex check as per Python
      if (RegExp(r'\.card\s*\{[^}]*border-radius[^}]*\}', caseSensitive: false)
              .hasMatch(htmlContent) ||
          RegExp(r'body\s*>\s*div[^}]*\{[^}]*border-radius[^}]*\}',
                  caseSensitive: false)
              .hasMatch(htmlContent) ||
          RegExp(r'body\s*\{[^}]*\}[^}]*div[^}]*\{[^}]*border-radius[^}]*\}',
                  caseSensitive: false)
              .hasMatch(htmlContent)) {
        _logger.warning(
            "Template $templateId contains border-radius on outer element, which is discouraged.");
      }

      // 4. Save template files
      final templatePath = _fileService.getTemplatePath(userId, templateId);
      final dir = Directory(templatePath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Save meta.json
      final metaData = {"description": description, "fields": fields};
      final metaFile = File(p.join(templatePath, "meta.json"));
      await metaFile.writeAsString(jsonEncode(
          metaData)); // No pretty print by default in jsonEncode, but fine.

      // Save view.html
      final viewFile = File(p.join(templatePath, "view.html"));
      await viewFile.writeAsString(htmlContent);

      return "Template saved successfully.\nID: $templateId\nDescription: $description";
    } catch (e, stack) {
      _logger.severe("Failed to save template: $e", e, stack);
      rethrow;
    }
  }
}
