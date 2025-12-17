import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';
import '../services/time_service.dart';
import '../services/auth_service.dart';
import '../services/test_data_service.dart';
import '../widgets/habit_item.dart';
import 'add_habit_screen.dart';
import 'edit_habit_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String userId;
  final Function(ThemeMode) onThemeChanged;

  const MainNavigationScreen({
    super.key,
    required this.userId,
    required this.onThemeChanged,
  });

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
    await _initializeGuestUserData();
    await _loadHabits();
  }

  /// Initialize test data for guest user on first use
  Future<void> _initializeGuestUserData() async {
    // Only initialize for guest user
    if (widget.userId != 'guest') {
      return;
    }

    // Check if guest user already has habits
    final existingHabits = await _storage.loadHabits();
    if (existingHabits.isNotEmpty) {
      return; // Guest user already has data
    }

    // Generate and save 5 random habits with 365 days of historical data
    final testHabits = TestDataService.generateRandomHabits();
    await _storage.saveHabits(testHabits);
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

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          userId: widget.userId,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  Widget _buildHabitsListView() {
    if (_habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 70,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No habits yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Start building better habits today.\nTap the button below to create your first habit!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...List.generate(_habits.length, (index) {
          final habit = _habits[index];
          return HabitItem(
            habit: habit,
            onToggle: () => _toggleCompletion(habit),
            onToggleDate: (date) => _toggleCompletion(habit, date),
            onDelete: () => _deleteHabit(habit.id),
            onEdit: () => _navigateToEditHabit(habit),
          );
        }),
        const SizedBox(height: 80), // Extra space for FAB
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: _navigateToSettings,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedIndex == 0 ? 'My Habits' : 'Calendar',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              timeOffset > 0
                  ? '$formattedDate (+${timeOffset}h)'
                  : formattedDate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.access_time_rounded),
              tooltip: '+24 hours',
              onPressed: _add24Hours,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sign Out',
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? _buildHabitsListView()
              : CalendarScreen(habits: _habits),
      floatingActionButton: _selectedIndex == 0
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _navigateToAddHabit,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add Habit',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onNavigationItemTapped,
          elevation: 0,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Habits',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_rounded),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
          ],
        ),
      ),
    );
  }
}
