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
      );

      final json = habit.toJson();
      final habitFromJson = Habit.fromJson(json);

      expect(habitFromJson.id, habit.id);
      expect(habitFromJson.name, habit.name);
      expect(habitFromJson.interval, habit.interval);
      expect(habitFromJson.createdAt, habit.createdAt);
      expect(habitFromJson.completions.length, habit.completions.length);
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
  });
}
