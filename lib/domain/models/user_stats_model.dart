enum UserStatsMetric {
  inputs,
  words,
  cards,
  knowledgeUnits,
  insights,
  completedTodos,
}

class UserStatsDateRange {
  final DateTime start;
  final DateTime end;

  const UserStatsDateRange({required this.start, required this.end});

  factory UserStatsDateRange.lastDays(int days, {DateTime? now}) {
    final anchor = now ?? DateTime.now();
    final end = DateTime(anchor.year, anchor.month, anchor.day);
    return UserStatsDateRange(
      start: end.subtract(Duration(days: days - 1)),
      end: end,
    );
  }

  int get dayCount => end.difference(start).inDays + 1;

  Map<String, dynamic> toJson() => {
    'start': _dateKey(start),
    'end': _dateKey(end),
    'day_count': dayCount,
  };
}

class UserStatsSummary {
  final int totalInputs;
  final int totalWords;
  final int totalCards;
  final int totalKnowledgeUnits;
  final int totalInsights;
  final int totalCompletedTodos;
  final int activeDays;
  final int currentStreakDays;

  const UserStatsSummary({
    required this.totalInputs,
    required this.totalWords,
    required this.totalCards,
    required this.totalKnowledgeUnits,
    required this.totalInsights,
    required this.totalCompletedTodos,
    required this.activeDays,
    required this.currentStreakDays,
  });

  int get totalOutputs =>
      totalCards + totalKnowledgeUnits + totalInsights + totalCompletedTodos;

  Map<String, dynamic> toJson() => {
    'total_inputs': totalInputs,
    'total_words': totalWords,
    'total_cards': totalCards,
    'total_knowledge_units': totalKnowledgeUnits,
    'total_insights': totalInsights,
    'total_completed_todos': totalCompletedTodos,
    'total_outputs': totalOutputs,
    'active_days': activeDays,
    'current_streak_days': currentStreakDays,
  };
}

class UserStatsDailyPoint {
  final DateTime date;
  final int inputs;
  final int words;
  final int cards;
  final int knowledgeUnits;
  final int insights;
  final int completedTodos;

  const UserStatsDailyPoint({
    required this.date,
    required this.inputs,
    required this.words,
    required this.cards,
    required this.knowledgeUnits,
    required this.insights,
    required this.completedTodos,
  });

  bool get isActive =>
      inputs > 0 ||
      cards > 0 ||
      knowledgeUnits > 0 ||
      insights > 0 ||
      completedTodos > 0;

  int valueFor(UserStatsMetric metric) {
    switch (metric) {
      case UserStatsMetric.inputs:
        return inputs;
      case UserStatsMetric.words:
        return words;
      case UserStatsMetric.cards:
        return cards;
      case UserStatsMetric.knowledgeUnits:
        return knowledgeUnits;
      case UserStatsMetric.insights:
        return insights;
      case UserStatsMetric.completedTodos:
        return completedTodos;
    }
  }

  Map<String, dynamic> toJson() => {
    'date': _dateKey(date),
    'inputs': inputs,
    'words': words,
    'cards': cards,
    'knowledge_units': knowledgeUnits,
    'insights': insights,
    'completed_todos': completedTodos,
    'is_active': isActive,
  };
}

class UserStatsTrendBucket {
  final DateTime start;
  final DateTime end;
  final List<UserStatsDailyPoint> dailyPoints;
  final int inputs;
  final int words;
  final int cards;
  final int knowledgeUnits;
  final int insights;
  final int completedTodos;

  const UserStatsTrendBucket({
    required this.start,
    required this.end,
    required this.dailyPoints,
    required this.inputs,
    required this.words,
    required this.cards,
    required this.knowledgeUnits,
    required this.insights,
    required this.completedTodos,
  });

  factory UserStatsTrendBucket.fromPoints(List<UserStatsDailyPoint> points) {
    if (points.isEmpty) {
      throw ArgumentError.value(points, 'points', 'Must not be empty');
    }
    return UserStatsTrendBucket(
      start: points.first.date,
      end: points.last.date,
      dailyPoints: List.unmodifiable(points),
      inputs: points.fold(0, (sum, point) => sum + point.inputs),
      words: points.fold(0, (sum, point) => sum + point.words),
      cards: points.fold(0, (sum, point) => sum + point.cards),
      knowledgeUnits: points.fold(
        0,
        (sum, point) => sum + point.knowledgeUnits,
      ),
      insights: points.fold(0, (sum, point) => sum + point.insights),
      completedTodos: points.fold(
        0,
        (sum, point) => sum + point.completedTodos,
      ),
    );
  }

  bool get isSingleDay => _dateKey(start) == _dateKey(end);

  String get key =>
      isSingleDay ? _dateKey(start) : '${_dateKey(start)}_${_dateKey(end)}';

  int valueFor(UserStatsMetric metric) {
    switch (metric) {
      case UserStatsMetric.inputs:
        return inputs;
      case UserStatsMetric.words:
        return words;
      case UserStatsMetric.cards:
        return cards;
      case UserStatsMetric.knowledgeUnits:
        return knowledgeUnits;
      case UserStatsMetric.insights:
        return insights;
      case UserStatsMetric.completedTodos:
        return completedTodos;
    }
  }

  UserStatsDailyPoint toAggregatePoint() {
    return UserStatsDailyPoint(
      date: start,
      inputs: inputs,
      words: words,
      cards: cards,
      knowledgeUnits: knowledgeUnits,
      insights: insights,
      completedTodos: completedTodos,
    );
  }
}

class UserStatsSourceBreakdown {
  final int textInputs;
  final int imageInputs;
  final int audioInputs;

