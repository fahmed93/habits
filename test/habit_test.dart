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
      );

      final json = habit.toJson();
      final habitFromJson = Habit.fromJson(json);

      expect(habitFromJson.id, habit.id);
      expect(habitFromJson.name, habit.name);
      expect(habitFromJson.interval, habit.interval);
      expect(habitFromJson.createdAt, habit.createdAt);
      expect(habitFromJson.completions.length, habit.completions.length);
      expect(habitFromJson.colorValue, habit.colorValue);
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
  });
}
