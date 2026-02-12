import 'package:flutter/material.dart';
import '../services/song_service.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _search.text.trim().toLowerCase();
    final categories = SongService()
        .getUniqueCategories()
        .where((c) => query.isEmpty || c.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Select a theme to browse hymns',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _search,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Search categories...',
                hintStyle: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black38,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black45,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Text(
                        "No categories found",
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _CategoryTile(
                          icon: _getIconForCategory(category),
                          title: category,
                          subtitle:
                              '${SongService().getSongsByCategory(category).length} Songs',
                          color: _getColorForCategory(category),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CategoryDetailScreen(category: category),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('worship') || lower.contains('waaqeffannaa')) {
      return Icons.church;
    }
    if (lower.contains('praise') || lower.contains('galata')) {
      return Icons.auto_awesome;
    }
    if (lower.contains('gospel') || lower.contains('wangeela')) {
      return Icons.menu_book;
    }
    if (lower.contains('salvation') || lower.contains('fayyina')) {
      return Icons.volunteer_activism;
    }
    if (lower.contains('history') || lower.contains('seenaa')) {
      return Icons.history_edu;
    }
    if (lower.contains('children')) return Icons.child_care;
    if (lower.contains('love')) return Icons.favorite;
    return Icons.music_note;
  }

  Color _getColorForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('worship')) return Colors.blue;
    if (lower.contains('praise')) return Theme.of(context).colorScheme.primary;
    if (lower.contains('gospel')) return Colors.purple;
    if (lower.contains('salvation')) return Colors.green;
    if (lower.contains('history')) return Colors.amber;
    return Colors.teal;
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty
                        ? title[0].toUpperCase() + title.substring(1)
                        : "General",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.black45,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black12,
            ),
          ],
        ),
      ),
    );
  }
}
