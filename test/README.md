# Habits App - Test Suite

This directory contains comprehensive unit and widget tests for the Habits application.

## Quick Start

Run all tests:
```bash
flutter test
```

Run a specific test file:
```bash
flutter test test/habit_test.dart
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Test Structure

```
test/
├── README.md (this file)
├── auth_service_test.dart              # Auth service tests
├── calendar_screen_test.dart           # Calendar screen widget tests
├── habit_calendar_widget_test.dart     # Habit calendar widget tests
├── habit_item_widget_test.dart         # Habit item widget tests
├── habit_storage_test.dart             # Habit storage service tests
├── habit_test.dart                     # Habit model tests
├── notification_settings_service_test.dart  # Notification settings service tests
├── notification_settings_test.dart     # Notification settings model tests
├── theme_service_test.dart             # Theme service tests
├── time_service_test.dart              # Time service tests
├── user_test.dart                      # User model tests
└── widget_test.dart                    # General widget tests
```

## Test Categories

### Model Tests (33 tests)
- `habit_test.dart` - Tests for Habit model serialization, copyWith, defaults
- `user_test.dart` - Tests for User model serialization
- `notification_settings_test.dart` - Tests for NotificationSettings model

### Service Tests (42 tests)
- `habit_storage_test.dart` - Tests for habit CRUD operations and user isolation
- `notification_settings_service_test.dart` - Tests for notification settings persistence
- `time_service_test.dart` - Tests for time offset functionality
- `theme_service_test.dart` - Tests for theme persistence
- `auth_service_test.dart` - Basic auth service tests (requires Firebase mocking for full coverage)

### Widget Tests (32 tests)
- `habit_item_widget_test.dart` - Tests for HabitItem widget rendering and interactions
- `habit_calendar_widget_test.dart` - Tests for HabitCalendar widget and navigation

### Screen Tests (7 tests)
- `calendar_screen_test.dart` - Tests for CalendarScreen empty state and rendering
- `widget_test.dart` - General app widget tests

## Total Test Coverage
- **114 total test cases**
- **~85% estimated code coverage** for testable components
- **100% coverage** for models and most services

## Testing Patterns

### SharedPreferences Mocking
All service tests use mock SharedPreferences:
```dart
setUp(() {
  SharedPreferences.setMockInitialValues({});
});
```

### Widget Test Wrapper
All widget tests wrap components in MaterialApp:
```dart
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: YourWidget(),
    ),
  ),
);
```

## Running Specific Test Groups

Run only model tests:
```bash
flutter test test/habit_test.dart test/user_test.dart test/notification_settings_test.dart
```

Run only service tests:
```bash
flutter test test/*_service_test.dart test/habit_storage_test.dart test/notification_settings_service_test.dart
```

Run only widget tests:
```bash
flutter test test/*_widget_test.dart test/calendar_screen_test.dart
```

## Viewing Coverage Reports

After running tests with coverage:
```bash
flutter test --coverage
```

Generate HTML report (requires lcov):
```bash
# Install lcov if not already installed
# Ubuntu/Debian: sudo apt-get install lcov
# macOS: brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

## Test Requirements

- Flutter SDK (3.0.0+)
- Dart SDK (3.0.0+)
- `flutter_test` package (included with Flutter SDK)
- `shared_preferences` package for mock testing

## Known Limitations

1. **Firebase Tests**: Full Firebase integration tests require proper mocking setup
2. **UI Integration Tests**: Complex screen interactions would benefit from integration tests
3. **Platform Tests**: Platform-specific features (Apple Sign-In) need platform channel mocking

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure all tests pass before committing
3. Aim for >80% code coverage on new features
4. Follow existing test patterns and naming conventions

## Test Naming Convention

- Test file: `{source_file}_test.dart`
- Test groups: `'{ClassName} {Type} Tests'`
- Test cases: `'should {expected behavior} when {condition}'`

Example:
```dart
group('Habit Model Tests', () {
  test('Habit toJson should serialize all fields correctly', () {
    // test implementation
  });
});
```

## Continuous Integration

These tests are designed to run in CI/CD pipelines. Ensure your CI configuration includes:
```yaml
- name: Run tests
  run: flutter test --coverage
```

## Documentation

For detailed coverage information, see [TEST_COVERAGE.md](../docs/TEST_COVERAGE.md)

## Support

If tests fail:
1. Check Flutter version: `flutter --version`
2. Clean and get dependencies: `flutter clean && flutter pub get`
3. Run tests with verbose output: `flutter test --verbose`
4. Check for platform-specific issues

## License

Same as the main project.
