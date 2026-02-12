import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/settings_provider.dart';
import 'about_screen.dart';
import 'accessibility_settings_screen.dart';
import 'backup_restore_screen.dart';
import 'collections_screen.dart';
import 'help_screen.dart';
import 'language_settings_screen.dart';
import 'onboarding_screen.dart';
import 'primary_color_picker_sheet.dart';
import 'privacy_policy_screen.dart';
import 'recently_viewed_screen.dart';
import 'terms_screen.dart';
import 'whats_new_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('APP SETTINGS'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildListTile(
                  title: 'Dark Mode',
                  leadingIcon: Icons.dark_mode,
                  leadingColor: Colors.blue,
                  trailing: Switch(
                    value: settings.isDarkMode,
                    onChanged: settings.toggleTheme,
                  ),
                ),
                _divider(),
                _buildListTile(
                  title: 'Primary Color',
                  leadingIcon: Icons.palette_outlined,
                  leadingColor: Theme.of(context).colorScheme.primary,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: settings.primaryColor,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      builder: (_) => PrimaryColorPickerSheet(
                        initialColor: settings.primaryColor,
                        onSave: settings.setPrimaryColor,
                      ),
                    );
                  },
                ),
                _divider(),
                _buildListTile(
                  title: 'Language',
                  leadingIcon: Icons.language,
                  leadingColor: Colors.indigo,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settings.languageCode == 'om' ? 'Oromo' : 'English',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LanguageSettingsScreen(),
                      ),
                    );
                  },
                ),
                _divider(),
                _buildListTile(
                  title: 'Accessibility',
                  leadingIcon: Icons.accessibility_new,
                  leadingColor: Colors.teal,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccessibilitySettingsScreen(),
                      ),
                    );
                  },
                ),
                _divider(),
                _buildListTile(
                  title: "What's New",
                  leadingIcon: Icons.new_releases_outlined,
                  leadingColor: Colors.orange,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WhatsNewScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Lyrics typography settings are available from song pages.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('LIBRARY'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildListTile(
                  title: 'Recently Viewed',
                  leadingIcon: Icons.history,
                  leadingColor: Colors.teal,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecentlyViewedScreen(),
                      ),
                    );
                  },
                ),
                _divider(),
                _buildListTile(
                  title: 'Collections',
                  leadingIcon: Icons.folder_open,
                  leadingColor: Colors.indigo,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CollectionsScreen(),
                      ),
                    );
                  },
                ),
                _divider(),
                _buildListTile(
                  title: 'Backup & Restore',
                  leadingIcon: Icons.cloud_upload_outlined,
                  leadingColor: Theme.of(context).colorScheme.primary,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BackupRestoreScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('SUPPORT'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildListTile(
                  title: 'Help & Feedback',
                  leadingIcon: Icons.help_outline,
                  leadingColor: Colors.blueGrey,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    );
                  },
                ),
                _divider(),
                _buildListTile(
                  title: 'Onboarding',
                  leadingIcon: Icons.play_circle_outline,
                  leadingColor: Colors.deepPurple,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OnboardingScreen(
                          onFinish: () async {
                            await context
                                .read<OnboardingProvider>()
                                .setComplete(true);
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('ABOUT'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildListTile(
                  title: 'About the App',
                  leadingIcon: Icons.info_outline,
                  leadingColor: Colors.grey,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                _divider(),
                _buildListTile(
                  title: 'Privacy Policy',
                  leadingIcon: Icons.privacy_tip_outlined,
                  leadingColor: Colors.green,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                _divider(),
                _buildListTile(
                  title: 'Terms',
                  leadingIcon: Icons.description_outlined,
                  leadingColor: Theme.of(context).colorScheme.primary,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 50,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData leadingIcon,
    required Color leadingColor,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: leadingColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(leadingIcon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing,
    );
  }
}
