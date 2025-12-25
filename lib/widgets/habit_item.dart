import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/time_service.dart';

class HabitItem extends StatefulWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final Function(DateTime)? onToggleDate; // New callback for toggling specific dates

  const HabitItem({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
    this.onToggleDate,
  });

  @override
  State<HabitItem> createState() => _HabitItemState();
}

class _HabitItemState extends State<HabitItem> {

  bool _isCompletedToday() {
    final now = TimeService().now();
    final today = DateTime(now.year, now.month, now.day);
    return widget.habit.completions.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  bool _isCompletedOnDate(DateTime date) {
    return widget.habit.completions.any((completion) =>
        completion.year == date.year &&
        completion.month == date.month &&
        completion.day == date.day);
  }

  List<DateTime> _getLast5DaysFrom(DateTime today) {
    // Generate last 5 days, with today on the right (index 4)
    return List.generate(5, (index) {
      return today.subtract(Duration(days: 4 - index));
    });
  }

  int _getCurrentStreak() {
    if (widget.habit.completions.isEmpty) return 0;

    final sortedCompletions = List<DateTime>.from(widget.habit.completions)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    final now = TimeService().now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    for (var completion in sortedCompletions) {
      final completionDate =
          DateTime(completion.year, completion.month, completion.day);

      if (completionDate == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (completionDate.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  String _getStreakUnitDisplay(int streak, String interval) {
    String unit;
    switch (interval) {
      case 'daily':
        unit = 'day';
        break;
      case 'weekly':
        unit = 'week';
        break;
      case 'monthly':
        unit = 'month';
        break;
      default:
        unit = 'day';
    }
    return '$streak $unit${streak > 1 ? 's' : ''}';
  }

  Widget _buildDayIndicator(DateTime date, bool isToday, BuildContext context) {
    final isCompleted = _isCompletedOnDate(date);
    // DateTime.weekday: Monday=1, Tuesday=2, ..., Sunday=7
    // We need: Sunday=0, Monday=1, ..., Saturday=6 for array indexing
    final dayIndex = date.weekday % 7;  // This converts Sunday(7) to 0, Monday(1) to 1, etc.
    final dayOfWeek = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][dayIndex];
    
    // Use fixed size for all squares to maintain alignment
    const size = 40.0;
    
    return GestureDetector(
      onTap: () {
        if (widget.onToggleDate != null) {
          widget.onToggleDate!(date);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: size,
        height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isCompleted 
                ? Color(widget.habit.colorValue)
                : Theme.of(context).colorScheme.surfaceVariant,
            border: Border.all(
              color: isToday 
                  ? Color(widget.habit.colorValue) 
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: Color(widget.habit.colorValue).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: isToday ? 24.0 : 20.0,
                )
              : Text(
                  dayOfWeek,
                  style: TextStyle(
                    fontSize: isToday ? 10.0 : 9.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
    );
  }

  List<Widget> _buildDayIndicators(DateTime today, BuildContext context) {
    final last5Days = _getLast5DaysFrom(today);
    
    return List.generate(last5Days.length, (i) {
      final date = last5Days[i];
      final isToday = date.year == today.year &&
                     date.month == today.month &&
                     date.day == today.day;
      return Expanded(
        child: Align(
          alignment: Alignment.center,
          child: _buildDayIndicator(date, isToday, context),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeService().now();
    final today = DateTime(now.year, now.month, now.day);
    final isCompleted = _isCompletedToday();
    final streak = _getCurrentStreak();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      elevation: 1,
      shadowColor: Color(widget.habit.colorValue).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.none,
      child: Dismissible(
          key: Key(widget.habit.id),
          direction: DismissDirection.horizontal,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Edit action - don't dismiss, just trigger edit
              if (widget.onEdit != null) {
                widget.onEdit!();
              }
              return false;
            } else if (direction == DismissDirection.endToStart) {
              // Delete action - show confirmation dialog
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Delete Habit'),
                    content: const Text('Are you sure you want to delete this habit?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            }
            return false;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              widget.onDelete();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Icon and Name
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon with gradient background
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(widget.habit.colorValue),
                                Color(widget.habit.colorValue).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(widget.habit.colorValue).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.habit.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Habit name
                            Expanded(
                              child: Text(
                                widget.habit.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  decorationThickness: 2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Streak badge
                            if (streak > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '🔥',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      _getStreakUnitDisplay(streak, widget.habit.interval),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right side: 5-day completion view
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        // Day indicators
                        Row(
                          children: _buildDayIndicators(today, context),
                        ),
                        // Vertical dividers between columns
                        Positioned.fill(
                          child: OverflowBox(
                            maxHeight: double.infinity,
                            child: Row(
                              children: List.generate(4, (i) {
                                return Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: 1,
                                      // Use screen height * 3 to ensure dividers connect even on tall screens
                                      height: MediaQuery.of(context).size.height * 3,
                                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                                    ),
                                  ),
                                );
                              })..add(const Expanded(child: SizedBox())), // Last column has no divider
                            ),
                          ),
                        ),
                      ],
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
