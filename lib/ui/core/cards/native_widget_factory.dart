import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:memex/ui/insight/widgets/insight_cards/map_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/route_map_card.dart';
import 'package:memex/ui/core/widgets/html_webview_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/highlight_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/composition_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/contrast_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/gallery_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/bubble_chart_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/progress_chart_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/radar_chart_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/trend_chart_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/bar_chart_card.dart';
import 'package:memex/ui/insight/widgets/insight_cards/timeline_card.dart';
import 'package:memex/ui/core/widgets/related_facts_list.dart'; // Import RelatedFactsList
import 'package:memex/ui/insight/widgets/insight_cards/summary_card.dart'; // Import SummaryCard
import 'package:memex/utils/user_storage.dart';

typedef NativeWidgetBuilder = Widget? Function(Map<String, dynamic> data);

/// Factory to create native widgets based on template name
class NativeWidgetFactory {
  // Registry of supported native widgets
  static final Map<String, NativeWidgetBuilder> _registry = {
    'map_card_v1': _buildMapCard,
    'route_map_card_v1': _buildRouteMapCard,
    'highlight_card_v1': _buildQuoteCard,
    'composition_card_v1': _buildCompositionCard,
    'contrast_card_v1': _buildReframingCard,
    'gallery_card_v1': _buildChronicleCard,
    'bubble_chart_card_v1': _buildBubbleCard,
    'progress_chart_card_v1': _buildProgressCard,
    'radar_chart_card_v1': _buildRadarCard,
    'trend_chart_card_v1': _buildTrendCard,
    'bar_chart_card_v1': _buildBarCard,
    'timeline_card_v1': _buildTimelineCard,
    'summary_card_v1': _buildSummaryCard,
  };

  static final Map<String, NativeWidgetBuilder> _detailRegistry = {
    'map_card_v1': _buildMapCardDetail,
    'route_map_card_v1': _buildRouteMapCardDetail,
    'highlight_card_v1':
        _buildQuoteCard, // Detail view is same as list view for now
    'composition_card_v1':
        _buildCompositionCard, // Detail view is same as list view
    'contrast_card_v1': _buildReframingCard, // Detail view is same as list view
    'gallery_card_v1': _buildChronicleCard, // Detail view is same as list view
    'bubble_chart_card_v1':
        _buildBubbleCard, // Detail view is same as list view
    'progress_chart_card_v1':
        _buildProgressCard, // Detail view is same as list view
    'radar_chart_card_v1': _buildRadarCard, // Detail view is same as list view
    'trend_chart_card_v1': _buildTrendCard, // Detail view is same as list view
    'bar_chart_card_v1': _buildBarCard, // Detail view is same as list view
    'timeline_card_v1': _buildTimelineCard, // Detail view is same as list view
    'summary_card_v1': _buildSummaryCard, // Detail view is same as list view
  };

  /// Build a native widget by template name
  static Widget? build(String template, Map<String, dynamic> data) {
    final builder = _registry[template];
    if (builder != null) {
      final widget = builder(data);
      if (widget != null) {
        return _wrapWithInjectors(widget, data, isDetail: false);
      }
    }
    return null;
  }

  /// Build a native widget detail view by template name
  static Widget? buildDetail(String template, Map<String, dynamic> data) {
    final builder = _detailRegistry[template];
    if (builder != null) {
      final widget = builder(data);
      if (widget != null) {
        return _wrapWithInjectors(widget, data, isDetail: true);
      }
    }
    return null;
  }

