# Component Structure: Habit Screen Redesign

## Widget Tree Structure

```
HomeScreen (Scaffold)
│
├── AppBar
│   ├── Title (Column)
│   │   ├── "Habit Tracker"
│   │   └── Date with offset
│   └── Actions
│       ├── +24 hours button
│       └── Logout button
│
├── Body (CustomScrollView)
│   │
│   ├── SliverPersistentHeader (pinned: true)
│   │   └── _DateHeaderDelegate (height: 50)
│   │       └── _buildDateHeader()
│   │           └── Container (padding: 16h, 12v)
│   │               └── Row
│   │                   ├── Expanded (flex: 3) - Empty space for habit names
│   │                   ├── SizedBox (width: 16)
│   │                   └── Expanded (flex: 5) - Date columns
│   │                       └── Row (spaceEvenly)
│   │                           ├── Date 1 (M/d)
│   │                           ├── Date 2 (M/d)
│   │                           ├── Date 3 (M/d)
│   │                           ├── Date 4 (M/d)
│   │                           └── Date 5 (M/d) ← today highlighted
│   │
│   ├── SliverToBoxAdapter
│   │   └── Padding (16px all)
│   │       └── HabitCalendar (monthly view)
│   │
│   └── SliverList
│       └── SliverChildBuilderDelegate
│           └── [HabitItem] × N habits
│               │
│               └── HabitItem
│                   └── Card (margin: 16h, 4v)
│                       └── Dismissible
│                           └── Container (borderRadius: 16)
│                               └── Padding (12px all)
│                                   └── Row
│                                       ├── Expanded (flex: 3) - Left Section
│                                       │   └── Column
│                                       │       ├── Row (icon + name)
│                                       │       │   ├── Icon Container (40×40)
│                                       │       │   ├── SizedBox (12)
│                                       │       │   └── Text (name, titleMedium)
│                                       │       ├── SizedBox (8)
│                                       │       └── Row (badges)
│                                       │           ├── Interval Badge
│                                       │           └── Streak Badge (if > 0)
│                                       │
│                                       ├── SizedBox (16)
│                                       │
│                                       └── Expanded (flex: 5) - Day Indicators
│                                           └── Row (spaceEvenly)
│                                               ├── Day Indicator 1
│                                               ├── Day Indicator 2
│                                               ├── Day Indicator 3
│                                               ├── Day Indicator 4
│                                               └── Day Indicator 5
│                                                   │
│                                                   └── Day Indicator
│                                                       └── GestureDetector
│                                                           └── AnimatedContainer (48×48)
│                                                               └── if completed: ✓ Icon
│                                                                  else: Day Label (MON/TUE/etc)
│
└── FloatingActionButton (+)
```

## Data Flow

```
HomeScreen
    │
    ├─→ TimeService.now() ──→ Calculate today
    │                          └─→ Generate 5 dates
    │                              └─→ Pass to _buildDateHeader()
    │                              └─→ Pass to each HabitItem
    │
    ├─→ HabitStorage.loadHabits() ──→ List<Habit>
    │                                  └─→ Pass to HabitCalendar
    │                                  └─→ Map to HabitItem widgets
    │
    └─→ User Actions
        ├─→ Toggle completion ──→ _toggleCompletion(habit, date?)
        │                         └─→ Update habit.completions
        │                             └─→ HabitStorage.updateHabit()
        │                                 └─→ _loadHabits()
        │
        ├─→ Delete habit ──→ _deleteHabit(habitId)
        │                    └─→ HabitStorage.deleteHabit()
        │                        └─→ _loadHabits()
        │
        └─→ Edit habit ──→ Navigate to EditHabitScreen
                          └─→ On return: _loadHabits()
```

## Layout Dimensions

```
┌────────────────────────────────────────────────────────────┐
│ STICKY HEADER (height: 50px)                               │
│ ┌──────────────────────────────────────────────────────┐   │
│ │ padding: 16h, 12v                                    │   │
│ │ ┌─────────────────┐ ┌─────────────────────────────┐ │   │
│ │ │ Empty (flex: 3) │ │ Dates (flex: 5)             │ │   │
│ │ └─────────────────┘ └─────────────────────────────┘ │   │
│ └──────────────────────────────────────────────────────┘   │
├────────────────────────────────────────────────────────────┤
│ HABIT CALENDAR (padding: 16px all)                         │
├────────────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────────┐   │
│ │ HABIT ITEM (margin: 16h, 4v | padding: 12px)         │   │
│ │ ┌────────────────┬─────────────────────────────────┐ │   │
│ │ │ Left (flex: 3) │ Day Indicators (flex: 5)        │ │   │
│ │ │ ┌────┐ Name    │ ┌───┐┌───┐┌───┐┌───┐┌───┐     │ │   │
│ │ │ │40×│ Daily    │ │48×││48×││48×││48×││48×│     │ │   │
│ │ │ │40 │ 🔥 3d    │ │48 ││48 ││48 ││48 ││48 │     │ │   │
│ │ │ └────┘          │ └───┘└───┘└───┘└───┘└───┘     │ │   │
│ │ └────────────────┴─────────────────────────────────┘ │   │
│ └──────────────────────────────────────────────────────┘   │
│ ┌──────────────────────────────────────────────────────┐   │
│ │ HABIT ITEM (margin: 16h, 4v | padding: 12px)         │   │
│ └──────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘

Key Measurements:
- Header height: 50px
- Card horizontal margin: 16px (left & right)
- Card vertical margin: 4px (top & bottom)
- Card padding: 12px (all sides)
- Icon size: 40×40px
- Day indicator size: 48×48px
- Flex ratio: 3:5 (left section : day indicators)
```

## Alignment Strategy

The key to the grid alignment is maintaining consistent flex ratios:

1. **Header Row**: 
   - Empty space: `flex: 3`
   - Date columns: `flex: 5`
   - 16px gap between

2. **Habit Row**:
   - Left section: `flex: 3`
   - Day indicators: `flex: 5`
   - 16px gap between

This ensures dates in the header align perfectly with the day indicators in each habit row, creating a clean grid appearance.
