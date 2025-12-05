import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/main.dart';

void main() {
  testWidgets('App should launch and show Habit Tracker title', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitsApp());

    expect(find.text('Habit Tracker'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Should show empty state when no habits', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitsApp());
    await tester.pumpAndSettle();

    expect(find.text('No habits yet'), findsOneWidget);
    expect(find.text('Tap the + button to add a habit'), findsOneWidget);
  });
}
