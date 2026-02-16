import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/hymn_model.dart';
import 'storage_keys.dart';

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

class SongSyncReport {
  final bool success;
  final int updatesApplied;
  final int deletionsApplied;
  final DateTime finishedAt;
  final String? error;

  const SongSyncReport({
    required this.success,
    required this.updatesApplied,
    required this.deletionsApplied,
    required this.finishedAt,
    this.error,
  });

  bool get hasChanges => updatesApplied > 0 || deletionsApplied > 0;
}

class SongService {
  static final SongService _instance = SongService._internal();
  factory SongService() => _instance;
  SongService._internal();

  static const int totalExpectedSongs = 329;
  static const String _apiBaseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  List<Hymn> _songs = [];
  bool _isLoaded = false;
  bool _isSyncing = false;
  SongLoadReport? _lastLoadReport;
  SongSyncReport? _lastSyncReport;
  DateTime? _lastSyncedAt;
  Set<int> _downloadedMusicSongIds = <int>{};

  final Set<VoidCallback> _catalogListeners = <VoidCallback>{};

  bool get isLoaded => _isLoaded;
  bool get isSyncing => _isSyncing;
  SongLoadReport? get lastLoadReport => _lastLoadReport;
  SongSyncReport? get lastSyncReport => _lastSyncReport;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  Set<int> get downloadedMusicSongIds => Set<int>.from(_downloadedMusicSongIds);

  void addCatalogListener(VoidCallback listener) {
    _catalogListeners.add(listener);
  }

  void removeCatalogListener(VoidCallback listener) {
    _catalogListeners.remove(listener);
  }

  void _notifyCatalogListeners() {
    for (final listener in List<VoidCallback>.from(_catalogListeners)) {
      listener();
    }
  }

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
      final List<Hymn> bundledSongs = [];
      final List<SongLoadError> errors = [];
      int missingCount = 0;
      int parseErrorCount = 0;
      int otherErrorCount = 0;

