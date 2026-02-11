import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_collection.dart';
import '../services/storage_keys.dart';

class CollectionsProvider with ChangeNotifier {
  List<SongCollection> _collections = [];
  late final Future<void> _initFuture;

  List<SongCollection> get collections {
    final list = List<SongCollection>.from(_collections);
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(list);
  }

  CollectionsProvider() {
    _initFuture = _load();
  }

  Future<void> waitForInit() => _initFuture;
  Future<void> reload() => _load();

  SongCollection? getById(String id) {
    try {
      return _collections.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool containsSong({required String collectionId, required int hymnNumber}) {
    final collection = getById(collectionId);
    if (collection == null) return false;
    return collection.hymnNumbers.contains(hymnNumber);
  }

  Future<String?> createCollection(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    final next = List<SongCollection>.from(_collections)
      ..add(
        SongCollection(
          id: id,
          name: trimmed,
          hymnNumbers: {},
          createdAt: now,
          updatedAt: now,
        ),
      );
    _collections = next;
    await _persist();
    notifyListeners();
    return id;
  }

  Future<void> renameCollection(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    _collections = _collections
        .map((c) => c.id == id ? c.copyWith(name: trimmed, updatedAt: now) : c)
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> deleteCollection(String id) async {
    _collections = _collections.where((c) => c.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> toggleSong({
    required String collectionId,
    required int hymnNumber,
  }) async {
    final now = DateTime.now();
    _collections = _collections.map((c) {
      if (c.id != collectionId) return c;
      final nextNumbers = Set<int>.from(c.hymnNumbers);
      if (nextNumbers.contains(hymnNumber)) {
        nextNumbers.remove(hymnNumber);
      } else {
        nextNumbers.add(hymnNumber);
      }
      return c.copyWith(hymnNumbers: nextNumbers, updatedAt: now);
    }).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> removeSong({
    required String collectionId,
    required int hymnNumber,
  }) async {
    final now = DateTime.now();
    _collections = _collections.map((c) {
      if (c.id != collectionId) return c;
      final nextNumbers = Set<int>.from(c.hymnNumbers)..remove(hymnNumber);
      return c.copyWith(hymnNumbers: nextNumbers, updatedAt: now);
    }).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _collections = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.collectionsJson);
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.collectionsJson);
    if (raw == null || raw.trim().isEmpty) {
      _collections = [];
      notifyListeners();
      return;
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is! List) {
        _collections = [];
        notifyListeners();
        return;
      }
      _collections = decoded
          .whereType<Map<String, dynamic>>()
          .map(SongCollection.fromJson)
          .toList();
      notifyListeners();
    } catch (_) {
      _collections = [];
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = json.encode(_collections.map((c) => c.toJson()).toList());
    await prefs.setString(StorageKeys.collectionsJson, payload);
  }
}
