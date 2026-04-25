import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/schedule_item.dart';
import '../../../core/cards/ui/glass_card.dart';
import '../../../core/themes/app_colors.dart';
import '../shared/tag_chip.dart';

class TodoCell extends StatelessWidget {
  final ScheduleItem item;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final bool compact;

  const TodoCell({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.status == ScheduleItemStatus.completed;
    final priorityColor = item.priority == 3
        ? AppColors.danger
        : item.priority == 2
            ? AppColors.warning
            : AppColors.textTertiary;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: GlassCard(
        onTap: onTap,
        padding: EdgeInsets.all(compact ? 14 : 16),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: compact ? 22 : 24,
                height: compact ? 22 : 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? AppColors.success : AppColors.primary,
                    width: 2,
                  ),
                  color: isCompleted ? AppColors.success : Colors.transparent,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.inter(
                            fontSize: compact ? 15 : 16,
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
                      ),
                      if (item.priority != null && item.priority! > 0)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (item.startTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(item.startTime!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
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
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
