/// Tarama giriş stratejisi — swipe-through (varsayılan) + tap modu
/// (erişilebilirlik), GDD §3.3.
///
/// `scan_handler.dart` her iki modu da destekleyen soyutlamayla başlar; Faz 1
/// playtest sonucu mod kararı netleşene dek esneklik sağlar (GDD §3.3 mimari
/// not). Tap modu prod'da Ayarlar'dan açılır; slice'ta fare-tık doğrulamasını
/// kolaylaştırmak için varsayılan açık.
class ScanHandler {
  const ScanHandler({this.tapModeEnabled = true});

  /// Açıksa, ürüne tek tap taramayı tamamlar (swipe gerekmez).
  final bool tapModeEnabled;

  /// Geçerli sayılan minimum sola-doğru swipe mesafesi (px).
  static const double minSwipeDistancePx = 26;

  /// Swipe hız toleransı (GDD §3.3: 200–2000 px/sn; üst sınırı cömert tutuyoruz).
  static const double minSpeedPxPerSec = 200;
  static const double maxSpeedPxPerSec = 6000;

  /// [leftwardPx] swipe boyunca biriken sola-doğru yatay mesafe (pozitif = sola),
  /// [durationSec] swipe süresi. Yatay sağdan-sola swipe geçerli mi?
  bool isValidSwipe(double leftwardPx, double durationSec) {
    if (leftwardPx < minSwipeDistancePx) return false;
    if (durationSec <= 0) return true; // anlık güçlü flick
    final speed = leftwardPx / durationSec;
    return speed >= minSpeedPxPerSec && speed <= maxSpeedPxPerSec;
  }
}
