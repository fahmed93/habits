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
        name: 'Reading',
        interval: 'daily',
        createdAt: DateTime.now(),
        completions: [],
        icon: '📚',
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

      expect(find.text('📚'), findsOneWidget);
    });
  });
}
