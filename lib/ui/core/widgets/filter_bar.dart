import 'package:flutter/material.dart';
import 'package:memex/domain/models/tag_model.dart';
import 'adaptive_icon.dart';

/// Filter bar for timeline view
class FilterBar extends StatefulWidget {
  final List<TagModel> tags;
  final String activeFilter;
  final ValueChanged<String> onFilterSelected;
  final bool showInsight;

  const FilterBar({
    super.key,
    required this.tags,
    required this.activeFilter,
    required this.onFilterSelected,
    this.showInsight = true,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveFilter();
    });
  }

  @override
  void didUpdateWidget(FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeFilter != widget.activeFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveFilter();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveFilter() {
    final key = _keys[widget.activeFilter];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.5, // 0.5 means center
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      _FilterItem(id: 'all', label: 'All', icon: null),
      if (widget.showInsight)
        _FilterItem(
          id: 'insight',
          label: 'Insight',
          icon: '✨',
          iconType: TagIconType.emoji,
        ),
      ...widget.tags.map((tag) => _FilterItem(
            id: tag.name,
            label: tag.name,
            icon: tag.icon,
            iconType: tag.iconType,
          )),
    ];

    // Ensure keys exist for all filters
    for (var filter in filters) {
      if (!_keys.containsKey(filter.id)) {
        _keys[filter.id] = GlobalKey();
      }
    }

    return Container(
      height: 56,
      width: double.infinity,
      color: const Color(0xFFFAFAFA).withValues(alpha: 0.95),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: filters.map((filter) {
            final index = filters.indexOf(filter);
            final isActive = filter.id == widget.activeFilter;
            final isInsight = filter.id == 'insight';

            // Premium Insight Colors
            const premiumColor = Color(0xFFF59E0B); // Amber-500

            return Padding(
              padding:
                  EdgeInsets.only(right: index == filters.length - 1 ? 0 : 8.0),
              child: GestureDetector(
                key: _keys[filter.id],
                onTap: () => widget.onFilterSelected(filter.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isInsight
                            ? premiumColor.withValues(alpha: 0.1)
                            : Colors.black)
                        : Colors.white,
                    border: Border.all(
                      color: isInsight
                          ? premiumColor.withValues(alpha: 0.5)
                          : (isActive ? Colors.black : const Color(0xFFE2E8F0)),
                      width: isInsight ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: (isActive || isInsight)
                        ? [
                            BoxShadow(
                              color: isInsight
                                  ? premiumColor.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (filter.icon != null) ...[
                        AdaptiveIcon(
                          icon: filter.icon,
                          iconType: filter.iconType,
                          size: 14,
                          color:
                              isActive ? Colors.white : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        filter.label,
                        style: TextStyle(
                          color: isInsight
                              ? (isActive
                                  ? premiumColor
                                  : premiumColor.withValues(alpha: 0.8))
                              : (isActive
                                  ? Colors.white
                                  : const Color(0xFF64748B)),
                          fontSize: 13,
                          fontWeight: (isActive || isInsight)
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterItem {
  final String id;
  final String label;
  final String?
      icon; // Icon identifier (Material Icon name, SVG path, or emoji)
  final TagIconType? iconType; // Type of icon

  _FilterItem({
    required this.id,
    required this.label,
    this.icon,
    this.iconType,
  });
}
