import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/agent/super_agent/pending_tool_image_buffer.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/webview_snapshot_service.dart';
import 'package:memex/ui/core/cards/native_card_factory.dart';
import 'package:memex/ui/core/widgets/html_webview_card.dart';
import 'package:memex/agent/skills/dynamic_timeline_ui/design_pattern_library.dart';
import 'package:screenshot/screenshot.dart';

final _logger = Logger('DynamicTimelineUiSkill');

/// Skill for creating display-only dynamic HTML cards on the Timeline.
class DynamicTimelineUiSkill extends Skill {
  /// [extraTools] lets a host inject additional tools that only become visible
  /// when this skill is active — used by the subagent runtime to expose scoped
  /// file tools (Read/Write/Edit on the template dir) ONLY while a worker is
  /// actually designing a template. Defaults to none, so the SuperAgent's own
  /// use of this skill is unchanged.
  DynamicTimelineUiSkill(
      {super.forceActivate, List<Tool> extraTools = const []})
      : super(
          name: 'dynamic_timeline_ui',
          description:
              'Designs, previews, and saves reusable HTML Timeline templates. '
              'This is a sub-step of the card-creation flow, used when no '
              'built-in template fits the record being captured or the user '
              'wants custom visuals. It does NOT create or update Timeline '
              'cards itself — after designing a template here, the card is '
              'created/updated via manage_timeline_card.save_timeline_card '
              'with the saved template_id and matching data fields.',
          systemPrompt: _buildSystemPrompt(),
          tools: [..._buildTools(), ...extraTools],
        );

  static String _buildSystemPrompt() {
    return '''
# Dynamic Timeline UI Skill

Use this skill when the user explicitly wants a custom visual card, timeline UI, mini dashboard, generated view, or a style/layout change that should appear on the Memex Timeline.

This skill is a sub-step of card creation: design a reusable template here, then go back to `manage_timeline_card.save_timeline_card` (passing the template_id) to actually create or update the card. Designing a template alone does not produce a card.

You are a template designer. Your job is to create or update reusable HTML templates, not Timeline cards.
- Manage template markup through file tools. For a given template_id, edit `/_UserSettings/Templates/<template_id>/view.html` with Read/Write/Edit.
  `save_timeline_template` only updates template metadata after the file content is in place.
- Generate self-contained HTML/CSS templates only.
- Use `{{variable_name}}` placeholders for all user/card-specific content.
- Every placeholder must be declared in the structured `fields` list passed to `save_timeline_template`.
- Each field must include `name`, `type`, `required`, and `description`.
- Supported field types are `String`, `Number`, and `Boolean`. Placeholder values must be scalar plain text when rendered; do not design fields that expect HTML, lists, maps, or rich markup.
- Write `use_case` and field descriptions so `manage_timeline_card` can choose and fill this template from the template catalog.
- Do not include JavaScript, iframes, forms, network calls, external scripts, external stylesheets, or event handler attributes.
- Keep the card compact and mobile-first. It will be rendered inside a Timeline WebView card.
- Prefer a single root container, inline CSS, readable text, and responsive dimensions.
- For image or media presentation, define URL-like string fields whose names include `url`, such as `image_url` or `cover_url`, and render them in safe HTML attributes such as `<img src="{{image_url}}">`.
- The template is display-only. If the user asks for actual system actions, use the appropriate action/tool skill instead of faking controls in HTML.
- Before generating HTML, call `recommend_dynamic_timeline_design_patterns` or `get_dynamic_timeline_design_pattern` unless the user explicitly provides a complete design direction.
- Treat design patterns as reference material, not rigid templates. Adapt the HTML to the user content and constraints.
- After generating HTML and BEFORE calling `save_timeline_template`, call `preview_dynamic_timeline_card_render` to render the template exactly as the Timeline WebView card will show it. Use plausible sample text in placeholders before previewing if needed. The rendered image arrives as the next message, so inspect it for layout, spacing, overflow, contrast, and clipped/empty content before deciding whether to revise the HTML, re-preview, or save. If the preview tool reports that rendering is unavailable, fall back to checking the HTML against the rules above.
- The outermost element must not set border-radius; Flutter applies the card radius. Inner elements may use rounded corners.
- When updating an existing template_id, `save_timeline_template` overwrites the old template.

Finish by returning a concise result: what template was saved, template_id, use_case, and field schema.
''';
  }