  static Widget _wrapWithInjectors(Widget widget, Map<String, dynamic> data,
      {required bool isDetail}) {
    if (!isDetail) {
      return widget;
    }

    final children = <Widget>[widget];

    // 1. Extension HTML
    // Try snake_case first, then camelCase
    final extHtml = data['ext_html'] ?? data['extHtml'];
    if (extHtml != null && (extHtml as String).isNotEmpty) {
      children.add(_buildSnippet(extHtml));
    }

    // 2. Related Facts — skip in detail mode since InsightDetailPage
    //    already renders related_cards, avoiding duplicate display.
    if (!isDetail) {
      final relatedFacts = data['related_fact_ids'] ?? data['related_facts'];
      if (relatedFacts is List && relatedFacts.isNotEmpty) {
        final factIds = relatedFacts
            .map((e) => e is Map ? e['id'] as String? : e.toString())
            .where((e) => e != null && e.isNotEmpty)
            .cast<String>()
            .toList();

        if (factIds.isNotEmpty) {
          children.add(RelatedFactsList(factIds: factIds));
        }
      }
    }

    if (children.length == 1) {
      return widget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  static Widget _buildSnippet(String html) {
    return HtmlWebViewCard(
      html: html,
      config: const HtmlWebViewConfig.snippet(),
    );
  }

  /// SummaryCard builder
  static Widget? _buildSummaryCard(Map<String, dynamic> data) {
    final metrics = (data['metrics'] as List?)
            ?.map((e) =>
                SummaryMetric.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    final highlights = (data['highlights'] as List?)
            ?.map((e) =>
                SummaryHighlight.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    final badge = data['badge'] as Map<String, dynamic>?;

    // Use generic insight key or fallback
    final insightContent = data['insight'] as String? ?? '';
    final insightTitle = data['insight_title'] as String? ?? 'Agent Insight';

    return SummaryCard(
      tag: data['tag'] as String? ?? 'REVIEW',
      title: data['title'] as String? ?? 'Summary',
      date: data['date'] as String? ?? '',
      badge: badge,
      insightTitle: insightTitle,
      insightContent: insightContent,
      metrics: metrics,
      highlightsTitle: data['highlights_title'] as String? ?? 'Highlights',
      highlights: highlights,
    );
  }

  /// MapCard builder
  static Widget? _buildMapCard(Map<String, dynamic> data,
      {bool isDetail = false}) {
    // Validate locations
    final locationsList = data['locations'];
    if (locationsList is! List || locationsList.isEmpty) {
      return null;
    }

    final locations = locationsList
        .map((l) {
          if (l is Map && l.containsKey('lat') && l.containsKey('lng')) {
            try {
              final lat = (l['lat'] as num).toDouble();
              final lng = (l['lng'] as num).toDouble();
              final name = l['name'] as String?;
              return MapLocation(point: LatLng(lat, lng), name: name);
            } catch (e) {
              return null;
            }
          }
          return null;
        })
        .whereType<MapLocation>()
        .toList();

    // If no valid locations found after parsing, return null
    if (locations.isEmpty) {
      return null;
    }

    return MapCard(
      title: data['title'] as String? ?? UserStorage.l10n.footprintMap,
      // Support both snake_case (legacy/internal) and camelCase (server) keys
      infoTitle: (data['infoTitle'] ?? data['info_title']) as String?,
      infoDetail: (data['infoDetail'] ?? data['info_detail']) as String?,
      insight: data['insight'] as String?,
      locations: locations,
      isDetail: isDetail,
    );
  }

  /// MapCard Detail builder
  static Widget? _buildMapCardDetail(Map<String, dynamic> data) {
    return _buildMapCard(data, isDetail: true);
  }

  /// RouteMapCard Detail builder
  static Widget? _buildRouteMapCardDetail(Map<String, dynamic> data) {
    return _buildRouteMapCard(data, isDetail: true);
  }

  /// RouteMapCard builder
  static Widget? _buildRouteMapCard(Map<String, dynamic> data,
      {bool isDetail = false}) {
    // Validate locations
    final locationsList = data['locations'];
    if (locationsList is! List || locationsList.isEmpty) {
      return null;
    }

    final locations = locationsList
        .map((l) {
          if (l is Map && l.containsKey('lat') && l.containsKey('lng')) {
            try {
              final lat = (l['lat'] as num).toDouble();
              final lng = (l['lng'] as num).toDouble();
              final name = l['name'] as String?;
              return MapLocation(point: LatLng(lat, lng), name: name);
            } catch (e) {
              return null;
            }
          }
          return null;
        })
        .whereType<MapLocation>()
        .toList();

    // If no valid locations found after parsing, return null
    if (locations.isEmpty) {
      return null;
    }

    return RouteMapCard(
      title: data['title'] as String? ?? UserStorage.l10n.footprintPath,
      locations: locations,
      insight: data['insight'] as String?,
      isDetail: isDetail,
    );
  }

  /// QuoteCard builder
  static Widget? _buildQuoteCard(Map<String, dynamic> data) {
    return HighlightCard(
      title: data['title'] as String? ?? 'INSIGHT',
      quoteContent: data['quote_content'] as String? ?? '',
      quoteHighlight: data['quote_highlight'] as String?,
      footer: data['footer'] as String?,
      theme: data['theme'] as String?,
      date: data['date'] as String?,
      insight: data['insight'] as String?,
    );
  }

  /// CompositionCard builder
  static Widget? _buildCompositionCard(Map<String, dynamic> data) {
    final headlineItems = (data['headline_items'] as List?)
            ?.map((e) =>
                HeadlineItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];
    final items = (data['items'] as List?)
            ?.map((e) =>
                CompositionItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return CompositionCard(
      title: data['title'] as String? ?? UserStorage.l10n.lifeCompositionTable,
      badge: data['badge'] as String?,
      headlineItems: headlineItems,
      items: items,
      footer: data['footer'] as String?,
      insight: data['insight'] as String?,
    );
  }

  /// ReframingCard builder
  static Widget? _buildReframingCard(Map<String, dynamic> data) {
    return ContrastCard(
      title: data['title'] as String? ?? UserStorage.l10n.emotionReframe,
      emotion: data['emotion'] as String? ?? 'negative',
      // Support new generic keys (context_section/highlight_section) and legacy specific keys
      oldPerspective: data['context_section'] as Map<String, dynamic>? ??
          data['old_perspective'] as Map<String, dynamic>? ??
          <String, dynamic>{},
      newPerspective: data['highlight_section'] as Map<String, dynamic>? ??
          data['new_perspective'] as Map<String, dynamic>? ??
          <String, dynamic>{},
      insight: data['insight'] as String?,
    );
  }

  /// ChronicleCard builder
  static Widget? _buildChronicleCard(Map<String, dynamic> data) {
    final images = (data['images'] as List?)
            ?.map((e) =>
                ChronicleImage.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return GalleryCard(
      title: data['title'] as String? ?? UserStorage.l10n.chronicleOfThings,
      headline: data['headline'] as String? ?? '',
      images: images,
      content: data['content'] as String?,
      insight: data['insight'] as String?,
    );
  }

  /// BubbleCard builder
  static Widget? _buildBubbleCard(Map<String, dynamic> data) {
    final bubbles = (data['bubbles'] as List?)
            ?.map((e) =>
                InsightBubble.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return BubbleChartCard(
      title: data['title'] as String? ?? 'KEYWORDS',
      bubbles: bubbles,
      footer: data['footer'] as String?,
      insight: data['insight'] as String?,
    );
  }

  /// ProgressCard builder
  static Widget? _buildProgressCard(Map<String, dynamic> data) {
    final items = (data['items'] as List?)
            ?.map((e) =>
                ProgressItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return ProgressChartCard(
      title: data['title'] as String? ?? UserStorage.l10n.goalProgress,
      subtitle: data['subtitle'] as String?,
      current: (data['current'] as num? ?? 0).toDouble(),
      target: (data['target'] as num? ?? 100).toDouble(),
      centerText: data['center_text'] as String?,
      items: items,
      insight: data['insight'] as String?,
    );
  }

  /// RadarCard builder
  static Widget? _buildRadarCard(Map<String, dynamic> data) {
    final dimensions = (data['dimensions'] as List?)
            ?.map((e) =>
                RadarDimension.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return RadarChartCard(
      title: data['title'] as String? ?? 'BALANCE',
      badge: data['badge'] as String?,
      centerValue:
          (data['center_value'] ?? data['centerValue']) as String? ?? '0',
      centerLabel:
          (data['center_label'] ?? data['centerLabel']) as String? ?? '',
      color: data['color'] as String? ?? '#8B5CF6',
      dimensions: dimensions,
      insight: data['insight'] as String?,
    );
  }

  /// TrendCard builder
  static Widget? _buildTrendCard(Map<String, dynamic> data) {
    final points = (data['points'] as List?)
            ?.map(
                (e) => TrendPoint.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return TrendChartCard(
      title: data['title'] as String? ?? UserStorage.l10n.trendChart,
      topRightText: (data['top_right_text'] ?? data['topRightText']) as String?,
      points: points,
      highlightInfo: data['highlight_info'] as Map<String, dynamic>?,
      color: data['color'] as String? ?? '#6366F1',
      insight: data['insight'] as String?,
    );
  }

  /// BarCard builder
  static Widget? _buildBarCard(Map<String, dynamic> data) {
    final items = (data['items'] as List?)
            ?.map((e) => BarItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return BarChartCard(
      title: data['title'] as String? ?? UserStorage.l10n.comparisonChart,
      subtitle: data['subtitle'] as String?,
      unit: data['unit'] as String? ?? '',
      items: items,
      insight: data['insight'] as String?,
    );
  }

  /// TimelineCard builder
  static Widget? _buildTimelineCard(Map<String, dynamic> data) {
    final items = (data['items'] as List?)
            ?.map((e) =>
                TimelineItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return TimelineCard(
      title: data['title'] as String? ?? UserStorage.l10n.todayTimeFlow,
      items: items,
      insight: data['insight'] as String?,
    );
  }
}
