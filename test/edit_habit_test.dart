import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/services/habit_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Edit Habit Functionality Tests', () {
    late HabitStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = HabitStorage(userId: 'test_user');
    });

    test('updateHabit should preserve habit ID and createdAt', () async {
      final originalHabit = Habit(
        id: '123',
        name: 'Original Name',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [DateTime(2024, 1, 2)],
        colorValue: 0xFF6366F1,
        icon: '✓',
      );

      await storage.addHabit(originalHabit);

      final updatedHabit = originalHabit.copyWith(
        name: 'Updated Name',
        interval: 'weekly',
        colorValue: 0xFFEC4899,
        icon: '💪',
      );

      await storage.updateHabit(updatedHabit);

      final habits = await storage.loadHabits();
      expect(habits.length, 1);
      expect(habits[0].id, '123');
      expect(habits[0].name, 'Updated Name');
      expect(habits[0].interval, 'weekly');
      expect(habits[0].colorValue, 0xFFEC4899);
      expect(habits[0].icon, '💪');
      expect(habits[0].createdAt, DateTime(2024, 1, 1));
      expect(habits[0].completions, [DateTime(2024, 1, 2)]);
    });

    test('updateHabit should preserve completions when editing', () async {
      final habit = Habit(
        id: '456',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 2),
          DateTime(2024, 1, 3),
        ],
        colorValue: 0xFF6366F1,
        icon: '🏃',
      );

      await storage.addHabit(habit);

      final updatedHabit = habit.copyWith(name: 'Morning Run');

      await storage.updateHabit(updatedHabit);

      final habits = await storage.loadHabits();
      expect(habits[0].completions.length, 3);
      expect(habits[0].completions[0], DateTime(2024, 1, 1));
      expect(habits[0].completions[1], DateTime(2024, 1, 2));
      expect(habits[0].completions[2], DateTime(2024, 1, 3));
    });

    test('updateHabit should allow changing all editable fields', () async {
      final habit = Habit(
        id: '789',
        name: 'Read',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
        colorValue: 0xFF6366F1,
        icon: '📖',
      );

      await storage.addHabit(habit);

      final updatedHabit = habit.copyWith(
        name: 'Read Books',
        interval: 'weekly',
        colorValue: 0xFF3B82F6,
        icon: '📚',
      );

      await storage.updateHabit(updatedHabit);

      final habits = await storage.loadHabits();
      expect(habits[0].name, 'Read Books');
      expect(habits[0].interval, 'weekly');
      expect(habits[0].colorValue, 0xFF3B82F6);
      expect(habits[0].icon, '📚');
    });

    test('updateHabit should work with user-scoped storage', () async {
      final user1Storage = HabitStorage(userId: 'user1');
      final user2Storage = HabitStorage(userId: 'user2');

      final habit1 = Habit(
        id: '1',
        name: 'User 1 Habit',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      final habit2 = Habit(
        id: '2',
        name: 'User 2 Habit',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      await user1Storage.addHabit(habit1);
      await user2Storage.addHabit(habit2);

      final updatedHabit1 = habit1.copyWith(name: 'Updated User 1 Habit');
      await user1Storage.updateHabit(updatedHabit1);

      final user1Habits = await user1Storage.loadHabits();
      final user2Habits = await user2Storage.loadHabits();

      expect(user1Habits[0].name, 'Updated User 1 Habit');
      expect(user2Habits[0].name, 'User 2 Habit'); // Should remain unchanged
    });

    test('updateHabit should handle multiple habits correctly', () async {
      final habit1 = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      final habit2 = Habit(
        id: '2',
        name: 'Read',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 2),
        completions: [],
      );

      final habit3 = Habit(
        id: '3',
        name: 'Meditate',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 3),
        completions: [],
      );

      await storage.addHabit(habit1);
      await storage.addHabit(habit2);
      await storage.addHabit(habit3);

      final updatedHabit2 = habit2.copyWith(name: 'Read 30 Minutes');
      await storage.updateHabit(updatedHabit2);

      final habits = await storage.loadHabits();
      expect(habits.length, 3);
      expect(habits[0].name, 'Exercise');
      expect(habits[1].name, 'Read 30 Minutes');
      expect(habits[2].name, 'Meditate');
    });

    test('habit copyWith should allow editing individual fields', () async {
      final habit = Habit(
        id: '100',
        name: 'Original',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
        colorValue: 0xFF6366F1,
        icon: '✓',
      );

      final updatedName = habit.copyWith(name: 'New Name');
      expect(updatedName.name, 'New Name');
      expect(updatedName.interval, 'daily');
      expect(updatedName.colorValue, 0xFF6366F1);
      expect(updatedName.icon, '✓');

      final updatedInterval = habit.copyWith(interval: 'weekly');
      expect(updatedInterval.name, 'Original');
      expect(updatedInterval.interval, 'weekly');

      final updatedColor = habit.copyWith(colorValue: 0xFFEC4899);
      expect(updatedColor.colorValue, 0xFFEC4899);
      expect(updatedColor.name, 'Original');

      final updatedIcon = habit.copyWith(icon: '🎯');
      expect(updatedIcon.icon, '🎯');
      expect(updatedIcon.name, 'Original');
    });
  });
}