  static List<Tool> _buildTools() {
    return [
      Tool(
        name: 'recommend_dynamic_timeline_design_patterns',
        description:
            'Recommend visual design patterns for a dynamic Timeline UI request based on user intent, content, and constraints.',
        parameterMode: ToolParameterMode.object,
        parameters: {
          'type': 'object',
          'properties': {
            'intent': {
              'type': 'string',
              'description':
                  'What the user wants to do, for example "record two photos", "review a project", or "compare options".',
            },
            'content_summary': {
              'type': 'string',
              'description':
                  'Short summary of the source content or user data that will drive the UI.',
            },
            'constraints': {
              'type': 'string',
              'description':
                  'User style constraints or feedback, for example "more editorial", "less text", "dashboard", "warmer".',
            },
            'limit': {
              'type': 'integer',
              'description': 'Number of candidates to return. Defaults to 3.',
            },
          },
          'required': ['intent'],
        },
        executable: (Map<String, dynamic> args) {
          return DynamicTimelineDesignPatternLibrary.recommendationJson(
            intent: args['intent']?.toString() ?? '',
            contentSummary: args['content_summary']?.toString(),
            constraints: args['constraints']?.toString(),
            limit: (args['limit'] as num?)?.toInt() ?? 3,
          );
        },
      ),
      Tool(
        name: 'get_dynamic_timeline_design_pattern',
        description:
            'Get the full design rules and HTML reference example for a dynamic Timeline UI pattern.',
        parameters: {
          'type': 'object',
          'properties': {
            'pattern_id': {
              'type': 'string',
              'description':
                  'Design pattern id returned by recommend_dynamic_timeline_design_patterns.',
            },
          },
          'required': ['pattern_id'],
        },
        executable: (String patternId) {
          return DynamicTimelineDesignPatternLibrary.patternJson(patternId);
        },
      ),
      Tool(
        name: 'list_dynamic_timeline_design_patterns',
        description:
            'List all available dynamic Timeline UI design pattern summaries.',
        parameters: {
          'type': 'object',
          'properties': {},
        },
        executable: () {
          return DynamicTimelineDesignPatternLibrary.catalogJson();
        },
      ),
      Tool(
        name: 'preview_dynamic_timeline_card_render',
        description:
            'Render candidate HTML or an existing saved template exactly as the Timeline WebView card will display it and return the result as an image for visual inspection. '
            'Pass either html or template_id. Call this before save_timeline_template so you can verify layout, spacing, overflow, and contrast.',
        parameterMode: ToolParameterMode.object,
        parameters: {
          'type': 'object',
          'properties': {
            'html': {
              'type': 'string',
              'description':
                  'Self-contained HTML/CSS to preview. Scripts, iframes, external resources, forms, and event handler attributes are not allowed.',
            },
            'template_id': {
              'type': 'string',
              'description':
                  'Existing saved Timeline template ID to preview. Use this when redesigning or evaluating a current template.',
            },
            'data': {
              'type': 'object',
              'description':
                  'Optional sample data for previewing a template_id. If omitted, representative sample data is used when available.',
            },
            'width': {
              'type': 'number',
              'description':
                  'Optional logical render width in dp. Defaults to 390 (the Timeline card width). Use the default unless the user needs a specific width.',
            },
          },
        },
        executable: (Map<String, dynamic> args) => _previewDynamicTimelineCard(
          html: args['html']?.toString(),
          templateId: args['template_id']?.toString(),
          data: args['data'] is Map
              ? Map<String, dynamic>.from(args['data'] as Map)
              : null,
          width: (args['width'] as num?)?.toDouble(),
        ),
      ),
      Tool(
        name: 'save_timeline_template',
        description:
            'Save or update a reusable HTML Timeline template under the user workspace. If template_id already exists, it is overwritten.',
        parameters: {
          'type': 'object',
          'properties': {
            'template_id': {
              'type': 'string',
              'description':
                  'Template ID, for example shopping_receipt_v2. Use lowercase letters, numbers, and underscores; start with a letter.',
            },
            'description': {
              'type': 'string',
              'description':
                  'Short template description for the template catalog.',
            },
            'use_case': {
              'type': 'string',
              'description':
                  'Use case explaining when manage_timeline_card should select this template.',
            },
            'fields': {
              'type': 'array',
              'description':
                  'Structured field definitions for all {{variable_name}} placeholders. '
                      'Before calling this tool, use Read/Write/Edit to maintain '
                      '`/_UserSettings/Templates/<template_id>/view.html`.',
              'items': {
                'type': 'object',
                'properties': {
                  'name': {
                    'type': 'string',
                    'description':
                        'Field name. Must match a {{variable_name}} placeholder.',
                  },
                  'type': {
                    'type': 'string',
                    'enum': ['String', 'Number', 'Boolean'],
                    'description':
                        'Scalar data type expected in ui_configs.data.',
                  },
                  'required': {
                    'type': 'boolean',
                    'description':
                        'Whether save_timeline_card must provide this field.',
                  },
                  'description': {
                    'type': 'string',
                    'description':
                        'Field meaning and extraction guidance for manage_timeline_card.',
                  },
                },
                'required': ['name', 'type', 'required', 'description'],
              },
            },
          },
          'required': ['template_id', 'description', 'use_case', 'fields'],
        },
        executable: (
          String templateId,
          String description,
          String useCase,
          dynamic fields,
        ) =>
            _saveTimelineTemplate(
          templateId: templateId,
          description: description,
          useCase: useCase,
          fields: fields,
        ),
      ),
    ];
  }

