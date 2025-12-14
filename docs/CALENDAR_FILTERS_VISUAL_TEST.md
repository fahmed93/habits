# Calendar Filters - Visual Test Plan

## Test Scenarios

### Scenario 1: Initial State (Month View with All Habits)
**Setup**: Open calendar with 3 habits (Exercise, Reading, Meditation)
**Expected UI**:
- View mode chips: Week (unselected), Month (selected), Year (unselected)
- Habit filter chip: "3/3 selected" with filter icon
- Calendar: Month view showing current month
- Legend: All 3 habits with colored dots

### Scenario 2: Switch to Week View
**Action**: Tap "Week" chip
**Expected UI**:
- Week chip becomes selected (highlighted)
- Month chip becomes unselected
- Calendar shows only 7 days (Sun-Sat)
- Header shows date range (e.g., "December 8-14, 2024")
- Navigation arrows still present

### Scenario 3: Switch to Year View
**Action**: Tap "Year" chip
**Expected UI**:
- Year chip becomes selected
- Calendar shows 12 month cards in 3x4 grid
- Each card displays:
  - Month name (January, February, etc.)
  - Completion percentage
  - "X/Y days" counter
- No legend shown in year view
- Header shows year (e.g., "2024")

### Scenario 4: Open Habit Filter Dialog
**Action**: Tap on "3/3 selected" chip
**Expected UI**:
- Dialog appears with title "Select Habits"
- Two action buttons at top: "Select All" and "Deselect All"
- List of habits with checkboxes:
  - Exercise (checked, with icon and color dot)
  - Reading (checked, with icon and color dot)
  - Meditation (checked, with icon and color dot)
- "Done" button at bottom

### Scenario 5: Deselect One Habit
**Action**: In dialog, uncheck "Reading" and tap "Done"
**Expected UI**:
- Dialog closes
- Habit filter chip now shows "2/3 selected"
- Two habit chips appear: "Exercise" and "Meditation" (each with X button)
- Calendar only shows completions for Exercise and Meditation
- Legend (in month/week view) only shows Exercise and Meditation

### Scenario 6: Remove Habit via Chip
**Action**: Tap X on "Exercise" habit chip
**Expected UI**:
- Exercise chip disappears
- Habit filter updates to "1/3 selected"
- Only Meditation chip remains
- Calendar shows only Meditation completions

### Scenario 7: Select All from Dialog
**Action**: Open filter dialog, tap "Select All", tap "Done"
**Expected UI**:
- Habit filter shows "3/3 selected"
- Individual habit chips disappear (all selected = default state)
- Calendar shows all habits again
- Legend shows all 3 habits

### Scenario 8: Deselect All from Dialog
**Action**: Open filter dialog, tap "Deselect All", tap "Done"
**Expected UI**:
- Habit filter shows "0/3 selected"
- No individual habit chips (none selected)
- Calendar shows empty days (no colored dots)
- Legend shows nothing or minimal placeholder

### Scenario 9: Empty State (No Habits)
**Setup**: Calendar with no habits
**Expected UI**:
- Large calendar icon (grey)
- "No habits yet" text
- "Add habits to see them in the calendar" subtext
- No filter controls visible

### Scenario 10: Year View with Completions
**Setup**: Habits with various completion rates across months
**Expected UI for each month card**:
- January: 85% completion (green) - "17/20 days"
- February: 50% completion (orange) - "14/28 days"
- March: 20% completion (grey) - "6/31 days"
- Future months: 0% (grey) - "0/0 days"

### Scenario 11: Week View Navigation
**Setup**: Week view, current week December 8-14, 2024
**Action**: Tap left arrow
**Expected UI**:
- Header updates to "December 1-7, 2024"
- Calendar shows previous week's 7 days
- Completion dots update for new date range

**Action**: Tap right arrow twice
**Expected UI**:
- Header updates to "December 15-21, 2024"
- Calendar shows next week's 7 days

### Scenario 12: Month View Navigation
**Setup**: Month view, December 2024
**Action**: Tap left arrow
**Expected UI**:
- Header updates to "November 2024"
- Calendar shows November days (30 days)

### Scenario 13: Year View Navigation
**Setup**: Year view, 2024
**Action**: Tap right arrow
**Expected UI**:
- Header updates to "2025"
- All month cards show 2025 data

### Scenario 14: Filter Persistence Across View Modes
**Setup**: Month view with only Exercise selected (1/3)
**Actions**: 
1. Switch to Week view
2. Switch to Year view
3. Switch back to Month view

**Expected UI at each step**:
- Habit filter always shows "1/3 selected"
- Exercise chip always visible
- Calendar always shows only Exercise data
- Filter selection persists across all view changes

### Scenario 15: Responsive Layout
**Expected UI on different screen sizes**:
- Small screens: Filter chips may wrap to multiple rows
- Habit chips scroll horizontally if many habits selected
- Calendar grid adapts but maintains aspect ratio
- Dialog content scrollable if many habits

## Verification Checklist
- [ ] All view mode chips work and show correct selection state
- [ ] Habit filter dialog opens and closes properly
- [ ] Select All / Deselect All buttons work
- [ ] Individual habit checkboxes toggle correctly
- [ ] Habit filter count updates accurately
- [ ] Selected habit chips display and remove correctly
- [ ] Calendar content updates based on filters
- [ ] Navigation works in all view modes
- [ ] Legend shows/hides appropriately
- [ ] Year view cards calculate percentages correctly
- [ ] Empty states display properly
- [ ] Filter persists across view mode changes
- [ ] All text is readable and properly formatted
- [ ] Icons and colors display correctly
- [ ] Touch targets are appropriately sized
- [ ] No layout overflow or clipping issues
