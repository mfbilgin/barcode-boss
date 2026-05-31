import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'services/audio_service.dart';
import 'services/crash_handler.dart';
import 'services/inventory_service.dart';
import 'services/save_service.dart';
import 'services/settings_service.dart';
import 'services/telemetry/firebase_telemetry_backend.dart';
import 'services/telemetry/telemetry_service.dart';
import 'services/tutorial_service.dart';
import 'state/app_providers.dart';

Future<void> main() async {
  await runWithCrashGuard(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase init — google-services.json'dan options okunur (Android).
    // Hata olursa NoopBackend'de kalırız (oyun çökmez).
    try {
      await Firebase.initializeApp();
      TelemetryService.swap(FirebaseTelemetryBackend());
    } catch (e, st) {
      debugPrint('Firebase init failed, NoopBackend\'de kalıyor: $e\n$st');
    }

    // Lokal kayıt (GDD §9.4).
    await Hive.initFlutter();
    final saveService = await SaveService.open();
    final inventoryService = await InventoryService.open();
    final settingsService = await SettingsService.open();
    final tutorialService = await TutorialService.open();

    // SFX cache ön-yükleme (asset eksikse no-op + log, oyun çökmez).
    await AudioService.instance.preloadAll();

    await TelemetryService.instance.appOpened();

    runApp(
      ProviderScope(
        overrides: [
          saveServiceProvider.overrideWithValue(saveService),
          inventoryServiceProvider.overrideWithValue(inventoryService),
          settingsServiceProvider.overrideWithValue(settingsService),
          tutorialServiceProvider.overrideWithValue(tutorialService),
        ],
        child: const BarcodeBossApp(),
      ),
    );
  });
}
