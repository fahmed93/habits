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

class _HabitItemState extends State<HabitItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  String _getIntervalDisplay() {
    switch (widget.habit.interval) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return widget.habit.interval;
    }
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

  Widget _buildDayIndicator(DateTime date, bool isToday, BuildContext context) {
    final isCompleted = _isCompletedOnDate(date);
    final dayOfWeek = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][date.weekday % 7];
    final monthDay = '${date.month}/${date.day}';
    
    return GestureDetector(
      onTap: () {
        if (widget.onToggleDate != null) {
          widget.onToggleDate!(date);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayOfWeek,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                color: isToday 
                    ? Color(widget.habit.colorValue) 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
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
                      size: 24,
                    )
                  : Text(
                      monthDay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDayIndicators(DateTime today, BuildContext context) {
    final last5Days = _getLast5DaysFrom(today);
    
    return last5Days.map((date) {
      final isToday = date.year == today.year &&
                     date.month == today.month &&
                     date.day == today.day;
      return _buildDayIndicator(date, isToday, context);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeService().now();
    final today = DateTime(now.year, now.month, now.day);
    final isCompleted = _isCompletedToday();
    final streak = _getCurrentStreak();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shadowColor: Color(widget.habit.colorValue).withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Dismissible(
          key: Key(widget.habit.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          confirmDismiss: (direction) async {
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
          },
          onDismissed: (direction) => widget.onDelete(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Icon with gradient background
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(widget.habit.colorValue),
                              Color(widget.habit.colorValue).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(widget.habit.colorValue).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.habit.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title and interval
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.habit.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                decorationThickness: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(widget.habit.colorValue).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getIntervalDisplay(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(widget.habit.colorValue),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                if (streak > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '🔥',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$streak ${widget.habit.interval == 'daily' ? 'day' : widget.habit.interval == 'weekly' ? 'week' : 'month'}${streak > 1 ? 's' : ''}',
                                          style: const TextStyle(
                                            fontSize: 12,
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
                      // Edit button
                      if (widget.onEdit != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Color(widget.habit.colorValue).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              color: Color(widget.habit.colorValue),
                              size: 20,
                            ),
                            onPressed: widget.onEdit,
                            tooltip: 'Edit',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 5-day completion view
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _buildDayIndicators(today, context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
