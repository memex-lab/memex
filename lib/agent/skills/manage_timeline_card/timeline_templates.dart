/// Allowed template IDs derived from [timelineTemplates].
Set<String> get allowedTemplateIds =>
    timelineTemplates.map((t) => t['template_id'] as String).toSet();

// --- Validation helpers (Pydantic-style checks) ---

void _reqStr(Map<String, dynamic> data, String key, [String? templateId]) {
  final v = data[key];
  if (v == null) {
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: required field "$key" is missing.',
    );
  }
  if (v is! String) {
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: "$key" must be String, got ${v.runtimeType}.',
    );
  }
  if (v.trim().isEmpty &&
      (key == 'url' ||
          key == 'body' ||
          key == 'text' ||
          key == 'content' ||
          key == 'image_url' ||
          key == 'video_url')) {
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: "$key" must not be empty.',
    );
  }
}

void _reqNum(Map<String, dynamic> data, String key, [String? templateId]) {
  final v = data[key];
  if (v == null) {
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: required field "$key" is missing.',
    );
  }
  if (v is! num) {
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: "$key" must be Number, got ${v.runtimeType}.',
    );
  }
}

void _reqInt(Map<String, dynamic> data, String key, [String? templateId]) {
  final v = data[key];
  if (v == null) {
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: required field "$key" is missing.',
    );
  }
  if (v is! int) {
    if (v is num && v.toInt() == v) {
      return; // allow double that is whole number
    }
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: "$key" must be int, got ${v.runtimeType}.',
    );
  }
}

void _reqList(Map<String, dynamic> data, String key, [String? templateId]) {
  final v = data[key];
  if (v == null) {
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: required field "$key" is missing.',
    );
  }
  if (v is! List) {
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: "$key" must be List, got ${v.runtimeType}.',
    );
  }
}

void _reqNonEmptyStr(
  Map<String, dynamic> data,
  String key, [
  String? templateId,
]) {
  _reqStr(data, key, templateId);
  final v = data[key] as String;
  if (v.trim().isEmpty) {
    throw ArgumentError(
      'Template${templateId != null ? " $templateId" : ""}: "$key" must not be empty.',
    );
  }
}

void _optStr(Map<String, dynamic> data, String key) {
  final v = data[key];
  if (v != null && v is! String) {
    throw ArgumentError(
      'Optional "$key" must be String if present, got ${v.runtimeType}.',
    );
  }
}

void _optNum(Map<String, dynamic> data, String key) {
  final v = data[key];
  if (v != null && v is! num) {
    throw ArgumentError(
      'Optional "$key" must be Number if present, got ${v.runtimeType}.',
    );
  }
}

void _optBool(Map<String, dynamic> data, String key) {
  final v = data[key];
  if (v != null && v is! bool) {
    throw ArgumentError(
      'Optional "$key" must be Boolean if present, got ${v.runtimeType}.',
    );
  }
}

