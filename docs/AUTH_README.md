# Authentication Setup Instructions

## Overview

This app now includes Firebase Authentication with support for:
- **Google Sign-In**: Available on all platforms
- **Apple Sign-In**: Available on iOS 13+ and macOS 10.15+

## Quick Start

### 1. Install Dependencies

```bash
cd /path/to/habits
flutter pub get
```

### 2. Set Up Firebase Project

You need to configure Firebase for your app. See the detailed setup in [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

**Quick Steps:**
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android and/or iOS apps to your Firebase project
3. Enable Google and Apple authentication in Firebase Console
4. Configure your app with Firebase credentials

### 3. Configure Platform-Specific Files

#### For Android:

1. Download `google-services.json` from Firebase Console
2. Replace the placeholder file at `android/app/google-services.json`
3. Get your SHA-1 fingerprint and add it to Firebase Console:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

#### For iOS:

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to your Xcode project in `ios/Runner/`
3. Enable "Sign in with Apple" capability in Xcode

### 4. Update Firebase Options

Replace `lib/firebase_options.dart` with your actual Firebase configuration. 

**Recommended**: Use FlutterFire CLI to generate this automatically:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 5. Run the App

```bash
flutter run
```

## Features Implemented

### Authentication Flow
- Users see a login screen on first launch
- Can sign in with Google or Apple (on supported devices)
- Authentication state persists across app restarts
- Users can sign out from the home screen

### Data Isolation
- Each user's habits are stored separately
- Habits are scoped to the authenticated user's ID
- Signing out clears the current session
- Signing in as a different user shows that user's habits

### UI/UX
- Clean, Material Design 3 login screen
- Loading states during authentication
- Error handling with user-friendly messages
- Sign out button in the app bar

## Code Structure

```
lib/
├── models/
│   ├── habit.dart          # Habit data model (unchanged)
│   └── user.dart           # User authentication model (NEW)
├── services/
│   ├── auth_service.dart   # Authentication service (NEW)
│   ├── habit_storage.dart  # Updated to support per-user storage
│   └── time_service.dart   # Time service (unchanged)
├── screens/
│   ├── login_screen.dart   # Login UI (NEW)
│   ├── home_screen.dart    # Updated with logout functionality
│   └── add_habit_screen.dart
└── main.dart               # Updated with auth state management
```

## Key Changes

### 1. User Model (`lib/models/user.dart`)
Simple model to represent authenticated users with uid, email, displayName, and photoURL.

### 2. AuthService (`lib/services/auth_service.dart`)
Handles all authentication operations:
- `signInWithGoogle()` - Google OAuth flow
- `signInWithApple()` - Apple OAuth flow
- `signOut()` - Sign out from all providers
- `authStateChanges` - Stream of authentication state
- `currentUser` - Get currently signed-in user

### 3. HabitStorage Updates
Now accepts an optional `userId` parameter to scope habits to specific users:
```dart
final storage = HabitStorage(userId: currentUser.uid);
```

### 4. Main App Updates
- Initializes Firebase on startup
- Uses `StreamBuilder` to listen to auth state changes
- Shows `LoginScreen` when not authenticated
- Shows `HomeScreen` when authenticated

### 5. Login Screen
- Material Design 3 UI
- Google and Apple sign-in buttons
- Checks Apple Sign-In availability dynamically
- Loading and error states

## Security Considerations

⚠️ **Important Security Notes:**

1. **Firebase Configuration Files**
   - Never commit actual `google-services.json` or `GoogleService-Info.plist` to public repos
   - The current files are placeholders with instructions
   - Update `.gitignore` to exclude these files once you add real credentials

2. **API Keys**
   - Firebase API keys in `google-services.json` are safe for client-side use
   - They are restricted by Firebase Security Rules
   - Still, follow Firebase security best practices

3. **Production Setup**
   - Use separate Firebase projects for development and production
   - Enable Firebase App Check for production apps
   - Review and configure Firebase Security Rules
   - Enable security features like email verification if needed

## Testing

### Test Authentication Flow
1. Run the app on a device/emulator
2. Try signing in with Google
3. Verify you land on the home screen
4. Create a habit
5. Sign out using the logout button
6. Sign back in and verify your habit is still there
7. (iOS only) Try signing in with Apple

### Test Multi-User Support
1. Sign in as User A
2. Create some habits
3. Sign out
4. Sign in as User B
5. Verify no habits from User A appear
6. Create different habits
7. Switch back to User A and verify original habits appear

## Troubleshooting

### Google Sign-In Fails
- Check SHA-1 fingerprint is added to Firebase Console
- Verify package name matches exactly (`com.example.habits`)
- Ensure Google Sign-In is enabled in Firebase Console
- Try `flutter clean` and rebuild

### Apple Sign-In Not Available
- Only works on iOS 13+, macOS 10.15+
- Check "Sign in with Apple" capability is enabled in Xcode
- Verify Apple Sign-In is enabled in Firebase Console

### Build Errors
- Run `flutter clean && flutter pub get`
- Check all dependencies are compatible
- For iOS: Delete `ios/Podfile.lock` and run `cd ios && pod install`

### Authentication State Not Persisting
- Firebase Auth persists by default
- Check that Firebase is initialized before any auth operations
- Verify `google-services.json` or `GoogleService-Info.plist` are correctly configured

## Next Steps

Optional enhancements you could add:
- Email/password authentication
- Phone number authentication
- Password reset functionality
- Email verification
- Profile editing
- Social profile display (avatar, name)
- Cloud Firestore for cross-device habit sync
- Offline support with local cache

## Support

For detailed Firebase setup instructions, see [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

For Firebase and FlutterFire documentation:
- [FlutterFire Overview](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Google Sign-In Package](https://pub.dev/packages/google_sign_in)
- [Apple Sign-In Package](https://pub.dev/packages/sign_in_with_apple)
