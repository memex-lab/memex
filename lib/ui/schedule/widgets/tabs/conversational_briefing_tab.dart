import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/schedule_item.dart';

class ConversationalBriefingTab extends StatelessWidget {
  final List<ScheduleItem> items;
  final void Function(ScheduleItem) onTapItem;

  const ConversationalBriefingTab({
    super.key,
    required this.items,
    required this.onTapItem,
  });

  List<ScheduleItem> _groupByTime() {
    return List<ScheduleItem>.from(items)
      ..sort((a, b) {
        if (a.startTime == null && b.startTime == null) {
          return 0;
        }
        if (a.startTime == null) {
          return 1;
        }
        if (b.startTime == null) {
          return -1;
        }
        return a.startTime!.compareTo(b.startTime!);
      });
  }

  String _buildGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '早上好';
    }
    if (hour < 18) {
      return '下午好';
    }
    return '晚上好';
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B6CFF), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
    );
  }

  Widget _buildAiMessage({
    required String text,
    Widget? child,
    bool showAvatar = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) _buildAiAvatar() else const SizedBox(width: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child ??
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF334155),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleBubble(ScheduleItem item) {
    final isCompleted = item.status == ScheduleItemStatus.completed;
    final isInProgress = item.status == ScheduleItemStatus.inProgress;

    Color accentColor;
    if (isCompleted) {
      accentColor = const Color(0xFF99A1AF);
    } else if (isInProgress) {
      accentColor = const Color(0xFF5B6CFF);
    } else if (item.priority == 3) {
      accentColor = const Color(0xFFF43F5E);
    } else {
      accentColor = const Color(0xFF10B981);
    }

    return GestureDetector(
      onTap: () => onTapItem(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFFE2E8F0)
                : accentColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? const Color(0xFF99A1AF)
                          : const Color(0xFF0A0A0A),
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (item.startTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(item.startTime!),
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF99A1AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isInProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6CFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '进行中',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B6CFF),
                  ),
                ),
              ),
            if (item.priority == 3 && !isCompleted && !isInProgress)
              const Icon(
                Icons.priority_high,
                size: 16,
                color: Color(0xFFF43F5E),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _groupByTime();
    final completed =
        sorted.where((i) => i.status == ScheduleItemStatus.completed).toList();
    final inProgress =
        sorted.where((i) => i.status == ScheduleItemStatus.inProgress).toList();
    final upcoming = sorted
        .where((i) =>
            i.status != ScheduleItemStatus.completed &&
            i.status != ScheduleItemStatus.inProgress)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        // AI Greeting
        _buildAiMessage(
          text: '${_buildGreeting()}！今天有 ${items.length} 个事项，'
              '已完成 ${completed.length} 个，还有 ${upcoming.length + inProgress.length} 个待处理。',
        ),

        // In progress section
        if (inProgress.isNotEmpty) ...[
          _buildAiMessage(
            showAvatar: false,
            text: '',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '正在进行的',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B6CFF),
                  ),
                ),
                const SizedBox(height: 10),
                ...inProgress.map(_buildScheduleBubble),
              ],
            ),
          ),
        ],

        // Upcoming section
        if (upcoming.isNotEmpty) ...[
          _buildAiMessage(
            showAvatar: false,
            text: '',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '接下来的安排',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 10),
                ...upcoming.map(_buildScheduleBubble),
              ],
            ),
          ),
        ],

        // Completed section
        if (completed.isNotEmpty) ...[
          _buildAiMessage(
            showAvatar: false,
            text: '',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '已完成的',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF99A1AF),
                  ),
                ),
                const SizedBox(height: 10),
                ...completed.map(_buildScheduleBubble),
              ],
            ),
          ),
        ],

        // Closing message
        _buildAiMessage(
          showAvatar: false,
          text: upcoming.isNotEmpty && upcoming.first.priority == 3
              ? '提醒："${upcoming.first.title}" 是高优先级事项，建议优先处理。'
              : '你的日程安排很合理，继续加油！',
        ),
      ],
    );
  }
}
