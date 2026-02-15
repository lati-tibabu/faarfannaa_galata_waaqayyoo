import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_keys.dart';

class HistoryProvider with ChangeNotifier {
  static const int maxItems = 30;

  List<int> _recentHymnNumbers = [];
  late final Future<void> _initFuture;

  List<int> get recentHymnNumbers => List.unmodifiable(_recentHymnNumbers);

  HistoryProvider() {
    _initFuture = _load();
  }

  Future<void> waitForInit() => _initFuture;
  Future<void> reload() => _load();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(StorageKeys.recentlyViewed) ?? [];
    _recentHymnNumbers = saved
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toList();
    notifyListeners();
  }

  Future<void> clear() async {
    _recentHymnNumbers = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.recentlyViewed);
    notifyListeners();
  }

  Future<void> recordViewed(int hymnNumber) async {
    final next = List<int>.from(_recentHymnNumbers);
    next.remove(hymnNumber);
    next.insert(0, hymnNumber);
    if (next.length > maxItems) {
      next.removeRange(maxItems, next.length);
    }

    _recentHymnNumbers = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      StorageKeys.recentlyViewed,
      _recentHymnNumbers.map((e) => e.toString()).toList(),
    );
    notifyListeners();
  }
}
