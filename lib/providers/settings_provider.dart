import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_keys.dart';
import '../theme.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = true;
  double _fontSize = 14.0;
  String _fontFamily = 'inter';
  int _fontWeight = 400;
  Color _primaryColor = AppColors.primary;
  late final Future<void> _initFuture;

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  int get fontWeight => _fontWeight;
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
    _fontFamily = prefs.getString(StorageKeys.fontFamily) ?? 'inter';
    const supportedFamilies = <String>{
      'inter',
      'nunito',
      'poppins',
      'playfair',
      'merriweather',
    };
    if (!supportedFamilies.contains(_fontFamily)) {
      _fontFamily = 'inter';
      await prefs.setString(StorageKeys.fontFamily, _fontFamily);
    }
    _fontWeight = prefs.getInt(StorageKeys.fontWeight) ?? 400;
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
    await prefs.setInt(StorageKeys.primaryColor, _primaryColor.toARGB32());
    notifyListeners();
  }

  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.fontFamily, _fontFamily);
    notifyListeners();
  }

  Future<void> setFontWeight(int weight) async {
    _fontWeight = weight;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.fontWeight, _fontWeight);
    notifyListeners();
  }
}
