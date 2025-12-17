class Category {
  final String id;
  final String name;
  final String icon; // Emoji icon for the category
  final bool isCustom; // True if user-created, false for predefined

  // Predefined categories
  static const List<Category> predefined = [
    Category(
      id: 'health',
      name: 'Health & Fitness',
      icon: '💪',
      isCustom: false,
    ),
    Category(
      id: 'mindfulness',
      name: 'Mindfulness',
      icon: '🧘',
      isCustom: false,
    ),
    Category(
      id: 'productivity',
      name: 'Productivity',
      icon: '⚡',
      isCustom: false,
    ),
    Category(
      id: 'learning',
      name: 'Learning',
      icon: '📚',
      isCustom: false,
    ),
    Category(
      id: 'creativity',
      name: 'Creativity',
      icon: '🎨',
      isCustom: false,
    ),
    Category(
      id: 'social',
      name: 'Social',
      icon: '👥',
      isCustom: false,
    ),
    Category(
      id: 'finance',
      name: 'Finance',
      icon: '💰',
      isCustom: false,
    ),
    Category(
      id: 'home',
      name: 'Home & Chores',
      icon: '🏠',
      isCustom: false,
    ),
  ];

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.isCustom,
  });

  // Convert a Category to a Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isCustom': isCustom,
    };
  }

  // Create a Category from a Map
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? '📁',
      isCustom: json['isCustom'] ?? true,
    );
  }

  // Create a copy with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isCustom,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
