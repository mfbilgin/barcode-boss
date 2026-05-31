/// GDD §23 balance parametreleri — tek kaynak. Faz 5 playtest sonrası
/// Remote Config (§15.4) ile uzaktan ince ayarlanabilir.
abstract class Balance {
  /// Başlangıç sermayesi: 1.000,00 B-Coin = 100.000 kuruş (GDD §3.7, §22).
  static const int startingCapitalKurus = 100000;

  /// Mağaza seviyesi XP eşikleri (toplam XP), index = level-1 (GDD §23.1).
  static const List<int> levelXpThresholds = [0, 100, 300, 800, 2000];

  static const int maxLevel = 5;

  /// Verilen toplam XP için mağaza seviyesi (1..5).
  static int levelForXp(int totalXp) {
    var level = 1;
    for (var i = 0; i < levelXpThresholds.length; i++) {
      if (totalXp >= levelXpThresholds[i]) level = i + 1;
    }
    return level;
  }

  /// Vardiya süresi (saniye). Playtest iterasyonu (Faz 5): tüm seviyelerde
  /// 2.5 dk = 150 sn — kısa loop, hızlı feedback.
  /// GDD §23.1 referans: lvl 1-2 = 5dk, 3-4 = 6dk, 5 = 7dk; playtest tuning
  /// sonrası geri ölçeklenecek.
  static int shiftDurationSec(int level) => 150;

  /// Maksimum sepet boyutu: `2 + min(level*2, 10)` (GDD §13.2, §23.1).
  static int maxBasket(int level) => 2 + (level * 2).clamp(0, 10);

  // --- Sabır (GDD §13.3) ---
  /// Saniyede 1 birim azalma; ödeme aşamasında ×1.2.
  static const double patienceDecayRate = 1.0;
  static double difficultyMultiplier(int level) => 1.0 + (level - 1) * 0.08;

  // --- XP kazanma kuralları (GDD §23.3) ---
  static const int xpCustomerNormal = 1;
  static const int xpCustomerAceleci = 2;
  static const int xpCorrectChange = 1;
  static const int xpComboChain = 2; // her 5 ardışık başarılı swipe
  static const int xpShiftComplete = 5;
  static const int xpHighSatisfaction = 10; // satisfaction > 0.8
  static const int xpPerfectShift = 15; // 0 kayıp müşteri

  // --- Combo (GDD §3.3) ---
  static const int comboThreshold = 5; // ardışık başarılı swipe
  static const double comboMaxGapSec = 1.5;
  static const double comboTipRate = 0.05; // +5% sabit bahşiş
}
