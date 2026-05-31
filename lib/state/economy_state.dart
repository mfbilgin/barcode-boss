import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shift_record.dart';
import '../services/balance.dart';
import '../services/lifeline_service.dart';
import '../services/save_service.dart';
import '../services/telemetry/telemetry_service.dart';
import 'app_providers.dart';

/// Oyuncunun ekonomi/ilerleme anlık durumu (GDD §3.7, §3.8).
class EconomyState {
  const EconomyState({
    required this.coinsKurus,
    required this.totalXp,
    required this.shiftNumber,
  });

  final int coinsKurus;
  final int totalXp;
  final int shiftNumber;

  int get storeLevel => Balance.levelForXp(totalXp);

  /// Bir sonraki seviyeye kalan XP (max seviyede 0).
  int get xpToNextLevel {
    if (storeLevel >= Balance.maxLevel) return 0;
    return Balance.levelXpThresholds[storeLevel] - totalXp;
  }

  EconomyState copyWith({int? coinsKurus, int? totalXp, int? shiftNumber}) {
    return EconomyState(
      coinsKurus: coinsKurus ?? this.coinsKurus,
      totalXp: totalXp ?? this.totalXp,
      shiftNumber: shiftNumber ?? this.shiftNumber,
    );
  }
}

class EconomyNotifier extends StateNotifier<EconomyState> {
  EconomyNotifier(this._save, this._lifeline)
    : super(
        EconomyState(
          coinsKurus: _save.coinsKurus,
          totalXp: _save.totalXp,
          shiftNumber: _save.shiftNumber,
        ),
      );

  final SaveService _save;
  final LifelineService _lifeline;

  /// Doğrudan B-Coin düşümü (sipariş yerleştirme vb.). Negatif olamaz; yeterli
  /// bakiye yoksa `false` döner ve düşüm yapılmaz.
  bool deductCoins(int kurus) {
    if (kurus <= 0) return true;
    if (_save.coinsKurus < kurus) return false;
    final newCoins = _save.coinsKurus - kurus;
    _save.coinsKurus = newCoins;
    state = state.copyWith(coinsKurus: newCoins);
    return true;
  }

  /// §14.4 — stok=0 lifeline avansı tarafından veya başka harici eklemelerden
  /// sonra Hive zaten güncellendi; Riverpod state'ini Hive'la senkronize et.
  void syncFromSave() {
    state = state.copyWith(
      coinsKurus: _save.coinsKurus,
      totalXp: _save.totalXp,
      shiftNumber: _save.shiftNumber,
    );
  }

  /// Vardiya sonucunu uygula: net kâr bakiyeye, XP toplama, vardiya no +1.
  /// §14 ayarlamaları (tutorial bonus, geri ödeme, acil avans) da burada
  /// hesaplanır ve döndürülen [ShiftRecord]'a iliştirilir.
  ShiftRecord applyShift(
    ShiftRecord raw, {
    required bool inventoryAllZero,
    required bool pendingOrdersEmpty,
  }) {
    final oldLevel = Balance.levelForXp(_save.totalXp);

    final lifeline = _lifeline.processShiftEnd(
      shiftNumber: raw.shiftNumber,
      netKurus: raw.netKurus,
      coinsBeforeKurus: _save.coinsKurus,
      inventoryAllZero: inventoryAllZero,
      pendingOrdersEmpty: pendingOrdersEmpty,
    );

    final delta = raw.netKurus + lifeline.coinDeltaKurus;
    final newCoins = _save.coinsKurus + delta;
    final newXp = _save.totalXp + raw.xpEarned;
    final newShift = _save.shiftNumber + 1;
    final newLevel = Balance.levelForXp(newXp);

    _save
      ..coinsKurus = newCoins
      ..totalXp = newXp
      ..shiftNumber = newShift;

    state = state.copyWith(
      coinsKurus: newCoins,
      totalXp: newXp,
      shiftNumber: newShift,
    );

    if (newLevel > oldLevel) {
      unawaited(
        TelemetryService.instance.storeLevelUp(
          newLevel: newLevel,
          totalXp: newXp,
        ),
      );
    }

    return raw.copyWith(
      tutorialBonusKurus: lifeline.tutorialBonusKurus,
      repaymentKurus: lifeline.repaymentKurus,
      emergencyAdvanceKurus: lifeline.emergencyAdvanceKurus,
    );
  }

  Future<void> newGame() async {
    await _save.reset();
    state = const EconomyState(
      coinsKurus: Balance.startingCapitalKurus,
      totalXp: 0,
      shiftNumber: 1,
    );
  }
}

/// `LifelineService` provider — `EconomyNotifier` ve `PrepScreen` (§14.4)
/// bunu kullanır.
final lifelineServiceProvider = Provider<LifelineService>(
  (ref) => LifelineService(ref.watch(saveServiceProvider)),
);

final economyProvider = StateNotifierProvider<EconomyNotifier, EconomyState>(
  (ref) => EconomyNotifier(
    ref.watch(saveServiceProvider),
    ref.watch(lifelineServiceProvider),
  ),
);
