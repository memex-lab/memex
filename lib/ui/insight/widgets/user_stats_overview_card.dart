import 'package:flutter/material.dart';

import 'package:memex/domain/models/user_stats_model.dart';
import 'package:memex/utils/user_storage.dart';

class UserStatsOverviewCard extends StatelessWidget {
  const UserStatsOverviewCard({
    super.key,
    required this.snapshot,
    required this.isLoading,
    required this.onTap,
  });

  final UserStatsSnapshot? snapshot;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final summary = snapshot?.summary;
    final daily = snapshot?.daily ?? const <UserStatsDailyPoint>[];
    final hasSnapshot = summary != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('user_stats_overview_card'),
        onTap: hasSnapshot ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: !hasSnapshot
              ? const _OverviewLoading()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.query_stats_rounded,
                            size: 18,
                            color: Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            UserStorage.l10n.activityStats,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (isLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF9CA3AF),
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF9CA3AF),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      UserStorage.l10n.activityStatsSummary(
                        summary.totalInputs,
                        summary.totalCards,
                        summary.totalCompletedTodos,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _MetricPill(
                          label: UserStorage.l10n.records,
                          value: summary.totalInputs,
                          color: const Color(0xFF5B6CFF),
                        ),
                        const SizedBox(width: 8),
                        _MetricPill(
                          label: UserStorage.l10n.cards,
                          value: summary.totalCards,
                          color: const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        _MetricPill(
                          label: UserStorage.l10n.completedTodos,
                          value: summary.totalCompletedTodos,
                          color: const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(height: 42, child: _MiniBarChart(points: daily)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({required this.points});

  final List<UserStatsDailyPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    final maxValue = points
        .map((point) => point.inputs + point.cards + point.completedTodos)
        .fold<int>(1, (max, value) => value > max ? value : max);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: points.map((point) {
        final value = point.inputs + point.cards + point.completedTodos;
        final height = 8 + (value / maxValue) * 30;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: value == 0
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF5B6CFF).withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _OverviewLoading extends StatelessWidget {
  const _OverviewLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}
