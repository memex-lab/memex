import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/style/timeline_theme.dart';

/// Standard Header for Timeline Cards
/// [Icon] [Title]           [Action/Date]
class TimelineHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool compact;

  const TimelineHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TimelineTheme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  size: 20, color: TimelineTheme.colors.primary), // Indigo-600
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TimelineTheme.typography.title.copyWith(
                    color: TimelineTheme.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TimelineTheme.typography.small.copyWith(
                      color: TimelineTheme.colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Standard Footer for Timeline Cards
/// [Tags...]               [Timestamp]
class TimelineFooter extends StatelessWidget {
  final List<String> tags;
  final String? timestamp;

  const TimelineFooter({
    super.key,
    this.tags = const [],
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty && timestamp == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: tags.map((t) => TimelineTag(label: t)).toList(),
            ),
          ),
          if (timestamp != null)
            Text(
              timestamp!,
              style: TimelineTheme.typography.label.copyWith(
                color: TimelineTheme.colors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class TimelineTag extends StatelessWidget {
  final String label;

  const TimelineTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      '#$label',
      style: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TimelineTheme.colors.primary,
        height: 1.43,
      ),
    );
  }
}

class TimelineDivider extends StatelessWidget {
  final bool dashed;

  const TimelineDivider({super.key, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    if (dashed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.constrainWidth();
            const dashWidth = 5.0;
            final dashCount = (boxWidth / (2 * dashWidth)).floor();
            return Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashWidth,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: TimelineTheme.colors.textTertiary
                            .withValues(alpha: 0.3)),
                  ),
                );
              }),
            );
          },
        ),
      );
    }
    return Divider(
      height: 32,
      thickness: 1,
      color: TimelineTheme.colors.textTertiary.withValues(alpha: 0.1),
    );
  }
}
