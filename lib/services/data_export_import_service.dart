import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/habit.dart';
import '../models/notification_settings.dart';
import 'habit_storage.dart';
import 'notification_settings_service.dart';
import 'theme_service.dart';

class DataExportImportService {
  final String? userId;

  DataExportImportService({this.userId});

  /// Export all user data to JSON format
  Future<Map<String, dynamic>> exportData() async {
    final habitStorage = HabitStorage(userId: userId);
    final notificationService = NotificationSettingsService(userId: userId);
    final themeService = ThemeService();

    final habits = await habitStorage.loadHabits();
    final notificationSettings = await notificationService.loadSettings();
    final themeMode = await themeService.getThemeMode();

    return {
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'userId': userId,
      'habits': habits.map((habit) => habit.toJson()).toList(),
      'notificationSettings': notificationSettings.toJson(),
      'themeMode': themeMode.toString().split('.').last, // 'light', 'dark', 'system'
    };
  }

  /// Export data to a file and share it
  Future<void> exportToFile() async {
    try {
      final data = await exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'habits_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      // Write JSON to file
      await file.writeAsString(jsonString);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Habits Backup',
        text: 'Export of your habits data',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Import data from JSON format
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Validate data structure
      if (!data.containsKey('version') || !data.containsKey('habits')) {
        throw Exception('Invalid backup file format');
      }

      final habitStorage = HabitStorage(userId: userId);
      final notificationService = NotificationSettingsService(userId: userId);
      final themeService = ThemeService();

      // Import habits
      if (data.containsKey('habits')) {
        final habitsJson = data['habits'] as List<dynamic>;
        final habits = habitsJson
            .map((json) => Habit.fromJson(json as Map<String, dynamic>))
            .toList();
        await habitStorage.saveHabits(habits);
      }

      // Import notification settings
      if (data.containsKey('notificationSettings')) {
        final settingsJson =
            data['notificationSettings'] as Map<String, dynamic>;
        final settings = NotificationSettings.fromJson(settingsJson);
        await notificationService.saveSettings(settings);
      }

      // Import theme mode
      if (data.containsKey('themeMode')) {
        final themeModeString = data['themeMode'] as String;
        ThemeMode themeMode;
        switch (themeModeString.toLowerCase()) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            themeMode = ThemeMode.system;
            break;
        }
        await themeService.setThemeMode(themeMode);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Import data from a file selected by user
  Future<void> importFromFile() async {
    try {
      // Pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      await importData(data);
    } catch (e) {
      rethrow;
    }
  }
}
