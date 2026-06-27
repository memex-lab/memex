// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/data/services/asset_reference_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/memory_sync_service.dart';
import 'package:memex/data/services/timeline_card_event_publisher.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_templates.dart';
import 'package:memex/utils/user_storage.dart';

final logger = Logger('TimelineCardSkill');

bool _nonEmpty(String? value) => value != null && value.trim().isNotEmpty;

/// Skill for managing Timeline Cards
class TimelineCardSkill extends Skill {
  TimelineCardSkill({
    super.forceActivate,
    bool stopAfterSuccessSaveCard = false,
    bool enableFinishSummary = false,
  }) : super(
          name: "manage_timeline_card", // Renamed as requested
          description:
              "Creates new timeline cards from user input or updates existing timeline card details based on feedback. "
              "Handles information extraction, template selection, and card data persistence for the Timeline view. "
              "Use when: 1. User posts new content needing a timeline card. 2. User provides feedback to modify an existing timeline card.",
          systemPrompt: _buildSystemPrompt(),
          tools: _buildTools(
            stopAfterSuccessSaveCard,
            enableFinishSummary: enableFinishSummary,
          ),
        );

  static String _buildSystemPrompt() {
    return Prompts.timelineCardSkillSystemPrompt(
      '## Timeline Card Templates\n'
      'Use `get_card_metadata` to retrieve the current template catalog and '
      'tags. If no suitable template exists, or the user asks to redesign a '
      'template, activate `dynamic_timeline_ui` to create or update a template '
      'first, then call `save_timeline_card` with that template_id and a '
      '`data` object matching its data structure.\n',
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
    sb.write(_buildTemplatesSection());
    final customTemplates = await fileService.listTimelineTemplateMetas(userId);
    for (final template in customTemplates) {
      sb.writeln("## template_id: ${template.templateId}");
      sb.writeln("**Use Case**: ${template.useCase}");
      sb.writeln("**Data Structure**:");
      sb.writeln(template.dataStructure);
      sb.writeln("");
    }

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

  static List<Tool> _buildTools(
    bool stopAfterSuccessSaveCard, {
    required bool enableFinishSummary,
  }) {
    final saveProperties = <String, dynamic>{
      'fact_id': {
        'type': 'string',
        'description':
            'REQUIRED. For a brand-new record: the id you minted with `mint_record_fact_id` first. For editing/repairing: the existing card id (e.g. 2025/01/01.md#ts_123). Never invent an id — it must come from mint_record_fact_id or be an existing card.'
      },
      'title': {
        'type': 'string',
        'description':
            'A concise summary displayed on detail page header. Required for a new card; omit when editing to keep the existing title.'
      },
      'ui_configs': {
        'type': 'array',
        'description':
            'UI rendering configuration list. Required for a new card; omit when editing to keep the existing layout. When provided, you MUST give the full data object for the selected template.',
        'items': {
          'type': 'object',
          'properties': {
            'template_id': {'type': 'string', 'description': 'Template ID'},
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
            'Location information for where the recorded card actually happened. Use raw input named places only when they are the actual occurrence, check-in, visit, photo capture, or activity location. For tasks, todos, reminders, plans, wishes, future destinations, or places the user merely wants to go to, omit address even if a place is mentioned. If raw input describes an immediate present-time event, check-in, photo capture, or daily activity and current_location_context is available, use its location_summary or full_address_candidate as a conservative default. Do not use current_location_context for memories, plans, remote events, or when raw input names a conflicting place. Do not be too specific. Use the format "City · Specific Location" (e.g., Beijing · Chaoyang Park) if possible, otherwise just the specific location name is fine.'
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
              'description': 'Not used anymore, internal icons are hardcoded.'
            },
          },
          'required': ['name']
        }
      },
      'fact': {
        'type': 'string',
        'description':
            "The source-of-truth record content. Write a coherent record in the user's own words and speaking/writing style, combining the user's text with the image/audio content that matters to this record. This is the faithful original content, not a summary, paraphrase, or your own commentary. If the user wrote text, preserve their wording where it matters. Do NOT put an `fs://` reference here — attachment references go only in `assets`. Required for a new card; omit when editing to keep the existing fact."
      },
      'assets': {
        'type': 'array',
        'description':
            "The image and audio files attached to this card, as bare `fs://...` references extracted from the attachment markers in the user message (for example `fs://photo.jpg`) — copied exactly, never invented or altered. Omit this field entirely to keep the card's existing assets unchanged; pass the full list to replace them. Required only when a new card has attachments.",
        'items': {'type': 'string'}
      },
      if (enableFinishSummary)
        'finish_summary': {
          'type': 'string',
          'description':
              'If this successful save completes the requested work, set this to the exact concise final summary to return. Include relevant work already done in this run. Omit it if another tool call, inspection, or repair is still needed.',
        },
    };

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
        description:
            "Saves or updates a timeline card. This is a partial update: any "
            "field you pass is replaced; any field you omit keeps its current "
            "value. So to edit one thing on an existing card, send just `fact_id` "
            "plus that field — don't resend the rest. A brand-new card has "
            "nothing to inherit, so it still needs `title`, `ui_configs`, and "
            "`fact`.",
        parameters: {
          'type': 'object',
          'properties': saveProperties,
          'required': ['fact_id']
        },
        executable: (String? fact_id,
            String? title,
            dynamic ui_configs,
            String? address,
            String? user_mark_address,
            String? content_creation_date,
            dynamic tags,
            String? fact,
            dynamic assets,
            [String? finish_summary]) async {
          final fileService = FileSystemService.instance;

          // Access context
          final context = AgentCallToolContext.current;
          if (context == null) {
            throw StateError(
                "save_timeline_card must be called within an agent execution context.");
          }

          // fact_id and userId are available via closure/args.

          logger.info("Saving card for fact: ${fact_id ?? '(new)'}");

          final userId = AgentCallToolContext.current!.state.metadata['userId'];
          final isSubAgent =
              AgentCallToolContext.current!.state.metadata['sub_agent_mode'] ==
                  true;

          final denied = await gateMutatingToolCall(
            toolName: 'save_timeline_card',
            summary: '${title ?? '(card)'}'
                '${fact_id == null ? '' : ' ($fact_id)'}',
          );
          if (denied != null) return denied;

          String? rollbackPlaceholderFactId;
          try {
            // Resolve identity and read the prior card FIRST — whether this is
            // a brand-new card or an edit drives what's required. fact_id is
            // always explicit now (minted via mint_record_fact_id for a new
            // record, or an existing card's id when editing); we never allocate
            // inside save.
            if (fact_id == null || fact_id.trim().isEmpty) {
              throw ArgumentError(
                  "fact_id is required. Mint one with mint_record_fact_id first (for a new record), or pass an existing card's id when editing.");
            }
            final resolvedFactId = fact_id.trim();
            final priorCard =
                await fileService.readCardFile(userId, resolvedFactId);
            if (priorCard == null) {
              throw ArgumentError(
                  "Card $resolvedFactId does not exist. Mint a fact_id with mint_record_fact_id before saving a new record, or pass the id of an existing card to edit.");
            }
            // A freshly-minted placeholder has status 'processing' and was never
            // completed → this save is the brand-new card. An already-'completed'
            // card → this is an edit. This also drives the comment + memory
            // triggers below.
            final isNewCard = priorCard.status != 'completed';
            final isEmptyProcessingPlaceholder =
                _isEmptyProcessingPlaceholder(priorCard);
            if (isEmptyProcessingPlaceholder) {
              rollbackPlaceholderFactId = resolvedFactId;
            }

            // This save is a partial update: any field you OMIT keeps its prior
            // value; only fields you pass are replaced. So an edit can change
            // just one field without resending the whole card. A brand-new card
            // has nothing to inherit, so its core content is still required.
            if (isNewCard) {
              if (title == null || title.trim().isEmpty) {
                throw ArgumentError("title is required for a new card.");
              }
              if (fact == null || fact.trim().isEmpty) {
                throw ArgumentError("fact is required for a new card.");
              }
              if (ui_configs == null) {
                throw ArgumentError("ui_configs is required for a new card.");
              }
            }

            // Guard: `fs://` references identify attachments and belong only in
            // `assets`. Keeping them out of `fact` (which is prose) prevents the
            // raw id leaking into the card's source-of-truth text.
            if (fact != null && fact.contains('fs://')) {
              throw ArgumentError(
                  "The `fact` field must not contain an `fs://` reference. Write `fact` as a coherent record in the user's own words and speaking/writing style, using the image/audio content that matters to the record, and put the bare `fs://...` reference in the `assets` field instead.");
            }

            // ui_configs: process only when provided. Omitted → keep prior
            // (uiConfigEntries stays null → copyWith preserves the old value).
            List<UiConfig>? uiConfigEntries;
            if (ui_configs != null) {
              final uiConfigsList =
                  _normalizeListArgument(ui_configs, 'ui_configs');
              final customTemplateFields = {
                for (final meta
                    in await fileService.listTimelineTemplateMetas(userId))
                  meta.templateId: meta.fields,
              };
              if (uiConfigsList.isEmpty) {
                throw ArgumentError(
                    "ui_configs must be non-empty when provided.");
              }
              final List<Map<String, dynamic>> finalUiConfigs = [];
              for (var i = 0; i < uiConfigsList.length; i++) {
                final raw = uiConfigsList[i];
                if (raw is! Map) {
                  throw ArgumentError(
                      "ui_configs[$i] must be an object (Map), got ${raw.runtimeType}.");
                }
                final config = Map<String, dynamic>.from(raw);
                validateUiConfig(
                  config,
                  customTemplateFields: customTemplateFields,
                );
                await _validateUiConfigMediaReferences(
                  userId: userId,
                  configIndex: i,
                  config: config,
                );
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
              uiConfigEntries = finalUiConfigs
                  .map((m) => UiConfig(
                        templateId: m['template_id'] as String? ?? '',
                        data: m['data'] is Map
                            ? Map<String, dynamic>.from(m['data'] as Map)
                            : {},
                      ))
                  .toList();
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

            final tagsList =
                tags == null ? null : _normalizeListArgument(tags, 'tags');
            if (tagsList != null) {
              for (var tagObj in tagsList) {
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

            // Normalize asset references. Tool callers provide bare
            // `fs://...` ids (view_image uses the same form). Cards still store
            // full markdown refs because the renderer uses the marker shape to
            // distinguish image vs audio.
            // Omitted (null) → keep the card's prior assets untouched. Provided
            // → replace with the validated set: each fs:// reference must
            // resolve to a real file under Facts/assets, so a fabricated /
            // hallucinated reference never lands on the card.
            List<String>? assetsList;
            if (assets != null) {
              assetsList = <String>[];
              final assetEntries = _normalizeListArgument(assets, 'assets');
              for (var i = 0; i < assetEntries.length; i++) {
                final entry = assetEntries[i];
                final ref = entry?.toString().trim() ?? '';
                if (ref.isEmpty) continue;
                final asset = await _resolveRequiredAssetReference(
                  userId: userId,
                  reference: ref,
                  path: 'assets[$i]',
                );
                assetsList.add(asset.markdownRef);
              }
            }

            final updatedCardData = await fileService.updateCardFile(
              userId,
              resolvedFactId,
              createIfNotExists: true,
              (card) {
                var c = card.copyWith(
                  status: 'completed',
                  title: title?.trim(),
                  uiConfigs: uiConfigEntries,
                  fact: fact?.trim(),
                  assets: assetsList,
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
              throw StateError(
                  "Card file not found for fact_id: $resolvedFactId, maybe it has been deleted");
            }
            rollbackPlaceholderFactId = null;

            if (isNewCard) {
              await emitTimelineCardAdded(
                userId: userId,
                cardId: resolvedFactId,
                cardData: updatedCardData,
              );
            } else {
              await emitTimelineCardUpdated(
                userId: userId,
                cardId: resolvedFactId,
                cardData: updatedCardData,
              );
            }

            // Log event
            try {
              // Determine card file path from fact_id
              final parts = resolvedFactId.split('#');
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
                  metadata: {'fact_id': resolvedFactId, 'title': title},
                );
              }
            } catch (e) {
              // Event logging failure should not break tool
            }

            // For a brand-new card, re-publish userInputSubmitted so the
            // independently-running comment agent (the only remaining
            // subscriber) reacts to the new record. Editing/repairing an
            // existing card does not re-trigger comments.
            if (isNewCard) {
              try {
                await GlobalEventBus.instance.publish(
                  userId: userId,
                  event: SystemEvent(
                    type: SystemEventTypes.userInputSubmitted,
                    source: 'timeline_card_skill.save_timeline_card',
                    payload: UserInputSubmittedPayload(
                      factId: resolvedFactId,
                      assetPaths: const [],
                      combinedText: fact?.trim() ?? '',
                      markdownEntry: '',
                      createdAtTs: updatedCardData.timestamp,
                      pkmCreatedAtTs: updatedCardData.timestamp.toDouble(),
                    ),
                  ),
                );
              } catch (e) {
                // Comment triggering is best-effort; never fail the save.
                logger.warning(
                    'Failed to publish userInputSubmitted for $resolvedFactId: $e');
              }

              // Enqueue the new record for background long-term memory sync
              // (batched + curated by MemoryAgent). Best-effort.
              try {
                await MemorySyncService.instance
                    .enqueueFact(userId, resolvedFactId);
              } catch (e) {
                logger.warning(
                    'Failed to enqueue memory sync for $resolvedFactId: $e');
              }
            }

            return AgentToolResult(
              content: TextPart('Successfully saved timeline card.'),
              stopFlag: stopAfterSuccessSaveCard ||
                  (isSubAgent && _nonEmpty(finish_summary)),
              metadata: {
                'artifact': {
                  'type': 'card',
                  'id': resolvedFactId,
                  'title': title ?? updatedCardData.title,
                  'tags': tagNames,
                  'updated': true,
                },
                if (isSubAgent && _nonEmpty(finish_summary))
                  'child_terminal_result': {
                    'status': 'completed',
                    'summary': finish_summary!.trim(),
                    'fact_id': resolvedFactId,
                    'card_changed': true,
                  },
              },
            );
          } catch (e, stack) {
            final factIdToRollback = rollbackPlaceholderFactId;
            if (factIdToRollback != null) {
              try {
                await fileService.deleteCard(userId, factIdToRollback);
                logger.warning(
                    'Rolled back empty processing placeholder after save_timeline_card failed: $factIdToRollback');
              } catch (deleteError) {
                logger.warning(
                    'Failed to roll back processing placeholder $factIdToRollback: $deleteError');
              }
            }
            logger.severe("SaveTimelineCard failed", e, stack);
            rethrow;
          }
        },
      ),
    ];
  }

  static List<dynamic> _normalizeListArgument(dynamic value, String name) {
    if (value is List) {
      return value;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        throw ArgumentError('$name must be a non-empty array.');
      }
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded;
        }
        throw ArgumentError(
            '$name must be an array or a JSON-encoded array string.');
      } on FormatException catch (e) {
        throw ArgumentError('$name must be valid JSON when passed as a string: '
            '${e.message}');
      }
    }
    throw ArgumentError(
        '$name must be an array or a JSON-encoded array string, got ${value.runtimeType}.');
  }

