/// Bir vardiyanın sonuç özeti (GDD §6.4 rapor ekranı, §13.5 memnuniyet).
///
/// §14 lifeline alanları (`tutorialBonusKurus`, `repaymentKurus`,
/// `emergencyAdvanceKurus`) Faz 5'te eklenen soft-lock önleme sistemi tarafından
/// `EconomyNotifier.applyShift` içinde doldurulur. Gameplay tarafı (CashierGame)
/// bu alanları 0 bırakır.
class ShiftRecord {
  const ShiftRecord({
    required this.shiftNumber,
    required this.customersServed,
    required this.customersLost,
    required this.missedDemand,
    required this.wrongChange,
    required this.revenueKurus,
    required this.costKurus,
    required this.xpEarned,
    this.tutorialBonusKurus = 0,
    this.repaymentKurus = 0,
    this.emergencyAdvanceKurus = 0,
  });

  final int shiftNumber;
  final int customersServed;
  final int customersLost;
  final int missedDemand;
  final int wrongChange;
  final int revenueKurus;
  final int costKurus;
  final int xpEarned;

  /// §14.3 — ilk 5 vardiyada otomatik eklenen "Yeni başlayan bonusu" (kuruş).
  final int tutorialBonusKurus;

  /// §14.2 — aktif acil avans geri ödemesi: net'ten kesilen miktar (kuruş).
  final int repaymentKurus;

  /// §14.2 — bu vardiya sonu tetiklenen acil avans miktarı (kuruş, 0 = tetik yok).
  final int emergencyAdvanceKurus;

  /// Net kâr (kuruş) = ciro − maliyet. §14 ayarlamaları DAHİL değildir; rapor
  /// satırlarında ayrı gösterilir.
  int get netKurus => revenueKurus - costKurus;

  /// Vardiya sonu bakiyeye uygulanan TOPLAM delta (net + bonus − repayment + advance).
  int get coinDeltaKurus =>
      netKurus + tutorialBonusKurus - repaymentKurus + emergencyAdvanceKurus;

  int get totalCustomers => customersServed + customersLost;

  /// `satisfaction = (served − lost×2 − wrongChange) / total`, aralık [-1, 1]
  /// (GDD §13.5).
  double get satisfaction {
    if (totalCustomers == 0) return 0;
    final raw =
        (customersServed - customersLost * 2 - wrongChange) / totalCustomers;
    return raw.clamp(-1.0, 1.0);
  }

  /// Memnuniyet → 5 yıldız görselleştirmesi (GDD §6.4).
  int get stars => ((satisfaction + 1) / 2 * 4 + 1).round().clamp(1, 5);

  ShiftRecord copyWith({
    int? tutorialBonusKurus,
    int? repaymentKurus,
    int? emergencyAdvanceKurus,
  }) {
    return ShiftRecord(
      shiftNumber: shiftNumber,
      customersServed: customersServed,
      customersLost: customersLost,
      missedDemand: missedDemand,
      wrongChange: wrongChange,
      revenueKurus: revenueKurus,
      costKurus: costKurus,
      xpEarned: xpEarned,
      tutorialBonusKurus: tutorialBonusKurus ?? this.tutorialBonusKurus,
      repaymentKurus: repaymentKurus ?? this.repaymentKurus,
      emergencyAdvanceKurus:
          emergencyAdvanceKurus ?? this.emergencyAdvanceKurus,
    );
  }

  Map<String, dynamic> toJson() => {
    'shiftNumber': shiftNumber,
    'customersServed': customersServed,
    'customersLost': customersLost,
    'missedDemand': missedDemand,
    'wrongChange': wrongChange,
    'revenueKurus': revenueKurus,
    'costKurus': costKurus,
    'xpEarned': xpEarned,
    'tutorialBonusKurus': tutorialBonusKurus,
    'repaymentKurus': repaymentKurus,
    'emergencyAdvanceKurus': emergencyAdvanceKurus,
  };

  factory ShiftRecord.fromJson(Map json) => ShiftRecord(
    shiftNumber: json['shiftNumber'] as int,
    customersServed: json['customersServed'] as int,
    customersLost: json['customersLost'] as int,
    missedDemand: json['missedDemand'] as int,
    wrongChange: json['wrongChange'] as int,
    revenueKurus: json['revenueKurus'] as int,
    costKurus: json['costKurus'] as int,
    xpEarned: json['xpEarned'] as int,
    tutorialBonusKurus: (json['tutorialBonusKurus'] as int?) ?? 0,
    repaymentKurus: (json['repaymentKurus'] as int?) ?? 0,
    emergencyAdvanceKurus: (json['emergencyAdvanceKurus'] as int?) ?? 0,
  );
}
