import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  Set<int> _favoriteIds = {};

  Set<int> get favoriteIds => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('favorites') ?? [];
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
      'favorites',
      _favoriteIds.map((e) => e.toString()).toList(),
    );

    notifyListeners();
  }

  bool isFavorite(int hymnNumber) {
    return _favoriteIds.contains(hymnNumber);
  }
}
