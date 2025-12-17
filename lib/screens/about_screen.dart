import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About',
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
          // App Icon and Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.task_alt_rounded,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Habit Tracker',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Description Section
          _buildSectionCard(
            context,
            icon: Icons.info_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            title: 'About This App',
            content:
                'A mobile habit tracker app built with Flutter with Firebase Authentication. Track your daily, weekly, and monthly habits to build better routines and achieve your goals.',
          ),
          const SizedBox(height: 16),

          // Features Section
          _buildSectionCard(
            context,
            icon: Icons.stars_rounded,
            iconColor: Theme.of(context).colorScheme.tertiary,
            title: 'Features',
            content: '• Create custom habits with different intervals\n'
                '• Track completion with visual history\n'
                '• View completion streaks\n'
                '• Sign in with Google or Apple\n'
                '• Theme customization\n'
                '• User-specific data storage',
          ),
          const SizedBox(height: 16),

          // Developer Section
          _buildSectionCard(
            context,
            icon: Icons.code_rounded,
            iconColor: Theme.of(context).colorScheme.secondary,
            title: 'Developer',
            content: 'Built with ❤️ using Flutter',
          ),
          const SizedBox(height: 16),

          // License Section
          _buildSectionCard(
            context,
            icon: Icons.gavel_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            title: 'License',
            content: 'Open Source Project',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
