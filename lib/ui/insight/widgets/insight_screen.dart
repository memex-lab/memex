import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:memex/domain/models/knowledge_insight_card.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'insight_detail_page.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/ui/core/cards/native_widget_factory.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/demo_service.dart';
import 'package:memex/ui/insight/widgets/insight_preview_data.dart';

/// Insight screen - global knowledge analytics. Receives [viewModel] from parent (Compass-style).
class InsightScreen extends StatefulWidget {
  final InsightViewModel viewModel;
  final bool isEmbedded;

  const InsightScreen({
    super.key,
    required this.viewModel,
    this.isEmbedded = false,
  });

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  Offset? _fabPosition;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onTogglePin(
      InsightViewModel vm, KnowledgeInsightCard item) async {
    try {
      await vm.togglePin(item);
      if (mounted) {
        ToastHelper.showSuccess(
            context,
            item.isPinned
                ? UserStorage.l10n.unpinned
                : UserStorage.l10n.pinnedStyle);
      }
    } catch (e) {
      if (mounted)
        ToastHelper.showError(
            context, UserStorage.l10n.operationFailed(e.toString()));
    }
  }

  Future<void> _onRefreshInsights(InsightViewModel vm) async {
    // During demo: don't hit the backend, just advance the demo step.
    if (DemoService.instance.tryAdvance(DemoStep.tapInsightUpdate)) {
      return;
    }
    try {
      ToastHelper.showInfo(context, UserStorage.l10n.refreshingInsightData);
      await vm.refreshInsights();
    } catch (e) {
      if (mounted)
        ToastHelper.showError(
            context, UserStorage.l10n.refreshFailed(e.toString()));
    }
  }

