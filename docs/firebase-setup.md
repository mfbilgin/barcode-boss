# Firebase Enablement Rehberi (Faz 4+)

Telemetry mimarisi backend-agnostic kuruldu — `TelemetryService.instance`
varsayılan olarak `NoopTelemetryBackend` (debug log) kullanır. Firebase'i
aktive etmek için:

## 1. Firebase Console — proje oluştur

1. https://console.firebase.google.com → **Add project** → `barcode-boss`.
2. **Add app → Android**:
   - **Package name:** `com.barcodeboss.barcode_boss`
   - **App nickname:** Barcode Boss
   - **Debug signing certificate SHA-1:** (opsiyonel, post-launch sign-in için)
3. **Download `google-services.json`** → `android/app/google-services.json`.

## 2. Pubspec — Firebase paketlerini aç

`pubspec.yaml` içindeki yorum satırlarını kaldır:
```yaml
firebase_core: ^3.0.0
firebase_analytics: ^11.0.0
firebase_crashlytics: ^4.0.0
firebase_remote_config: ^5.0.0  # Faz 7
```
Sonra: `flutter pub get`

## 3. Android — gradle plugin (Kotlin DSL)

> **Önemli:** Bu proje Kotlin DSL (`.kts`) kullanır. Eski Groovy syntax'ı
> (`classpath 'foo'`, `apply plugin: 'bar'`) çalışmaz — derleme hatası verir.

**`android/settings.gradle.kts`** içindeki `plugins { ... }` bloğuna ekle:
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    // Firebase
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.google.firebase.crashlytics") version "3.0.2" apply false
}
```

**`android/app/build.gradle.kts`** içindeki `plugins { ... }` bloğuna ekle:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}
```

> Root `android/build.gradle.kts`'e Firebase için bir şey **eklemiyoruz** —
> modern Flutter (3.16+) için her şey yukarıdaki iki dosyada.

## 4. FirebaseTelemetryBackend ekle

`lib/services/telemetry/firebase_telemetry_backend.dart`:
```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'telemetry_backend.dart';

class FirebaseTelemetryBackend implements TelemetryBackend {
  final _analytics = FirebaseAnalytics.instance;
  final _crashlytics = FirebaseCrashlytics.instance;

  @override
  Future<void> logEvent(String name, [Map<String, Object?>? params]) {
    return _analytics.logEvent(
      name: name,
      parameters: params?.map((k, v) => MapEntry(k, v as Object)) ?? const {},
    );
  }

  @override
  Future<void> recordError(Object error, StackTrace? stack,
      {String? context, bool fatal = false}) {
    return _crashlytics.recordError(error, stack,
        reason: context, fatal: fatal);
  }

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _analytics.setUserProperty(name: name, value: value);
}
```

## 5. main.dart — init + swap

```dart
import 'package:firebase_core/firebase_core.dart';
import 'services/telemetry/firebase_telemetry_backend.dart';

Future<void> main() async {
  await runWithCrashGuard(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    TelemetryService.swap(FirebaseTelemetryBackend());
    // ... mevcut Hive + diğer init kodu ...
  });
}
```

## 6. KVKK consent (GDD §21.1)

İlk açılışta consent banner (kabul/reddet). Reddedilirse
`FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false)`.

## Doğrulama

- `flutter run -d <device>` → Firebase Console → Analytics → DebugView
- `customer_completed`, `shift_started` vb. event'lerin akışını gör (GDD §15.2).
- Test crash: `FirebaseCrashlytics.instance.crash()` → Console → Crashlytics.

## Önemli notlar

- `google-services.json` `.gitignore`'da YOK (private repo varsayımı).
  Open-source'a açıyorsanız `android/app/google-services.json` satırını
  `.gitignore`'a ekleyin.
- Telemetry/crash kod yolları zaten yerinde — tek değişiklik
  `TelemetryService.swap(...)`.
- Remote Config kullanımı Faz 7'de (`balance_overrides`, `feature_flags`).
