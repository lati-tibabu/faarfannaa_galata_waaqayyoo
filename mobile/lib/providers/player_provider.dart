import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/hymn_model.dart';
import '../services/song_service.dart';
import '../services/audio_handler.dart';

class PlayerProvider with ChangeNotifier {
  Hymn? _currentSong;
  final MyAudioHandler audioHandler;
  final SongService _songService = SongService();
  bool _isPlaying = false;
  bool _isPreparing = false;
  String? _error;

  Hymn? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isPreparing => _isPreparing;
  String? get error => _error;

  PlayerProvider({required this.audioHandler}) {
    audioHandler.playbackState.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }

  Future<void> start(Hymn song) async {
    _currentSong = song;
    _isPreparing = true;
    _error = null;
    notifyListeners();

    try {
      final localPath = await _songService.getLocalMusicPath(song.number);
      if (localPath == null) {
        _isPlaying = false;
        _isPreparing = false;
        _error = 'Music is not downloaded for this song.';
        notifyListeners();
        return;
      }

      final localFile = File(localPath);
      if (!await localFile.exists() || await localFile.length() == 0) {
        _isPlaying = false;
        _isPreparing = false;
        _error =
            'Downloaded music file is missing or empty. Please re-download.';
        notifyListeners();
        return;
      }

      final mediaItem = MediaItem(
        id: localPath,
        album: 'Faarfannaa Galata Waaqayyoo',
        title: song.title,
        artist: 'Hymn ${song.number}',
        duration: null, // Update if duration is known
        extras: {'number': song.number},
      );

      await audioHandler.playFromFile(localPath, mediaItem);

      _isPreparing = false;
      _isPlaying = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Audio playback failed for song ${song.number}: $e');
      _isPlaying = false;
      _isPreparing = false;
      _error = 'Unable to play this music file. Please re-download.';
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) return;

    try {
      _error = null;
      if (_isPlaying) {
        await audioHandler.pause();
      } else {
        await audioHandler.play();
      }
    } catch (_) {
      _error = 'Unable to update playback state.';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await audioHandler.stop();
    _currentSong = null;
    _isPlaying = false;
    _isPreparing = false;
    _error = null;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await audioHandler.seek(position);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
