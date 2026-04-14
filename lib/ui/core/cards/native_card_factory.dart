import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/templates/system_task_card.dart';
import 'package:memex/ui/core/cards/templates/classic_card.dart';

import 'package:memex/ui/core/cards/templates/textual/compact_card.dart';
import 'package:memex/ui/core/cards/templates/textual/snippet_card.dart';
import 'package:memex/ui/core/cards/templates/textual/article_card.dart';
import 'package:memex/ui/core/cards/templates/textual/conversation_card.dart';
import 'package:memex/ui/core/cards/templates/textual/insight_summary_card.dart';
import 'package:memex/ui/core/cards/templates/textual/quote_card.dart';
import 'package:memex/ui/core/cards/templates/visual/snapshot_card.dart';
import 'package:memex/ui/core/cards/templates/visual/gallery_card.dart';
import 'package:memex/ui/core/cards/templates/visual/video_card.dart';
import 'package:memex/ui/core/cards/templates/visual/canvas_card.dart';
import 'package:memex/ui/core/cards/templates/quantifiable/metric_card.dart';
import 'package:memex/ui/core/cards/templates/quantifiable/rating_card.dart';
import 'package:memex/ui/core/cards/templates/quantifiable/mood_card.dart';
import 'package:memex/ui/core/cards/templates/quantifiable/progress_card.dart';
import 'package:memex/ui/core/cards/templates/temporal/event_card.dart';
import 'package:memex/ui/core/cards/templates/temporal/duration_card.dart';
import 'package:memex/ui/core/cards/templates/temporal/task_card.dart';
import 'package:memex/ui/core/cards/templates/temporal/routine_card.dart';
import 'package:memex/ui/core/cards/templates/temporal/procedure_card.dart';
import 'package:memex/ui/core/cards/templates/entities/person_card.dart';
import 'package:memex/ui/core/cards/templates/entities/place_card.dart';
import 'package:memex/ui/core/cards/templates/entities/spec_sheet_card.dart';
import 'package:memex/ui/core/cards/templates/entities/transaction_card.dart';
import 'package:memex/ui/core/cards/templates/entities/link_card.dart';

/// Factory class to create native card widgets based on template ID.
class NativeCardFactory {
  /// Builds a native card widget from the given parameters.
  static Widget build({
    required String templateId,
    required Map<String, dynamic> data,
    required String title,
    required String status,
    VoidCallback? onTap,
    List<String> tags = const [],
    String? cardId,
    int? configIndex,
    String? failureReason,
    bool overrideTitle = true,
    Function(String cardId, int configIndex, Map<String, dynamic> data)?
        onUpdate,
  }) {
    // Merge generic properties into data for self-contained widgets
    final Map<String, dynamic> mergedData = {
      'tags': tags,
      'status': status,
      if (failureReason != null) 'failure_reason': failureReason,
      ...data,
      if (overrideTitle) 'title': title,
    };

    switch (templateId) {
      case 'classic_card':
      case 'audio_card': // Consolidated
      case 'gallery_card': // Consolidated
        return ClassicCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'quote_card': // Preserving old quote_card mapping if needed, or redirecting to new QuoteCard
        return QuoteCard(
          data: mergedData,
          onTap: onTap,
        );
      // New Textual Categories
      case 'snippet':
        return SnippetCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'article':
        return ArticleCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'conversation':
        return ConversationCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'quote':
        return QuoteCard(
          data: mergedData,
          onTap: onTap,
        );
      // New Visual Categories
      case 'snapshot':
        return SnapshotCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'gallery':
        return GalleryCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'video':
        return VideoCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'canvas':
        return CanvasCard(
          data: mergedData,
          onTap: onTap,
        );
      // New Quantifiable Categories
      case 'metric':
        return MetricCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'rating':
        return RatingCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'mood':
        return MoodCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'progress':
        return ProgressCard(
          data: mergedData,
          onTap: onTap,
          cardId: cardId,
          configIndex: configIndex,
          onUpdate: onUpdate,
        );
      // New Temporal Categories
      case 'event':
        return EventCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'duration':
        return DurationCard(
          data: mergedData,
          onTap: onTap,
          cardId: cardId,
          configIndex: configIndex,
          onUpdate: onUpdate,
        );
      case 'task':
        return TaskCard(
          data: mergedData,
          onTap: onTap,
          cardId: cardId,
          configIndex: configIndex,
          onUpdate: onUpdate,
        );
      case 'routine':
        return RoutineCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'procedure':
        return ProcedureCard(
          data: mergedData,
          onTap: onTap,
        );
      // New Entity Categories
      case 'person':
        return PersonCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'place':
        return PlaceCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'spec_sheet':
        return SpecSheetCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'transaction':
        return TransactionCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'link':
        return LinkCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'compact':
      case 'compact_card':
        return CompactCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'insight_summary':
        return InsightSummaryCard(
          data: mergedData,
          onTap: onTap,
        );
      case 'system_task':
        return SystemTaskCard(data: mergedData);
      default:
        // Fallback to ClassicCard for now, or could return a specific Error/Fallback card
        return ClassicCard(
          data: mergedData, // Fallback also needs correct data structure
          onTap: onTap,
        );
    }
  }
}
