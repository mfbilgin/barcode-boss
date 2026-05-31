# App Icon Source Files

`flutter_launcher_icons` bu klasörden okur ve `android/app/src/main/res/mipmap-*`
altına her density için `ic_launcher.png` ve adaptive icon XML'leri üretir.

## Beklenen dosyalar

| Dosya | Boyut | İçerik |
|---|---|---|
| `app_icon.png` | **1024×1024 PNG** | Tam icon (eski Android için kullanılır, köşeler yuvarlanır) |
| `app_icon_foreground.png` | **1024×1024 PNG** | Adaptive icon ön plan (Android 8+); arka plan `#FFF3E0` ile birleştirilir |

> **Adaptive icon kuralları:** Görsel **merkezdeki 432×432** alanda kalmalı.
> Dışındaki 296px güvenlik şeridi her launcher tarafından farklı maskelenir
> (yuvarlak, kare, squircle vb.) — orada yalnız arka plan rengi görünmeli.

## Üretme komutu

PNG'leri yerleştirdikten sonra (proje kökünden):

```bash
dart run flutter_launcher_icons
```

Bu komut sırayla:
- `android/app/src/main/res/mipmap-mdpi/` ... `mipmap-xxxhdpi/` altına `ic_launcher.png` koyar.
- `mipmap-anydpi-v26/ic_launcher.xml` adaptive icon XML'i yazar (foreground + background renk).
- `values/colors.xml` içine `ic_launcher_background` rengini ekler.

Sonra `flutter build apk --release` veya `--debug` yeni icon'la çıkar.
