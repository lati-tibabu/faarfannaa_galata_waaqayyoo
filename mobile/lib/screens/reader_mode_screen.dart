import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hymn_model.dart';
import '../providers/settings_provider.dart';
import '../theme.dart';
import 'lyrics_settings_screen.dart';

class ReaderModeScreen extends StatelessWidget {
  final Hymn song;

  const ReaderModeScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final fontSizeScale = settings.fontSize;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Lyrics settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LyricsSettingsScreen()),
              );
            },
          ),
        ],
        title: Text(
          'HYMN ${song.number}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              if (song.sections.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No lyrics available.'),
                )
              else
                ...song.sections.map((section) {
                  return _ReaderLyricSection(
                    label: section.typeLabel,
                    isChorus: section.type == 'CHR',
                    content: section.lines,
                    fontSize: fontSizeScale,
                    fontFamily: settings.fontFamily,
                    fontWeightValue: settings.fontWeight,
                  );
                }),
              const SizedBox(height: 30),
              Text(
                'Tip: Tune typography with the top-right settings icon.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderLyricSection extends StatelessWidget {
  final String label;
  final List<String> content;
  final bool isChorus;
  final double fontSize;
  final String fontFamily;
  final int fontWeightValue;

  const _ReaderLyricSection({
    required this.label,
    required this.content,
    this.isChorus = false,
    this.fontSize = 14.0,
    this.fontFamily = 'inter',
    this.fontWeightValue = 400,
  });

  @override
  Widget build(BuildContext context) {
    final double textFontSize = fontSize + 4.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isChorus
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: isChorus
            ? Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.35),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: isChorus
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).disabledColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...content.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: textFontSize,
                  height: 1.7,
                  fontWeight: isChorus
                      ? FontWeight.w500
                      : _fontWeight(fontWeightValue),
                  fontFamily: fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FontWeight _fontWeight(int value) {
    switch (value) {
      case 300:
        return FontWeight.w300;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 400:
      default:
        return FontWeight.w400;
    }
  }
}
