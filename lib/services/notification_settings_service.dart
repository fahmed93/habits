import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_settings.dart';

class NotificationSettingsService {
  static const String _settingsKey = 'notification_settings';
  final String? userId;

  NotificationSettingsService({this.userId});

  String get _storageKey =>
      userId != null ? 'notification_settings_$userId' : _settingsKey;

  // Save notification settings to local storage
  Future<void> saveSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(settings.toJson()));
  }

  // Load notification settings from local storage
  Future<NotificationSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString(_storageKey);

      if (settingsString == null) {
        return const NotificationSettings();
      }

      final settingsJson = jsonDecode(settingsString);
      return NotificationSettings.fromJson(settingsJson);
    } catch (e) {
      // Return default settings if data is corrupted
      return const NotificationSettings();
    }
  }
}
