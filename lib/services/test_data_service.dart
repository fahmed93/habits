import 'dart:math';
import '../models/habit.dart';

class TestDataService {
  static final Random _random = Random();
  static const int _historicalDays = 365;

  // List of habit names for random selection
  static const List<String> habitNames = [
    'Morning Exercise',
    'Read for 30 min',
    'Drink 8 glasses of water',
    'Meditate',
    'Practice gratitude',
    'Learn something new',
    'Take a walk',
    'Healthy breakfast',
    'Journal writing',
    'Stretch',
    'No social media',
    'Early to bed',
    'Call a friend',
    'Practice a skill',
    'Clean workspace',
  ];

  // List of emojis for random selection
  static const List<String> habitEmojis = [
    '💪', '📚', '💧', '🧘', '🙏',
    '🧠', '🚶', '🥗', '📝', '🤸',
    '📵', '😴', '📞', '🎯', '🧹',
    '🏃', '🎨', '🎵', '☕', '🌱',
    '✨', '🔥', '⭐', '💡',
  ];

  /// Generate 5 random habits with unique names, emojis, and colors
  static List<Habit> generateRandomHabits() {
    final selectedNames = <String>[];
    final habits = <Habit>[];
    final now = DateTime.now();

    // Select 5 unique habit names
    while (selectedNames.length < 5) {
      final name = habitNames[_random.nextInt(habitNames.length)];
      if (!selectedNames.contains(name)) {
        selectedNames.add(name);
      }
    }

    for (int i = 0; i < 5; i++) {
      // Generate unique ID (same pattern as AddHabitScreen, with +i to prevent collisions)
      final id = (now.millisecondsSinceEpoch + i).toString();
      
      // Select random emoji
      final emoji = habitEmojis[_random.nextInt(habitEmojis.length)];
      
      // Select random color from palette
      final color = Habit.habitColors[_random.nextInt(Habit.habitColors.length)];
      
      // Create habit with 365 days of historical data
      final habit = Habit(
        id: id,
        name: selectedNames[i],
        interval: 'daily',
        createdAt: now.subtract(Duration(days: _historicalDays)),
        completions: _generate365DaysOfData(now),
        colorValue: color,
        icon: emoji,
      );
      
      habits.add(habit);
    }

    return habits;
  }

  /// Generate 365 days of completion data with realistic patterns
  /// Some days completed, some not, to simulate real usage
  static List<DateTime> _generate365DaysOfData(DateTime endDate) {
    final completions = <DateTime>[];
    
    // Generate completions for the past 365 days (from 365 days ago to yesterday)
    // Use a success rate between 50-85% to make it realistic
    final successRate = 0.50 + (_random.nextDouble() * 0.35);
    
    for (int i = 0; i < _historicalDays; i++) {
      // Calculate date: when i=0, we get (endDate - 365 days); when i=364, we get (endDate - 1 day)
      final date = endDate.subtract(Duration(days: _historicalDays - i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      // Randomly decide if this day was completed based on success rate
      if (_random.nextDouble() < successRate) {
        completions.add(normalizedDate);
      }
    }
    
    return completions;
  }
}
