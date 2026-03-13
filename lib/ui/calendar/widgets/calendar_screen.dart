import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:memex/ui/calendar/view_models/calendar_viewmodel.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';

/// Calendar screen. Receives [viewModel] from parent (Compass-style).
class CalendarScreen extends StatefulWidget {
  final DateTime initialDate;
  final CalendarViewModel viewModel;

  const CalendarScreen({
    super.key,
    required this.initialDate,
    required this.viewModel,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          DateFormat.yMMM(UserStorage.l10n.localeName).format(vm.focusedMonth),
          style:
              const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF64748B)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int pageIndex) {
                const initialPage = 1000;
                final monthDiff = pageIndex - initialPage;
                final newMonth = DateTime(
                    widget.initialDate.year, widget.initialDate.month + monthDiff);
                vm.setFocusedMonth(newMonth);
                vm.fetchMonthData(newMonth);
              },
              itemBuilder: (context, index) {
                const initialPage = 1000;
                final monthDiff = index - initialPage;
                final month = DateTime(
                    widget.initialDate.year, widget.initialDate.month + monthDiff);
                return _buildMonthGrid(context, vm, month);
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildDayList(context, vm),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildCalendarHeader() {
    final days = [
      UserStorage.l10n.calendarShortSun,
      UserStorage.l10n.calendarShortMon,
      UserStorage.l10n.calendarShortTue,
      UserStorage.l10n.calendarShortWed,
      UserStorage.l10n.calendarShortThu,
      UserStorage.l10n.calendarShortFri,
      UserStorage.l10n.calendarShortSat,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map((e) => Text(
                  e,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMonthGrid(
      BuildContext context, CalendarViewModel vm, DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayWeekday = DateTime(month.year, month.month, 1).weekday;
    final firstDayIndex = firstDayWeekday == 7 ? 0 : firstDayWeekday;
    final totalSlots = daysInMonth + firstDayIndex;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
      ),
      itemCount: totalSlots,
      itemBuilder: (context, index) {
        if (index < firstDayIndex) {
          return const SizedBox.shrink();
        }
        final day = index - firstDayIndex + 1;
        final date = DateTime(month.year, month.month, day);
        return _buildDayCell(vm, date);
      },
    );
  }

  Widget _buildDayCell(CalendarViewModel vm, DateTime date) {
    final isSelected = date.year == vm.selectedDate.year &&
        date.month == vm.selectedDate.month &&
        date.day == vm.selectedDate.day;
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final count = vm.getCardCountForDay(date);
    final hasData = count > 0;

    return GestureDetector(
      onTap: () => vm.setSelectedDate(date),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : (hasData ? const Color(0xFFE0E7FF) : null),
                  shape: BoxShape.circle,
                  border: isToday && !isSelected
                      ? Border.all(color: const Color(0xFF6366F1))
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (hasData
                            ? const Color(0xFF4338CA)
                            : (date.weekday >= 6 ? const Color(0xFF94A3B8) : const Color(0xFF0F172A))),
                    fontWeight:
                        isSelected || isToday || hasData
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ),
              if (hasData)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 10,
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayList(BuildContext context, CalendarViewModel vm) {
    final cards = vm.getSelectedDayCards();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              UserStorage.l10n.noRecordsOnDate(
                DateFormat.MMMd(UserStorage.l10n.localeName).format(vm.selectedDate),
              ),
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final time = DateTime.fromMillisecondsSinceEpoch(card.timestamp * 1000)
            .toLocal();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimelineCardDetailScreen(cardId: card.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('HH:mm').format(time),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...card.tags.map((tag) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFF64748B)),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (card.location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            card.location,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
