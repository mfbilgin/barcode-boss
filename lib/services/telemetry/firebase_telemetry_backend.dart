import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'telemetry_backend.dart';

/// Firebase Analytics + Crashlytics arka ucu (GDD §15, §16.1).
///
/// `main.dart`'ta `Firebase.initializeApp()` sonrası
/// `TelemetryService.swap(FirebaseTelemetryBackend())` ile aktive edilir.
/// `google-services.json` android/app altında olmalı.
class FirebaseTelemetryBackend implements TelemetryBackend {
  FirebaseTelemetryBackend();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  @override
  Future<void> logEvent(String name, [Map<String, Object?>? params]) {
    // Firebase Analytics null değer kabul etmez — filtrele.
    final filtered = <String, Object>{};
    params?.forEach((k, v) {
      if (v != null) filtered[k] = v;
    });
    return _analytics.logEvent(name: name, parameters: filtered);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? context,
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      error,
      stack,
      reason: context,
      fatal: fatal,
    );
  }

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _analytics.setUserProperty(name: name, value: value);
}
