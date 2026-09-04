import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:memex/config/app_config.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/ui/card_attachments/card_attachment_data.dart';
import 'package:memex/ui/card_attachments/card_attachment_factory.dart';
import 'package:memex/ui/core/widgets/html_webview_card.dart';
import 'package:memex/ui/main_screen/widgets/action_center_sheet.dart';

import 'package:memex/ui/core/cards/native_card_factory.dart';
import 'package:memex/data/services/demo_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/ui/core/cards/card_action_notification.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';
import 'package:memex/ui/timeline/widgets/timeline_model_config_banner.dart';
import 'package:memex/ui/settings/widgets/personal_center_screen.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/insight/widgets/insight_screen.dart';
import 'package:memex/ui/insight/widgets/insight_detail_page.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/permission_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memex/ui/settings/widgets/ai_service_setup_page.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/ui/settings/widgets/system_authorization_page.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/core/widgets/memex_brand_title.dart';
import 'package:memex/ui/core/widgets/character_avatar.dart';
import 'package:memex/ui/character/widgets/persona_avatar_button.dart';
import 'package:memex/ui/character/view_models/persona_avatar_viewmodel.dart';
import 'package:memex/routing/routes.dart';

/// Timeline screen - main memory view. Receives [viewModel] and [insightViewModel] from parent (Compass-style).
class TimelineScreen extends StatefulWidget {
  final TimelineViewModel viewModel;
  final InsightViewModel insightViewModel;
  final PersonaAvatarViewModel personaAvatarViewModel;
  final VoidCallback onInputTap;
  final VoidCallback? onRefreshAction;

  const TimelineScreen({
    super.key,
    required this.viewModel,
    required this.insightViewModel,
    required this.personaAvatarViewModel,
    required this.onInputTap,
    this.onRefreshAction,
  });

  @override
  State<TimelineScreen> createState() => TimelineScreenState();
}

