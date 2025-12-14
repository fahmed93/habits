import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/screens/edit_habit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('EditHabitScreen Widget Tests', () {
    testWidgets('EditHabitScreen should display habit name in text field',
        (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
        colorValue: 0xFF6366F1,
        icon: '💪',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditHabitScreen(
            userId: 'test_user',
            habit: habit,
          ),
        ),
      );

      expect(find.text('Edit Habit'), findsOneWidget);
      expect(find.text('Exercise'), findsOneWidget);
    });

    testWidgets('EditHabitScreen should pre-populate all fields',
        (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Read Books',
        interval: 'weekly',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
        colorValue: 0xFFEC4899,
        icon: '📚',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditHabitScreen(
            userId: 'test_user',
            habit: habit,
          ),
        ),
      );

      // Verify habit name
      expect(find.text('Read Books'), findsOneWidget);
      
      // Verify icon preview
      expect(find.text('📚'), findsWidgets);
      
      // Verify interval is selected (Weekly radio button should be selected)
      expect(find.text('Weekly'), findsOneWidget);
    });

    testWidgets('EditHabitScreen should have Save Changes button',
        (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditHabitScreen(
            userId: 'test_user',
            habit: habit,
          ),
        ),
      );

      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('EditHabitScreen should show validation error for empty name',
        (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditHabitScreen(
            userId: 'test_user',
            habit: habit,
          ),
        ),
      );

      // Clear the text field
      final textField = find.widgetWithText(TextFormField, 'Exercise');
      await tester.enterText(textField, '');
      await tester.pump();
      
      // Scroll to make the Save Changes button visible
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.pump();
      
      // Tap Save Changes button
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      // Verify validation error appears
      expect(find.text('Please enter a habit name'), findsOneWidget);
    });
  });
}
