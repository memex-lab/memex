import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;

import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/user_stats_model.dart';
import 'package:memex/utils/logger.dart';

final _logger = getLogger('UserStatsService');

Future<UserStatsSnapshot> _fetchUserStatsSnapshotInWorker(
  String dataRoot,
  String userId,
  DateTime start,
  DateTime end,
) {
  final fileSystemService = FileSystemService.detached(dataRoot: dataRoot);
  return UserStatsService(
    fileSystemService: fileSystemService,
    useBackgroundIsolate: false,
  ).fetchSnapshot(
    userId: userId,
    range: UserStatsDateRange(start: start, end: end),
  );
}

class UserStatsService {
  UserStatsService({
    FileSystemService? fileSystemService,
    bool useBackgroundIsolate = true,
  }) : _fileSystemService = fileSystemService ?? FileSystemService.instance,
       _useBackgroundIsolate = useBackgroundIsolate;

  final FileSystemService _fileSystemService;
  final bool _useBackgroundIsolate;

  Future<UserStatsSnapshot> fetchSnapshot({
    required String userId,
    required UserStatsDateRange range,
  }) async {
    final normalizedRange = UserStatsDateRange(
      start: _dateOnly(range.start),
      end: _dateOnly(range.end),
    );
    if (normalizedRange.end.isBefore(normalizedRange.start)) {
      return UserStatsSnapshot.empty(normalizedRange);
    }

    if (_useBackgroundIsolate) {
      final dataRoot = _fileSystemService.dataRoot;
      final start = normalizedRange.start;
      final end = normalizedRange.end;
      return Isolate.run(
        () => _fetchUserStatsSnapshotInWorker(dataRoot, userId, start, end),
      );
    }

    return _fetchSnapshotOnCurrentIsolate(
      userId: userId,
      normalizedRange: normalizedRange,
    );
  }

  Future<UserStatsSnapshot> _fetchSnapshotOnCurrentIsolate({
    required String userId,
    required UserStatsDateRange normalizedRange,
  }) async {
    final daily = <String, _DailyStatsAccumulator>{};
    final details = <String, _DayDetailAccumulator>{};
    for (var i = 0; i < normalizedRange.dayCount; i++) {
      final date = normalizedRange.start.add(Duration(days: i));
      final key = _dateKey(date);
      daily[key] = _DailyStatsAccumulator(date);
      details[key] = _DayDetailAccumulator(date);
    }

    final events = await _loadEvents(userId, normalizedRange);

    final inputFactIds = _collectInputFactIds(events, daily);

    await _collectFactInputStats(
      userId,
      normalizedRange,
      events,
      inputFactIds,
      daily,
    );
    _collectSourceStats(events, daily);
    await _collectCardStats(
      userId,
      normalizedRange,
      events,
      inputFactIds,
      daily,
      details,
    );
    await _collectKnowledgeStats(
      userId,
      normalizedRange,
      events,
      daily,
      details,
    );
    await _collectInsightStats(userId, normalizedRange, events, daily, details);

    final dailyPoints = daily.values.map((item) => item.toPoint()).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final sourceBreakdown = UserStatsSourceBreakdown(
      textInputs: daily.values.fold(0, (sum, item) => sum + item.textInputs),
      imageInputs: daily.values.fold(0, (sum, item) => sum + item.imageInputs),
      audioInputs: daily.values.fold(0, (sum, item) => sum + item.audioInputs),
    );

    final summary = UserStatsSummary(
      totalInputs: dailyPoints.fold(0, (sum, item) => sum + item.inputs),
      totalWords: dailyPoints.fold(0, (sum, item) => sum + item.words),
      totalCards: dailyPoints.fold(0, (sum, item) => sum + item.cards),
      totalKnowledgeUnits: dailyPoints.fold(
        0,
        (sum, item) => sum + item.knowledgeUnits,
      ),
      totalInsights: dailyPoints.fold(0, (sum, item) => sum + item.insights),
      totalCompletedTodos: dailyPoints.fold(
        0,
        (sum, item) => sum + item.completedTodos,
      ),
      activeDays: dailyPoints.where((item) => item.isActive).length,
      currentStreakDays: _currentStreak(dailyPoints),
    );

    final topTags = _buildTopTags(daily.values);
    final dayDetails = {
      for (final entry in details.entries) entry.key: entry.value.toDetail(),
    };

    return UserStatsSnapshot(
      range: normalizedRange,
      summary: summary,
      daily: dailyPoints,
      sourceBreakdown: sourceBreakdown.total == 0 && summary.totalInputs > 0
          ? UserStatsSourceBreakdown(
              textInputs: summary.totalInputs,
              imageInputs: 0,
              audioInputs: 0,
            )
          : sourceBreakdown,
      topTags: topTags,
      dayDetails: dayDetails,
    );
  }

