import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_templates.dart';
import 'package:memex/utils/user_storage.dart';

final logger = Logger('TimelineCardSkill');

/// Skill for managing Timeline Cards
class TimelineCardSkill extends Skill {
  TimelineCardSkill({
    super.forceActivate,
    bool stopAfterSuccessSaveCard = false,
  }) : super(
          name: "manage_timeline_card", // Renamed as requested
          description:
              "Creates new timeline cards from user input or updates existing timeline card details based on feedback. "
              "Handles information extraction, template selection, and card data persistence for the Timeline view. "
              "Use when: 1. User posts new content needing a timeline card. 2. User provides feedback to modify an existing timeline card.",
          systemPrompt: _buildSystemPrompt(),
          tools: _buildTools(stopAfterSuccessSaveCard),
        );

  static String _buildSystemPrompt() {
    final templatesSection = _buildTemplatesSection();
    return Prompts.timelineCardSkillSystemPrompt(
      templatesSection,
      UserStorage.l10n.timelineCardLanguageInstruction,
    );
  }

  static String _buildTemplatesSection() {
    final sb = StringBuffer();
    sb.writeln("# Available Templates\n");

    for (final template in timelineTemplates) {
      sb.writeln("## template_id: ${template['template_id']}");
      sb.writeln("**Use Case**: ${template['use_case']}");
      sb.writeln("**Data Structure**:");
      sb.writeln(template['data_structure']);
      sb.writeln("");
    }

    return sb.toString();
  }

  static Future<String> getTimelineCardMetadata(String userId) async {
    final fileService = FileSystemService.instance;
    fileService.ensureTagsFileInitialized(userId);
    final tagsListRaw = await fileService.readTagsFile(userId);
    final tagsList = tagsListRaw.map((t) => t['name'] as String).toList();

    final sb = StringBuffer();
    sb.writeln("# Existing Tags");
    if (tagsList.isEmpty) {
      sb.writeln("No tags currently available. Create tags as needed.");
    } else {
      for (final tag in tagsList) {
        sb.writeln("- $tag");
      }
    }

    return sb.toString();
  }

