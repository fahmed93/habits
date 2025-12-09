import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/time_service.dart';

class HabitItem extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const HabitItem({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  bool _isCompletedToday() {
    final now = TimeService().now();
    final today = DateTime(now.year, now.month, now.day);
    return habit.completions.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  String _getIntervalDisplay() {
    switch (habit.interval) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return habit.interval;
    }
  }

  int _getCurrentStreak() {
    if (habit.completions.isEmpty) return 0;

    final sortedCompletions = List<DateTime>.from(habit.completions)
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

  @override
  Widget build(BuildContext context) {
    final isCompleted = _isCompletedToday();
    final streak = _getCurrentStreak();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(habit.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Habit'),
                content:
                    const Text('Are you sure you want to delete this habit?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) => onDelete(),
        child: ListTile(
          leading: GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Color(habit.colorValue) : Colors.grey[300],
                border: Border.all(
                  color: Color(habit.colorValue),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  habit.icon,
                  style: TextStyle(
                    fontSize: 20,
                    color: isCompleted ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            habit.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(_getIntervalDisplay()),
              if (streak > 0)
                Text(
                  '$streak ${habit.interval == 'daily' ? 'day' : habit.interval == 'weekly' ? 'week' : 'month'} streak 🔥',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          trailing: Text(
            '${habit.completions.length}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(habit.colorValue),
            ),
          ),
        ),
      ),
    );
  }
}