  const UserStatsSourceBreakdown({
    required this.textInputs,
    required this.imageInputs,
    required this.audioInputs,
  });

  int get total => textInputs + imageInputs + audioInputs;

  Map<String, dynamic> toJson() => {
    'text_inputs': textInputs,
    'image_inputs': imageInputs,
    'audio_inputs': audioInputs,
    'total': total,
  };
}

class UserStatsTopTag {
  final String label;
  final int count;

  const UserStatsTopTag({required this.label, required this.count});

  Map<String, dynamic> toJson() => {'label': label, 'count': count};
}

class UserStatsDayDetail {
  final DateTime date;
  final List<String> cardTitles;
  final List<String> knowledgePaths;
  final List<String> insightTitles;
  final List<String> completedTodoTitles;

  const UserStatsDayDetail({
    required this.date,
    this.cardTitles = const [],
    this.knowledgePaths = const [],
    this.insightTitles = const [],
    this.completedTodoTitles = const [],
  });

  Map<String, dynamic> toJson() => {
    'date': _dateKey(date),
    'card_titles': cardTitles,
    'knowledge_paths': knowledgePaths,
    'insight_titles': insightTitles,
    'completed_todo_titles': completedTodoTitles,
  };
}

class UserStatsSnapshot {
  final UserStatsDateRange range;
  final UserStatsSummary summary;
  final List<UserStatsDailyPoint> daily;
  final UserStatsSourceBreakdown sourceBreakdown;
  final List<UserStatsTopTag> topTags;
  final Map<String, UserStatsDayDetail> dayDetails;

  const UserStatsSnapshot({
    required this.range,
    required this.summary,
    required this.daily,
    required this.sourceBreakdown,
    required this.topTags,
    required this.dayDetails,
  });

  factory UserStatsSnapshot.empty(UserStatsDateRange range) {
    final daily = List.generate(range.dayCount, (index) {
      return UserStatsDailyPoint(
        date: range.start.add(Duration(days: index)),
        inputs: 0,
        words: 0,
        cards: 0,
        knowledgeUnits: 0,
        insights: 0,
        completedTodos: 0,
      );
    });
    return UserStatsSnapshot(
      range: range,
      summary: const UserStatsSummary(
        totalInputs: 0,
        totalWords: 0,
        totalCards: 0,
        totalKnowledgeUnits: 0,
        totalInsights: 0,
        totalCompletedTodos: 0,
        activeDays: 0,
        currentStreakDays: 0,
      ),
      daily: daily,
      sourceBreakdown: const UserStatsSourceBreakdown(
        textInputs: 0,
        imageInputs: 0,
        audioInputs: 0,
      ),
      topTags: const [],
      dayDetails: {
        for (final point in daily)
          _dateKey(point.date): UserStatsDayDetail(date: point.date),
      },
    );
  }

  UserStatsDailyPoint? pointFor(DateTime date) {
    final key = _dateKey(date);
    for (final point in daily) {
      if (_dateKey(point.date) == key) return point;
    }
    return null;
  }

  int maxValueFor(UserStatsMetric metric) {
    var max = 0;
    for (final point in daily) {
      final value = point.valueFor(metric);
      if (value > max) max = value;
    }
    return max;
  }

  int get preferredTrendBucketSizeDays => range.dayCount >= 90 ? 7 : 1;

  List<UserStatsTrendBucket> trendBuckets({int? bucketSizeDays}) {
    final size = bucketSizeDays ?? preferredTrendBucketSizeDays;
    if (daily.isEmpty) return const [];
    if (size <= 1) {
      return daily
          .map((point) => UserStatsTrendBucket.fromPoints([point]))
          .toList();
    }

    final buckets = <UserStatsTrendBucket>[];
    for (var index = 0; index < daily.length; index += size) {
      final end = index + size > daily.length ? daily.length : index + size;
      buckets.add(UserStatsTrendBucket.fromPoints(daily.sublist(index, end)));
    }
    return buckets;
  }

  int maxTrendValueFor(UserStatsMetric metric, {int? bucketSizeDays}) {
    var max = 0;
    for (final bucket in trendBuckets(bucketSizeDays: bucketSizeDays)) {
      final value = bucket.valueFor(metric);
      if (value > max) max = value;
    }
    return max;
  }

  UserStatsDayDetail detailForBucket(UserStatsTrendBucket bucket) {
    final cardTitles = <String>[];
    final knowledgePaths = <String>[];
    final insightTitles = <String>[];
    final completedTodoTitles = <String>[];

    for (final point in bucket.dailyPoints) {
      final detail = dayDetails[_dateKey(point.date)];
      if (detail == null) continue;
      cardTitles.addAll(detail.cardTitles);
      knowledgePaths.addAll(detail.knowledgePaths);
      insightTitles.addAll(detail.insightTitles);
      completedTodoTitles.addAll(detail.completedTodoTitles);
    }

    return UserStatsDayDetail(
      date: bucket.start,
      cardTitles: _dedupe(cardTitles),
      knowledgePaths: _dedupe(knowledgePaths),
      insightTitles: _dedupe(insightTitles),
      completedTodoTitles: _dedupe(completedTodoTitles),
    );
  }

  Map<String, dynamic> toJson() => {
    'range': range.toJson(),
    'summary': summary.toJson(),
    'daily': daily.map((point) => point.toJson()).toList(),
    'source_breakdown': sourceBreakdown.toJson(),
    'top_tags': topTags.map((tag) => tag.toJson()).toList(),
    'day_details': dayDetails.map((key, value) {
      return MapEntry(key, value.toJson());
    }),
  };
}

List<String> _dedupe(List<String> values) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in values) {
    if (seen.add(value)) result.add(value);
  }
  return result;
}

String _dateKey(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
