import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../widgets/habit_calendar.dart';

enum CalendarViewMode { week, month, year }

class CalendarScreen extends StatefulWidget {
  final List<Habit> habits;
  final Function(Habit, DateTime)? onToggleDate;

  const CalendarScreen({
    super.key,
    required this.habits,
    this.onToggleDate,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String? _selectedHabitId;
  CalendarViewMode _viewMode = CalendarViewMode.month;

  @override
  void initState() {
    super.initState();
    // Initially select first habit if available
    if (widget.habits.isNotEmpty) {
      _selectedHabitId = widget.habits.first.id;
    }
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected habit if habits list changes
    if (widget.habits.length != oldWidget.habits.length) {
      final currentIds = widget.habits.map((h) => h.id).toSet();
      if (_selectedHabitId == null || !currentIds.contains(_selectedHabitId)) {
        // Select first habit if current selection is invalid
        _selectedHabitId = widget.habits.isNotEmpty ? widget.habits.first.id : null;
      }
    }
  }

  List<Habit> get _filteredHabits {
    if (_selectedHabitId == null) return [];
    return widget.habits
        .where((habit) => habit.id == _selectedHabitId)
        .toList();
  }

  void _selectHabit(String habitId) {
    setState(() {
      _selectedHabitId = habitId;
    });
  }

  void _showHabitFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Habit'),
          content: SizedBox(
            width: double.maxFinite,
            child: widget.habits.isEmpty
                ? const Text('No habits available')
                : ListView(
                    shrinkWrap: true,
                    children: widget.habits.map((habit) {
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            Text(habit.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(habit.name)),
                          ],
                        ),
                        value: habit.id,
                        groupValue: _selectedHabitId,
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              _selectHabit(value);
                            }
                          });
                          setDialogState(() {});
                        },
                        secondary: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(habit.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    Habit? selectedHabit;
    if (_selectedHabitId != null && widget.habits.isNotEmpty) {
      try {
        selectedHabit = widget.habits.firstWhere((h) => h.id == _selectedHabitId);
      } catch (e) {
        // If selected habit not found, fallback to first habit
        selectedHabit = widget.habits.first;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // View mode filter
          Text(
            'View Mode',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildViewModeChip('Week', CalendarViewMode.week),
                const SizedBox(width: 8),
                _buildViewModeChip('Month', CalendarViewMode.month),
                const SizedBox(width: 8),
                _buildViewModeChip('Year', CalendarViewMode.year),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Habit filter
          Text(
            'Selected Habit',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedHabit != null)
            InkWell(
              onTap: _showHabitFilterDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(selectedHabit.colorValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(selectedHabit.colorValue).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(selectedHabit.colorValue),
                            Color(selectedHabit.colorValue).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          selectedHabit.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedHabit.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            )
          else
            InkWell(
              onTap: _showHabitFilterDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Select a habit',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewModeChip(String label, CalendarViewMode mode) {
    final isSelected = _viewMode == mode;
    return ChoiceChip(
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _viewMode = mode);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) {
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
                Icons.calendar_today_rounded,
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
                'Add habits to see them in the calendar',
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

    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: SingleChildScrollView(
            child: HabitCalendar(
              habits: _filteredHabits,
              viewMode: _viewMode,
              onToggleDate: widget.onToggleDate,
            ),
          ),
        ),
      ],
    );
  }
}
