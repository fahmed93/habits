# Emoji/Icon Selector Feature

## Overview

The emoji/icon selector feature allows users to personalize their habits with visual icons (emojis) that help identify and differentiate habits at a glance.

## Feature Details

### Available Icons

The app provides 24 carefully selected emoji icons covering common habit categories:

#### Fitness & Exercise
- 💪 Strength training, gym, exercise
- 🏃 Running, cardio
- 🧘 Yoga, meditation, mindfulness
- 🏋️ Weightlifting
- 🚴 Cycling
- 🏊 Swimming

#### Productivity & Learning
- ✓ General tasks, completion
- 📚 Reading, studying
- 💻 Coding, computer work
- 📝 Writing, journaling
- 🎯 Goal-focused activities
- 🎓 Learning, education

#### Health & Wellness
- 🌱 Growth, healthy habits
- 💧 Hydration, water intake
- 🍎 Nutrition, healthy eating
- 🛏️ Sleep, rest

#### Creative & Personal
- 🎨 Art, painting, drawing
- 🎵 Music practice
- ✍️ Writing
- 🧹 Cleaning, organization

#### Motivation
- ⚡ Energy, motivation
- 🔥 Streak, consistency
- 🌟 Achievement
- 💡 Ideas, creativity

## User Interface

### Add Habit Screen

When creating a new habit, users see three main sections:

1. **Habit Name** - Text input field
2. **Interval Selection** - Radio buttons (Daily/Weekly/Monthly)
3. **Color Selection** - 12 color circles to choose from
4. **Icon Selection** - 24 emoji icons in a wrap layout (NEW)

#### Icon Selector Design

- **Layout**: Emojis displayed in a responsive wrap grid
- **Size**: Each icon is 44x44 pixels in a rounded square
- **Visual Feedback**:
  - Unselected: Light gray background (#EEEEEE)
  - Selected: Colored background (20% opacity of selected color) + colored border
- **Default Selection**: Checkmark (✓) is selected by default

### Habit List Display

Each habit in the list shows:
- **Circular Icon Button**: 40x40 pixels
  - Contains the selected emoji
  - Background color: Selected color when completed, gray when not
  - Border: 2px in the habit's selected color
- **Habit Name**: To the right of the icon
- **Details**: Interval and streak information below name
- **Count**: Total completions on the right

#### Visual States

**Uncompleted Habit:**
- Gray circular background
- Emoji in natural colors
- Habit's color as border

**Completed Habit:**
- Colored circular background (habit's selected color)
- Emoji in natural colors
- Line-through text

## Implementation Details

### Data Model

The `Habit` model includes:
```dart
final String icon;  // Emoji string, default: '✓'
```

### Persistence

- Icons are stored in JSON as strings
- Backward compatible: Old habits without icons default to '✓'
- No data migration required

### Code Locations

- **Model**: `lib/models/habit.dart` (lines 8, 33, 45, 60, 72, 81)
- **Icon Selector UI**: `lib/screens/add_habit_screen.dart` (lines 20-28, 175-222)
- **Display Logic**: `lib/widgets/habit_item.dart` (lines 117-125)
- **Tests**: `test/habit_test.dart` (updated serialization tests)

## User Workflow

1. User opens "Add New Habit" screen
2. Enters habit name (e.g., "Morning Exercise")
3. Selects interval (e.g., "Daily")
4. Picks a color (e.g., Blue)
5. **Picks an emoji** (e.g., 💪)
6. Taps "Save Habit"
7. Habit appears in list with 💪 icon
8. User can easily identify their exercise habit by the muscle emoji

## Benefits

### Visual Identification
- Quickly scan and find habits by icon
- Reduce cognitive load with visual cues
- Makes the app more engaging and personal

### Categorization
- Icons naturally group similar habits
- All fitness habits might use 💪, 🏃, 🧘
- All learning habits might use 📚, 💻, 🎓

### Personalization
- Users can express their personality
- Makes habit tracking more fun
- Increases user engagement

## Design Decisions

### Why Emojis?
- **Universal**: Work on all platforms without custom assets
- **Colorful**: Already visually appealing
- **Familiar**: Users know what emojis mean
- **No localization needed**: Emojis transcend language
- **Lightweight**: No image files or network requests

### Why 24 Icons?
- Enough variety for most use cases
- Not overwhelming (avoids choice paralysis)
- Fits nicely in the UI without scrolling
- Covers major habit categories

### Why Default to ✓?
- Backward compatibility with existing habits
- Universal symbol of completion/achievement
- Neutral choice that works for any habit type

## Future Enhancements

Potential additions could include:
- Custom emoji picker (access to full emoji set)
- Search/filter emojis by category
- Recently used emojis
- Ability to upload custom images
- Animated icons for streak milestones

## Testing

### Unit Tests
- ✅ Icon serialization to JSON
- ✅ Icon deserialization from JSON
- ✅ Default icon when missing
- ✅ Icon updates via copyWith()

### Manual Testing Checklist
- [ ] Create habit with each emoji
- [ ] Verify icon displays correctly in list
- [ ] Verify icon persists after app restart
- [ ] Toggle completion and check visual feedback
- [ ] Verify old habits default to ✓
- [ ] Test on different screen sizes
- [ ] Test with different color selections

## Accessibility

- Emojis are text-based, so they work with screen readers
- Size (20-24px) is large enough to see clearly
- Color is not the only indicator (shape and emoji help)
- High contrast between background and emoji

## Summary

The emoji/icon selector adds personality and visual identification to habits while maintaining simplicity and backward compatibility. Users can now express themselves and quickly identify their habits at a glance, making the habit tracking experience more engaging and personal.
