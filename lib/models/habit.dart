class Habit {
  final String id;
  final String name;
  final String interval; // 'daily', 'weekly', 'monthly'
  final DateTime createdAt;
  final List<DateTime> completions;

  Habit({
    required this.id,
    required this.name,
    required this.interval,
    required this.createdAt,
    required this.completions,
  });

  // Convert a Habit to a Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'interval': interval,
      'createdAt': createdAt.toIso8601String(),
      'completions': completions.map((date) => date.toIso8601String()).toList(),
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
    );
  }

  // Create a copy with updated fields
  Habit copyWith({
    String? id,
    String? name,
    String? interval,
    DateTime? createdAt,
    List<DateTime>? completions,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      interval: interval ?? this.interval,
      createdAt: createdAt ?? this.createdAt,
      completions: completions ?? this.completions,
    );
  }
}
