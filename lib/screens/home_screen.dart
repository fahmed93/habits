import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';
import '../services/time_service.dart';
import '../services/auth_service.dart';
import '../widgets/habit_calendar.dart';
import '../widgets/habit_item.dart';
import 'add_habit_screen.dart';
import 'edit_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HabitStorage _storage;
  final TimeService _timeService = TimeService();
  final AuthService _authService = AuthService();
  List<Habit> _habits = [];
  bool _isLoading = true;

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

  Future<void> _toggleCompletion(Habit habit, [DateTime? date]) async {
    final now = _timeService.now();
    final targetDate = date ?? DateTime(now.year, now.month, now.day);
    final normalizedDate = DateTime(targetDate.year, targetDate.month, targetDate.day);

    final completions = List<DateTime>.from(habit.completions);
    final isCompletedOnDate = completions.any((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);

    if (isCompletedOnDate) {
      completions.removeWhere((d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day);
    } else {
      completions.add(normalizedDate);
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

  void _navigateToEditHabit(Habit habit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHabitScreen(
          userId: widget.userId,
          habit: habit,
        ),
      ),
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

  List<DateTime> _getLast5DaysFrom(DateTime today) {
    return List.generate(5, (index) {
      return today.subtract(Duration(days: 4 - index));
    });
  }

  Widget _buildDateHeader(DateTime today) {
    final dates = _getLast5DaysFrom(today);
    final dateFormat = DateFormat('M/d');
    
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Left side: Empty space for habit name
          const Expanded(
            flex: 3,
            child: SizedBox(),
          ),
          const SizedBox(width: 16),
          // Right side: Date columns
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dates.map((date) {
                final isToday = date.year == today.year &&
                               date.month == today.month &&
                               date.day == today.day;
                return Expanded(
                  child: Center(
                    child: Text(
                      dateFormat.format(date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsGrid() {
    final now = _timeService.now();
    final today = DateTime(now.year, now.month, now.day);

    return CustomScrollView(
      slivers: [
        // Sticky date header
        SliverPersistentHeader(
          pinned: true,
          delegate: _DateHeaderDelegate(
            child: _buildDateHeader(today),
            height: 50,
          ),
        ),
        // Habit calendar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HabitCalendar(habits: _habits),
          ),
        ),
        // Habit items
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final habit = _habits[index];
              return HabitItem(
                habit: habit,
                onToggle: () => _toggleCompletion(habit),
                onToggleDate: (date) => _toggleCompletion(habit, date),
                onDelete: () => _deleteHabit(habit.id),
                onEdit: () => _navigateToEditHabit(habit),
              );
            },
            childCount: _habits.length,
          ),
        ),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Habit Tracker'),
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
              : _buildHabitsGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddHabit,
        tooltip: 'Add Habit',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Delegate for sticky date header
class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _DateHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_DateHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
