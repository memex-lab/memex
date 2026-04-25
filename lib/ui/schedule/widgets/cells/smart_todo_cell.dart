import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/schedule_item.dart';
import '../../../core/cards/ui/glass_card.dart';
import '../../../core/themes/app_colors.dart';
import '../shared/tag_chip.dart';

class SmartTodoCell extends StatelessWidget {
  final ScheduleItem item;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final bool isCurrent;

  const SmartTodoCell({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onTap,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.status == ScheduleItemStatus.completed;
    final priorityColors = [
      AppColors.textTertiary,
      AppColors.warning,
      AppColors.danger,
    ];
    final priorityLabels = ['低', '中', '高'];
    final priorityIndex = item.priority == null
        ? -1
        : item.priority!.clamp(1, priorityColors.length).toInt() - 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        backgroundColor: isCurrent ? const Color(0xFFFFF7ED) : null,
        child: Row(
          children: [
            // Priority badge + checkbox
            Column(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isCompleted ? AppColors.success : AppColors.primary,
                        width: 2,
                      ),
                      color:
                          isCompleted ? AppColors.success : Colors.transparent,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                if (priorityIndex >= 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          priorityColors[priorityIndex].withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priorityLabels[priorityIndex],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: priorityColors[priorityIndex],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children:
                          item.tags.map((tag) => TagChip(label: tag)).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
