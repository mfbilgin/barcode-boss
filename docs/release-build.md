# Release APK Build Rehberi (Faz 5)

Bu rehber Play Store'sız tester dağıtımı içindir: keystore üret, signed APK
çıkar, tester'a WhatsApp/Telegram/Drive linkle gönder.

## 1. Keystore üret (TEK SEFER)

Komut interaktif sorular sorar. **Şifreleri ve alias'ı kaybetme** — bir gün
Play Store'a yüklersen aynı imzayla güncelleme atman gerekir; kayıpta uygulama
"farklı uygulama" olarak görünür ve kullanıcılar veri kaybeder.

```bash
keytool -genkey -v \
  -keystore $HOME/keystores/barcode-boss-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias barcode_boss
```

Windows PowerShell:
```powershell
keytool -genkey -v `
  -keystore "$HOME\keystores\barcode-boss-release.jks" `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias barcode_boss
```

> `keytool` yoksa: JDK 17+ kurulu olmalı (Android Studio ile geliyor). Konum:
> `C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`.

İstediği bilgiler:
- **First and last name:** Muhammet Bilgin
- **Organizational unit / Organization:** boş geçebilirsin
- **City / State / Country code:** `Istanbul` / `Istanbul` / `TR`
- **Keystore password** ve **Alias password:** güçlü, birbirinden farklı.
  1Password / KeePass'a kaydet.

## 2. `key.properties` dosyasını oluştur

`android/key.properties.example`'i `android/key.properties` olarak kopyala ve
gerçek değerlerle doldur:

```properties
storePassword=...
keyPassword=...
keyAlias=barcode_boss
storeFile=C:/Users/PC/keystores/barcode-boss-release.jks
```

> `key.properties` **gitignore'da** — commit olmaz. `.jks` dosyası da proje
> dışında tut (`*.jks` zaten ignored ama yine de dışarıda güvenli).

## 3. Release APK build

```bash
flutter build apk --release                # universal (~58 MB)
flutter build apk --release --split-per-abi   # ABI başına 3 APK
```

Flutter çıktısı `build/app/outputs/flutter-apk/` altına şu isimlerle düşer:
- `app-armeabi-v7a-release.apk` (eski 32-bit telefonlar, ~24 MB)
- `app-arm64-v8a-release.apk` (modern telefonların %95'i, ~26 MB)
- `app-x86_64-release.apk` (yalnız emülatör, ~27 MB)
- `app-release.apk` (universal, ~58 MB)

### 3.1 Rename — release upload için kullanıcı dostu isim

Yukarıdaki isimler çirkin. Bir PowerShell scripti onları yeniden adlandırır
ve `build/release-uploads/` altına kopyalar:

```powershell
powershell -ExecutionPolicy Bypass -File tools/prepare-release-apks.ps1
```

Çıktı:
```
build/release-uploads/
  barcode-boss-arm32.apk        # ~24 MB
  barcode-boss-arm64.apk        # ~26 MB (tester'a önerilen)
  barcode-boss-universal.apk    # ~58 MB
```

Dosya adında **versiyon yok** — Pages'teki `/latest/download/<name>` URL
her release'te aynı dosya adıyla çalışır, tester'a paylaştığın link
bozulmaz.

> `app-x86_64-release.apk` kasıtlı olarak release'e konmaz; sadece
> emülatör için, tester'a faydası yok.

## 4. APK doğrulama

İmzayı kontrol et:
```bash
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

Çıktıda `Owner:` satırı kendi adınla görünmeli (debug-key olsaydı
`CN=Android Debug` yazardı).

## 5. Cihaza yükleme

```bash
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

Cihazda manuel: APK'yı WhatsApp/Telegram/Drive ile paylaş → cihaz "Bilinmeyen
kaynaklardan yükleme" izni ister (Settings → Security) → kur.

## 6. Sürüm artırma

Her release öncesi `pubspec.yaml`'da `version: 0.1.0+1` → `+2`, `+3`, ... arttır
(buildNumber). Aynı buildNumber'la güncelleme APK'sı kurulamaz.

## Sık karşılaşılan hatalar

| Hata | Sebep | Çözüm |
|---|---|---|
| `Keystore was tampered with, or password was incorrect` | `key.properties`'teki şifre yanlış | Şifre yöneticinden tekrar al, dosyayı düzelt |
| `signing config "release" not found` | `key.properties` yok veya yolu bozuk | Dosyayı `android/` altına koy, yolu UNIX `/` ile yaz |
| `Install failed: INSTALL_FAILED_VERSION_DOWNGRADE` | Cihazda daha yüksek versionCode kurulu | `pubspec.yaml` versionCode'u (+N) arttır |
| `App not installed as package conflicts with an existing package` | Aynı `applicationId`'li farklı imzalı APK kurulu (örn. debug) | Cihazdan eski uygulamayı kaldır → tekrar kur |
| `INSTALL_FAILED_NO_MATCHING_ABIS` | x86 APK ARM cihaza yüklenmeye çalışılıyor | `arm64-v8a` APK kullan |

## Faz 7'de yapılacaklar (Play Store öncesi)

- [ ] `isMinifyEnabled = true` (R8) — APK %30-40 küçülür
- [ ] ProGuard keep rule'ları: Flame, Riverpod, Hive sınıfları
- [ ] AAB (Android App Bundle) build: `flutter build appbundle --release`
- [ ] Google Play Console hesabı + Play App Signing'e geçiş (Google keystore'u tutar)
- [ ] Privacy Policy URL'i Play Console'a girilir (bkz. [kvkk-privacy.md](kvkk-privacy.md))