  Future<List<Map<String, dynamic>>> _loadEvents(
    String userId,
    UserStatsDateRange range,
  ) async {
    try {
      return await _fileSystemService.eventLogService.searchEvents(
        userId: userId,
        fromTime: range.start.toIso8601String(),
        toTime: range.end
            .add(const Duration(days: 1))
            .subtract(const Duration(microseconds: 1))
            .toIso8601String(),
        offset: 0,
        limit: 100000,
      );
    } catch (e) {
      _logger.warning('Failed to load user stats events: $e');
      return const [];
    }
  }

  Future<void> _collectFactInputStats(
    String userId,
    UserStatsDateRange range,
    List<Map<String, dynamic>> events,
    Set<String> inputFactIds,
    Map<String, _DailyStatsAccumulator> daily,
  ) async {
    final userInputCountsByDay = <String, int>{};
    for (final event in events) {
      if (event['event_type'] != 'user_input') continue;
      final date = _eventDate(event);
      if (date == null) continue;
      final key = _dateKey(date);
      if (!daily.containsKey(key)) continue;
      userInputCountsByDay[key] = (userInputCountsByDay[key] ?? 0) + 1;
    }
    final hasUserInputEvents = userInputCountsByDay.isNotEmpty;

    for (var i = 0; i < range.dayCount; i++) {
      final date = range.start.add(Duration(days: i));
      final key = _dateKey(date);
      final file = File(_factPath(userId, date));
      final eventInputCount = userInputCountsByDay[key] ?? 0;

      try {
        if (hasUserInputEvents) {
          daily[key]?.inputs += eventInputCount;
          if (!await file.exists()) continue;

          final content = await file.readAsString();
          final entries = _parseFactEntries(content, date);
          final eventEntries = entries.where(
            (entry) => inputFactIds.contains(entry.factId),
          );
          daily[key]?.words += eventEntries.fold(
            0,
            (sum, item) => sum + item.words,
          );
          continue;
        }

        if (!await file.exists()) continue;
        final content = await file.readAsString();
        final entries = _parseFactEntries(content, date);
        daily[key]?.inputs += entries.length;
        daily[key]?.words += entries.fold(0, (sum, item) => sum + item.words);
      } catch (e) {
        _logger.warning('Failed to read fact stats from ${file.path}: $e');
      }
    }
  }

  void _collectSourceStats(
    List<Map<String, dynamic>> events,
    Map<String, _DailyStatsAccumulator> daily,
  ) {
    for (final event in events) {
      if (event['event_type'] != 'user_input') continue;
      final date = _eventDate(event);
      if (date == null) continue;
      final bucket = daily[_dateKey(date)];
      if (bucket == null) continue;

      final metadata = _metadata(event);
      if (metadata['has_text'] == true) bucket.textInputs += 1;
      if (metadata['has_images'] == true) bucket.imageInputs += 1;
      if (metadata['has_audio'] == true) bucket.audioInputs += 1;
    }
  }

