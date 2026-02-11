import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hymn_model.dart';
import '../providers/collections_provider.dart';
import '../services/song_service.dart';
import '../theme.dart';
import 'song_detail_screen.dart';

class CollectionDetailScreen extends StatefulWidget {
  final String collectionId;

  const CollectionDetailScreen({super.key, required this.collectionId});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(
      () => setState(() => _query = _search.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _promptRename(BuildContext context, String currentName) async {
    final collectionsProvider = context.read<CollectionsProvider>();
    final controller = TextEditingController(text: currentName);
    final renamed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename collection'),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (renamed == true) {
      await collectionsProvider.renameCollection(
        widget.collectionId,
        controller.text,
      );
    }
  }

  Future<void> _promptDelete(BuildContext context) async {
    final collectionsProvider = context.read<CollectionsProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete collection?'),
        content: const Text(
          'This removes the collection but does not delete any hymns.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      if (!context.mounted) return;
      await collectionsProvider.deleteCollection(widget.collectionId);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CollectionsProvider>(
      builder: (context, collectionsProvider, _) {
        final collection = collectionsProvider.getById(widget.collectionId);
        if (collection == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Collection')),
            body: Center(
              child: Text(
                'Collection not found',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
          );
        }

        final List<Hymn> songs =
            collection.hymnNumbers
                .map((n) => SongService().getSongByNumber(n))
                .whereType<Hymn>()
                .where((h) {
                  if (_query.isEmpty) return true;
                  return h.number.toString().contains(_query) ||
                      h.title.toLowerCase().contains(_query);
                })
                .toList()
              ..sort((a, b) => a.number.compareTo(b.number));

        return Scaffold(
          appBar: AppBar(
            title: Text(
              collection.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Rename',
                onPressed: () => _promptRename(context, collection.name),
                icon: Icon(
                  Icons.edit_outlined,
                  color: isDark ? Colors.white : Colors.black54,
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _promptDelete(context),
                icon: Icon(
                  Icons.delete_outline,
                  color: isDark ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Search in collection...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.withValues(alpha: 0.12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: songs.isEmpty
                    ? Center(
                        child: Text(
                          'No hymns in this collection',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: isDark ? 0.18 : 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    song.number.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                song.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                tooltip: 'Remove',
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () async {
                                  await context
                                      .read<CollectionsProvider>()
                                      .removeSong(
                                        collectionId: widget.collectionId,
                                        hymnNumber: song.number,
                                      );
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SongDetailScreen(song: song),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
