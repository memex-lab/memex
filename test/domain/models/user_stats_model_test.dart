import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/user_stats_model.dart';

void main() {
  group('UserStatsSnapshot trend buckets', () {
    test('uses daily buckets for shorter ranges', () {
      final snapshot = _snapshot(start: DateTime(2026, 1, 1), dayCount: 30);

      final buckets = snapshot.trendBuckets();

      expect(snapshot.preferredTrendBucketSizeDays, 1);
      expect(buckets, hasLength(30));
      expect(buckets.first.isSingleDay, isTrue);
      expect(buckets.first.key, '2026-01-01');
      expect(buckets.first.inputs, 1);
      expect(snapshot.maxTrendValueFor(UserStatsMetric.inputs), 30);
    });

    test('groups ninety-day ranges into seven-day buckets', () {
      final snapshot = _snapshot(start: DateTime(2026, 1, 1), dayCount: 90);

      final buckets = snapshot.trendBuckets();

      expect(snapshot.preferredTrendBucketSizeDays, 7);
      expect(buckets, hasLength(13));
      expect(buckets.first.key, '2026-01-01_2026-01-07');
      expect(buckets.first.start, DateTime(2026, 1, 1));
      expect(buckets.first.end, DateTime(2026, 1, 7));
      expect(buckets.first.inputs, 28);
      expect(buckets.first.cards, 7);
      expect(buckets.last.dailyPoints, hasLength(6));
      expect(buckets.last.start, DateTime(2026, 3, 26));
      expect(buckets.last.end, DateTime(2026, 3, 31));
      expect(snapshot.maxTrendValueFor(UserStatsMetric.inputs), 567);
    });

    test('combines and deduplicates details for a bucket', () {
      final snapshot = _snapshot(start: DateTime(2026, 1, 1), dayCount: 90);

      final detail = snapshot.detailForBucket(snapshot.trendBuckets().first);

      expect(detail.date, DateTime(2026, 1, 1));
      expect(detail.cardTitles, ['Card 0', 'Card 1']);
      expect(detail.knowledgePaths, ['PKM/Area 0.md', 'PKM/Area 1.md']);
      expect(detail.insightTitles, ['Insight 0', 'Insight 1']);
      expect(detail.completedTodoTitles, ['Todo 0', 'Todo 1']);
    });
  });
}

UserStatsSnapshot _snapshot({required DateTime start, required int dayCount}) {
  final daily = List.generate(dayCount, (index) {
    return UserStatsDailyPoint(
      date: start.add(Duration(days: index)),
      inputs: index + 1,
      words: (index + 1) * 10,
      cards: 1,
      knowledgeUnits: index.isEven ? 1 : 0,
      insights: index % 3 == 0 ? 1 : 0,
      completedTodos: index % 4 == 0 ? 1 : 0,
    );
  });

  return UserStatsSnapshot(
    range: UserStatsDateRange(
      start: start,
      end: start.add(Duration(days: dayCount - 1)),
    ),
    summary: UserStatsSummary(
      totalInputs: daily.fold(0, (sum, point) => sum + point.inputs),
      totalWords: daily.fold(0, (sum, point) => sum + point.words),
      totalCards: daily.fold(0, (sum, point) => sum + point.cards),
      totalKnowledgeUnits: daily.fold(
        0,
        (sum, point) => sum + point.knowledgeUnits,
      ),
      totalInsights: daily.fold(0, (sum, point) => sum + point.insights),
      totalCompletedTodos: daily.fold(
        0,
        (sum, point) => sum + point.completedTodos,
      ),
      activeDays: daily.where((point) => point.isActive).length,
      currentStreakDays: daily.where((point) => point.isActive).length,
    ),
    daily: daily,
    sourceBreakdown: const UserStatsSourceBreakdown(
      textInputs: 1,
      imageInputs: 0,
      audioInputs: 0,
    ),
    topTags: const [],
    dayDetails: {
      for (var index = 0; index < dayCount; index++)
        _dateKey(daily[index].date): UserStatsDayDetail(
          date: daily[index].date,
          cardTitles: ['Card ${index % 2}'],
          knowledgePaths: ['PKM/Area ${index % 2}.md'],
          insightTitles: ['Insight ${index % 2}'],
          completedTodoTitles: ['Todo ${index % 2}'],
        ),
    },
  );
}

String _dateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
