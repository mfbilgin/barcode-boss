// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Barcode Boss';

  @override
  String get appTagline => 'Mahalle marketinin patronu sensin';

  @override
  String get labelBalance => 'Bakiye';

  @override
  String get labelLevel => 'Seviye';

  @override
  String levelAndShift(int level, int shift) {
    return '$level · Gün $shift';
  }

  @override
  String get buttonStartShift => 'Güne Başla';

  @override
  String get buttonNewGame => 'Yeni Oyun (sıfırla)';

  @override
  String get tooltipSettings => 'Ayarlar';

  @override
  String prepTitle(int shift) {
    return 'Gün $shift hazırlığı';
  }

  @override
  String get tabStock => 'Stok';

  @override
  String get tabOrders => 'Sipariş';

  @override
  String get tabPricing => 'Fiyat';

  @override
  String get tabReport => 'Önceki Rapor';

  @override
  String get buttonStartShiftUpper => 'GÜNE BAŞLA';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get sectionSound => 'Ses';

  @override
  String get sectionAccessibility => 'Erişilebilirlik';

  @override
  String get sectionProgress => 'İlerleme';

  @override
  String get labelMasterVolume => 'Ana ses';

  @override
  String get labelMusicVolume => 'Müzik';

  @override
  String get labelSfxVolume => 'Efekt (SFX)';

  @override
  String get labelMute => 'Sessize al';

  @override
  String get labelTapMode => 'Tap modu (tarama)';

  @override
  String get subtitleTapMode => 'Swipe yerine tek tap ile tara';

  @override
  String get labelHaptic => 'Titreşim feedback';

  @override
  String get labelReduceAnimations => 'Animasyonları azalt';

  @override
  String get buttonResetTutorial => 'Tutorial\'ı tekrar göster';

  @override
  String get snackTutorialReset => 'Tutorial sıfırlandı.';

  @override
  String get tooltipTest => 'Test';

  @override
  String get summaryTitle => '🎉 Kepenk Kapandı!';

  @override
  String get labelCustomersServed => 'İşlenen müşteri';

  @override
  String get labelCustomersLost => 'Kaybedilen müşteri';

  @override
  String get labelMissedDemand => 'Kaçırılan talep';

  @override
  String get labelWrongChange => 'Yanlış para üstü';

  @override
  String get labelSatisfaction => 'Memnuniyet';

  @override
  String get labelRevenue => 'Ciro';

  @override
  String get labelCost => 'Maliyet';

  @override
  String get labelNet => 'Net kâr';

  @override
  String get labelXp => 'XP';

  @override
  String get buttonBackToPrep => 'Hazırlık Ekranına Dön';

  @override
  String get emptyShiftRecord => 'Henüz tamamlanmış gün yok.';

  @override
  String get labelTutorialBonus => 'Yeni başlayan bonusu';

  @override
  String get labelAdvanceRepayment => 'Avans geri ödemesi';

  @override
  String get labelEmergencyAdvance => 'Acil avans';

  @override
  String get emergencyAdvanceDialogTitle => 'Acil avans aldın!';

  @override
  String emergencyAdvanceDialogBody(String amount) {
    return '$amount bakiyene eklendi. Sonraki 3 günde net kazancının %20\'si kesilecek (gün başına max 🪙 200).';
  }

  @override
  String get emergencyAdvanceDialogClose => 'Anladım';

  @override
  String get stockZeroDialogTitle => 'Tüm stoğun bitti';

  @override
  String get stockZeroDialogBody =>
      'Günü başlatamazsın. Önce Sipariş sekmesinden mal getirt.';

  @override
  String stockZeroDialogBodyWithAdvance(String amount) {
    return 'Günü başlatamazsın. Önce Sipariş sekmesinden mal getirt. Sana bir kerelik $amount avans verildi.';
  }

  @override
  String get stockZeroDialogClose => 'Sipariş ekranına git';
}
