import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../services/song_service.dart';
import '../models/hymn_model.dart';
import '../theme.dart';
import 'song_detail_screen.dart';
import 'song_index_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _search = TextEditingController();
  bool _searchMode = false;
  _FavSort _sort = _FavSort.number;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final songService = SongService();
    // Get favorite songs, sort by number
    List<Hymn> favoriteSongs =
        favoritesProvider.favoriteIds
            .map((id) => songService.getSongByNumber(id))
            .whereType<Hymn>()
            .toList()
          ..sort((a, b) {
            switch (_sort) {
              case _FavSort.title:
                return a.title.toLowerCase().compareTo(b.title.toLowerCase());
              case _FavSort.number:
                return a.number.compareTo(b.number);
            }
          });

    final query = _search.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      favoriteSongs = favoriteSongs.where((song) {
        return song.title.toLowerCase().contains(query) ||
            song.number.toString().contains(query);
      }).toList();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: _searchMode
            ? TextField(
                controller: _search,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search favorites...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text(
                'Favorite Hymns',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        actions: [
          PopupMenuButton<_FavSort>(
            tooltip: 'Sort',
            icon: Icon(
              Icons.sort,
              color: isDark ? Colors.white : Colors.black54,
            ),
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _FavSort.number,
                child: Text('Sort by number'),
              ),
              PopupMenuItem(
                value: _FavSort.title,
                child: Text('Sort by title'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _searchMode ? Icons.close : Icons.search,
              color: isDark ? Colors.white : Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _searchMode = !_searchMode;
                if (!_searchMode) _search.clear();
              });
            },
          ),
        ],
      ),
      body: favoriteSongs.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.02)
                        : Colors.white,
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.secondary.withValues(alpha: 0.5)
                            : AppColors.backgroundLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          song.number.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Icon(
                      Icons.favorite,
                      color: primary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongDetailScreen(song: song),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.1),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor,
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    size: 50,
                    color: primary,
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle,
                    color: primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "No favorites yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Tap the heart icon on any hymn to add it to your personal collection.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SongIndexScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("Browse Hymns"),
          ),
        ],
      ),
    );
  }
}

enum _FavSort { number, title }
