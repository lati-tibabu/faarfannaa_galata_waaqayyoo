import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/hymn_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';

class SongDetailScreen extends StatelessWidget {
  final Hymn song;

  const SongDetailScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    // Listen to font size setting
    final settings = Provider.of<SettingsProvider>(context);
    final fontSizeScale = settings.fontSize; // e.g. 14.0 is base

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'HYMN ${song.number}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.4),
                letterSpacing: 2,
              ),
            ),
            Text(
              song.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favorites, child) {
              final isFav = favorites.isFavorite(song.number);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.primary : Colors.grey,
                ),
                onPressed: () => favorites.toggleFavorite(song.number),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Theme.of(context).primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lyrics
            if (song.sections.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No lyrics available.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              ...song.sections.map((section) {
                return _LyricSection(
                  label: section.typeLabel,
                  isChorus: section.type == 'CHR',
                  content: section.lines,
                  fontSize: fontSizeScale,
                );
              }),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Play functionality placeholder
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.play_arrow, color: Colors.white),
      ),
    );
  }
}

class _LyricSection extends StatelessWidget {
  final String label;
  final List<String> content;
  final bool isChorus;
  final double fontSize;

  const _LyricSection({
    required this.label,
    required this.content,
    this.isChorus = false,
    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    // Base font sizes
    final double textFontSize = fontSize + 2.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isChorus
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isChorus
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
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
                    ? AppColors.primary
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
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: TextStyle(
                  color: isChorus
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                  fontSize: textFontSize,
                  height: 1.6,
                  fontWeight: isChorus ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
