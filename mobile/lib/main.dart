import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: const MyApp(),
    ),
  );
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

class _InitializerState extends State<Initializer> {
  double _progress = 0.0;
  bool _isLoading = true;
  SongLoadReport? _report;
  bool _showOnboarding = false;
  bool _showWhatsNew = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _start();
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
