import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility'), centerTitle: true),
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
                  title: const Text('High Contrast'),
                  subtitle: const Text('Increase UI contrast and separators'),
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
                  title: const Text('Reduce Motion'),
                  subtitle: const Text('Minimize page transition animations'),
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
                  title: const Text('Large Touch Targets'),
                  subtitle: const Text('Increase tap target sizes'),
                  value: settings.largeTouchTargets,
                  onChanged: settings.setLargeTouchTargets,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'These settings apply app-wide immediately.',
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
