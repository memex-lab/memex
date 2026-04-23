import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/schedule_item.dart';
import '../../../core/cards/ui/glass_card.dart';
import '../../../core/themes/app_colors.dart';
import '../shared/tag_chip.dart';

class EventCell extends StatelessWidget {
  final ScheduleItem item;
  final VoidCallback onTap;
  final bool compact;

  const EventCell({
    required this.item,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startTime = item.startTime;
    final endTime = item.endTime;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 12),
      child: GlassCard(
        onTap: onTap,
        padding: EdgeInsets.all(compact ? 14 : 16),
        child: Row(
          children: [
            // Time block
            Container(
              width: compact ? 44 : 52,
              height: compact ? 48 : 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item.status == ScheduleItemStatus.completed
                      ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                      : [const Color(0xFF5B6CFF), const Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (startTime != null) ...[
                    Text(
                      timeFormat.format(startTime),
                      style: GoogleFonts.inter(
                        fontSize: compact ? 11 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (endTime != null)
                      Text(
                        timeFormat.format(endTime),
                        style: GoogleFonts.inter(
                          fontSize: compact ? 9 : 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                  ] else
                    const Icon(Icons.schedule, size: 18, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Details
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
                            color: item.status == ScheduleItemStatus.completed
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                            decoration: item.status == ScheduleItemStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.status == ScheduleItemStatus.completed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '已完成',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: item.tags.map((tag) => TagChip(label: tag)).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
