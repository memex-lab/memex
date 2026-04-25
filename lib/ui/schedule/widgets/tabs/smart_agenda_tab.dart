import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/schedule_item.dart';
import '../../../core/cards/ui/glass_card.dart';
import '../../../core/themes/app_colors.dart';
import '../cells/smart_event_cell.dart';
import '../cells/smart_todo_cell.dart';

class SmartAgendaTab extends StatelessWidget {
  final List<ScheduleItem> items;
  final void Function(int index) onToggle;
  final void Function(ScheduleItem) onTapItem;

  const SmartAgendaTab({
    super.key,
    required this.items,
    required this.onToggle,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<ScheduleItem>.from(items)
      ..sort((a, b) {
        // Sort by: completed last, then by priority desc, then by start time
        if (a.status == ScheduleItemStatus.completed &&
            b.status != ScheduleItemStatus.completed) {
          return 1;
        }
        if (b.status == ScheduleItemStatus.completed &&
            a.status != ScheduleItemStatus.completed) {
          return -1;
        }
        if (a.priority != null && b.priority != null) {
          return b.priority!.compareTo(a.priority!);
        }
        if (a.startTime != null && b.startTime != null) {
          return a.startTime!.compareTo(b.startTime!);
        }
        return 0;
      });

    final now = DateTime.now();
    final currentHour = now.hour;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        _buildSmartSummaryCard(sorted, currentHour),
        const SizedBox(height: 20),
        _buildSectionHeader('智能排序', Icons.auto_awesome),
        const SizedBox(height: 4),
        Text(
          '基于优先级和时间自动排序',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 16),
        ...sorted.asMap().entries.map((entry) {
          final index = items.indexOf(entry.value);
          final isCurrent = entry.value.startTime != null &&
              entry.value.endTime != null &&
              currentHour >= entry.value.startTime!.hour &&
              currentHour < entry.value.endTime!.hour;

          if (entry.value.type == ScheduleItemType.event) {
            return SmartEventCell(
              item: entry.value,
              onTap: () => onTapItem(entry.value),
              isCurrent: isCurrent,
            );
          } else {
            return SmartTodoCell(
              item: entry.value,
              onToggle: () => onToggle(index),
              onTap: () => onTapItem(entry.value),
              isCurrent: isCurrent,
            );
          }
        }),
      ],
    );
  }

  Widget _buildSmartSummaryCard(List<ScheduleItem> allItems, int currentHour) {
    final highPriority = allItems
        .where(
            (i) => i.priority == 3 && i.status != ScheduleItemStatus.completed)
        .length;
    final inProgress =
        allItems.where((i) => i.status == ScheduleItemStatus.inProgress).length;
    final upcoming = allItems.where((i) {
      if (i.startTime == null) return false;
      return i.startTime!.hour > currentHour &&
          i.status != ScheduleItemStatus.completed;
    }).length;

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
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
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
                      '智能议程',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'AI 建议优先处理高优先级任务',
                      style: TextStyle(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmartStat(
                '高优先级',
                highPriority.toString(),
                AppColors.danger,
              ),
              _buildSmartStat('进行中', inProgress.toString(), AppColors.primary),
              _buildSmartStat('即将开始', upcoming.toString(), AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