/// Validates `data` for the given [templateId]. Throws [ArgumentError] if invalid.
void validateTemplateData(String templateId, Map<String, dynamic> data) {
  final t = templateId;
  switch (templateId) {
    case 'link':
      _reqStr(data, 'url', t);
      _optStr(data, 'title');
      _optStr(data, 'domain');
      break;
    case 'person':
      _reqStr(data, 'name', t);
      _optStr(data, 'image_url');
      _optStr(data, 'relation');
      _optStr(data, 'status');
      break;
    case 'place':
      _reqStr(data, 'name', t);
      _optStr(data, 'address');
      _optNum(data, 'latitude');
      _optNum(data, 'lat');
      _optNum(data, 'longitude');
      _optNum(data, 'lng');
      break;
    case 'spec_sheet':
      _optStr(data, 'name');
      _optStr(data, 'image_url');
      _optStr(data, 'subtitle');
      if (data['specs'] != null && data['specs'] is! Map) {
        throw ArgumentError('Template $t: "specs" must be Map if present.');
      }
      break;
    case 'transaction':
      _reqStr(data, 'merchant', t);
      _reqStr(data, 'amount', t);
      _optStr(data, 'location');
      if (data['items'] != null) {
        final itemsList = data['items'];
        if (itemsList is! List) {
          throw ArgumentError('Template $t: "items" must be List.');
        }
        for (var i = 0; i < itemsList.length; i++) {
          final item = itemsList[i];
          if (item is! Map) {
            throw ArgumentError('Template $t: items[$i] must be Map.');
          }
          final m = Map<String, dynamic>.from(item);
          _reqStr(m, 'name', t);
          _reqStr(m, 'amount', t);
        }
      }
      break;
    case 'metric':
      _reqList(data, 'items', t);
      _optStr(data, 'title');
      final items = data['items'];
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is! Map) {
          throw ArgumentError('Template $t: items[$i] must be Map.');
        }
        final m = Map<String, dynamic>.from(item);
        _reqStr(m, 'title', t);
        _reqNum(m, 'value', t);
        _optStr(m, 'unit');
        _optStr(m, 'label');
        _optStr(m, 'trend');
        _optStr(m, 'color');
      }
      break;
    case 'rating':
      _reqStr(data, 'subject', t);
      _reqNum(data, 'score', t);
      _optNum(data, 'max_score');
      _optStr(data, 'comment');
      break;
    case 'mood':
      final moodVal = data['mood_name'] ?? data['mood'];
      if (moodVal == null) {
        throw ArgumentError(
          'Template $t: required "mood_name" or "mood" is missing.',
        );
      }
      if (moodVal is! String) {
        throw ArgumentError('Template $t: mood_name/mood must be String.');
      }
      _reqStr(data, 'color_hex', t);
      _optNum(data, 'intensity');
      _optStr(data, 'trigger');
      break;
    case 'progress':
      _reqNum(data, 'current', t);
      _reqNum(data, 'total', t);
      _optStr(data, 'unit');
      _optStr(data, 'label');
      break;
    case 'event':
      _reqStr(data, 'start_time', t);
      _optStr(data, 'title');
      _optStr(data, 'end_time');
      _optStr(data, 'location');
      break;
    case 'duration':
      _reqInt(data, 'elapsed', t);
      _optStr(data, 'title');
      break;
    case 'task':
      _optStr(data, 'title');
      _optBool(data, 'is_completed');
      _optStr(data, 'priority');
      _optStr(data, 'due_date');
      if (data['subtasks'] != null) {
        final subtasksList = data['subtasks'];
        if (subtasksList is! List) {
          throw ArgumentError('Template $t: "subtasks" must be List.');
        }
        for (var i = 0; i < subtasksList.length; i++) {
          final item = subtasksList[i];
          if (item is! Map) {
            throw ArgumentError('Template $t: subtasks[$i] must be Map.');
          }
          final m = Map<String, dynamic>.from(item);
          _reqStr(m, 'title', t);
          _optBool(m, 'completed');
        }
      }
      break;
    case 'routine':
      _reqStr(data, 'habit_name', t);
      _reqNum(data, 'streak', t);
      if (data['history'] != null) {
        if (data['history'] is! List) {
          throw ArgumentError('Template $t: "history" must be List.');
        }
      }
      break;
    case 'procedure':
      _reqList(data, 'steps', t);
      _optStr(data, 'title');
      final steps = data['steps'];
      for (var i = 0; i < steps.length; i++) {
        if (steps[i] is! String) {
          throw ArgumentError('Template $t: steps[$i] must be String.');
        }
      }
      break;
    case 'compact':
      _reqStr(data, 'color', t);
      _optStr(data, 'title');
      _optStr(data, 'icon');
      if (data['details'] != null) {
        if (data['details'] is! List) {
          throw ArgumentError('Template $t: "details" must be List.');
        }
      }
      break;
    case 'digest':
      _reqNonEmptyStr(data, 'summary', t);
      _reqList(data, 'sections', t);
      final sections = data['sections'];
      if (sections.isEmpty) {
        throw ArgumentError('Template $t: "sections" must not be empty.');
      }
      for (var i = 0; i < sections.length; i++) {
        final section = sections[i];
        if (section is! Map) {
          throw ArgumentError('Template $t: sections[$i] must be Map.');
        }
        final m = Map<String, dynamic>.from(section);
        _reqNonEmptyStr(m, 'type', t);
        _reqNonEmptyStr(m, 'title', t);
        _reqList(m, 'items', t);
        final items = m['items'];
        if (items.isEmpty) {
          throw ArgumentError(
            'Template $t: sections[$i].items must not be empty.',
          );
        }
        for (var j = 0; j < items.length; j++) {
          if (items[j] is! String || (items[j] as String).trim().isEmpty) {
            throw ArgumentError(
              'Template $t: sections[$i].items[$j] must be a non-empty String.',
            );
          }
        }
      }
      break;
    case 'snippet':
      _reqStr(data, 'text', t);
      _optStr(data, 'style');
      if (data['tags'] != null) {
        if (data['tags'] is! List) {
          throw ArgumentError('Template $t: "tags" must be List.');
        }
      }
      break;
    case 'article':
      _reqStr(data, 'body', t);
      _optStr(data, 'title');
      _optStr(data, 'image_url');
      break;
    case 'conversation':
      _reqList(data, 'messages', t);
      _optStr(data, 'title');
      final messagesList = data['messages'];
      for (var i = 0; i < messagesList.length; i++) {
        final msg = messagesList[i];
        if (msg is! Map) {
          throw ArgumentError('Template $t: messages[$i] must be Map.');
        }
        final m = Map<String, dynamic>.from(msg);
        _reqStr(m, 'text', t);
        _optStr(m, 'sender');
        _optBool(m, 'isMe');
      }
      break;
    case 'quote':
      _reqStr(data, 'content', t);
      _optStr(data, 'author');
      _optStr(data, 'source');
      break;
    case 'snapshot':
      _reqStr(data, 'image_url', t);
      _optStr(data, 'caption');
      _optStr(data, 'location');
      break;
    case 'gallery':
      _reqList(data, 'image_urls', t);
      _optStr(data, 'title');
      break;
    case 'video':
      _reqStr(data, 'video_url', t);
      _optStr(data, 'title');
      _optStr(data, 'duration');
      break;
    default:
      throw ArgumentError(
        'Unknown template_id: "$templateId". Allowed: ${allowedTemplateIds.join(", ")}.',
      );
  }
}

