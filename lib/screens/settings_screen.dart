import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String? userId;
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({
    super.key,
    this.userId,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await _themeService.getThemeMode();
    setState(() {
      _currentThemeMode = themeMode;
    });
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> _showThemeDialog() async {
    final selectedMode = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeName(mode)),
              value: mode,
              groupValue: _currentThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  Navigator.pop(context, value);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedMode != null && selectedMode != _currentThemeMode) {
      setState(() {
        _currentThemeMode = selectedMode;
      });
      widget.onThemeChanged(selectedMode);
      await _themeService.setThemeMode(selectedMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Preferences Section
          _buildSectionHeader(context, 'Preferences'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            icon: Icons.notifications_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            title: 'Notifications',
            subtitle: 'Configure reminder notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationSettingsScreen(userId: widget.userId),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            icon: Icons.palette_rounded,
            iconColor: Theme.of(context).colorScheme.tertiary,
            title: 'Theme',
            subtitle: 'Current: ${_getThemeModeName(_currentThemeMode)}',
            onTap: _showThemeDialog,
          ),
          const SizedBox(height: 32),
          
          // General Section
          _buildSectionHeader(context, 'General'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            icon: Icons.language_rounded,
            iconColor: Theme.of(context).colorScheme.secondary,
            title: 'Language',
            subtitle: 'Select app language',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('TODO: Implement language settings'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            icon: Icons.cloud_upload_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            title: 'Data Sync',
            subtitle: 'Backup and sync your data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('TODO: Implement data sync settings'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // About Section
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            icon: Icons.info_rounded,
            iconColor: Theme.of(context).colorScheme.tertiary,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('TODO: Implement about page'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
