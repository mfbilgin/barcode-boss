// Basit sentetik SFX üreticisi — Barcode Boss MVP için 5 ses dosyası
// üretir (16-bit PCM mono 22050 Hz WAV). Pixabay/Freesound/Kenney CC0
// dosyaları indirilince bu placeholder'ların yerini alabilir (GDD §8).
//
// Çalıştırma: `dart run tools/gen_sfx.dart`

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const int sampleRate = 22050;
const String outDir = 'assets/audio/sfx';

void main() {
  Directory(outDir).createSync(recursive: true);

  _writeWav('$outDir/beep.wav', _beep());
  _writeWav('$outDir/buzz.wav', _buzz());
  _writeWav('$outDir/coin.wav', _coin());
  _writeWav('$outDir/card.wav', _card());
  _writeWav('$outDir/drawer.wav', _drawer());

  stdout.writeln('SFX üretildi: $outDir/{beep,buzz,coin,card,drawer}.wav');
}

// ---------------- SFX recipes ----------------

/// Tarayıcı "BEEP" — 880 Hz sinüs, hızlı attack + üstel decay.
List<double> _beep() {
  return _synth(
    durationSec: 0.09,
    sample: (t) => sin(2 * pi * 880 * t),
    envelope: _envelope(attackSec: 0.003, releaseSec: 0.07, sustainLevel: 1.0),
    gain: 0.85,
  );
}

/// Hatalı tarama "buzz" — 180 Hz sawtooth.
List<double> _buzz() {
  return _synth(
    durationSec: 0.18,
    sample: (t) => _sawtooth(180 * t),
    envelope: _envelope(attackSec: 0.005, releaseSec: 0.16),
    gain: 0.7,
  );
}

/// Madeni para "clink" — iki kısa tetik (1500 Hz → 2000 Hz triangle).
List<double> _coin() {
  final samples = <double>[];
  samples.addAll(
    _synth(
      durationSec: 0.07,
      sample: (t) => _triangle(1500 * t),
      envelope: _envelope(attackSec: 0.002, releaseSec: 0.06),
      gain: 0.8,
    ),
  );
  samples.addAll(
    _synth(
      durationSec: 0.1,
      sample: (t) => _triangle(2000 * t),
      envelope: _envelope(attackSec: 0.002, releaseSec: 0.09),
      gain: 0.75,
    ),
  );
  return samples;
}

/// Kart onay "ding" — 1200 Hz sinüs, hafif/yumuşak.
List<double> _card() {
  return _synth(
    durationSec: 0.12,
    sample: (t) => sin(2 * pi * 1200 * t),
    envelope: _envelope(attackSec: 0.01, releaseSec: 0.11),
    gain: 0.65,
  );
}

/// Kasa çekmecesi — gürültü patlaması + low-pass karakterli (gürültü +
/// hareketli ortalama).
List<double> _drawer() {
  final rng = Random(42);
  final raw = List<double>.generate(
    (sampleRate * 0.22).round(),
    (_) => rng.nextDouble() * 2 - 1,
  );
  // Basit low-pass (3-tap hareketli ortalama).
  final smoothed = List<double>.filled(raw.length, 0);
  for (var i = 0; i < raw.length; i++) {
    final a = i > 0 ? raw[i - 1] : 0.0;
    final b = raw[i];
    final c = i < raw.length - 1 ? raw[i + 1] : 0.0;
    smoothed[i] = (a + b + c) / 3;
  }
  final env = _envelope(attackSec: 0.005, releaseSec: 0.2);
  return [
    for (var i = 0; i < smoothed.length; i++)
      smoothed[i] * env(i / sampleRate, 0.22) * 0.55,
  ];
}

// ---------------- Synthesis helpers ----------------

typedef _Envelope = double Function(double t, double durationSec);

List<double> _synth({
  required double durationSec,
  required double Function(double t) sample,
  required _Envelope envelope,
  double gain = 1.0,
}) {
  final n = (sampleRate * durationSec).round();
  return [
    for (var i = 0; i < n; i++)
      sample(i / sampleRate) * envelope(i / sampleRate, durationSec) * gain,
  ];
}

_Envelope _envelope({
  required double attackSec,
  required double releaseSec,
  double sustainLevel = 1.0,
}) {
  return (double t, double durationSec) {
    if (t < attackSec) return t / attackSec * sustainLevel;
    final releaseStart = durationSec - releaseSec;
    if (t >= releaseStart) {
      final r = (t - releaseStart) / releaseSec;
      return sustainLevel * (1 - r).clamp(0, 1);
    }
    return sustainLevel;
  };
}

double _sawtooth(double phase) => 2 * (phase - phase.floorToDouble()) - 1;

double _triangle(double phase) {
  final p = phase - phase.floorToDouble();
  return 4 * (p - 0.5).abs() - 1;
}

// ---------------- WAV writer ----------------

void _writeWav(String path, List<double> samples) {
  final pcm = ByteData(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    pcm.setInt16(i * 2, v, Endian.little);
  }
  final dataBytes = pcm.buffer.asUint8List();

  const channels = 1;
  const bitsPerSample = 16;
  const byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  const blockAlign = channels * bitsPerSample ~/ 8;
  final fileSize = 36 + dataBytes.length;

  final header = BytesBuilder()
    ..add(_ascii('RIFF'))
    ..add(_u32(fileSize))
    ..add(_ascii('WAVE'))
    ..add(_ascii('fmt '))
    ..add(_u32(16))
    ..add(_u16(1)) // PCM
    ..add(_u16(channels))
    ..add(_u32(sampleRate))
    ..add(_u32(byteRate))
    ..add(_u16(blockAlign))
    ..add(_u16(bitsPerSample))
    ..add(_ascii('data'))
    ..add(_u32(dataBytes.length));

  final file = File(path);
  file.writeAsBytesSync([...header.toBytes(), ...dataBytes]);
  stdout.writeln(
    '  $path  (${(file.lengthSync() / 1024).toStringAsFixed(1)} KB, '
    '${samples.length} samples)',
  );
}

List<int> _ascii(String s) => s.codeUnits;

List<int> _u32(int v) {
  final b = ByteData(4)..setUint32(0, v, Endian.little);
  return b.buffer.asUint8List();
}

List<int> _u16(int v) {
  final b = ByteData(2)..setUint16(0, v, Endian.little);
  return b.buffer.asUint8List();
}
