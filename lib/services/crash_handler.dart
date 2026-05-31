import 'dart:async';

import 'package:flutter/widgets.dart';

import 'telemetry/telemetry_service.dart';

/// Crash + uncaught exception toplama (GDD §16.1).
///
/// [runApp] çağrısını [body] içinde sarmalayın. Hem Flutter widget tree
/// hatalarını (`FlutterError.onError`) hem de async zone hatalarını
/// (`runZonedGuarded`) telemetri backend'ine raporlar.
Future<void> runWithCrashGuard(Future<void> Function() body) async {
  // Tüm init + body aynı Zone içinde olmalı — yoksa Flutter "Zone mismatch"
  // verir (binding'i farklı zone'da kuran kod runApp'i başka zone'da çağırırsa).
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        TelemetryService.instance.errorCaught(
          details.exception,
          details.stack,
          screen: details.context?.toString(),
          fatal: false,
        ),
      );
    };

    // PlatformDispatcher.onError Flutter 3.3+ — engine-level hatalar
    // (FFI/native plugin throw).
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      unawaited(
        TelemetryService.instance.errorCaught(error, stack, fatal: true),
      );
      return true;
    };

    await body();
  }, (error, stack) {
    unawaited(
      TelemetryService.instance.errorCaught(error, stack, fatal: true),
    );
  });
}
