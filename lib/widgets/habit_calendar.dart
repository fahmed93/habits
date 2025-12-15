import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/time_service.dart';
import '../screens/calendar_screen.dart';

class HabitCalendar extends StatefulWidget {
  final List<Habit> habits;
  final CalendarViewMode viewMode;

  const HabitCalendar({
    super.key,
    required this.habits,
    this.viewMode = CalendarViewMode.month,
  });

  @override
  State<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends State<HabitCalendar> {
  late DateTime _currentDate;
  final TimeService _timeService = TimeService();

  @override
  void initState() {
    super.initState();
    final now = _timeService.now();
    _currentDate = DateTime(now.year, now.month, 1);
  }

  void _previousPeriod() {
    setState(() {
      switch (widget.viewMode) {
        case CalendarViewMode.week:
          _currentDate = _currentDate.subtract(const Duration(days: 7));
          break;
        case CalendarViewMode.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
          break;
        case CalendarViewMode.year:
          _currentDate = DateTime(_currentDate.year - 1, 1, 1);
          break;
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      switch (widget.viewMode) {
        case CalendarViewMode.week:
          _currentDate = _currentDate.add(const Duration(days: 7));
          break;
        case CalendarViewMode.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
          break;
        case CalendarViewMode.year:
          _currentDate = DateTime(_currentDate.year + 1, 1, 1);
          break;
      }
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

  List<Widget> _buildMonthCalendarDays(BuildContext context) {
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
        DateTime(_currentDate.year, _currentDate.month, 1);
    final daysInMonth =
        DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    // Empty cells for days before the first day of the month
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Calendar days
    final now = _timeService.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentDate.year, _currentDate.month, day);
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

  List<Widget> _buildWeekCalendarDays(BuildContext context) {
    final List<Widget> dayWidgets = [];
    final now = _timeService.now();
    final today = DateTime(now.year, now.month, now.day);

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

    // Find the start of the week (Sunday)
    final currentWeekday = _currentDate.weekday % 7;
    final weekStart = _currentDate.subtract(Duration(days: currentWeekday));

    // Build 7 days of the week
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final completedHabits = _getCompletedHabits(date);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isFuture = date.isAfter(today);

      dayWidgets.add(
        _CalendarDay(
          day: date.day,
          completedHabits: completedHabits,
          totalHabits: widget.habits.length,
          isToday: isToday,
          isFuture: isFuture,
        ),
      );
    }

    return dayWidgets;
  }

  Widget _buildYearView(BuildContext context) {
    final months = [
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthDate = DateTime(_currentDate.year, index + 1, 1);
        return _buildMiniMonth(context, monthDate, months[index]);
      },
    );
  }

  Widget _buildMiniMonth(BuildContext context, DateTime monthDate, String monthName) {
    final now = _timeService.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    
    int completedDaysCount = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(monthDate.year, monthDate.month, day);
      if (!date.isAfter(today)) {
        final completed = _getCompletedHabits(date);
        if (completed.isNotEmpty) {
          completedDaysCount++;
        }
      }
    }

    final activeDays = monthDate.month == now.month && monthDate.year == now.year
        ? now.day
        : (monthDate.isAfter(today) ? 0 : daysInMonth);
    final completionRate = activeDays > 0 ? (completedDaysCount / activeDays) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              monthName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(completionRate * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: completionRate > 0.7
                    ? Colors.green
                    : completionRate > 0.4
                        ? Colors.orange
                        : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$completedDaysCount/$activeDays days',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHeaderText() {
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

    switch (widget.viewMode) {
      case CalendarViewMode.week:
        final currentWeekday = _currentDate.weekday % 7;
        final weekStart = _currentDate.subtract(Duration(days: currentWeekday));
        final weekEnd = weekStart.add(const Duration(days: 6));
        if (weekStart.month == weekEnd.month) {
          return '${months[weekStart.month - 1]} ${weekStart.day}-${weekEnd.day}, ${weekStart.year}';
        } else {
          return '${months[weekStart.month - 1]} ${weekStart.day} - ${months[weekEnd.month - 1]} ${weekEnd.day}, ${weekStart.year}';
        }
      case CalendarViewMode.month:
        return '${months[_currentDate.month - 1]} ${_currentDate.year}';
      case CalendarViewMode.year:
        return '${_currentDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousPeriod,
                    tooltip: widget.viewMode == CalendarViewMode.week
                        ? 'Previous week'
                        : widget.viewMode == CalendarViewMode.month
                            ? 'Previous month'
                            : 'Previous year',
                  ),
                  Text(
                    _getHeaderText(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextPeriod,
                    tooltip: widget.viewMode == CalendarViewMode.week
                        ? 'Next week'
                        : widget.viewMode == CalendarViewMode.month
                            ? 'Next month'
                            : 'Next year',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Calendar content
              if (widget.viewMode == CalendarViewMode.year)
                _buildYearView(context)
              else
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: widget.viewMode == CalendarViewMode.week
                      ? _buildWeekCalendarDays(context)
                      : _buildMonthCalendarDays(context),
                ),
              const SizedBox(height: 12),
              // Legend
              if (widget.viewMode != CalendarViewMode.year) _buildLegend(context),
            ],
          ),
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
    
    // Get the background color - use habit color if completed, otherwise transparent
    final backgroundColor = !isFuture && habitColors.isNotEmpty
        ? habitColors.first
        : Colors.transparent;
    
    // Determine text color based on background brightness
    final textColor = !isFuture && habitColors.isNotEmpty
        ? _getContrastColor(backgroundColor)
        : isFuture
            ? Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withOpacity(0.5)
            : Theme.of(context).colorScheme.onSurface;

    return Tooltip(
      message: isFuture
          ? ''
          : completionCount == 0
              ? 'No completions'
              : completedHabits.map((h) => h.name).join(", "),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
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
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Determines whether to use light or dark text based on background color brightness
  Color _getContrastColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    // Use white text for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
