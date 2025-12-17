import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/screens/about_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AboutScreen Widget Tests', () {
    testWidgets('AboutScreen should display app name and version',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Habit Tracker'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    testWidgets('AboutScreen should display app description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('About This App'), findsOneWidget);
      expect(
        find.textContaining(
            'A mobile habit tracker app built with Flutter and Firebase Authentication'),
        findsOneWidget,
      );
    });

    testWidgets('AboutScreen should display features section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('Features'), findsOneWidget);
      expect(
        find.textContaining('Create custom habits with different intervals'),
        findsOneWidget,
      );
    });

    testWidgets('AboutScreen should display developer section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('Developer'), findsOneWidget);
      expect(find.textContaining('Built with'), findsOneWidget);
    });

    testWidgets('AboutScreen should display license section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('License'), findsOneWidget);
      expect(find.text('Open Source Project'), findsOneWidget);
    });

    testWidgets('AboutScreen should have a back button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('AboutScreen back button should pop navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
                child: const Text('Open About'),
              ),
            ),
          ),
        ),
      );

      // Navigate to AboutScreen
      await tester.tap(find.text('Open About'));
      await tester.pumpAndSettle();

      // Verify we're on AboutScreen
      expect(find.text('About'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Verify we're back to the original screen
      expect(find.text('Open About'), findsOneWidget);
      expect(find.text('About'), findsNothing);
    });
  });
}
