import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Oyun boyu kullanılan SFX türleri (GDD §8.3).
enum SfxId {
  /// Barkod beep — başarılı tarama.
  beep('sfx/beep.wav', cooldownMs: 70, gain: 0.9),

  /// Yanlış tarama buzz.
  buzz('sfx/buzz.wav', cooldownMs: 80, gain: 0.85),

  /// Madeni para — nakit ödeme.
  coin('sfx/coin.wav', cooldownMs: 120, gain: 0.9),

  /// Kart onay — kart ödeme.
  card('sfx/card.wav', cooldownMs: 120, gain: 0.9),

  /// Kasa çekmecesi — vardiya sonu / büyük olaylar.
  drawer('sfx/drawer.wav', cooldownMs: 200, gain: 0.8);

  const SfxId(this.asset, {required this.cooldownMs, required this.gain});

  /// `assets/audio/` altına göreli yol.
  final String asset;
  final int cooldownMs;

  /// Sesin "yapısal" volume katsayısı (waveform ham seviyesi).
  final double gain;
}

/// Ses tasarımı sarmalayıcısı (GDD §8.6 mix mimarisi).
///
/// Volume = `master × channel × sfx.gain`. Master = global on/off ve toplu
/// kontrol; channel = music veya sfx; gain = SFX'in yapısal seviyesi.
///
/// **Cooldown:** Aynı SFX (özellikle combo sırasında beep) çok hızlı
/// tetiklenirse `cooldownMs` engelliyor (ses çakışmasını önler, GDD §8.6).
///
/// **Ducking:** Müşteri konuşma / büyük SFX çaldığında müzik 1 sn boyunca
/// %30'a düşer. Faz 3'te müzik track'leri eklenince aktif olacak — şimdilik
/// API hazır, no-op.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  // --- ayarlar (0..1) ---
  double masterVolume = 0.8;
  double musicVolume = 0.6;
  double sfxVolume = 0.9;

  /// Toplu kapatma (settings).
  bool muted = false;

  /// Cihazda gerçekten ses çalmaya izin ver (test/CI'da false).
  bool enabled = true;

  final Map<SfxId, int> _lastPlayMs = {};

  /// Tüm SFX'leri audio cache'e ön-yükle (uygulama başlangıcında bir kez).
  Future<void> preloadAll() async {
    if (!enabled) return;
    try {
      await FlameAudio.audioCache.loadAll([
        for (final id in SfxId.values) id.asset,
      ]);
    } catch (e, st) {
      // Asset eksikliği oyunu çökertmesin (GDD §16.4 fallback ilkesi).
      debugPrint('AudioService.preloadAll failed: $e\n$st');
    }
  }

  void setVolumes({double? master, double? music, double? sfx}) {
    if (master != null) masterVolume = master.clamp(0, 1);
    if (music != null) musicVolume = music.clamp(0, 1);
    if (sfx != null) sfxVolume = sfx.clamp(0, 1);
  }

  /// SFX çal. Cooldown içinde tekrar tetiklenirse no-op.
  Future<void> playSfx(SfxId id, {int? nowMs}) async {
    if (!enabled || muted || masterVolume <= 0 || sfxVolume <= 0) return;
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayMs[id];
    if (last != null && now - last < id.cooldownMs) return;
    _lastPlayMs[id] = now;
    final volume = (masterVolume * sfxVolume * id.gain).clamp(0, 1).toDouble();
    try {
      await FlameAudio.play(id.asset, volume: volume);
    } catch (e) {
      debugPrint('AudioService.playSfx(${id.name}) failed: $e');
    }
  }

  /// Müzik başlat (Faz 3+ track'leri eklenince kullanılır). Şimdilik
  /// hiçbir track yüklü değil — no-op + log.
  Future<void> startMusic(String track) async {
    if (!enabled || muted) return;
    debugPrint('AudioService.startMusic stub: $track');
  }
}
