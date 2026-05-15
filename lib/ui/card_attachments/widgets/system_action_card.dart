import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/data/services/native_action_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/utils/user_storage.dart';

class SystemActionCard extends StatefulWidget {
  final SystemAction action;
  final SystemActionService service;

  const SystemActionCard({
    super.key,
    required this.action,
    required this.service,
  });

  @override
  State<SystemActionCard> createState() => _SystemActionCardState();
}

class _SystemActionCardState extends State<SystemActionCard> {
  bool _isProcessing = false;

  Future<void> _handleAccept() async {
    setState(() => _isProcessing = true);

    Map<String, dynamic> data = {};
    if (widget.action.actionData != null) {
      try {
        data = jsonDecode(widget.action.actionData!);
      } catch (_) {}
    }

    final String title = data['title'] ?? 'Unknown Action';
    final isCalendar = widget.action.actionType == 'calendar';

    bool success = false;
    if (isCalendar) {
      if (!await _checkAndRequestPermission(
          Permission.calendarFullAccess, UserStorage.l10n.calendar)) {
        setState(() => _isProcessing = false);
        return;
      }

      final startTimeStr = data['start_time'];
      final endTimeStr = data['end_time'];
      DateTime? startTime = parseLocalDateTime(startTimeStr);
      DateTime? endTime = parseLocalDateTime(endTimeStr);

      startTime ??= DateTime.now().add(const Duration(hours: 1));

      success = await NativeActionService.addCalendarEvent(
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: data['location'],
        notes: data['notes'],
      );
    } else {
      final reminderPermission = Platform.isAndroid
          ? Permission.calendarFullAccess
          : Permission.reminders;
      if (!await _checkAndRequestPermission(
          reminderPermission, UserStorage.l10n.reminders)) {
        setState(() => _isProcessing = false);
        return;
      }

      final dueDateStr = data['due_date'];
      DateTime? dueDate = parseLocalDateTime(dueDateStr);

      success = await NativeActionService.addReminder(
        title: title,
        dueDate: dueDate,
        notes: data['notes'],
      );
    }

    if (success) {
      await widget.service.updateActionStatus(widget.action.id, 'completed');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(UserStorage.l10n.writeToSystemFailed)));
      }
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleIgnore() async {
    setState(() => _isProcessing = true);
    await widget.service.updateActionStatus(widget.action.id, 'rejected');
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  Future<bool> _checkAndRequestPermission(
      Permission permission, String name) async {
    var status = await permission.status;
    if (status.isGranted) return true;

    status = await permission.request();
    if (status.isGranted) return true;

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(UserStorage.l10n.permissionRequired(name)),
          content: Text(UserStorage.l10n.permissionRationale(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(UserStorage.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: Text(UserStorage.l10n.goToSettings),
            ),
          ],
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.action.status == 'rejected') {
      return const SizedBox.shrink();
    }

    Map<String, dynamic> data = {};
    if (widget.action.actionData != null) {
      try {
        data = jsonDecode(widget.action.actionData!);
      } catch (e) {
        // ignore
      }
    }

    final String title = data['title'] ?? UserStorage.l10n.unknownAction;
    final String? startTime = data['start_time'];
    final String? dueDate = data['due_date'];
    final bool isCalendar = widget.action.actionType == 'calendar';

    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor =
        isCalendar ? const Color(0xFF007AFF) : const Color(0xFFFF9500);
    final iconData =
        isCalendar ? Icons.calendar_month_rounded : Icons.checklist_rounded;
    final headerText = isCalendar
        ? UserStorage.l10n.discoveredCalendarEvent
        : UserStorage.l10n.discoveredReminder;
    final buttonText = isCalendar
        ? UserStorage.l10n.addToCalendar
        : UserStorage.l10n.addToReminders;

    final displayTime = _formatDisplayTime(isCalendar ? startTime : dueDate);
    final isCompleted = widget.action.status == 'completed';

    if (isCompleted) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                UserStorage.l10n.addedToSuccess(isCalendar
                    ? UserStorage.l10n.calendar
                    : UserStorage.l10n.reminders),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: primaryColor, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  headerText,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
            ),
            if (displayTime != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 14,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      displayTime,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isProcessing ? null : _handleIgnore,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(UserStorage.l10n.ignore),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isProcessing ? null : _handleAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(buttonText,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _formatDisplayTime(String? value) {
    final dateTime = parseLocalDateTime(value);
    if (dateTime == null) return value;
    return DateFormat.yMd(UserStorage.l10n.localeName)
        .add_Hm()
        .format(dateTime);
  }
}
