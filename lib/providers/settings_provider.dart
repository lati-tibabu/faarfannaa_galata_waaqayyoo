import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_keys.dart';
import '../theme.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = true;
  double _fontSize = 14.0;
  Color _primaryColor = AppColors.primary;
  late final Future<void> _initFuture;

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  Color get primaryColor => _primaryColor;

  SettingsProvider() {
    _initFuture = _loadSettings();
  }

  Future<void> waitForInit() => _initFuture;
  Future<void> reload() => _loadSettings();

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(StorageKeys.isDarkMode) ?? true;
    _fontSize = prefs.getDouble(StorageKeys.fontSize) ?? 14.0;
    final storedPrimary = prefs.getInt(StorageKeys.primaryColor);
    _primaryColor = storedPrimary == null
        ? AppColors.primary
        : Color(storedPrimary).withValues(alpha: 1);
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isDarkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(StorageKeys.fontSize, _fontSize);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color.withValues(alpha: 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.primaryColor, _primaryColor.value);
    notifyListeners();
  }
}
