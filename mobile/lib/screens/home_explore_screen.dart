import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_text.dart';
import '../theme.dart';
import '../models/hymn_model.dart';
import '../providers/favorites_provider.dart';
import '../services/song_service.dart';
import 'collections_screen.dart';
import 'now_playing_screen.dart';
import 'recently_viewed_screen.dart';
import 'search_screen.dart';
import 'song_detail_screen.dart';
import 'song_index_screen.dart';

class HomeExploreScreen extends StatefulWidget {
  const HomeExploreScreen({super.key});

  @override
  State<HomeExploreScreen> createState() => _HomeExploreScreenState();
}

class _HomeExploreScreenState extends State<HomeExploreScreen> {
  final SongService _songService = SongService();
  List<Hymn> _allSongs = [];
  String _selectedCategory = '__all__';
  bool _favoritesOnly = false;
  _SortOption _sort = _SortOption.number;

  @override
  void initState() {
    super.initState();
    _songService.addCatalogListener(_loadSongs);
    _loadSongs();
  }

  @override
  void dispose() {
    _songService.removeCatalogListener(_loadSongs);
    super.dispose();
  }

  void _loadSongs() {
    if (!mounted) return;
    setState(() {
      _allSongs = _songService.getAllSongs();
    });
  }

  void _openFilters() async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) =>
          _FilterSheet(favoritesOnly: _favoritesOnly, sort: _sort),
    );

    if (!mounted || result == null) return;
    setState(() {
      _favoritesOnly = result.favoritesOnly;
      _sort = result.sort;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = context.watch<FavoritesProvider>();

    List<Hymn> songs = _allSongs;
    if (_selectedCategory != '__all__') {
      songs = songs
          .where(
            (s) => s.category.toLowerCase() == _selectedCategory.toLowerCase(),
          )
          .toList();
    }
    if (_favoritesOnly) {
      songs = songs.where((s) => favorites.isFavorite(s.number)).toList();
    }

    songs.sort((a, b) {
      switch (_sort) {
        case _SortOption.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case _SortOption.number:
          return a.number.compareTo(b.number);
      }
    });

    final categories = <String>[
      '__all__',
      ..._songService.getUniqueCategories(),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            toolbarHeight: 68,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor:
                Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor,
            shape: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            titleSpacing: 20,
            centerTitle: false,
            title: Text(
              context.tr('hymns'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              IconButton(
                tooltip: context.tr('search'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                icon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              IconButton(
                tooltip: context.tr('filter'),
                onPressed: _openFilters,
                icon: Icon(
                  Icons.tune,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: context.tr('more'),
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'index':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SongIndexScreen(),
                        ),
                      );
                      break;
                    case 'recent':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecentlyViewedScreen(),
                        ),
                      );
                      break;
                    case 'collections':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CollectionsScreen(),
                        ),
                      );
                      break;
                    case 'now_playing':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NowPlayingScreen(),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'index',
                    child: Text(context.tr('song_index')),
                  ),
                  PopupMenuItem(
                    value: 'recent',
                    child: Text(context.tr('recently_viewed')),
                  ),
                  PopupMenuItem(
                    value: 'collections',
                    child: Text(context.tr('collections')),
                  ),
                  PopupMenuItem(
                    value: 'now_playing',
                    child: Text(context.tr('now_playing')),
                  ),
                ],
              ),
              const SizedBox(width: 6),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: context.tr('favorites'),
                          isActive: _favoritesOnly,
                          onTap: () =>
                              setState(() => _favoritesOnly = !_favoritesOnly),
                        ),
                        const SizedBox(width: 8),
                        ...categories.map((c) {
                          final active =
                              _selectedCategory.toLowerCase() ==
                              c.toLowerCase();
                          return _CategoryChip(
                            label: c == '__all__'
                                ? context.tr('all')
                                : _categoryLabel(context, c),
                            isActive: active,
                            onTap: () => setState(() => _selectedCategory = c),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (songs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    _favoritesOnly
                        ? context.tr('no_favorites_found')
                        : context.tr('no_hymns_found'),
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = songs[index];
                  // Determine a subtitle (e.g., first line of first verse/chorus or author if available)
                  String subtitle = '';
                  if (song.sections.isNotEmpty &&
                      song.sections.first.lines.isNotEmpty) {
                    subtitle = song.sections.first.lines.first;
                  }

                  return _HymnTile(hymn: song, subtitle: subtitle);
                }, childCount: songs.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _categoryLabel(BuildContext context, String category) {
    final key = 'category_${category.toLowerCase()}';
    final translated = context.tr(key);
    if (translated != key) return translated;
    if (category.isEmpty) return category;
    return '${category[0].toUpperCase()}${category.substring(1)}';
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _CategoryChip({required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? primary
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (isDark ? Colors.white60 : Colors.black54),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _HymnTile extends StatelessWidget {
  final Hymn hymn;
  final String subtitle;

  const _HymnTile({required this.hymn, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongDetailScreen(song: hymn),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.secondary.withValues(alpha: 0.5)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: Text(
              hymn.number.toString(),
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          hymn.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white24 : Colors.black26,
        ),
      ),
    );
  }
}

enum _SortOption { number, title }

class _FilterResult {
  final bool favoritesOnly;
  final _SortOption sort;

  const _FilterResult({required this.favoritesOnly, required this.sort});
}

class _FilterSheet extends StatefulWidget {
  final bool favoritesOnly;
  final _SortOption sort;

  const _FilterSheet({required this.favoritesOnly, required this.sort});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late bool _favoritesOnly;
  late _SortOption _sort;

  @override
  void initState() {
    super.initState();
    _favoritesOnly = widget.favoritesOnly;
    _sort = widget.sort;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('browse_options'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: _favoritesOnly,
            onChanged: (v) => setState(() => _favoritesOnly = v),
            title: Text(context.tr('favorites_only')),
            secondary: Icon(Icons.favorite, color: primary),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('sort_by'),
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          RadioGroup<_SortOption>(
            groupValue: _sort,
            onChanged: (v) => setState(() => _sort = v ?? _SortOption.number),
            child: Column(
              children: [
                RadioListTile<_SortOption>(
                  value: _SortOption.number,
                  title: Text(context.tr('number')),
                ),
                RadioListTile<_SortOption>(
                  value: _SortOption.title,
                  title: Text(context.tr('title')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('cancel')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _FilterResult(favoritesOnly: _favoritesOnly, sort: _sort),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(context.tr('apply')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
