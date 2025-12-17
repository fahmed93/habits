import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/services/test_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TestDataService Tests', () {
    test('generateRandomHabits should create exactly 15 habits', () {
      final habits = TestDataService.generateRandomHabits();
      
      expect(habits.length, 15);
    });

    test('generated habits should have unique names', () {
      final habits = TestDataService.generateRandomHabits();
      final names = habits.map((h) => h.name).toSet();
      
      expect(names.length, 15); // All names should be unique
    });

    test('generated habits should have valid properties', () {
      final habits = TestDataService.generateRandomHabits();
      
      for (final habit in habits) {
        // Check all required properties are set
        expect(habit.id, isNotEmpty);
        expect(habit.name, isNotEmpty);
        expect(habit.interval, 'daily');
        expect(habit.icon, isNotEmpty);
        
        // Check color is from the palette
        expect(Habit.habitColors.contains(habit.colorValue), true);
        
        // Check createdAt is about 365 days ago
        final daysDifference = DateTime.now().difference(habit.createdAt).inDays;
        expect(daysDifference, greaterThanOrEqualTo(364));
        expect(daysDifference, lessThanOrEqualTo(366));
      }
    });

    test('generated habits should have 365 days of completion data', () {
      final habits = TestDataService.generateRandomHabits();
      
      for (final habit in habits) {
        // Each habit should have some completions (not necessarily 365)
        // since we use a success rate between 50-85%
        expect(habit.completions, isNotEmpty);
        
        // Should have between 50% and 85% of days completed
        // (roughly 182 to 310 days)
        expect(habit.completions.length, greaterThanOrEqualTo(150));
        expect(habit.completions.length, lessThanOrEqualTo(330));
      }
    });

    test('completion dates should be normalized to midnight', () {
      final habits = TestDataService.generateRandomHabits();
      
      for (final habit in habits) {
        for (final completion in habit.completions) {
          expect(completion.hour, 0);
          expect(completion.minute, 0);
          expect(completion.second, 0);
          expect(completion.millisecond, 0);
        }
      }
    });

    test('completion dates should span approximately 365 days', () {
      final habits = TestDataService.generateRandomHabits();
      
      for (final habit in habits) {
        if (habit.completions.length >= 2) {
          final sortedCompletions = List<DateTime>.from(habit.completions)
            ..sort();
          
          final firstDate = sortedCompletions.first;
          final lastDate = sortedCompletions.last;
          final daySpan = lastDate.difference(firstDate).inDays;
          
          // The span should be close to 365 days
          expect(daySpan, greaterThanOrEqualTo(300));
          expect(daySpan, lessThanOrEqualTo(365));
        }
      }
    });

    test('completion dates should not be in the future', () {
      final habits = TestDataService.generateRandomHabits();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (final habit in habits) {
        for (final completion in habit.completions) {
          expect(completion.isBefore(today.add(const Duration(days: 1))), true);
        }
      }
    });

    test('habits should have different emojis (at least sometimes)', () {
      // Run multiple times to check for variety
      final emojis = <String>{};
      
      for (int i = 0; i < 3; i++) {
        final habits = TestDataService.generateRandomHabits();
        for (final habit in habits) {
          emojis.add(habit.icon);
        }
      }
      
      // With 3 runs of 5 habits each, we should have more than 1 unique emoji
      expect(emojis.length, greaterThan(1));
    });

    test('habits should have different colors (at least sometimes)', () {
      // Run multiple times to check for variety
      final colors = <int>{};
      
      for (int i = 0; i < 3; i++) {
        final habits = TestDataService.generateRandomHabits();
        for (final habit in habits) {
          colors.add(habit.colorValue);
        }
      }
      
      // With 3 runs of 5 habits each, we should have more than 1 unique color
      expect(colors.length, greaterThan(1));
    });
  });
}