      for (int i = 1; i <= totalExpectedSongs; i++) {
        try {
          final String response = await rootBundle.loadString(
            'assets/songs/$i.json',
          );
          try {
            final data = json.decode(response);
            if (data is Map<String, dynamic>) {
              bundledSongs.add(Hymn.fromJson(data));
            } else {
              parseErrorCount++;
              errors.add(
                SongLoadError(
                  songNumber: i,
                  type: SongLoadErrorType.invalidJson,
                  message: 'Unexpected song JSON structure',
                ),
              );
            }
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

      _songs = await _mergeBundledWithCachedRemote(bundledSongs);
      _songs.sort((a, b) => a.number.compareTo(b.number));
      _isLoaded = _songs.isNotEmpty;
      _lastLoadReport = SongLoadReport(
        totalExpected: totalExpectedSongs,
        loadedCount: _songs.length,
        missingCount: missingCount,
        parseErrorCount: parseErrorCount,
        otherErrorCount: otherErrorCount,
        finishedAt: DateTime.now(),
        errors: List.unmodifiable(errors),
      );

      _notifyCatalogListeners();
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

  Future<SongSyncReport> syncWithBackend({bool forceFullSync = false}) async {
    if (_isSyncing) {
      return SongSyncReport(
        success: false,
        updatesApplied: 0,
        deletionsApplied: 0,
        finishedAt: DateTime.now(),
        error: 'Sync already in progress',
      );
    }

    _isSyncing = true;
    final baseUrl = _resolveApiBaseUrl();
    try {
      if (!_isLoaded) {
        await loadSongs();
      }

      final query = <String, String>{};
      if (!forceFullSync && _lastSyncedAt != null) {
        query['since'] = _lastSyncedAt!.toUtc().toIso8601String();
      }

      final uri = Uri.parse(
        '$baseUrl/songs/sync',
      ).replace(queryParameters: query.isEmpty ? null : query);

      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception(
          'Sync failed with status ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected sync response format');
      }

      final updatesRaw = decoded['updates'] as List<dynamic>? ?? const [];
      final deletionsRaw = decoded['deletions'] as List<dynamic>? ?? const [];
      final serverTime = DateTime.tryParse(
        decoded['serverTime']?.toString() ?? '',
      );

      final songMap = <int, Hymn>{for (final song in _songs) song.number: song};
      final deletedIds = await _readDeletedSongIds();

      int updatesApplied = 0;
      for (final raw in updatesRaw) {
        if (raw is! Map) continue;
        try {
          final hymn = Hymn.fromJson(Map<String, dynamic>.from(raw));
          if (hymn.number <= 0) continue;
          songMap[hymn.number] = hymn;
          deletedIds.remove(hymn.number);
          updatesApplied++;
        } catch (_) {
          continue;
        }
      }

      int deletionsApplied = 0;
      for (final raw in deletionsRaw) {
        if (raw is! Map) continue;
        final songIdRaw = raw['songId'];
        final songId = songIdRaw is int
            ? songIdRaw
            : int.tryParse(songIdRaw?.toString() ?? '');
        if (songId == null || songId <= 0) continue;

        if (songMap.remove(songId) != null) {
          deletionsApplied++;
        }
        deletedIds.add(songId);
      }

      final merged = songMap.values.toList()
        ..sort((a, b) => a.number.compareTo(b.number));

      _songs = merged;
      _isLoaded = _songs.isNotEmpty;
      _lastSyncedAt = serverTime ?? DateTime.now().toUtc();
      _downloadedMusicSongIds = await _readDownloadedMusicSongIds();
      await _persistSyncState(
        songs: _songs,
        deletedSongIds: deletedIds,
        syncedAt: _lastSyncedAt!,
      );

      _lastSyncReport = SongSyncReport(
        success: true,
        updatesApplied: updatesApplied,
        deletionsApplied: deletionsApplied,
        finishedAt: DateTime.now(),
      );

      if (_lastSyncReport!.hasChanges) {
        _notifyCatalogListeners();
      }

      return _lastSyncReport!;
    } catch (e) {
      final rawError = e.toString();
      final friendlyError = _toFriendlySyncError(rawError, baseUrl);
      _lastSyncReport = SongSyncReport(
        success: false,
        updatesApplied: 0,
        deletionsApplied: 0,
        finishedAt: DateTime.now(),
        error: friendlyError,
      );
      if (kDebugMode) {
        debugPrint('Song sync error: $friendlyError');
      }
      return _lastSyncReport!;
    } finally {
      _isSyncing = false;
    }
  }

  String _resolveApiBaseUrl() {
    final fromEnv = _apiBaseUrlFromEnv.trim();
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // Android emulator cannot reach host machine via localhost.
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }

    return 'http://localhost:3000/api';
  }

  String _toFriendlySyncError(String error, String baseUrl) {
    if (error.contains('Connection refused')) {
      return 'Cannot reach backend at $baseUrl. Start backend server and set API_BASE_URL for your device network if needed.';
    }
    return error;
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

  Future<List<Hymn>> _mergeBundledWithCachedRemote(
    List<Hymn> bundledSongs,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final rawSyncedSongs = prefs.getString(StorageKeys.syncedSongsJson);
    final rawDeletedIds =
        prefs.getStringList(StorageKeys.syncedDeletedSongIds) ?? const [];

    final merged = <int, Hymn>{
      for (final song in bundledSongs) song.number: song,
    };

    if (rawSyncedSongs != null && rawSyncedSongs.trim().isNotEmpty) {
      try {
        final decoded = json.decode(rawSyncedSongs);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map) continue;
            final hymn = Hymn.fromJson(Map<String, dynamic>.from(item));
            if (hymn.number > 0) {
              merged[hymn.number] = hymn;
            }
          }
        }
      } catch (_) {
        // Ignore broken cache and continue with bundled songs.
      }
    }

