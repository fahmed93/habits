# Export/Import Data Feature

## Overview
The Export/Import feature allows users to back up and restore their habit data, including habits, notification settings, and theme preferences. This is useful for:
- Creating backups before major changes
- Migrating data to a new device
- Sharing habit templates with others
- Recovering from data loss

## How to Use

### Exporting Data

1. Navigate to **Settings** from the main screen
2. Scroll to the **General** section
3. Tap on **Export Data**
4. Confirm the export in the dialog
5. Wait for the export to complete
6. The system share sheet will appear, allowing you to:
   - Save the file to your device
   - Share via email, messaging apps, or cloud storage
   - AirDrop to another device (iOS/macOS)

The exported file will be named `habits_backup_[timestamp].json` where timestamp is the Unix milliseconds when the export was created.

### Importing Data

1. Navigate to **Settings** from the main screen
2. Scroll to the **General** section  
3. Tap on **Import Data**
4. Read the warning that current data will be replaced
5. Confirm the import in the dialog
6. Select a backup JSON file from your device
7. Wait for the import to complete
8. You'll see a success message
9. Navigate back to the home screen to see your imported habits

**Important Notes:**
- Importing will **replace** all current data
- Export your current data first if you want to keep it
- Theme settings apply immediately after import
- Habits will update when you return to the home screen
- The import process validates the backup file format

## Data Format

The backup file is a JSON document with the following structure:

```json
{
  "version": "1.0.0",
  "exportDate": "2024-12-17T04:00:00.000Z",
  "userId": "user123",
  "habits": [
    {
      "id": "1",
      "name": "Morning Exercise",
      "interval": "daily",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "completions": [
        "2024-01-01T00:00:00.000Z",
        "2024-01-02T00:00:00.000Z"
      ],
      "colorValue": 4285612273,
      "icon": "💪"
    }
  ],
  "notificationSettings": {
    "enabled": true,
    "reminderTime": "09:00",
    "dailyReminder": true,
    "weeklyReminder": false,
    "monthlyReminder": true
  },
  "themeMode": "dark"
}
```

### Fields

- **version**: Format version (currently "1.0.0")
- **exportDate**: ISO 8601 timestamp when export was created
- **userId**: User ID the data belongs to (can be null for guest users)
- **habits**: Array of habit objects with all their properties
- **notificationSettings**: Notification configuration
- **themeMode**: Theme preference ("light", "dark", or "system")

## Technical Implementation

### Service Layer
The `DataExportImportService` handles all export/import operations:

```dart
final service = DataExportImportService(userId: userId);

// Export to file and share
await service.exportToFile();

// Import from user-selected file
final success = await service.importFromFile();

// Low-level export (for testing or custom flows)
final data = await service.exportData();

// Low-level import (for testing or custom flows)
await service.importData(jsonData);
```

### User Scoping
The service respects user isolation:
- Each user's data is stored separately in SharedPreferences
- The `userId` parameter ensures data is scoped correctly
- Guest users have userId set to a special guest constant
- Importing respects the current user's scope

### Dependencies
The feature uses these Flutter packages:
- **file_picker** (^8.0.0): For selecting backup files to import
- **path_provider** (^2.1.0): For accessing temporary directory
- **share_plus** (^10.0.0): For sharing exported files

### Validation
Import validation checks:
1. File format is valid JSON
2. JSON contains required fields: `version` and `habits`
3. Habit objects can be deserialized properly
4. Theme mode value is one of: light, dark, system

Invalid imports throw an exception with a descriptive error message.

### Error Handling
- User cancellation during file selection is handled gracefully (no error shown)
- Invalid JSON shows an error message to the user
- File read errors are caught and displayed
- Network/permission errors are surfaced to the user

## Testing

The feature includes comprehensive unit tests in `test/data_export_import_service_test.dart`:

- Export includes all data fields
- Export handles empty habits
- Import restores all data correctly
- Import validates required fields
- Import handles partial data
- Import replaces existing data
- Theme mode conversion works correctly
- User cancellation is handled gracefully

Run tests with:
```bash
flutter test test/data_export_import_service_test.dart
```

## Future Enhancements

Potential improvements for future versions:
- Cloud backup integration (Google Drive, iCloud, Dropbox)
- Automatic periodic backups
- Version migration for format changes
- Selective import (choose which data to import)
- Merge mode (combine with existing data instead of replacing)
- Encrypted backups for privacy
- Backup history and management
- Import preview before confirming
