import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class LyricsSettingsScreen extends StatelessWidget {
  const LyricsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('Lyrics Settings'), centerTitle: true),
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
                ListTile(
                  title: const Text('Font Size'),
                  subtitle: Text(_fontSizeLabel(settings.fontSize)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFontSizeDialog(context, settings),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                ListTile(
                  title: const Text('Font Family'),
                  subtitle: Text(_fontFamilyLabel(settings.fontFamily)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFontFamilyDialog(context, settings),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                ListTile(
                  title: const Text('Font Weight'),
                  subtitle: Text(_fontWeightLabel(settings.fontWeight)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFontWeightDialog(context, settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'These options affect lyrics pages only.',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, SettingsProvider settings) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Font Size'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              settings.setFontSize(12.0);
              Navigator.pop(ctx);
            },
            child: const Text('Small'),
          ),
          SimpleDialogOption(
            onPressed: () {
              settings.setFontSize(14.0);
              Navigator.pop(ctx);
            },
            child: const Text('Medium'),
          ),
          SimpleDialogOption(
            onPressed: () {
              settings.setFontSize(18.0);
              Navigator.pop(ctx);
            },
            child: const Text('Large'),
          ),
        ],
      ),
    );
  }

  void _showFontFamilyDialog(BuildContext context, SettingsProvider settings) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Font Family'),
        children: [
          _fontFamilyOption(ctx, settings, 'inter', 'Inter'),
          _fontFamilyOption(ctx, settings, 'nunito', 'Nunito Sans'),
          _fontFamilyOption(ctx, settings, 'poppins', 'Poppins'),
          _fontFamilyOption(ctx, settings, 'playfair', 'Playfair Display'),
          _fontFamilyOption(ctx, settings, 'merriweather', 'Merriweather'),
        ],
      ),
    );
  }

  SimpleDialogOption _fontFamilyOption(
    BuildContext ctx,
    SettingsProvider settings,
    String value,
    String label,
  ) {
    return SimpleDialogOption(
      onPressed: () {
        settings.setFontFamily(value);
        Navigator.pop(ctx);
      },
      child: Text(label, style: TextStyle(fontFamily: value)),
    );
  }

  void _showFontWeightDialog(BuildContext context, SettingsProvider settings) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Font Weight'),
        children: [
          _fontWeightOption(ctx, settings, 300, 'Light (300)'),
          _fontWeightOption(ctx, settings, 400, 'Regular (400)'),
          _fontWeightOption(ctx, settings, 500, 'Medium (500)'),
          _fontWeightOption(ctx, settings, 600, 'SemiBold (600)'),
          _fontWeightOption(ctx, settings, 700, 'Bold (700)'),
        ],
      ),
    );
  }

  SimpleDialogOption _fontWeightOption(
    BuildContext ctx,
    SettingsProvider settings,
    int value,
    String label,
  ) {
    return SimpleDialogOption(
      onPressed: () {
        settings.setFontWeight(value);
        Navigator.pop(ctx);
      },
      child: Text(label),
    );
  }

  String _fontSizeLabel(double size) {
    if (size <= 12.0) return 'Small';
    if (size >= 18.0) return 'Large';
    return 'Medium';
  }

  String _fontFamilyLabel(String family) {
    switch (family) {
      case 'nunito':
        return 'Nunito Sans';
      case 'poppins':
        return 'Poppins';
      case 'playfair':
        return 'Playfair Display';
      case 'merriweather':
        return 'Merriweather';
      case 'inter':
      default:
        return 'Inter';
    }
  }

  String _fontWeightLabel(int weight) {
    switch (weight) {
      case 300:
        return 'Light';
      case 500:
        return 'Medium';
      case 600:
        return 'SemiBold';
      case 700:
        return 'Bold';
      case 400:
      default:
        return 'Regular';
    }
  }
}
