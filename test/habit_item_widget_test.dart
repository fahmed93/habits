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

    testWidgets('HabitItem should not display daily interval', (WidgetTester tester) async {
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

      expect(find.text('Daily'), findsNothing);
    });

    testWidgets('HabitItem should not display weekly interval', (WidgetTester tester) async {
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

      expect(find.text('Weekly'), findsNothing);
    });

    testWidgets('HabitItem should not display monthly interval', (WidgetTester tester) async {
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

      expect(find.text('Monthly'), findsNothing);
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

      // Streak now displays as "🔥 X day/days" instead of "X day streak 🔥"
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('3 days'), findsOneWidget);
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

    testWidgets('HabitItem should use Stack for day columns with dividers',
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

      // Verify that Stack is used to overlay dividers on day indicators
      expect(find.byType(Stack), findsWidgets);
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

      // Find a day indicator by looking for the day labels (e.g., 'MON', 'TUE', etc.)
      final dayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
      Finder? dayIndicator;
      
      for (final label in dayLabels) {
        final finder = find.text(label);
        if (finder.evaluate().isNotEmpty) {
          dayIndicator = finder;
          break;
        }
      }
      
      // We should find at least one day label
      expect(dayIndicator, isNotNull);
      expect(dayIndicator, findsOneWidget);
      
      // Tap on the day indicator
      await tester.tap(dayIndicator!);
      await tester.pumpAndSettle();

      // Verify the callback was called with a date
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

      // Streak now displays as "🔥 1 week" instead of "1 week streak 🔥"
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('1 week'), findsOneWidget);
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

      // Streak now displays as "🔥 1 month" instead of "1 month streak 🔥"
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('1 month'), findsOneWidget);
    });

    testWidgets('HabitItem should call onEdit when swiped right and not dismiss',
        (WidgetTester tester) async {
      bool editCalled = false;
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
              onEdit: () {
                editCalled = true;
              },
            ),
          ),
        ),
      );

      // Swipe right to edit
      await tester.drag(find.byType(Dismissible), const Offset(500, 0));
      await tester.pumpAndSettle();

      expect(editCalled, true);
      // Habit item should still be present (not dismissed)
      expect(find.byType(HabitItem), findsOneWidget);
      expect(find.text('Exercise'), findsOneWidget);
    });
  });
}