  Future<void> _collectCardStats(
    String userId,
    UserStatsDateRange range,
    List<Map<String, dynamic>> events,
    Set<String> inputFactIds,
    Map<String, _DailyStatsAccumulator> daily,
    Map<String, _DayDetailAccumulator> details,
  ) async {
    final completionEvents = _collectTodoCompletionEvents(
      events,
      daily,
      details,
    );
    final hasTodoCompletionEvents = completionEvents > 0;

    final cardPaths = await _fileSystemService.listAllCardFiles(userId);
    for (final cardPath in cardPaths) {
      final factId = _factIdFromCardPath(userId, cardPath);
      if (factId == null) continue;
      if (inputFactIds.isNotEmpty && !inputFactIds.contains(factId)) {
        continue;
      }

      final card = await _fileSystemService.readCardFile(userId, factId);
      if (card == null || card.deleted == true) continue;

      final date = _cardDate(card);
      if (!_dateInRange(date, range)) continue;
      final key = _dateKey(date);
      final bucket = daily[key];
      if (bucket == null) continue;

      if (_isGeneratedCard(card)) {
        bucket.cards += 1;
        details[key]?.cardTitles.add(_cardTitle(card));
      }

      for (final tag in card.tags) {
        final trimmed = tag.trim();
        if (trimmed.isNotEmpty) {
          bucket.tagCounts[trimmed] = (bucket.tagCounts[trimmed] ?? 0) + 1;
        }
      }

      if (!hasTodoCompletionEvents && _isCompletedTask(card)) {
        bucket.completedTodos += 1;
        details[key]?.completedTodoTitles.add(_cardTitle(card));
      }
    }
  }

  int _collectTodoCompletionEvents(
    List<Map<String, dynamic>> events,
    Map<String, _DailyStatsAccumulator> daily,
    Map<String, _DayDetailAccumulator> details,
  ) {
    var count = 0;
    for (final event in events) {
      if (event['event_type'] != 'todo_completed') continue;
      final date = _eventDate(event);
      if (date == null) continue;
      final key = _dateKey(date);
      final bucket = daily[key];
      if (bucket == null) continue;

      bucket.completedTodos += 1;
      count += 1;
      final metadata = _metadata(event);
      final title = metadata['title']?.toString();
      if (title != null && title.trim().isNotEmpty) {
        details[key]?.completedTodoTitles.add(title.trim());
      }
    }
    return count;
  }

  Future<void> _collectKnowledgeStats(
    String userId,
    UserStatsDateRange range,
    List<Map<String, dynamic>> events,
    Map<String, _DailyStatsAccumulator> daily,
    Map<String, _DayDetailAccumulator> details,
  ) async {
    final byDay = <String, Set<String>>{};
    for (final event in events) {
      final type = event['event_type'];
      if (type != 'file_created' && type != 'file_modified') continue;
      final filePath = event['file_path']?.toString();
      if (filePath == null || !filePath.startsWith('PKM/')) continue;

      final date = _eventDate(event);
      if (date == null) continue;
      final key = _dateKey(date);
      if (!daily.containsKey(key)) continue;
      byDay.putIfAbsent(key, () => <String>{}).add(filePath);
    }

    if (byDay.isEmpty && events.isEmpty) {
      await _collectKnowledgeStatsFromModifiedFiles(
        userId,
        range,
        daily,
        details,
      );
      return;
    }

    for (final entry in byDay.entries) {
      final bucket = daily[entry.key];
      bucket?.knowledgeUnits += entry.value.length;
      details[entry.key]?.knowledgePaths.addAll(entry.value.toList()..sort());
    }
  }

