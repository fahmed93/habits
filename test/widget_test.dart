import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

// Mock Firebase setup for testing
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': {},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }

    return null;
  });
}

void main() {
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HabitsApp Widget Tests', () {
    testWidgets('HabitsApp should create MaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(const HabitsApp());
      
      // The app should be created
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('HabitsApp should use Material 3', (WidgetTester tester) async {
      await tester.pumpWidget(const HabitsApp());
      await tester.pumpAndSettle();
      
      // Verify Material 3 is being used
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, true);
    });
  });
}
