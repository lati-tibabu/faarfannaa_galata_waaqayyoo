import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/hymn_model.dart';

enum SongLoadErrorType { missingAsset, invalidJson, unknown }

class SongLoadError {
  final int songNumber;
  final SongLoadErrorType type;
  final String message;

  const SongLoadError({
    required this.songNumber,
    required this.type,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'songNumber': songNumber,
    'type': type.name,
    'message': message,
  };
}

class SongLoadReport {
  final int totalExpected;
  final int loadedCount;
  final int missingCount;
  final int parseErrorCount;
  final int otherErrorCount;
  final DateTime finishedAt;
  final List<SongLoadError> errors;

  const SongLoadReport({
    required this.totalExpected,
    required this.loadedCount,
    required this.missingCount,
    required this.parseErrorCount,
    required this.otherErrorCount,
    required this.finishedAt,
    required this.errors,
  });

  bool get isSuccessful => loadedCount > 0;

  Map<String, dynamic> toJson() => {
    'totalExpected': totalExpected,
    'loadedCount': loadedCount,
    'missingCount': missingCount,
    'parseErrorCount': parseErrorCount,
    'otherErrorCount': otherErrorCount,
    'finishedAt': finishedAt.toIso8601String(),
    'errors': errors.map((e) => e.toJson()).toList(),
  };
}

class SongService {
  static final SongService _instance = SongService._internal();
  factory SongService() => _instance;
  SongService._internal();

  static const int totalExpectedSongs = 329;

  List<Hymn> _songs = [];
  bool _isLoaded = false;
  SongLoadReport? _lastLoadReport;

  bool get isLoaded => _isLoaded;
  SongLoadReport? get lastLoadReport => _lastLoadReport;

  Future<SongLoadReport> loadSongs({
    ValueChanged<double>? onProgress,
    bool forceReload = false,
  }) async {
    if (_isLoaded && !forceReload) {
      onProgress?.call(1.0);
      return _lastLoadReport ??
          SongLoadReport(
            totalExpected: totalExpectedSongs,
            loadedCount: _songs.length,
            missingCount: 0,
            parseErrorCount: 0,
            otherErrorCount: 0,
            finishedAt: DateTime.now(),
            errors: const [],
          );
    }

    try {
      final List<Hymn> loadedSongs = [];
      final List<SongLoadError> errors = [];
      int missingCount = 0;
      int parseErrorCount = 0;
      int otherErrorCount = 0;

      // Attempt to load songs 1 through totalExpectedSongs
      for (int i = 1; i <= totalExpectedSongs; i++) {
        try {
          final String response = await rootBundle.loadString(
            'assets/songs/$i.json',
          );
          try {
            final data = json.decode(response);
            loadedSongs.add(Hymn.fromJson(data));
          } catch (e) {
            parseErrorCount++;
            errors.add(
              SongLoadError(
                songNumber: i,
                type: SongLoadErrorType.invalidJson,
                message: e.toString(),
              ),
            );
          }

          onProgress?.call(i / totalExpectedSongs);
        } catch (e) {
          final String msg = e.toString();
          if (msg.contains('Unable to load asset')) {
            missingCount++;
            errors.add(
              SongLoadError(
                songNumber: i,
                type: SongLoadErrorType.missingAsset,
                message: msg,
              ),
            );
          } else {
            otherErrorCount++;
            errors.add(
              SongLoadError(
                songNumber: i,
                type: SongLoadErrorType.unknown,
                message: msg,
              ),
            );
          }
        }
      }

      _songs = loadedSongs;
      _songs.sort((a, b) => a.number.compareTo(b.number));
      _isLoaded = loadedSongs.isNotEmpty;
      _lastLoadReport = SongLoadReport(
        totalExpected: totalExpectedSongs,
        loadedCount: loadedSongs.length,
        missingCount: missingCount,
        parseErrorCount: parseErrorCount,
        otherErrorCount: otherErrorCount,
        finishedAt: DateTime.now(),
        errors: List.unmodifiable(errors),
      );

      return _lastLoadReport!;
    } catch (e) {
      debugPrint('Error loading songs: $e');
      final report = SongLoadReport(
        totalExpected: totalExpectedSongs,
        loadedCount: 0,
        missingCount: 0,
        parseErrorCount: 0,
        otherErrorCount: 1,
        finishedAt: DateTime.now(),
        errors: [
          SongLoadError(
            songNumber: 0,
            type: SongLoadErrorType.unknown,
            message: e.toString(),
          ),
        ],
      );
      _lastLoadReport = report;
      _isLoaded = false;
      _songs = [];
      return report;
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

  List<String> getUniqueCategories() {
    final categories = _songs.map((s) => s.category).toSet().toList();
    categories.sort();
    return categories;
  }

  List<Hymn> getSongsByCategory(String category) {
    return _songs
        .where((s) => s.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
