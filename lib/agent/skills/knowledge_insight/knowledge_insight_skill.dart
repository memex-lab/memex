import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/agent/skills/knowledge_insight/native_widgets.dart';

import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/user_storage.dart';
import '../../../utils/logger.dart';

class KnowledgeInsightSkill extends Skill {
  KnowledgeInsightSkill({super.forceActivate})
      : super(
          name: "update_knowledge_insight",
          description:
              "Analyzes user knowledge and generates visual insights cards. (Only activate when need to update knowledge insight card data)",
          systemPrompt:
              Prompts.knowledgeInsightAgentKnowledgeInsightSkillPrompt(
            UserStorage.l10n.knowledgeInsightLanguageInstruction,
          ),
          tools: [
            buildGetExistsKnowledgeInsightCardsTool(),
            buildSaveKnowledgeInsightCardsTool(),
            buildDeleteKnowledgeInsightCardTool(),
            buildDeleteKnowledgeInsightTagsTool(),
            buildGetAvailableTemplatesTool(),
          ],
        );
}

class ChartData {
  final String?
      id; // Optional ID, if null, a new one will be generated or derived from title
  final String? templateId;
  final String? title;
  final String? insight;
  final String? type; // 'add' or 'update'
  final Map<String, dynamic>? data;
  final List<String>? relatedFacts;
  final bool? pinned;
  final double? sortOrder;
  final List<String>? tags;

