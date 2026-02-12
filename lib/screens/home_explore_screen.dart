import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/hymn_model.dart';
import '../providers/favorites_provider.dart';
import '../services/song_service.dart';
import 'collections_screen.dart';
import 'now_playing_screen.dart';
import 'recently_viewed_screen.dart';
import 'song_detail_screen.dart';
import 'song_index_screen.dart';
import 'song_not_found_screen.dart';

class HomeExploreScreen extends StatefulWidget {
  const HomeExploreScreen({super.key});

  @override
  State<HomeExploreScreen> createState() => _HomeExploreScreenState();
}

class _HomeExploreScreenState extends State<HomeExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  List<Hymn> _allSongs = [];
  String _selectedCategory = 'All';
  bool _favoritesOnly = false;
  _SortOption _sort = _SortOption.number;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _searchController.addListener(() => setState(() {}));
    _numberController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _loadSongs() {
    setState(() {
      _allSongs = SongService().getAllSongs();
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

    final String query = _searchController.text.trim().toLowerCase();
    final String numberText = _numberController.text.trim();

    List<Hymn> songs = _allSongs;
    if (_selectedCategory != 'All') {
      songs = songs
          .where(
            (s) => s.category.toLowerCase() == _selectedCategory.toLowerCase(),
          )
          .toList();
    }
    if (_favoritesOnly) {
      songs = songs.where((s) => favorites.isFavorite(s.number)).toList();
    }

    if (numberText.isNotEmpty) {
      songs = songs
          .where((s) => s.number.toString().startsWith(numberText))
          .toList();
    } else if (query.isNotEmpty) {
      songs = songs
          .where((s) => s.title.toLowerCase().contains(query))
          .toList();
    }

    songs.sort((a, b) {
      switch (_sort) {
        case _SortOption.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case _SortOption.number:
          return a.number.compareTo(b.number);
      }
    });

    final categories = <String>['All', ...SongService().getUniqueCategories()];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor:
                Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              centerTitle: false,
              title: Text(
                'Faarfannaa',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _openFilters,
                icon: Icon(
                  Icons.tune,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              PopupMenuButton<String>(
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
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'index', child: Text('Song Index')),
                  PopupMenuItem(
                    value: 'recent',
                    child: Text('Recently Viewed'),
                  ),
                  PopupMenuItem(
                    value: 'collections',
                    child: Text('Collections'),
                  ),
                  PopupMenuItem(
                    value: 'now_playing',
                    child: Text('Now Playing'),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search hymns...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.black38,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.black45,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _numberController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          onSubmitted: (value) {
                            final parsed = int.tryParse(value.trim());
                            if (parsed == null) return;
                            final hymn = SongService().getSongByNumber(parsed);
                            if (hymn != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SongDetailScreen(song: hymn),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SongNotFoundScreen(number: parsed),
                                ),
                              );
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'No.',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.black38,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: 'Favorites',
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
                            label: c,
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
                    _favoritesOnly ? 'No favorites found' : 'No hymns found',
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
          const Text(
            'Browse options',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: _favoritesOnly,
            onChanged: (v) => setState(() => _favoritesOnly = v),
            title: const Text('Favorites only'),
            secondary: Icon(Icons.favorite, color: primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Sort by',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          RadioGroup<_SortOption>(
            groupValue: _sort,
            onChanged: (v) => setState(() => _sort = v ?? _SortOption.number),
            child: const Column(
              children: [
                RadioListTile<_SortOption>(
                  value: _SortOption.number,
                  title: Text('Number'),
                ),
                RadioListTile<_SortOption>(
                  value: _SortOption.title,
                  title: Text('Title'),
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
                  child: const Text('Cancel'),
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
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
