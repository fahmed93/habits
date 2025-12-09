# Theme Feature UI Flow

## User Journey

### Step 1: Access Settings
- User taps the settings icon (⚙️) in the app bar
- Settings screen opens showing multiple options

### Step 2: View Current Theme
- Settings screen displays "Theme" option with palette icon
- Subtitle shows current theme: "Current: Light", "Current: Dark", or "Current: System"

### Step 3: Change Theme
- User taps on the "Theme" list item
- Dialog appears titled "Choose Theme"
- Three radio options are displayed:
  - ⚪ Light
  - ⚪ Dark
  - ⚪ System
- Current selection is pre-selected with filled radio button (⚫)

### Step 4: Select New Theme
- User taps on a different theme option
- Dialog automatically closes
- App theme changes immediately
- User is returned to settings screen
- Settings screen subtitle now shows the new theme

### Step 5: Theme Persistence
- User can close the app
- When reopening, the selected theme is maintained
- No need to select theme again

## Visual States

### Settings Screen - Theme Option

```
┌─────────────────────────────────────┐
│  ⚙️  Settings                       │
├─────────────────────────────────────┤
│                                     │
│  🔔  Notifications              >   │
│  Configure reminder notifications   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🎨  Theme                      >   │
│  Current: Light                     │
│                                     │
├─────────────────────────────────────┤
│  ...                                │
└─────────────────────────────────────┘
```

### Theme Selection Dialog

```
┌─────────────────────────────────┐
│  Choose Theme                   │
├─────────────────────────────────┤
│                                 │
│  ⚫  Light                       │
│                                 │
│  ⚪  Dark                        │
│                                 │
│  ⚪  System                      │
│                                 │
├─────────────────────────────────┤
│                        [Cancel] │
└─────────────────────────────────┘
```

## Theme Effects

### Light Theme
- Uses deep purple color scheme
- Light backgrounds with dark text
- Standard Material 3 light colors
- Suitable for bright environments

### Dark Theme
- Uses deep purple color scheme with dark brightness
- Dark backgrounds with light text
- Material 3 dark colors
- Reduces eye strain in low-light environments

### System Theme
- Automatically matches device theme setting
- Switches between light and dark based on system
- Updates automatically when system theme changes
- Respects user's device-wide preference

## Implementation Notes

All screens throughout the app respond to theme changes:
- Home screen
- Calendar view
- Add habit screen
- Settings screen
- Login screen

Theme changes are:
- ✅ Immediate (no app restart required)
- ✅ Persistent (saved across app sessions)
- ✅ System-aware (follows device theme when set to System)
- ✅ Smooth (no flicker or reload artifacts)
