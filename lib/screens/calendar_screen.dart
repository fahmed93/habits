import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../widgets/habit_calendar.dart';

class CalendarScreen extends StatelessWidget {
  final List<Habit> habits;

  const CalendarScreen({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    return habits.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No habits yet',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add habits to see them in the calendar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(0),
            children: [
              HabitCalendar(habits: habits),
            ],
          );
  }
}
