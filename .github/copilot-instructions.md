# Copilot Instructions - Habit Tracker

## Project Overview
Flutter mobile habit tracker with local persistence. Simple architecture: no state management libraries, direct service layer calls from StatefulWidgets.

## Architecture
- **Data Flow**: Screen → HabitStorage service → SharedPreferences → JSON serialization
- **State**: StatefulWidget with local state (`setState`), no BLoC/Provider/Riverpod
- **Storage**: Single service class (`HabitStorage`) handles all CRUD operations
- **Navigation**: Direct `Navigator.push` with result passing for screen communication

## Code Organization
```
lib/
├── models/         # Data models with JSON serialization
├── services/       # Storage/business logic (HabitStorage)
├── screens/        # Full-page StatefulWidgets
└── widgets/        # Reusable UI components

docs/               # All documentation files (*.md) except README.md
```

## Documentation Guidelines
- **All documentation files must be placed in the `docs/` folder**
- Only `README.md` stays at the project root
- Use relative links between docs (e.g., `[FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)`)
- From README.md, link to docs with `docs/` prefix (e.g., `[docs/AUTH_README.md](docs/AUTH_README.md)`)

## Key Patterns

### Habit Model (Immutable)
- Uses `copyWith()` for updates, not setters
- DateTime completions stored as List<DateTime>, normalized to midnight
- JSON serialization via `toJson()`/`fromJson()` factory methods
- Example: `habit.copyWith(completions: [...habit.completions, today])`

### Storage Service Pattern
Every screen operation follows:
```dart
final storage = HabitStorage();
await storage.loadHabits();        // READ
await storage.addHabit(habit);      // CREATE
await storage.updateHabit(habit);   // UPDATE
await storage.deleteHabit(id);      // DELETE
```
After mutations, screens call `_loadHabits()` to refresh UI.

### Date Normalization
Always normalize dates to midnight before comparison:
```dart
final today = DateTime(now.year, now.month, now.day);
```
Completions are checked by comparing year/month/day components, not DateTime equality.

### Streak Calculation
Streaks count consecutive days backwards from today. Implementation in `HabitItem._getCurrentStreak()` sorts completions descending and checks for consecutive dates.

## UI Conventions
- **Material 3**: Uses `ColorScheme.fromSeed()` with `useMaterial3: true`
- **Dismissible**: Swipe-to-delete requires `confirmDismiss` with AlertDialog
- **Empty States**: Show large icon + message when no data (see `HomeScreen` body)
- **Loading States**: Always show `CircularProgressIndicator` during async operations

## Development Workflow

### Run/Test Commands
```bash
flutter pub get           # Install dependencies
flutter run              # Run on connected device/emulator
flutter test             # Run all tests
flutter test test/habit_test.dart  # Run specific test file
```

### Common Tasks
- **Add new feature**: Start with model changes, update storage if needed, then UI
- **Modify date logic**: Check `HabitItem` widget for existing date normalization patterns
- **Add persistence**: Extend `HabitStorage` methods, always use JSON serialization

## Testing Strategy
- Unit tests for model serialization/deserialization in `test/habit_test.dart`
- Widget tests verify UI exists but don't test interactions deeply
- No integration tests; manual testing on device/emulator

## Linting
Enforces `prefer_const_constructors` and `prefer_const_literals_to_create_immutables` via `analysis_options.yaml`. Use `const` wherever possible for constructors and collections.

## Dependencies
- `shared_preferences: ^2.2.0` - Local key-value storage
- `intl: ^0.19.0` - Date formatting (imported but not heavily used)
- No state management, routing, or dependency injection libraries

## Gotchas
- **State refresh**: Must manually reload data after storage mutations (no automatic reactivity)
- **DateTime comparisons**: Always normalize to midnight; don't compare DateTime objects directly
- **Habit IDs**: Generated as timestamps in `AddHabitScreen`, not UUIDs
- **Interval field**: String enum ('daily', 'weekly', 'monthly'), not actual enum type
