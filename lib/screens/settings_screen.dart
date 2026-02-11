import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
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
                    activeColor: Colors.green,
                  ),
                ),
                Divider(
                  height: 1,
                  indent: 50,
                  color: Colors.grey.withOpacity(0.2),
                ),
                _buildListTile(
                  title: 'Font Size',
                  leadingIcon: Icons.format_size,
                  leadingColor: AppColors.primary,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getFontSizeLabel(settings.fontSize),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                        title: const Text("Select Font Size"),
                        children: [
                          SimpleDialogOption(
                            child: const Text("Small"),
                            onPressed: () {
                              settings.setFontSize(12.0);
                              Navigator.pop(ctx);
                            },
                          ),
                          SimpleDialogOption(
                            child: const Text("Medium"),
                            onPressed: () {
                              settings.setFontSize(14.0);
                              Navigator.pop(ctx);
                            },
                          ),
                          SimpleDialogOption(
                            child: const Text("Large"),
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
          _buildSectionHeader('ABOUT THE APP'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildListTile(
              title: 'Version',
              leadingIcon: Icons.info,
              leadingColor: Colors.grey,
              trailing: const Text(
                "1.0.0",
                style: TextStyle(color: Colors.grey),
              ),
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

  String _getFontSizeLabel(double size) {
    if (size <= 12.0) return "Small";
    if (size >= 18.0) return "Large";
    return "Medium";
  }
}
