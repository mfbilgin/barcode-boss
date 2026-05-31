import 'package:hive/hive.dart';

/// Kullanıcı ayarları için Hive `settings_v1` box sarmalayıcısı (GDD §6.1, §8.6,
/// §18). Volume kanalları, erişilebilirlik toggle'ları, ve tap modu.
class SettingsService {
  SettingsService._(this._box);

  static const String _boxName = 'settings_v1';

  static const String _kMaster = 'volume_master';
  static const String _kMusic = 'volume_music';
  static const String _kSfx = 'volume_sfx';
  static const String _kMuted = 'muted';
  static const String _kTapMode = 'tap_mode';
  static const String _kHaptic = 'haptic';
  static const String _kReduceAnim = 'reduce_anim';

  // Default değerler GDD §8.6 mix mimarisinden.
  static const double defaultMaster = 0.8;
  static const double defaultMusic = 0.6;
  static const double defaultSfx = 0.9;

  final Box<dynamic> _box;

  static Future<SettingsService> open() async {
    final box = await Hive.openBox<dynamic>(_boxName);
    return SettingsService._(box);
  }

  double get masterVolume =>
      (_box.get(_kMaster, defaultValue: defaultMaster) as num).toDouble();
  set masterVolume(double v) => _box.put(_kMaster, v.clamp(0, 1));

  double get musicVolume =>
      (_box.get(_kMusic, defaultValue: defaultMusic) as num).toDouble();
  set musicVolume(double v) => _box.put(_kMusic, v.clamp(0, 1));

  double get sfxVolume =>
      (_box.get(_kSfx, defaultValue: defaultSfx) as num).toDouble();
  set sfxVolume(double v) => _box.put(_kSfx, v.clamp(0, 1));

  bool get muted => _box.get(_kMuted, defaultValue: false) as bool;
  set muted(bool v) => _box.put(_kMuted, v);

  /// Erişilebilirlik: swipe yerine tek tap ile tarama (GDD §3.3).
  bool get tapModeEnabled => _box.get(_kTapMode, defaultValue: true) as bool;
  set tapModeEnabled(bool v) => _box.put(_kTapMode, v);

  /// Titreşim feedback'i (GDD §18.3).
  bool get hapticEnabled => _box.get(_kHaptic, defaultValue: true) as bool;
  set hapticEnabled(bool v) => _box.put(_kHaptic, v);

  /// Animasyon azaltma (GDD §18.6).
  bool get reduceAnimations =>
      _box.get(_kReduceAnim, defaultValue: false) as bool;
  set reduceAnimations(bool v) => _box.put(_kReduceAnim, v);
}
