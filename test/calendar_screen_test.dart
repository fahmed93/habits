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

  group('CalendarScreen Widget Tests', () {
    testWidgets('CalendarScreen should show empty state when no habits',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: []),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.text('No habits yet'), findsOneWidget);
      expect(find.text('Add habits to see them in the calendar'), findsOneWidget);
    });

    testWidgets('CalendarScreen should display HabitCalendar when habits exist',
        (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: [habit]),
          ),
        ),
      );

      expect(find.byType(HabitCalendar), findsOneWidget);
      expect(find.text('No habits yet'), findsNothing);
    });

    testWidgets('CalendarScreen should display filter chips',
        (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: [habit]),
          ),
        ),
      );

      // Check for view mode chips
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
      
      // Check for habit filter
      expect(find.text('1/1 selected'), findsOneWidget);
    });

    testWidgets('CalendarScreen should switch view modes',
        (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: [habit]),
          ),
        ),
      );

      // Tap on Week chip
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();

      // Verify HabitCalendar still exists
      expect(find.byType(HabitCalendar), findsOneWidget);

      // Tap on Year chip
      await tester.tap(find.text('Year'));
      await tester.pumpAndSettle();

      expect(find.byType(HabitCalendar), findsOneWidget);
    });

    testWidgets('CalendarScreen should open habit filter dialog',
        (WidgetTester tester) async {
      final habits = [
        Habit(
          id: '1',
          name: 'Exercise',
          interval: 'daily',
          createdAt: DateTime.now(),
          completions: [],
        ),
        Habit(
          id: '2',
          name: 'Reading',
          interval: 'weekly',
          createdAt: DateTime.now(),
          completions: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: habits),
          ),
        ),
      );

      // Tap on habit filter chip
      await tester.tap(find.text('2/2 selected'));
      await tester.pumpAndSettle();

      // Check dialog appears
      expect(find.text('Select Habits'), findsOneWidget);
      expect(find.text('Select All'), findsOneWidget);
      expect(find.text('Deselect All'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
    });

    testWidgets('CalendarScreen should filter habits',
        (WidgetTester tester) async {
      final habits = [
        Habit(
          id: '1',
          name: 'Exercise',
          interval: 'daily',
          createdAt: DateTime.now(),
          completions: [],
        ),
        Habit(
          id: '2',
          name: 'Reading',
          interval: 'weekly',
          createdAt: DateTime.now(),
          completions: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: habits),
          ),
        ),
      );

      // Open filter dialog
      await tester.tap(find.text('2/2 selected'));
      await tester.pumpAndSettle();

      // Uncheck one habit
      final checkboxes = find.byType(CheckboxListTile);
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Check that filter count updated
      expect(find.text('1/2 selected'), findsOneWidget);
    });

    testWidgets('CalendarScreen should handle multiple habits',
        (WidgetTester tester) async {
      final habits = [
        Habit(
          id: '1',
          name: 'Exercise',
          interval: 'daily',
          createdAt: DateTime.now(),
          completions: [],
        ),
        Habit(
          id: '2',
          name: 'Reading',
          interval: 'weekly',
          createdAt: DateTime.now(),
          completions: [],
        ),
        Habit(
          id: '3',
          name: 'Meditation',
          interval: 'daily',
          createdAt: DateTime.now(),
          completions: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: habits),
          ),
        ),
      );

      expect(find.byType(HabitCalendar), findsOneWidget);
      expect(find.text('3/3 selected'), findsOneWidget);
    });

    testWidgets('CalendarScreen empty state should use grey colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: []),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.calendar_today));
      expect(iconWidget.size, 80);
      expect(iconWidget.color, Colors.grey[400]);
    });

    testWidgets('CalendarScreen should center empty state content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: []),
          ),
        ),
      );

      // More specific - find Center widget within CalendarScreen body
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('CalendarScreen should show selected habits as chips',
        (WidgetTester tester) async {
      final habits = [
        Habit(
          id: '1',
          name: 'Exercise',
          interval: 'daily',
          createdAt: DateTime.now(),
          completions: [],
        ),
        Habit(
          id: '2',
          name: 'Reading',
          interval: 'weekly',
          createdAt: DateTime.now(),
          completions: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: habits),
          ),
        ),
      );

      // Open filter dialog
      await tester.tap(find.text('2/2 selected'));
      await tester.pumpAndSettle();

      // Deselect all habits
      await tester.tap(find.text('Deselect All'));
      await tester.pumpAndSettle();

      // Select just Exercise
      final checkboxes = find.byType(CheckboxListTile);
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Should show Exercise chip when not all are selected
      expect(find.widgetWithText(Chip, 'Exercise'), findsOneWidget);
    });

    testWidgets('CalendarScreen should update checkboxes in real-time',
        (WidgetTester tester) async {
      final habits = [
        Habit(
          id: '1',
          name: 'Exercise',
          interval: 'daily',
          createdAt: DateTime.now(),
          completions: [],
        ),
        Habit(
          id: '2',
          name: 'Reading',
          interval: 'weekly',
          createdAt: DateTime.now(),
          completions: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: habits),
          ),
        ),
      );

      // Open filter dialog
      await tester.tap(find.text('2/2 selected'));
      await tester.pumpAndSettle();

      // Verify both checkboxes are initially checked
      final checkboxes = find.byType(CheckboxListTile);
      expect(checkboxes, findsNWidgets(2));
      
      CheckboxListTile firstCheckbox = tester.widget(checkboxes.first);
      CheckboxListTile secondCheckbox = tester.widget(checkboxes.last);
      expect(firstCheckbox.value, true);
      expect(secondCheckbox.value, true);

      // Tap first checkbox to uncheck it
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Verify first checkbox is now unchecked, second still checked
      firstCheckbox = tester.widget(checkboxes.first);
      secondCheckbox = tester.widget(checkboxes.last);
      expect(firstCheckbox.value, false);
      expect(secondCheckbox.value, true);

      // Tap first checkbox again to re-check it
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Verify first checkbox is checked again
      firstCheckbox = tester.widget(checkboxes.first);
      expect(firstCheckbox.value, true);

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('CalendarScreen "Select All" button should update checkboxes immediately',
        (WidgetTester tester) async {
      final habits = [
        Habit(
          id: '1',
          name: 'Exercise',
          interval: 'daily',
          createdAt: DateTime.now(),
          completions: [],
        ),
        Habit(
          id: '2',
          name: 'Reading',
          interval: 'weekly',
          createdAt: DateTime.now(),
          completions: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: habits),
          ),
        ),
      );

      // Open filter dialog
      await tester.tap(find.text('2/2 selected'));
      await tester.pumpAndSettle();

      // Deselect all
      await tester.tap(find.text('Deselect All'));
      await tester.pumpAndSettle();

      // Verify all checkboxes are unchecked
      final checkboxes = find.byType(CheckboxListTile);
      CheckboxListTile firstCheckbox = tester.widget(checkboxes.first);
      CheckboxListTile secondCheckbox = tester.widget(checkboxes.last);
      expect(firstCheckbox.value, false);
      expect(secondCheckbox.value, false);

      // Select all
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();

      // Verify all checkboxes are now checked
      firstCheckbox = tester.widget(checkboxes.first);
      secondCheckbox = tester.widget(checkboxes.last);
      expect(firstCheckbox.value, true);
      expect(secondCheckbox.value, true);

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('CalendarScreen "Deselect All" button should update checkboxes immediately',
        (WidgetTester tester) async {
      final habits = [
        Habit(
          id: '1',
          name: 'Exercise',
          interval: 'daily',
          createdAt: DateTime.now(),
          completions: [],
        ),
        Habit(
          id: '2',
          name: 'Reading',
          interval: 'weekly',
          createdAt: DateTime.now(),
          completions: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScreen(habits: habits),
          ),
        ),
      );

      // Open filter dialog
      await tester.tap(find.text('2/2 selected'));
      await tester.pumpAndSettle();

      // Verify all checkboxes are initially checked
      final checkboxes = find.byType(CheckboxListTile);
      CheckboxListTile firstCheckbox = tester.widget(checkboxes.first);
      CheckboxListTile secondCheckbox = tester.widget(checkboxes.last);
      expect(firstCheckbox.value, true);
      expect(secondCheckbox.value, true);

      // Deselect all
      await tester.tap(find.text('Deselect All'));
      await tester.pumpAndSettle();

      // Verify all checkboxes are now unchecked
      firstCheckbox = tester.widget(checkboxes.first);
      secondCheckbox = tester.widget(checkboxes.last);
      expect(firstCheckbox.value, false);
      expect(secondCheckbox.value, false);

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });
  });
}
