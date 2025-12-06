class Habit {
  final String id;
  final String name;
  final String interval; // 'daily', 'weekly', 'monthly'
  final DateTime createdAt;
  final List<DateTime> completions;
  final int colorValue; // Store color as int for JSON serialization

  // Predefined palette of habit colors
  static const List<int> habitColors = [
    0xFF6366F1, // Indigo
    0xFF8B5CF6, // Violet
    0xFFEC4899, // Pink
    0xFFEF4444, // Red
    0xFFF97316, // Orange
    0xFFF59E0B, // Amber
    0xFF84CC16, // Lime
    0xFF22C55E, // Green
    0xFF14B8A6, // Teal
    0xFF06B6D4, // Cyan
    0xFF3B82F6, // Blue
    0xFF6B7280, // Gray
  ];

  Habit({
    required this.id,
    required this.name,
    required this.interval,
    required this.createdAt,
    required this.completions,
    this.colorValue = 0xFF6366F1, // Default to Indigo
  });

  // Convert a Habit to a Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'interval': interval,
      'createdAt': createdAt.toIso8601String(),
      'completions': completions.map((date) => date.toIso8601String()).toList(),
      'colorValue': colorValue,
    };
  }

  // Create a Habit from a Map
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      interval: json['interval'],
      createdAt: DateTime.parse(json['createdAt']),
      completions: (json['completions'] as List<dynamic>)
          .map((date) => DateTime.parse(date))
          .toList(),
      colorValue: json['colorValue'] ?? 0xFF6366F1,
    );
  }

  // Create a copy with updated fields
  Habit copyWith({
    String? id,
    String? name,
    String? interval,
    DateTime? createdAt,
    List<DateTime>? completions,
    int? colorValue,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      interval: interval ?? this.interval,
      createdAt: createdAt ?? this.createdAt,
      completions: completions ?? this.completions,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
