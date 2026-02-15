import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hymn_model.dart';
import '../providers/collections_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import 'lyrics_settings_screen.dart';
import 'now_playing_screen.dart';
import 'reader_mode_screen.dart';

class SongDetailScreen extends StatefulWidget {
  final Hymn song;

  const SongDetailScreen({super.key, required this.song});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HistoryProvider>().recordViewed(widget.song.number);
    });
  }

  Future<void> _openAddToCollection() async {
    await context.read<CollectionsProvider>().waitForInit();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) => _AddToCollectionSheet(songNumber: widget.song.number),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to font size setting
    final settings = Provider.of<SettingsProvider>(context);
    final fontSizeScale = settings.fontSize; // e.g. 14.0 is base
    final song = widget.song;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
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
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                letterSpacing: 2,
              ),
            ),
            Text(
              song.title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                  color: isFav
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                onPressed: () => favorites.toggleFavorite(song.number),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz),
            onSelected: (value) {
              switch (value) {
                case 'collection':
                  _openAddToCollection();
                  break;
                case 'reader':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReaderModeScreen(song: song),
                    ),
                  );
                  break;
                case 'lyrics_settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LyricsSettingsScreen(),
                    ),
                  );
                  break;
                case 'now_playing':
                  context.read<PlayerProvider>().start(song);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'collection',
                child: Text('Add to collection'),
              ),
              PopupMenuItem(
                value: 'lyrics_settings',
                child: Text('Lyrics settings'),
              ),
              PopupMenuItem(value: 'reader', child: Text('Reader mode')),
              PopupMenuItem(value: 'now_playing', child: Text('Now playing')),
            ],
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
                  fontFamily: settings.fontFamily,
                  fontWeightValue: settings.fontWeight,
                );
              }),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<PlayerProvider>().start(song);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.play_arrow, color: Colors.white),
      ),
    );
  }
}

class _LyricSection extends StatelessWidget {
  final String label;
  final List<String> content;
  final bool isChorus;
  final double fontSize;
  final String fontFamily;
  final int fontWeightValue;

  const _LyricSection({
    required this.label,
    required this.content,
    this.isChorus = false,
    this.fontSize = 14.0,
    this.fontFamily = 'inter',
    this.fontWeightValue = 400,
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
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isChorus
            ? Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
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
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: TextStyle(
                  color: isChorus
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                  fontSize: textFontSize,
                  height: 1.6,
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

class _AddToCollectionSheet extends StatefulWidget {
  final int songNumber;

  const _AddToCollectionSheet({required this.songNumber});

  @override
  State<_AddToCollectionSheet> createState() => _AddToCollectionSheetState();
}

class _AddToCollectionSheetState extends State<_AddToCollectionSheet> {
  Future<void> _promptCreate(BuildContext context) async {
    final collectionsProvider = context.read<CollectionsProvider>();
    final controller = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Collection name'),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Create'),
          ),
        ],
      ),
    );

    if (created == true) {
      if (!mounted) return;
      final id = await collectionsProvider.createCollection(controller.text);
      if (!mounted || id == null) return;
      await collectionsProvider.toggleSong(
        collectionId: id,
        hymnNumber: widget.songNumber,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        top: 8,
      ),
      child: Consumer<CollectionsProvider>(
        builder: (context, collectionsProvider, _) {
          final collections = collectionsProvider.collections;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to collection',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose one or more collections.',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _promptCreate(context),
                    icon: Icon(Icons.add),
                    label: Text('New'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (collections.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'No collections yet. Tap New to create one.',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: collections.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (context, index) {
                      final c = collections[index];
                      final selected = c.hymnNumbers.contains(
                        widget.songNumber,
                      );
                      return ListTile(
                        onTap: () =>
                            context.read<CollectionsProvider>().toggleSong(
                              collectionId: c.id,
                              hymnNumber: widget.songNumber,
                            ),
                        leading: Icon(
                          selected ? Icons.check_circle : Icons.circle_outlined,
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : (isDark ? Colors.white38 : Colors.black38),
                        ),
                        title: Text(
                          c.name,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${c.hymnNumbers.length} hymns',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
