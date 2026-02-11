import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hymn_model.dart';

class SongService {
  static final SongService _instance = SongService._internal();
  factory SongService() => _instance;
  SongService._internal();

  List<Hymn> _songs = [];
  bool _isLoaded = false;

  Future<void> loadSongs({Function(double)? onProgress}) async {
    if (_isLoaded) {
      if (onProgress != null) onProgress(1.0);
      return;
    }

    try {
      final List<Hymn> loadedSongs = [];
      const int totalFiles = 329;

      // Attempt to load songs 1 through 329
      for (int i = 1; i <= totalFiles; i++) {
        try {
          final String response = await rootBundle.loadString(
            'assets/songs/$i.json',
          );
          final data = json.decode(response);
          loadedSongs.add(Hymn.fromJson(data));

          if (onProgress != null) {
            onProgress(i / totalFiles);
          }
        } catch (e) {
          // Skip if file doesn't exist or error parsing details
          // print('Error loading song $i: $e');
        }
      }

      _songs = loadedSongs;
      _songs.sort((a, b) => a.number.compareTo(b.number));
      _isLoaded = true;
    } catch (e) {
      print('Error loading songs: $e');
    }
  }

  List<Hymn> getAllSongs() => _songs;

  Hymn? getSongByNumber(int number) {
    try {
      return _songs.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  List<Hymn> searchSongs(String query) {
    if (query.isEmpty) return _songs;
    final lowerQuery = query.toLowerCase();
    return _songs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.number.toString().contains(lowerQuery);
    }).toList();
  }
}
