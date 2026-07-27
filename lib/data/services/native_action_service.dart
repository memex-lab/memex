import 'package:flutter/services.dart';
import 'package:memex/utils/logger.dart';

class NativeActionService {
  static final _logger = getLogger('NativeActionService');

  static const MethodChannel _channel =
      MethodChannel('com.memexlab.memex/system_actions');

  static Future<bool> addCalendarEvent({
    required String title,
    required DateTime startTime,
    DateTime? endTime,
    String? location,
    String? notes,
  }) async {
    try {
      final result = await _channel.invokeMethod('addCalendarEvent', {
        'title': title,
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime?.millisecondsSinceEpoch ??
            startTime.add(const Duration(hours: 1)).millisecondsSinceEpoch,
        'location': location,
        'notes': notes,
      });
      return result == true;
    } catch (error, stackTrace) {
      _logger.severe(
        'Failed to add calendar event',
        error,
        stackTrace,
      );
      return false;
    }
  }

  static Future<bool> addReminder({
    required String title,
    required DateTime dueDate,
    String? notes,
  }) async {
    try {
      final result = await _channel.invokeMethod('addReminder', {
        'title': title,
        'dueDate': dueDate.millisecondsSinceEpoch,
        'notes': notes,
      });
      return result == true;
    } catch (error, stackTrace) {
      _logger.severe(
        'Failed to add reminder',
        error,
        stackTrace,
      );
      return false;
    }
  }
}
