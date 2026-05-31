/// Telemetry/crash backend arayüzü (GDD §15).
///
/// Faz 4'te [NoopTelemetryBackend] varsayılan. Faz 4+ Firebase aktif edildiğinde
/// `FirebaseTelemetryBackend` (firebase_analytics + firebase_crashlytics
/// sarmalayıcısı) bu interface'i implement eder ve `main.dart`'ta swap edilir.
abstract class TelemetryBackend {
  /// Snake_case event adı + tipli parametreler (GDD §15.2).
  Future<void> logEvent(String name, [Map<String, Object?>? params]);

  /// Crash veya yakalanmış exception raporu.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? context,
    bool fatal = false,
  });

  /// Kullanıcı özelliği (örn: store_level, locale) — analiz boyutlandırma.
  Future<void> setUserProperty(String name, String? value);
}