  static List<Tool> _buildTools(bool stopAfterSuccessSaveCard) {
    return [
      Tool(
        name: 'get_card_metadata',
        description: 'Get all available Timeline Card Templates and Tags.',
        parameters: {
          'type': 'object',
          'properties': {},
        },
        executable: () async {
          final userId = AgentCallToolContext.current!.state.metadata['userId'];
          return getTimelineCardMetadata(userId);
        },
      ),
      Tool(
        name: 'save_timeline_card',
        description: "Saves or updates a timeline card for the Memex timeline.",
        parameters: {
          'type': 'object',
          'properties': {
            'fact_id': {
              'type': 'string',
              'description':
                  'The id of the raw input (e.g. 2025/01/01.md#ts_123)'
            },
            'title': {
              'type': 'string',
              'description':
                  'A concise summary displayed on detail page header.'
            },
            'ui_configs': {
              'type': 'array',
              'description':
                  'UI rendering configuration list. You MUST provide the full data object according to the selected template.',
              'items': {
                'type': 'object',
                'properties': {
                  'template_id': {
                    'type': 'string',
                    'description': 'Template ID'
                  },
                  'data': {
                    'type': 'object',
                    'description':
                        'Template data object. CRITICAL: This MUST NOT be empty. You must populate all required fields for the chosen template_id as defined in the available templates.'
                  }
                },
                'required': ['template_id', 'data']
              }
            },
            'address': {
              'type': 'string',
              'description':
                  'Location information, set when raw input contains location-related information. Do not be too specific. Use the format "City · Specific Location" (e.g., Beijing · Chaoyang Park) if possible, otherwise just the specific location name is fine.'
            },
            'user_mark_address': {
              'type': 'string',
              'description':
                  'User-marked location information, set when raw input contains very close user-marked location'
            },
            'content_creation_date': {
              'type': 'string',
              'description':
                  'The creation date of the content (e.g. image capture time), in format "YYYY-MM-DD HH:MM:SS". If not provided, current time will be used.'
            },
            'tags': {
              'type': 'array',
              'description':
                  'Select 1-3 most appropriate tags strictly from internal pre-defined list. Do not invent new tags.',
              'items': {
                'type': 'object',
                'properties': {
                  'name': {
                    'type': 'string',
                    'description':
                        "Tag name. MUST be one of: 'Project', 'Trip', 'Milestone', 'Health', 'Relationship', 'Finance', 'Knowledge', 'Emotion', 'Visual', 'Audio'."
                  },
                  'icon': {
                    'type': 'string',
                    'description':
                        'Not used anymore, internal icons are hardcoded.'
                  },
                },
                'required': ['name']
              }
            },
          },
          'required': ['fact_id', 'title', 'ui_configs']
        },
        executable: (String fact_id,
            String title,
            List ui_configs,
            String? address,
            String? user_mark_address,
            String? content_creation_date,
            List? tags) async {
          final fileService = FileSystemService.instance;

          // Access context
          final context = AgentCallToolContext.current;
          if (context == null) {
            throw StateError(
                "save_timeline_card must be called within an agent execution context.");
          }

          // fact_id and userId are available via closure/args.


          final userId = AgentCallToolContext.current!.state.metadata['userId'];
          final stateFactId =
              AgentCallToolContext.current!.state.metadata['factId'] as String?;

          // Use state factId as fallback if model-provided one is invalid
          final effectiveFactId =
              (stateFactId != null && stateFactId.isNotEmpty)
                  ? stateFactId
                  : fact_id;

          logger.info(
              "Saving card for fact: $fact_id (effective: $effectiveFactId)");

          try {
            // 1. Validate required fields
            if (title.isEmpty) {
              throw ArgumentError("title is required");
            }
            // ui_configs: must be array, each element must be dict with valid template_id and data
            if (ui_configs.isEmpty) {
              throw ArgumentError("ui_configs must be provided and non-empty.");
            }
            final List<Map<String, dynamic>> finalUiConfigs = [];
            for (var i = 0; i < ui_configs.length; i++) {
              final raw = ui_configs[i];
              if (raw is! Map) {
                throw ArgumentError(
                    "ui_configs[$i] must be an object (Map), got ${raw.runtimeType}.");
              }
              final config = Map<String, dynamic>.from(raw);
              validateUiConfig(config);
              finalUiConfigs.add(config);
            }
            // When multiple templates are selected, remove snapshot template; if all are snapshot, keep one
            if (finalUiConfigs.length > 1) {
              final nonSnapshot = finalUiConfigs
                  .where((c) => c['template_id'] != 'snapshot')
                  .toList();
              if (nonSnapshot.isNotEmpty) {
                finalUiConfigs
                  ..clear()
                  ..addAll(nonSnapshot);
              } else {
                // All are snapshot: keep exactly one
                final oneSnapshot = finalUiConfigs.first;
                finalUiConfigs
                  ..clear()
                  ..add(oneSnapshot);
              }
            }

            // 2. Read factContent from file (validates fact exists)
            final factInfo = await fileService.extractFactContentFromFile(
                userId, effectiveFactId);
            if (factInfo == null) {
              throw ArgumentError(
                  "fact id: $effectiveFactId not exist, please check the fact id is correct, or create/edit fact file first, the format of fact_id is 2026/01/20.md#ts_5");
            }

            // 3. Load existing tags
            await fileService.ensureTagsFileInitialized(userId);
            final tagDefinitions = await fileService.readTagsFile(userId);
            final existingTagNames =
                tagDefinitions.map((t) => t['name'] as String).toSet();

            // 4. Strict Tag Processing — only predefined tags are allowed
            const Map<String, Map<String, String>> allowedTags = {
              'Project': {'icon': '🎯', 'icon_type': 'emoji'},
              'Trip': {'icon': '✈️', 'icon_type': 'emoji'},
              'Milestone': {'icon': '🏆', 'icon_type': 'emoji'},
              'Health': {'icon': '🏥', 'icon_type': 'emoji'},
              'Relationship': {'icon': '🫂', 'icon_type': 'emoji'},
              'Finance': {'icon': '💰', 'icon_type': 'emoji'},
              'Knowledge': {'icon': '💡', 'icon_type': 'emoji'},
              'Emotion': {'icon': '🎭', 'icon_type': 'emoji'},
              'Visual': {'icon': '📸', 'icon_type': 'emoji'},
              'Audio': {'icon': '🎙️', 'icon_type': 'emoji'},
            };

            final tagNames = <String>[];
            final newTagsToCreate = <Map<String, dynamic>>[];

            if (tags != null) {
              for (var tagObj in tags) {
                final extractMap = Map<String, dynamic>.from(tagObj as Map);
                var tagName = (extractMap['name'] as String?)?.trim() ?? '';

                if (tagName.isEmpty) continue;

                // Normalize capitalization (e.g. 'project' -> 'Project')
                tagName = tagName[0].toUpperCase() +
                    tagName.substring(1).toLowerCase();

                if (!allowedTags.containsKey(tagName)) {
                  throw ArgumentError(
                    "Invalid tag '$tagName'. You MUST only use tags from the following list: ${allowedTags.keys.join(', ')}.",
                  );
                }

                if (!tagNames.contains(tagName)) {
                  tagNames.add(tagName);
                }

                // Auto-persist the tag if it's the first time being used
                if (!existingTagNames.contains(tagName)) {
                  newTagsToCreate.add({
                    'name': tagName,
                    'icon': allowedTags[tagName]!['icon']!,
                    'icon_type': allowedTags[tagName]!['icon_type']!,
                  });
                  existingTagNames.add(tagName);
                }
              }
            }

            // 5. Save new tags to DB
            if (newTagsToCreate.isNotEmpty) {
              await fileService.appendNewTags(userId, newTagsToCreate);
            }

            // 9. Determine timestamp
            int? timestamp;
            if (content_creation_date != null &&
                content_creation_date.isNotEmpty) {
              try {
                timestamp = DateTime.parse(content_creation_date)
                        .millisecondsSinceEpoch ~/
                    1000;
              } catch (e) {
                logger.warning(
                    "Failed to parse content_creation_date: $content_creation_date");
              }
            }

            // 10. Update Card File
            Map<String, dynamic>? locationInfo;
            if (user_mark_address != null) {
              locationInfo = await fileService.getUserLocationByName(
                  userId, user_mark_address);
            }

            final uiConfigEntries = finalUiConfigs
                .map((m) => UiConfig(
                      templateId: m['template_id'] as String? ?? '',
                      data: m['data'] is Map
                          ? Map<String, dynamic>.from(m['data'] as Map)
                          : {},
                    ))
                .toList();

            final updatedCardData = await fileService.updateCardFile(
              userId,
              effectiveFactId,
              createIfNotExists: true,
              (card) {
                var c = card.copyWith(
                  status: 'completed',
                  title: title,
                  uiConfigs: uiConfigEntries,
                  timestamp: timestamp ??
                      (card.timestamp > 0
                          ? card.timestamp
                          : DateTime.now().millisecondsSinceEpoch ~/ 1000),
                  address: address ?? card.address,
                  tags: tagNames.isNotEmpty ? tagNames : card.tags,
                );
                if (locationInfo != null) {
                  c = c.copyWith(
                    userFixedAddress: locationInfo['name'] as String?,
                    userFixedLocation: UserFixedLocation(
                      lat: (locationInfo['lat'] as num?)?.toDouble(),
                      lng: (locationInfo['lng'] as num?)?.toDouble(),
                      name: locationInfo['name'] as String?,
                    ),
                  );
                }
                return c;
              },
            );

            if (updatedCardData == null) {
              return AgentToolResult(
                content: TextPart(
                    "Card file not found for fact_id: $effectiveFactId, maybe it has been deleted"),
              );
            }

            // Log event
            try {
              // Determine card file path from fact_id
              final parts = effectiveFactId.split('#');
              if (parts.length == 2) {
                final datePart = parts[0]; // e.g., "2025/01/21.md"
                final dateWithoutExt = datePart.replaceFirst('.md', '');
                final tsId = parts[1]; // e.g., "ts_1"
                final cardFileName = '${dateWithoutExt}_$tsId.yaml';
                final cardPath = 'Cards/$cardFileName';

                await fileService.eventLogService.logFileModified(
                  userId: userId,
                  filePath: cardPath,
                  description: 'Agent updated timeline card',
                  metadata: {'fact_id': effectiveFactId, 'title': title},
                );
              }
            } catch (e) {
              // Event logging failure should not break tool
            }

            return AgentToolResult(
              content: TextPart(
                  "Successfully saved timeline card for Fact $effectiveFactId"),
              stopFlag: stopAfterSuccessSaveCard,
            );
          } catch (e, stack) {
            logger.severe("SaveTimelineCard failed", e, stack);
            return AgentToolResult(
              content: TextPart("Failed to save timeline card: $e"),
            );
          }
        },
      ),
    ];
  }
}
