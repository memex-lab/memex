import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/ui/card_attachments/card_attachment_data.dart';
import 'package:memex/ui/card_attachments/card_attachment_factory.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/domain/models/card_generation_retry_result.dart';
import 'package:memex/data/repositories/memex_router.dart';

class ActionCenterSheet extends StatefulWidget {
  const ActionCenterSheet({
    super.key,
    this.loadPendingAttachments,
    this.loadFailedCardCount,
    this.retryAllFailedCards,
    this.dismissPendingAttachments,
  });

  final Future<List<CardAttachmentData>> Function()? loadPendingAttachments;
  final Future<int> Function()? loadFailedCardCount;
  final Future<CardGenerationRetryResult> Function()? retryAllFailedCards;
  final Future<int> Function(String? type)? dismissPendingAttachments;

  @override
  State<ActionCenterSheet> createState() => _ActionCenterSheetState();
}

class _ActionCenterSheetState extends State<ActionCenterSheet>
    with SingleTickerProviderStateMixin {
  List<CardAttachmentData>? _items;
  int _failedCardCount = 0;
  bool _isLoading = true;
  bool _isDismissing = false;
  bool _isRetryingFailedCards = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _load();
    EventBusService.instance.addHandler(
      EventBusMessageType.attachmentsChanged,
      _onAttachmentsChanged,
    );
    EventBusService.instance.addHandler(
      EventBusMessageType.cardUpdated,
      _onCardUpdated,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    EventBusService.instance.removeHandler(
      EventBusMessageType.attachmentsChanged,
      _onAttachmentsChanged,
    );
    EventBusService.instance.removeHandler(
      EventBusMessageType.cardUpdated,
      _onCardUpdated,
    );
    super.dispose();
  }

  void _onAttachmentsChanged(EventBusMessage message) {
    _load();
  }

  void _onCardUpdated(EventBusMessage message) {
    _load();
  }

  Future<void> _load() async {
    final loadAttachments = widget.loadPendingAttachments ??
        CardAttachmentService.instance.getPendingAttachments;
    final loadFailedCount =
        widget.loadFailedCardCount ?? MemexRouter().countFailedCardGenerations;
    final results = await Future.wait([loadAttachments(), loadFailedCount()]);
    if (!mounted) return;
    setState(() {
      _items = results[0] as List<CardAttachmentData>;
      _failedCardCount = results[1] as int;
      _isLoading = false;
    });
    if ((_items ?? const []).isNotEmpty || _failedCardCount > 0) {
      _fadeController.forward();
    }
  }

  /// Count items by type.
  Map<String, int> _countByType() {
    final items = _items ?? [];
    final counts = <String, int>{};
    for (final item in items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Clear all — direct action.
  Future<void> _clearAll() async {
    await _performDismiss(null);
  }

  /// Show per-type options via dropdown.
  void _showTypeMenu() {
    final counts = _countByType();
    if (counts.isEmpty) return;

    final l10n = UserStorage.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DismissOptionsSheet(
        counts: counts,
        l10n: l10n,
        colorScheme: colorScheme,
        onDismiss: (String? type) {
          Navigator.pop(ctx);
          _performDismiss(type);
        },
      ),
    );
  }

  Future<void> _performDismiss(String? type) async {
    if (_isDismissing) return;
    setState(() => _isDismissing = true);

    HapticFeedback.mediumImpact();

    final dismiss = widget.dismissPendingAttachments ??
        (String? selectedType) => CardAttachmentService.instance
            .dismissAllPending(type: selectedType);
    final count = await dismiss(type);

    if (!mounted) return;

    setState(() => _isDismissing = false);

    if (count > 0) {
      final l10n = UserStorage.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dismissedCount(count)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
        ),
      );
      await _load();
    }
  }

  Future<void> _retryAllFailedCards() async {
    if (_isRetryingFailedCards) return;
    setState(() => _isRetryingFailedCards = true);
    HapticFeedback.mediumImpact();

    try {
      final retryAll = widget.retryAllFailedCards ??
          MemexRouter().retryAllFailedCardGenerations;
      final result = await retryAll();
      if (!mounted) return;

      final l10n = UserStorage.l10n;
      final failed = result.errors.length;
      final message = failed == 0
          ? l10n.failedCardsRetryStarted(result.retried)
          : l10n.failedCardsRetryPartial(result.retried, failed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
        ),
      );
      await _load();
    } finally {
      if (mounted) {
        setState(() => _isRetryingFailedCards = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppDatabase.isInitialized) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        minHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          _buildHeader(colorScheme),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),

          // Content
          Expanded(child: _buildContent(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    final l10n = UserStorage.l10n;
    final attachmentCount = _items?.length ?? 0;
    final hasItems = attachmentCount > 0 || _failedCardCount > 0;
    final itemCount = attachmentCount + (_failedCardCount > 0 ? 1 : 0);
    final hasMultipleTypes = _countByType().length > 1;
    final hasDismissibleItems = attachmentCount > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
      child: Row(
        children: [
          // Title + count badge
          Text(
            l10n.actionCenterTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (hasItems) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],

          const Spacer(),

          // Clear button
          if (hasDismissibleItems) ...[
            _ClearButtonGroup(
              isDismissing: _isDismissing,
              hasMultipleTypes: hasMultipleTypes,
              onClearAll: _clearAll,
              onShowTypeMenu: _showTypeMenu,
            ),
            const SizedBox(width: 8),
          ],

          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: AgentLogoLoading());
    }

    final items = _items ?? const [];

    if (items.isEmpty && _failedCardCount == 0) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                UserStorage.l10n.noPendingActions,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pendingActions = _itemsWhere(
      (item) =>
          item.type == CardAttachmentType.systemAction &&
          !_isPastDueSystemAction(item),
    );
    final pastDueActions = _itemsWhere(_isPastDueSystemAction);
    final clarifications = _itemsWhere(
      (item) => item.type == CardAttachmentType.clarificationRequest,
    );
    final cardUpdates = _itemsWhere(
      (item) => item.type == CardAttachmentType.cardDetailNotification,
    );
    final l10n = UserStorage.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      children: [
        if (_failedCardCount > 0)
          _ActionCenterSection(
            title: l10n.actionCenterBackgroundSection,
            subtitle: l10n.actionCenterBackgroundSectionDescription,
            count: _failedCardCount,
            icon: Icons.error_outline_rounded,
            iconColor: const Color(0xFFD97706),
            children: [
              _FailedCardsRetryCard(
                count: _failedCardCount,
                isRetrying: _isRetryingFailedCards,
                onRetryAll: _retryAllFailedCards,
              ),
            ],
          ),
        if (pendingActions.isNotEmpty)
          _ActionCenterSection(
            title: l10n.actionCenterPendingActionsSection,
            subtitle: l10n.actionCenterPendingActionsSectionDescription,
            count: pendingActions.length,
            icon: Icons.event_available_rounded,
            iconColor: const Color(0xFF10B981),
            children: pendingActions.map(_buildAttachmentItem).toList(),
          ),
        if (pastDueActions.isNotEmpty)
          _ActionCenterSection(
            title: l10n.actionCenterPastDueSection,
            subtitle: l10n.actionCenterPastDueSectionDescription,
            count: pastDueActions.length,
            icon: Icons.history_toggle_off_rounded,
            iconColor: const Color(0xFF64748B),
            children: pastDueActions.map(_buildAttachmentItem).toList(),
          ),
        if (clarifications.isNotEmpty)
          _ActionCenterSection(
            title: l10n.actionCenterClarificationsSection,
            subtitle: l10n.actionCenterClarificationsSectionDescription,
            count: clarifications.length,
            icon: Icons.help_outline_rounded,
            iconColor: const Color(0xFFF59E0B),
            children: clarifications.map(_buildAttachmentItem).toList(),
          ),
        if (cardUpdates.isNotEmpty)
          _ActionCenterSection(
            title: l10n.actionCenterCardUpdatesSection,
            subtitle: l10n.actionCenterCardUpdatesSectionDescription,
            count: cardUpdates.length,
            icon: Icons.article_outlined,
            iconColor: const Color(0xFF6366F1),
            trailing: TextButton.icon(
              onPressed: _isDismissing
                  ? null
                  : () => _performDismiss(
                        CardAttachmentType.cardDetailNotification,
                      ),
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: Text(l10n.actionCenterMarkAllCardUpdatesRead),
            ),
            children: cardUpdates.map(_buildAttachmentItem).toList(),
          ),
      ],
    );
  }

  List<CardAttachmentData> _itemsWhere(
    bool Function(CardAttachmentData item) test,
  ) {
    return (_items ?? const <CardAttachmentData>[]).where(test).toList();
  }

  bool _isPastDueSystemAction(CardAttachmentData item) {
    if (item.type != CardAttachmentType.systemAction) return false;
    final action = item.data['action'];
    return action is SystemAction &&
        action.status == SystemActionService.statusPastDue;
  }

  Widget _buildAttachmentItem(CardAttachmentData item) {
    return KeyedSubtree(
      key: ValueKey(item.id),
      child: CardAttachmentFactory.build(item),
    );
  }
}

