import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/time_service.dart';

class HabitCalendar extends StatefulWidget {
  final List<Habit> habits;

  const HabitCalendar({super.key, required this.habits});

  @override
  State<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends State<HabitCalendar> {
  late DateTime _currentMonth;
  final TimeService _timeService = TimeService();

  @override
  void initState() {
    super.initState();
    final now = _timeService.now();
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  /// Returns the list of habits completed on a given date
  List<Habit> _getCompletedHabits(DateTime date) {
    final List<Habit> completedHabits = [];
    for (var habit in widget.habits) {
      for (var completion in habit.completions) {
        if (completion.year == date.year &&
            completion.month == date.month &&
            completion.day == date.day) {
          completedHabits.add(habit);
          break; // Count each habit only once per day
        }
      }
    }
    return completedHabits;
  }

  List<Widget> _buildCalendarDays(BuildContext context) {
    final List<Widget> dayWidgets = [];

    // Day of week headers
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (var dayName in dayNames) {
      dayWidgets.add(
        Center(
          child: Text(
            dayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // First day of the month and number of days
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    // Empty cells for days before the first day of the month
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Calendar days
    final now = _timeService.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final completedHabits = _getCompletedHabits(date);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isFuture = date.isAfter(today);

      dayWidgets.add(
        _CalendarDay(
          day: day,
          completedHabits: completedHabits,
          totalHabits: widget.habits.length,
          isToday: isToday,
          isFuture: isFuture,
        ),
      );
    }

    return dayWidgets;
  }

  String _getMonthYearText() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                  tooltip: 'Previous month',
                ),
                Text(
                  _getMonthYearText(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                  tooltip: 'Next month',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Calendar grid
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1,
              children: _buildCalendarDays(context),
            ),
            const SizedBox(height: 12),
            // Legend
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    if (widget.habits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: widget.habits.map((habit) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Color(habit.colorValue),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              habit.name,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final List<Habit> completedHabits;
  final int totalHabits;
  final bool isToday;
  final bool isFuture;

  const _CalendarDay({
    required this.day,
    required this.completedHabits,
    required this.totalHabits,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final completionCount = completedHabits.length;
    final habitColors =
        completedHabits.map((h) => Color(h.colorValue)).toList();

    return Tooltip(
      message: isFuture
          ? ''
          : completionCount == 0
              ? 'No completions'
              : completedHabits.map((h) => h.name).join(", "),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 0.5,
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isFuture
                    ? Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (!isFuture && habitColors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildColorDots(habitColors),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildColorDots(List<Color> colors) {
    // Show up to 4 dots, if more show "+" indicator
    const maxDots = 4;
    final displayColors = colors.take(maxDots).toList();
    final hasMore = colors.length > maxDots;

    return [
      ...displayColors.map((color) => Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          )),
      if (hasMore)
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          child: const Center(
            child: Text(
              '+',
              style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold),
            ),
          ),
        ),
    ];
  }
}
