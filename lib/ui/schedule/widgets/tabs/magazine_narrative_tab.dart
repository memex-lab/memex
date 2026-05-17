import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memex/utils/user_storage.dart';

import '../../../../domain/models/schedule_aggregation_model.dart';
import '../../models/schedule_day_label.dart';
import '../../models/schedule_item.dart';
import '../../../core/cards/ui/glass_card.dart';

/// Magazine Narrative Tab renders the AI-curated schedule aggregation.
class MagazineNarrativeTab extends StatefulWidget {
  final ScheduleAggregationModel aggregation;
  final void Function(String cardId)? onTapCardId;
  final Map<String, ScheduleItemStatus> itemStatuses;
  final void Function(String cardId)? onToggleTask;
  final DateTime? referenceDate;

  const MagazineNarrativeTab({
    super.key,
    required this.aggregation,
    this.onTapCardId,
    this.itemStatuses = const {},
    this.onToggleTask,
    this.referenceDate,
  });

  @override
  State<MagazineNarrativeTab> createState() => _MagazineNarrativeTabState();
}

class _MagazineNarrativeTabState extends State<MagazineNarrativeTab> {
  @override
  Widget build(BuildContext context) {
    return _buildAgentMode(widget.aggregation);
  }

  // ===========================================================================
  // Agent Mode - uses ScheduleAggregationModel
  // ===========================================================================

