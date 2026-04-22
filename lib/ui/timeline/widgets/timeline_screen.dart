import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/ui/agent_activity/widgets/system_action_card.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/ui/core/widgets/html_webview_card.dart';
import 'package:memex/ui/main_screen/widgets/action_center_sheet.dart';

import 'package:memex/ui/core/cards/native_card_factory.dart';
import 'package:memex/data/services/demo_service.dart';
import 'package:memex/ui/core/cards/card_action_notification.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';
import 'package:memex/ui/settings/widgets/personal_center_screen.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/insight/widgets/insight_screen.dart';
import 'package:memex/ui/insight/widgets/insight_detail_page.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/permission_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/ui/settings/widgets/system_authorization_page.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/core/widgets/dicebear_avatar.dart';
import 'package:memex/ui/character/widgets/persona_avatar_button.dart';

/// Timeline screen - main memory view. Receives [viewModel] and [insightViewModel] from parent (Compass-style).
class TimelineScreen extends StatefulWidget {
  final TimelineViewModel viewModel;
  final InsightViewModel insightViewModel;
  final VoidCallback onInputTap;
  final VoidCallback? onRefreshAction;

  const TimelineScreen({
    super.key,
    required this.viewModel,
    required this.insightViewModel,
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
  bool _showModelConfigBanner = false;
  bool _showFitnessBanner = false;
  late PageController _pageController;
  int _currentPageIndex = 0;
  final ScrollController _tagScrollController = ScrollController();

  /// Show loading indicator for submission (called from main screen).
  void showLoading() {
    if (!mounted) return;
    widget.viewModel.setSubmitting(true);
  }

  /// Hide loading indicator (called from main screen).
  void hideLoading() {
    if (!mounted) return;
    widget.viewModel.setSubmitting(false);
  }

  /// Add a new card to the top (called from main screen after submit).
  void addCard(TimelineCardModel card) {
    if (!mounted) return;
    widget.viewModel.addCard(card);
  }

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

  void _showChatDialog(TimelineViewModel vm) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        if (vm.viewMode == TimelineViewMode.insight) {
          return AgentChatDialog(
            agentName: 'knowledge_insight_agent',
            title: UserStorage.l10n.insightAssistant,
            inputHint: UserStorage.l10n.insightInputHint,
            scene: 'insight_card_chat',
            sceneId: 'general_insight_chat',
            initialRefs: const [],
          );
        }
        return AgentChatDialog(
          agentName: 'memex_agent',
          title: UserStorage.l10n.aiAssistant,
          inputHint: UserStorage.l10n.aiInputHint,
          scene: 'assistant_home',
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController.addListener(_onScroll);
    _checkPermissionBadge();
    _loadUserAvatar();
    _checkModelConfig();
    _checkFitnessBanner();
  }

  Future<void> _checkModelConfig() async {
    final configs = await UserStorage.getLLMConfigs();
    final hasValid = configs.any((c) => c.isValid);
    if (mounted && !hasValid != _showModelConfigBanner) {
      setState(() => _showModelConfigBanner = !hasValid);
    }
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
    final avatar = await UserStorage.getUserAvatar();
    if (mounted && avatar != null) {
      setState(() => _userAvatar = avatar);
    }
  }

  @override
  void dispose() {
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

  /// Called when user taps a tag chip — animate PageView to that page.
  void _animateToPage(int index) {
    _currentPageIndex = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _scrollTagIntoView(index, widget.viewModel);
  }

  /// Check if a card is a system_task created by a custom agent.
  bool _isCustomAgentSystemTask(TimelineCardModel card) {
    if (card.uiConfigs.isEmpty) return false;
    final config = card.uiConfigs.first;
    return config.templateId == 'system_task' &&
        config.data['agentName'] != null &&
        config.data['sessionId'] != null;
  }

  /// Open AgentChatDialog for a custom agent system_task card.
  void _openCustomAgentChat(TimelineCardModel card) {
    final config = card.uiConfigs.first;
    final agentName = config.data['agentName'] as String;
    final sessionId = config.data['sessionId'] as String;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AgentChatDialog(
          agentName: agentName,
          title: agentName,
          initialSessionId: sessionId,
          inputHint: UserStorage.l10n.aiInputHint,
          scene: 'custom_agent_$agentName',
        );
      },
    );
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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Meme',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.41,
                            height: 22 / 32,
                            color: const Color(0xFF0A0A0A),
                          ),
                        ),
                        TextSpan(
                          text: 'x',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.41,
                            height: 22 / 32,
                            color: const Color(0xFF5B6CFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 4 buttons: chat, notification, companion, user avatar
                  SizedBox(
                    height: 36,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Chat button
                        GestureDetector(
                          onTap: () => _showChatDialog(vm),
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/chat_add.svg',
                                width: 22,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Notification button
                        if (AppDatabase.isInitialized)
                          StreamBuilder<List<SystemAction>>(
                            stream: (AppDatabase.instance
                                    .select(AppDatabase.instance.systemActions)
                                  ..where((t) => t.status.equals('pending')))
                                .watch(),
                            builder: (context, snapshot) {
                              final pendingCount = snapshot.data?.length ?? 0;
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
                        const PersonaAvatarButton(),
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
                              child: DiceBearAvatar(
                                seed: _userAvatar ??
                                    UserStorage.defaultAvatarSeed,
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
            if (_showModelConfigBanner)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ModelConfigListPage(),
                      ),
                    ).then((_) => _checkModelConfig());
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.72),
                              Colors.white.withOpacity(0.48),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF818CF8),
                                    Color(0xFF6366F1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.auto_awesome,
                                  size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    UserStorage.l10n.configureNow,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    UserStorage.l10n.modelNotConfiguredBanner,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B)
                                          .withOpacity(0.9),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward_ios,
                                  size: 12, color: Color(0xFF6366F1)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_showFitnessBanner)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.72),
                            Colors.white.withOpacity(0.48),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.08),
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
                                          .withOpacity(0.9),
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
                                color: const Color(0xFF94A3B8).withOpacity(0.1),
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
                ),
              ),
            if (vm.tags.isNotEmpty)
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
                    vm.loadCards(refresh: true).catchError((e) {
                      if (mounted) ToastHelper.showError(context, e);
                    });
                    // Also sync PageView
                    final pageIdx = _filterToPageIndex(vm);
                    _animateToPage(pageIdx);
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
                      return InsightScreen(
                        isEmbedded: true,
                        viewModel: widget.insightViewModel,
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
    if (vm.tags.isEmpty) return const SizedBox.shrink();

    final userTags = vm.tags;
    // Items: All(0) + Insight(1) + user tags(2..)
    final totalCount = 2 + userTags.length;

    return ListView.separated(
      controller: _tagScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20, right: 20),
      itemCount: totalCount,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        // Index 0: "All"
        if (index == 0) {
          final isSelected = vm.activeFilter == 'all' &&
              vm.viewMode == TimelineViewMode.timeline;
          return _buildTagChip(
            label: UserStorage.l10n.timelineFilterAll,
            isSelected: isSelected,
            onTap: () {
              vm.setViewMode(TimelineViewMode.timeline);
              vm.setActiveFilter('all');
              vm.loadCards(refresh: true);
              _animateToPage(0);
            },
          );
        }

        // Index 1: "Insight"
        if (index == 1) {
          final isSelected = vm.viewMode == TimelineViewMode.insight;
          final chip = _buildTagChip(
            label: UserStorage.l10n.insights,
            icon: '✨',
            isSelected: isSelected,
            onTap: () {
              vm.setViewMode(TimelineViewMode.insight);
              vm.setActiveFilter('insight');
              _animateToPage(1);
              DemoService.instance.tryAdvance(DemoStep.tapInsightTab);
            },
          );
          // Only attach the demo GlobalKey when the demo is active,
          // to avoid duplicate-key crashes during normal tab switching.
          if (DemoService.instance.isActive) {
            return KeyedSubtree(
                key: DemoService.instance.insightTabKey, child: chip);
          }
          return chip;
        }

        // Index 2+: user tags
        final tag = userTags[index - 2];
        final isSelected = vm.activeFilter == tag.name &&
            vm.viewMode == TimelineViewMode.timeline;
        return _buildTagChip(
          label: tag.name,
          icon: tag.icon,
          isSelected: isSelected,
          onTap: () {
            vm.setViewMode(TimelineViewMode.timeline);
            vm.setActiveFilter(tag.name);
            vm.loadCards(refresh: true);
            _animateToPage(index);
          },
        );
      },
    );
  }

  Widget _buildTagChip({
    required String label,
    String? icon,
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

  Widget _buildTimelineBody(TimelineViewModel vm) {
    if ((vm.isLoading || vm.load.running) && vm.cards.isEmpty) {
      return Center(child: AgentLogoLoading());
    }

    if (vm.isSubmitting) {
      if (vm.cards.isEmpty) {
        return Center(child: AgentLogoLoading());
      } else {
        return Stack(
          children: [
            _buildTimelineContent(vm),
            Container(
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: AgentLogoLoading(),
              ),
            ),
          ],
        );
      }
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

    if (vm.cards.isEmpty) {
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        cacheExtent: 400,
        itemCount: vm.cards.length + (vm.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= vm.cards.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final card = vm.cards[index];
          return _TimelineEntryItem(
            card: card,
            isDemoTarget: index == 0,
            onTap: () async {
              // If this is a custom agent system_task card, open chat dialog.
              if (_isCustomAgentSystemTask(card)) {
                _openCustomAgentChat(card);
                return;
              }
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TimelineCardDetailScreen(cardId: card.id),
                ),
              );
              if (!mounted) return;

              // Advance demo AFTER returning from detail screen so the
              // knowledgeTab spotlight measures the correct position.
              if (index == 0) {
                DemoService.instance.tryAdvance(DemoStep.tapCard);
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
}

class _TimelineEntryItem extends StatefulWidget {
  final TimelineCardModel card;
  final VoidCallback onTap;
  final bool isDemoTarget;

  const _TimelineEntryItem({
    super.key,
    required this.card,
    required this.onTap,
    this.isDemoTarget = false,
  });

  @override
  State<_TimelineEntryItem> createState() => _TimelineEntryItemState();
}

class _TimelineEntryItemState extends State<_TimelineEntryItem> {
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

      return StreamBuilder<List<SystemAction>>(
        stream: (AppDatabase.instance.select(AppDatabase.instance.systemActions)
              ..where((t) => t.factId.equals(card.id)))
            .watch(),
        builder: (context, snapshot) {
          // Filter to only show actionable or completed UI (hide rejected)
          final actions = (snapshot.data ?? [])
              .where((a) => a.status != 'rejected')
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimestampHeader(),
              content,
              if (actions.isNotEmpty)
                ...actions.map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SystemActionCard(
                        action: action,
                        service: SystemActionService.instance,
                      ),
                    )),
            ],
          );
        },
      );
    }

    final normalContent = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: isAlreadyClassic ? null : _toggleClassicMode,
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
                          DemoService.instance.isActive)
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

    return StreamBuilder<List<SystemAction>>(
      stream: (AppDatabase.instance.select(AppDatabase.instance.systemActions)
            ..where((t) => t.factId.equals(card.id)))
          .watch(),
      builder: (context, snapshot) {
        // Filter to only show actionable or completed UI (hide rejected)
        final actions =
            (snapshot.data ?? []).where((a) => a.status != 'rejected').toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimestampHeader(),
            normalContent,
            if (actions.isNotEmpty)
              ...actions.map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SystemActionCard(
                      action: action,
                      service: SystemActionService.instance,
                    ),
                  )),
          ],
        );
      },
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
