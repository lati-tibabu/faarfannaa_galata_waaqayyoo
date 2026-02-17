import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_text.dart';
import '../providers/settings_provider.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('accessibility')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(context.tr('high_contrast')),
                  subtitle: Text(context.tr('high_contrast_sub')),
                  value: settings.highContrastMode,
                  onChanged: settings.setHighContrastMode,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                SwitchListTile(
                  title: Text(context.tr('reduce_motion')),
                  subtitle: Text(context.tr('reduce_motion_sub')),
                  value: settings.reduceMotion,
                  onChanged: settings.setReduceMotion,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                SwitchListTile(
                  title: Text(context.tr('large_touch_targets')),
                  subtitle: Text(context.tr('large_touch_targets_sub')),
                  value: settings.largeTouchTargets,
                  onChanged: settings.setLargeTouchTargets,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('accessibility_note'),
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