class TimelineScreenState extends State<TimelineScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showPermissionBadge = false;
  String? _userAvatar;
  bool _showFitnessBanner = false;
  late PageController _pageController;
  int _currentPageIndex = 0;
  final ScrollController _tagScrollController = ScrollController();

  /// Scroll to top and refresh timeline (called from main screen).
  void scrollToTopAndRefresh() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    if (mounted) {
      widget.viewModel.refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController.addListener(_onScroll);
    EventBusService.instance.addHandler(
      EventBusMessageType.profileUpdated,
      _handleProfileUpdated,
    );
    _checkPermissionBadge();
    _loadUserAvatar();
    _checkFitnessBanner();
  }

  Future<void> _checkFitnessBanner() async {
    // Fitness permission banner is temporarily hidden — may be re-enabled in the future.
    return;
    // ignore: dead_code
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool('fitness_banner_dismissed') ?? false;
    if (dismissed) {
      if (mounted && _showFitnessBanner) {
        setState(() => _showFitnessBanner = false);
      }
      return;
    }
    final granted = await PermissionUtils.isFitnessPermissionGranted();
    if (mounted && _showFitnessBanner != !granted) {
      setState(() => _showFitnessBanner = !granted);
    }
  }

  Future<void> _dismissFitnessBanner() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(UserStorage.l10n.fitnessDismissTitle),
        content: Text(UserStorage.l10n.fitnessDismissMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              UserStorage.l10n.skipAnyway,
              style: const TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fitness_banner_dismissed', true);
    if (mounted) {
      setState(() => _showFitnessBanner = false);
    }
  }

  Future<void> _checkPermissionBadge() async {
    final granted = await PermissionUtils.isFitnessPermissionGranted();
    if (mounted && !granted != _showPermissionBadge) {
      setState(() => _showPermissionBadge = !granted);
    }
  }

  Future<void> _loadUserAvatar() async {
    final avatar = await MemexRouter().getUserAvatar();
    if (mounted) {
      setState(() => _userAvatar = avatar);
    }
  }

  void _handleProfileUpdated(EventBusMessage message) {
    if (mounted) {
      _loadUserAvatar();
    }
  }

  @override
  void dispose() {
    EventBusService.instance.removeHandler(
      EventBusMessageType.profileUpdated,
      _handleProfileUpdated,
    );
    _pageController.dispose();
    _tagScrollController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final vm = widget.viewModel;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!vm.isLoading && vm.hasMore) {
        vm.loadMore();
      }
    }
  }

  /// Get the total number of tab pages: All(0) + Insight(1) + user tags(2..)
  int _totalPageCount(TimelineViewModel vm) => 2 + vm.tags.length;

  /// Convert a page index to the corresponding filter string.
  String _pageIndexToFilter(int index, TimelineViewModel vm) {
    if (index == 0) return 'all';
    if (index == 1) return 'insight';
    return vm.tags[index - 2].name;
  }

  /// Convert the current active filter to a page index.
  int _filterToPageIndex(TimelineViewModel vm) {
    if (vm.viewMode == TimelineViewMode.insight) return 1;
    if (vm.activeFilter == 'all') return 0;
    final idx = vm.tags.indexWhere((t) => t.name == vm.activeFilter);
    return idx >= 0 ? idx + 2 : 0;
  }

  /// Called when user swipes to a new page.
  void _onPageChanged(int index, TimelineViewModel vm) {
    if (index == _currentPageIndex) return;
    _currentPageIndex = index;
    final filter = _pageIndexToFilter(index, vm);
    if (index == 1) {
      unawaited(widget.insightViewModel.ensureLoaded());
      vm.setViewMode(TimelineViewMode.insight);
      vm.setActiveFilter('insight');
    } else {
      vm.setViewMode(TimelineViewMode.timeline);
      vm.setActiveFilter(filter);
      vm.loadCards(refresh: true);
    }
    _scrollTagIntoView(index, vm);
  }

  /// Scroll the tag chip list so the active tag is visible.
  void _scrollTagIntoView(int index, TimelineViewModel vm) {
    if (!_tagScrollController.hasClients) return;
    // Estimate each chip width ~80px + 10px gap
    const estimatedChipWidth = 90.0;
    final targetOffset = (index * estimatedChipWidth) -
        (MediaQuery.of(context).size.width / 2 - estimatedChipWidth / 2);
    final maxScroll = _tagScrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);
    _tagScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Called when user taps a tag chip.
  void _jumpToPage(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    _pageController.jumpToPage(index);
    _scrollTagIntoView(index, widget.viewModel);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.viewModel, widget.viewModel.load]),
      builder: (context, _) {
        final vm = widget.viewModel;
        return Column(
          children: [
            // Header: Memex title + action icons
            // Figma: title top=73, left=20; buttons top=68, left=253, w=120, h=36
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: MemexBrandTitle(),
                      ),
                    ),
                  ),
                  // Header actions: notification, companion, user avatar
                  SizedBox(
                    height: 36,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Notification button
                        if (AppDatabase.isInitialized)
                          Builder(
                            builder: (context) {
                              final pendingCount = vm.pendingAttachmentCount;
                              return GestureDetector(
                                onTap: () {
                                  if (pendingCount > 0) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          const ActionCenterSheet(),
                                    );
                                  } else {
                                    ToastHelper.showSuccess(context,
                                        UserStorage.l10n.noPendingActionsToast);
                                  }
                                },
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/notification_bell.svg',
                                          width: 19,
                                          height: 20,
                                        ),
                                      ),
                                      if (pendingCount > 0)
                                        Positioned(
                                          top: 6,
                                          left: 22,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF5B6CFF),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(width: 6),
                        // Companion character button (next to user avatar)
                        PersonaAvatarButton(
                          viewModel: widget.personaAvatarViewModel,
                          onTap: (character) => context.push(
                            '${AppRoutes.personaChat}/${character.id}',
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Avatar button
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  const PersonalCenterScreen(),
                            ).then((_) {
                              _checkPermissionBadge();
                              _checkFitnessBanner();
                              _loadUserAvatar();
                            });
                          },
                          child: Badge(
                            isLabelVisible: _showPermissionBadge,
                            smallSize: 10,
                            backgroundColor: Colors.red,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEEF2FF),
                              ),
                              child: CharacterAvatar(
                                avatar: _userAvatar ??
                                    UserStorage.defaultAvatarSeed,
                                name: '',
                                size: 32,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tag Chips (All + Insight + user tags)
            TimelineModelConfigBanner(
              onConfigureTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppConfig.enableMemexModelService
                        ? const AiServiceSetupPage()
                        : const ModelConfigListPage(),
                  ),
                );
              },
            ),
            if (_showFitnessBanner)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.92),
                        Colors.white.withValues(alpha: 0.82),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SystemAuthorizationPage(),
                            ),
                          ).then((_) {
                            _checkPermissionBadge();
                            _checkFitnessBanner();
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF34D399),
                                Color(0xFF10B981),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.favorite_rounded,
                              size: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SystemAuthorizationPage(),
                              ),
                            ).then((_) {
                              _checkPermissionBadge();
                              _checkFitnessBanner();
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                UserStorage.l10n.enableFitness,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                UserStorage.l10n.fitnessBannerMessage,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B)
                                      .withValues(alpha: 0.9),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _dismissFitnessBanner,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF94A3B8).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 36,
                child: _buildInlineTagChips(vm),
              ),
            ),

            // Content
            Expanded(
              child: NotificationListener<CardActionNotification>(
                onNotification: (notification) {
                  final action = notification.action;
                  if (action['action'] == 'filter_tag' &&
                      action['tag'] != null) {
                    vm.setActiveFilter(action['tag'] as String);
                    vm.setViewMode(action['tag'] == 'insight'
                        ? TimelineViewMode.insight
                        : TimelineViewMode.timeline);
                    if (action['tag'] == 'insight') {
                      unawaited(widget.insightViewModel.ensureLoaded());
                    }
                    final toastContext = context;
                    vm.loadCards(refresh: true).catchError((e) {
                      if (toastContext.mounted) {
                        ToastHelper.showError(toastContext, e);
                      }
                    });
                    // Also sync PageView
                    final pageIdx = _filterToPageIndex(vm);
                    _jumpToPage(pageIdx);
                    return true;
                  } else if (action['action'] == 'navigate_to_card' &&
                      action['card_id'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InsightDetailPage(id: action['card_id'] as String),
                      ),
                    );
                    return true;
                  } else if (action['action'] == 'refresh_timeline') {
                    vm.refresh();
                    return true;
                  } else if (action['action'] == 'delete_card' &&
                      action['card_id'] != null) {
                    vm.removeCardById(action['card_id'] as String);
                    return true;
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _totalPageCount(vm),
                  onPageChanged: (index) => _onPageChanged(index, vm),
                  itemBuilder: (context, index) {
                    if (index == 1) {
                      // Insight page
                      return _DeferredActivePage(
                        isActive: _currentPageIndex == 1,
                        builder: (_) => InsightScreen(
                          isEmbedded: true,
                          viewModel: widget.insightViewModel,
                        ),
                      );
                    }
                    // Timeline page (All or filtered by tag)
                    return _buildTimelineBody(vm);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInlineTagChips(TimelineViewModel vm) {
    return TimelineFilterBar(
      viewModel: vm,
      scrollController: _tagScrollController,
      onPageSelected: _jumpToPage,
      onInsightSelected: () {
        unawaited(widget.insightViewModel.ensureLoaded());
        DemoService.instance.tryAdvance(DemoStep.tapInsightTab);
      },
    );
  }

  Widget _buildTimelineBody(TimelineViewModel vm) {
    if ((vm.isLoading || vm.load.running) && vm.cards.isEmpty) {
      return const Center(child: AgentLogoLoading(size: 72));
    }

    return _buildTimelineContent(vm);
  }

  Widget _buildTimelineContent(TimelineViewModel vm) {
    if (vm.errorMessage != null) {
      return RefreshIndicator(
        onRefresh: () async {
          await vm.refresh();
          widget.onRefreshAction?.call();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off,
                      size: 48, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.loadCards(refresh: true),
                    child: Text(UserStorage.l10n.reload),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!AppDatabase.isInitialized) {
      return _buildTimelineList(vm);
    }

    if (vm.cards.isEmpty && (vm.isLoading || vm.load.running)) {
      return const Center(child: AgentLogoLoading(size: 72));
    }
    return _buildTimelineList(vm);
  }

  Widget _buildTimelineList(
    TimelineViewModel vm,
  ) {
    final entries = _buildTimelineFeedEntries(vm);

    if (entries.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await vm.refresh();
          widget.onRefreshAction?.call();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '📝',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    UserStorage.l10n.nothingHere,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    UserStorage.l10n.nothingHereHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFADB5BD),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await vm.refresh();
        widget.onRefreshAction?.call();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 220),
        cacheExtent: 400,
        itemCount: entries.length + (vm.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= entries.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final entry = entries[index];
          final card = entry.card;
          final isDemoTarget = DemoService.instance.isDemoTargetCardId(card.id);
          return TimelineEntryItem(
            key: ValueKey(card.id),
            card: card,
            isDemoTarget: isDemoTarget,
            attachments: vm.attachments[card.id] ?? const [],
            onTap: () async {
              final isDemoTapCardStep = isDemoTarget &&
                  DemoService.instance.currentStep == DemoStep.tapCard;
              if (isDemoTapCardStep) {
                DemoService.instance.suspendOverlay();
              }
              final Object? result;
              var shouldAdvanceDemo = false;
              try {
                result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimelineCardDetailScreen(
                      cardId: card.id,
                      showDemoHint: isDemoTapCardStep,
                    ),
                  ),
                );
                shouldAdvanceDemo = isDemoTapCardStep;
              } finally {
                if (isDemoTapCardStep && !shouldAdvanceDemo) {
                  DemoService.instance.resumeOverlay();
                }
              }
              if (!mounted) {
                if (isDemoTapCardStep) {
                  DemoService.instance.resumeOverlay();
                }
                return;
              }

              // Advance demo AFTER returning from detail screen so the
              // knowledgeTab spotlight measures the correct position.
              if (shouldAdvanceDemo) {
                DemoService.instance.tryAdvance(DemoStep.tapCard);
                DemoService.instance.resumeOverlay();
              }

              if (result == true) {
                vm.loadCards(refresh: true);
              } else if (result is Map &&
                  result['action'] == 'filter_tag' &&
                  result['tag'] != null) {
                vm.setActiveFilter(result['tag'] as String);
                vm.loadCards(refresh: true);
              }
            },
          );
        },
      ),
    );
  }

  List<_TimelineFeedEntry> _buildTimelineFeedEntries(
    TimelineViewModel vm,
  ) {
    final entries = <_TimelineFeedEntry>[
      for (var i = 0; i < vm.cards.length; i++)
        _TimelineFeedEntry(card: vm.cards[i]),
    ];
    return entries;
  }
}

