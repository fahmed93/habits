import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/notification_settings.dart';

void main() {
  group('NotificationSettings Model Tests', () {
    test('NotificationSettings toJson and fromJson should work correctly', () {
      const settings = NotificationSettings(
        enabled: true,
        reminderTime: '10:30',
        dailyReminder: true,
        weeklyReminder: false,
        monthlyReminder: true,
      );

      final json = settings.toJson();
      final settingsFromJson = NotificationSettings.fromJson(json);

      expect(settingsFromJson.enabled, settings.enabled);
      expect(settingsFromJson.reminderTime, settings.reminderTime);
      expect(settingsFromJson.dailyReminder, settings.dailyReminder);
      expect(settingsFromJson.weeklyReminder, settings.weeklyReminder);
      expect(settingsFromJson.monthlyReminder, settings.monthlyReminder);
    });

    test('NotificationSettings should use default values', () {
      const settings = NotificationSettings();

      expect(settings.enabled, false);
      expect(settings.reminderTime, '09:00');
      expect(settings.dailyReminder, true);
      expect(settings.weeklyReminder, true);
      expect(settings.monthlyReminder, true);
    });

    test('NotificationSettings fromJson should use defaults for missing fields',
        () {
      final json = <String, dynamic>{};

      final settings = NotificationSettings.fromJson(json);

      expect(settings.enabled, false);
      expect(settings.reminderTime, '09:00');
      expect(settings.dailyReminder, true);
      expect(settings.weeklyReminder, true);
      expect(settings.monthlyReminder, true);
    });

    test('NotificationSettings copyWith should create new instance with updated fields',
        () {
      const settings = NotificationSettings(
        enabled: false,
        reminderTime: '09:00',
        dailyReminder: true,
        weeklyReminder: true,
        monthlyReminder: true,
      );

      final updatedSettings = settings.copyWith(
        enabled: true,
        reminderTime: '14:00',
      );

      expect(updatedSettings.enabled, true);
      expect(updatedSettings.reminderTime, '14:00');
      expect(updatedSettings.dailyReminder, settings.dailyReminder);
      expect(updatedSettings.weeklyReminder, settings.weeklyReminder);
      expect(updatedSettings.monthlyReminder, settings.monthlyReminder);
    });

    test('NotificationSettings copyWith should preserve unmodified fields', () {
      const settings = NotificationSettings(
        enabled: true,
        reminderTime: '10:30',
        dailyReminder: false,
        weeklyReminder: false,
        monthlyReminder: false,
      );

      final updatedSettings = settings.copyWith(dailyReminder: true);

      expect(updatedSettings.enabled, settings.enabled);
      expect(updatedSettings.reminderTime, settings.reminderTime);
      expect(updatedSettings.dailyReminder, true);
      expect(updatedSettings.weeklyReminder, settings.weeklyReminder);
      expect(updatedSettings.monthlyReminder, settings.monthlyReminder);
    });

    test('NotificationSettings toJson should include all fields', () {
      const settings = NotificationSettings(
        enabled: true,
        reminderTime: '10:30',
        dailyReminder: false,
        weeklyReminder: true,
        monthlyReminder: false,
      );

      final json = settings.toJson();

      expect(json.containsKey('enabled'), true);
      expect(json.containsKey('reminderTime'), true);
      expect(json.containsKey('dailyReminder'), true);
      expect(json.containsKey('weeklyReminder'), true);
      expect(json.containsKey('monthlyReminder'), true);
    });

    test('NotificationSettings fromJson and toJson should be symmetric', () {
      const originalSettings = NotificationSettings(
        enabled: true,
        reminderTime: '14:30',
        dailyReminder: false,
        weeklyReminder: false,
        monthlyReminder: true,
      );

      final json = originalSettings.toJson();
      final deserializedSettings = NotificationSettings.fromJson(json);

      expect(deserializedSettings.enabled, originalSettings.enabled);
      expect(deserializedSettings.reminderTime, originalSettings.reminderTime);
      expect(deserializedSettings.dailyReminder, originalSettings.dailyReminder);
      expect(deserializedSettings.weeklyReminder, originalSettings.weeklyReminder);
      expect(deserializedSettings.monthlyReminder, originalSettings.monthlyReminder);
    });

    test('NotificationSettings copyWith with all null should preserve all fields', () {
      const settings = NotificationSettings(
        enabled: true,
        reminderTime: '15:00',
        dailyReminder: false,
        weeklyReminder: true,
        monthlyReminder: false,
      );

      final updatedSettings = settings.copyWith();

      expect(updatedSettings.enabled, settings.enabled);
      expect(updatedSettings.reminderTime, settings.reminderTime);
      expect(updatedSettings.dailyReminder, settings.dailyReminder);
      expect(updatedSettings.weeklyReminder, settings.weeklyReminder);
      expect(updatedSettings.monthlyReminder, settings.monthlyReminder);
    });

    test('NotificationSettings should handle various time formats', () {
      const settings1 = NotificationSettings(reminderTime: '00:00');
      const settings2 = NotificationSettings(reminderTime: '23:59');
      const settings3 = NotificationSettings(reminderTime: '12:30');

      expect(settings1.reminderTime, '00:00');
      expect(settings2.reminderTime, '23:59');
      expect(settings3.reminderTime, '12:30');
    });

    test('NotificationSettings copyWith should update multiple fields at once', () {
      const settings = NotificationSettings();

      final updatedSettings = settings.copyWith(
        enabled: true,
        reminderTime: '20:00',
        dailyReminder: false,
      );

      expect(updatedSettings.enabled, true);
      expect(updatedSettings.reminderTime, '20:00');
      expect(updatedSettings.dailyReminder, false);
      // These should remain default
      expect(updatedSettings.weeklyReminder, true);
      expect(updatedSettings.monthlyReminder, true);
    });
  });
}
