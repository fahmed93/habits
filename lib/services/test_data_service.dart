import 'dart:math';
import '../models/habit.dart';

class TestDataService {
  static final Random _random = Random();
  static const int _historicalDays = 365;

  // List of habit names for random selection (with category hints)
  static const List<Map<String, String>> habitData = [
    {'name': 'Morning Exercise', 'category': 'health'},
    {'name': 'Read for 30 min', 'category': 'learning'},
    {'name': 'Drink 8 glasses of water', 'category': 'health'},
    {'name': 'Meditate', 'category': 'mindfulness'},
    {'name': 'Practice gratitude', 'category': 'mindfulness'},
    {'name': 'Learn something new', 'category': 'learning'},
    {'name': 'Take a walk', 'category': 'health'},
    {'name': 'Healthy breakfast', 'category': 'health'},
    {'name': 'Journal writing', 'category': 'creativity'},
    {'name': 'Stretch', 'category': 'health'},
    {'name': 'No social media', 'category': 'productivity'},
    {'name': 'Early to bed', 'category': 'health'},
    {'name': 'Call a friend', 'category': 'social'},
    {'name': 'Practice a skill', 'category': 'learning'},
    {'name': 'Clean workspace', 'category': 'home'},
  ];

  // Keep legacy habitNames for backwards compatibility
  static final List<String> habitNames = habitData.map((e) => e['name']!).toList();

  // List of emojis for random selection
  static const List<String> habitEmojis = [
    '💪', '📚', '💧', '🧘', '🙏',
    '🧠', '🚶', '🥗', '📝', '🤸',
    '📵', '😴', '📞', '🎯', '🧹',
    '🏃', '🎨', '🎵', '☕', '🌱',
    '✨', '🔥', '⭐', '💡',
  ];

  /// Generate 15 random habits with unique names, emojis, colors, and categories
  static List<Habit> generateRandomHabits() {
    final selectedData = <Map<String, String>>[];
    final habits = <Habit>[];
    final now = DateTime.now();

    // Select all 15 unique habit entries (we have exactly 15 in habitData)
    selectedData.addAll(habitData);

    for (int i = 0; i < 15; i++) {
      // Generate unique ID (same pattern as AddHabitScreen, with +i to prevent collisions)
      final id = (now.millisecondsSinceEpoch + i).toString();
      
      // Select random emoji
      final emoji = habitEmojis[_random.nextInt(habitEmojis.length)];
      
      // Select random color from palette
      final color = Habit.habitColors[_random.nextInt(Habit.habitColors.length)];
      
      // Get category from data
      final categoryId = selectedData[i]['category'];
      
      // Create habit with 365 days of historical data
      final habit = Habit(
        id: id,
        name: selectedData[i]['name']!,
        interval: 'daily',
        createdAt: now.subtract(const Duration(days: _historicalDays)),
        completions: _generate365DaysOfData(now),
        colorValue: color,
        icon: emoji,
        categoryId: categoryId,
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
