import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memex/utils/user_storage.dart';

import '../../../../domain/models/schedule_aggregation_model.dart';
import '../../models/schedule_item.dart';
import '../../../core/cards/ui/glass_card.dart';
import '../../../core/themes/app_colors.dart';

/// Magazine Narrative Tab renders the AI-curated schedule aggregation.
class MagazineNarrativeTab extends StatefulWidget {
  final ScheduleAggregationModel aggregation;
  final void Function(String cardId)? onTapCardId;
  final Map<String, ScheduleItemStatus> itemStatuses;
  final void Function(String cardId)? onToggleTask;

  const MagazineNarrativeTab({
    super.key,
    required this.aggregation,
    this.onTapCardId,
    this.itemStatuses = const {},
    this.onToggleTask,
  });

  @override
  State<MagazineNarrativeTab> createState() => _MagazineNarrativeTabState();
}

class _MagazineNarrativeTabState extends State<MagazineNarrativeTab> {
  final _scrollController = ScrollController();
  final _conflictsKey = GlobalKey();
  final _completedKey = GlobalKey();
  final Map<int, GlobalKey> _dayKeys = {};

  GlobalKey _dayKey(int index) {
    return _dayKeys.putIfAbsent(index, GlobalKey.new);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToKey(
    GlobalKey key, {
    double fallbackFraction = 0,
  }) async {
    final context = key.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
      return;
    }
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final targetOffset = position.maxScrollExtent * fallbackFraction;
    await _scrollController.animateTo(
      targetOffset.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) return;
    final resolvedContext = key.currentContext;
    if (resolvedContext == null) return;
    if (!resolvedContext.mounted) return;
    await Scrollable.ensureVisible(
      resolvedContext,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

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
        const SizedBox(height: 28),
      ],

      // Editorial intro
      if (agg.editorialIntro.isNotEmpty) ...[
        _buildAgentEditorialIntro(agg.editorialIntro),
        const SizedBox(height: 28),
      ],

      // Quote blocks
      if (agg.quoteBlocks.isNotEmpty) ...[
        ...agg.quoteBlocks.map(_buildAgentQuoteBlock),
        const SizedBox(height: 28),
      ],

      // Conflicts
      if (agg.conflicts.isNotEmpty) ...[
        KeyedSubtree(
          key: _conflictsKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: agg.conflicts.map(_buildAgentConflict).toList(),
          ),
        ),
        const SizedBox(height: 28),
      ],