  static Future<AgentToolResult> _previewDynamicTimelineCard({
    String? html,
    String? templateId,
    Map<String, dynamic>? data,
    double? width,
  }) async {
    final cleanTemplateId = templateId?.trim();
    final rawHtml = html?.trim();
    if ((rawHtml == null || rawHtml.isEmpty) &&
        (cleanTemplateId == null || cleanTemplateId.isEmpty)) {
      throw ArgumentError('Either html or template_id is required.');
    }
    if (rawHtml != null &&
        rawHtml.isNotEmpty &&
        cleanTemplateId != null &&
        cleanTemplateId.isNotEmpty) {
      throw ArgumentError('Pass either html or template_id, not both.');
    }

    final fileService = FileSystemService.instance;
    final userId = _currentUserId();
    TimelineTemplateMeta? previewMeta;
    var previewHtml = rawHtml;
    if (previewHtml == null || previewHtml.isEmpty) {
      final validTemplateId = _validateTemplateId(cleanTemplateId!);
      previewMeta =
          await fileService.readTimelineTemplateMeta(userId, validTemplateId);
      final savedHtml =
          await fileService.readTemplateHtml(userId, validTemplateId);
      if (savedHtml == null || savedHtml.trim().isEmpty) {
        if (isNativeCard(validTemplateId)) {
          final bytes = await _renderNativeTemplatePreview(
            templateId: validTemplateId,
            data: data,
            width: width,
          );
          return _storePreviewImage(
            bytes,
            'Rendered template "$validTemplateId" with the current Timeline card style.',
          );
        }
        throw ArgumentError('Template "$validTemplateId" does not exist.');
      }
      previewHtml = savedHtml;
    }

    // Apply the same safety validation as save so the preview matches what
    // would actually be persisted.
    final cleanHtmlTemplate = sanitizeHtmlForTimeline(previewHtml);
    final previewData = _buildPreviewDataForHtmlTemplate(
      cleanHtmlTemplate,
      explicitData: data,
      fields: previewMeta?.fields,
    );
    final cleanHtml = sanitizeHtmlForTimeline(
      fileService.renderHtmlTemplate(cleanHtmlTemplate, previewData),
    );
    final renderWidth = (width == null || width <= 0) ? 390.0 : width;

    // Wrap with the shared timeline document builder so the snapshot renders
    // pixel-identically to the live Timeline card (no interactive script needed
    // off-screen).
    final document = HtmlWebViewCard.buildTimelineHtmlDocument(cleanHtml);

    final bytes = await WebviewSnapshotService.instance.renderHtmlToImage(
      html: document,
      width: renderWidth,
    );

    if (bytes == null || bytes.isEmpty) {
      return AgentToolResult(
        content: TextPart(
          'Render preview is unavailable on this platform or the snapshot failed. '
          'Could not produce an image. Re-check the HTML against the skill rules '
          '(self-contained, no scripts/iframes/external resources, single root '
          'container, mobile-first) before creating the card.',
        ),
      );
    }

    return _storePreviewImage(
      bytes,
      'Rendered ${cleanTemplateId == null || cleanTemplateId.isEmpty ? "the candidate HTML" : 'template "$cleanTemplateId"'} '
      'at ${renderWidth.toStringAsFixed(0)}dp wide, exactly as the Timeline WebView card will display it.',
    );
  }

