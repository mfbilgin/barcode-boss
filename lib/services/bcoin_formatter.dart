import 'package:intl/intl.dart';

/// B-Coin para birimi formatlama yardımcısı.
///
/// Tüm B-Coin değerleri **integer kuruş** cinsinden tutulur
/// (1 B-Coin = 100 kuruş, örn: 4750 = 47,50 B-Coin). Bu, elastikiyet
/// hesabındaki floating-point yuvarlama hatalarını engeller (GDD §3.7, §9.5).
/// Görüntüleme katmanı değeri 100'e bölüp locale'e göre formatlar.
class BCoinFormatter {
  BCoinFormatter._();

  /// HUD/raporlarda sayının yanında gösterilen geçici sembol.
  /// Faz 3+'da custom "B" madeni para sprite'ı ile değiştirilir (GDD §3.7).
  static const String symbol = '🪙';

  /// ≥ 1.000.000 B-Coin → "M" kısaltması eşiği (kuruş cinsinden).
  static const int _millionThresholdKurus = 100000000; // 1M B-Coin
  /// ≥ 100.000 B-Coin → "K" kısaltması eşiği (kuruş cinsinden).
  static const int _thousandThresholdKurus = 10000000; // 100K B-Coin

  /// [kurus] integer kuruş değerini locale'e göre formatlar.
  ///
  /// TR locale örnekleri:
  /// * `5`        → `"0,05"`
  /// * `4750`     → `"47,50"`
  /// * `999999`   → `"9.999,99"`
  /// * `10000000` → `"100,0K"`   (≥100K B-Coin eşiği)
  /// * `100000000`→ `"1,0M"`     (≥1M B-Coin eşiği)
  ///
  /// EN locale'de ondalık/binlik ayraçlar yer değiştirir (`"47.50"`).
  static String format(int kurus, {String locale = 'tr_TR'}) {
    final value = kurus / 100.0;

    // Büyük rakamlar için kısaltma (yalnızca pozitif değerlerde).
    if (kurus >= _millionThresholdKurus) {
      return '${NumberFormat('#,##0.0', locale).format(value / 1000000)}M';
    }
    if (kurus >= _thousandThresholdKurus) {
      return '${NumberFormat('#,##0.0', locale).format(value / 1000)}K';
    }

    // Standart format: 2 ondalık, locale'e göre ayraçlar.
    return NumberFormat('#,##0.00', locale).format(value);
  }

  /// Sembol önde, sayı arkada: `"🪙 47,50"` (GDD §3.7 yazılı gösterim kuralı).
  static String withSymbol(int kurus, {String locale = 'tr_TR'}) {
    return '$symbol ${format(kurus, locale: locale)}';
  }

  /// Pozitif değerlere açık `+` işareti ekler (rapor "Net kâr: +🪙 149,50").
  static String signed(int kurus, {String locale = 'tr_TR'}) {
    final sign = kurus > 0 ? '+' : '';
    return '$sign${withSymbol(kurus, locale: locale)}';
  }
}
