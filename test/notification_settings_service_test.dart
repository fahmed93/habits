import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/notification_settings.dart';
import 'package:habits/services/notification_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationSettingsService Tests', () {
    late NotificationSettingsService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = NotificationSettingsService();
    });

    test('loadSettings should return default settings when no data exists',
        () async {
      final settings = await service.loadSettings();

      expect(settings.enabled, false);
      expect(settings.reminderTime, '09:00');
      expect(settings.dailyReminder, true);
      expect(settings.weeklyReminder, true);
      expect(settings.monthlyReminder, true);
    });

    test('saveSettings and loadSettings should persist settings correctly',
        () async {
      const settings = NotificationSettings(
        enabled: true,
        reminderTime: '10:30',
        dailyReminder: false,
        weeklyReminder: true,
        monthlyReminder: false,
      );

      await service.saveSettings(settings);
      final loadedSettings = await service.loadSettings();

      expect(loadedSettings.enabled, settings.enabled);
      expect(loadedSettings.reminderTime, settings.reminderTime);
      expect(loadedSettings.dailyReminder, settings.dailyReminder);
      expect(loadedSettings.weeklyReminder, settings.weeklyReminder);
      expect(loadedSettings.monthlyReminder, settings.monthlyReminder);
    });

    test('saveSettings should overwrite existing settings', () async {
      const initialSettings = NotificationSettings(
        enabled: true,
        reminderTime: '09:00',
      );

      await service.saveSettings(initialSettings);

      const updatedSettings = NotificationSettings(
        enabled: false,
        reminderTime: '14:00',
      );

      await service.saveSettings(updatedSettings);
      final loadedSettings = await service.loadSettings();

      expect(loadedSettings.enabled, false);
      expect(loadedSettings.reminderTime, '14:00');
    });

    test('loadSettings should return default settings on corrupted data',
        () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_settings', 'invalid json');

      final settings = await service.loadSettings();

      expect(settings.enabled, false);
      expect(settings.reminderTime, '09:00');
    });

    test(
        'NotificationSettingsService should use user-scoped key when userId provided',
        () async {
      final userService = NotificationSettingsService(userId: 'user123');

      const settings = NotificationSettings(
        enabled: true,
        reminderTime: '11:00',
      );

      await userService.saveSettings(settings);

      // Verify it's stored with user-scoped key
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('notification_settings_user123'), true);
      expect(prefs.containsKey('notification_settings'), false);
    });

    test('NotificationSettingsService should isolate data between users',
        () async {
      final user1Service = NotificationSettingsService(userId: 'user1');
      final user2Service = NotificationSettingsService(userId: 'user2');

      const user1Settings = NotificationSettings(
        enabled: true,
        reminderTime: '08:00',
      );

      const user2Settings = NotificationSettings(
        enabled: false,
        reminderTime: '20:00',
      );

      await user1Service.saveSettings(user1Settings);
      await user2Service.saveSettings(user2Settings);

      final loadedUser1Settings = await user1Service.loadSettings();
      final loadedUser2Settings = await user2Service.loadSettings();

      expect(loadedUser1Settings.enabled, true);
      expect(loadedUser1Settings.reminderTime, '08:00');
      expect(loadedUser2Settings.enabled, false);
      expect(loadedUser2Settings.reminderTime, '20:00');
    });

    test('saveSettings should handle all boolean combinations', () async {
      const settings = NotificationSettings(
        enabled: true,
        reminderTime: '12:00',
        dailyReminder: false,
        weeklyReminder: false,
        monthlyReminder: false,
      );

      await service.saveSettings(settings);
      final loadedSettings = await service.loadSettings();

      expect(loadedSettings.dailyReminder, false);
      expect(loadedSettings.weeklyReminder, false);
      expect(loadedSettings.monthlyReminder, false);
    });
  });
}
