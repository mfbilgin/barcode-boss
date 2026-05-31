import 'dart:async';

import 'save_service.dart';
import 'telemetry/telemetry_service.dart';

/// GDD §14 — Soft-lock önleme parametreleri (tek kaynak, Faz 5'te
/// Remote Config ile uzaktan ayarlanabilir hale gelecek — GDD §15.4).
abstract class Lifelines {
  /// §14.1 — tespit eşiği: bakiye 100 BC = 10.000 kuruş altı.
  static const int detectionCoinThresholdKurus = 10000;

  /// §14.2 — acil avans miktarı: 500 BC = 50.000 kuruş.
  static const int emergencyAdvanceKurus = 50000;

  /// §14.2 — lifetime'da maksimum tetik sayısı.
  static const int emergencyAdvanceMaxLifetime = 3;

  /// §14.2 — geri ödeme: sonraki 3 vardiyanın net gelirinden kesilir.
  static const int repaymentShifts = 3;

  /// §14.2 — kesinti oranı (net pozitif olmalı).
  static const double repaymentRate = 0.20;

  /// §14.2 — vardiya başına maksimum kesinti: 200 BC = 20.000 kuruş.
  static const int repaymentMaxPerShiftKurus = 20000;

  /// §14.3 — ilk N vardiya boyunca öğrenme yardımı verilir.
  static const int tutorialBonusShifts = 5;

  /// §14.3 — vardiya başına bonus: 50 BC = 5.000 kuruş.
  static const int tutorialBonusKurus = 5000;

  /// §14.4 — stok=0 durumunda verilen avans: 200 BC = 20.000 kuruş.
  static const int stockZeroAdvanceKurus = 20000;

  /// §14.4 — avansın verileceği bakiye eşiği (altında ise verilir).
  /// "B-Coin yeterli değilse" — bir başlangıç siparişi yapmaya yetecek miktar.
  static const int stockZeroAdvanceCoinThresholdKurus = 20000;

  /// §14.4 — lifetime'da maksimum stok-sıfır avansı sayısı (istismarı önler).
  static const int stockZeroAdvanceMaxLifetime = 3;
}

/// Bir vardiya sonu uygulanan §14 ayarlamalarının özeti.
class LifelineShiftResult {
  const LifelineShiftResult({
    required this.tutorialBonusKurus,
    required this.repaymentKurus,
    required this.emergencyAdvanceKurus,
  });

  const LifelineShiftResult.none()
    : tutorialBonusKurus = 0,
      repaymentKurus = 0,
      emergencyAdvanceKurus = 0;

  final int tutorialBonusKurus;
  final int repaymentKurus;
  final int emergencyAdvanceKurus;

  /// Vardiya sonu bakiyeye uygulanacak NET §14 deltası (rawNet ile toplanır).
  int get coinDeltaKurus =>
      tutorialBonusKurus - repaymentKurus + emergencyAdvanceKurus;
}

/// Vardiya başlamadan §14.4 kontrolünün sonucu.
class StockZeroLifelineResult {
  const StockZeroLifelineResult({
    required this.shouldBlockStart,
    required this.advanceKurus,
  });

  /// Stok yeterli; vardiya başlatılabilir.
  static const StockZeroLifelineResult allow = StockZeroLifelineResult(
    shouldBlockStart: false,
    advanceKurus: 0,
  );

  /// Vardiya başlamasın; oyuncu sipariş ekranına yönlendirilsin.
  final bool shouldBlockStart;

  /// §14.4 — verilmesi gereken otomatik avans (0 = yeterli bakiye veya
  /// lifetime sınırı aşıldı).
  final int advanceKurus;
}

/// GDD §14 yaşam-kurtarıcı (soft-lock önleme) mantığı. State'i `SaveService`
/// üzerinden okur ve mutasyon yapar; UI tarafı sadece sonuç nesnelerini kullanır.
class LifelineService {
  LifelineService(this._save);

  final SaveService _save;

  /// §14.3 + §14.2 — vardiya sonu işleme.
  ///
  /// Sırayla:
  /// 1. Tutorial bonusu (ilk 5 vardiya): +50 BC.
  /// 2. Geri ödeme (varsa): net'in %20'si, max 200 BC; counter azalır.
  /// 3. Lifeline tespit (§14.1): bakiye + net + bonus − repayment < 100 BC
  ///    VE inventory boş VE pending boş VE lifetime < 3 → +500 BC + 3 vardiya
  ///    geri ödeme counter set.
  LifelineShiftResult processShiftEnd({
    required int shiftNumber,
    required int netKurus,
    required int coinsBeforeKurus,
    required bool inventoryAllZero,
    required bool pendingOrdersEmpty,
  }) {
    // §14.3 — Tutorial bonusu
    final tutorialBonus = shiftNumber <= Lifelines.tutorialBonusShifts
        ? Lifelines.tutorialBonusKurus
        : 0;

    // §14.2 — Aktif geri ödeme
    var repayment = 0;
    if (_save.advanceRepayShiftsRemaining > 0 && netKurus > 0) {
      final raw = (netKurus * Lifelines.repaymentRate).round();
      repayment = raw > Lifelines.repaymentMaxPerShiftKurus
          ? Lifelines.repaymentMaxPerShiftKurus
          : raw;
      _save.advanceRepayShiftsRemaining =
          _save.advanceRepayShiftsRemaining - 1;
    }

    // §14.1 + §14.2 — Soft-lock tespit ve tetik
    var emergencyAdvance = 0;
    final coinsAfterRegular =
        coinsBeforeKurus + netKurus + tutorialBonus - repayment;
    if (coinsAfterRegular < Lifelines.detectionCoinThresholdKurus &&
        inventoryAllZero &&
        pendingOrdersEmpty &&
        _save.emergencyAdvanceCount < Lifelines.emergencyAdvanceMaxLifetime) {
      emergencyAdvance = Lifelines.emergencyAdvanceKurus;
      _save.emergencyAdvanceCount = _save.emergencyAdvanceCount + 1;
      _save.advanceRepayShiftsRemaining = Lifelines.repaymentShifts;
      unawaited(
        TelemetryService.instance.emergencyAdvanceTriggered(
          count: _save.emergencyAdvanceCount,
        ),
      );
    }

    return LifelineShiftResult(
      tutorialBonusKurus: tutorialBonus,
      repaymentKurus: repayment,
      emergencyAdvanceKurus: emergencyAdvance,
    );
  }

  /// §14.4 — vardiya başlamadan önce çağrılır. Tüm ürünler stok=0 ise
  /// vardiya engellenir; bakiye yetersizse otomatik 200 BC avans verilir
  /// (lifetime max 3). Avans verildiyse [SaveService.coinsKurus] güncellenir.
  StockZeroLifelineResult checkStockZero({
    required bool inventoryAllZero,
  }) {
    if (!inventoryAllZero) return StockZeroLifelineResult.allow;

    var advance = 0;
    if (_save.coinsKurus < Lifelines.stockZeroAdvanceCoinThresholdKurus &&
        _save.stockZeroAdvanceCount <
            Lifelines.stockZeroAdvanceMaxLifetime) {
      advance = Lifelines.stockZeroAdvanceKurus;
      _save.coinsKurus = _save.coinsKurus + advance;
      _save.stockZeroAdvanceCount = _save.stockZeroAdvanceCount + 1;
      unawaited(
        TelemetryService.instance.emergencyAdvanceTriggered(
          count: _save.stockZeroAdvanceCount,
        ),
      );
    }
    return StockZeroLifelineResult(
      shouldBlockStart: true,
      advanceKurus: advance,
    );
  }
}