/// Validates one ui_config entry (must have template_id and data; data validated per template).
/// Throws [ArgumentError] with clear message if invalid.
void validateUiConfig(Map<String, dynamic> config) {
  if (!config.containsKey('template_id')) {
    throw ArgumentError('ui_configs entry missing "template_id".');
  }
  final tid = config['template_id'];
  if (tid is! String || tid.isEmpty) {
    throw ArgumentError(
      'ui_configs entry "template_id" must be a non-empty String.',
    );
  }
  final templateId = tid;
  if (!allowedTemplateIds.contains(templateId)) {
    throw ArgumentError(
      'template_id "$templateId" is not allowed. Allowed: ${allowedTemplateIds.join(", ")}.',
    );
  }
  if (!config.containsKey('data')) {
    throw ArgumentError(
      'ui_configs entry for template "$templateId" missing "data".',
    );
  }
  final data = config['data'];
  if (data is! Map) {
    throw ArgumentError(
      'ui_configs entry for template "$templateId": "data" must be an object (Map).',
    );
  }
  validateTemplateData(templateId, Map<String, dynamic>.from(data));
}

final List<Map<String, dynamic>> timelineTemplates = [
  {
    'template_id': 'link',
    'use_case': 'Web links, article links, resource links, etc.',
    'data_structure': '''
- `url` (String, required): Link address.
- `title` (String, optional): Link title (defaults to card title).
- `domain` (String, optional): Domain name, automatically extracted from URL if not provided.
''',
  },
  {
    'template_id': 'person',
    'use_case': 'Person information, contacts, social relationships, etc.',
    'data_structure': '''
- `name` (String, required): Name.
- `image_url` (String, optional): Avatar link.
- `relation` (String, optional): Relationship, e.g., "Colleague", "Friend".
- `status` (String, optional): Status, e.g., "Online", "Busy", "Away".
''',
  },
  {
    'template_id': 'place',
    'use_case':
        'Location information, location check-ins, location sharing, etc.',
    'data_structure': '''
- `name` (String, required): Location name.
- `address` (String, optional): Detailed address.
- `latitude` or `lat` (Number, optional): Latitude (WGS-84 coordinate system).
- `longitude` or `lng` (Number, optional): Longitude (WGS-84 coordinate system). If coordinates are provided, a map preview will be displayed.
''',
  },
  {
    'template_id': 'spec_sheet',
    'use_case':
        'Product information, product specifications, technical parameters, etc.',
    'data_structure': '''
- `name` (String, optional): Name (defaults to card title).
- `image_url` (String, optional): Image.
- `subtitle` (String, optional): Subtitle.
- `specs` (Map<String, dynamic>, optional): Specification key-value pairs, e.g., {"Brand": "Apple", "Model": "iPhone 15"}.
''',
  },
  {
    'template_id': 'transaction',
    'use_case': 'Transaction records, expense records, bills, etc.',
    'data_structure': '''
- `merchant` (String, required): Merchant name.
- `amount` (String, required): Total amount, must include currency unit, e.g., "¥50.00", "\$25.99", "€30.00".
- `location` (String, optional): Transaction location.
- `items` (List<Map>, optional): Transaction detail list, each item contains:
  - `name` (String, required): Item name.
  - `amount` (String, required): Item price, must include currency unit, e.g., "¥20.00", "\$10.99".
''',
  },
  {
    'template_id': 'metric',
    'use_case': 'Metric data, statistical data, measured values, etc.',
    'data_structure': '''
- `title` (String, optional): Main title for the entire card (defaults to card title).
- `items` (List<Map>, required): List of metric items, each item contains:
  - `title` (String, required): Metric name.
  - `value` (Number, required): Numeric value.
  - `unit` (String, optional): Unit, e.g., "kg", "km", "times".
  - `label` (String, optional): Label description.
  - `trend` (String, optional): Trend, options: "up", "down", "neutral".
  - `color` (String, optional): Color theme, options: "indigo", "emerald", "orange".
''',
  },
  {
    'template_id': 'rating',
    'use_case': 'Ratings, reviews, star ratings, etc.',
    'data_structure': '''
- `subject` (String, required): Subject being rated.
- `score` (Number, required): Rating value.
- `max_score` (Number, optional): Maximum score, defaults to 5.0.
- `comment` (String, optional): Review text.
''',
  },
  {
    'template_id': 'mood',
    'use_case': 'Mood records, emotion tracking, etc.',
    'data_structure': '''
- `mood_name` or `mood` (String, required): Mood name, e.g., "Happy", "Sad".
- `intensity` (Number, optional): Intensity (1-10), defaults to 5.
- `color_hex` (String, required): Color hex value.
- `trigger` (String, optional): Trigger reason.
''',
  },
  {
    'template_id': 'progress',
    'use_case': 'Progress tracking, completion percentage, etc.',
    'data_structure': '''
- `current` (Number, required): Current value.
- `total` (Number, required): Total value.
- `unit` (String, optional): Unit, defaults to "%".
- `label` (String, optional): Label description (defaults to card title).
''',
  },
  {
    'template_id': 'event',
    'use_case': 'Events, meetings, activities, schedules, etc.',
    'data_structure': '''
- `title` (String, optional): Event title (defaults to card title).
- `start_time` (String, required): Start time (ISO8601 format string).
- `end_time` (String, optional): End time.
- `location` (String, optional): Location.
''',
  },
  {
    'template_id': 'duration',
    'use_case': 'Duration records, elapsed time, timing, etc.',
    'data_structure': '''
- `title` (String, optional): Title (defaults to card title).
- `elapsed` (int, required): Duration in seconds.
''',
  },
  {
    'template_id': 'task',
    'use_case': 'Tasks, todos, checklists, etc.',
    'data_structure': '''
- `title` (String, optional): Task title (defaults to card title).
- `is_completed` (Boolean, optional): Whether completed, defaults to false.
- `subtasks` (List<Map>, optional): Subtask list, each subtask contains:
  - `title` (String, required): Subtask title.
  - `completed` (Boolean, optional): Whether completed.
- `priority` (String, optional): Priority, e.g., "high".
- `due_date` (String, optional): Due date.
''',
  },
  {
    'template_id': 'routine',
    'use_case': 'Habit tracking, daily routines, streak tracking, etc.',
    'data_structure': '''
- `habit_name` (String, required): Habit name.
- `streak` (Number, required): Consecutive days.
- `history` (List<Boolean>, optional): Completion records for the last 7 days, defaults to 7 false values.
''',
  },
  {
    'template_id': 'procedure',
    'use_case': 'Process steps, operation guides, procedure instructions, etc.',
    'data_structure': '''
- `title` (String, optional): Procedure title (defaults to card title).
- `steps` (List<String>, required): Step list, in order.
''',
  },
  {
    'template_id': 'compact',
    'use_case':
        'Brief information records, habit check-ins, daily routines, lightweight logs, etc.',
    'data_structure': '''
- `title` (String, optional): Brief title (defaults to card title).
- `icon` (String, optional): Valid flutter icon key (e.g. Icons.home) suitable for this information.
- `details` (List<String>, optional): Supplementary information list, e.g., ["200ml", "10:00"].
- `color` (String, required): Color hex value (e.g., "#EF4444").
''',
  },
  {
    'template_id': 'digest',
    'use_case':
        'Mixed, long, or messy raw inputs that contain multiple semantic domains such as project updates, thoughts, emotions, schedules, and todos. Use as an overview card, not as a replacement for specific action cards.',
    'data_structure': '''
- `summary` (String, required): One concise synthesis of the whole input.
- `sections` (List<Map>, required): Structured semantic sections. Use 2-6 sections when possible. Each section contains:
  - `type` (String, required): One of "project", "thought", "mood", "schedule", "todo", "decision", "idea", "health", "finance", "relationship", "note", "other".
  - `title` (String, required): Short section title.
  - `items` (List<String>, required): Key extracted points for this section. Keep each item short and faithful to the raw input.
''',
  },
  {
    'template_id': 'snippet',
    'use_case': 'Code snippets, text snippets, short text, etc.',
    'data_structure': '''
- `text` (String, required): Text content (Markdown supported).
- `style` (String, optional): Style, options: "default", "mono", "handwritten".
- `tags` (List<String>, optional): Tag list.
''',
  },
  {
    'template_id': 'article',
    'use_case': 'Articles, long text, blogs, notes, etc.',
    'data_structure': '''
- `title` (String, optional): Article title (defaults to card title).
- `body` (String, required): Body content (Markdown supported).
- `image_url` (String, optional): Cover image.
''',
  },
  {
    'template_id': 'conversation',
    'use_case': 'Conversation records, chat logs, sessions, etc.',
    'data_structure': '''
- `title` (String, optional): Conversation title (defaults to card title).
- `messages` (List<Map>, required): Message list, each message contains:
  - `text` (String, required): Message content.
  - `sender` (String, optional): Sender name.
  - `isMe` (Boolean, optional): Whether sent by me.
''',
  },
  {
    'template_id': 'quote',
    'use_case': 'Quotes, citations, excerpts, reflections, etc.',
    'data_structure': '''
- `content` (String, required): Quote content.
- `author` (String, optional): Author.
- `source` (String, optional): Source/origin.
''',
  },
  {
    'template_id': 'snapshot',
    'use_case': 'Photo snapshots, single images, photography works, etc.',
    'data_structure': '''
- `image_url` (String, required): Image link.
- `caption` (String, optional): Image caption (defaults to card title).
- `location` (String, optional): Shooting location.
''',
  },
  {
    'template_id': 'gallery',
    'use_case': 'Image collections, multi-image displays, albums, etc.',
    'data_structure': '''
- `image_urls` (List<String>, required): Image link list.
- `title` (String, optional): Title (defaults to card title).
''',
  },
  {
    'template_id': 'video',
    'use_case': 'Video content, video records, etc.',
    'data_structure': '''
- `video_url` (String, required): Video link.
- `title` (String, optional): Video title (defaults to card title).
- `duration` (String, optional): Video duration.
''',
  },
];
