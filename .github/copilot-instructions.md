# Copilot Instructions - Habit Tracker

## Project Overview
Flutter mobile habit tracker with Firebase Authentication and local persistence. Simple architecture: no state management libraries, direct service layer calls from StatefulWidgets.

## Architecture
- **Authentication**: Firebase Auth with Google/Apple sign-in via `AuthService`
- **Auth Flow**: `main.dart` uses `StreamBuilder` on `authStateChanges` to route between `LoginScreen` and `MainNavigationScreen`
- **Data Flow**: Screen → Service (user-scoped) → SharedPreferences → JSON serialization
- **State**: StatefulWidget with local state (`setState`), no BLoC/Provider/Riverpod
- **Storage**: Services accept optional `userId` parameter for per-user data isolation
- **Navigation**: `BottomNavigationBar` in `MainNavigationScreen` for multi-view navigation (Home/Calendar/Settings)

## Code Organization
```
lib/
├── models/         # Data models with JSON serialization (Habit, User, NotificationSettings)
├── services/       # Business logic and storage services
│   ├── auth_service.dart          # Firebase Authentication
│   ├── habit_storage.dart         # User-scoped habit persistence
│   ├── theme_service.dart         # Theme preferences
│   ├── notification_settings_service.dart  # User-scoped notification settings
│   └── time_service.dart          # Singleton for mockable time (testing)
├── screens/        # Full-page StatefulWidgets
│   ├── login_screen.dart          # Google/Apple sign-in
│   ├── main_navigation_screen.dart # BottomNavigationBar with shared state
│   ├── home_screen.dart, calendar_screen.dart, settings_screen.dart
│   ├── add_habit_screen.dart, notification_settings_screen.dart
└── widgets/        # Reusable UI components (HabitItem, HabitCalendar)

docs/               # All documentation files (*.md) except README.md
```

## Documentation Guidelines
- **All documentation files must be placed in the `docs/` folder**
- Only `README.md` stays at the project root
- Use relative links between docs (e.g., `[FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)`)
- From README.md, link to docs with `docs/` prefix (e.g., `[docs/AUTH_README.md](docs/AUTH_README.md)`)

## Key Patterns

