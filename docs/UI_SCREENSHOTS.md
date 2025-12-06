# UI Screenshots Description

Since the app requires Firebase configuration to run, here are detailed descriptions of the new UI screens:

## Login Screen

### Layout
```
┌────────────────────────────────────┐
│                                    │
│                                    │
│           ✓ (Large Icon)           │
│        Habit Tracker               │
│   Track your habits, achieve       │
│         your goals                 │
│                                    │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  🔑  Continue with Google    │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  🍎  Continue with Apple     │ │
│  └──────────────────────────────┘ │
│                                    │
│    By continuing, you agree to     │
│    our Terms of Service and        │
│        Privacy Policy              │
│                                    │
└────────────────────────────────────┘
```

### Visual Details

#### App Icon/Logo
- Large check circle outline icon (100px)
- Primary purple color (from theme)
- Centered at top of screen

#### App Title
- Text: "Habit Tracker"
- Style: Large headline, bold
- Color: Primary purple
- Centered

#### Subtitle
- Text: "Track your habits, achieve your goals"
- Style: Body text
- Color: Gray (600)
- Centered

#### Google Sign-In Button
- Full-width button with rounded corners
- White background with gray border
- Login icon + "Continue with Google" text
- Black text color
- 56px height
- Elevated (shadow)

#### Apple Sign-In Button (iOS/macOS only)
- Full-width button with rounded corners
- Black background
- Apple icon + "Continue with Apple" text
- White text color
- 56px height
- Elevated (shadow)
- Only shows on devices that support Apple Sign-In

#### Terms Notice
- Small gray text at bottom
- "By continuing, you agree to our Terms of Service and Privacy Policy"

#### Loading State
- When signing in, buttons are hidden
- Circular progress indicator shown instead
- Centered on screen

## Home Screen Changes

### App Bar Updates
```
┌────────────────────────────────────┐
│  Habit Tracker        ⏰  ↪️       │
│  Monday, December 6, 2025          │
└────────────────────────────────────┘
```

#### New Logout Button
- Added logout icon button (↪️) next to time adjustment button
- Shows "Sign Out" on hover/long press
- Clicking shows confirmation dialog

### Sign Out Dialog
```
┌────────────────────────────────┐
│  Sign Out                      │
│                                │
│  Are you sure you want to      │
│  sign out?                     │
│                                │
│    [Cancel]      [Sign Out]    │
└────────────────────────────────┘
```

## Color Scheme

All screens follow Material Design 3 with:
- **Primary Color**: Deep Purple (from seed color)
- **Background**: White/Light gray
- **Text**: Black/Dark gray
- **Buttons**: White (Google), Black (Apple)
- **Accents**: Primary purple for icons and highlights

## Responsive Design

- All screens use SafeArea to respect device notches/insets
- Buttons are full-width on mobile with 32px horizontal padding
- Vertical spacing adapts to screen height
- Loading states replace interactive elements to prevent double-taps

## Animations

- Auth state changes trigger smooth page transitions
- Button presses show standard Material ripple effect
- Loading spinner rotates continuously
- Dialog appears with fade-in animation

## Accessibility

- All buttons have semantic labels
- Icons include tooltips
- Text contrast meets WCAG AA standards
- Touch targets are at least 48x48 logical pixels
- Screen reader compatible

## Error States

When sign-in fails:
- SnackBar appears at bottom of screen
- Red background with white text
- Message: "Sign in cancelled or failed" or specific error
- Auto-dismisses after a few seconds

## Empty State (No Firebase Config)

If Firebase is not properly configured:
- App will show error during initialization
- Debug console will show Firebase initialization errors
- User must configure Firebase before app can run

---

**Note**: These are design descriptions. To see the actual UI, you need to:
1. Configure Firebase following FIREBASE_SETUP.md
2. Run `flutter run` on a device or simulator
3. The login screen will appear on first launch
