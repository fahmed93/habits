# Theme and Appearance Settings

## Overview

The Habit Tracker app supports theme customization with three options:
- **Light Mode**: Traditional light color scheme
- **Dark Mode**: Dark color scheme for low-light environments
- **System**: Automatically follows the device's system theme setting

## Implementation Details

### Architecture

The theme system consists of three main components:

1. **ThemeService** (`lib/services/theme_service.dart`)
   - Manages theme preferences using SharedPreferences
   - Provides `getThemeMode()` to retrieve saved theme
   - Provides `setThemeMode(ThemeMode)` to save theme preference
   - Uses storage key: `'theme_mode'`
   - Defaults to `ThemeMode.system` if no preference exists

2. **App Configuration** (`lib/main.dart`)
   - `HabitsApp` is a StatefulWidget with theme state
   - Defines both `theme` (light) and `darkTheme` properties
   - Uses Material 3 with deep purple seed color
   - `themeMode` property controls which theme is active
   - Theme state loads on app initialization

3. **Settings Screen** (`lib/screens/settings_screen.dart`)
   - Displays current theme selection in subtitle
   - Shows dialog with RadioListTile for theme selection
   - Updates theme immediately when changed
   - Persists selection to SharedPreferences

### Theme Propagation Flow

```
HabitsApp (root)
  └─ onThemeChanged callback
      └─ AuthWrapper
          └─ passes callback to MainNavigationScreen
              └─ passes callback to SettingsScreen
                  └─ invokes callback when theme changes
```

When a user selects a new theme:
1. SettingsScreen calls `ThemeService.setThemeMode()`
2. SettingsScreen invokes the `onThemeChanged` callback
3. Callback propagates to HabitsApp
4. HabitsApp calls `setState()` to update `themeMode`
5. MaterialApp rebuilds with new theme
6. All descendant widgets automatically update

### Data Persistence

Theme preferences are stored in SharedPreferences:
- **Key**: `'theme_mode'`
- **Value**: String representation of ThemeMode enum
  - `"ThemeMode.light"`
  - `"ThemeMode.dark"`
  - `"ThemeMode.system"`

### Color Scheme

Both light and dark themes use:
- **Seed Color**: `Colors.deepPurple`
- **Material Design**: Version 3
- Dynamic color generation via `ColorScheme.fromSeed()`

## Usage

### Accessing Theme Settings

1. Open the app
2. Tap the settings icon (⚙️) in the app bar
3. Tap on "Theme" in the settings list
4. Select your preferred theme from the dialog
5. Theme changes immediately

### For Developers

To modify the color scheme:

```dart
// In lib/main.dart, update the seed color:
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.yourColor),
  useMaterial3: true,
),
darkTheme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yourColor,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
),
```

To add theme control to a new screen:

```dart
// Add onThemeChanged parameter to the screen
class YourScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;
  
  const YourScreen({super.key, required this.onThemeChanged});
  
  // Use it when needed
  onThemeChanged(ThemeMode.dark);
}
```

## Testing

Theme functionality is tested in `test/theme_service_test.dart`:
- Theme persistence (save and load)
- Default theme behavior
- All theme mode options (light, dark, system)
- Error handling for corrupted data

Run tests:
```bash
flutter test test/theme_service_test.dart
```

## Technical Decisions

### Why SharedPreferences?

- Consistent with existing data storage pattern (HabitStorage)
- Simple key-value storage appropriate for theme preference
- No need for complex data structures
- Fast synchronous access after initial load

### Why Callback Propagation?

- Maintains consistency with existing state management approach
- No external state management library dependencies
- Simple and predictable data flow
- Easy to debug and understand

### Why Material 3?

- Modern design language
- Better accessibility features
- Improved dark mode support
- Already used throughout the app

## Future Enhancements

Potential improvements:
- Custom color scheme selection
- Per-screen theme overrides
- Scheduled theme switching (e.g., auto-dark at night)
- Theme preview before applying
- More granular appearance settings (font size, etc.)
