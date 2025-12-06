# Habit Tracker

A mobile habit tracker app built with Flutter.

## Features

- Create custom habits with different intervals (daily, weekly, monthly)
- Track habit completion with a simple tap
- View completion streaks
- Swipe to delete habits
- Persistent local storage

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   └── habit.dart         # Habit data model
├── services/
│   └── habit_storage.dart # Local storage service
├── screens/
│   ├── home_screen.dart   # Main screen
│   └── add_habit_screen.dart # Add habit screen
└── widgets/
    └── habit_item.dart    # Habit list item widget
```

## Usage

1. Tap the + button to add a new habit
2. Enter the habit name and select an interval
3. Tap the circle icon to mark the habit as complete for today
4. Swipe left to delete a habit