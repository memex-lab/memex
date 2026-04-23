import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/schedule_mock_data.dart';
import '../models/schedule_item.dart';
import '../view_models/schedule_aggregator_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_shadows.dart';
import 'schedule_detail_screen.dart';
import 'tabs/daily_focus_tab.dart';
import 'tabs/weekly_overview_tab.dart';
import 'tabs/smart_agenda_tab.dart';
import 'tabs/adaptive_cards_tab.dart';
import 'tabs/conversational_briefing_tab.dart';
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
    with TickerProviderStateMixin {
  late TabController _tabController;

  // State for each interaction's data
  late List<ScheduleItem> _dailyFocusItems;
  late List<ScheduleItem> _weeklyItems;
  late List<ScheduleItem> _smartAgendaItems;
  late List<ScheduleItem> _adaptiveItems;
  late List<ScheduleItem> _conversationalItems;
  late List<ScheduleItem> _magazineItems;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _dailyFocusItems = ScheduleMockData.dailyFocusData;
    _weeklyItems = ScheduleMockData.weeklyOverviewData;
    _smartAgendaItems = ScheduleMockData.smartAgendaData;
    _adaptiveItems = ScheduleMockData.adaptiveCardData;
    _conversationalItems = ScheduleMockData.conversationalData;
    _magazineItems = ScheduleMockData.magazineData;

    // Load real aggregation data in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleAggregatorViewModel>().ensureFresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleTodoCompletion(List<ScheduleItem> items, int index,
      void Function(List<ScheduleItem>) onUpdate) {
    final item = items[index];
    if (item.type != ScheduleItemType.todo) return;

    final newStatus = item.status == ScheduleItemStatus.completed
        ? ScheduleItemStatus.pending
        : ScheduleItemStatus.completed;

    final newItems = List<ScheduleItem>.from(items);
    newItems[index] = item.copyWith(
      status: newStatus,
      completedAt:
          newStatus == ScheduleItemStatus.completed ? DateTime.now() : null,
    );
    onUpdate(newItems);
  }

  void _navigateToDetail(ScheduleItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleDetailScreen(item: item),
      ),
    );
  }

  Future<void> _onRefresh() async {
    final vm = context.read<ScheduleAggregatorViewModel>();
    await vm.refreshAggregation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Tab Bar
            _buildTabBar(),
            // Tab Content
            Expanded(
              child: Consumer<ScheduleAggregatorViewModel>(
                builder: (context, vm, child) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      DailyFocusTab(
                        items: _dailyFocusItems,
                        onToggle: (index) => _toggleTodoCompletion(
                          _dailyFocusItems,
                          index,
                          (newItems) =>
                              setState(() => _dailyFocusItems = newItems),
                        ),
                        onTapItem: _navigateToDetail,
                      ),
                      WeeklyOverviewTab(
                        items: _weeklyItems,
                        onToggle: (index) => _toggleTodoCompletion(
                          _weeklyItems,
                          index,
                          (newItems) =>
                              setState(() => _weeklyItems = newItems),
                        ),
                        onTapItem: _navigateToDetail,
                      ),
                      SmartAgendaTab(
                        items: _smartAgendaItems,
                        onToggle: (index) => _toggleTodoCompletion(
                          _smartAgendaItems,
                          index,
                          (newItems) =>
                              setState(() => _smartAgendaItems = newItems),
                        ),
                        onTapItem: _navigateToDetail,
                      ),
                      AdaptiveCardsTab(
                        items: _adaptiveItems,
                        onToggle: (index) => _toggleTodoCompletion(
                          _adaptiveItems,
                          index,
                          (newItems) =>
                              setState(() => _adaptiveItems = newItems),
                        ),
                        onTapItem: _navigateToDetail,
                      ),
                      ConversationalBriefingTab(
                        items: _conversationalItems,
                        onTapItem: _navigateToDetail,
                      ),
                      MagazineNarrativeTab(
                        items: _magazineItems,
                        aggregation: vm.aggregation,
                        onToggle: (index) => _toggleTodoCompletion(
                          _magazineItems,
                          index,
                          (newItems) =>
                              setState(() => _magazineItems = newItems),
                        ),
                        onTapItem: _navigateToDetail,
                        onTapCardId: (cardId) {
                          // TODO: Navigate to card detail by factId
                          debugPrint('Tapped card: $cardId');
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '日程聚合',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.41,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _buildDateSubtitle(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // AI refresh button
          Consumer<ScheduleAggregatorViewModel>(
            builder: (context, vm, child) {
              return GestureDetector(
                onTap: vm.isLoading ? null : _onRefresh,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B6CFF), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B6CFF).withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: vm.isLoading
                        ? [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '生成中...',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ]
                        : [
                            const Icon(Icons.auto_awesome,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'AI 生成',
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

  String _buildDateSubtitle() {
    final now = DateTime.now();
    final weekdays = [
      '周日',
      '周一',
      '周二',
      '周三',
      '周四',
      '周五',
      '周六'
    ];
    return '${now.year}年${now.month}月${now.day}日 ${weekdays[now.weekday % 7]}';
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppShadows.card],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B6CFF), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: '日程一'),
          Tab(text: '日程二'),
          Tab(text: '日程三'),
          Tab(text: '日程四'),
          Tab(text: '日程五'),
          Tab(text: '日程六'),
        ],
      ),
    );
  }
}