    for (final rawId in rawDeletedIds) {
      final id = int.tryParse(rawId);
      if (id != null) {
        merged.remove(id);
      }
    }

    _lastSyncedAt = DateTime.tryParse(
      prefs.getString(StorageKeys.songsLastSyncAt) ?? '',
    );
    _downloadedMusicSongIds = await _readDownloadedMusicSongIds();

    final list = merged.values.toList();
    list.sort((a, b) => a.number.compareTo(b.number));
    return list;
  }

  Future<Directory> _musicDirectory() async {
    final rootDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${rootDir.path}${Platform.pathSeparator}music');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<String?> getLocalMusicPath(int songNumber) async {
    final dir = await _musicDirectory();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) => path.basename(file.path).startsWith('$songNumber.'))
        .toList();
    if (files.isEmpty) {
      return null;
    }
    return files.first.path;
  }

  Future<bool> hasDownloadedMusic(int songNumber) async {
    if (_downloadedMusicSongIds.contains(songNumber)) {
      return true;
    }
    final local = await getLocalMusicPath(songNumber);
    final exists = local != null;
    if (exists) {
      _downloadedMusicSongIds.add(songNumber);
      await _persistDownloadedMusicSongIds(_downloadedMusicSongIds);
    }
    return exists;
  }

  Future<String> downloadSongMusic(Hymn song) async {
    final baseUrl = _resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/songs/${song.number}/music');
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Failed to download music: ${response.statusCode}');
    }

    final contentType = response.headers['content-type'] ?? 'audio/mpeg';
    final normalizedContentType = contentType.toLowerCase();
    if (!normalizedContentType.startsWith('audio/')) {
      throw Exception('Invalid music response content-type: $contentType');
    }
    if (response.bodyBytes.isEmpty) {
      throw Exception('Downloaded music file is empty.');
    }

    String extension = '.mp3';
    if (normalizedContentType.contains('wav')) {
      extension = '.wav';
    } else if (normalizedContentType.contains('ogg')) {
      extension = '.ogg';
    } else if (normalizedContentType.contains('aac')) {
      extension = '.aac';
    } else if (normalizedContentType.contains('m4a') ||
        normalizedContentType.contains('mp4')) {
      extension = '.m4a';
    }

    final dir = await _musicDirectory();
    final existingFiles = dir.listSync().whereType<File>().where(
      (file) => path.basename(file.path).startsWith('${song.number}.'),
    );
    for (final file in existingFiles) {
      try {
        file.deleteSync();
      } catch (_) {
        // Ignore cleanup failures.
      }
    }

    final targetPath =
        '${dir.path}${Platform.pathSeparator}${song.number}$extension';
    final targetFile = File(targetPath);
    await targetFile.writeAsBytes(response.bodyBytes, flush: true);

    _downloadedMusicSongIds.add(song.number);
    await _persistDownloadedMusicSongIds(_downloadedMusicSongIds);
    return targetPath;
  }

  Future<Set<int>> _readDeletedSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw =
        prefs.getStringList(StorageKeys.syncedDeletedSongIds) ?? const [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<Set<int>> _readDownloadedMusicSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw =
        prefs.getStringList(StorageKeys.downloadedMusicSongIds) ?? const [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> _persistDownloadedMusicSongIds(Set<int> songIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      StorageKeys.downloadedMusicSongIds,
      songIds.map((id) => id.toString()).toList()..sort(),
    );
  }

  Future<void> _persistSyncState({
    required List<Hymn> songs,
    required Set<int> deletedSongIds,
    required DateTime syncedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = json.encode(songs.map((song) => song.toJson()).toList());

    await prefs.setString(StorageKeys.syncedSongsJson, payload);
    await prefs.setStringList(
      StorageKeys.syncedDeletedSongIds,
      deletedSongIds.map((id) => id.toString()).toList()..sort(),
    );
    await prefs.setString(
      StorageKeys.songsLastSyncAt,
      syncedAt.toUtc().toIso8601String(),
    );
  }
}
