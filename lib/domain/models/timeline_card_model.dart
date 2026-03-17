import 'package:intl/intl.dart';
import 'package:memex/l10n/app_localizations.dart';

import 'card_detail_model.dart';
import 'card_model.dart';

/// Re-export UiConfig so existing imports of timeline_card_model still resolve UiConfig.
export 'card_model.dart' show UiConfig;

/// Represents a timeline card that is rendered via WebView (HTML) or Native widget.
class TimelineCardModel {
  final String id;
  final String? html; // HTML content for HTML cards, null for native cards
  final DateTime timestamp;
  final List<String> tags;
  final String status;
  final String? title;
  final List<UiConfig> uiConfigs; // List of UI configurations
  final List<AssetData>? assets; // Extracted image and audio assets
  final String?
      rawText; // Original user input text (with asset markers removed)
  final String? address; // Location name
  final String? failureReason;

  TimelineCardModel({
    required this.id,
    this.html,
    required this.timestamp,
    required this.tags,
    required this.status,
    this.title,
    required this.uiConfigs,
    this.assets,
    this.rawText,
    this.address,
    this.failureReason,
  });

  factory TimelineCardModel.fromJson(Map<String, dynamic> json) {
    // Handle UI Configs with backward compatibility
    List<UiConfig> configs = [];

    // 1. Try to read new 'ui_configs' list
    if (json['ui_configs'] != null) {
      configs = (json['ui_configs'] as List)
          .map((e) => UiConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TimelineCardModel(
      id: json['id'] as String,
      html: json['html'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as int) * 1000,
        isUtc: true,
      ).toLocal(),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
      status: json['status'] as String? ?? 'processing',
      title: json['title'] as String?,
      uiConfigs: configs,
      assets: (json['assets'] as List<dynamic>? ?? const [])
          .where((asset) => asset != null && asset is Map<String, dynamic>)
          .map((asset) => AssetData.fromJson(asset as Map<String, dynamic>))
          .toList(),
      rawText: json['raw_text'] as String?,
      address: json['address'] as String?,
      failureReason: json['failure_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (html != null) 'html': html,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
      'tags': tags,
      'status': status,
      if (title != null) 'title': title,
      'ui_configs': uiConfigs.map((c) => c.toJson()).toList(),
      if (assets != null && assets!.isNotEmpty)
        'assets': assets!.map((a) => a.toJson()).toList(),
      if (rawText != null) 'raw_text': rawText,
      if (address != null) 'address': address,
      if (failureReason != null) 'failure_reason': failureReason,
    };
  }

  String displayTime(AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cardDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final locale = l10n.localeName;

    if (cardDate == today) {
      // Same day: show time only
      return DateFormat.Hm(locale).format(timestamp);
    } else {
      // Other days: show date and time
      final daysDiff = today.difference(cardDate).inDays;
      if (daysDiff == 1) {
        // yesterday
        return l10n.yesterdayAt(DateFormat.Hm(locale).format(timestamp));
      } else if (daysDiff < 7) {
        // Within a week: show weekday
        var weekdayText = switch (timestamp.weekday) {
          DateTime.monday => l10n.calendarShortMon,
          DateTime.tuesday => l10n.calendarShortTue,
          DateTime.wednesday => l10n.calendarShortWed,
          DateTime.thursday => l10n.calendarShortThu,
          DateTime.friday => l10n.calendarShortFri,
          DateTime.saturday => l10n.calendarShortSat,
          DateTime.sunday => l10n.calendarShortSun,
          _ => DateFormat.E(locale).format(timestamp),
        };
        if (locale.startsWith('zh')) {
          weekdayText = '周$weekdayText';
        }
        return '$weekdayText ${DateFormat.Hm(locale).format(timestamp)}';
      } else if (cardDate.year == today.year) {
        // Same year: show month/day
        return DateFormat.Md(locale).add_Hm().format(timestamp);
      } else {
        // Different year: show full date
        return DateFormat.yMd(locale).add_Hm().format(timestamp);
      }
    }
  }
}
