import 'package:flutter/material.dart';
import '../models/notification_settings.dart';
import '../services/notification_settings_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final String? userId;

  const NotificationSettingsScreen({super.key, this.userId});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late final NotificationSettingsService _service;
  NotificationSettings _settings = const NotificationSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = NotificationSettingsService(userId: widget.userId);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings(NotificationSettings newSettings) async {
    await _service.saveSettings(newSettings);
    setState(() {
      _settings = newSettings;
    });
  }

  Future<void> _selectTime() async {
    try {
      final timeParts = _settings.reminderTime.split(':');
      if (timeParts.length != 2) {
        // Invalid format, use default
        timeParts.clear();
        timeParts.addAll(['9', '0']);
      }

      final initialTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );

      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (picked != null) {
        final timeString =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        await _saveSettings(_settings.copyWith(reminderTime: timeString));
      }
    } catch (e) {
      // If parsing fails, use default time
      final initialTime = const TimeOfDay(hour: 9, minute: 0);

      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (picked != null) {
        final timeString =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        await _saveSettings(_settings.copyWith(reminderTime: timeString));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Notification Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Turn on habit reminder notifications'),
            value: _settings.enabled,
            onChanged: (value) {
              _saveSettings(_settings.copyWith(enabled: value));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Reminder Time'),
            subtitle: Text(_settings.reminderTime),
            trailing: const Icon(Icons.chevron_right),
            enabled: _settings.enabled,
            onTap: _settings.enabled ? _selectTime : null,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Reminder Types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.today),
            title: const Text('Daily Habits'),
            subtitle: const Text('Remind me about daily habits'),
            value: _settings.dailyReminder,
            onChanged: _settings.enabled
                ? (value) {
                    _saveSettings(_settings.copyWith(dailyReminder: value));
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.calendar_today),
            title: const Text('Weekly Habits'),
            subtitle: const Text('Remind me about weekly habits'),
            value: _settings.weeklyReminder,
            onChanged: _settings.enabled
                ? (value) {
                    _saveSettings(_settings.copyWith(weeklyReminder: value));
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.calendar_month),
            title: const Text('Monthly Habits'),
            subtitle: const Text('Remind me about monthly habits'),
            value: _settings.monthlyReminder,
            onChanged: _settings.enabled
                ? (value) {
                    _saveSettings(_settings.copyWith(monthlyReminder: value));
                  }
                : null,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Note: Notification functionality requires additional system permissions and will be fully implemented in a future update.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
