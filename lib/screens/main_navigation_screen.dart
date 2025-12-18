import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/habit.dart';
import '../models/category.dart';
import '../services/habit_storage.dart';
import '../services/category_storage.dart';
import '../services/time_service.dart';
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
  late final CategoryStorage _categoryStorage;
  final TimeService _timeService = TimeService();
  List<Habit> _habits = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _storage = HabitStorage(userId: widget.userId);
    _categoryStorage = CategoryStorage(userId: widget.userId);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _timeService.loadOffset();
    await _initializeGuestUserData();
    await _loadData();
  }

  /// Initialize test data for guest user on first use
  Future<void> _initializeGuestUserData() async {
    // Only initialize for guest user
    if (widget.userId != AppConstants.guestUserId) {
      return;
    }

    // Check if guest user already has habits
    final existingHabits = await _storage.loadHabits();
    if (existingHabits.isNotEmpty) {
      return; // Guest user already has data
    }

    // Generate and save 15 random habits with 365 days of historical data
    final testHabits = TestDataService.generateRandomHabits();
    await _storage.saveHabits(testHabits);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final habits = await _storage.loadHabits();
    final categories = await _categoryStorage.loadAllCategories();
    setState(() {
      _habits = habits;
      _categories = categories;
      _isLoading = false;
    });
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

  // Group habits by category
  Map<String, List<Habit>> _groupHabitsByCategory() {
    final grouped = <String, List<Habit>>{};
    
    for (final habit in _habits) {
      final categoryId = habit.categoryId ?? 'uncategorized';
      grouped.putIfAbsent(categoryId, () => []).add(habit);
    }
    
    return grouped;
  }

  // Get category by ID
  Category? _getCategoryById(String categoryId) {
    if (categoryId == 'uncategorized') return null;
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Get the last 5 days including today
  List<DateTime> _getLast5DaysFrom(DateTime today) {
    return List.generate(5, (index) {
      return today.subtract(Duration(days: 4 - index));
    });
  }

  // Build the sticky date header showing last 5 days
  Widget _buildDateHeader(DateTime today) {
    final dates = _getLast5DaysFrom(today);
    final dateFormat = DateFormat('M/d');
    
    return Container(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16), // Match Card margin
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12), // Match Card inner padding
      child: Row(
        children: [
          // Left side: Empty space for habit name
          const Expanded(
            flex: 3,
            child: SizedBox(),
          ),
          const SizedBox(width: 16),
          // Right side: Date columns - match the exact structure of habit items
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: List.generate(dates.length, (i) {
                  final date = dates[i];
                  final isToday = date.year == today.year &&
                                 date.month == today.month &&
                                 date.day == today.day;
                  return Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        dateFormat.format(date),
                        textAlign: TextAlign.center,
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
                }),
              ),
            ),
          ),
        ],
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

    final now = _timeService.now();
    final today = DateTime(now.year, now.month, now.day);

    // Group habits by category
    final groupedHabits = _groupHabitsByCategory();
    
    // Sort category IDs
    final sortedCategoryIds = groupedHabits.keys.toList()..sort((a, b) {
      if (a == 'uncategorized') return 1;
      if (b == 'uncategorized') return -1;
      
      final categoryA = _getCategoryById(a);
      final categoryB = _getCategoryById(b);
      
      if (categoryA == null && categoryB == null) return 0;
      if (categoryA == null) return 1;
      if (categoryB == null) return -1;
      
      if (!categoryA.isCustom && categoryB.isCustom) return -1;
      if (categoryA.isCustom && !categoryB.isCustom) return 1;
      
      if (!categoryA.isCustom && !categoryB.isCustom) {
        final indexA = Category.predefined.indexWhere((c) => c.id == a);
        final indexB = Category.predefined.indexWhere((c) => c.id == b);
        return indexA.compareTo(indexB);
      }
      
      return categoryA.name.compareTo(categoryB.name);
    });

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
        // Habits grouped by category
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ...sortedCategoryIds.expand((categoryId) {
                final categoryHabits = groupedHabits[categoryId]!;
                final category = _getCategoryById(categoryId);
                final categoryName = category?.name ?? 'Uncategorized';
                final categoryIcon = category?.icon ?? '📋';
                
                return [
                  // Category header
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          categoryIcon,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoryName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${categoryHabits.length})',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Habits in this category
                  ...categoryHabits.map((habit) => HabitItem(
                    habit: habit,
                    onToggle: () => _toggleCompletion(habit),
                    onToggleDate: (date) => _toggleCompletion(habit, date),
                    onDelete: () => _deleteHabit(habit.id),
                    onEdit: () => _navigateToEditHabit(habit),
                  )),
                ];
              }),
              const SizedBox(height: 80), // Extra space for FAB
            ]),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? _buildHabitsListView()
              : CalendarScreen(
                  habits: _habits,
                  onToggleDate: _toggleCompletion,
                ),
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
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_DateHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
