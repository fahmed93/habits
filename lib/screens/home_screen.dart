import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';
import '../widgets/habit_item.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitStorage _storage = HabitStorage();
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    final habits = await _storage.loadHabits();
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Future<void> _toggleCompletion(Habit habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final completions = List<DateTime>.from(habit.completions);
    final isCompletedToday = completions.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);

    if (isCompletedToday) {
      completions.removeWhere((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);
    } else {
      completions.add(today);
    }

    final updatedHabit = habit.copyWith(completions: completions);
    await _storage.updateHabit(updatedHabit);
    await _loadHabits();
  }

  Future<void> _deleteHabit(String habitId) async {
    await _storage.deleteHabit(habitId);
    await _loadHabits();
  }

  void _navigateToAddHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
    if (result == true) {
      await _loadHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Habit Tracker'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
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
                        'Tap the + button to add a habit',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _habits.length,
                  itemBuilder: (context, index) {
                    final habit = _habits[index];
                    return HabitItem(
                      habit: habit,
                      onToggle: () => _toggleCompletion(habit),
                      onDelete: () => _deleteHabit(habit.id),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddHabit,
        tooltip: 'Add Habit',
        child: const Icon(Icons.add),
      ),
    );
  }
}
