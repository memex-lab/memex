/// Definition of a native widget available for the Knowledge Insight Agent.
class NativeWidgetDefinition {
  final String id;
  final String description;
  final String promptStructure;
  final String? Function(Map<String, dynamic> data) validator;

  const NativeWidgetDefinition({
    required this.id,
    required this.description,
    required this.promptStructure,
    required this.validator,
  });
}

/// Helper to parse color strings
bool _isValidColor(String? color) {
  if (color == null) return true;
  return RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(color);
}

/// Helper to validate list items
String? _validateList(
    dynamic list, String fieldName, String? Function(Map) itemValidator) {
  if (list == null) return null; // Optional list is fine
  if (list is! List) return '$fieldName must be a list';
  for (var i = 0; i < list.length; i++) {
    final item = list[i];
    if (item is! Map) return '$fieldName[$i] must be an object';
    final error = itemValidator(item);
    if (error != null) return '$fieldName[$i]: $error';
  }
  return null;
}

final List<NativeWidgetDefinition> nativeWidgets = [
  NativeWidgetDefinition(
    id: "map_card_v1",
    description: "Map Card - Visualize location data, tracks or check-in points",
    promptStructure: '''
interface MapCardData {
  locations: Array<{
    lat: number;
    lng: number;
    name: string; // Location name, e.g. "Place Name"
  }>;
  infoTitle?: string; // Location name or summary (shown at card bottom, optional)
  infoDetail?: string; // Address or note (below infoTitle, optional)
  ext_html?: string; // Optional: extra HTML for detail page (intro, links, images)
}
''',
    validator: (data) {
      if (data['locations'] is! List) {
        return 'locations is required and must be a list';
      }
      if ((data['locations'] as List).isEmpty) {
        return 'locations cannot be empty';
      }

      return _validateList(data['locations'], 'locations', (item) {
        if (item['lat'] is! num) return 'lat is required and must be a number';
        if (item['lng'] is! num) return 'lng is required and must be a number';
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "route_map_card_v1",
    description: "Route Map Card - Show ordered path/route",
    promptStructure: '''
interface RouteMapCardData {
  locations: Array<{
    lat: number;
    lng: number;
    name: string; // Location name, e.g. "Start"
  }>;
  ext_html?: string; // Optional: extra HTML for detail (e.g. difficulty, gear tips)
}
''',
    validator: (data) {
      if (data['locations'] is! List) {
        return 'locations is required and must be a list';
      }
      if ((data['locations'] as List).length < 2) {
        return 'locations must have at least 2 points for a route';
      }

      return _validateList(data['locations'], 'locations', (item) {
        if (item['lat'] is! num) return 'lat is required and must be a number';
        if (item['lng'] is! num) return 'lng is required and must be a number';
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "highlight_card_v1",
    description: "Highlight Card - Emphasize key points, quotes or conclusions",
    promptStructure: '''
interface HighlightCardData {
  quote_content: string; // Main quote text
  quote_highlight?: string; // Keywords to highlight
  footer?: string; // Footer text (optional)
  theme?: 'primary' | 'orange' | 'blue'; // Theme (optional)
  date?: string; // Date string (optional)
}
''',
    validator: (data) {
      if (data['quote_content'] is! String ||
          (data['quote_content'] as String).isEmpty) {
        return 'quote_content is required';
      }
      return null;
    },
  ),
  NativeWidgetDefinition(
    id: "composition_card_v1",
    description: "Composition Card - Show composition, percentages or weights",
    promptStructure: '''
interface CompositionCardData {
  badge?: string; // Top-right badge (optional)
  headline_items?: Array<{
    text: string;
    color?: string; // Hex color code
  }>;
  items: Array<{
    label: string;
    percentage: number; // Percentage value (0-100)
    color?: string; // Hex color code
  }>;
  footer?: string; // Footer summary or insight
}
''',
    validator: (data) {
      if (data['items'] is! List) return 'items is required and must be a list';

      return _validateList(data['items'], 'items', (item) {
        if (item['label'] is! String) return 'label is required';
        if (item['percentage'] is! num) {
          return 'percentage is required and must be a number';
        }
        if (!_isValidColor(item['color'])) return 'invalid color format';
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "contrast_card_v1",
    description:
        "Contrast Card - Visual contrast of two groups: problem vs solution, current vs goal, input vs output",
    promptStructure: '''
interface ContrastCardData {
  emotion?: 'negative' | 'neutral' | 'positive'; // Sentiment: negative, neutral, positive
  context_section: {
    content: string;
    source?: string; // Source or time (optional)
  };
  highlight_section: {
    title?: string; // e.g. 'Improvement', 'New perspective'
    content: string;
    highlight?: string; // Key highlight (optional)
  };
}
''',
    validator: (data) {
      // Support old keys for backward compatibility check? No, new structure is preferred.
      // But let's check for either.
      final context = data['context_section'] ?? data['old_perspective'];
      if (context is! Map) return 'context_section is required';

      final highlight = data['highlight_section'] ?? data['new_perspective'];
      if (highlight is! Map) return 'highlight_section is required';

      return null;
    },
  ),
  NativeWidgetDefinition(
    id: "gallery_card_v1",
    description: "Gallery Card - Show multiple images in parallel (items, comparison or gallery)",
    promptStructure: '''
interface GalleryCardData {
  headline?: string; // Main headline
  images: Array<{
    url: string; // Image URL, e.g. fs://xxx.yy
    label?: string; // Image caption
  }>;
  content?: string; // Footer description or analysis
}
''',
    validator: (data) {
      if (data['images'] is! List) {
        return 'images is required and must be a list';
      }

      return _validateList(data['images'], 'images', (item) {
        if (item['url'] is! String || (item['url'] as String).isEmpty) {
          return 'url is required';
        }
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "bubble_chart_card_v1",
    description: "Topic Bubble Insight Card - Show keyword or topic distribution",
    promptStructure: '''
interface BubbleChartCardData {
  bubbles: Array<{
    label: string; // Keyword or topic
    value: number; // Weight/size (1-100)
    color?: string; // Bubble fill hex
    sub_label?: string; // Sub-label (optional)
    is_highlight?: boolean; // Highlight/center
  }>;
  footer?: string; // Footer text
}
''',
    validator: (data) {
      if (data['bubbles'] is! List) {
        return 'bubbles is required and must be a list';
      }

      return _validateList(data['bubbles'], 'bubbles', (item) {
        if (item['label'] is! String) return 'label is required';
        if (item['value'] is! num) return 'value must be a number';
        if (!_isValidColor(item['color'])) return 'invalid color format';
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "progress_chart_card_v1",
    description: "Progress Ring Card - Show goal completion",
    promptStructure: '''
interface ProgressChartCardData {
  subtitle?: string; // Subtitle/status (e.g. '12 books left')
  current: number; // Current value or percentage
  target: number; // Target (use 100 if current is percentage)
  center_text?: string; // Center text
  items: Array<{
    label: string; // Label
    value: number; // Value
    color?: string; // Color
  }>;
}
''',
    validator: (data) {
      if (data['current'] is! num) return 'current must be a number';
      if (data['target'] is! num) return 'target must be a number';

      return _validateList(data['items'], 'items', (item) {
        if (item['label'] is! String) return 'label is required';
        if (item['value'] is! num) return 'value must be a number';
        if (!_isValidColor(item['color'])) return 'invalid color format';
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "radar_chart_card_v1",
    description: "Radar Card - Show multi-dimensional balance, capability or feature distribution",
    promptStructure: '''
interface RadarChartCardData {
  badge?: string; // Top-right badge (e.g. 'Focus this month')
  center_value?: string; // Center total/value
  center_label?: string; // Center label
  dimensions: Array<{
    label: string;
    value: number;
    max: number;
  }>;
  color?: string; // Theme color
}
''',
    validator: (data) {
      if (data['dimensions'] is! List) {
        return 'dimensions is required and must be a list';
      }
      if ((data['dimensions'] as List).length < 3) {
        return 'radar chart requires at least 3 dimensions';
      }

      return _validateList(data['dimensions'], 'dimensions', (item) {
        if (item['label'] is! String) return 'label is required';
        if (item['value'] is! num) return 'value must be a number';
        if (item['max'] is! num) return 'max must be a number';
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "trend_chart_card_v1",
    description: "Trend Card - Show time-series trend",
    promptStructure: '''
interface TrendChartCardData {
  top_right_text?: string; // Top-right text (e.g. 'Avg: 7.2')
  points: Array<{
    label: string; // X-axis label
    value: number; // Value
    is_highlight?: boolean;
  }>;
  highlight_info?: {
    title?: string;
    subtitle?: string;
  };
  color?: string; // Line color
}
''',
    validator: (data) {
      if (data['points'] is! List) {
        return 'points is required and must be a list';
      }
      if ((data['points'] as List).length < 2) {
        return 'trend chart requires at least 2 points';
      }

      return _validateList(data['points'], 'points', (item) {
        if (item['label'] is! String) return 'label is required';
        if (item['value'] is! num) return 'value must be a number';
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "bar_chart_card_v1",
    description: "Bar Chart Card - Show categorical comparison or distribution",
    promptStructure: '''
interface BarChartCardData {
  subtitle?: string; // Subtitle or insight
  unit?: string; // Unit (optional)
  items: Array<{
    label: string; // Category label
    value: number; // Value
    icon?: string; // Emoji or URL
    color?: string; // Bar color
    is_highlight?: boolean;
  }>;
}
''',
    validator: (data) {
      if (data['items'] is! List) return 'items is required and must be a list';

      return _validateList(data['items'], 'items', (item) {
        if (item['label'] is! String) return 'label is required';
        if (item['value'] is! num) return 'value must be a number';
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "timeline_card_v1",
    description: "Timeline Card - Show time-based event flow",
    promptStructure: '''
interface TimelineCardData {
  items: Array<{
    time: string; // Time, e.g. "09:00"
    title?: string; // Event title
    content?: string; // Detail
    icon?: string; // Emoji or asset
    color?: string; // Theme color
    is_filled_dot?: boolean; // Ring vs Solid dot
  }>;
}
''',
    validator: (data) {
      if (data['items'] is! List) return 'items is required and must be a list';

      return _validateList(data['items'], 'items', (item) {
        if (item['time'] is! String) return 'time is required';
        // content and title are situational, at least one is usually needed but let's be loose
        return null;
      });
    },
  ),
  NativeWidgetDefinition(
    id: "summary_card_v1",
    description: "Summary Card - Show weekly/daily reports, retrospectives or summaries",
    promptStructure: '''
interface SummaryCardData {
  tag?: string; // Tag (e.g. 'WEEKLY REVIEW')
  date?: string; // Date range or time
  badge?: {
    icon?: string; // Badge icon
    text?: string; // Badge text
  };
  insight_title?: string; // Insight title (default 'Agent Insight')
  metrics?: Array<{
    label: string;
    value: string;
    color?: string;
  }>;
  highlights_title?: string;
  highlights?: Array<{
    url: string; // image url
    label?: string;
  }>;
}
''',
    validator: (data) {
      if (data['metrics'] != null) {
        final error = _validateList(data['metrics'], 'metrics', (item) {
          if (item['label'] is! String) return 'label is required';
          if (item['value'] is! String && item['value'] is! num) {
            return 'value is required';
          }
          return null;
        });
        if (error != null) return error;
      }

      if (data['highlights'] != null) {
        final error = _validateList(data['highlights'], 'highlights', (item) {
          if (item['url'] is! String) return 'url is required';
          return null;
        });
        if (error != null) return error;
      }

      return null;
    },
  )
];