  Widget _buildAgentMode(ScheduleAggregationModel agg) {
    final bodyItems = <Widget>[
      // Hero card
      if (agg.heroItem != null) ...[
        _buildAgentHeroCard(agg.heroItem!),
        const SizedBox(height: 16),
      ],

      // Overview and reminders
      if (agg.editorialIntro.isNotEmpty || agg.quoteBlocks.isNotEmpty) ...[
        _buildAgentSummaryPanel(agg),
        const SizedBox(height: 18),
      ],

      // Conflicts
      if (agg.conflicts.isNotEmpty) ...[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: agg.conflicts.map(_buildAgentConflict).toList(),
        ),
        const SizedBox(height: 18),
      ],

      // Timeline
      if (agg.timeline.isNotEmpty)
        for (final entry in agg.timeline.indexed) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(_resolveDayLabel(entry.$2).toUpperCase()),
              const SizedBox(height: 10),
              ...entry.$2.items.map(
                (item) =>
                    _buildAgentTimelineCard(item, dayDate: entry.$2.dayDate),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],

      if (agg.completed.isNotEmpty) ...[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(UserStorage.l10n.scheduleDone.toUpperCase()),
            const SizedBox(height: 10),
            ...agg.completed.map(_buildAgentDoneCard),
          ],
        ),
      ],
    ];

    return CustomScrollView(
      key: const ValueKey('schedule_magazine_list'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 220),
          sliver: SliverList.list(children: bodyItems),
        ),
      ],
    );
  }

  Widget _buildAgentHeroCard(HeroItem item) {
    return GestureDetector(
      onTap: () => widget.onTapCardId?.call(item.cardId),
      child: Container(
        height: 188,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF172554), Color(0xFF0F766E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      UserStorage.l10n.scheduleFeatured.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.startTime != null
                              ? DateFormat.MMMEd(
                                  UserStorage.l10n.localeName,
                                ).add_Hm().format(item.startTime!)
                              : UserStorage.l10n.scheduleTbd,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      if (item.location != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentSummaryPanel(ScheduleAggregationModel agg) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (agg.editorialIntro.isNotEmpty) ...[
            Text(
              UserStorage.l10n.scheduleWeekOverview,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                color: const Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              agg.editorialIntro,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Color(0xFF4A5565),
              ),
            ),
          ],
          if (agg.editorialIntro.isNotEmpty && agg.quoteBlocks.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
          ],
          for (final entry in agg.quoteBlocks.indexed) ...[
            if (entry.$1 > 0) const SizedBox(height: 8),
            _buildAgentReminderRow(entry.$2),
          ],
        ],
      ),
    );
  }

  Widget _buildAgentReminderRow(QuoteBlock block) {
    final isHighPriority = block.priority == 'high';
    final accentColor =
        isHighPriority ? const Color(0xFFD97706) : const Color(0xFF64748B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isHighPriority
                ? Icons.priority_high_rounded
                : Icons.access_time_rounded,
            size: 14,
            color: accentColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                block.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: Color(0xFF4A5565),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentConflict(Conflict conflict) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, size: 20, color: Color(0xFFF87171)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              conflict.description,
              style: const TextStyle(fontSize: 14, color: Color(0xFFB91C1C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentTimelineCard(TimelineItem item, {DateTime? dayDate}) {
    final status =
        widget.itemStatuses[item.cardId] ?? _parseStatus(item.status);
    final isCompleted = status == ScheduleItemStatus.completed;
    final isTask = _isTaskItem(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => widget.onTapCardId?.call(item.cardId),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF99A1AF)
                        : item.priority == 3
                            ? const Color(0xFFF43F5E)
                            : const Color(0xFF5B6CFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: (isCompleted
                                ? const Color(0xFF99A1AF)
                                : item.priority == 3
                                    ? const Color(0xFFF43F5E)
                                    : const Color(0xFF5B6CFF))
                            .withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Container(width: 2, height: 60, color: const Color(0xFFE2E8F0)),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GlassCard(
                borderRadius: 14,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isTask) ...[
                          _buildTaskCompletionCircle(item.cardId, isCompleted),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? const Color(0xFF99A1AF)
                                  : const Color(0xFF0A0A0A),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (item.priority == 3 && !isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              UserStorage.l10n.scheduleImportant,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (item.startTime != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _formatTimelineItemTime(item.startTime!, dayDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF99A1AF),
                        ),
                      ),
                    ],
                    if (item.description != null && !isCompleted) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4A5565),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentDoneCard(CompletedItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => widget.onTapCardId?.call(item.cardId),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF99A1AF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Opacity(
                opacity: 0.5,
                child: GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF99A1AF),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF99A1AF),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      if (item.completedAt != null)
                        Text(
                          DateFormat.MMMd(
                            UserStorage.l10n.localeName,
                          ).format(item.completedAt!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF99A1AF),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCompletionCircle(String cardId, bool isCompleted) {
    return GestureDetector(
      key: ValueKey('schedule_task_toggle_$cardId'),
      onTap: () => widget.onToggleTask?.call(cardId),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? const Color(0xFF5B6CFF) : Colors.transparent,
          border: Border.all(
            color:
                isCompleted ? const Color(0xFF5B6CFF) : const Color(0xFFCBD5E1),
            width: 2,
          ),
        ),
        child: isCompleted
            ? const Icon(Icons.check, size: 13, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: const Color(0xFF99A1AF),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0), height: 1)),
      ],
    );
  }

  String _formatTimelineItemTime(DateTime startTime, DateTime? dayDate) {
    if (dayDate != null &&
        startTime.year == dayDate.year &&
        startTime.month == dayDate.month &&
        startTime.day == dayDate.day) {
      return DateFormat.Hm(UserStorage.l10n.localeName).format(startTime);
    }
    return DateFormat.MMMd(
      UserStorage.l10n.localeName,
    ).add_Hm().format(startTime);
  }

  String _resolveDayLabel(TimelineDay day) {
    return resolveScheduleDayLabel(
      day,
      referenceDate: widget.referenceDate ?? DateTime.now(),
      labels: ScheduleDayLabelStrings(
        yesterday: UserStorage.l10n.yesterday,
        today: UserStorage.l10n.today,
        tomorrow: UserStorage.l10n.tomorrow,
        thisWeek: UserStorage.l10n.scheduleThisWeek,
        localeName: UserStorage.l10n.localeName,
      ),
    );
  }

  bool _isTaskItem(TimelineItem item) {
    final type = item.type.toLowerCase().trim();
    return type == 'task' || type == 'todo';
  }

  ScheduleItemStatus _parseStatus(String value) {
    final normalized = value.toLowerCase().trim().replaceAll('-', '_');
    return switch (normalized) {
      'completed' || 'done' => ScheduleItemStatus.completed,
      'in_progress' ||
      'inprogress' ||
      'active' =>
        ScheduleItemStatus.inProgress,
      'overdue' => ScheduleItemStatus.overdue,
      _ => ScheduleItemStatus.pending,
    };
  }
}
