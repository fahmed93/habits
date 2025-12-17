import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/screens/calendar_screen.dart';
import 'package:habits/widgets/habit_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Calendar Day Tap Tests', () {
    testWidgets('Tapping a calendar day in month view should call onToggleDate',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      Habit? tappedHabit;
      DateTime? tappedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(
              habits: [habit],
              onToggleDate: (habit, date) {
                tappedHabit = habit;
                tappedDate = date;
              },
            ),
          ),
        ),
      );

      // Find a calendar day (the GestureDetector wrapping the day)
      // We'll tap on the day that shows today's date
      final dayFinder = find.text('${today.day}');
      expect(dayFinder, findsWidgets); // May find multiple if day appears in multiple places
      
      // Tap on the first occurrence
      await tester.tap(dayFinder.first);
      await tester.pumpAndSettle();

      // Verify the callback was called with correct parameters
      expect(tappedHabit, isNotNull);
      expect(tappedHabit?.id, habit.id);
      expect(tappedDate, isNotNull);
      expect(tappedDate?.day, today.day);
    });

    testWidgets('Tapping a calendar day in week view should call onToggleDate',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final habit = Habit(
        id: '1',
        name: 'Reading',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      Habit? tappedHabit;
      DateTime? tappedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(
              habits: [habit],
              onToggleDate: (habit, date) {
                tappedHabit = habit;
                tappedDate = date;
              },
            ),
          ),
        ),
      );

      // Switch to week view
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();

      // Find a calendar day (the GestureDetector wrapping the day)
      final dayFinder = find.text('${today.day}');
      expect(dayFinder, findsWidgets);
      
      // Tap on the first occurrence
      await tester.tap(dayFinder.first);
      await tester.pumpAndSettle();

      // Verify the callback was called
      expect(tappedHabit, isNotNull);
      expect(tappedHabit?.id, habit.id);
      expect(tappedDate, isNotNull);
    });

    testWidgets('Tapping a calendar day should toggle completion status',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      List<DateTime> completions = List.from(habit.completions);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(
              habits: [habit.copyWith(completions: completions)],
              onToggleDate: (h, date) {
                // Simulate toggle logic
                final normalizedDate = DateTime(date.year, date.month, date.day);
                final isCompleted = completions.any((d) =>
                    d.year == normalizedDate.year &&
                    d.month == normalizedDate.month &&
                    d.day == normalizedDate.day);
                
                if (isCompleted) {
                  completions.removeWhere((d) =>
                      d.year == normalizedDate.year &&
                      d.month == normalizedDate.month &&
                      d.day == normalizedDate.day);
                } else {
                  completions.add(normalizedDate);
                }
              },
            ),
          ),
        ),
      );

      // Initially, habit should not be completed
      expect(completions.length, 0);

      // Tap on today's date
      final dayFinder = find.text('${today.day}');
      await tester.tap(dayFinder.first);
      await tester.pumpAndSettle();

      // After tapping, habit should be marked as completed
      expect(completions.length, 1);
      expect(completions.first.day, today.day);
    });

    testWidgets('HabitCalendar with onToggleDate callback should work',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      Habit? tappedHabit;
      DateTime? tappedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCalendar(
              habits: [habit],
              onToggleDate: (h, date) {
                tappedHabit = h;
                tappedDate = date;
              },
            ),
          ),
        ),
      );

      // Find a calendar day
      final dayFinder = find.text('${today.day}');
      expect(dayFinder, findsWidgets);
      
      // Tap on it
      await tester.tap(dayFinder.first);
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(tappedHabit, isNotNull);
      expect(tappedDate, isNotNull);
    });

    testWidgets('HabitCalendar without onToggleDate callback should not crash',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(
              habits: [],
              // No onToggleDate callback
            ),
          ),
        ),
      );

      // Tapping should not crash even without callback
      final dayFinder = find.text('${today.day}');
      if (dayFinder.evaluate().isNotEmpty) {
        await tester.tap(dayFinder.first);
        await tester.pumpAndSettle();
      }

      // Test passes if no exception is thrown
      expect(find.byType(HabitCalendar), findsOneWidget);
    });
  });
}
