import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/onboarding_provider.dart';
import 'about_screen.dart';
import 'backup_restore_screen.dart';
import 'collections_screen.dart';
import 'help_screen.dart';
import 'onboarding_screen.dart';
import 'privacy_policy_screen.dart';
import 'primary_color_picker_sheet.dart';
import 'recently_viewed_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('APPEARANCE'),
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
                    onChanged: (value) => settings.toggleTheme(value),
                    activeThumbColor: Colors.green,
                  ),
                ),
                Divider(
                  height: 1,
                  indent: 50,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _buildListTile(
                  title: 'Font Size',
                  leadingIcon: Icons.format_size,
                  leadingColor: Theme.of(context).colorScheme.primary,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getFontSizeLabel(settings.fontSize),
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                        title: Text("Select Font Size"),
                        children: [
                          SimpleDialogOption(
                            child: Text("Small"),
                            onPressed: () {
                              settings.setFontSize(12.0);
                              Navigator.pop(ctx);
                            },
                          ),
                          SimpleDialogOption(
                            child: Text("Medium"),
                            onPressed: () {
                              settings.setFontSize(14.0);
                              Navigator.pop(ctx);
                            },
                          ),
                          SimpleDialogOption(
                            child: Text("Large"),
                            onPressed: () {
                              settings.setFontSize(18.0);
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 50,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
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
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      builder: (_) => PrimaryColorPickerSheet(
                        initialColor: settings.primaryColor,
                        onSave: (color) => settings.setPrimaryColor(color),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Adjust the app's look and reading experience to your preference.",
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
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecentlyViewedScreen(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 50,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _buildListTile(
                  title: 'Collections',
                  leadingIcon: Icons.folder_open,
                  leadingColor: Colors.indigo,
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CollectionsScreen(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 50,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _buildListTile(
                  title: 'Backup & Restore',
                  leadingIcon: Icons.cloud_upload_outlined,
                  leadingColor: Theme.of(context).colorScheme.primary,
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
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
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 50,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _buildListTile(
                  title: 'Onboarding',
                  leadingIcon: Icons.play_circle_outline,
                  leadingColor: Colors.deepPurple,
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
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
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 50,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _buildListTile(
                  title: 'Privacy Policy',
                  leadingIcon: Icons.privacy_tip_outlined,
                  leadingColor: Colors.green,
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 50,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _buildListTile(
                  title: 'Terms',
                  leadingIcon: Icons.description_outlined,
                  leadingColor: Theme.of(context).colorScheme.primary,
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
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
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
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
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing,
    );
  }

  String _getFontSizeLabel(double size) {
    if (size <= 12.0) return "Small";
    if (size >= 18.0) return "Large";
    return "Medium";
  }
}
