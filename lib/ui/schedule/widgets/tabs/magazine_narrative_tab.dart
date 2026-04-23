import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/schedule_item.dart';
import '../../../../domain/models/schedule_aggregation_model.dart';
import '../../../core/cards/ui/glass_card.dart';

/// Magazine Narrative Tab - renders in two modes:
/// 1. Agent mode: when [aggregation] is provided, uses AI-curated layout
/// 2. Mock mode: falls back to [items] with frontend-driven layout
class MagazineNarrativeTab extends StatefulWidget {
  final List<ScheduleItem> items;
  final ScheduleAggregationModel? aggregation;
  final void Function(int index) onToggle;
  final void Function(ScheduleItem) onTapItem;
  final void Function(String cardId)? onTapCardId;

  const MagazineNarrativeTab({
    required this.items,
    this.aggregation,
    required this.onToggle,
    required this.onTapItem,
    this.onTapCardId,
  });

  @override
  State<MagazineNarrativeTab> createState() => _MagazineNarrativeTabState();
}

class _MagazineNarrativeTabState extends State<MagazineNarrativeTab> {
  late List<ScheduleItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  void _toggle(int index) {
    final item = _items[index];
    if (item.type != ScheduleItemType.todo) return;
    final newStatus = item.status == ScheduleItemStatus.completed
        ? ScheduleItemStatus.pending
        : ScheduleItemStatus.completed;
    setState(() {
      _items[index] = item.copyWith(
        status: newStatus,
        completedAt:
            newStatus == ScheduleItemStatus.completed ? DateTime.now() : null,
      );
    });
    widget.onToggle(index);
  }

  @override
  Widget build(BuildContext context) {
    // Agent mode: AI-curated layout
    if (widget.aggregation != null) {
      return _buildAgentMode(widget.aggregation!);
    }

    // Mock mode: frontend-driven layout
    return _buildMockMode();
  }

  // ===========================================================================
  // Agent Mode - uses ScheduleAggregationModel
  // ===========================================================================

