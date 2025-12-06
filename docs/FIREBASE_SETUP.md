# Firebase Configuration Guide

This guide will help you set up Firebase authentication for the Habit Tracker app.

## Prerequisites

1. A Firebase account (https://firebase.google.com/)
2. Flutter SDK installed
3. FlutterFire CLI (optional but recommended)

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com/
2. Click "Add project" or select an existing project
3. Follow the setup wizard

## Step 2: Configure Firebase for Your App

### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter app
flutterfire configure
```

This will:
- Create/update `firebase_options.dart`
- Download and configure platform-specific files
- Set up your app in Firebase Console

### Option B: Manual Configuration

#### Android Configuration

1. In Firebase Console, add an Android app:
   - Package name: `com.example.habits`
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`

2. Get your app's SHA-1 fingerprint:
   ```bash
   # Debug SHA-1
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Add this SHA-1 to Firebase Console > Project Settings > Your apps
   ```

#### iOS Configuration

1. In Firebase Console, add an iOS app:
   - Bundle ID: `com.example.habits`
   - Download `GoogleService-Info.plist`
   - Add it to `ios/Runner/GoogleService-Info.plist` in Xcode

2. Update `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR-REVERSED-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```
   (Replace YOUR-REVERSED-CLIENT-ID with the value from GoogleService-Info.plist)

## Step 3: Enable Authentication Methods

1. Go to Firebase Console > Authentication > Sign-in method
2. Enable **Google** sign-in:
   - Click on Google
   - Enable the toggle
   - Add a support email
   - Save

3. Enable **Apple** sign-in (for iOS):
   - Click on Apple
   - Enable the toggle
   - Save

## Step 4: Configure Apple Sign In (iOS only)

1. In Apple Developer Console:
   - Enable "Sign In with Apple" capability for your app
   - Configure Service IDs if needed

2. In Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select Runner target
   - Go to "Signing & Capabilities"
   - Add "Sign in with Apple" capability

## Step 5: Test Your Configuration

```bash
flutter pub get
flutter run
```

## Troubleshooting

### Google Sign In Issues
- Ensure SHA-1 is added to Firebase Console
- Check that package name matches exactly
- Verify google-services.json is in the correct location

### Apple Sign In Issues
- Only works on iOS 13+ and macOS 10.15+
- Ensure "Sign in with Apple" capability is enabled
- Check Bundle ID matches in all places

### Build Errors
- Run `flutter clean` and `flutter pub get`
- Delete `ios/Podfile.lock` and run `cd ios && pod install`
- Check that all Firebase dependencies are compatible

## Security Notes

- Never commit your actual `google-services.json` or `GoogleService-Info.plist` to public repositories
- Use environment-specific Firebase projects for development and production
- Enable Firebase App Check for production apps
- Review Firebase Security Rules for your project

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple for Flutter](https://pub.dev/packages/sign_in_with_apple)
