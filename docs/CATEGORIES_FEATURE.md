# Habit Categories Feature

## Overview

The Habit Categories feature allows users to organize their habits into categories. The app provides a set of predefined generic categories, and users can optionally create their own custom categories.

## Implementation

### Core Components

1. **Category Model** (`lib/models/category.dart`)
   - Immutable data model representing a category
   - Fields: `id`, `name`, `icon`, `isCustom`
   - Provides 8 predefined categories:
     - Health & Fitness (💪)
     - Mindfulness (🧘)
     - Productivity (⚡)
     - Learning (📚)
     - Creativity (🎨)
     - Social (👥)
     - Finance (💰)
     - Home & Chores (🏠)

2. **CategoryStorage Service** (`lib/services/category_storage.dart`)
   - Manages custom category persistence using SharedPreferences
   - User-scoped storage (categories are isolated per user)
   - CRUD operations for custom categories
   - `loadAllCategories()` returns both predefined and custom categories

3. **Updated Habit Model** (`lib/models/habit.dart`)
   - Added optional `categoryId` field
   - Backward compatible (existing habits without categories continue to work)
   - Full serialization support in `toJson()` and `fromJson()`

### UI Integration

#### Add Habit Screen
- Category dropdown appears after the Frequency selection
- Shows all available categories (predefined + custom)
- Optional selection (defaults to "None")
- Each category displays its icon and name

#### Edit Habit Screen
- Same category dropdown as Add Habit Screen
- Pre-selects the habit's current category (if any)
- Allows changing or removing the category

### Data Storage

Categories are stored using the user-scoped pattern:
- Key pattern: `categories_$userId`
- Falls back to `categories` for global storage (when no userId provided)
- JSON serialization format maintains all category properties

## Usage

### For Users

1. **Adding a habit with category:**
   - Tap the + button
   - Fill in habit details
   - Select a category from the dropdown (optional)
   - Create the habit

2. **Editing a habit's category:**
   - Long-press or swipe on a habit
   - Select Edit
   - Choose a different category or select "None"
   - Save changes

### For Developers

**Creating predefined categories:**
```dart
// Predefined categories are defined as const in Category.predefined
static const List<Category> predefined = [
  Category(
    id: 'health',
    name: 'Health & Fitness',
    icon: '💪',
    isCustom: false,
  ),
  // ... more categories
];
```

**Using CategoryStorage:**
```dart
final storage = CategoryStorage(userId: currentUser.uid);

// Load all categories (predefined + custom)
final categories = await storage.loadAllCategories();

// Add a custom category
final customCategory = Category(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'My Custom Category',
  icon: '🎯',
  isCustom: true,
);
await storage.addCategory(customCategory);

// Load only custom categories
final customOnly = await storage.loadCustomCategories();
```

**Creating a habit with category:**
```dart
final habit = Habit(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'Morning Jog',
  interval: 'daily',
  createdAt: DateTime.now(),
  completions: [],
  categoryId: 'health', // Optional
);
```

## Testing

The feature includes comprehensive test coverage:

1. **Category Model Tests** (`test/category_test.dart`)
   - Serialization/deserialization
   - copyWith functionality
   - Equality checks
   - Predefined categories validation

2. **CategoryStorage Tests** (`test/category_storage_test.dart`)
   - CRUD operations
   - User isolation
   - Data persistence
   - Error handling

3. **Updated Habit Tests** (`test/habit_test.dart`)
   - Category field serialization
   - Backward compatibility (missing categoryId)
   - copyWith with categoryId

## Future Enhancements

Potential improvements for future versions:

1. **Custom Category Management UI**
   - Dedicated screen for creating/editing/deleting custom categories
   - Category icon picker
   - Category name validation

2. **Category Filtering**
   - Filter habits by category in HomeScreen
   - Category-based grouping in list view
   - Statistics per category

3. **Category Analytics**
   - Completion rates by category
   - Time spent per category
   - Category performance comparison

4. **Category Colors**
   - Allow custom colors for categories
   - Category-based habit color suggestions

## Backward Compatibility

The implementation is fully backward compatible:
- Existing habits without categories continue to work
- `categoryId` field defaults to `null`
- UI shows "None" when no category is selected
- No data migration required
