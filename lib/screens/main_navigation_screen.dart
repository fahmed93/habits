import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';
import '../services/time_service.dart';
import '../services/auth_service.dart';
import '../widgets/habit_item.dart';
import 'add_habit_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String userId;

  const MainNavigationScreen({super.key, required this.userId});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late final HabitStorage _storage;
  final TimeService _timeService = TimeService();
  final AuthService _authService = AuthService();
  List<Habit> _habits = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _storage = HabitStorage(userId: widget.userId);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _timeService.loadOffset();
    await _loadHabits();
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
    final now = _timeService.now();
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

  Future<void> _add24Hours() async {
    await _timeService.addHours(24);
    setState(() {
      // Trigger rebuild to show new date
    });
  }

  Future<void> _deleteHabit(String habitId) async {
    await _storage.deleteHabit(habitId);
    await _loadHabits();
  }

  void _navigateToAddHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddHabitScreen(userId: widget.userId)),
    );
    if (result == true) {
      await _loadHabits();
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.signOut();
      // Navigation will be handled by the auth state listener in main.dart
    }
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Widget _buildHabitsListView() {
    if (_habits.isEmpty) {
      return Center(
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
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...List.generate(_habits.length, (index) {
          final habit = _habits[index];
          return HabitItem(
            habit: habit,
            onToggle: () => _toggleCompletion(habit),
            onDelete: () => _deleteHabit(habit.id),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = _timeService.now();
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final formattedDate = dateFormat.format(now);
    final timeOffset = _timeService.offsetHours;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: _navigateToSettings,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_selectedIndex == 0 ? 'Habit Tracker' : 'Calendar'),
            Text(
              timeOffset > 0
                  ? '$formattedDate (+${timeOffset}h)'
                  : formattedDate,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            tooltip: '+24 hours',
            onPressed: _add24Hours,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? _buildHabitsListView()
              : CalendarScreen(habits: _habits),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToAddHabit,
              tooltip: 'Add Habit',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigationItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
