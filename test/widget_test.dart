import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/widgets/habit_item.dart';

void main() {
  testWidgets('HabitItem should display habit name', (WidgetTester tester) async {
    final habit = Habit(
      id: '1',
      name: 'Test Habit',
      interval: 'daily',
      completions: [],
      colorValue: 0xFF4CAF50,
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

    expect(find.text('Test Habit'), findsOneWidget);
  });

  testWidgets('HabitItem should display habit icon', (WidgetTester tester) async {
    final habit = Habit(
      id: '2',
      name: 'Exercise',
      interval: 'daily',
      completions: [],
      colorValue: 0xFFFF5722,
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
    expect(find.text('Exercise'), findsOneWidget);
  });
}
