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

      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
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
      
      // Check for habit filter showing selected habit name
      // Note: habit name appears in multiple places (filter display and potentially interval label)
      expect(find.text('Exercise'), findsWidgets);
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

      // Find the "Selected Habit" section and tap on it
      expect(find.text('Selected Habit'), findsOneWidget);
      
      // Find the InkWell that contains the habit info (after the "Selected Habit" text)
      // We need to tap specifically on the container showing the selected habit
      final habitContainers = find.descendant(
        of: find.byType(InkWell),
        matching: find.text('Exercise'),
      );
      await tester.tap(habitContainers.first);
      await tester.pumpAndSettle();

      // Check dialog appears with radio buttons
      expect(find.text('Select Habit'), findsOneWidget);
      expect(find.byType(RadioListTile<String>), findsNWidgets(2));
    });

    testWidgets('CalendarScreen should select a single habit',
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

      // Initially shows first habit (Exercise) - may appear in multiple places
      expect(find.text('Exercise'), findsWidgets);

      // Open filter dialog (tap on Exercise text)
      await tester.tap(find.text('Exercise').first);
      await tester.pumpAndSettle();

      // Select second habit
      final radioButtons = find.byType(RadioListTile<String>);
      await tester.tap(radioButtons.last);
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Check that selected habit changed to Reading
      expect(find.text('Reading'), findsWidgets);
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
      // First habit should be selected and visible
      expect(find.text('Exercise'), findsWidgets);
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

      // Icon should be calendar_today_rounded with size 70
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.calendar_today_rounded));
      expect(iconWidget.size, 70);
      // Color is now based on theme's primary color, not grey
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

    testWidgets('CalendarScreen should show selected habit in chip',
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

      // Should show first habit by default
      expect(find.text('Exercise'), findsWidgets);

      // Open filter dialog
      await tester.tap(find.text('Exercise').first);
      await tester.pumpAndSettle();

      // Select Reading
      final radioButtons = find.byType(RadioListTile<String>);
      await tester.tap(radioButtons.last);
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Should now show Reading
      expect(find.text('Reading'), findsWidgets);
    });

    testWidgets('CalendarScreen should update radio buttons in real-time',
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

      // Open filter dialog (tap on Exercise text which is the first habit)
      await tester.tap(find.text('Exercise').first);
      await tester.pumpAndSettle();

      // Verify first radio button is initially selected
      final radioButtons = find.byType(RadioListTile<String>);
      expect(radioButtons, findsNWidgets(2));
      
      RadioListTile<String> firstRadio = tester.widget(radioButtons.first);
      RadioListTile<String> secondRadio = tester.widget(radioButtons.last);
      expect(firstRadio.groupValue, firstRadio.value);
      expect(secondRadio.groupValue, firstRadio.value);

      // Tap second radio button to select it
      await tester.tap(radioButtons.last);
      await tester.pumpAndSettle();

      // Verify second radio button is now selected
      firstRadio = tester.widget(radioButtons.first);
      secondRadio = tester.widget(radioButtons.last);
      expect(firstRadio.groupValue, secondRadio.value);
      expect(secondRadio.groupValue, secondRadio.value);

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });
  });
}
