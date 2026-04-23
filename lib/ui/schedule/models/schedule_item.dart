import 'package:flutter/material.dart';

// =============================================================================
// Mock Data Models
// =============================================================================

enum ScheduleItemType { todo, event }

enum ScheduleItemStatus { pending, completed, inProgress, overdue }

class ScheduleItem {
  final String id;
  final String title;
  final ScheduleItemType type;
  final ScheduleItemStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? completedAt;
  final String? location;
  final String? description;
  final List<String> tags;
  final int? priority; // 1-3, 3 = highest
  final List<RelatedEvent> relatedEvents;

  ScheduleItem({
    required this.id,
    required this.title,
    required this.type,
    this.status = ScheduleItemStatus.pending,
    this.startTime,
    this.endTime,
    this.completedAt,
    this.location,
    this.description,
    this.tags = const [],
    this.priority,
    this.relatedEvents = const [],
  });

  ScheduleItem copyWith({
    ScheduleItemStatus? status,
    DateTime? completedAt,
  }) {
    return ScheduleItem(
      id: id,
      title: title,
      type: type,
      status: status ?? this.status,
      startTime: startTime,
      endTime: endTime,
      completedAt: completedAt ?? this.completedAt,
      location: location,
      description: description,
      tags: tags,
      priority: priority,
      relatedEvents: relatedEvents,
    );
  }
}

class RelatedEvent {
  final String id;
  final String title;
  final String type;
  final DateTime timestamp;

  RelatedEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.timestamp,
  });
}
