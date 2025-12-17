import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/models/notification_settings.dart';
import 'package:habits/services/data_export_import_service.dart';
import 'package:habits/services/habit_storage.dart';
import 'package:habits/services/notification_settings_service.dart';
import 'package:habits/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  group('DataExportImportService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Export data should include all user data', () async {
      const userId = 'test_user_123';
      final exportService = DataExportImportService(userId: userId);
      final habitStorage = HabitStorage(userId: userId);
      final notificationService = NotificationSettingsService(userId: userId);
      final themeService = ThemeService();

      // Create test data
      final testHabit = Habit(
        id: '1',
        name: 'Test Habit',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [DateTime(2024, 1, 1), DateTime(2024, 1, 2)],
        colorValue: 0xFF6366F1,
        icon: '✓',
      );

      final testSettings = const NotificationSettings(
        enabled: true,
        reminderTime: '09:00',
        dailyReminder: true,
        weeklyReminder: false,
        monthlyReminder: true,
      );

      // Save test data
      await habitStorage.saveHabits([testHabit]);
      await notificationService.saveSettings(testSettings);
      await themeService.setThemeMode(ThemeMode.dark);

      // Export data
      final exportedData = await exportService.exportData();

      // Verify exported data structure
      expect(exportedData.containsKey('version'), true);
      expect(exportedData.containsKey('exportDate'), true);
      expect(exportedData.containsKey('userId'), true);
      expect(exportedData.containsKey('habits'), true);
      expect(exportedData.containsKey('notificationSettings'), true);
      expect(exportedData.containsKey('themeMode'), true);

      // Verify content
      expect(exportedData['userId'], userId);
      expect(exportedData['version'], '1.0.0');
      
      final habits = exportedData['habits'] as List<dynamic>;
      expect(habits.length, 1);
      expect(habits[0]['id'], '1');
      expect(habits[0]['name'], 'Test Habit');

      final settings = exportedData['notificationSettings'] as Map<String, dynamic>;
      expect(settings['enabled'], true);
      expect(settings['reminderTime'], '09:00');

      expect(exportedData['themeMode'], 'dark');
    });

    test('Export data should handle empty habits', () async {
      const userId = 'test_user_empty';
      final exportService = DataExportImportService(userId: userId);

      final exportedData = await exportService.exportData();

      expect(exportedData.containsKey('habits'), true);
      final habits = exportedData['habits'] as List<dynamic>;
      expect(habits, isEmpty);
    });

    test('Import data should restore all user data', () async {
      const userId = 'test_user_import';
      final importService = DataExportImportService(userId: userId);
      final habitStorage = HabitStorage(userId: userId);
      final notificationService = NotificationSettingsService(userId: userId);
      final themeService = ThemeService();

      // Create test import data
      final importData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'habits': [
          {
            'id': '1',
            'name': 'Imported Habit',
            'interval': 'weekly',
            'createdAt': DateTime(2024, 1, 1).toIso8601String(),
            'completions': [
              DateTime(2024, 1, 1).toIso8601String(),
              DateTime(2024, 1, 8).toIso8601String(),
            ],
            'colorValue': 0xFFEC4899,
            'icon': '💪',
          },
        ],
        'notificationSettings': {
          'enabled': false,
          'reminderTime': '10:00',
          'dailyReminder': false,
          'weeklyReminder': true,
          'monthlyReminder': false,
        },
        'themeMode': 'light',
      };

      // Import data
      await importService.importData(importData);

      // Verify imported habits
      final habits = await habitStorage.loadHabits();
      expect(habits.length, 1);
      expect(habits[0].id, '1');
      expect(habits[0].name, 'Imported Habit');
      expect(habits[0].interval, 'weekly');
      expect(habits[0].completions.length, 2);
      expect(habits[0].colorValue, 0xFFEC4899);
      expect(habits[0].icon, '💪');

      // Verify imported notification settings
      final settings = await notificationService.loadSettings();
      expect(settings.enabled, false);
      expect(settings.reminderTime, '10:00');
      expect(settings.dailyReminder, false);
      expect(settings.weeklyReminder, true);
      expect(settings.monthlyReminder, false);

      // Verify imported theme mode
      final themeMode = await themeService.getThemeMode();
      expect(themeMode, ThemeMode.light);
    });

    test('Import data should handle invalid format', () async {
      const userId = 'test_user_invalid';
      final importService = DataExportImportService(userId: userId);

      // Test with missing version
      final invalidData1 = {
        'habits': [],
      };

      expect(
        () => importService.importData(invalidData1),
        throwsException,
      );

      // Test with missing habits
      final invalidData2 = {
        'version': '1.0.0',
      };

      expect(
        () => importService.importData(invalidData2),
        throwsException,
      );
    });

    test('Import data should handle partial data', () async {
      const userId = 'test_user_partial';
      final importService = DataExportImportService(userId: userId);
      final habitStorage = HabitStorage(userId: userId);

      // Import data with only habits, no settings
      final partialData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'habits': [
          {
            'id': '1',
            'name': 'Partial Habit',
            'interval': 'daily',
            'createdAt': DateTime(2024, 1, 1).toIso8601String(),
            'completions': [],
          },
        ],
      };

      await importService.importData(partialData);

      // Verify habits were imported
      final habits = await habitStorage.loadHabits();
      expect(habits.length, 1);
      expect(habits[0].name, 'Partial Habit');
    });

    test('Import data should replace existing data', () async {
      const userId = 'test_user_replace';
      final importService = DataExportImportService(userId: userId);
      final habitStorage = HabitStorage(userId: userId);

      // Create initial data
      final initialHabit = Habit(
        id: 'old',
        name: 'Old Habit',
        interval: 'daily',
        createdAt: DateTime(2024, 1, 1),
        completions: [],
      );
      await habitStorage.saveHabits([initialHabit]);

      // Import new data
      final importData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'habits': [
          {
            'id': 'new',
            'name': 'New Habit',
            'interval': 'weekly',
            'createdAt': DateTime(2024, 2, 1).toIso8601String(),
            'completions': [],
          },
        ],
      };

      await importService.importData(importData);

      // Verify old data was replaced
      final habits = await habitStorage.loadHabits();
      expect(habits.length, 1);
      expect(habits[0].id, 'new');
      expect(habits[0].name, 'New Habit');
    });

    test('Import should handle different theme modes', () async {
      const userId = 'test_theme';
      final importService = DataExportImportService(userId: userId);
      final themeService = ThemeService();

      // Test light theme
      await importService.importData({
        'version': '1.0.0',
        'habits': [],
        'themeMode': 'light',
      });
      expect(await themeService.getThemeMode(), ThemeMode.light);

      // Test dark theme
      await importService.importData({
        'version': '1.0.0',
        'habits': [],
        'themeMode': 'dark',
      });
      expect(await themeService.getThemeMode(), ThemeMode.dark);

      // Test system theme
      await importService.importData({
        'version': '1.0.0',
        'habits': [],
        'themeMode': 'system',
      });
      expect(await themeService.getThemeMode(), ThemeMode.system);

      // Test invalid theme (should default to system)
      await importService.importData({
        'version': '1.0.0',
        'habits': [],
        'themeMode': 'invalid',
      });
      expect(await themeService.getThemeMode(), ThemeMode.system);
    });

    test('Export should include export date', () async {
      final exportService = DataExportImportService(userId: 'test');
      final beforeExport = DateTime.now();
      
      final exportedData = await exportService.exportData();
      
      final afterExport = DateTime.now();
      final exportDate = DateTime.parse(exportedData['exportDate'] as String);
      
      expect(exportDate.isAfter(beforeExport.subtract(const Duration(seconds: 1))), true);
      expect(exportDate.isBefore(afterExport.add(const Duration(seconds: 1))), true);
    });
  });
}
