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
  });
}
