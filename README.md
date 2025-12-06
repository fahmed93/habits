# Habit Tracker

A mobile habit tracker app built with Flutter with Firebase Authentication.

## Features

- **Authentication**: Sign in with Google or Apple (iOS 13+)
- **User-specific data**: Each user's habits are private and separate
- Create custom habits with different intervals (daily, weekly, monthly)
- Track habit completion with a simple tap
- View completion streaks
- Swipe to delete habits
- Persistent local storage per user

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio / Xcode for mobile development
- Firebase account (for authentication)

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. **Set up Firebase Authentication** - See [docs/AUTH_README.md](docs/AUTH_README.md) for detailed instructions
4. Configure Firebase for your platform:
   - Android: Add `google-services.json` to `android/app/`
   - iOS: Add `GoogleService-Info.plist` to `ios/Runner/`
5. Run `flutter run` to start the app

### Quick Firebase Setup

For a quick start with Firebase:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase automatically
flutterfire configure
```

See [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md) for detailed setup instructions.

## Project Structure

```
lib/
├── main.dart              # App entry point with auth state management
├── firebase_options.dart  # Firebase configuration (generated)
├── models/
│   ├── habit.dart         # Habit data model
│   └── user.dart          # User authentication model
├── services/
│   ├── auth_service.dart  # Authentication service
│   ├── habit_storage.dart # Local storage service (per-user)
│   └── time_service.dart  # Time service
├── screens/
│   ├── login_screen.dart  # Login screen with Google/Apple sign-in
│   ├── home_screen.dart   # Main screen
│   └── add_habit_screen.dart # Add habit screen
└── widgets/
    ├── habit_item.dart    # Habit list item widget
    └── habit_calendar.dart # Calendar widget
```

## Usage

1. **Sign in** with Google or Apple ID
2. Tap the + button to add a new habit
3. Enter the habit name and select an interval
4. Tap the circle icon to mark the habit as complete for today
5. Swipe left to delete a habit
6. Tap the logout icon in the app bar to sign out

## Authentication

This app uses Firebase Authentication with support for:
- **Google Sign-In**: Available on all platforms
- **Apple Sign-In**: Available on iOS 13+ and macOS 10.15+

Each user's habits are stored locally but scoped to their user ID, ensuring data privacy and separation.

For complete authentication setup and configuration instructions, see:
- [docs/AUTH_README.md](docs/AUTH_README.md) - Complete authentication guide
- [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md) - Detailed Firebase setup instructions