import 'package:flutter/material.dart';
import '../models/hymn_model.dart';

class PlayerProvider with ChangeNotifier {
  Hymn? _currentSong;
  bool _isPlaying = false;

  Hymn? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  void start(Hymn song) {
    _currentSong = song;
    _isPlaying = true;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_currentSong == null) return;
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void stop() {
    _currentSong = null;
    _isPlaying = false;
    notifyListeners();
  }
}
