import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';

class AddHabitScreen extends StatefulWidget {
  final String userId;

  const AddHabitScreen({super.key, required this.userId});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final HabitStorage _storage;
  String _selectedInterval = 'daily';
  int _selectedColor = Habit.habitColors[0];
  String _selectedIcon = '✓';

  // Predefined emoji options for habits
  static const List<String> _habitIcons = [
    '✓', '💪', '📚', '🏃', '🧘', '💻',
    '🎨', '🎵', '✍️', '🌱', '💧', '🍎',
    '🛏️', '🧹', '📝', '🎯', '⚡', '🔥',
    '🌟', '💡', '🎓', '🏋️', '🚴', '🏊',
  ];

  @override
  void initState() {
    super.initState();
    _storage = HabitStorage(userId: widget.userId);
  }

  final List<Map<String, String>> _intervals = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        interval: _selectedInterval,
        createdAt: DateTime.now(),
        completions: [],
        colorValue: _selectedColor,
        icon: _selectedIcon,
      );

      await _storage.addHabit(habit);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add New Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Exercise, Read, Meditate',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Interval',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<String>(
                groupValue: _selectedInterval,
                onChanged: (value) {
                  setState(() {
                    _selectedInterval = value!;
                  });
                },
                child: Column(
                  children: _intervals.map((interval) {
                    return RadioListTile<String>(
                      title: Text(interval['label']!),
                      value: interval['value']!,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: Habit.habitColors.map((colorValue) {
                  final isSelected = _selectedColor == colorValue;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorValue;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      Color(colorValue).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Icon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _habitIcons.map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(_selectedColor).withValues(alpha: 0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: Color(_selectedColor),
                                width: 2,
                              )
                            : Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Habit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
