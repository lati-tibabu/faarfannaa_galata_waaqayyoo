import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/collections_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/settings_provider.dart';
import '../services/storage_keys.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  String _exportJson = '';
  final TextEditingController _import = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshExport();
  }

  @override
  void dispose() {
    _import.dispose();
    super.dispose();
  }

  Future<void> _refreshExport() async {
    final prefs = await SharedPreferences.getInstance();

    dynamic collections;
    final rawCollections = prefs.getString(StorageKeys.collectionsJson);
    if (rawCollections != null && rawCollections.trim().isNotEmpty) {
      try {
        collections = json.decode(rawCollections);
      } catch (_) {
        collections = rawCollections;
      }
    }

    final payload = {
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'favorites': prefs.getStringList(StorageKeys.favorites) ?? const [],
      'settings': {
        StorageKeys.isDarkMode: prefs.getBool(StorageKeys.isDarkMode),
        StorageKeys.fontSize: prefs.getDouble(StorageKeys.fontSize),
        StorageKeys.fontFamily: prefs.getString(StorageKeys.fontFamily),
        StorageKeys.fontWeight: prefs.getInt(StorageKeys.fontWeight),
        StorageKeys.primaryColor: prefs.getInt(StorageKeys.primaryColor),
        StorageKeys.languageCode: prefs.getString(StorageKeys.languageCode),
        StorageKeys.highContrastMode: prefs.getBool(
          StorageKeys.highContrastMode,
        ),
        StorageKeys.reduceMotion: prefs.getBool(StorageKeys.reduceMotion),
        StorageKeys.largeTouchTargets: prefs.getBool(
          StorageKeys.largeTouchTargets,
        ),
        StorageKeys.lastSeenWhatsNewVersion: prefs.getString(
          StorageKeys.lastSeenWhatsNewVersion,
        ),
      },
      StorageKeys.onboardingComplete:
          prefs.getBool(StorageKeys.onboardingComplete) ?? false,
      StorageKeys.recentlyViewed:
          prefs.getStringList(StorageKeys.recentlyViewed) ?? const [],
      'collections': collections ?? const [],
    };

    setState(() {
      _exportJson = const JsonEncoder.withIndent('  ').convert(payload);
    });
  }

  Future<void> _importData() async {
    final raw = _import.text.trim();
    if (raw.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    try {
      final decoded = json.decode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid JSON structure');
      }

      final favorites = decoded['favorites'];
      if (favorites is List) {
        await prefs.setStringList(
          StorageKeys.favorites,
          favorites.map((e) => e.toString()).toList(),
        );
      }

      final settings = decoded['settings'];
      if (settings is Map) {
        final isDark = settings[StorageKeys.isDarkMode];
        final fontSize = settings[StorageKeys.fontSize];
        final fontFamily = settings[StorageKeys.fontFamily];
        final fontWeight = settings[StorageKeys.fontWeight];
        final primaryColor = settings[StorageKeys.primaryColor];
        final languageCode = settings[StorageKeys.languageCode];
        final highContrastMode = settings[StorageKeys.highContrastMode];
        final reduceMotion = settings[StorageKeys.reduceMotion];
        final largeTouchTargets = settings[StorageKeys.largeTouchTargets];
        final lastSeenWhatsNewVersion =
            settings[StorageKeys.lastSeenWhatsNewVersion];
        if (isDark is bool) {
          await prefs.setBool(StorageKeys.isDarkMode, isDark);
        }
        if (fontSize is num) {
          await prefs.setDouble(StorageKeys.fontSize, fontSize.toDouble());
        }
        if (fontFamily is String) {
          await prefs.setString(StorageKeys.fontFamily, fontFamily);
        }
        if (fontWeight is int) {
          await prefs.setInt(StorageKeys.fontWeight, fontWeight);
        }
        if (primaryColor is int) {
          await prefs.setInt(StorageKeys.primaryColor, primaryColor);
        }
        if (languageCode is String) {
          await prefs.setString(StorageKeys.languageCode, languageCode);
        }
        if (highContrastMode is bool) {
          await prefs.setBool(StorageKeys.highContrastMode, highContrastMode);
        }
        if (reduceMotion is bool) {
          await prefs.setBool(StorageKeys.reduceMotion, reduceMotion);
        }
        if (largeTouchTargets is bool) {
          await prefs.setBool(StorageKeys.largeTouchTargets, largeTouchTargets);
        }
        if (lastSeenWhatsNewVersion is String) {
          await prefs.setString(
            StorageKeys.lastSeenWhatsNewVersion,
            lastSeenWhatsNewVersion,
          );
        }
      }

      final onboarding = decoded[StorageKeys.onboardingComplete];
      if (onboarding is bool) {
        await prefs.setBool(StorageKeys.onboardingComplete, onboarding);
      }

      final recent = decoded[StorageKeys.recentlyViewed];
      if (recent is List) {
        await prefs.setStringList(
          StorageKeys.recentlyViewed,
          recent.map((e) => e.toString()).toList(),
        );
      }

      final collections = decoded['collections'];
      if (collections is List) {
        await prefs.setString(
          StorageKeys.collectionsJson,
          json.encode(collections),
        );
      }

      if (!mounted) return;
      await Future.wait([
        context.read<FavoritesProvider>().reload(),
        context.read<SettingsProvider>().reload(),
        context.read<OnboardingProvider>().reload(),
        context.read<HistoryProvider>().reload(),
        context.read<CollectionsProvider>().reload(),
      ]);

      await _refreshExport();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Import complete')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Backup & Restore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshExport,
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : Colors.black54,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Backup', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: SelectableText(
              _exportJson,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _exportJson));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup copied')),
                      );
                    }
                  },
                  child: Text('Copy'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _import,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Paste backup JSON here...',
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.withValues(alpha: 0.12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _importData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text('Import'),
          ),
          const SizedBox(height: 8),
          Text(
            'Import overwrites favorites, settings, recent history, and collections.',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
