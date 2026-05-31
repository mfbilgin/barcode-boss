import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase (GDD §15 Telemetry — Faz 4). google-services.json zorunlu.
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Release imzalama (Faz 5). `android/key.properties` dosyası `.gitignore`'da
// olmalıdır — keystore + şifre commit'lenmez. Dosya yoksa release build
// debug-key ile imzalanır (yalnız geliştirme için; tester'a paylaşılamaz).
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}
val hasReleaseKeystore: Boolean = keystorePropertiesFile.exists()

android {
    namespace = "com.mfbilgin.barcode_boss"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mfbilgin.barcode_boss"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // Fallback: key.properties yoksa debug-key. Tester'a paylaşılamaz.
                signingConfigs.getByName("debug")
            }
            // R8/ProGuard varsayılan agresif optimizasyon kapalı (Flame +
            // reflection kullanan paketlerle stabilite önceliği). Faz 7+ Play
            // Store'a yüklemeden önce minify aç + keep rule'ları gözden geçir.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
