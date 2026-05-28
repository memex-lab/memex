import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:memex/domain/models/user_stats_model.dart';
import 'package:memex/utils/user_storage.dart';

class UserStatsPage extends StatelessWidget {
  const UserStatsPage({
    super.key,
    required this.snapshot,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedDays,
    required this.selectedMetric,
    required this.onMetricChanged,
    required this.onPresetSelected,
    required this.onReload,
    this.header,
  });

  final UserStatsSnapshot? snapshot;
  final bool isLoading;
  final String? errorMessage;
  final int selectedDays;
  final UserStatsMetric selectedMetric;
  final ValueChanged<UserStatsMetric> onMetricChanged;
  final ValueChanged<int> onPresetSelected;
  final VoidCallback onReload;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    if (isLoading && snapshot == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null && snapshot == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onReload,
                child: Text(UserStorage.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final data = snapshot;
    if (data == null) {
      return Center(child: Text(UserStorage.l10n.noStatsYet));
    }

    return ListView(
      key: const ValueKey('user_stats_page'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
      children: [
        const SizedBox(height: 16),
        if (header != null) ...[header!, const SizedBox(height: 16)],
        _RangeSelector(
          selectedDays: selectedDays,
          isLoading: isLoading,
          onSelected: onPresetSelected,
        ),
        const SizedBox(height: 16),
        _SummaryPanel(snapshot: data),
        const SizedBox(height: 16),
        _MetricGrid(snapshot: data),
        const SizedBox(height: 16),
        _DailyRhythmCard(
          snapshot: data,
          selectedMetric: selectedMetric,
          onMetricChanged: onMetricChanged,
        ),
        const SizedBox(height: 16),
        _OutputFlowCard(snapshot: data),
        const SizedBox(height: 16),
        _SourceBreakdownCard(snapshot: data),
        const SizedBox(height: 16),
        _TopThemesCard(snapshot: data),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.selectedDays,
    required this.isLoading,
    required this.onSelected,
  });

  final int selectedDays;
  final bool isLoading;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      (7, UserStorage.l10n.last7Days),
      (30, UserStorage.l10n.last30Days),
      (90, UserStorage.l10n.last90Days),
    ];
    return Row(
      children: [
        ...items.map((item) {
          final selected = selectedDays == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              key: ValueKey('stats_range_${item.$1}'),
              label: Text(item.$2),
              selected: selected,
              onSelected: (_) => onSelected(item.$1),
              selectedColor: const Color(0xFF111827),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF4B5563),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF111827)
                      : const Color(0xFFE5E7EB),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        if (isLoading)
          const SizedBox(
            key: ValueKey('stats_range_loading'),
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
            ),
          ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.snapshot});

  final UserStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final summary = snapshot.summary;
    return _SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6CFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Color(0xFF5B6CFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  UserStorage.l10n.activityStats,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            UserStorage.l10n.activityStatsSummary(
              summary.totalInputs,
              summary.totalCards,
              summary.totalCompletedTodos,
            ),
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.snapshot});

  final UserStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final summary = snapshot.summary;
    final items = [
      _MetricItem(
        UserStorage.l10n.records,
        summary.totalInputs,
        Icons.edit_note_rounded,
        const Color(0xFF5B6CFF),
      ),
      _MetricItem(
        UserStorage.l10n.words,
        summary.totalWords,
        Icons.notes_rounded,
        const Color(0xFF0EA5E9),
      ),
      _MetricItem(
        UserStorage.l10n.cards,
        summary.totalCards,
        Icons.view_agenda_rounded,
        const Color(0xFF10B981),
      ),
      _MetricItem(
        UserStorage.l10n.knowledgeUnits,
        summary.totalKnowledgeUnits,
        Icons.hub_rounded,
        const Color(0xFF8B5CF6),
      ),
      _MetricItem(
        UserStorage.l10n.knowledgeInsight,
        summary.totalInsights,
        Icons.auto_awesome_rounded,
        const Color(0xFFF59E0B),
      ),
      _MetricItem(
        UserStorage.l10n.completedTodos,
        summary.totalCompletedTodos,
        Icons.task_alt_rounded,
        const Color(0xFFEF4444),
      ),
      _MetricItem(
        UserStorage.l10n.activeDays,
        summary.activeDays,
        Icons.calendar_month_rounded,
        const Color(0xFF14B8A6),
      ),
      _MetricItem(
        UserStorage.l10n.streakDays,
        summary.currentStreakDays,
        Icons.local_fire_department_rounded,
        const Color(0xFFF97316),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.25,
      ),
      itemBuilder: (context, index) => _MetricTile(item: items[index]),
    );
  }
}

