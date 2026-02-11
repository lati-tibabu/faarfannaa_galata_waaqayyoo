import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_keys.dart';

class OnboardingProvider with ChangeNotifier {
  bool _isComplete = false;
  bool _isFirstInstall = true;
  late final Future<void> _initFuture;

  bool get isComplete => _isComplete;
  bool get isFirstInstall => _isFirstInstall;
  bool get shouldAutoShow => _isFirstInstall && !_isComplete;

  OnboardingProvider() {
    _initFuture = _load();
  }

  Future<void> waitForInit() => _initFuture;
  Future<void> reload() => _load();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstInstall = !prefs.containsKey(StorageKeys.onboardingComplete);
    _isComplete = prefs.getBool(StorageKeys.onboardingComplete) ?? false;
    notifyListeners();
  }

  Future<void> setComplete(bool value) async {
    _isComplete = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.onboardingComplete, _isComplete);
    _isFirstInstall = false;
    notifyListeners();
  }

  Future<void> reset() => setComplete(false);
}
