import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/hymn_model.dart';
import '../services/song_service.dart';

class PlayerProvider with ChangeNotifier {
  Hymn? _currentSong;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SongService _songService = SongService();
  bool _isPlaying = false;
  bool _isPreparing = false;
  String? _error;

  Hymn? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isPreparing => _isPreparing;
  String? get error => _error;

  PlayerProvider() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
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

      await _audioPlayer.play(DeviceFileSource(localPath));

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
        await _audioPlayer.pause();
        _isPlaying = false;
      } else {
        await _audioPlayer.resume();
        _isPlaying = true;
      }
      notifyListeners();
    } catch (_) {
      _error = 'Unable to update playback state.';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSong = null;
    _isPlaying = false;
    _isPreparing = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
