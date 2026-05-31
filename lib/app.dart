import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'l10n/gen/app_localizations.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/prep_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shift_summary_screen.dart';
import 'theme/app_theme.dart';

/// Uygulama route'ları (GDD §6.1 ekran listesi).
class Routes {
  static const String home = '/';
  static const String prep = '/prep';
  static const String game = '/game';
  static const String summary = '/summary';
  static const String settings = '/settings';
}

final GoRouter _router = GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.prep,
      builder: (context, state) => const PrepScreen(),
    ),
    GoRoute(
      path: Routes.game,
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: Routes.summary,
      builder: (context, state) => const ShiftSummaryScreen(),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class BarcodeBossApp extends StatelessWidget {
  const BarcodeBossApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Barcode Boss',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('tr'),
      routerConfig: _router,
    );
  }
}
