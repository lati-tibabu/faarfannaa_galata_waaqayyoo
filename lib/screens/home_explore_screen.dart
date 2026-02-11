import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/hymn_model.dart';
import '../services/song_service.dart';
import 'song_detail_screen.dart';

class HomeExploreScreen extends StatefulWidget {
  const HomeExploreScreen({super.key});

  @override
  State<HomeExploreScreen> createState() => _HomeExploreScreenState();
}

class _HomeExploreScreenState extends State<HomeExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  List<Hymn> _allSongs = [];
  List<Hymn> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _searchController.addListener(_onSearchChanged);
    _numberController.addListener(_onNumberChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _numberController.removeListener(_onNumberChanged);
    _searchController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _loadSongs() {
    setState(() {
      _allSongs = SongService().getAllSongs();
      _filteredSongs = _allSongs;
    });
  }

  void _onSearchChanged() {
    _filterSongs(_searchController.text);
  }

  void _onNumberChanged() {
    String numberText = _numberController.text;
    if (numberText.isNotEmpty) {
      // If searching by number, clear text search or handle priority
      // Here we filter by number startsWith
      setState(() {
        _filteredSongs = _allSongs.where((song) {
          return song.number.toString().startsWith(numberText);
        }).toList();
      });
    } else {
      // Fallback to text search if number is cleared
      _filterSongs(_searchController.text);
    }
  }

  void _filterSongs(String query) {
    if (_numberController.text.isNotEmpty) {
      return; // Priority to number search
    }

    if (query.isEmpty) {
      setState(() {
        _filteredSongs = _allSongs;
      });
    } else {
      setState(() {
        _filteredSongs = SongService().searchSongs(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Theme.of(
              context,
            ).scaffoldBackgroundColor.withOpacity(0.95),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              centerTitle: false,
              title: const Text(
                'Faarfannaa',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Sort logic or other actions
                },
                icon: Icon(
                  Icons.sort,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
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
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.black38,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.black45,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
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
                          decoration: InputDecoration(
                            hintText: 'No.',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.black38,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
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
                        _CategoryChip(label: 'All', isActive: true),
                        _CategoryChip(label: 'New Songs'),
                        _CategoryChip(label: 'Old Hymns'),
                        _CategoryChip(label: 'Children'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_filteredSongs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    'No songs found',
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
                  final song = _filteredSongs[index];
                  // Determine a subtitle (e.g., first line of first verse/chorus or author if available)
                  String subtitle = '';
                  if (song.sections.isNotEmpty &&
                      song.sections.first.lines.isNotEmpty) {
                    subtitle = song.sections.first.lines.first;
                  }

                  return _HymnTile(hymn: song, subtitle: subtitle);
                }, childCount: _filteredSongs.length),
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

  const _CategoryChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1)),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                ? AppColors.secondary.withOpacity(0.5)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Text(
              hymn.number.toString(),
              style: const TextStyle(
                color: AppColors.primary,
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
            ).textTheme.bodySmall?.color?.withOpacity(0.6),
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
