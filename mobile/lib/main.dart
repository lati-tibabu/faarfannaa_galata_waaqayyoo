import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'services/audio_handler.dart';
import 'theme.dart';
import 'services/song_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_layout.dart';
import 'providers/settings_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/history_provider.dart';
import 'providers/collections_provider.dart';
import 'providers/player_provider.dart';
import 'screens/load_error_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/whats_new_screen.dart';

late MyAudioHandler _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestAndroidNotificationPermission();

  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.lati.faarfannaa.channel.audio',
      androidNotificationChannelName: 'Hymn Playback',
      androidNotificationIcon: 'mipmap/launcher_icon',
      androidStopForegroundOnPause: false,
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => CollectionsProvider()),
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(audioHandler: _audioHandler),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _requestAndroidNotificationPermission() async {
  if (!Platform.isAndroid) return;

  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final primaryColor = settings.primaryColor;
        return MaterialApp(
          title: 'Faarfannaa Galata Waaqayyoo',
          debugShowCheckedModeBanner: false,
          locale: const Locale('en'),
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme(
            primaryColor,
            highContrast: settings.highContrastMode,
            reduceMotion: settings.reduceMotion,
            largeTouchTargets: settings.largeTouchTargets,
          ),
          darkTheme: AppTheme.darkTheme(
            primaryColor,
            highContrast: settings.highContrastMode,
            reduceMotion: settings.reduceMotion,
            largeTouchTargets: settings.largeTouchTargets,
          ),
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const Initializer(),
        );
      },
    );
  }
}

class Initializer extends StatefulWidget {
  const Initializer({super.key});

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> with WidgetsBindingObserver {
  double _progress = 0.0;
  bool _isLoading = true;
  SongLoadReport? _report;
  bool _showOnboarding = false;
  bool _showWhatsNew = false;
  String _appVersion = '';
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _syncInBackground();
    });
    _start();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncInBackground();
    }
  }

  Future<void> _syncInBackground() async {
    if (!_isLoading && _report?.isSuccessful == true) {
      await SongService().syncWithBackend();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _start({bool forceReload = false}) async {
    final startedAt = DateTime.now();
    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _report = null;
      _showOnboarding = false;
      _showWhatsNew = false;
      _appVersion = '';
    });

    final report = await SongService().loadSongs(
      forceReload: forceReload,
      onProgress: (p) {
        if (!mounted) return;
        setState(() => _progress = p);
      },
    );

    if (!mounted) return;

    setState(() {
      _report = report;
      _progress = 1.0;
    });

    const minSplashDuration = Duration(milliseconds: 1500);
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < minSplashDuration) {
      await Future.delayed(minSplashDuration - elapsed);
    }

    if (!mounted) return;

    if (!report.isSuccessful) {
      setState(() => _isLoading = false);
      return;
    }

    await SongService().syncWithBackend();
    if (!mounted) return;

    final onboarding = context.read<OnboardingProvider>();
    final settings = context.read<SettingsProvider>();
    await onboarding.waitForInit();
    await settings.waitForInit();
    if (!mounted) return;
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    final shouldShowWhatsNew =
        !onboarding.isFirstInstall &&
        settings.lastSeenWhatsNewVersion != currentVersion;

    setState(() {
      _showOnboarding = onboarding.shouldAutoShow;
      _showWhatsNew = shouldShowWhatsNew;
      _appVersion = currentVersion;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SplashScreen(progress: _progress);
    }

    final report = _report;
    if (report != null && !report.isSuccessful) {
      return LoadErrorScreen(
        report: report,
        onRetry: () => _start(forceReload: true),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(
        onFinish: () async {
          await context.read<OnboardingProvider>().setComplete(true);
          if (!mounted) return;
          setState(() => _showOnboarding = false);
        },
      );
    }

    if (_showWhatsNew) {
      return WhatsNewScreen(
        versionLabel: _appVersion,
        onClose: () async {
          await context.read<SettingsProvider>().setLastSeenWhatsNewVersion(
            _appVersion,
          );
          if (!mounted) return;
          setState(() => _showWhatsNew = false);
        },
      );
    }

    return const MainLayout();
  }
}