  static bool _isEmptyProcessingPlaceholder(CardData card) {
    if (card.status != 'processing') return false;
    if (card.fact?.trim().isNotEmpty ?? false) return false;
    if (card.title?.trim().isNotEmpty ?? false) return false;
    if (card.assets.isNotEmpty) return false;
    if (card.uiConfigs.isEmpty) return true;
    if (card.uiConfigs.length != 1) return false;

    final config = card.uiConfigs.single;
    if (config.templateId != 'classic_card') return false;

    final content = config.data['content'];
    if (content != null && content.toString().trim().isNotEmpty) {
      return false;
    }

    return config.data.entries.every((entry) {
      if (entry.key == 'content') return true;
      final value = entry.value;
      if (value == null) return true;
      if (value is String) return value.trim().isEmpty;
      if (value is Iterable) return value.isEmpty;
      if (value is Map) return value.isEmpty;
      return false;
    });
  }

  static Future<void> _validateUiConfigMediaReferences({
    required String userId,
    required int configIndex,
    required Map<String, dynamic> config,
  }) async {
    final data = config['data'];
    if (data is! Map) return;
    await _validateMediaReferencesInValue(
      userId: userId,
      path: 'ui_configs[$configIndex].data',
      value: Map<String, dynamic>.from(data),
    );
  }

