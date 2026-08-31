import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/domain/models/card_detail_model.dart';

final _logger = getLogger('GetAggregatedTimeline');

/// Fetches aggregated timeline data.
/// Corresponds to backend GET /timeline/aggregated endpoint.
/// Groups by days/weeks/months/years and returns summary stats and thumbnails per period.
Future<Map<String, dynamic>> getAggregatedTimeline({
  required String groupBy,
  int page = 1,
  int limit = 20,
  List<String>? tags,
}) async {
  _logger.info(
      'getAggregatedTimeline called: groupBy=$groupBy, page=$page, limit=$limit, tags=$tags');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      _logger.warning('No user ID found');
      return {'items': [], 'hasMore': false};
    }

    final db = AppDatabase.instance;
    final fileSystemService = FileSystemService.instance;

    // Ensure cache is populated
    if (await db.cardDao.isCacheEmpty()) {
      _logger.info('Card cache is empty, triggering rebuild...');
      await fileSystemService.rebuildCardCache(userId);
    }

    // Fetch ALL cards matching tag filter (no pagination here, we group locally)
    final allCards = await db.cardDao.getCards(
      page: 1,
      limit: 100000, // Get all cards for grouping
      tags: tags,
    );

    if (allCards.isEmpty) {
      return {'items': [], 'hasMore': false};
    }

    // Group cards by period
    final Map<String, List<CardCacheData>> grouped = {};
    for (final card in allCards) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        card.timestamp * 1000,
        isUtc: true,
      ).toLocal();
      final periodId = _getPeriodId(dt, groupBy);
      grouped.putIfAbsent(periodId, () => []).add(card);
    }

    // Sort period keys descending (newest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    // Paginate
    final startIndex = (page - 1) * limit;
    if (startIndex >= sortedKeys.length) {
      return {'items': [], 'hasMore': false};
    }
    final endIndex = (startIndex + limit).clamp(0, sortedKeys.length);
    final pageKeys = sortedKeys.sublist(startIndex, endIndex);
    final hasMore = endIndex < sortedKeys.length;

    // Build aggregated items
    final items = <Map<String, dynamic>>[];
    for (final periodId in pageKeys) {
      final cards = grouped[periodId]!;

      // Build summary stats: count per tag
      final Map<String, int> summaryStats = {};
      for (final card in cards) {
        final cardTags = _parseTags(card.tags);
        for (final tag in cardTags) {
          summaryStats[tag] = (summaryStats[tag] ?? 0) + 1;
        }
      }
      // If no tags found, show total count
      if (summaryStats.isEmpty) {
        summaryStats['total'] = cards.length;
      }

      // Extract up to 5 image URLs from the first few cards
      final images = await _extractImages(
        userId,
        fileSystemService,
        cards.take(10).toList(),
      );

      // Generate labels
      final labels = getPeriodLabels(periodId, groupBy);

      items.add({
        'periodId': periodId,
        'periodLabel': labels.$1,
        'periodSubLabel': labels.$2,
        'summaryStats': summaryStats,
        'images': images,
      });
    }

    return {'items': items, 'hasMore': hasMore};
  } catch (e, st) {
    _logger.severe('Failed to get aggregated timeline: $e', e, st);
    return {'items': [], 'hasMore': false};
  }
}

/// Generates periodId from the given groupBy type.
String _getPeriodId(DateTime dt, String groupBy) {
  switch (groupBy) {
    case 'days':
      return DateFormat('yyyy-MM-dd').format(dt);
    case 'weeks':
      // ISO week: yyyy-Www
      final weekNumber = _isoWeekNumber(dt);
      final weekYear = _isoWeekYear(dt);
      return '$weekYear-W${weekNumber.toString().padLeft(2, '0')}';
    case 'months':
      return DateFormat('yyyy-MM').format(dt);
    case 'years':
      return dt.year.toString();
    default:
      return DateFormat('yyyy-MM-dd').format(dt);
  }
}

/// Generates display labels for the period.
@visibleForTesting
(String label, String subLabel) getPeriodLabels(
    String periodId, String groupBy) {
  final locale = UserStorage.l10n.localeName;
  try {
    switch (groupBy) {
      case 'days':
        final dt = DateFormat('yyyy-MM-dd').parse(periodId);
        final label = DateFormat('MMM d, yyyy', locale).format(dt);
        final dayName = DateFormat('EEEE', locale).format(dt);
        return (label, dayName);

      case 'weeks':
        final parts = periodId.split('-W');
        if (parts.length == 2) {
          final year = int.parse(parts[0]);
          final week = int.parse(parts[1]);
          final jan4 = DateTime.utc(year, 1, 4);
          final dayOfWeek = jan4.weekday;
          final isoWeekStart = jan4.subtract(Duration(days: dayOfWeek - 1));
          final weekStart = isoWeekStart.add(Duration(days: (week - 1) * 7));
          final weekEnd = weekStart.add(const Duration(days: 6));
          final startStr = DateFormat('MMM d', locale).format(weekStart);
          final endStr = DateFormat('MMM d, yyyy', locale).format(weekEnd);
          return (
            UserStorage.l10n.timelineWeekNumberLabel(week.toString()),
            '$startStr - $endStr',
          );
        }
        return (UserStorage.l10n.timelineWeekLabel, periodId);

      case 'months':
        final dt = DateFormat('yyyy-MM').parse(periodId);
        final label = DateFormat('MMMM yyyy', locale).format(dt);
        return (label, '');

      case 'years':
        return (periodId, '');

      default:
        return (periodId, '');
    }
  } catch (e) {
    return (periodId, '');
  }
}

/// ISO 8601 week number
int _isoWeekNumber(DateTime date) {
  final dayOfYear = int.parse(DateFormat('D').format(date));
  final wday = date.weekday; // 1=Mon, 7=Sun
  final weekNumber = ((dayOfYear - wday + 10) / 7).floor();
  if (weekNumber < 1) {
    // Belongs to last week of previous year
    return _isoWeekNumber(DateTime(date.year - 1, 12, 31));
  }
  if (weekNumber > 52) {
    final dec31 = DateTime(date.year, 12, 31);
    final dec31Wday = dec31.weekday;
    if (dec31Wday < 4) return 1; // Belongs to week 1 of next year
  }
  return weekNumber;
}

/// ISO week year (may differ from calendar year at year boundaries)
int _isoWeekYear(DateTime date) {
  final weekNumber = _isoWeekNumber(date);
  if (weekNumber > 50 && date.month == 1) return date.year - 1;
  if (weekNumber == 1 && date.month == 12) return date.year + 1;
  return date.year;
}

/// Parses a JSON-formatted tags string.
List<String> _parseTags(String tagsJson) {
  try {
    if (tagsJson.isEmpty || tagsJson == '[]') return [];
    final decoded = jsonDecode(tagsJson);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
    return [];
  } catch (e) {
    return [];
  }
}

/// Extracts image URLs from cards (up to 5).
Future<List<String>> _extractImages(
  String userId,
  FileSystemService fileSystemService,
  List<CardCacheData> cards,
) async {
  final images = <String>[];
  for (final card in cards) {
    if (images.length >= 5) break;
    try {
      final cardData =
          await fileSystemService.readCardFile(userId, card.factId);
      if (cardData == null) continue;
      final assetsAndText = await extractAssetsAndRawText(userId, cardData);
      final assets = assetsAndText['assets'] as List<AssetData>;
      for (final asset in assets) {
        if (asset.type == 'image' && images.length < 5) {
          images.add(asset.url);
        }
      }
    } catch (e) {
      _logger.fine('Failed to extract images from ${card.factId}: $e');
    }
  }
  return images;
}
