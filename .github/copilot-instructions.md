# Copilot Instructions - Habit Tracker

## Architecture Overview
Flutter mobile habit tracker with Firebase Authentication and local per-user persistence. **No state management libraries** - uses vanilla StatefulWidget + setState pattern with manual state refresh after mutations.

### Data Flow & State Management
```
Screen (StatefulWidget) 
  ↓ calls methods
Service Layer (HabitStorage/ThemeService/etc) 
  ↓ serializes to JSON
SharedPreferences (key-value store)
```
- **No reactivity**: After mutations, screens manually call `_loadHabits()` to refresh UI
- **User isolation**: All storage services accept `userId` param for user-scoped keys (`habits_$userId`)
- **Auth routing**: `main.dart` uses `StreamBuilder` on `AuthService.authStateChanges` to route between LoginScreen and MainNavigationScreen

### Critical Patterns

#### Immutable Models with copyWith
All models (Habit, Category, NotificationSettings) use immutable pattern:
```dart
final updatedHabit = habit.copyWith(completions: [...habit.completions, today]);
await storage.updateHabit(updatedHabit);
await _loadHabits(); // Manual refresh required!
```
Never mutate model fields directly. Use `copyWith()` for updates.

#### Date Normalization (Critical!)
**Always normalize dates to midnight before comparison/storage**:
```dart
final now = TimeService().now(); // NOT DateTime.now()!
final today = DateTime(now.year, now.month, now.day);
```
Completions are checked by comparing `year/month/day` components, not DateTime equality. See `HabitItem._isCompletedOnDate()`.

#### TimeService Singleton (Testing)
Singleton for time offset manipulation in tests. **Always use `TimeService().now()`** instead of `DateTime.now()`:
```dart
final now = TimeService().now(); // Can be offset by hours via addHours(24)
await TimeService().loadOffset(); // Required in initState
```

#### User-Scoped Storage
All services accept optional `userId` to scope data per-user:
```dart
final storage = HabitStorage(userId: widget.userId); // Creates key 'habits_$userId'
final settings = ThemeService(); // Global key (no userId)
```
**Always pass userId** from MainNavigationScreen/HomeScreen to ensure data isolation.

#### Guest Mode Test Data
Guest user (userId = 'guest_user') auto-generates 15 sample habits with 365 days of historical data on first launch. See `TestDataService.generateRandomHabits()` and `MainNavigationScreen._initializeGuestUserData()`.

## Code Organization
```
lib/
├── main.dart              # App entry + AuthWrapper (StreamBuilder on auth state)
├── models/                # Immutable models (toJson/fromJson/copyWith)
├── services/              # Storage layer (SharedPreferences → JSON)
│   ├── auth_service.dart  # Firebase Auth (Google/Apple)
│   ├── habit_storage.dart # User-scoped CRUD operations
│   ├── time_service.dart  # Singleton for time offset (testing)
│   └── test_data_service.dart # Guest user sample data generation
├── screens/               # StatefulWidget screens (manual setState)
├── widgets/               # Reusable UI (HabitItem, HabitCalendar)
└── constants.dart         # App-wide constants (guestUserId, etc)
```

## Essential Workflows

### Firebase Setup (First Time)
```bash
dart pub global activate flutterfire_cli
flutterfire configure  # Generates firebase_options.dart
# Add google-services.json (Android) or GoogleService-Info.plist (iOS)
```

### Pre-Commit Requirements (CI Enforced)
**MANDATORY before any commit:**
```bash
flutter test     # All 114+ tests must pass
flutter analyze  # Zero errors AND warnings (enforced by CI)
```
CI pipeline (`.github/workflows/flutter-test.yml`) blocks PRs with failures. Fix issues locally first.

### Testing Patterns
**Service tests** require mock SharedPreferences in setUp:
```dart
setUp(() {
  SharedPreferences.setMockInitialValues({});
  storage = HabitStorage(userId: 'test_user');
});
```

**Widget tests** require MaterialApp + Scaffold wrapper:
```dart
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: HabitItem(habit: testHabit, onToggle: () {}, onDelete: () {}),
    ),
  ),
);
```

## UI Conventions
- **Material 3**: `ColorScheme.fromSeed(seedColor: Color(0xFF6366F1))` with `useMaterial3: true`
- **Navigation**: BottomNavigationBar in MainNavigationScreen (Home/Calendar/Settings tabs)
- **Theme propagation**: Callback chain `HabitsApp._updateThemeMode` → `AuthWrapper` → `MainNavigationScreen` → `SettingsScreen`
- **Loading states**: Always show `CircularProgressIndicator` during async ops
- **Empty states**: Large icon + message (see `MainNavigationScreen` empty state)
- **Swipe-to-delete**: Use `Dismissible` with `confirmDismiss` AlertDialog

## Dependencies
- `firebase_core/firebase_auth` - Authentication only (no Firestore/Cloud Storage)
- `shared_preferences` - All persistence (no SQLite/Hive)
- `google_sign_in`, `sign_in_with_apple` - OAuth providers
- `intl` - Date formatting (minimal usage)
- **No**: state management (BLoC/Provider/Riverpod), routing (GoRouter), DI (GetIt)

## Common Gotchas
- **Habit IDs**: Generated as `DateTime.now().millisecondsSinceEpoch.toString()` (not UUIDs)
- **Interval field**: String literal ('daily', 'weekly', 'monthly'), not enum type
- **copyWith for Theme**: Extend TextTheme via `?.copyWith()` (see `main.dart` theme config)
- **Analysis warnings**: Must fix all warnings (prefer_const_constructors, etc) before commit
- **Guest user ID**: Constant `AppConstants.guestUserId = 'guest_user'` in `constants.dart`

## Key Files Reference
- **Authentication flow**: `lib/main.dart` (AuthWrapper StreamBuilder)
- **Storage pattern**: `lib/services/habit_storage.dart` (user-scoped keys)
- **Date handling**: `lib/widgets/habit_item.dart` (_isCompletedOnDate, _getCurrentStreak)
- **Test data**: `lib/services/test_data_service.dart` (guest user sample habits)
- **Testing setup**: `test/habit_storage_test.dart`, `test/habit_item_widget_test.dart`
