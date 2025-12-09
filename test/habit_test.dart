import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/habit.dart';

void main() {
  group('Habit Model Tests', () {
    test('Habit toJson and fromJson should work correctly', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [DateTime(2024, 1, 1), DateTime(2024, 1, 2)],
        colorValue: 0xFF6366F1,
        icon: '💪',
      );

      final json = habit.toJson();
      final habitFromJson = Habit.fromJson(json);

      expect(habitFromJson.id, habit.id);
      expect(habitFromJson.name, habit.name);
      expect(habitFromJson.interval, habit.interval);
      expect(habitFromJson.createdAt, habit.createdAt);
      expect(habitFromJson.completions.length, habit.completions.length);
      expect(habitFromJson.colorValue, habit.colorValue);
      expect(habitFromJson.icon, habit.icon);
    });

    test('Habit fromJson should use default color when colorValue is missing',
        () {
      final json = {
        'id': '123',
        'name': 'Exercise',
        'interval': 'daily',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'completions': [],
      };

      final habitFromJson = Habit.fromJson(json);
      expect(habitFromJson.colorValue, 0xFF6366F1);
      expect(habitFromJson.icon, '✓'); // Should use default icon
    });

    test('Habit fromJson should use default icon when icon is missing', () {
      final json = {
        'id': '123',
        'name': 'Exercise',
        'interval': 'daily',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'completions': [],
        'colorValue': 0xFF6366F1,
      };

      final habitFromJson = Habit.fromJson(json);
      expect(habitFromJson.icon, '✓');
    });

    test('Habit copyWith should create a new habit with updated fields', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      final updatedHabit = habit.copyWith(name: 'Workout');

      expect(updatedHabit.name, 'Workout');
      expect(updatedHabit.id, habit.id);
      expect(updatedHabit.interval, habit.interval);
    });

    test('Habit copyWith should update colorValue', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
        colorValue: 0xFF6366F1,
      );

      final updatedHabit = habit.copyWith(colorValue: 0xFFEC4899);

      expect(updatedHabit.colorValue, 0xFFEC4899);
      expect(updatedHabit.name, habit.name);
    });

    test('Habit copyWith should update icon', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
        icon: '✓',
      );

      final updatedHabit = habit.copyWith(icon: '💪');

      expect(updatedHabit.icon, '💪');
      expect(updatedHabit.name, habit.name);
    });

    test('Habit copyWith should update completions', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      final newCompletions = [DateTime(2024, 1, 2), DateTime(2024, 1, 3)];
      final updatedHabit = habit.copyWith(completions: newCompletions);

      expect(updatedHabit.completions.length, 2);
      expect(updatedHabit.completions, newCompletions);
      expect(updatedHabit.id, habit.id);
    });

    test('Habit copyWith should update interval', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      final updatedHabit = habit.copyWith(interval: 'weekly');

      expect(updatedHabit.interval, 'weekly');
      expect(updatedHabit.name, habit.name);
    });

    test('Habit copyWith should update id', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      final updatedHabit = habit.copyWith(id: '456');

      expect(updatedHabit.id, '456');
      expect(updatedHabit.name, habit.name);
    });

    test('Habit copyWith should update createdAt', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      final newDate = DateTime(2024, 2, 1);
      final updatedHabit = habit.copyWith(createdAt: newDate);

      expect(updatedHabit.createdAt, newDate);
      expect(updatedHabit.name, habit.name);
    });

    test('Habit habitColors should contain predefined colors', () {
      expect(Habit.habitColors, isNotEmpty);
      expect(Habit.habitColors.length, 12);
      // Verify all entries are valid color values
      for (final color in Habit.habitColors) {
        expect(color, isA<int>());
      }
    });

    test('Habit should handle empty completions list', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      expect(habit.completions, isEmpty);
    });

    test('Habit should preserve order of completions', () {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 1, 2);
      final date3 = DateTime(2024, 1, 3);
      
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [date3, date1, date2],
      );

      expect(habit.completions[0], date3);
      expect(habit.completions[1], date1);
      expect(habit.completions[2], date2);
    });

    test('Habit toJson should include all fields', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [DateTime(2024, 1, 1)],
        colorValue: 0xFF6366F1,
        icon: '💪',
      );

      final json = habit.toJson();

      expect(json.containsKey('id'), true);
      expect(json.containsKey('name'), true);
      expect(json.containsKey('interval'), true);
      expect(json.containsKey('createdAt'), true);
      expect(json.containsKey('completions'), true);
      expect(json.containsKey('colorValue'), true);
      expect(json.containsKey('icon'), true);
    });

    test('Habit fromJson should handle different intervals', () {
      final jsonDaily = {
        'id': '1',
        'name': 'Daily Habit',
        'interval': 'daily',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'completions': [],
      };

      final jsonWeekly = {
        'id': '2',
        'name': 'Weekly Habit',
        'interval': 'weekly',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'completions': [],
      };

      final jsonMonthly = {
        'id': '3',
        'name': 'Monthly Habit',
        'interval': 'monthly',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'completions': [],
      };

      final habitDaily = Habit.fromJson(jsonDaily);
      final habitWeekly = Habit.fromJson(jsonWeekly);
      final habitMonthly = Habit.fromJson(jsonMonthly);

      expect(habitDaily.interval, 'daily');
      expect(habitWeekly.interval, 'weekly');
      expect(habitMonthly.interval, 'monthly');
    });

    test('Habit copyWith with null values should preserve original values', () {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [DateTime(2024, 1, 1)],
        colorValue: 0xFF6366F1,
        icon: '💪',
      );

      final updatedHabit = habit.copyWith();

      expect(updatedHabit.id, habit.id);
      expect(updatedHabit.name, habit.name);
      expect(updatedHabit.interval, habit.interval);
      expect(updatedHabit.createdAt, habit.createdAt);
      expect(updatedHabit.completions, habit.completions);
      expect(updatedHabit.colorValue, habit.colorValue);
      expect(updatedHabit.icon, habit.icon);
    });
  });
}
