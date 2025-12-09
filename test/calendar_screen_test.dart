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

    testWidgets('CalendarScreen should be scrollable when habits exist',
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
          home: CalendarScreen(habits: [habit]),
        ),
      );

      // CalendarScreen and HabitCalendar both use SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsAtLeastNWidgets(1));
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
  });
}
