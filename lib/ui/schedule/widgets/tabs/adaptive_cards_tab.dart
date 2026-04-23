import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/schedule_item.dart';
import '../../../core/cards/ui/glass_card.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_shadows.dart';
import '../shared/tag_chip.dart';

class AdaptiveCardsTab extends StatefulWidget {
  final List<ScheduleItem> items;
  final void Function(int index) onToggle;
  final void Function(ScheduleItem) onTapItem;

  const AdaptiveCardsTab({
    required this.items,
    required this.onToggle,
    required this.onTapItem,
  });

  @override
  State<AdaptiveCardsTab> createState() => AdaptiveCardsTabState();
}

class AdaptiveCardsTabState extends State<AdaptiveCardsTab> {
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
        completedAt: newStatus == ScheduleItemStatus.completed ? DateTime.now() : null,
      );
    });
    widget.onToggle(index);
  }

  /// AI decides which card style to use based on content characteristics
  Widget _buildAdaptiveCard(int index) {
    final item = _items[index];

    // Decision 1: Completed items → compact faded card
    if (item.status == ScheduleItemStatus.completed) {
      return _buildDoneCard(item);
    }

    // Decision 2: High priority + long description → Hero card
    if (item.priority == 3 &&
        item.description != null &&
        item.description!.length > 20) {
      return _buildHeroCard(item);
    }

    // Decision 3: High priority + short → Quote emphasis card
    if (item.priority == 3) {
      return _buildEmphasisCard(item);
    }

    // Decision 4: Has markdown-like description → Snippet card
    if (item.description != null &&
        item.description!.length > 30 &&
        (item.description!.contains('#') ||
            item.description!.contains('-') ||
            item.description!.contains('1.'))) {
      return _buildSnippetCard(item);
    }

    // Decision 5: Event with time → Event card
    if (item.type == ScheduleItemType.event && item.startTime != null) {
      return _buildEventStyleCard(item);
    }

    // Decision 6: Todo → Interactive task card
    if (item.type == ScheduleItemType.todo) {
      return _buildInteractiveTaskCard(item, index);
    }

    // Fallback: Compact
    return _buildCompactCard(item);
  }

  Widget _buildHeroCard(ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => widget.onTapItem(item),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [AppShadows.card],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top gradient bar
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B6CFF), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags row
                    Row(
                      children: [
                        ...item.tags.take(3).map((t) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: TagChip(label: t),
                            )),
                        const Spacer(),
                        if (item.priority == 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '重要',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        letterSpacing: -0.3,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Description
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Color(0xFF4A5565),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Time & location
                    if (item.startTime != null)
                      _buildMetaRow(
                        Icons.access_time,
                        '${DateFormat('HH:mm').format(item.startTime!)}${item.endTime != null ? ' - ${DateFormat('HH:mm').format(item.endTime!)}' : ''}',
                      ),
                    if (item.location != null) ...[
                      const SizedBox(height: 6),
                      _buildMetaRow(
                        Icons.location_on_outlined,
                        item.location!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmphasisCard(ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => widget.onTapItem(item),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFED7AA), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“',
                style: GoogleFonts.imbue(
                  fontSize: 60,
                  fontWeight: FontWeight.w700,
                  height: 0.3,
                  color: const Color(0xFFFDBA74),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: const Color(0xFF9A3412),
                ),
              ),
              if (item.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  item.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFC2410C),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '”',
                  style: GoogleFonts.imbue(
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                    height: 0.3,
                    color: const Color(0xFFFDBA74),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSnippetCard(ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => widget.onTapItem(item),
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0A0A),
                ),
              ),
              const SizedBox(height: 12),
              MarkdownBody(
                data: item.description ?? '',
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF4A5565),
                  ),
                  h1: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A0A0A)),
                  h2: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A0A0A)),
                  blockquote: const TextStyle(
                    color: Color(0xFF4A5565),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: item.tags.map((t) => TagChip(label: t)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventStyleCard(ScheduleItem item) {
    final timeFormat = DateFormat('HH:mm');
    final monthFormat = DateFormat('MMM');
    final dayFormat = DateFormat('dd');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => widget.onTapItem(item),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date block
              Container(
                width: 50,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6CFF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.startTime != null
                          ? monthFormat.format(item.startTime!).toUpperCase()
                          : '---',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5B6CFF),
                      ),
                    ),
                    Text(
                      item.startTime != null ? dayFormat.format(item.startTime!) : '--',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5B6CFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.startTime != null)
                      Text(
                        '${timeFormat.format(item.startTime!)}${item.endTime != null ? ' - ${timeFormat.format(item.endTime!)}' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF99A1AF),
                        ),
                      ),
                    if (item.location != null)
                      Text(
                        item.location!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF99A1AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveTaskCard(ScheduleItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => widget.onTapItem(item),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _toggle(index),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF5B6CFF),
                      width: 2,
                    ),
                    color: item.status == ScheduleItemStatus.completed
                        ? const Color(0xFF5B6CFF)
                        : Colors.transparent,
                  ),
                  child: item.status == ScheduleItemStatus.completed
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A0A),
                        decoration: item.status == ScheduleItemStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: const Color(0xFF99A1AF),
                      ),
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
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
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children:
                            item.tags.map((t) => TagChip(label: t)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.priority == 2)
                const Icon(Icons.flag, size: 16, color: Color(0xFFF59E0B)),
              if (item.priority == 3)
                const Icon(Icons.priority_high, size: 16, color: Color(0xFFF43F5E)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneCard(ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => widget.onTapItem(item),
        child: Opacity(
          opacity: 0.5,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Color(0xFF99A1AF),
                ),
                const SizedBox(width: 12),
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
                    DateFormat('HH:mm').format(item.completedAt!),
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
    );
  }

  Widget _buildCompactCard(ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => widget.onTapItem(item),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.type == ScheduleItemType.event
                      ? const Color(0xFF5B6CFF)
                      : const Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              if (item.startTime != null)
                Text(
                  DateFormat('HH:mm').format(item.startTime!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF99A1AF),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF99A1AF)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF99A1AF),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // AI insight header
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B6CFF), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '为你选择了 7 种展示样式',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '根据内容特征自动适配：重要事项突出展示，长文本用 Markdown 渲染，已完成事项自动淡化',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildAdaptiveCard(index - 1);
      },
    );
  }
}
