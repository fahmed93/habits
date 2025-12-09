import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/services/habit_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HabitStorage Tests', () {
    late HabitStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = HabitStorage();
    });

    test('loadHabits should return empty list when no data exists', () async {
      final habits = await storage.loadHabits();
      
      expect(habits, isEmpty);
    });

    test('saveHabits and loadHabits should persist habits correctly', () async {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [DateTime(2024, 1, 1)],
      );

      await storage.saveHabits([habit]);
      final loadedHabits = await storage.loadHabits();

      expect(loadedHabits.length, 1);
      expect(loadedHabits[0].id, habit.id);
      expect(loadedHabits[0].name, habit.name);
      expect(loadedHabits[0].interval, habit.interval);
    });

    test('addHabit should add a new habit to storage', () async {
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

      await storage.addHabit(habit1);
      await storage.addHabit(habit2);

      final habits = await storage.loadHabits();
      expect(habits.length, 2);
      expect(habits[0].id, '1');
      expect(habits[1].id, '2');
    });

    test('updateHabit should update an existing habit', () async {
      final habit = Habit(
        id: '123',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      await storage.addHabit(habit);

      final updatedHabit = habit.copyWith(name: 'Workout');
      await storage.updateHabit(updatedHabit);

      final habits = await storage.loadHabits();
      expect(habits.length, 1);
      expect(habits[0].name, 'Workout');
      expect(habits[0].id, habit.id);
    });

    test('updateHabit should not add habit if it does not exist', () async {
      final habit = Habit(
        id: '999',
        name: 'Non-existent',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      await storage.updateHabit(habit);

      final habits = await storage.loadHabits();
      expect(habits, isEmpty);
    });

    test('deleteHabit should remove a habit from storage', () async {
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

      await storage.addHabit(habit1);
      await storage.addHabit(habit2);
      await storage.deleteHabit('1');

      final habits = await storage.loadHabits();
      expect(habits.length, 1);
      expect(habits[0].id, '2');
    });

    test('deleteHabit should handle non-existent habit gracefully', () async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      await storage.addHabit(habit);
      await storage.deleteHabit('999');

      final habits = await storage.loadHabits();
      expect(habits.length, 1);
      expect(habits[0].id, '1');
    });

    test('loadHabits should return empty list on corrupted data', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('habits', 'invalid json');

      final habits = await storage.loadHabits();
      expect(habits, isEmpty);
    });

    test('HabitStorage should use user-scoped key when userId provided', () async {
      final userStorage = HabitStorage(userId: 'user123');
      
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      await userStorage.addHabit(habit);

      // Verify it's stored with user-scoped key
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('habits_user123'), true);
      expect(prefs.containsKey('habits'), false);
    });

    test('HabitStorage should isolate data between different users', () async {
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
        createdAt: DateTime(2024, 1, 2),
        completions: [],
      );

      await user1Storage.addHabit(habit1);
      await user2Storage.addHabit(habit2);

      final user1Habits = await user1Storage.loadHabits();
      final user2Habits = await user2Storage.loadHabits();

      expect(user1Habits.length, 1);
      expect(user1Habits[0].name, 'User 1 Habit');
      expect(user2Habits.length, 1);
      expect(user2Habits[0].name, 'User 2 Habit');
    });
  });
}
