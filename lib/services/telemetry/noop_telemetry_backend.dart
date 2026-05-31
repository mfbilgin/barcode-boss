import 'package:flutter/foundation.dart';

import 'telemetry_backend.dart';

/// Varsayılan no-op telemetri backend'i — Firebase aktif edilmediğinde
/// debug log'a yazar, prod'da sessiz kalır.
class NoopTelemetryBackend implements TelemetryBackend {
  const NoopTelemetryBackend();

  @override
  Future<void> logEvent(String name, [Map<String, Object?>? params]) async {
    if (kDebugMode) {
      debugPrint('[telemetry] $name ${params ?? ''}');
    }
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? context,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[telemetry/error]${fatal ? ' FATAL' : ''}'
        '${context != null ? ' [$context]' : ''}: $error\n$stack',
      );
    }
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    if (kDebugMode) {
      debugPrint('[telemetry/prop] $name=$value');
    }
  }
}
