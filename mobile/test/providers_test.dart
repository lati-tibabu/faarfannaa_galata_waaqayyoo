import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:faarfannaa_galata_waaqayyoo/providers/collections_provider.dart';
import 'package:faarfannaa_galata_waaqayyoo/providers/history_provider.dart';
import 'package:faarfannaa_galata_waaqayyoo/providers/onboarding_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('OnboardingProvider persists completion', () async {
    final onboarding = OnboardingProvider();
    await onboarding.waitForInit();
    expect(onboarding.isComplete, isFalse);

    await onboarding.setComplete(true);
    expect(onboarding.isComplete, isTrue);

    final onboarding2 = OnboardingProvider();
    await onboarding2.waitForInit();
    expect(onboarding2.isComplete, isTrue);
  });

  test('HistoryProvider records most recent first', () async {
    final history = HistoryProvider();
    await history.waitForInit();

    await history.recordViewed(10);
    await history.recordViewed(2);
    await history.recordViewed(10);

    expect(history.recentHymnNumbers.first, 10);
    expect(history.recentHymnNumbers[1], 2);
  });

  test('CollectionsProvider create/toggle/delete', () async {
    final collections = CollectionsProvider();
    await collections.waitForInit();

    final id = await collections.createCollection('Sunday Service');
    expect(id, isNotNull);
    expect(collections.collections.length, 1);

    await collections.toggleSong(collectionId: id!, hymnNumber: 5);
    expect(collections.containsSong(collectionId: id, hymnNumber: 5), isTrue);

    await collections.renameCollection(id, 'Youth Service');
    expect(collections.getById(id)?.name, 'Youth Service');

    await collections.deleteCollection(id);
    expect(collections.collections, isEmpty);
  });
}
