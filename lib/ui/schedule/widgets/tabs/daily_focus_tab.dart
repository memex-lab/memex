import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/schedule_item.dart';
import '../../../core/cards/ui/glass_card.dart';
import '../../../core/themes/app_colors.dart';
import '../cells/event_cell.dart';
import '../cells/todo_cell.dart';

class DailyFocusTab extends StatelessWidget {
  final List<ScheduleItem> items;
  final void Function(int index) onToggle;
  final void Function(ScheduleItem) onTapItem;

  const DailyFocusTab({
    required this.items,
    required this.onToggle,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final pending = items.where((i) =>
        i.status != ScheduleItemStatus.completed && i.type == ScheduleItemType.todo).toList();
    final completed = items.where((i) =>
        i.status == ScheduleItemStatus.completed && i.type == ScheduleItemType.todo).toList();
    final events = items.where((i) => i.type == ScheduleItemType.event).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        // Summary card
        _buildSummaryCard(items),
        const SizedBox(height: 20),
        // Events section
        _buildSectionHeader('今日日程', Icons.calendar_today_outlined),
        const SizedBox(height: 12),
        ...events.map((e) => EventCell(
          item: e,
          onTap: () => onTapItem(e),
        )),
        const SizedBox(height: 24),
        // Pending todos
        _buildSectionHeader('待办事项', Icons.check_circle_outline),
        const SizedBox(height: 12),
        if (pending.isEmpty)
          _buildEmptyState('暂无待办，太棒了！')
        else
          ...pending.asMap().entries.map((entry) {
            final index = items.indexOf(entry.value);
            return TodoCell(
              item: entry.value,
              onToggle: () => onToggle(index),
              onTap: () => onTapItem(entry.value),
            );
          }),
        const SizedBox(height: 24),
        // Completed todos
        if (completed.isNotEmpty) ...[
          _buildSectionHeader('已完成', Icons.done_all, color: AppColors.success),
          const SizedBox(height: 12),
          ...completed.asMap().entries.map((entry) {
            final index = items.indexOf(entry.value);
            return TodoCell(
              item: entry.value,
              onToggle: () => onToggle(index),
              onTap: () => onTapItem(entry.value),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(List<ScheduleItem> allItems) {
    final total = allItems.length;
    final done = allItems.where((i) => i.status == ScheduleItemStatus.completed).length;
    final pending = allItems.where((i) =>
        i.status != ScheduleItemStatus.completed).length;
    final progress = total == 0 ? 0.0 : done / total;

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
                    colors: [Color(0xFF5B6CFF), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.today, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日概览',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$done / $total 已完成',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEEF2FF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B6CFF)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('待办', pending.toString(), AppColors.warning),
              _buildStatItem('日程', allItems.where((i) => i.type == ScheduleItemType.event).length.toString(), AppColors.primary),
              _buildStatItem('已完成', done.toString(), AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
