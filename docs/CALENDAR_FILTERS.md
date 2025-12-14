# Calendar Filters Feature

## Overview
The Calendar screen now supports advanced filtering options to help users customize their view and focus on specific habits or time periods.

## Features

### 1. View Mode Selection
Users can switch between three different view modes:

- **Week View**: Shows a single week (7 days) with day-by-day completion tracking
- **Month View** (Default): Shows a full month calendar with all days
- **Year View**: Shows a 12-month overview with completion percentages for each month

View modes are selected using choice chips at the top of the calendar screen.

### 2. Habit Selection Filter
Users can filter which habits are displayed in the calendar:

- **Select All**: Shows all habits in the calendar
- **Custom Selection**: Choose specific habits to display
- **Multi-select Dialog**: Tap the habit filter chip to open a dialog with checkboxes for each habit
- **Visual Feedback**: Selected habits show as individual chips when filtering is active
- **Color Coding**: Each habit maintains its unique color in the calendar

### 3. Dynamic Updates
- Filter state persists while navigating within the calendar
- Automatically updates when habits are added or removed
- Selected habits persist across view mode changes

## UI Components

### Filter Controls
Located at the top of the calendar screen:

1. **View Mode Chips**: Row of choice chips (Week, Month, Year)
2. **Habit Filter Chip**: Shows count of selected habits (e.g., "3/5 selected")
3. **Selected Habit Chips**: Individual chips for each selected habit (when filtering)

### Calendar Views

#### Week View
- 7-day horizontal layout
- Day names as headers
- Navigation arrows to move between weeks
- Header shows date range (e.g., "January 7-13, 2024")

#### Month View
- Traditional calendar grid (7 columns)
- Day names as headers
- Navigation arrows to move between months
- Header shows month and year
- Color dots indicate completed habits
- Legend shows all habits with their colors

#### Year View
- 3x4 grid of mini-month cards
- Each card shows:
  - Month name
  - Completion percentage
  - Days completed / Total active days
  - Color-coded completion rate (green >70%, orange >40%, grey otherwise)
- Navigation arrows to move between years

## Technical Implementation

### Architecture
- `CalendarScreen` (StatefulWidget): Manages filter state
- `CalendarViewMode` enum: Defines view modes (week, month, year)
- `HabitCalendar` widget: Renders calendar based on view mode and filtered habits

### Key Methods
- `_toggleHabitSelection()`: Toggle individual habit selection
- `_selectAllHabits()`: Select all available habits
- `_deselectAllHabits()`: Clear all selections
- `_showHabitFilterDialog()`: Display habit selection dialog
- `_filteredHabits`: Computed property returning filtered habit list

### State Management
- `_selectedHabitIds`: Set of selected habit IDs
- `_viewMode`: Current calendar view mode
- Auto-initializes with all habits selected
- Updates when habit list changes via `didUpdateWidget()`

## User Workflow

### Changing View Mode
1. Open Calendar tab
2. Tap desired view chip (Week, Month, or Year)
3. Calendar updates immediately

### Filtering Habits
1. Open Calendar tab
2. Tap on habit filter chip showing "X/Y selected"
3. In dialog:
   - Check/uncheck individual habits
   - Or use "Select All" / "Deselect All" buttons
4. Tap "Done" to apply filter
5. Selected habits appear as chips below filter controls
6. Tap 'X' on individual habit chip to deselect

### Navigation
- **Week View**: Previous/Next week buttons
- **Month View**: Previous/Next month buttons
- **Year View**: Previous/Next year buttons

## Testing
Comprehensive test coverage includes:
- View mode switching
- Habit filter dialog interaction
- Select/Deselect all functionality
- Individual habit toggling
- Filter persistence
- Empty states
- Year/month/week view rendering
- Navigation in all view modes

See `test/calendar_screen_test.dart` and `test/habit_calendar_widget_test.dart` for details.

## Design Decisions

### Why These Features?
1. **View Modes**: Different users have different tracking needs - some want weekly focus, others monthly overview, or yearly trends
2. **Habit Filtering**: Users with many habits need to focus on specific ones without clutter
3. **Persistent Selection**: Reduces repeated filtering actions during a session

### UI Choices
- **Choice Chips**: Material 3 pattern for mutually exclusive options
- **Action Chip**: Clear affordance for opening filter dialog
- **Dialog**: Familiar pattern for multi-select with confirmation
- **Visual Feedback**: Selected habits shown as removable chips for transparency

## Future Enhancements
Potential improvements for future versions:
- Save filter preferences per user
- Quick filter presets (e.g., "Daily Habits", "Weekly Goals")
- Date range picker for custom periods
- Export filtered view to PDF/image
- Habit comparison view (side-by-side completion rates)