      // Timeline
      if (agg.timeline.isNotEmpty)
        for (final entry in agg.timeline.indexed) ...[
          KeyedSubtree(
            key: _dayKey(entry.$1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(entry.$2.dayLabel.toUpperCase()),
                const SizedBox(height: 16),
                ...entry.$2.items.map(_buildAgentTimelineCard),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],

      if (agg.completed.isNotEmpty) ...[
        KeyedSubtree(
          key: _completedKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                UserStorage.l10n.scheduleDone.toUpperCase(),
              ),
              const SizedBox(height: 16),
              ...agg.completed.map(_buildAgentDoneCard),
            ],
          ),
        ),
      ],
    ];

    return CustomScrollView(
      key: const ValueKey('schedule_magazine_list'),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverList.list(
            children: [
              _buildMagazineHeader(),
            ],
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _ScheduleLensHeaderDelegate(
            child: _buildOverviewLens(agg),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 220),
          sliver: SliverList.list(children: bodyItems),
        ),
      ],
    );
  }

  Widget _buildOverviewLens(ScheduleAggregationModel agg) {
    final chips = <Widget>[
      _buildLensChip(
        key: const ValueKey('schedule_lens_updated'),
        icon: Icons.auto_awesome,
        label: UserStorage.l10n.scheduleBriefingUpdated(
          DateFormat.Md(UserStorage.l10n.localeName).add_Hm().format(
                agg.generatedAt,
              ),
        ),
      ),
      for (final entry in agg.timeline.indexed)
        _buildLensChip(
          key: ValueKey('schedule_lens_day_${entry.$1}'),
          icon: Icons.view_agenda_outlined,
          label: '${_dayChipLabel(entry.$2)} · ${entry.$2.items.length}',
          onTap: () => _scrollToKey(
            _dayKey(entry.$1),
            fallbackFraction: (0.64 + entry.$1 * 0.08).clamp(0.64, 0.92),
          ),
        ),
      if (agg.conflicts.isNotEmpty)
        _buildLensChip(
          key: const ValueKey('schedule_lens_conflicts'),
          icon: Icons.warning_amber_rounded,
          label: UserStorage.l10n.scheduleBriefingConflictCount(
            agg.conflicts.length,
          ),
          onTap: () => _scrollToKey(_conflictsKey, fallbackFraction: 0.5),
          accentColor: const Color(0xFFB45309),
          backgroundColor: const Color(0xFFFFF7ED),
        ),
      if (agg.completed.isNotEmpty)
        _buildLensChip(
          key: const ValueKey('schedule_lens_done'),
          icon: Icons.check_circle_outline,
          label: UserStorage.l10n.scheduleBriefingDoneCount(
            agg.completed.length,
          ),
          onTap: () => _scrollToKey(_completedKey, fallbackFraction: 1),
          accentColor: const Color(0xFF047857),
          backgroundColor: const Color(0xFFECFDF5),
        ),
    ];

    return SingleChildScrollView(
      key: const ValueKey('schedule_overview_lens'),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final entry in chips.indexed) ...[
            if (entry.$1 > 0) const SizedBox(width: 8),
            entry.$2,
          ],
        ],
      ),
    );
  }

  Widget _buildLensChip({
    required Key key,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color accentColor = const Color(0xFF334155),
    Color backgroundColor = const Color(0xFFF8FAFC),
  }) {
    return Material(
      key: key,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: accentColor),
              const SizedBox(width: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayChipLabel(TimelineDay day) {
    if (day.dayLabel.trim().isNotEmpty) {
      return day.dayLabel.trim();
    }
    if (day.dayDate != null) {
      return DateFormat.E(UserStorage.l10n.localeName).format(day.dayDate!);
    }
    return UserStorage.l10n.scheduleThisWeek;
  }

  Widget _buildAgentHeroCard(HeroItem item) {
    return GestureDetector(
      onTap: () => widget.onTapCardId?.call(item.cardId),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  const SizedBox(height: 16),
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 16),
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
                              ? DateFormat.MMMEd(UserStorage.l10n.localeName)
                                  .add_Hm()
                                  .format(item.startTime!)
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

  Widget _buildAgentEditorialIntro(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UserStorage.l10n.scheduleWeekOverview,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.7,
            color: Color(0xFF4A5565),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentQuoteBlock(QuoteBlock block) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: block.priority == 'high'
                ? const Color(0xFFF59E0B)
                : const Color(0xFF99A1AF),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                size: 16,
                color: block.priority == 'high'
                    ? const Color(0xFFD97706)
                    : const Color(0xFF99A1AF),
              ),
              const SizedBox(width: 8),
              Text(
                block.title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: block.priority == 'high'
                      ? const Color(0xFFD97706)
                      : const Color(0xFF99A1AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            block.content,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF92400E),
            ),
          ),
        ],
      ),
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
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentTimelineCard(TimelineItem item) {
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
                Container(
                  width: 2,
                  height: 60,
                  color: const Color(0xFFE2E8F0),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
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
                                horizontal: 6, vertical: 2),
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
                        DateFormat.MMMEd(UserStorage.l10n.localeName)
                            .add_Hm()
                            .format(item.startTime!),
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
                          DateFormat.MMMd(UserStorage.l10n.localeName)
                              .format(item.completedAt!),
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

  Widget _buildMagazineHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            UserStorage.l10n.scheduleThisWeek.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: const Color(0xFF99A1AF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat.MMMMd(UserStorage.l10n.localeName)
                .format(DateTime.now()),
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: const Color(0xFF0A0A0A),
            ),
          ),
        ],
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
            ? const Icon(
                Icons.check,
                size: 13,
                color: Colors.white,
              )
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
        const Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ],
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

class _ScheduleLensHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ScheduleLensHeaderDelegate({required this.child});

  static const double _height = 60;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ScheduleLensHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