  ChartData({
    this.id,
    this.templateId,
    this.title,
    this.insight,
    this.type,
    this.data,
    this.relatedFacts,
    this.pinned,
    this.sortOrder,
    this.tags,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (templateId != null) 'template_id': templateId,
        if (title != null) 'title': title,
        if (insight != null) 'insight': insight,
        if (type != null) 'type': type,
        if (data != null) 'data': data,
        if (relatedFacts != null) 'related_facts': relatedFacts,
        if (pinned != null) 'pinned': pinned,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (tags != null) 'tags': tags,
      };

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      id: json['id'] as String?,
      templateId: json['template_id'] as String?,
      title: json['title'] as String?,
      insight: json['insight'] as String?,
      type: json['type'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      relatedFacts: (json['related_facts'] as List?)?.cast<String>(),
      pinned: json['pinned'] as bool?,
      sortOrder: (json['sort_order'] as num?)?.toDouble(),
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }
}

Tool buildGetExistsKnowledgeInsightCardsTool() {
  return Tool(
    name: 'get_exists_knowledge_insight_cards',
    description: Prompts.knowledgeInsightToolGetKnowledgeInsightDataDescription,
    parameters: {
      'type': 'object',
      'properties': {},
    },
    executable: () async {
      final logger = getLogger('KnowledgeInsightSkill');
      final fileSystem = FileSystemService.instance;
      final userId = AgentCallToolContext.current!.state.metadata['userId'];

      try {
        final cards = await fileSystem.listKnowledgeInsightCards(userId);
        if (cards.isEmpty) {
          return "No existing knowledge insight cards found.";
        }
        return jsonEncode(cards);
      } catch (e) {
        logger.warning('Failed to get knowledge insight data: $e');
        return "Error: $e";
      }
    },
  );
}

Tool buildDeleteKnowledgeInsightCardTool() {
  return Tool(
    name: 'delete_knowledge_insight_card',
    description: 'Delete a knowledge insight card by its ID.',
    parameters: {
      'type': 'object',
      'properties': {
        'card_id': {
          'type': 'string',
          'description': 'The ID of the card to delete.',
        },
      },
      'required': ['card_id'],
    },
    executable: (String cardId) async {
      final logger = getLogger('KnowledgeInsightSkill');
      final fileSystem = FileSystemService.instance;
      final userId = AgentCallToolContext.current!.state.metadata['userId'];

      try {
        final success =
            await fileSystem.deleteKnowledgeInsightCard(userId, cardId);
        if (success) {
          return "Card $cardId deleted successfully.";
        } else {
          return "Failed to delete card $cardId (File not found or error).";
        }
      } catch (e) {
        logger.warning('Failed to delete knowledge insight card: $e');
        return "Error: $e";
      }
    },
  );
}

Tool buildDeleteKnowledgeInsightTagsTool() {
  return Tool(
    name: 'delete_knowledge_insight_tags',
    description:
        'Delete unused insight tags to keep the tag list clean and prevent them from appearing in the UI.',
    parameters: {
      'type': 'object',
      'properties': {
        'tags': {
          'type': 'array',
          'description': 'List of tag names to delete.',
          'items': {'type': 'string'}
        },
      },
      'required': ['tags'],
    },
    executable: (List<dynamic> tags) async {
      final logger = getLogger('KnowledgeInsightSkill');
      final fileSystem = FileSystemService.instance;
      final userId = AgentCallToolContext.current!.state.metadata['userId'];

      try {
        final tagList = tags.cast<String>();
        await fileSystem.deleteInsightTags(userId, tagList);
        return "Successfully deleted tags: ${tagList.join(', ')}";
      } catch (e) {
        logger.warning('Failed to delete insight tags: $e');
        return "Error: $e";
      }
    },
  );
}

Tool buildSaveKnowledgeInsightCardsTool() {
  return Tool(
    name: 'save_knowledge_insight_cards',
    description: Prompts.knowledgeInsightToolUpdateInsightChartsDescription,
    parameters: Prompts.knowledgeInsightToolUpdateInsightChartsParameters,
    executable: (List<dynamic> cards) async {
      final logger = getLogger('KnowledgeInsightSkill');
      final fileSystem = FileSystemService.instance;
      final userId = AgentCallToolContext.current!.state.metadata['userId'];

      // Convert dicts to ChartData objects
      final chartObjects = cards.map((c) {
        final cardMap = c as Map<String, dynamic>;
        if (cardMap.containsKey('template_data_json') &&
            cardMap['template_data_json'] is String) {
          try {
            cardMap['data'] =
                jsonDecode(cardMap['template_data_json'] as String);
          } catch (e) {
            throw Exception(
                'Failed to decode template_data_json for card ID ${cardMap['id']}: $e');
          }
          cardMap.remove('template_data_json');
        }
        return ChartData.fromJson(cardMap);
      }).toList();

      // Convert charts to modifiable maps to update sort_order later
      // We can't modify ChartData objects directly as they are final
      // So we will modify the json map before writing or reconstructing
      // Actually, let's keep chartObjects for validation, but use a parallel logic for data prep
      // Or just rely on the fact that we construct `newData` from `chart.toJson()` later.
      // Better: we modify `chart.toJson()` result which is `newData`.

      // Helper function to get available template IDs
      Future<Set<String>> getAvailableTemplateIds() async {
        return nativeWidgets.map((w) => w.id).toSet();
      }

      final availableTemplateIds = await getAvailableTemplateIds();

      // Validate template IDs
      final notSupportedTemplateIds = chartObjects
          .where((chart) =>
              chart.templateId != null &&
              !availableTemplateIds.contains(chart.templateId))
          .toList();
      if (notSupportedTemplateIds.isNotEmpty) {
        return "Error: Template IDs ${notSupportedTemplateIds.map((t) => t.templateId).join(", ")} do not exist. Please check available templates using 'get_available_insight_card_templates' tool.";
      }

      // Validate data against schema
      for (final chart in chartObjects) {
        if (chart.templateId != null && chart.data != null) {
          final widgetDef =
              nativeWidgets.firstWhere((w) => w.id == chart.templateId);
          final error = widgetDef.validator(chart.data!);
          if (error != null) {
            return "Error: Validation failed for card (id: ${chart.id}, template: ${chart.templateId}): $error";
          }
        }
      }

      // Validate required fields (related_facts must be present and non-empty for new/updates)
      for (final chart in chartObjects) {
        // We require related_facts to be non-empty for meaningful insights
        // Exception: if it's an update and relatedFacts is null (not provided), we assume it's unchanged.
        // But if it IS provided, it must not be empty.
        // Actually, for 'add', it MUST be provided.
        if (chart.type == 'add') {
          if (chart.relatedFacts == null || chart.relatedFacts!.isEmpty) {
            return "Error: `related_facts` is REQUIRED and must not be empty for new insight cards (id: ${chart.id}). Please provide at least one related fact ID.";
          }
        } else if (chart.type == 'update') {
          // For updates, if provided, it must be non-empty
          if (chart.relatedFacts != null && chart.relatedFacts!.isEmpty) {
            return "Error: `related_facts` cannot be set to empty (id: ${chart.id}). Please provide valid related fact IDs or omit the field to keep existing facts.";
          }
        }
      }

      final updatedIds = <String>[];
      final createdIds = <String>[];

      try {
        for (final chart in chartObjects) {
          String cardId = chart.id ?? '';
          bool isNew = false;
          Map<String, dynamic> existingData = {};

          if (cardId.isEmpty) {
            throw Exception('Card ID must be provided for all operations.');
          }

          if (chart.type == 'add') {
            final existing =
                await fileSystem.readKnowledgeInsightCard(userId, cardId);
            if (existing != null) {
              throw Exception(
                  'Card with ID $cardId already exists. Cannot add.');
            }
            createdIds.add(cardId);
            isNew = true;
          } else if (chart.type == 'update') {
            final existing =
                await fileSystem.readKnowledgeInsightCard(userId, cardId);
            if (existing == null) {
              throw Exception('Card with ID $cardId not found. Cannot update.');
            }
            existingData = existing;
            updatedIds.add(cardId);
            isNew = false;
          } else {
            throw Exception(
                'Invalid operation type: ${chart.type}. Must be "add" or "update".');
          }

          var newData = chart.toJson();

          // Apply auto-sort logic if new
          if (isNew) {
            try {
              final allCards =
                  await fileSystem.listKnowledgeInsightCards(userId);
              int minSortOrder = 0;
              if (allCards.isNotEmpty) {
                final orders = allCards
                    .map((c) => (c['sort_order'] as num? ?? 0).toInt())
                    .toList();
                if (orders.isNotEmpty) {
                  minSortOrder =
                      orders.reduce((min, val) => val < min ? val : min);
                }
              }
              newData['sort_order'] = minSortOrder - 1;
            } catch (e) {
              logger.warning('Failed to auto-calculate sort order: $e');
            }
          }

          // Merge data if it's an update
          final Map<String, dynamic> finalData;
          if (isNew) {
            finalData = newData;
          } else {
            // Incremental update: merge fields
            finalData = Map<String, dynamic>.from(existingData);
            newData.forEach((key, value) {
              if (key == 'data' &&
                  value is Map &&
                  finalData['data'] is Map<String, dynamic>) {
                // Deep merge for 'data' field
                finalData['data'] = {
                  ...finalData['data'] as Map<String, dynamic>,
                  ...value as Map<String, dynamic>
                };
              } else {
                finalData[key] = value;
              }
            });
          }

          finalData['id'] = cardId; // Ensure ID is saved
          finalData['updated_at'] = DateTime.now().toIso8601String();

          await fileSystem.writeKnowledgeInsightCard(userId, cardId, finalData);

          // Log event
          try {
            final cardPath = 'KnowledgeInsights/Cards/$cardId.yaml';
            if (isNew) {
              await fileSystem.eventLogService.logFileCreated(
                userId: userId,
                filePath: cardPath,
                description: 'Agent created knowledge insight card',
                metadata: {'card_id': cardId, 'title': finalData['title']},
              );
            } else {
              await fileSystem.eventLogService.logFileModified(
                userId: userId,
                filePath: cardPath,
                description: 'Agent updated knowledge insight card',
                metadata: {'card_id': cardId, 'title': finalData['title']},
              );
            }
          } catch (e) {
            // Event logging failure should not break tool
          }
        }

        // Collect and save all unique tags
        final allTags = <String>{};
        for (final chart in chartObjects) {
          if (chart.tags != null) {
            allTags.addAll(chart.tags!);
          }
        }
        if (allTags.isNotEmpty) {
          await fileSystem.saveInsightTags(userId, allTags.toList());
        }

        // Track added/updated cards in state metadata for summary card generation
        try {
          final state = AgentCallToolContext.current!.state;
          final tracker =
              state.metadata['insight_updates'] as Map<String, dynamic>? ??
                  {'added': [], 'updated': []};
          final addedList =
              List<Map<String, dynamic>>.from(tracker['added'] ?? []);
          final updatedList =
              List<Map<String, dynamic>>.from(tracker['updated'] ?? []);

          for (final chart in chartObjects) {
            final info = {'id': chart.id, 'title': chart.title ?? ''};
            if (chart.type == 'add') {
              addedList.add(info);
            } else if (chart.type == 'update') {
              updatedList.add(info);
            }
          }
          state.metadata['insight_updates'] = {
            'added': addedList,
            'updated': updatedList
          };
        } catch (e) {
          // Tracking failure should not break the tool
        }

        return Prompts.knowledgeInsightToolSuccessUpdate(
            createdIds.length, createdIds, updatedIds.length, updatedIds);
      } catch (e) {
        logger.severe('Failed to update knowledge insight cards: $e');
        throw Exception('Failed to update knowledge insight cards: $e');
      }
    },
  );
}

// buildGetUserPinnedInsightTemplatesTool removed

Tool buildGetAvailableTemplatesTool() {
  return Tool(
    name: 'get_available_insight_card_templates',
    description: Prompts.knowledgeInsightToolGetAvailableTemplatesDescription,
    parameters: {
      'type': 'object',
      'properties': {},
    },
    executable: () async {
      final logger = getLogger('KnowledgeInsightSkill');
      final fileSystem = FileSystemService.instance;
      final userId = AgentCallToolContext.current!.state.metadata['userId'];

      List<String> tags = [];

      try {
        tags = await fileSystem.readInsightTags(userId);
      } catch (e) {
        logger.warning('Failed to read insight tags: $e');
      }

      final buffer = StringBuffer();
      buffer.writeln('# Available Insight Templates');
      buffer.writeln(
          'Here are the available native templates you can use to generate insight cards.');
      buffer.writeln(
          '\nIMPORTANT: When calling `save_knowledge_insight_cards` tool, you MUST construct the data object matching the `Data Structure` (TypeScript definitions) below. Then, you MUST serialize this object into a JSON string and pass it to the `template_data_json` field.');

      // 1. Native Widgets (System)
      for (final widget in nativeWidgets) {
        buffer.writeln('\n## Template: `${widget.id}`');
        buffer.writeln('**Description**: ${widget.description}');
        buffer.writeln('**Data Structure**:');
        buffer.writeln('```ts');
        buffer.writeln(widget.promptStructure.trim());
        buffer.writeln('```');
      }

      // 2. Existing Tags
      if (tags.isNotEmpty) {
        buffer.writeln('\n# Existing Tags');
        buffer.writeln('The following tags are already in use in the system:');
        buffer.writeln(tags.map((t) => '- $t').join('\n'));
      } else {
        buffer.writeln('\n# Existing Tags');
        buffer.writeln('(No tags found)');
      }

      return buffer.toString();
    },
  );
}
