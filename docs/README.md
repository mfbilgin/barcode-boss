# Barcode Boss

Bir mobil kasiyer / süpermarket simülatörü. Flutter + Flame ile geliştiriliyor.

| Alan | Değer |
|------|-------|
| **Tür** | Casual · Management · Time-pressure simulator |
| **Platform** | Android (iOS post-launch) |
| **Engine** | Flutter 3.x + [Flame](https://flame-engine.org/) 1.x |
| **Para birimi** | B-Coin (oyun içi, 2 ondalık) |
| **MVP dili** | Türkçe (EN post-launch) |
| **Mevcut faz** | Faz 0 — Setup |

## Belgeler

Tam Game Design Document: [`docs/GDD.md`](docs/GDD.md) (v1.0 — Approved Pre-production)

## Önkoşullar

- Flutter SDK ≥ 3.16 ([kurulum](https://docs.flutter.dev/get-started/install))
- Android SDK (target API 34, min API 21 / Android 5.0)
- Asset render pipeline için: Blender 4.x + Python 3.10+

## Kurulum

```bash
git clone <repo-url>
cd barcode-boss
flutter pub get
flutter run -d <device-id>
```

## Geliştirme

```bash
# Lint + analiz
flutter analyze

# Unit testler
flutter test

# Belirli bir test dosyası
flutter test test/services/bcoin_formatter_test.dart

# Release APK build
flutter build apk --release --obfuscate --split-debug-info=build/symbols/
```

## Klasör Yapısı

```
barcode-boss/
├── lib/                # Dart kaynak kodu
├── assets/
│   ├── data/           # JSON config (products.json, credits.json)
│   ├── images/         # UI ve sprite'lar
│   ├── audio/          # SFX ve müzik (.ogg)
│   └── fonts/          # Nunito font ailesi
├── tools/              # Blender render scripti vb.
├── docs/               # GDD ve teknik notlar
└── test/               # Unit + widget testler
```

## Lisans

Bu yazılım kapalı kaynaktır. Tüm hakları saklıdır.

Asset attribution detayları için: [`assets/data/credits.json`](assets/data/credits.json) (Kenney CC0 + Pixabay/Freesound).
