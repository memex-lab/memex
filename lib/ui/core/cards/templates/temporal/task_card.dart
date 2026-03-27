import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';

class TaskCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;
  final String? cardId;
  final int? configIndex;
  final Function(String cardId, int configIndex, Map<String, dynamic> data)?
      onUpdate;

  const TaskCard({
    super.key,
    required this.data,
    this.onTap,
    this.cardId,
    this.configIndex,
    this.onUpdate,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late bool _isCompleted;
  late List<dynamic> _subtasks;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _initializeState();
    }
  }

  void _initializeState() {
    _isCompleted = widget.data['is_completed'] ?? false;
    _subtasks = List.from(widget.data['subtasks'] ?? []);
  }

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
    _updateData();
  }

  void _toggleSubtask(int index) {
    setState(() {
      final task = Map<String, dynamic>.from(_subtasks[index]);
      task['completed'] = !(task['completed'] ?? false);
      _subtasks[index] = task;

      // Optional: Auto-update parent completion if all subtasks are done
      // For now, keeping them independent as per typical todo list behavior
    });
    _updateData();
  }

  void _updateData() {
    if (widget.cardId != null &&
        widget.configIndex != null &&
        widget.onUpdate != null) {
      widget.onUpdate!(
        widget.cardId!,
        widget.configIndex!,
        {
          'is_completed': _isCompleted,
          'subtasks': _subtasks,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.data['title'] ?? 'Task';
    final bool hasSubtasks = _subtasks.isNotEmpty;

    return GlassCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Main Title)
          Row(
            children: [
              GestureDetector(
                onTap: _toggleCompletion,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF5B6CFF), width: 2),
                      color: _isCompleted
                          ? const Color(0xFF5B6CFF)
                          : Colors.transparent),
                  child: _isCompleted
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A0A0A),
                        decoration:
                            _isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFF99A1AF))),
              ),
              if (widget.data['priority'] == 'high')
                const Icon(Icons.priority_high, size: 16, color: Color(0xFFF43F5E))
            ],
          ),
          if (hasSubtasks) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ..._subtasks.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> task = entry.value;
              final bool done = task['completed'] ?? false;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleSubtask(index),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                            done
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 18,
                            color:
                                done ? const Color(0xFF99A1AF) : const Color(0xFF4A5565)),
                      ),
                    ),
                    Expanded(
                      child: Text(task['title'] ?? '',
                          style: TextStyle(
                              fontSize: 13,
                              color:
                                  done ? const Color(0xFF99A1AF) : const Color(0xFF334155),
                              decoration:
                                  done ? TextDecoration.lineThrough : null)),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            if (widget.data['due_date'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 32),
                child: Text("${widget.data['due_date']}",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF99A1AF))),
              )
          ]
        ],
      ),
    );
  }
}
