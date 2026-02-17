import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:faarfannaa_galata_waaqayyoo/providers/collections_provider.dart';
import 'package:faarfannaa_galata_waaqayyoo/providers/favorites_provider.dart';
import 'package:faarfannaa_galata_waaqayyoo/providers/history_provider.dart';
import 'package:faarfannaa_galata_waaqayyoo/providers/onboarding_provider.dart';
import 'package:faarfannaa_galata_waaqayyoo/providers/player_provider.dart';
import 'package:faarfannaa_galata_waaqayyoo/providers/settings_provider.dart';
import 'package:faarfannaa_galata_waaqayyoo/services/audio_handler.dart';
import 'package:faarfannaa_galata_waaqayyoo/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Settings has key sections', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ChangeNotifierProvider(create: (_) => CollectionsProvider()),
          ChangeNotifierProvider(
            create: (_) => PlayerProvider(audioHandler: MyAudioHandler()),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Recently Viewed'), findsOneWidget);
    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('Backup & Restore'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Help & Feedback'), 200);
    expect(find.text('Help & Feedback'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200);
    expect(find.text('Privacy Policy'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Terms'), 200);
    expect(find.text('Terms'), findsOneWidget);
  });

  testWidgets('Can open Backup & Restore', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ChangeNotifierProvider(create: (_) => CollectionsProvider()),
          ChangeNotifierProvider(
            create: (_) => PlayerProvider(audioHandler: MyAudioHandler()),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Backup & Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Backup & Restore'), findsOneWidget);
    expect(find.text('Backup'), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);
  });
}