  Future<void> _collectKnowledgeStatsFromModifiedFiles(
    String userId,
    UserStatsDateRange range,
    Map<String, _DailyStatsAccumulator> daily,
    Map<String, _DayDetailAccumulator> details,
  ) async {
    final root = Directory(_fileSystemService.getPkmPath(userId));
    if (!await root.exists()) return;

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.md')) continue;
      final stat = await entity.stat();
      final date = _dateOnly(stat.modified);
      if (!_dateInRange(date, range)) continue;
      final key = _dateKey(date);
      final relative = path.join(
        'PKM',
        path.relative(entity.path, from: root.path),
      );
      daily[key]?.knowledgeUnits += 1;
      details[key]?.knowledgePaths.add(relative);
    }
  }

  Future<void> _collectInsightStats(
    String userId,
    UserStatsDateRange range,
    List<Map<String, dynamic>> events,
    Map<String, _DailyStatsAccumulator> daily,
    Map<String, _DayDetailAccumulator> details,
  ) async {
    final createdByDay = <String, Set<String>>{};
    for (final event in events) {
      if (event['event_type'] != 'file_created') continue;
      final filePath = event['file_path']?.toString();
      if (filePath == null || !filePath.startsWith('KnowledgeInsights/')) {
        continue;
      }
      final date = _eventDate(event);
      if (date == null) continue;
      final key = _dateKey(date);
      if (!daily.containsKey(key)) continue;
      createdByDay.putIfAbsent(key, () => <String>{}).add(filePath);
      final title = _metadata(event)['title']?.toString();
      if (title != null && title.trim().isNotEmpty) {
        details[key]?.insightTitles.add(title.trim());
      }
    }

    if (createdByDay.isNotEmpty) {
      for (final entry in createdByDay.entries) {
        daily[entry.key]?.insights += entry.value.length;
      }
      return;
    }

    if (events.isNotEmpty) return;

    final cards = await _fileSystemService.listKnowledgeInsightCards(userId);
    for (final card in cards) {
      final updatedAt = DateTime.tryParse(card['updated_at']?.toString() ?? '');
      if (updatedAt == null) continue;
      final date = _dateOnly(updatedAt);
      if (!_dateInRange(date, range)) continue;
      final key = _dateKey(date);
      daily[key]?.insights += 1;
      final title = card['title']?.toString();
      if (title != null && title.trim().isNotEmpty) {
        details[key]?.insightTitles.add(title.trim());
      }
    }
  }

  List<UserStatsTopTag> _buildTopTags(Iterable<_DailyStatsAccumulator> daily) {
    final counts = <String, int>{};
    for (final item in daily) {
      item.tagCounts.forEach((tag, count) {
        counts[tag] = (counts[tag] ?? 0) + count;
      });
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });
    return entries
        .take(6)
        .map((entry) => UserStatsTopTag(label: entry.key, count: entry.value))
        .toList();
  }

  int _currentStreak(List<UserStatsDailyPoint> daily) {
    var streak = 0;
    for (final point in daily.reversed) {
      if (!point.isActive) break;
      streak += 1;
    }
    return streak;
  }

  String _factPath(String userId, DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return path.join(
      _fileSystemService.getFactsPath(userId),
      year,
      month,
      '$day.md',
    );
  }

  Set<String> _collectInputFactIds(
    List<Map<String, dynamic>> events,
    Map<String, _DailyStatsAccumulator> daily,
  ) {
    final factIds = <String>{};
    for (final event in events) {
      if (event['event_type'] != 'user_input') continue;
      final date = _eventDate(event);
      if (date == null || !daily.containsKey(_dateKey(date))) continue;
      final factId = _metadata(event)['fact_id']?.toString();
      if (factId != null && factId.trim().isNotEmpty) {
        factIds.add(factId.trim());
      }
    }
    return factIds;
  }

  List<_FactEntryStats> _parseFactEntries(String content, DateTime date) {
    final matches = RegExp(
      r'^## <id:([^>]+)>.*$',
      multiLine: true,
    ).allMatches(content).toList();
    final entries = <_FactEntryStats>[];
    for (var i = 0; i < matches.length; i++) {
      final start = matches[i].end;
      final end = i + 1 < matches.length
          ? matches[i + 1].start
          : content.length;
      final simpleId = matches[i].group(1) ?? '';
      entries.add(
        _FactEntryStats(
          factId: _factIdForDate(date, simpleId),
          words: _countWords(content.substring(start, end)),
        ),
      );
    }
    return entries;
  }

  String _factIdForDate(DateTime date, String simpleId) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$month/$day.md#$simpleId';
  }

  int _countWords(String value) {
    final withoutMedia = value
        .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]+\)'), ' ')
        .replaceAll(RegExp(r'\[[^\]]*\]\([^)]+\)'), ' ');
    final cjkCount = RegExp(r'[\u3400-\u9fff]').allMatches(withoutMedia).length;
    final latinSource = withoutMedia.replaceAll(
      RegExp(r'[\u3400-\u9fff]'),
      ' ',
    );
    final latinCount = RegExp(
      r"[A-Za-z0-9]+(?:[-'][A-Za-z0-9]+)?",
    ).allMatches(latinSource).length;
    return cjkCount + latinCount;
  }

  String? _factIdFromCardPath(String userId, String cardPath) {
    try {
      final relative = path.relative(
        cardPath,
        from: _fileSystemService.getCardsPath(userId),
      );
      final parts = path.split(relative);
      if (parts.length != 3) return null;
      final filename = path.basenameWithoutExtension(parts[2]);
      final match = RegExp(r'^(\d{2})_(ts_\d+)$').firstMatch(filename);
      if (match == null) return null;
      return '${parts[0]}/${parts[1]}/${match.group(1)}.md#${match.group(2)}';
    } catch (_) {
      return null;
    }
  }

  bool _isGeneratedCard(CardData card) {
    if (card.status == 'processing' || card.status == 'failed') return false;
    return card.uiConfigs.isNotEmpty;
  }

  bool _isCompletedTask(CardData card) {
    for (final config in card.uiConfigs) {
      if ((config.templateId == 'task' || config.templateId == 'todo') &&
          config.data['is_completed'] == true) {
        return true;
      }
    }
    return false;
  }

  DateTime _cardDate(CardData card) {
    final seconds = card.userFixedTimestamp ?? card.timestamp;
    return _dateOnly(DateTime.fromMillisecondsSinceEpoch(seconds * 1000));
  }

  String _cardTitle(CardData card) {
    final direct = card.title?.trim();
    if (direct != null && direct.isNotEmpty) return direct;
    for (final config in card.uiConfigs) {
      final title = config.data['title']?.toString().trim();
      if (title != null && title.isNotEmpty) return title;
    }
    return card.factId;
  }

  DateTime? _eventDate(Map<String, dynamic> event) {
    final raw = event['event_time']?.toString();
    if (raw == null) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return _dateOnly(parsed);
  }

  Map<String, dynamic> _metadata(Map<String, dynamic> event) {
    final metadata = event['metadata'];
    if (metadata is Map<String, dynamic>) return metadata;
    if (metadata is Map) return Map<String, dynamic>.from(metadata);
    return const {};
  }

  bool _dateInRange(DateTime date, UserStatsDateRange range) {
    return !date.isBefore(range.start) && !date.isAfter(range.end);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _dateKey(DateTime date) {
    final normalized = _dateOnly(date);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _DailyStatsAccumulator {
  _DailyStatsAccumulator(this.date);

  final DateTime date;
  int inputs = 0;
  int words = 0;
  int cards = 0;
  int knowledgeUnits = 0;
  int insights = 0;
  int completedTodos = 0;
  int textInputs = 0;
  int imageInputs = 0;
  int audioInputs = 0;
  final Map<String, int> tagCounts = {};

  UserStatsDailyPoint toPoint() => UserStatsDailyPoint(
    date: date,
    inputs: inputs,
    words: words,
    cards: cards,
    knowledgeUnits: knowledgeUnits,
    insights: insights,
    completedTodos: completedTodos,
  );
}

class _DayDetailAccumulator {
  _DayDetailAccumulator(this.date);

  final DateTime date;
  final List<String> cardTitles = [];
  final List<String> knowledgePaths = [];
  final List<String> insightTitles = [];
  final List<String> completedTodoTitles = [];

  UserStatsDayDetail toDetail() => UserStatsDayDetail(
    date: date,
    cardTitles: _dedupe(cardTitles),
    knowledgePaths: _dedupe(knowledgePaths),
    insightTitles: _dedupe(insightTitles),
    completedTodoTitles: _dedupe(completedTodoTitles),
  );

  List<String> _dedupe(List<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      if (seen.add(value)) result.add(value);
    }
    return result;
  }
}

class _FactEntryStats {
  _FactEntryStats({required this.factId, required this.words});

  final String factId;
  final int words;
}
