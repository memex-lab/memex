import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:provider/provider.dart';

import '../view_models/schedule_aggregator_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../timeline/widgets/timeline_card_detail_screen.dart';
import 'tabs/magazine_narrative_tab.dart';

/// Schedule Aggregator Screen - entry point with ViewModel
class ScheduleAggregatorScreen extends StatelessWidget {
  const ScheduleAggregatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleAggregatorViewModel(),
      child: const _ScheduleAggregatorScreenBody(),
    );
  }
}

class _ScheduleAggregatorScreenBody extends StatefulWidget {
  const _ScheduleAggregatorScreenBody();

  @override
  State<_ScheduleAggregatorScreenBody> createState() =>
      _ScheduleAggregatorScreenState();
}

class _ScheduleAggregatorScreenState
    extends State<_ScheduleAggregatorScreenBody>
    with WidgetsBindingObserver {
  DateTime _relativeDate = DateTime.now();
  Timer? _dayRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextDayRefresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleAggregatorViewModel>().ensureFresh();
    });
  }

  @override
  void dispose() {
    _dayRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _syncRelativeDate();
    _scheduleNextDayRefresh();
  }

  void _scheduleNextDayRefresh() {
    _dayRefreshTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    final delay = nextDay.difference(now) + const Duration(seconds: 1);
    _dayRefreshTimer = Timer(delay, () {
      if (!mounted) return;
      _syncRelativeDate();
      _scheduleNextDayRefresh();
    });
  }

  void _syncRelativeDate() {
    final now = DateTime.now();
    if (_relativeDate.year == now.year &&
        _relativeDate.month == now.month &&
        _relativeDate.day == now.day) {
      return;
    }
    setState(() {
      _relativeDate = now;
    });
  }

  void _navigateToCard(String cardId) {
    if (cardId.isEmpty || !_isFactCardId(cardId)) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimelineCardDetailScreen(cardId: cardId),
      ),
    );
  }

  bool _isFactCardId(String cardId) {
    return RegExp(r'^\d{4}/\d{2}/\d{2}\.md#ts_\d+$').hasMatch(cardId);
  }

  Future<void> _onReload() async {
    final vm = context.read<ScheduleAggregatorViewModel>();
    await vm.loadAggregation();
  }

  Future<void> _onUpdate() async {
    final vm = context.read<ScheduleAggregatorViewModel>();
    await vm.refreshAggregation();
  }

  void _toggleTaskCompletion(String itemId) {
    final vm = context.read<ScheduleAggregatorViewModel>();
    final index = vm.items.indexWhere((item) => item.itemId == itemId);
    if (index < 0) return;
    vm.toggleCompletion(vm.items[index]);
  }

  void _restoreCompletedTask(String itemId) {
    context.read<ScheduleAggregatorViewModel>().restoreCompletedItem(itemId);
  }

  void _toggleSubtask(String itemId, int subtaskIndex) {
    final vm = context.read<ScheduleAggregatorViewModel>();
    final index = vm.items.indexWhere((item) => item.itemId == itemId);
    if (index < 0) return;
    vm.toggleSubtask(vm.items[index], subtaskIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<ScheduleAggregatorViewModel>(
                builder: (context, vm, child) {
                  if (!vm.hasData && (!vm.hasLoaded || vm.isLoading)) {
                    return _buildRefreshableState(_buildLoadingState());
                  }
                  if (!vm.hasData) {
                    return _buildRefreshableState(_buildEmptyState(vm.error));
                  }

                  final items = vm.items;
                  final itemStatuses = {
                    for (final item in items) item.itemId: item.status,
                  };
                  final itemSubtasks = {
                    for (final item in items)
                      if (item.subtasks.isNotEmpty) item.itemId: item.subtasks,
                  };

                  return RefreshIndicator(
                    onRefresh: _onReload,
                    child: MagazineNarrativeTab(
                      aggregation: vm.aggregation!,
                      referenceDate: _relativeDate,
                      onTapCardId: _navigateToCard,
                      itemStatuses: itemStatuses,
                      onToggleTask: _toggleTaskCompletion,
                      onToggleCompletedTask: _restoreCompletedTask,
                      itemSubtasks: itemSubtasks,
                      onToggleSubtask: _toggleSubtask,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshableState(Widget child) {
    return RefreshIndicator(
      onRefresh: _onReload,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [SizedBox(height: constraints.maxHeight, child: child)],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              UserStorage.l10n.noScheduleAggregation,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? UserStorage.l10n.scheduleAggregationEmptyHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _onUpdate,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(UserStorage.l10n.update),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserStorage.l10n.schedule,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    color: AppColors.textPrimary,
                  ),
                ),
                Consumer<ScheduleAggregatorViewModel>(
                  builder: (context, vm, child) {
                    final label = _buildUpdatedSubtitle(vm);
                    if (label.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // AI refresh button
          Consumer<ScheduleAggregatorViewModel>(
            builder: (context, vm, child) {
              return GestureDetector(
                onTap: vm.isLoading ? null : _onUpdate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B6CFF), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B6CFF).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: vm.isRefreshing
                        ? [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              UserStorage.l10n.updating,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ]
                        : [
                            const Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              UserStorage.l10n.update,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _buildUpdatedSubtitle(ScheduleAggregatorViewModel vm) {
    final generatedAt = vm.aggregation?.generatedAt;
    if (generatedAt == null) return '';
    final time = DateFormat.Md(
      UserStorage.l10n.localeName,
    ).add_Hm().format(generatedAt);
    return UserStorage.l10n.scheduleBriefingUpdated(time);
  }
}
