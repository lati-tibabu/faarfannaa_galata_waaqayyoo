import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/hymn_model.dart';
import '../services/song_service.dart';
import 'song_detail_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final songs = SongService().getSongsByCategory(category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: songs.isEmpty
          ? Center(
              child: Text(
                'No songs in this category',
                 style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                 ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return _HymnTile(hymn: song);
              },
            ),
    );
  }
}

class _HymnTile extends StatelessWidget {
  final Hymn hymn;

  const _HymnTile({required this.hymn});

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
          hymn.category,
           style: TextStyle(
             color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6), 
             fontSize: 12
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
