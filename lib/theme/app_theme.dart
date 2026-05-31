import 'package:flutter/material.dart';

/// "Cozy capitalism" palet — sıcak, hafif, stresli olmayan ton (GDD §1.2, §6.5).
abstract class AppColors {
  static const Color background = Color(0xFFFFF6EA); // krem
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFF0883E); // sıcak turuncu — "Boss"
  static const Color secondary = Color(0xFF2A9D8F); // teal
  static const Color ink = Color(0xFF2B2B2B);
  static const Color inkSoft = Color(0xFF6E6E6E);

  // Kasa ekranı
  static const Color belt = Color(0xFFB7C2CC); // metal bant
  static const Color beltStripe = Color(0xFF9AA7B2);
  static const Color scannerGlass = Color(0xFF1E2A38);
  static const Color scanLaser = Color(0xFFFF1744); // tarayıcı laser

  // Sabır metresi (GDD §13.3) — renk + ifade ikonu birlikte (erişilebilirlik §18)
  static const Color patienceHigh = Color(0xFF4CAF50);
  static const Color patienceMid = Color(0xFFFFC107);
  static const Color patienceLow = Color(0xFFE53935);
}

abstract class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: AppColors.surface,
    ).copyWith(secondary: AppColors.secondary);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Nunito',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
