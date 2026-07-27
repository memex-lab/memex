import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class SystemActionCard extends StatefulWidget {
  final SystemAction action;
  final SystemActionService service;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onActionChanged;

  const SystemActionCard({
    super.key,
    required this.action,
    required this.service,
    this.margin = const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 16.0,
    ),
    this.onActionChanged,
  });

  @override
  State<SystemActionCard> createState() => _SystemActionCardState();
}

class _SystemActionCardState extends State<SystemActionCard> {
  bool _isProcessing = false;
  String? _statusOverride;

  @override
  void didUpdateWidget(covariant SystemActionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.action.id != widget.action.id ||
        oldWidget.action.status != widget.action.status) {
      _statusOverride = null;
    }
  }

  Future<void> _handleAccept() async {
    setState(() => _isProcessing = true);

    final isCalendar = widget.action.actionType == 'calendar';
    final isReminder = widget.action.actionType == 'reminder';

    if (!isCalendar && !isReminder) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserStorage.l10n.writeToSystemFailed)),
        );
        setState(() => _isProcessing = false);
      }
      return;
    }

    if (isCalendar) {
      final calendarPermission = Platform.isIOS
          ? Permission.calendarWriteOnly
          : Permission.calendarFullAccess;
      if (!await _checkAndRequestPermission(
          calendarPermission, UserStorage.l10n.calendar)) {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }
    } else {
      final reminderPermission = Platform.isAndroid
          ? Permission.calendarFullAccess
          : Permission.reminders;
      if (!await _checkAndRequestPermission(
          reminderPermission, UserStorage.l10n.reminders)) {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }
    }

    final success = await widget.service.applyToDevice(widget.action);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(UserStorage.l10n.writeToSystemFailed)));
      }
    } else if (mounted) {
      setState(() => _statusOverride = 'completed');
      widget.onActionChanged?.call();
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleIgnore() async {
    setState(() => _isProcessing = true);
    final success =
        await widget.service.updateActionStatus(widget.action.id, 'rejected');
    if (mounted) {
      setState(() {
        _isProcessing = false;
        if (success) _statusOverride = 'rejected';
      });
      if (success) widget.onActionChanged?.call();
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
    final status = _statusOverride ?? widget.action.status;
    if (status == 'rejected') {
      return const SizedBox.shrink();
    }

    final data = widget.service.decodeActionData(widget.action);

    final String title = data['title'] ?? UserStorage.l10n.unknownAction;
    final String? startTime = data['start_time'];
    final String? dueDate = data['due_date'];
    final bool isCalendar = widget.action.actionType == 'calendar';
    final bool isReminder = widget.action.actionType == 'reminder';
    final bool isSupported = isCalendar || isReminder;

    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor =
        isCalendar ? const Color(0xFF007AFF) : const Color(0xFFFF9500);
    final iconData =
        isCalendar ? Icons.calendar_month_rounded : Icons.checklist_rounded;
    final headerText = switch (widget.action.actionType) {
      'calendar' => UserStorage.l10n.discoveredCalendarEvent,
      'reminder' => UserStorage.l10n.discoveredReminder,
      _ => UserStorage.l10n.unknownAction,
    };
    final buttonText = switch (widget.action.actionType) {
      'calendar' => UserStorage.l10n.addToCalendar,
      'reminder' => UserStorage.l10n.addToReminders,
      _ => UserStorage.l10n.unknownAction,
    };

    final displayTime = _formatDisplayTime(isCalendar ? startTime : dueDate);
    final isCompleted = status == 'completed';

    if (isCompleted) {
      return Container(
        margin: widget.margin,
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
      margin: widget.margin,
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
                Expanded(
                  child: Text(
                    headerText,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                    softWrap: true,
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
            const SizedBox(height: 10),
            Text(
              UserStorage.l10n.systemActionPendingExplanation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
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
                FilledButton(
                  onPressed:
                      _isProcessing || !isSupported ? null : _handleAccept,
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

/// Resolves a persisted system action and renders its confirmation controls
/// directly where the originating agent artifact appears.
class SystemActionArtifactCard extends StatefulWidget {
  const SystemActionArtifactCard({
    super.key,
    required this.actionId,
    required this.actionKind,
    this.fallbackTitle,
    this.fallbackSummary,
    this.service,
  });

  final String actionId;
  final String actionKind;
  final String? fallbackTitle;
  final String? fallbackSummary;
  final SystemActionService? service;

  @override
  State<SystemActionArtifactCard> createState() =>
      _SystemActionArtifactCardState();
}

class _SystemActionArtifactCardState extends State<SystemActionArtifactCard> {
  late Future<SystemAction?> _actionFuture;

  SystemActionService get _service =>
      widget.service ?? SystemActionService.instance;

  @override
  void initState() {
    super.initState();
    _actionFuture = _loadAction();
  }

  @override
  void didUpdateWidget(covariant SystemActionArtifactCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actionId != widget.actionId ||
        oldWidget.service != widget.service) {
      _actionFuture = _loadAction();
    }
  }

  Future<SystemAction?> _loadAction() {
    if (!AppDatabase.isInitialized) return Future.value();
    return _service.getAction(widget.actionId);
  }

  void _reloadAction() {
    if (!mounted) return;
    setState(() => _actionFuture = _loadAction());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SystemAction?>(
      future: _actionFuture,
      builder: (context, snapshot) {
        final action = snapshot.data;
        if (action != null) {
          return SystemActionCard(
            action: action,
            service: _service,
            margin: EdgeInsets.zero,
            onActionChanged: _reloadAction,
          );
        }

        return _SystemActionArtifactPlaceholder(
          actionKind: widget.actionKind,
          title: widget.fallbackTitle,
          summary: widget.fallbackSummary,
          loading: snapshot.connectionState != ConnectionState.done,
        );
      },
    );
  }
}

class _SystemActionArtifactPlaceholder extends StatelessWidget {
  const _SystemActionArtifactPlaceholder({
    required this.actionKind,
    required this.title,
    required this.summary,
    required this.loading,
  });

  final String actionKind;
  final String? title;
  final String? summary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isCalendar = actionKind == 'calendar';
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor =
        isCalendar ? const Color(0xFF007AFF) : const Color(0xFFFF9500);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCalendar
                    ? Icons.calendar_month_rounded
                    : Icons.checklist_rounded,
                color: accentColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCalendar
                      ? UserStorage.l10n.discoveredCalendarEvent
                      : UserStorage.l10n.discoveredReminder,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentColor,
                  ),
                ),
            ],
          ),
          if (title != null) ...[
            const SizedBox(height: 8),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (summary != null) ...[
            const SizedBox(height: 6),
            Text(
              summary!,
              style: TextStyle(
                fontSize: 12.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
