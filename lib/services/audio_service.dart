import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Oyun boyu kullanılan SFX türleri (GDD §8.3).
enum SfxId {
  /// Barkod beep — başarılı tarama.
  beep('sfx/beep.wav', cooldownMs: 70, gain: 0.9, poolSize: 4),

  /// Yanlış tarama buzz.
  buzz('sfx/buzz.wav', cooldownMs: 80, gain: 0.85, poolSize: 2),

  /// Madeni para — nakit ödeme.
  coin('sfx/coin.wav', cooldownMs: 120, gain: 0.9, poolSize: 2),

  /// Kart onay — kart ödeme.
  card('sfx/card.wav', cooldownMs: 120, gain: 0.9, poolSize: 2),

  /// Kasa çekmecesi — vardiya sonu / büyük olaylar.
  drawer('sfx/drawer.wav', cooldownMs: 200, gain: 0.8, poolSize: 1);

  const SfxId(
    this.asset, {
    required this.cooldownMs,
    required this.gain,
    required this.poolSize,
  });

  /// `assets/audio/` altına göreli yol.
  final String asset;
  final int cooldownMs;

  /// Sesin "yapısal" volume katsayısı (waveform ham seviyesi).
  final double gain;

  /// AudioPool'da tutulan eşzamanlı çalabilecek player sayısı. `beep`
  /// gibi hızlı tekrarlı SFX'ler için yüksek; drawer için 1 yeter.
  final int poolSize;
}

/// Ses tasarımı sarmalayıcısı (GDD §8.6 mix mimarisi).
///
/// Volume = `master × channel × sfx.gain`. Master = global on/off ve toplu
/// kontrol; channel = music veya sfx; gain = SFX'in yapısal seviyesi.
///
/// **AudioPool:** `FlameAudio.play()` her çağrıda yeni bir AudioPlayer
/// instance açar → ilk çalma "soğuk" başlar, fark edilebilir gecikme.
/// Pool ön-instantiated player'ları döndürür → start() neredeyse anlık.
/// Tester feedback'i: "seslerde gecikme var" — pool ile çözüldü.
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
  final Map<SfxId, AudioPool> _pools = {};

  /// Tüm SFX'leri AudioPool olarak ön-yükle (uygulama başlangıcında bir kez).
  /// Pool oluşturulamasa bile `FlameAudio.play` fallback'i devrede kalır.
  Future<void> preloadAll() async {
    if (!enabled) return;
    try {
      // Cache'e yükle (loadAll fallback play için de gerekli).
      await FlameAudio.audioCache.loadAll([
        for (final id in SfxId.values) id.asset,
      ]);
    } catch (e, st) {
      // Asset eksikliği oyunu çökertmesin (GDD §16.4 fallback ilkesi).
      debugPrint('AudioService.preloadAll cache failed: $e\n$st');
      return;
    }

    // Her SFX için pool kur (paralel).
    await Future.wait([
      for (final id in SfxId.values) _initPool(id),
    ]);
  }

  Future<void> _initPool(SfxId id) async {
    try {
      _pools[id] = await FlameAudio.createPool(
        id.asset,
        maxPlayers: id.poolSize,
      );
    } catch (e) {
      // Pool kurulamadıysa fallback FlameAudio.play kullanılır — log + devam.
      debugPrint('AudioService.createPool(${id.name}) failed: $e');
    }
  }

  void setVolumes({double? master, double? music, double? sfx}) {
    if (master != null) masterVolume = master.clamp(0, 1);
    if (music != null) musicVolume = music.clamp(0, 1);
    if (sfx != null) sfxVolume = sfx.clamp(0, 1);
  }

  /// SFX çal. Cooldown içinde tekrar tetiklenirse no-op. Pool varsa
  /// pool'dan çalar (anlık), yoksa FlameAudio.play fallback (cold-start).
  Future<void> playSfx(SfxId id, {int? nowMs}) async {
    if (!enabled || muted || masterVolume <= 0 || sfxVolume <= 0) return;
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayMs[id];
    if (last != null && now - last < id.cooldownMs) return;
    _lastPlayMs[id] = now;
    final volume = (masterVolume * sfxVolume * id.gain).clamp(0, 1).toDouble();
    try {
      final pool = _pools[id];
      if (pool != null) {
        await pool.start(volume: volume);
      } else {
        await FlameAudio.play(id.asset, volume: volume);
      }
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