class _ActionCenterSection extends StatelessWidget {
  const _ActionCenterSection({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.children,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.25,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _FailedCardsRetryCard extends StatelessWidget {
  const _FailedCardsRetryCard({
    required this.count,
    required this.isRetrying,
    required this.onRetryAll,
  });

  final int count;
  final bool isRetrying;
  final VoidCallback onRetryAll;

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.failedCardsRetryTitle(count),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.failedCardsRetryDescription,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: const Color(0xFF92400E).withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: isRetrying ? null : onRetryAll,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFFD97706,
                      ).withValues(alpha: 0.35),
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: isRetrying
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.7,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 17),
                    label: Text(
                      l10n.retryAllFailedCards,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Clear button group: [Clear All] [▼]
// ---------------------------------------------------------------------------

class _ClearButtonGroup extends StatelessWidget {
  const _ClearButtonGroup({
    required this.isDismissing,
    required this.hasMultipleTypes,
    required this.onClearAll,
    required this.onShowTypeMenu,
  });

  final bool isDismissing;
  final bool hasMultipleTypes;
  final VoidCallback onClearAll;
  final VoidCallback onShowTypeMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main clear text button
        GestureDetector(
          onTap: isDismissing ? null : onClearAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDismissing)
                const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.textTertiary,
                  ),
                )
              else
                const Icon(
                  Icons.clear_all_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              const SizedBox(width: 3),
              Text(
                l10n.dismissAllNotifications,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Dropdown arrow (only if multiple types)
        if (hasMultipleTypes) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: isDismissing ? null : onShowTypeMenu,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dismiss options bottom sheet (per-type selection)
// ---------------------------------------------------------------------------

class _DismissOptionsSheet extends StatelessWidget {
  const _DismissOptionsSheet({
    required this.counts,
    required this.l10n,
    required this.colorScheme,
    required this.onDismiss,
  });

  final Map<String, int> counts;
  final dynamic l10n;
  final ColorScheme colorScheme;
  final void Function(String? type) onDismiss;

  String _typeLabel(String type) {
    switch (type) {
      case CardAttachmentType.systemAction:
        return l10n.dismissTypeSystemAction;
      case CardAttachmentType.clarificationRequest:
        return l10n.dismissTypeClarification;
      case CardAttachmentType.cardDetailNotification:
        return l10n.dismissTypeCardUpdate;
      default:
        return type;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case CardAttachmentType.systemAction:
        return Icons.event_note_rounded;
      case CardAttachmentType.clarificationRequest:
        return Icons.help_outline_rounded;
      case CardAttachmentType.cardDetailNotification:
        return Icons.article_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case CardAttachmentType.systemAction:
        return const Color(0xFF10B981);
      case CardAttachmentType.clarificationRequest:
        return const Color(0xFFF59E0B);
      case CardAttachmentType.cardDetailNotification:
        return const Color(0xFF6366F1);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.dismissByType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            indent: 24,
            endIndent: 24,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),

          const SizedBox(height: 8),

          // Per-type options
          ...counts.entries.map(
            (entry) => _DismissOptionTile(
              icon: _typeIcon(entry.key),
              iconColor: _typeColor(entry.key),
              label: _typeLabel(entry.key),
              count: entry.value,
              onTap: () => onDismiss(entry.key),
            ),
          ),

          const SizedBox(height: 12),

          // Cancel
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                ),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissOptionTile extends StatelessWidget {
  const _DismissOptionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
