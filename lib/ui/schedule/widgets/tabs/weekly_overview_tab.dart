import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/schedule_item.dart';
import '../../../core/cards/ui/glass_card.dart';
import '../../../core/themes/app_colors.dart';
import '../cells/event_cell.dart';
import '../cells/todo_cell.dart';

class WeeklyOverviewTab extends StatelessWidget {
  final List<ScheduleItem> items;
  final void Function(int index) onToggle;
  final void Function(ScheduleItem) onTapItem;

  const WeeklyOverviewTab({
    super.key,
    required this.items,
    required this.onToggle,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    // Group by day
    final grouped = <String, List<ScheduleItem>>{};
    for (final item in items) {
      final key = _dayKey(item.startTime);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        _buildWeekSummaryCard(items),
        const SizedBox(height: 20),
        ...sortedKeys.expand((key) {
          final dayItems = grouped[key]!;
          return [
            _buildDayHeader(key, dayItems),
            const SizedBox(height: 10),
            ...dayItems.asMap().entries.map((entry) {
              final index = items.indexOf(entry.value);
              if (entry.value.type == ScheduleItemType.event) {
                return EventCell(
                  item: entry.value,
                  onTap: () => onTapItem(entry.value),
                  compact: true,
                );
              } else {
                return TodoCell(
                  item: entry.value,
                  onToggle: () => onToggle(index),
                  onTap: () => onTapItem(entry.value),
                  compact: true,
                );
              }
            }),
            const SizedBox(height: 20),
          ];
        }),
      ],
    );
  }

  String _dayKey(DateTime? dt) {
    if (dt == null) {
      return '未安排';
    }
    final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${dt.month}/${dt.day} ${weekdayNames[dt.weekday - 1]}';
  }

  Widget _buildWeekSummaryCard(List<ScheduleItem> allItems) {
    final done =
        allItems.where((i) => i.status == ScheduleItemStatus.completed).length;
    final total = allItems.length;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.date_range,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本周概览',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$done / $total 项已完成',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Week day indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final dayItems = allItems.where((i) {
                if (i.startTime == null) {
                  return false;
                }
                return i.startTime!.weekday == index + 1;
              }).toList();
              final dayDone = dayItems
                  .where((i) => i.status == ScheduleItemStatus.completed)
                  .length;
              final hasItems = dayItems.isNotEmpty;
              final allDone = hasItems && dayDone == dayItems.length;

              final weekdayLabels = ['一', '二', '三', '四', '五'];
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: allDone
                          ? AppColors.success.withValues(alpha: 0.15)
                          : hasItems
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: allDone
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.success,
                            )
                          : Text(
                              weekdayLabels[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: hasItems
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasItems ? '$dayDone/${dayItems.length}' : '-',
                    style: TextStyle(
                      fontSize: 11,
                      color: hasItems
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String dayKey, List<ScheduleItem> dayItems) {
    final done =
        dayItems.where((i) => i.status == ScheduleItemStatus.completed).length;
    final isToday =
        dayKey.contains('${DateTime.now().month}/${DateTime.now().day}');

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary : AppColors.textTertiary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          dayKey,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isToday ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$done/${dayItems.length}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        if (isToday) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '今天',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
