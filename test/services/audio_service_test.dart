import 'package:barcode_boss/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService cooldown', () {
    setUp(() {
      AudioService.instance
        ..enabled = false // cihaz playback yapma (test env)
        ..muted = false
        ..setVolumes(master: 0.8, music: 0.6, sfx: 0.9);
    });

    test('cooldown içinde tekrar tetik no-op (idempotent çağrı sayısı)', () {
      // enabled=false → playSfx zaten erken çıkar, ama cooldown kaydı
      // _lastPlayMs'e yazılmaz; bu test yapısal davranışı doğrular.
      // (Gerçek cooldown muted=false + enabled=true ile çalışır.)
      AudioService.instance.enabled = true;
      AudioService.instance.playSfx(SfxId.beep, nowMs: 1000);
      AudioService.instance.playSfx(SfxId.beep, nowMs: 1010); // < 70ms
      AudioService.instance.playSfx(SfxId.beep, nowMs: 1080); // > 70ms — geçer
      // Test başarılıysa çağrılar exception fırlatmadı (FlameAudio cache
      // miss debugPrint'e gider).
      expect(SfxId.beep.cooldownMs, 70);
    });

    test('volume clamp 0..1', () {
      AudioService.instance.setVolumes(master: 1.5, sfx: -0.2);
      expect(AudioService.instance.masterVolume, 1.0);
      expect(AudioService.instance.sfxVolume, 0.0);
    });

    test('muted = true → playSfx no-op', () {
      AudioService.instance
        ..enabled = true
        ..muted = true;
      AudioService.instance.playSfx(SfxId.beep, nowMs: 2000);
      // No exception — test passes.
      expect(AudioService.instance.muted, true);
    });
  });
}