  Widget _buildAgentMode(ScheduleAggregationModel agg) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        // Magazine header
        _buildMagazineHeader(),

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
          ...agg.conflicts.map(_buildAgentConflict),
          const SizedBox(height: 28),
        ],

        // Timeline
        if (agg.timeline.isNotEmpty) ...[
          for (final day in agg.timeline) ...[
            _buildSectionTitle(day.dayLabel.toUpperCase()),
            const SizedBox(height: 16),
            ...day.items.map(_buildAgentTimelineCard),
            const SizedBox(height: 28),
          ],
        ],

        // Completed
        if (agg.completed.isNotEmpty) ...[
          _buildSectionTitle('DONE'),
          const SizedBox(height: 16),
          ...agg.completed.map(_buildAgentDoneCard),
        ],
      ],
    );
  }

  Widget _buildAgentHeroCard(HeroItem item) {
    return GestureDetector(
      onTap: () => widget.onTapCardId?.call(item.cardId),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'FEATURED',
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
                      Text(
                        item.startTime != null
                            ? DateFormat('EEE, MMM d · HH:mm')
                                .format(item.startTime!)
                            : 'TBD',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
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
                        Text(
                          item.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
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
          '本周概览',
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
    final isCompleted = item.status == 'completed';

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
                            child: const Text(
                              '重要',
                              style: TextStyle(
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
                        DateFormat('EEE, MMM d · HH:mm')
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
                          DateFormat('MMM d').format(item.completedAt!),
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

  // ===========================================================================
  // Mock Mode - frontend-driven layout (original logic)
  // ===========================================================================

  Widget _buildMockMode() {
    final heroItem = _findMockHeroItem();
    final otherItems = _items.where((i) => i != heroItem).toList();

    final today = DateTime.now();
    final todayItems = <ScheduleItem>[];
    final futureItems = <ScheduleItem>[];
    final pastItems = <ScheduleItem>[];

    for (final item in otherItems) {
      if (item.status == ScheduleItemStatus.completed) {
        pastItems.add(item);
      } else if (item.startTime != null &&
          item.startTime!.day == today.day &&
          item.startTime!.month == today.month) {
        todayItems.add(item);
      } else {
        futureItems.add(item);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        _buildMagazineHeader(),
        if (heroItem != null) ...[
          _buildMockHeroCard(heroItem),
          const SizedBox(height: 28),
        ],
        _buildMockEditorialIntro(),
        const SizedBox(height: 28),
        if (futureItems.any((i) => i.priority == 3)) ...[
          _buildMockQuoteBlock(
              futureItems.firstWhere((i) => i.priority == 3)),
          const SizedBox(height: 28),
        ],
        if (todayItems.isNotEmpty) ...[
          _buildSectionTitle('TODAY'),
          const SizedBox(height: 16),
          ...todayItems.map((item) => _buildMockTimelineCard(item)),
          const SizedBox(height: 28),
        ],
        if (futureItems.isNotEmpty) ...[
          _buildSectionTitle('UPCOMING'),
          const SizedBox(height: 16),
          ...futureItems.map((item) => _buildMockTimelineCard(item)),
          const SizedBox(height: 28),
        ],
        if (pastItems.isNotEmpty) ...[
          _buildSectionTitle('DONE'),
          const SizedBox(height: 16),
          ...pastItems.map((item) => _buildMockDoneCard(item)),
        ],
      ],
    );
  }

  ScheduleItem? _findMockHeroItem() {
    final upcomingEvents = _items
        .where((i) =>
            i.type == ScheduleItemType.event &&
            i.status != ScheduleItemStatus.completed &&
            i.priority == 3)
        .toList();
    if (upcomingEvents.isNotEmpty) return upcomingEvents.first;

    final upcoming = _items
        .where((i) =>
            i.status != ScheduleItemStatus.completed && i.priority == 3)
        .toList();
    if (upcoming.isNotEmpty) return upcoming.first;

    return _items.firstWhere(
      (i) => i.status != ScheduleItemStatus.completed,
      orElse: () => _items.first,
    );
  }

  Widget _buildMagazineHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: const Color(0xFF99A1AF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM d').format(DateTime.now()),
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

  Widget _buildMockHeroCard(ScheduleItem item) {
    return GestureDetector(
      onTap: () => widget.onTapItem(item),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'FEATURED',
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
                      Text(
                        item.startTime != null
                            ? DateFormat('EEE, MMM d · HH:mm')
                                .format(item.startTime!)
                            : 'TBD',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
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
                        Text(
                          item.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
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

  Widget _buildMockEditorialIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本周概览',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '这是一个忙碌的星期。你已经完成了 ${_items.where((i) => i.status == ScheduleItemStatus.completed).length} 个事项，'
          '还有 ${_items.where((i) => i.status != ScheduleItemStatus.completed).length} 个待处理。'
          '最重要的是 ${_findMockHeroItem()?.title}，记得提前准备。',
          style: const TextStyle(
            fontSize: 15,
            height: 1.7,
            color: Color(0xFF4A5565),
          ),
        ),
      ],
    );
  }

  Widget _buildMockQuoteBlock(ScheduleItem item) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: const Color(0xFFF59E0B),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_filled,
                size: 16,
                color: Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              Text(
                '截止提醒',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF92400E),
            ),
          ),
          if (item.description != null) ...[
            const SizedBox(height: 6),
            Text(
              item.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB45309),
              ),
            ),
          ],
        ],
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

  Widget _buildMockTimelineCard(ScheduleItem item) {
    final isTodo = item.type == ScheduleItemType.todo;
    final isCompleted = item.status == ScheduleItemStatus.completed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => widget.onTapItem(item),
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
                        if (isTodo)
                          GestureDetector(
                            onTap: () => _toggle(_items.indexOf(item)),
                            child: Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF5B6CFF),
                                  width: 1.5,
                                ),
                                color: isCompleted
                                    ? const Color(0xFF5B6CFF)
                                    : Colors.transparent,
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check,
                                      size: 11, color: Colors.white)
                                  : null,
                            ),
                          ),
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
                            child: const Text(
                              '重要',
                              style: TextStyle(
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
                        DateFormat('EEE, MMM d · HH:mm')
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

  Widget _buildMockDoneCard(ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => widget.onTapItem(item),
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
                          DateFormat('MMM d').format(item.completedAt!),
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
}
