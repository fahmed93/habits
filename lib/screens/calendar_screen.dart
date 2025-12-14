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
  Set<String> _selectedHabitIds = {};
  CalendarViewMode _viewMode = CalendarViewMode.month;

  @override
  void initState() {
    super.initState();
    // Initially select all habits
    _selectedHabitIds = widget.habits.map((h) => h.id).toSet();
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected habits if habits list changes
    if (widget.habits.length != oldWidget.habits.length) {
      final currentIds = widget.habits.map((h) => h.id).toSet();
      _selectedHabitIds = _selectedHabitIds.intersection(currentIds);
      // Add new habits to selection
      _selectedHabitIds.addAll(currentIds);
    }
  }

  List<Habit> get _filteredHabits {
    return widget.habits
        .where((habit) => _selectedHabitIds.contains(habit.id))
        .toList();
  }

  void _toggleHabitSelection(String habitId) {
    setState(() {
      if (_selectedHabitIds.contains(habitId)) {
        _selectedHabitIds.remove(habitId);
      } else {
        _selectedHabitIds.add(habitId);
      }
    });
  }

  void _showHabitFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Habits'),
          content: SizedBox(
            width: double.maxFinite,
            child: widget.habits.isEmpty
                ? const Text('No habits available')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedHabitIds = widget.habits.map((h) => h.id).toSet();
                              });
                              setDialogState(() {});
                            },
                            child: const Text('Select All'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedHabitIds.clear();
                              });
                              setDialogState(() {});
                            },
                            child: const Text('Deselect All'),
                          ),
                        ],
                      ),
                      const Divider(),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: widget.habits.map((habit) {
                            return CheckboxListTile(
                              title: Row(
                                children: [
                                  Text(habit.icon, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(habit.name)),
                                ],
                              ),
                              value: _selectedHabitIds.contains(habit.id),
                              onChanged: (value) {
                                setState(() {
                                  _toggleHabitSelection(habit.id);
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
                    ],
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
              const Text('Habits: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        label: Text(
                          '${_selectedHabitIds.length}/${widget.habits.length} selected',
                        ),
                        avatar: const Icon(Icons.filter_list, size: 18),
                        onPressed: _showHabitFilterDialog,
                      ),
                      if (_selectedHabitIds.length != widget.habits.length &&
                          _selectedHabitIds.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ...widget.habits
                            .where((h) => _selectedHabitIds.contains(h.id))
                            .map((habit) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Chip(
                                    label: Text(habit.name),
                                    avatar: Text(habit.icon),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () => _toggleHabitSelection(habit.id),
                                  ),
                                )),
                      ],
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
