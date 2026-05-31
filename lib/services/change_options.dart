import 'dart:math';

/// Tek bir para üstü seçeneği — denomination'ların toplamı [totalKurus]
/// olarak verilir. Doğru/yanlış kontrolü `total == hedef change`.
class ChangeOption {
  const ChangeOption(this.denominationsKurus);

  /// Denominationların listesi (kuruş cinsinden), çoktan büyüğe sıralı.
  final List<int> denominationsKurus;

  int get totalKurus =>
      denominationsKurus.fold(0, (sum, d) => sum + d);
}

/// 3-option para üstü teklif paketi (GDD §3.4). Liste shuffled; [correctIndex]
/// doğru seçeneğin indexi.
class ChangeOptions {
  const ChangeOptions({required this.options, required this.correctIndex});
  final List<ChangeOption> options;
  final int correctIndex;
}

abstract class ChangeOptionsGenerator {
  /// TL modeli denominations kuruş cinsinden (GDD §3.7).
  static const List<int> denominationsDesc = [
    20000, 10000, 5000, 2000, 1000, 500, 200, 100, 50, 25, 10, 5,
  ];

  /// Greedy decomposition — TL modeli için minimum kupür sayısı verir.
  static List<int> greedy(int amountKurus) {
    if (amountKurus <= 0) return const [];
    final out = <int>[];
    var remaining = amountKurus;
    for (final d in denominationsDesc) {
      while (remaining >= d) {
        out.add(d);
        remaining -= d;
      }
      if (remaining == 0) break;
    }
    return out;
  }

  /// [changeKurus] hedef para üstü için 1 doğru + 2 yakın yanlış seçenek
  /// üretir. Yanlış seçeneklerin sapması rastgele aralıkta seçilir
  /// (tester'ın "hep aynı miktar" şikâyetini önler). [random] tohum kontrolü
  /// için (test).
  static ChangeOptions generate(int changeKurus, {Random? random}) {
    final rng = random ?? Random();
    final correct = ChangeOption(greedy(changeKurus));

    // Yanlış 1: doğrudan FAZLA. Aralık change boyutuna göre.
    // changeKurus < 500 (≤5 BC): +25..+150 kuruş (0.25..1.50 BC)
    // changeKurus < 2000: +50..+250
    // diğer: +100..+500
    final overMin = changeKurus < 500 ? 25 : (changeKurus < 2000 ? 50 : 100);
    final overMax = changeKurus < 500 ? 150 : (changeKurus < 2000 ? 250 : 500);
    final over = overMin + rng.nextInt(overMax - overMin + 1);

    // Yanlış 2: doğrudan EKSİK. Aralık benzer ama overlap olmasın diye
    // 'eksik' tarafından farklı seed.
    final underMin = changeKurus < 500 ? 25 : (changeKurus < 2000 ? 50 : 100);
    final underMax = changeKurus < 500 ? 150 : (changeKurus < 2000 ? 250 : 500);
    final under = underMin + rng.nextInt(underMax - underMin + 1);

    final wrong1 = ChangeOption(greedy(changeKurus + over));
    final wrong2 = ChangeOption(
      greedy((changeKurus - under).clamp(5, 1 << 30)),
    );

    final ordered = [correct, wrong1, wrong2];
    final indices = [0, 1, 2]..shuffle(rng);
    final shuffled = [for (final i in indices) ordered[i]];
    return ChangeOptions(
      options: shuffled,
      correctIndex: indices.indexOf(0),
    );
  }
}
