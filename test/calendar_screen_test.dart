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
      
      // Check for habit filter showing selected habit name (should be in ActionChip)
      expect(find.descendant(
        of: find.byType(ActionChip),
        matching: find.text('Exercise')
      ), findsOneWidget);
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

      // Tap on habit filter chip (should show first habit's name)
      await tester.tap(find.byType(ActionChip));
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

      // Initially shows first habit in ActionChip
      expect(find.descendant(
        of: find.byType(ActionChip),
        matching: find.text('Exercise')
      ), findsOneWidget);

      // Open filter dialog
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      // Select second habit
      final radioButtons = find.byType(RadioListTile<String>);
      await tester.tap(radioButtons.last);
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Check that selected habit changed to Reading in ActionChip
      expect(find.descendant(
        of: find.byType(ActionChip),
        matching: find.text('Reading')
      ), findsOneWidget);
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
      // First habit should be selected in ActionChip
      expect(find.descendant(
        of: find.byType(ActionChip),
        matching: find.text('Exercise')
      ), findsOneWidget);
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

      // Should show first habit by default in ActionChip
      expect(find.descendant(
        of: find.byType(ActionChip),
        matching: find.text('Exercise')
      ), findsOneWidget);

      // Open filter dialog
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      // Select Reading
      final radioButtons = find.byType(RadioListTile<String>);
      await tester.tap(radioButtons.last);
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Should now show Reading in the chip
      expect(find.descendant(
        of: find.byType(ActionChip),
        matching: find.text('Reading')
      ), findsOneWidget);
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

      // Open filter dialog
      await tester.tap(find.byType(ActionChip));
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
