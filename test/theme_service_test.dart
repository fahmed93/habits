import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeService Tests', () {
    late ThemeService themeService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      themeService = ThemeService();
    });

    test('getThemeMode should return system theme when no preference is saved',
        () async {
      final themeMode = await themeService.getThemeMode();
      
      expect(themeMode, ThemeMode.system);
    });

    test('setThemeMode and getThemeMode should persist light theme', () async {
      await themeService.setThemeMode(ThemeMode.light);
      final themeMode = await themeService.getThemeMode();
      
      expect(themeMode, ThemeMode.light);
    });

    test('setThemeMode and getThemeMode should persist dark theme', () async {
      await themeService.setThemeMode(ThemeMode.dark);
      final themeMode = await themeService.getThemeMode();
      
      expect(themeMode, ThemeMode.dark);
    });

    test('setThemeMode and getThemeMode should persist system theme', () async {
      await themeService.setThemeMode(ThemeMode.system);
      final themeMode = await themeService.getThemeMode();
      
      expect(themeMode, ThemeMode.system);
    });

    test('getThemeMode should handle corrupted preference data gracefully',
        () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': 'invalid_value',
      });
      
      final themeMode = await themeService.getThemeMode();
      
      expect(themeMode, ThemeMode.system); // Should return default
    });
  });
}