class _TimelineFeedEntry {
  const _TimelineFeedEntry({
    required this.card,
  });

  final TimelineCardModel card;
}

/// Horizontal page/filter navigation for Timeline.
class TimelineFilterBar extends StatelessWidget {
  const TimelineFilterBar({
    super.key,
    required this.viewModel,
    required this.onPageSelected,
    required this.onInsightSelected,
    this.scrollController,
  });

  final TimelineViewModel viewModel;
  final ValueChanged<int> onPageSelected;
  final VoidCallback onInsightSelected;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final userTags = viewModel.tags;
    final totalCount = 2 + userTags.length;

    return ListView.separated(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20, right: 20),
      itemCount: totalCount,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildTagChip(
            label: UserStorage.l10n.timelineFilterAll,
            isSelected: viewModel.activeFilter == 'all' &&
                viewModel.viewMode == TimelineViewMode.timeline,
            onTap: () {
              viewModel.setViewMode(TimelineViewMode.timeline);
              viewModel.setActiveFilter('all');
              viewModel.loadCards(refresh: true);
              onPageSelected(0);
            },
          );
        }

        if (index == 1) {
          final chip = _buildTagChip(
            label: UserStorage.l10n.insights,
            isSelected: viewModel.viewMode == TimelineViewMode.insight,
            onTap: () {
              onPageSelected(1);
              viewModel.setViewMode(TimelineViewMode.insight);
              viewModel.setActiveFilter('insight');
              onInsightSelected();
            },
          );
          if (DemoService.instance.isActive) {
            return KeyedSubtree(
              key: DemoService.instance.insightTabKey,
              child: chip,
            );
          }
          return chip;
        }

        final tag = userTags[index - 2];
        return _buildTagChip(
          label: tag.name,
          isSelected: viewModel.activeFilter == tag.name &&
              viewModel.viewMode == TimelineViewMode.timeline,
          onTap: () {
            viewModel.setViewMode(TimelineViewMode.timeline);
            viewModel.setActiveFilter(tag.name);
            viewModel.loadCards(refresh: true);
            onPageSelected(index);
          },
        );
      },
    );
  }

  Widget _buildTagChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4A5565),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeferredActivePage extends StatefulWidget {
  const _DeferredActivePage({
    required this.isActive,
    required this.builder,
  });

  final bool isActive;
  final WidgetBuilder builder;

  @override
  State<_DeferredActivePage> createState() => _DeferredActivePageState();
}