  static AgentToolResult _storePreviewImage(Uint8List bytes, String summary) {
    final base64Png = base64Encode(bytes);

    // Do NOT return the image inside the tool result: OpenAI-compatible
    // providers reject images in a function-result message. Instead stash it in
    // the per-session buffer; the SuperAgent after-tool hook injects it as a
    // UserMessage (supported by every provider).
    final sessionId = AgentCallToolContext.current?.state.sessionId ?? '';
    PendingToolImageBuffer.instance.add(
      sessionId,
      ImagePart(base64Png, 'image/png'),
      message: 'Rendered preview(s) of the dynamic timeline card HTML you '
          'generated. Inspect the preview before deciding:',
    );

    return AgentToolResult(
      content: TextPart(
        '$summary The rendered image is attached as the next message — inspect '
        'it now for layout, spacing, overflow, contrast, and clipped/empty '
        'content.',
      ),
    );
  }

  static Future<Uint8List> _renderNativeTemplatePreview({
    required String templateId,
    Map<String, dynamic>? data,
    double? width,
  }) async {
    final previewData = data == null || data.isEmpty
        ? _sampleDataForNativeTemplate(templateId)
        : data;
    final title = previewData['title']?.toString() ?? _sampleTitle(templateId);
    final renderWidth = (width == null || width <= 0) ? 390.0 : width;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(430, 900)),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: SizedBox(
              width: renderWidth,
              child: NativeCardFactory.build(
                templateId: templateId,
                data: previewData,
                title: title,
                status: 'completed',
                tags: const ['Preview'],
              ),
            ),
          ),
        ),
      ),
    );

    return ScreenshotController().captureFromWidget(
      widget,
      delay: const Duration(milliseconds: 100),
      pixelRatio: 2,
      targetSize: Size(renderWidth, 640),
    );
  }

  static String _sampleTitle(String templateId) {
    return switch (templateId) {
      'article' => 'Flow State Notes',
      'snapshot' => 'Dusk Moment',
      'transaction' => 'Coffee Receipt',
      'metric' => 'Health Metrics',
      'task' => 'Product Checklist',
      _ => 'Template Preview',
    };
  }

  static Map<String, dynamic> _sampleDataForNativeTemplate(String templateId) {
    return switch (templateId) {
      'link' => {
          'url': 'https://example.com/article',
          'title': 'Design reference',
          'domain': 'example.com',
        },
      'person' => {
          'name': 'Alex Chen',
          'relation': 'Product designer',
          'status': 'Available',
        },
      'place' => {
          'name': 'Riverside Cafe',
          'address': 'West Bund · Shanghai',
          'lat': 31.2304,
          'lng': 121.4737,
        },
      'spec_sheet' => {
          'name': 'Travel Backpack',
          'subtitle': '28L daily carry',
          'specs': {'Weight': '820g', 'Volume': '28L', 'Material': 'Nylon'},
        },
      'transaction' => {
          'merchant': 'Blue Bottle Coffee',
          'amount': r'$8.60',
          'location': 'San Francisco',
          'items': [
            {'name': 'Latte', 'amount': r'$5.20'},
            {'name': 'Cookie', 'amount': r'$3.40'},
          ],
        },
      'metric' => {
          'items': [
            {
              'title': 'Deep sleep',
              'value': 2.5,
              'unit': 'h',
              'label': 'Last night',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Steps',
              'value': 8342,
              'unit': 'steps',
              'label': 'Today',
              'trend': 'up',
              'color': 'emerald',
            },
          ],
        },
      'rating' => {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5,
          'comment': 'Breathtaking visuals and a memorable ending.',
        },
      'mood' => {
          'mood_name': 'Excited',
          'color_hex': '#F97316',
          'intensity': 8,
          'trigger': 'New project kickoff',
        },
      'progress' => {
          'label': 'Annual reading plan',
          'current': 18,
          'total': 52,
          'unit': 'books',
        },
      'event' => {
          'start_time': '2026-03-10 14:00',
          'end_time': '2026-03-10 16:00',
          'location': 'Conference room A',
        },
      'duration' => {'elapsed': 1500, 'title': 'Pomodoro timer'},
      'task' => {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Competitive analysis', 'completed': true},
            {'title': 'Draft requirements', 'completed': false},
          ],
        },
      'routine' => {
          'habit_name': 'Daily meditation',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      'procedure' => {
          'steps': [
            'Prepare ingredients',
            'Preheat the oven',
            'Mix and fold until combined',
            'Bake for 25 minutes',
          ],
        },
      'snippet' => {'text': 'A compact thought worth remembering.'},
      'article' => {
          'body':
              '## What is flow?\n\nFlow is a state of deep focus where time feels quiet and the work itself becomes rewarding.',
        },
      'conversation' => {
          'messages': [
            {
              'sender': 'Assistant',
              'text': 'What changed today?',
              'isMe': false
            },
            {
              'sender': 'me',
              'text': 'The new card direction feels cleaner.',
              'isMe': true
            },
          ],
        },
      'quote' => {
          'content': 'Make it simple, but significant.',
          'author': 'Don Draper',
        },
      'snapshot' => {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'caption': 'Late afternoon light',
          'location': 'Riverside',
        },
      'gallery' => {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      'video' => {
          'video_url': 'https://example.com/video.mp4',
          'duration': '00:30',
        },
      'compact_card' => {
          'details': ['500ml', 'Cup 4', 'Goal 2000ml'],
          'color': '#3B82F6',
        },
      _ => {
          'content':
              'A short preview note showing the default card appearance.',
        },
    };
  }

  static Future<AgentToolResult> _saveTimelineTemplate({
    required String templateId,
    String? description,
    String? useCase,
    required dynamic fields,
  }) async {
    final cleanTemplateId = _validateTemplateId(templateId);
    final cleanDescription = _validateDescription(description);
    final cleanUseCase = _validateUseCase(useCase);
    final cleanFields = _normalizeTemplateFields(fields);

    final denied = await gateMutatingToolCall(
      toolName: 'save_timeline_template',
      summary: cleanTemplateId,
    );
    if (denied != null) return denied;

    final userId = _currentUserId();
    final fileService = FileSystemService.instance;
    final htmlTemplate =
        await fileService.readTemplateHtml(userId, cleanTemplateId);
    if (htmlTemplate == null || htmlTemplate.trim().isEmpty) {
      throw ArgumentError(
        'Template HTML is required before saving metadata. '
        'Create or edit /_UserSettings/Templates/$cleanTemplateId/view.html '
        'using Read/Write/Edit first.',
      );
    }
    final cleanHtml = sanitizeHtmlForTimeline(htmlTemplate);
    _validateTemplateVariables(cleanHtml, cleanFields);

    final previousMeta = await fileService.readTimelineTemplateMeta(
      userId,
      cleanTemplateId,
    );
    final fieldsChanged = previousMeta != null &&
        !_sameFieldSchema(previousMeta.fields, cleanFields);
    final templateUsages =
        await fileService.findCardTemplateUsages(userId, cleanTemplateId);
    final incompatibleCards = templateUsages
        .where((usage) => !_isDataCompatibleWithFields(
              usage.data,
              cleanFields,
            ))
        .map((usage) => usage.cardId)
        .toSet()
        .toList();

    await fileService.saveTimelineTemplateMeta(
      userId: userId,
      templateId: cleanTemplateId,
      description: cleanDescription,
      useCase: cleanUseCase,
      fields: cleanFields,
    );

    await _logTemplateSavedEvent(
      fileService,
      userId,
      cleanTemplateId,
      previousMeta != null,
      fieldsChanged,
      incompatibleCards,
    );

    final verb = previousMeta == null ? 'Created' : 'Updated';
    final buffer = StringBuffer()
      ..writeln('$verb Timeline HTML template "$cleanTemplateId".')
      ..writeln('Description: $cleanDescription')
      ..writeln('Use Case: $cleanUseCase')
      ..writeln('Fields:')
      ..write(_formatFieldSchema(cleanFields));
    if (incompatibleCards.isNotEmpty) {
      _addTemplateSchemaChangedReminder(
        templateId: cleanTemplateId,
        previousFields: previousMeta?.fields,
        nextFields: cleanFields,
        affectedCards: incompatibleCards,
      );
    }

    return AgentToolResult(
      content: TextPart(buffer.toString().trimRight()),
      metadata: {
        'artifact': ChatArtifact.uiTemplate(
          templateId: cleanTemplateId,
          path: '_UserSettings/Templates/$cleanTemplateId/view.html',
          updated: previousMeta != null,
        ).toJson(),
      },
    );
  }

  static String sanitizeHtmlForTimeline(String value) {
    var html = value.trim();
    if (html.startsWith('```')) {
      html = html
          .replaceFirst(RegExp(r'^```(?:html)?\s*', caseSensitive: false), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }
    if (html.isEmpty) {
      throw ArgumentError('html is required');
    }
    if (html.length > 60000) {
      throw ArgumentError('html is too large for a Timeline card.');
    }

    final lower = html.toLowerCase();
    const blockedNeedles = [
      '<script',
      '</script',
      '<iframe',
      '<object',
      '<embed',
      '<form',
      '<input',
      '<button',
      '<link',
      '<meta',
      'javascript:',
      'data:text/html',
      'srcdoc=',
    ];
    for (final needle in blockedNeedles) {
      if (lower.contains(needle)) {
        throw ArgumentError('html contains unsupported content: $needle');
      }
    }

    final eventAttributePattern =
        RegExp(r'\son[a-z]+\s*=', caseSensitive: false);
    if (eventAttributePattern.hasMatch(html)) {
      throw ArgumentError('html event handler attributes are not supported.');
    }

    return html;
  }

  static String _currentUserId() {
    final context = AgentCallToolContext.current;
    if (context == null) {
      throw StateError(
        'Dynamic timeline UI tools must run inside an agent execution context.',
      );
    }
    final userId = context.state.metadata['userId']?.toString();
    if (userId == null || userId.isEmpty) {
      throw StateError('Agent state metadata does not include userId.');
    }
    return userId;
  }

  static String _validateTemplateId(String value) {
    final cleanValue = value.trim();
    if (cleanValue.isEmpty) {
      throw ArgumentError('template_id is required');
    }
    if (!RegExp(r'^[a-z][a-z0-9_]{1,63}$').hasMatch(cleanValue)) {
      throw ArgumentError(
        'template_id must start with a lowercase letter and contain only lowercase letters, numbers, and underscores.',
      );
    }
    return cleanValue;
  }

  static String _validateDescription(String? value) {
    final cleanValue = value?.trim();
    if (cleanValue == null || cleanValue.isEmpty) {
      throw ArgumentError('description is required');
    }
    if (cleanValue.length > 400) {
      throw ArgumentError('description must be 400 characters or fewer.');
    }
    return cleanValue;
  }

  static String _validateUseCase(String? value) {
    final cleanValue = value?.trim();
    if (cleanValue == null || cleanValue.isEmpty) {
      throw ArgumentError('use_case is required');
    }
    if (cleanValue.length > 600) {
      throw ArgumentError('use_case must be 600 characters or fewer.');
    }
    return cleanValue;
  }

  static Map<String, dynamic> _buildPreviewDataForHtmlTemplate(
    String html, {
    Map<String, dynamic>? explicitData,
    List<TimelineTemplateFieldMeta>? fields,
  }) {
    final data = <String, dynamic>{};
    final variables = _extractTemplateVariables(html);
    final fieldsByName = {
      for (final field in fields ?? const <TimelineTemplateFieldMeta>[])
        field.name: field,
    };

    for (final variable in variables) {
      data[variable] = _sampleValueForTemplateField(
        variable,
        fieldsByName[variable],
      );
    }

    if (explicitData != null) {
      data.addAll(explicitData);
    }
    return data;
  }

  static Set<String> _extractTemplateVariables(String html) {
    return RegExp(r'\{\{\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\}\}')
        .allMatches(html)
        .map((match) => match.group(1)!)
        .toSet();
  }

  static dynamic _sampleValueForTemplateField(
    String name,
    TimelineTemplateFieldMeta? field,
  ) {
    if (field?.type == 'Number') return 42;
    if (field?.type == 'Boolean') return true;

    final lowerName = name.toLowerCase();
    if (lowerName.contains('image') || lowerName.contains('photo')) {
      return 'https://picsum.photos/600/400?random=42';
    }
    if (lowerName.contains('url') || lowerName.contains('link')) {
      return 'https://example.com';
    }
    if (lowerName.contains('date')) return '2026-03-10';
    if (lowerName.contains('time')) return '14:30';
    if (lowerName.contains('title')) return 'Preview title';
    if (lowerName.contains('amount') ||
        lowerName.contains('price') ||
        lowerName.contains('total') ||
        lowerName.contains('count') ||
        lowerName.contains('score')) {
      return '42';
    }
    return 'Preview ${name.replaceAll("_", " ")}';
  }

  static List<dynamic> _normalizeListArgument(dynamic value, String name) {
    if (value is List) {
      return value;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return const [];
      }
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded;
        }
      } on FormatException catch (e) {
        throw ArgumentError('$name must be valid JSON when passed as a string: '
            '${e.message}');
      }
    }
    throw ArgumentError(
      '$name must be an array or a JSON-encoded array string, got ${value.runtimeType}.',
    );
  }

  static List<TimelineTemplateFieldMeta> _normalizeTemplateFields(
      dynamic value) {
    final rawFields = _normalizeListArgument(value, 'fields');
    if (rawFields.isEmpty) {
      throw ArgumentError('fields is required');
    }
    final fields = <TimelineTemplateFieldMeta>[];
    final names = <String>{};
    final pattern = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
    for (final raw in rawFields) {
      if (raw is! Map) {
        throw ArgumentError(
          'Each fields item must be an object with name, type, required, and description.',
        );
      }
      final map = Map<String, dynamic>.from(raw);
      final name = map['name']?.toString().trim() ?? '';
      if (!pattern.hasMatch(name)) {
        throw ArgumentError(
          'Invalid field "$name"; fields.name must contain only letters, numbers, and underscores, and cannot start with a number.',
        );
      }
      if (!names.add(name)) {
        throw ArgumentError('Duplicate field "$name".');
      }
      final type = map['type']?.toString().trim() ?? '';
      if (!{'String', 'Number', 'Boolean'}.contains(type)) {
        throw ArgumentError(
          'Field "$name" has invalid type "$type"; supported types are String, Number, and Boolean.',
        );
      }
      final required = map['required'];
      if (required is! bool) {
        throw ArgumentError('Field "$name" required must be a boolean.');
      }
      final description = map['description']?.toString().trim() ?? '';
      if (description.isEmpty) {
        throw ArgumentError('Field "$name" description is required.');
      }
      fields.add(TimelineTemplateFieldMeta(
        name: name,
        type: type,
        required: required,
        description: description,
      ));
    }
    return fields;
  }

  static void _validateTemplateVariables(
    String html,
    List<TimelineTemplateFieldMeta> fields,
  ) {
    final variablePattern = RegExp(r'\{\{\s*([^}]+?)\s*\}\}');
    final used = <String>{};
    final invalid = <String>[];
    final namePattern = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
    for (final match in variablePattern.allMatches(html)) {
      final variable = match.group(1)!.trim();
      if (!namePattern.hasMatch(variable)) {
        invalid.add(variable);
      } else {
        used.add(variable);
      }
    }
    if (invalid.isNotEmpty) {
      throw ArgumentError(
        'Template variables use invalid names: ${invalid.join(", ")}.',
      );
    }
    final declared = fields.map((field) => field.name).toSet();
    final undefined = used.difference(declared);
    if (undefined.isNotEmpty) {
      throw ArgumentError(
        'Template variables not declared in fields: ${undefined.join(", ")}.',
      );
    }
    final unused = declared.difference(used);
    if (unused.isNotEmpty) {
      throw ArgumentError(
        'Fields declared but not used in HTML: ${unused.join(", ")}.',
      );
    }
  }

  static bool _sameFieldSchema(
    List<TimelineTemplateFieldMeta> a,
    List<TimelineTemplateFieldMeta> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].name != b[i].name ||
          a[i].type != b[i].type ||
          a[i].required != b[i].required ||
          a[i].description != b[i].description) {
        return false;
      }
    }
    return true;
  }

  static bool _isDataCompatibleWithFields(
    Map<String, dynamic> data,
    List<TimelineTemplateFieldMeta> fields,
  ) {
    final expected = fields.map((field) => field.name).toSet();
    final required = fields
        .where((field) => field.required)
        .map((field) => field.name)
        .toSet();
    final actual = data.keys.map((key) => key.toString()).toSet();
    if (required.difference(actual).isNotEmpty) return false;
    if (actual.difference(expected).isNotEmpty) return false;

    for (final field in fields) {
      if (!data.containsKey(field.name)) continue;
      final value = data[field.name];
      if (value == null) return false;
      if (value is Map || value is List) return false;
      if (field.type == 'String' && value is! String) return false;
      if (field.type == 'Number' && value is! num) return false;
      if (field.type == 'Boolean' && value is! bool) return false;
    }
    return true;
  }

  static String _formatFieldSchema(List<TimelineTemplateFieldMeta> fields) {
    return fields
        .map(
          (field) =>
              '- `${field.name}` (${field.type}, ${field.required ? "required" : "optional"}): ${field.description}',
        )
        .join('\n');
  }

  static void _addTemplateSchemaChangedReminder({
    required String templateId,
    required List<TimelineTemplateFieldMeta>? previousFields,
    required List<TimelineTemplateFieldMeta> nextFields,
    required List<String> affectedCards,
  }) {
    final state = AgentCallToolContext.current?.state;
    if (state == null) return;
    state.systemReminders['timeline_template_schema_changed_$templateId'] = '''
Timeline template "$templateId" was saved with a field schema that is incompatible with existing cards.

${previousFields == null ? 'No previous saved HTML template metadata exists for this template_id. Existing cards using this template_id may render with the newly saved template.' : 'Previous field schema:\n${_formatFieldSchema(previousFields)}'}

New field schema:
${_formatFieldSchema(nextFields)}

Existing cards using this template may need updated ui_configs.data:
${affectedCards.map((id) => '- $id').join('\n')}
'''
        .trim();
  }

  static Future<void> _logTemplateSavedEvent(
    FileSystemService fileService,
    String userId,
    String templateId,
    bool updated,
    bool fieldsChanged,
    List<String> affectedCards,
  ) async {
    try {
      await fileService.eventLogService.logFileModified(
        userId: userId,
        filePath: '_UserSettings/Templates/$templateId/view.html',
        description: updated
            ? 'Agent updated timeline HTML template'
            : 'Agent created timeline HTML template',
        metadata: {
          'template_id': templateId,
          'fields_changed': fieldsChanged,
          'affected_cards': affectedCards,
        },
      );
    } catch (e) {
      _logger.warning('Failed to log dynamic timeline template save: $e');
    }
  }
}