### Firebase Authentication
- **AuthService** wraps Firebase Auth with Google/Apple sign-in support
- Returns custom `User` model (not Firebase's) with uid, email, displayName, photoURL
- `authStateChanges` stream drives routing in `AuthWrapper` component
- Example: `final user = authService.currentUser; // Returns models.User?`

### User-Scoped Storage Pattern
All data services follow this pattern for per-user isolation:
```dart
final storage = HabitStorage(userId: currentUser.uid);
String get _storageKey => userId != null ? 'habits_$userId' : 'habits';
```
Services that use this: `HabitStorage`, `NotificationSettingsService`. Settings screens conditionally disable controls when master toggle is off (see `notification_settings_screen.dart:106-167`).

### Habit Model (Immutable)
- Uses `copyWith()` for updates, not setters
- DateTime completions stored as `List<DateTime>`, normalized to midnight
- JSON serialization via `toJson()`/`fromJson()` factory methods
- Includes `icon` field (emoji string) with default '✓' and `colorValue` (int) for visual identification
- Example: `habit.copyWith(completions: [...habit.completions, today])`

### Storage Service Pattern
Every screen operation follows:
```dart
final storage = HabitStorage(userId: widget.userId); // User-scoped
await storage.loadHabits();        // READ
await storage.addHabit(habit);      // CREATE
await storage.updateHabit(habit);   // UPDATE
await storage.deleteHabit(id);      // DELETE
```
After mutations, screens call `_loadHabits()` to refresh UI.

### Navigation Pattern
- **BottomNavigationBar**: Used in `MainNavigationScreen` for Home/Calendar/Settings tabs with shared state
- **Direct Navigator.push**: Used for modal screens like `AddHabitScreen` with `await` for results
- Settings button in AppBar's leading position navigates to `SettingsScreen` with ListView of ListTiles

### TimeService (Singleton for Testing)
Always use `TimeService().now()` instead of `DateTime.now()` for date operations:
```dart
final now = TimeService().now(); // Mockable time for testing
final today = DateTime(now.year, now.month, now.day);
```
Supports `addHours()` offset for debugging and testing. Must call `await _timeService.loadOffset()` in initState.

### Date Normalization
Always normalize dates to midnight before comparison:
```dart
final today = DateTime(now.year, now.month, now.day);
```
Completions are checked by comparing year/month/day components, not DateTime equality.

### Date-Specific Habit Toggling
Habit completion methods accept optional DateTime parameter for marking past days:
```dart
Future<void> _toggleCompletion(Habit habit, [DateTime? date]) async {
  final targetDate = date ?? DateTime(now.year, now.month, now.day);
  // Check and toggle completion for targetDate
}
```
`HabitItem` widget provides `onToggleDate` callback for 5-day completion view (see below).

### 5-Day Completion View
`HabitItem` displays last 5 days of completion as a row of circular indicators with today on the right:
- Each indicator shows day-of-week, month/day, and completion status
- Tappable via `onToggleDate(DateTime)` callback to toggle specific dates
- 36px circular indicators with habit's color when completed
- Implementation in `habit_item.dart:83-128`

### Streak Calculation
Streaks count consecutive days backwards from today. Implementation in `HabitItem._getCurrentStreak()` sorts completions descending and checks for consecutive dates.

### Theme Management
- Theme changes propagate via callback: `HabitsApp` → `AuthWrapper` → `MainNavigationScreen` → `SettingsScreen`
- `ThemeService` manages theme with SharedPreferences key 'theme_mode'
- App supports Material 3 with light/dark/system themes using deep purple seed color
- Theme selected in Settings screen with radio buttons for Light/Dark/System

## UI Conventions
- **Material 3**: Uses `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` with `useMaterial3: true`
- **Dismissible**: Swipe-to-delete requires `confirmDismiss` with AlertDialog
- **Empty States**: Show large icon + message when no data (see `HomeScreen`, `CalendarScreen` body)
- **Loading States**: Always show `CircularProgressIndicator` during async operations
- **TODO Placeholders**: Use SnackBar with TODO message for unimplemented features in onTap callbacks
- **Habit Icons**: AddHabitScreen provides 24 predefined emojis in wrap layout with visual selection feedback

## Development Workflow

### Run/Test Commands
```bash
flutter pub get           # Install dependencies
flutter run              # Run on connected device/emulator
flutter test             # Run all tests
flutter test test/habit_test.dart  # Run specific test file

# Firebase setup (required for auth)
dart pub global activate flutterfire_cli
flutterfire configure    # Auto-configure Firebase for your project
```

### Common Tasks
- **Add new feature**: Start with model changes, update storage if needed, then UI
- **Modify date logic**: Check `HabitItem` widget and always use `TimeService().now()` for date normalization
- **Add persistence**: Extend service with user-scoped storage key pattern, always use JSON serialization
- **Add authentication flow**: Check `AuthService` and ensure Firebase is configured (see `docs/AUTH_README.md`)
- **Update theme**: Propagate callback through component tree or modify `ThemeService`

## Testing Strategy
- Unit tests for model serialization/deserialization in `test/habit_test.dart`, `test/notification_settings_test.dart`
- Unit tests for services in `test/theme_service_test.dart`
- Widget tests verify UI exists but don't test interactions deeply
- Use `TimeService` singleton pattern for mockable time in tests
- No integration tests; manual testing on device/emulator for auth flows

## Linting
Enforces `prefer_const_constructors` and `prefer_const_literals_to_create_immutables` via `analysis_options.yaml`. Use `const` wherever possible for constructors and collections.

## Dependencies
- `shared_preferences: ^2.2.0` - Local key-value storage
- `intl: ^0.19.0` - Date formatting (imported but not heavily used)
- `firebase_core: ^3.8.1`, `firebase_auth: ^5.3.4` - Firebase Authentication
- `google_sign_in: ^6.2.2` - Google OAuth
- `sign_in_with_apple: ^6.1.4` - Apple Sign-In (iOS 13+)
- No state management, routing, or dependency injection libraries

## Gotchas
- **State refresh**: Must manually reload data after storage mutations (no automatic reactivity)
- **DateTime comparisons**: Always normalize to midnight via `TimeService().now()`; don't compare DateTime objects directly
- **User scoping**: Always pass `userId` to storage/settings services for per-user data isolation
- **Habit IDs**: Generated as timestamps in `AddHabitScreen`, not UUIDs
- **Interval field**: String enum ('daily', 'weekly', 'monthly'), not actual enum type
- **Firebase setup**: Requires `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) - see `docs/FIREBASE_SETUP.md`
- **Auth dependencies**: Google Sign-In requires SHA-1 certificate in Firebase Console
- **TimeService**: Singleton pattern - must call `loadOffset()` in initState before first use