  static Future<void> _validateMediaReferencesInValue({
    required String userId,
    required String path,
    required dynamic value,
    bool isUrlField = false,
  }) async {
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString();
        await _validateMediaReferencesInValue(
          userId: userId,
          path: '$path.$key',
          value: entry.value,
          isUrlField: isUrlField || _isUrlFieldName(key),
        );
      }
      return;
    }

    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        await _validateMediaReferencesInValue(
          userId: userId,
          path: '$path[$i]',
          value: value[i],
          isUrlField: isUrlField,
        );
      }
      return;
    }

    if (value is String) {
      await _validateMediaReferenceString(
        userId: userId,
        path: path,
        value: value,
        isUrlField: isUrlField,
      );
    }
  }

  static Future<void> _validateMediaReferenceString({
    required String userId,
    required String path,
    required String value,
    required bool isUrlField,
  }) async {
    if (!isUrlField) return;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (!trimmed.contains('fs://')) return;

    if (trimmed.startsWith('fs://')) {
      await _resolveRequiredAssetReference(
        userId: userId,
        reference: trimmed,
        path: path,
      );
      return;
    }

    throw ArgumentError(
      '$path must use a bare `fs://filename.ext` reference, not markdown or surrounding text: "$value".',
    );
  }

  static Future<AssetReference> _resolveRequiredAssetReference({
    required String userId,
    required String reference,
    required String path,
  }) async {
    if (!reference.startsWith('fs://')) {
      throw ArgumentError(
        '$path must be a bare `fs://filename.ext` reference to an existing image or audio file under Facts/assets; got "$reference".',
      );
    }

    final fileName = AssetReferenceService.extractFileNameFromReference(
      reference,
    );
    if (fileName == null) {
      throw ArgumentError(
        '$path has an invalid local media reference "$reference". Use a bare `fs://filename.ext` reference with a supported image or audio extension.',
      );
    }
    if (reference != 'fs://$fileName') {
      throw ArgumentError(
        '$path must be exactly `fs://$fileName`; do not add markdown, query strings, paths, or surrounding text.',
      );
    }

    final asset = await AssetReferenceService.resolveExistingFileName(
      userId: userId,
      fileName: fileName,
    );
    if (asset == null) {
      throw ArgumentError(
        '$path references "$reference", but no supported image or audio file with that name exists under Facts/assets.',
      );
    }
    return asset;
  }

  static bool _isUrlFieldName(String key) => key.toLowerCase().contains('url');
}
