# Barcode Boss

Mobil mahalle marketi kasiyer simülatörü. Flutter + Flame ile geliştiriliyor.

| Alan | Değer |
|------|-------|
| **Tür** | Casual · Management · Time-pressure simulator |
| **Platform** | Android (iOS post-launch) |
| **Engine** | Flutter 3.x + [Flame](https://flame-engine.org/) 1.x |
| **State** | Riverpod 2.5 · Hive 2.2 (lokal kayıt) |
| **Telemetry** | Firebase Analytics + Crashlytics (opt-in, KVKK uyumlu — bkz. [`docs/kvkk-privacy.md`](docs/kvkk-privacy.md)) |
| **Para birimi** | B-Coin (oyun içi, 2 ondalık, TL modeli denomination) |
| **Dil** | Türkçe (EN post-launch) |
| **Mevcut faz** | Faz 5 — Closed Beta / Playtest |
| **Test** | `flutter test` → 59/59 ✓ · `flutter analyze` → 0 sorun ✓ |

## Belgeler

| Doküman | İçerik |
|---|---|
| [`docs/GDD.md`](docs/GDD.md) | Tam Game Design Document (v1.0.3) |
| [`docs/firebase-setup.md`](docs/firebase-setup.md) | Firebase Analytics + Crashlytics aktivasyonu |
| [`docs/release-build.md`](docs/release-build.md) | Keystore üretme + imzalı APK build |
| [`docs/playtest-guide.md`](docs/playtest-guide.md) | Tester brief + test senaryoları |
| [`docs/kvkk-privacy.md`](docs/kvkk-privacy.md) | KVKK uyumu + Privacy Policy şablonu |

## Önkoşullar

- Flutter SDK ≥ 3.16 ([kurulum](https://docs.flutter.dev/get-started/install))
- Android SDK (target API 34, min API 21 / Android 5.0)
- (Opsiyonel) Firebase projesi — telemetry için, olmadan da çalışır

## Kurulum

```bash
git clone https://github.com/mfbilgin/barcode-boss.git
cd barcode-boss
flutter pub get
```

### Firebase (opsiyonel — telemetry/crashlytics için)

Telemetry kullanmak istemiyorsan **bu adımı atla** — uygulama `NoopTelemetryBackend` ile çalışır, hata vermez.

1. [Firebase Console](https://console.firebase.google.com) → yeni proje aç → Android app ekle (package: `com.mfbilgin.barcode_boss`).
2. `google-services.json`'ı indir → `android/app/google-services.json` olarak yerleştir.
3. Şablon için: [`android/app/google-services.json.example`](android/app/google-services.json.example).
4. Detaylı setup: [`docs/firebase-setup.md`](docs/firebase-setup.md).

### Çalıştır

```bash
flutter run -d <android-device-id>
```

> Bu proje **Android-only**. Windows/iOS/web build'leri desteklenmiyor (Flame ses + Firebase Android'e bağlı).

## Geliştirme

```bash
flutter analyze                                    # Lint
flutter test                                       # Tüm testler (~60 test)
flutter test test/services/lifeline_service_test.dart   # Tekil dosya
dart run flutter_launcher_icons                    # App icon regenerate (assets/icon/'dan)
flutter build apk --release --split-per-abi        # ~26 MB ARM64 APK (tester'a)
```

Release imzalama: [`docs/release-build.md`](docs/release-build.md).

## Klasör Yapısı

```
barcode-boss/
├── lib/
│   ├── game/              # Flame oyunu (cashier_game, components, overlays)
│   ├── models/            # Catalog, ShiftRecord, InventoryItem, ...
│   ├── screens/           # Home, Prep (4 tab), Game, Summary, Settings
│   ├── services/          # Save, Inventory, Audio, Lifeline, Telemetry, ...
│   ├── state/             # Riverpod notifier'lar (economy, inventory, ...)
│   ├── widgets/           # Tutorial banner, vs.
│   ├── l10n/              # ARB + gen'd AppLocalizations
│   └── theme/             # AppColors, ThemeData
├── assets/
│   ├── data/              # products.json, credits.json
│   ├── icon/              # App icon kaynak (PNG)
│   ├── images/            # UI/karakter/ürün sprite'ları
│   ├── audio/             # SFX (sentetik WAV) + müzik
│   └── fonts/             # Nunito variable font
├── tools/                 # gen_sfx.dart, Blender render scripti
├── docs/                  # GDD + setup/release/playtest/KVKK rehberleri
├── test/                  # Unit + widget testler
└── android/               # Native Android (Kotlin DSL, Firebase plugin'leri)
```

## Lisans

MIT — bkz. [LICENSE](LICENSE).

Üçüncü taraf asset attribution: [`assets/data/credits.json`](assets/data/credits.json)
(Kenney CC0 + Pixabay/Freesound + tasarımcının kendi üretimleri).
