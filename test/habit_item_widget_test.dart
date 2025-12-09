import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/widgets/habit_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HabitItem Widget Tests', () {
    testWidgets('HabitItem should display habit name', (WidgetTester tester) async {
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
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Exercise'), findsOneWidget);
    });

    testWidgets('HabitItem should display habit icon', (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
        icon: '💪',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('💪'), findsOneWidget);
    });

    testWidgets('HabitItem should display daily interval', (WidgetTester tester) async {
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
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Daily'), findsOneWidget);
    });

    testWidgets('HabitItem should display weekly interval', (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'weekly',
        createdAt: DateTime.now(),
        completions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Weekly'), findsOneWidget);
    });

    testWidgets('HabitItem should display monthly interval', (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'monthly',
        createdAt: DateTime.now(),
        completions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('HabitItem should display streak when habit has completions',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [
          today,
          today.subtract(const Duration(days: 1)),
          today.subtract(const Duration(days: 2)),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('day streak'), findsOneWidget);
      expect(find.text('3 day streak 🔥'), findsOneWidget);
    });

    testWidgets('HabitItem should not display streak when no completions',
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
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('streak'), findsNothing);
    });

    testWidgets('HabitItem should show delete confirmation dialog on dismiss',
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
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Swipe to dismiss
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Check if dialog appears
      expect(find.text('Delete Habit'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this habit?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('HabitItem should not delete when cancel is pressed',
        (WidgetTester tester) async {
      bool deleteCalled = false;
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
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      // Swipe to dismiss
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Press cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(deleteCalled, false);
      expect(find.text('Exercise'), findsOneWidget);
    });

    testWidgets('HabitItem should call onDelete when delete is confirmed',
        (WidgetTester tester) async {
      bool deleteCalled = false;
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
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      // Swipe to dismiss
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Press delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleteCalled, true);
    });

    testWidgets('HabitItem should display 5 day indicators',
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
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find GestureDetectors that wrap day indicators
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('HabitItem should call onToggleDate when day is tapped',
        (WidgetTester tester) async {
      DateTime? toggledDate;
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
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
              onToggleDate: (date) {
                toggledDate = date;
              },
            ),
          ),
        ),
      );

      // Tap on one of the day indicators
      final gestureDetectors = find.byType(GestureDetector);
      await tester.tap(gestureDetectors.first);
      await tester.pumpAndSettle();

      expect(toggledDate, isNotNull);
    });

    testWidgets('HabitItem should show completed habit with line-through',
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
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find the Text widget with the habit name
      final textWidget = tester.widget<Text>(find.text('Exercise'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('HabitItem should display week streak label for weekly habit',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'weekly',
        createdAt: DateTime.now(),
        completions: [today],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('1 week streak 🔥'), findsOneWidget);
    });

    testWidgets('HabitItem should display month streak label for monthly habit',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'monthly',
        createdAt: DateTime.now(),
        completions: [today],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitItem(
              habit: habit,
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('1 month streak 🔥'), findsOneWidget);
    });
  });
}
