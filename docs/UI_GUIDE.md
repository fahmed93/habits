# Habit Tracker - App Flow & UI Description

## Screen Flow
```
[Home Screen]
     |
     ├─── Tap + Button ───> [Add Habit Screen]
     |                             |
     |                        Enter Name
     |                        Select Interval
     |                             |
     |                        Save Button ───> Back to [Home Screen]
     |
     ├─── Tap Circle Icon ───> Toggle Completion
     |
     └─── Swipe Left ───> [Confirmation Dialog] ───> Delete Habit
```

## Home Screen Layout
```
┌─────────────────────────────────┐
│  Habit Tracker              🔙  │ ← App Bar
├─────────────────────────────────┤
│                                 │
│  ┌───────────────────────────┐ │
│  │ ⭕ Exercise        [ 15 ] │ │ ← Habit Item
│  │    Daily                   │ │
│  │    5 day streak 🔥        │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ ✅ Read Books     [ 23 ] │ │ ← Completed Today
│  │    Daily                   │ │
│  │    2 day streak 🔥        │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ ⭕ Meditate       [  8 ] │ │
│  │    Weekly                  │ │
│  │                            │ │
│  └───────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
                │
                [+] ← Floating Action Button
```

## Add Habit Screen Layout
```
┌─────────────────────────────────┐
│  ← Add New Habit                │ ← App Bar
├─────────────────────────────────┤
│                                 │
│  Habit Name                     │
│  ┌─────────────────────────┐   │
│  │ Exercise                │   │ ← Text Input
│  └─────────────────────────┘   │
│                                 │
│  Interval                       │
│  ◉ Daily                        │ ← Radio Button (Selected)
│  ○ Weekly                       │ ← Radio Button
│  ○ Monthly                      │ ← Radio Button
│                                 │
│                                 │
│                                 │
│  ┌─────────────────────────┐   │
│  │    Save Habit           │   │ ← Save Button
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

## Empty State Layout
```
┌─────────────────────────────────┐
│  Habit Tracker              🔙  │
├─────────────────────────────────┤
│                                 │
│          ✓                      │
│        ╱   ╲                    │ ← Large Icon
│       │     │                   │
│        ╲   ╱                    │
│          ᵥ                      │
│                                 │
│     No habits yet               │ ← Empty Message
│                                 │
│  Tap the + button to add        │
│  a habit                        │
│                                 │
└─────────────────────────────────┘
                │
                [+] ← Call to Action
```

## Color Scheme
- **Primary Color**: Deep Purple (Material 3)
- **Completed State**: Green with checkmark
- **Incomplete State**: Grey circle outline
- **Streak Indicator**: Orange text with 🔥 emoji
- **Delete Background**: Red
- **Counter Badge**: Deep Purple

## Interactions

### 1. Mark Complete
- **Action**: Tap circle icon
- **Visual**: Circle → Green checkmark
- **Effect**: 
  - Text gets line-through
  - Counter increments
  - Streak updates
  - Saved to storage

### 2. Add Habit
- **Action**: Tap + button
- **Flow**: Navigate to form → Fill name → Select interval → Save
- **Effect**: New habit appears in list

### 3. Delete Habit
- **Action**: Swipe left on habit item
- **Visual**: Red background with trash icon appears
- **Effect**: Confirmation dialog → Delete if confirmed

### 4. View Streak
- **Display**: Shows under habit name when active
- **Format**: "X day/week/month streak 🔥"
- **Calculation**: Consecutive completions from today backwards

## Data Flow
```
User Action
    ↓
UI Event (onTap, onSwipe, etc.)
    ↓
State Update (setState)
    ↓
Storage Service (save/load)
    ↓
SharedPreferences (JSON)
    ↓
Rebuild UI with new data
```

## Key Features in UI

1. **Instant Feedback**: Tapping shows immediate visual response
2. **Confirmation Dialogs**: Prevents accidental deletions
3. **Empty States**: Helpful guidance when no data
4. **Loading States**: Spinner while loading data
5. **Material Design**: Follows Material Design 3 guidelines
6. **Responsive**: Works on different screen sizes
7. **Intuitive**: Common mobile patterns (swipe to delete, FAB for add)

## Technical UI Components

- **Material App**: Root application widget
- **Scaffold**: Page structure with app bar and body
- **ListView.builder**: Efficient scrolling list
- **Card**: Material card for each habit
- **Dismissible**: Swipe to delete functionality
- **FloatingActionButton**: Primary action button
- **Form**: Input validation
- **RadioListTile**: Interval selection
- **TextFormField**: Habit name input
- **AlertDialog**: Deletion confirmation
- **CircularProgressIndicator**: Loading state

## Accessibility

- Clear visual hierarchy
- Large tap targets (40x40 for checkboxes)
- Confirmation dialogs for destructive actions
- Helpful empty states
- Consistent color meanings

This UI design prioritizes simplicity, clarity, and ease of use while maintaining a modern, polished appearance.