class _DeferredActivePageState extends State<_DeferredActivePage> {
  bool _showChild = false;
  bool _isScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleMountIfActive();
  }

  @override
  void didUpdateWidget(covariant _DeferredActivePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleMountIfActive();
  }

  void _scheduleMountIfActive() {
    if (!widget.isActive || _showChild || _isScheduled) return;
    _isScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showChild = true;
        _isScheduled = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showChild) {
      return const Center(child: CircularProgressIndicator());
    }
    return widget.builder(context);
  }
}

class TimelineEntryItem extends StatefulWidget {
  final TimelineCardModel card;
  final VoidCallback onTap;
  final bool isDemoTarget;
  final List<CardAttachmentData> attachments;

  const TimelineEntryItem({
    super.key,
    required this.card,
    required this.onTap,
    required this.attachments,
    this.isDemoTarget = false,
  });

  @override
  State<TimelineEntryItem> createState() => _TimelineEntryItemState();
}

class _TimelineEntryItemState extends State<TimelineEntryItem> {
  bool _isClassicMode = false;

  void _toggleClassicMode() {
    setState(() {
      _isClassicMode = !_isClassicMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final onTap = widget.onTap;

    // Determine the template config list to display
    List<UiConfig> displayConfigs = [];

    if (_isClassicMode) {
      // Use classic_card template
      final audioAssets = card.assets?.where((a) => a.isAudio).toList() ?? [];
      displayConfigs.add(UiConfig(
        templateId: 'classic_card',
        data: <String, dynamic>{
          'content': card.rawText ?? '',
          'images':
              card.assets?.where((a) => a.isImage).map((a) => a.url).toList() ??
                  [],
          'audioUrl': audioAssets.isNotEmpty ? audioAssets.first.url : null,
          'tags': card.tags,
        },
      ));
    } else {
      // Use the original template config list
      displayConfigs = card.uiConfigs;
    }

    final isAlreadyClassic = card.uiConfigs.length == 1 &&
        card.uiConfigs.first.templateId == 'classic_card';

    final canToggleClassic = !isAlreadyClassic;

    // Check for single compact card
    bool isSingleCompactCard = false;
    if (displayConfigs.length == 1 && !_isClassicMode) {
      final config = displayConfigs.first;
      if (config.templateId == 'compact_card' ||
          config.templateId == 'compact') {
        isSingleCompactCard = true;
      }
    }

    if (isSingleCompactCard) {
      final config = displayConfigs.first;
      final content = Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: NativeCardFactory.build(
              status: card.status,
              templateId: config.templateId,
              data: config.data,
              title: card.title ?? '',
              tags: card.tags,
              onTap: onTap,
              cardId: card.id,
              configIndex: 0,
              failureReason: card.failureReason,
              onUpdate: (cardId, configIndex, data) {
                MemexRouter().updateCardUiConfig(cardId, configIndex, data);
              },
            ),
          ),
        ),
      );

      if (!AppDatabase.isInitialized) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimestampHeader(),
            content,
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimestampHeader(),
          content,
          ...widget.attachments.map((a) => Padding(
                key: ValueKey(a.id),
                padding: const EdgeInsets.only(bottom: 20),
                child: CardAttachmentFactory.build(a),
              )),
        ],
      );
    }

    final normalContent = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: canToggleClassic ? _toggleClassicMode : null,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Content Loop
            if (card.html != null && !_isClassicMode)
              HtmlWebViewCard(
                html: card.html!,
                config: const HtmlWebViewConfig.timeline(),
                onContentTap: onTap,
              )
            else if (displayConfigs.isNotEmpty)
              ...displayConfigs.asMap().entries.map((entry) {
                final index = entry.key;
                final config = entry.value;
                final isLast = index == displayConfigs.length - 1;

                if (config.templateId == 'legacy_html') {
                  final html = config.data['html'] as String?;
                  if (html != null && html.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
                      child: HtmlWebViewCard(
                        html: html,
                        config: const HtmlWebViewConfig.timeline(),
                        onContentTap: onTap,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final cardWidget = NativeCardFactory.build(
                  status: card.status,
                  templateId: config.templateId,
                  data: config.data,
                  title: card.title ?? '',
                  tags: card.tags,
                  onTap: onTap,
                  cardId: card.id,
                  configIndex: index,
                  overrideTitle: index == 0,
                  failureReason: card.failureReason,
                  onUpdate: (cardId, configIndex, data) {
                    MemexRouter().updateCardUiConfig(cardId, configIndex, data);
                  },
                );

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
                  child: (widget.isDemoTarget &&
                          index == 0 &&
                          DemoService.instance.currentStep == DemoStep.tapCard)
                      ? Container(
                          key: DemoService.instance.firstCardKey,
                          child: cardWidget,
                        )
                      : cardWidget,
                );
              })
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );

    if (!AppDatabase.isInitialized) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimestampHeader(),
          normalContent,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimestampHeader(),
        normalContent,
        ...widget.attachments.map((a) => Padding(
              key: ValueKey(a.id),
              padding: const EdgeInsets.only(bottom: 20),
              child: CardAttachmentFactory.build(a),
            )),
      ],
    );
  }

  Widget _buildTimestampHeader() {
    final card = widget.card;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Text(
            card.displayTime(UserStorage.l10n),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF99A1AF),
              letterSpacing: -0.15,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (card.status == 'processing' &&
                    card.uiConfigs.isNotEmpty &&
                    card.uiConfigs.first.templateId != 'classic_card') ...[
                  const Icon(Icons.auto_awesome_outlined,
                      size: 11, color: Color(0xFF99A1AF)),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      UserStorage.l10n.pendingAiProcessingHint,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF99A1AF),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ] else if (card.address != null &&
                    card.address!.isNotEmpty) ...[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      card.address!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8), // Using the requested color
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