  void _onChatWithAssistant() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AgentChatDialog(
          agentName: 'knowledge_insight_agent',
          title: UserStorage.l10n.insightAssistant,
          inputHint: UserStorage.l10n.insightInputHint,
          scene: 'insight_card_chat',
          sceneId: 'general_insight_chat', // Use a generic ID
          initialRefs: const [], // No specific card context
        );
      },
    );
  }

  Future<void> _saveSortOrder(InsightViewModel vm) async {
    try {
      await vm.saveSortOrder();
      if (mounted)
        ToastHelper.showSuccess(context, UserStorage.l10n.sortUpdated);
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
            context, UserStorage.l10n.sortSaveFailed(e.toString()));
      }
    }
  }

  Future<void> _onDeleteCard(
      InsightViewModel vm, KnowledgeInsightCard item) async {
    try {
      await vm.deleteCard(item);
      if (mounted)
        ToastHelper.showSuccess(context, UserStorage.l10n.insightCardDeleted);
    } catch (e) {
      if (mounted)
        ToastHelper.showError(
            context, UserStorage.l10n.deleteFailedShort(e.toString()));
    }
  }

  void _showChatDialog(InsightViewModel vm, KnowledgeInsightCard item) {
    vm.setActiveCardId(null);

    final mergedData = item.mergedWidgetData;
    final title = mergedData['title'] as String? ?? 'Insight Card';
    final contextString = StringBuffer();
    contextString.writeln('Widget Template ID: ${item.widgetTemplate}');
    contextString.writeln('Insight ID: ${item.id}');
    contextString.writeln('Title: $title');
    contextString.writeln('Widget Data: $mergedData');

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AgentChatDialog(
          agentName: 'knowledge_insight_agent', // Use insight agent
          title: UserStorage.l10n.insightAssistant,
          inputHint: UserStorage.l10n.aboutThisInsightHint,
          scene: 'insight_card_chat',
          sceneId: item.id,
          initialRefs: [
            {
              'title': title,
              'content': contextString.toString(),
              'type': 'knowledge_insight_card',
            }
          ],
        );
      },
    );
  }

  Widget _buildPinButton(InsightViewModel vm, KnowledgeInsightCard item) {
    final isPinning = vm.pinningIds.contains(item.id);
    return GestureDetector(
      onTap: () => _onTogglePin(vm, item),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isPinning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B6CFF)),
                ),
              )
            : Icon(
                item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                size: 20,
                color: item.isPinned
                    ? const Color(0xFF5B6CFF)
                    : const Color(0xFF99A1AF),
              ),
      ),
    );
  }

  Widget _buildActionOverlay(InsightViewModel vm, KnowledgeInsightCard item) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => vm.setActiveCardId(null),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Stack(
            children: [
              // Center actions
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _showChatDialog(vm, item),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B6CFF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5B6CFF).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 32), // Spacing between buttons
                    // Sort Button
                    GestureDetector(
                      onTap: () {
                        vm.setActiveCardId(null);
                        vm.setReordering(true);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sort,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 32), // Spacing between buttons
                    // Delete Button
                    GestureDetector(
                      onTap: () => _onDeleteCard(vm, item),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: vm.isDeleting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              // Top-right cancel button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => vm.setActiveCardId(null),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF4A5565),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(InsightViewModel vm, KnowledgeInsightCard item,
      {VoidCallback? onTap}) {
    if (item.widgetType == 'native' && item.widgetTemplate != null) {
      final widget = NativeWidgetFactory.build(
        item.widgetTemplate!,
        item.mergedWidgetData,
      );
      if (widget != null) {
        return GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            absorbing: vm.isReordering,
            child: widget,
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            final content = Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => vm.loadData(),
                  child: vm.isReordering
                      ? ReorderableListView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
                          onReorder: (oldIndex, newIndex) =>
                              vm.moveItem(oldIndex, newIndex),
                          header: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (!widget.isEmbedded)
                                      Text(
                                        UserStorage.l10n.knowledgeInsight,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0A0A0A),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                    TextButton.icon(
                                      onPressed: () => _saveSortOrder(vm),
                                      icon: const Icon(Icons.check),
                                      label:
                                          Text(UserStorage.l10n.completeSort),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ]),
                          children: (vm.insights ?? [])
                              .map((item) => Container(
                                    key: ValueKey(item.id),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Stack(
                                      children: [
                                        _buildItemCard(vm, item),
                                        // Maybe drag handle?
                                        // ReorderableListView provides drag handle by default on long press or handle.
                                      ],
                                    ),
                                  ))
                              .toList(),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
                          children: [
                            // Header
                            // Add some top padding if embedded since we removed SafeArea/Scaffold top padding
                            // Actually ListView padding controls it.
                            // If embedded, we might want less padding if parent has it.
                            // But let's keep consistency for now.
                            if (widget.isEmbedded) const SizedBox(height: 16),

                            // Header
                            // Only show header if NOT embedded OR reordering
                            if (!widget.isEmbedded || vm.isReordering)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!widget.isEmbedded)
                                    Text(
                                      UserStorage.l10n.knowledgeInsight,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A0A0A),
                                      ),
                                    )
                                  else if (vm.isReordering)
                                    const Spacer(),
                                  if (vm.isReordering)
                                    TextButton.icon(
                                      onPressed: () => _saveSortOrder(vm),
                                      icon: const Icon(Icons.check),
                                      label:
                                          Text(UserStorage.l10n.completeSort),
                                    )
                                  else
                                    Row(
                                      children: [
                                        if (!widget.isEmbedded) ...[
                                          InkWell(
                                            onTap: _onChatWithAssistant,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFE2E8F0)),
                                              ),
                                              child: const Icon(
                                                Icons.chat_bubble_outline,
                                                size: 20,
                                                color: Color(0xFF5B6CFF),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        // Update Button (Only in Header if NOT embedded)
                                      ],
                                    ),
                                ],
                              ),

                            if (!widget.isEmbedded || vm.isReordering)
                              const SizedBox(height: 16),

                            const SizedBox(height: 16),

                            if (vm.isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (vm.errorMessage != null)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        vm.errorMessage!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF99A1AF),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => vm.loadData(),
                                        child: Text(UserStorage.l10n.reload),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              if (vm.insights != null &&
                                  vm.insights!.isNotEmpty)
                                ...(vm.insights!.map((item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: GestureDetector(
                                        onLongPress: () =>
                                            vm.setActiveCardId(item.id),
                                        child: Stack(
                                          children: [
                                            _buildItemCard(vm, item, onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      InsightDetailPage.insight(
                                                    insightId: item.id,
                                                  ),
                                                ),
                                              );
                                            }),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: _buildPinButton(vm, item),
                                            ),
                                            if (vm.activeCardId == item.id)
                                              _buildActionOverlay(vm, item),
                                          ],
                                        ),
                                      ),
                                    )))
                              else
                              // During demo: hide preview until user taps the update button.
                              // After demo (or on subsequent launches): always show preview.
                              if (!DemoService.instance.isActive ||
                                  DemoService.instance.currentStep!.index >
                                      DemoStep.tapInsightUpdate.index)
                                _buildPreviewCards()
                              else
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(
                                        UserStorage.l10n.noKnowledgeInsight),
                                  ),
                                ),
                            ],
                          ],
                        ),
                ),
                if (!vm.isReordering)
                  Positioned(
                    left: _fabPosition?.dx,
                    top: _fabPosition?.dy,
                    right: _fabPosition == null ? 20 : null,
                    bottom: _fabPosition == null ? 140 : null,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          Offset newPos;
                          if (_fabPosition == null) {
                            // Find initial position: right: 20, bottom: 100 from SafeArea edges
                            // We can use maxWidth/Height to estimate
                            newPos = Offset(
                              maxWidth - 140 - 20, // 140 is approx width
                              maxHeight - 48 - 100, // 48 is approx height
                            );
                          } else {
                            newPos = _fabPosition! + details.delta;
                          }

                          // Clamp to avoid bottom bar (approx 120px from bottom)
                          const btnWidth = 120.0;
                          const btnHeight = 48.0;
                          final left =
                              newPos.dx.clamp(16.0, maxWidth - btnWidth - 16.0);
                          final top = newPos.dy
                              .clamp(16.0, maxHeight - btnHeight - 120.0);
                          _fabPosition = Offset(left, top);
                        });
                      },
                      child: KeyedSubtree(
                        key: DemoService.instance.insightUpdateKey,
                        child: _buildPremiumUpdateFab(vm),
                      ),
                    ),
                  ),
              ],
            );

            // Wrap in Scaffold when not embedded
            final wrappedContent = widget.isEmbedded
                ? content
                : Scaffold(
                    backgroundColor: const Color(0xFFF7F8FA),
                    body: SafeArea(
                      child: content,
                    ),
                  );

            return wrappedContent;
          },
        );
      },
    );
  }

  /// Preview cards shown when the user has no real insights yet.
  /// Rendered with reduced opacity and a banner hint; non-interactive.
  Widget _buildPreviewCards() {
    final samples = InsightPreviewData.samples;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner hint
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome,
                  size: 18, color: Color(0xFF6366F1)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  UserStorage.l10n.noKnowledgeInsight,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Sample cards — visual only, no interaction
        ...samples.map((s) {
          final card = NativeWidgetFactory.build(s.template, s.data);
          if (card == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Opacity(
              opacity: 0.55,
              child: IgnorePointer(child: card),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPremiumUpdateFab(InsightViewModel vm) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF5B6CFF).withOpacity(0.9),
                const Color(0xFF8B5CF6).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B6CFF).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: vm.isRefreshing ? null : () => _onRefreshInsights(vm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                vm.isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                const SizedBox(width: 10),
                Text(
                  vm.isRefreshing
                      ? UserStorage.l10n.updating
                      : UserStorage.l10n.update,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