class _DailyRhythmCard extends StatelessWidget {
  const _DailyRhythmCard({
    required this.snapshot,
    required this.selectedMetric,
    required this.onMetricChanged,
  });

  final UserStatsSnapshot snapshot;
  final UserStatsMetric selectedMetric;
  final ValueChanged<UserStatsMetric> onMetricChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: UserStorage.l10n.dailyRhythm,
            subtitle: UserStorage.l10n.tapDayForDetails,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: UserStatsMetric.values.map((metric) {
                final selected = metric == selectedMetric;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: ValueKey('stats_metric_${metric.name}'),
                    label: Text(_metricLabel(metric)),
                    selected: selected,
                    onSelected: (_) => onMetricChanged(metric),
                    selectedColor: const Color(0xFF5B6CFF),
                    backgroundColor: const Color(0xFFF9FAFB),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF4B5563),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF5B6CFF)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          _DailyBars(snapshot: snapshot, metric: selectedMetric),
        ],
      ),
    );
  }
}

class _DailyBars extends StatelessWidget {
  const _DailyBars({required this.snapshot, required this.metric});

  final UserStatsSnapshot snapshot;
  final UserStatsMetric metric;

  @override
  Widget build(BuildContext context) {
    final buckets = snapshot.trendBuckets();
    final maxValue = snapshot.maxTrendValueFor(metric).clamp(1, 1 << 30);
    final formatter = DateFormat.Md(UserStorage.l10n.localeName);
    final bucketWidth = snapshot.preferredTrendBucketSizeDays > 1 ? 44.0 : 28.0;
    final minContentWidth = buckets.length * bucketWidth;
    final viewportWidth = MediaQuery.sizeOf(context).width - 80;
    final contentWidth = buckets.length <= 14
        ? (viewportWidth < minContentWidth ? minContentWidth : viewportWidth)
        : minContentWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: contentWidth,
        height: 172,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: buckets.map((bucket) {
            final value = bucket.valueFor(metric);
            final height = value == 0 ? 8.0 : 20 + value / maxValue * 100;
            final key = bucket.isSingleDay
                ? 'stats_day_${_dateKey(bucket.start)}'
                : 'stats_bucket_${bucket.key}';
            return Expanded(
              child: GestureDetector(
                key: ValueKey(key),
                behavior: HitTestBehavior.opaque,
                onTap: () => _showBucketDetails(context, snapshot, bucket),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        value == 0 ? '' : value.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: double.infinity,
                        height: height,
                        decoration: BoxDecoration(
                          color: value == 0
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF5B6CFF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatter.format(bucket.start),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _OutputFlowCard extends StatelessWidget {
  const _OutputFlowCard({required this.snapshot});

  final UserStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final summary = snapshot.summary;
    final values = [
      (UserStorage.l10n.records, summary.totalInputs, const Color(0xFF5B6CFF)),
      (UserStorage.l10n.cards, summary.totalCards, const Color(0xFF10B981)),
      (
        UserStorage.l10n.knowledgeUnits,
        summary.totalKnowledgeUnits,
        const Color(0xFF8B5CF6),
      ),
      (
        UserStorage.l10n.knowledgeInsight,
        summary.totalInsights,
        const Color(0xFFF59E0B),
      ),
      (
        UserStorage.l10n.completedTodos,
        summary.totalCompletedTodos,
        const Color(0xFFEF4444),
      ),
    ];
    final maxValue = values
        .map((item) => item.$2)
        .fold<int>(1, (max, value) => value > max ? value : max);

    return _SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: UserStorage.l10n.recordToOutput),
          const SizedBox(height: 14),
          ...values.map((item) {
            final widthFactor = item.$2 / maxValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        item.$2.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: widthFactor,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(item.$3),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SourceBreakdownCard extends StatelessWidget {
  const _SourceBreakdownCard({required this.snapshot});

  final UserStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final source = snapshot.sourceBreakdown;
    final items = [
      (UserStorage.l10n.textInput, source.textInputs, const Color(0xFF5B6CFF)),
      (
        UserStorage.l10n.imageInput,
        source.imageInputs,
        const Color(0xFF10B981),
      ),
      (
        UserStorage.l10n.audioInput,
        source.audioInputs,
        const Color(0xFFF59E0B),
      ),
    ];
    final total = source.total == 0 ? 1 : source.total;

    return _SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: UserStorage.l10n.sourceBreakdown),
          const SizedBox(height: 14),
          Row(
            children: items.map((item) {
              final flex = item.$2 == 0 ? 1 : item.$2;
              return Expanded(
                flex: flex,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: item.$2 == 0
                        ? const Color(0xFFE5E7EB)
                        : item.$3.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final percentage = (item.$2 / total * 100).round();
              return _LegendPill(
                label: '${item.$1} $percentage%',
                color: item.$3,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TopThemesCard extends StatelessWidget {
  const _TopThemesCard({required this.snapshot});

  final UserStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: UserStorage.l10n.topThemes),
          const SizedBox(height: 12),
          if (snapshot.topTags.isEmpty)
            Text(
              UserStorage.l10n.noData,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: snapshot.topTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${tag.label} ${tag.count}',
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _MetricItem {
  const _MetricItem(this.label, this.value, this.icon, this.color);

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSurface extends StatelessWidget {
  const _SectionSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _metricLabel(UserStatsMetric metric) {
  switch (metric) {
    case UserStatsMetric.inputs:
      return UserStorage.l10n.records;
    case UserStatsMetric.words:
      return UserStorage.l10n.words;
    case UserStatsMetric.cards:
      return UserStorage.l10n.cards;
    case UserStatsMetric.knowledgeUnits:
      return UserStorage.l10n.knowledgeUnits;
    case UserStatsMetric.insights:
      return UserStorage.l10n.knowledgeInsight;
    case UserStatsMetric.completedTodos:
      return UserStorage.l10n.completedTodos;
  }
}

void _showBucketDetails(
  BuildContext context,
  UserStatsSnapshot snapshot,
  UserStatsTrendBucket bucket,
) {
  final detail = snapshot.detailForBucket(bucket);
  final formatter = DateFormat.yMMMd(UserStorage.l10n.localeName);
  final dateLabel = bucket.isSingleDay
      ? formatter.format(bucket.start)
      : '${formatter.format(bucket.start)} - ${formatter.format(bucket.end)}';

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  UserStorage.l10n.dayDetails,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                _DetailCountRow(point: bucket.toAggregatePoint()),
                const SizedBox(height: 18),
                _DetailList(
                  title: UserStorage.l10n.cards,
                  items: detail.cardTitles,
                ),
                _DetailList(
                  title: UserStorage.l10n.knowledgeUnits,
                  items: detail.knowledgePaths,
                ),
                _DetailList(
                  title: UserStorage.l10n.knowledgeInsight,
                  items: detail.insightTitles,
                ),
                _DetailList(
                  title: UserStorage.l10n.completedTodos,
                  items: detail.completedTodoTitles,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _DetailCountRow extends StatelessWidget {
  const _DetailCountRow({required this.point});

  final UserStatsDailyPoint point;

  @override
  Widget build(BuildContext context) {
    final items = [
      (UserStorage.l10n.records, point.inputs),
      (UserStorage.l10n.cards, point.cards),
      (UserStorage.l10n.knowledgeInsight, point.insights),
      (UserStorage.l10n.completedTodos, point.completedTodos),
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$2.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DetailList extends StatelessWidget {
  const _DetailList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          ...items.take(6).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Color(0xFF4B5563),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String _dateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
