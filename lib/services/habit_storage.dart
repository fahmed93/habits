import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitStorage {
  static const String _habitsKey = 'habits';

  // Save habits to local storage
  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = habits.map((habit) => habit.toJson()).toList();
    await prefs.setString(_habitsKey, jsonEncode(habitsJson));
  }

  // Load habits from local storage
  Future<List<Habit>> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsString = prefs.getString(_habitsKey);
      
      if (habitsString == null) {
        return [];
      }

      final List<dynamic> habitsJson = jsonDecode(habitsString);
      return habitsJson.map((json) => Habit.fromJson(json)).toList();
    } catch (e) {
      // Return empty list if data is corrupted
      return [];
    }
  }

  // Add a new habit
  Future<void> addHabit(Habit habit) async {
    final habits = await loadHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  // Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    final habits = await loadHabits();
    final index = habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      habits[index] = updatedHabit;
      await saveHabits(habits);
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    final habits = await loadHabits();
    habits.removeWhere((h) => h.id == habitId);
    await saveHabits(habits);
  }
}
