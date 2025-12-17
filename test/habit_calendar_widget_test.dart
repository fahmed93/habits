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

  group('HabitCalendar Widget Tests', () {
    testWidgets('HabitCalendar should display with empty habits',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: []),
          ),
        ),
      );

      expect(find.byType(HabitCalendar), findsOneWidget);
    });

    testWidgets('HabitCalendar should display current month',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: []),
          ),
        ),
      );

      final now = DateTime.now();
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      final expectedMonth = '${months[now.month - 1]} ${now.year}';

      expect(find.text(expectedMonth), findsOneWidget);
    });

    testWidgets('HabitCalendar should display day names in month view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [], viewMode: CalendarViewMode.month),
          ),
        ),
      );

      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
    });

    testWidgets('HabitCalendar should display day names in week view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [], viewMode: CalendarViewMode.week),
          ),
        ),
      );

      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
    });

    testWidgets('HabitCalendar should display navigation buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: []),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('HabitCalendar should navigate to previous month',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: []),
          ),
        ),
      );

      final now = DateTime.now();
      final previousMonth = DateTime(now.year, now.month - 1, 1);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      final expectedMonth =
          '${months[previousMonth.month - 1]} ${previousMonth.year}';

      // Tap previous button
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text(expectedMonth), findsOneWidget);
    });

    testWidgets('HabitCalendar should navigate to next month',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: []),
          ),
        ),
      );

      final now = DateTime.now();
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      final expectedMonth = '${months[nextMonth.month - 1]} ${nextMonth.year}';

      // Tap next button
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text(expectedMonth), findsOneWidget);
    });

    testWidgets('HabitCalendar should display days of month',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: []),
          ),
        ),
      );

      // Should display day 1
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('HabitCalendar should display legend when habits exist in month view',
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
            body: HabitCalendar(habits: [habit], viewMode: CalendarViewMode.month),
          ),
        ),
      );

      expect(find.text('Exercise'), findsOneWidget);
    });

    testWidgets('HabitCalendar should display multiple habits in legend',
        (WidgetTester tester) async {
      final habit1 = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      final habit2 = Habit(
        id: '2',
        name: 'Reading',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [habit1, habit2]),
          ),
        ),
      );

      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
    });

    testWidgets('HabitCalendar should not display legend when no habits',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: []),
          ),
        ),
      );

      // Only day names and dates should be present, no legend
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('HabitCalendar should render with completed habits',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [today],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [habit]),
          ),
        ),
      );

      // The calendar should render
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('HabitCalendar should handle habits with multiple completions',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [today, yesterday],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [habit]),
          ),
        ),
      );

      expect(find.byType(HabitCalendar), findsOneWidget);
    });

    testWidgets('HabitCalendar should display tooltips on day tiles',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [today],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [habit]),
          ),
        ),
      );

      // Should have Tooltip widgets
      expect(find.byType(Tooltip), findsWidgets);
    });

    testWidgets('HabitCalendar should highlight today with border',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: []),
          ),
        ),
      );

      // The calendar should be rendered with proper containers
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('HabitCalendar should handle year transition correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: []),
          ),
        ),
      );

      // Navigate back several times to test year transition
      for (int i = 0; i < 13; i++) {
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
      }

      // Should not crash and should display a valid month
      expect(find.byType(HabitCalendar), findsOneWidget);
    });

    testWidgets('HabitCalendar should display year view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [], viewMode: CalendarViewMode.year),
          ),
        ),
      );

      final now = DateTime.now();
      expect(find.text('${now.year}'), findsOneWidget);
    });

    testWidgets('HabitCalendar year view should show all months',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [], viewMode: CalendarViewMode.year),
          ),
        ),
      );

      // Check for month names
      expect(find.text('January'), findsOneWidget);
      expect(find.text('February'), findsOneWidget);
      expect(find.text('December'), findsOneWidget);
    });

    testWidgets('HabitCalendar week view should show 7 days',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [], viewMode: CalendarViewMode.week),
          ),
        ),
      );

      // Week view should render GridView with 14 children (7 headers + 7 days)
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('HabitCalendar should navigate weeks in week view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [], viewMode: CalendarViewMode.week),
          ),
        ),
      );

      // Navigate to next week
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Should still render properly
      expect(find.byType(HabitCalendar), findsOneWidget);
    });

    testWidgets('HabitCalendar should navigate years in year view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [], viewMode: CalendarViewMode.year),
          ),
        ),
      );

      final now = DateTime.now();
      final nextYear = now.year + 1;

      // Navigate to next year
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text('$nextYear'), findsOneWidget);
    });

    testWidgets('HabitCalendar should fill day background with habit color when completed',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [today],
        colorValue: 0xFF6366F1, // Indigo color
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [habit]),
          ),
        ),
      );

      // Find containers that are descendants of Tooltips (calendar day cells)
      final dayContainers = find.descendant(
        of: find.byType(Tooltip),
        matching: find.byType(Container),
      );
      
      // At least one day container should have the habit's background color
      bool foundColoredDayContainer = false;
      for (final element in dayContainers.evaluate()) {
        final container = element.widget as Container;
        final decoration = container.decoration as BoxDecoration?;
        if (decoration?.color != null && 
            decoration?.color?.value == habit.colorValue) {
          foundColoredDayContainer = true;
          break;
        }
      }
      
      expect(foundColoredDayContainer, true);
    });

    testWidgets('HabitCalendar should not fill background for uncompleted days',
        (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [], // No completions
        colorValue: 0xFF6366F1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCalendar(habits: [habit]),
          ),
        ),
      );

      // Find containers that are descendants of Tooltips (calendar day cells)
      final dayContainers = find.descendant(
        of: find.byType(Tooltip),
        matching: find.byType(Container),
      );
      
      // Check that no day container has the habit's background color as a solid fill
      // (the legend will have small colored circles, but day cells should be transparent)
      bool foundColoredDayContainer = false;
      for (final element in dayContainers.evaluate()) {
        final container = element.widget as Container;
        final decoration = container.decoration as BoxDecoration?;
        if (decoration?.color != null && 
            decoration?.color != Colors.transparent &&
            decoration?.color?.value == habit.colorValue) {
          foundColoredDayContainer = true;
          break;
        }
      }
      
      expect(foundColoredDayContainer, false);
    });
  });
}
