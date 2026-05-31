import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../game/cashier_game.dart';
import '../game/input/scan_handler.dart';
import '../game/overlays/payment_overlay.dart';
import '../game/overlays/shift_hud.dart';
import '../models/shift_record.dart';
import '../services/balance.dart';
import '../state/app_providers.dart';
import '../state/economy_state.dart';
import '../state/inventory_state.dart';
import '../state/settings_state.dart';

/// Kasa Ekranı (GDD §6.3). Vardiya öncesi envanter teslim/raflama yapılır,
/// sonra Flame oyunu kurulur ve HUD/ödeme overlay'leriyle çalışır.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  CashierGame? _game;

  void _handleShiftComplete(ShiftRecord record) {
    // §14.1 — soft-lock tespit girdileri.
    final inv = ref.read(inventoryProvider);
    final allZero =
        inv.isEmpty || inv.values.every((it) => it.totalQty == 0);
    final pendingEmpty =
        ref.read(inventoryServiceProvider).pendingOrders().isEmpty;

    final enriched = ref.read(economyProvider.notifier).applyShift(
      record,
      inventoryAllZero: allZero,
      pendingOrdersEmpty: pendingEmpty,
    );
    ref.read(lastShiftProvider.notifier).state = enriched;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(Routes.summary);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Katalog yüklenemedi: $e')),
        data: (catalog) {
          if (_game == null) {
            // Seed + delivery PrepScreen'in "VARDİYAYI BAŞLAT" butonunda
            // yapılıyor (build sırasında provider mutasyonu yasak).
            final economy = ref.read(economyProvider);
            final settings = ref.read(settingsProvider);
            _game = CashierGame(
              catalog: catalog,
              inventorySnapshot: () => ref.read(inventoryProvider),
              onShelfDepletion: (id, qty) =>
                  ref.read(inventoryProvider.notifier).depleteShelf(id, qty),
              cardCapacityPercent: 5, // Faz 2 default; upgrade Faz 3+
              shiftNumber: economy.shiftNumber,
              storeLevel: economy.storeLevel,
              shiftDurationSec: Balance.shiftDurationSec(economy.storeLevel),
              onShiftComplete: _handleShiftComplete,
              scanHandler: ScanHandler(
                tapModeEnabled: settings.tapModeEnabled,
              ),
            );
          }
          return GameWidget<CashierGame>(
            game: _game!,
            overlayBuilderMap: {
              CashierGame.hudOverlay: (_, g) => ShiftHud(game: g),
              CashierGame.paymentOverlay: (_, g) => PaymentOverlay(game: g),
            },
            initialActiveOverlays: const [CashierGame.hudOverlay],
          );
        },
      ),
    );
  }
}
