import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_keys.dart';

class FavoritesProvider with ChangeNotifier {
  Set<int> _favoriteIds = {};
  late final Future<void> _initFuture;

  Set<int> get favoriteIds => _favoriteIds;

  FavoritesProvider() {
    _initFuture = _loadFavorites();
  }

  Future<void> waitForInit() => _initFuture;
  Future<void> reload() => _loadFavorites();

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(StorageKeys.favorites) ?? [];
    _favoriteIds = saved.map((e) => int.parse(e)).toSet();
    notifyListeners();
  }

  Future<void> toggleFavorite(int hymnNumber) async {
    if (_favoriteIds.contains(hymnNumber)) {
      _favoriteIds.remove(hymnNumber);
    } else {
      _favoriteIds.add(hymnNumber);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      StorageKeys.favorites,
      _favoriteIds.map((e) => e.toString()).toList(),
    );

    notifyListeners();
  }

  bool isFavorite(int hymnNumber) {
    return _favoriteIds.contains(hymnNumber);
  }
}
