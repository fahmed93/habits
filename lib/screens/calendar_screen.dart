import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../widgets/habit_calendar.dart';

enum CalendarViewMode { week, month, year }

class CalendarScreen extends StatefulWidget {
  final List<Habit> habits;

  const CalendarScreen({super.key, required this.habits});

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
    final selectedHabit = _selectedHabitId != null
        ? widget.habits.firstWhere((h) => h.id == _selectedHabitId,
            orElse: () => widget.habits.first)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // View mode filter
          Row(
            children: [
              const Text('View: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Week'),
                selected: _viewMode == CalendarViewMode.week,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _viewMode = CalendarViewMode.week);
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Month'),
                selected: _viewMode == CalendarViewMode.month,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _viewMode = CalendarViewMode.month);
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Year'),
                selected: _viewMode == CalendarViewMode.year,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _viewMode = CalendarViewMode.year);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Habit filter
          Row(
            children: [
              const Text('Habit: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (selectedHabit != null)
                        ActionChip(
                          label: Text(selectedHabit.name),
                          avatar: Text(selectedHabit.icon),
                          onPressed: _showHabitFilterDialog,
                        )
                      else
                        ActionChip(
                          label: const Text('Select a habit'),
                          avatar: const Icon(Icons.filter_list, size: 18),
                          onPressed: _showHabitFilterDialog,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) {
      return Center(
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
            ),
          ),
        ),
      ],
    );
  }
}
