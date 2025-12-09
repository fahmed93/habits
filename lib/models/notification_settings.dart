class NotificationSettings {
  final bool enabled;
  final String reminderTime; // Format: "HH:mm"
  final bool dailyReminder;
  final bool weeklyReminder;
  final bool monthlyReminder;

  const NotificationSettings({
    this.enabled = false,
    this.reminderTime = '09:00',
    this.dailyReminder = true,
    this.weeklyReminder = true,
    this.monthlyReminder = true,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'reminderTime': reminderTime,
      'dailyReminder': dailyReminder,
      'weeklyReminder': weeklyReminder,
      'monthlyReminder': monthlyReminder,
    };
  }

  // Create from JSON
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? false,
      reminderTime: json['reminderTime'] ?? '09:00',
      dailyReminder: json['dailyReminder'] ?? true,
      weeklyReminder: json['weeklyReminder'] ?? true,
      monthlyReminder: json['monthlyReminder'] ?? true,
    );
  }

  // Create a copy with updated fields
  NotificationSettings copyWith({
    bool? enabled,
    String? reminderTime,
    bool? dailyReminder,
    bool? weeklyReminder,
    bool? monthlyReminder,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      reminderTime: reminderTime ?? this.reminderTime,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      weeklyReminder: weeklyReminder ?? this.weeklyReminder,
      monthlyReminder: monthlyReminder ?? this.monthlyReminder,
    );
  }
}
