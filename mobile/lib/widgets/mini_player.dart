import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:typed_data';

import '../providers/player_provider.dart';
import '../screens/now_playing_screen.dart';
import '../services/song_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final song = playerProvider.currentSong;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (song == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
            );
          },
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    // Leading Icon/Artwork
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FutureBuilder<Uint8List?>(
                          future: SongService().getMusicArtwork(song.number),
                          builder: (context, snapshot) {
                            final bytes = snapshot.data;
                            if (bytes != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(bytes, fit: BoxFit.cover),
                              );
                            }

                            return Icon(
                              Icons.music_note,
                              color: Theme.of(context).colorScheme.primary,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Hymn ${song.number}',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Controls
                    IconButton(
                      icon: Icon(
                        playerProvider.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () => playerProvider.togglePlayPause(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_full, size: 20),
                      tooltip: 'View Full Player',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NowPlayingScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => playerProvider.stop(),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                // Tiny Progress bar at bottom of the container
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 0,
                  child: StreamBuilder<PlaybackState>(
                    stream: playerProvider.audioHandler.playbackState,
                    builder: (context, snapshot) {
                      final position = snapshot.data?.position ?? Duration.zero;
                      final duration =
                          playerProvider
                              .audioHandler
                              .mediaItem
                              .value
                              ?.duration ??
                          Duration.zero;
                      if (duration == Duration.zero) {
                        return const SizedBox.shrink();
                      }

                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (position.inMilliseconds / duration.inMilliseconds)
                                .clamp(0.0, 1.0),
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
