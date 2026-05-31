import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog.dart';
import '../models/shift_record.dart';
import '../services/catalog_loader.dart';
import '../services/inventory_service.dart';
import '../services/save_service.dart';
import '../services/settings_service.dart';
import '../services/tutorial_service.dart';

/// `main()` içinde açılan [SaveService] örneği `ProviderScope.overrides` ile
/// sağlanır (GDD §9.4).
final saveServiceProvider = Provider<SaveService>((ref) {
  throw UnimplementedError(
    'saveServiceProvider, ProviderScope override ile sağlanmalı',
  );
});

/// `main()` içinde açılan [InventoryService] örneği `ProviderScope.overrides`
/// ile sağlanır (Hive `inventory_v1` box).
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  throw UnimplementedError(
    'inventoryServiceProvider, ProviderScope override ile sağlanmalı',
  );
});

/// `main()` içinde açılan [SettingsService] örneği `ProviderScope.overrides`
/// ile sağlanır (Hive `settings_v1` box).
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError(
    'settingsServiceProvider, ProviderScope override ile sağlanmalı',
  );
});

/// `main()` içinde açılan [TutorialService] örneği `ProviderScope.overrides`
/// ile sağlanır (Hive `tutorial_v1` box).
final tutorialServiceProvider = Provider<TutorialService>((ref) {
  throw UnimplementedError(
    'tutorialServiceProvider, ProviderScope override ile sağlanmalı',
  );
});

/// Master ürün katalogu (`products.json`).
final catalogProvider = FutureProvider<Catalog>((ref) => CatalogLoader.load());

/// En son tamamlanan vardiyanın özeti — rapor ekranı bunu okur.
final lastShiftProvider = StateProvider<ShiftRecord?>((ref) => null);
