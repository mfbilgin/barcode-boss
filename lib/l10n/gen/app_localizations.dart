import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Barcode Boss'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In tr, this message translates to:
  /// **'Mahalle marketinin patronu sensin'**
  String get appTagline;

  /// No description provided for @labelBalance.
  ///
  /// In tr, this message translates to:
  /// **'Bakiye'**
  String get labelBalance;

  /// No description provided for @labelLevel.
  ///
  /// In tr, this message translates to:
  /// **'Seviye'**
  String get labelLevel;

  /// No description provided for @levelAndShift.
  ///
  /// In tr, this message translates to:
  /// **'{level} · Gün {shift}'**
  String levelAndShift(int level, int shift);

  /// No description provided for @buttonStartShift.
  ///
  /// In tr, this message translates to:
  /// **'Güne Başla'**
  String get buttonStartShift;

  /// No description provided for @buttonNewGame.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Oyun (sıfırla)'**
  String get buttonNewGame;

  /// No description provided for @tooltipSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get tooltipSettings;

  /// No description provided for @prepTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gün {shift} hazırlığı'**
  String prepTitle(int shift);

  /// No description provided for @tabStock.
  ///
  /// In tr, this message translates to:
  /// **'Stok'**
  String get tabStock;

  /// No description provided for @tabOrders.
  ///
  /// In tr, this message translates to:
  /// **'Sipariş'**
  String get tabOrders;

  /// No description provided for @tabPricing.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat'**
  String get tabPricing;

  /// No description provided for @tabReport.
  ///
  /// In tr, this message translates to:
  /// **'Önceki Rapor'**
  String get tabReport;

  /// No description provided for @buttonStartShiftUpper.
  ///
  /// In tr, this message translates to:
  /// **'GÜNE BAŞLA'**
  String get buttonStartShiftUpper;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @sectionSound.
  ///
  /// In tr, this message translates to:
  /// **'Ses'**
  String get sectionSound;

  /// No description provided for @sectionAccessibility.
  ///
  /// In tr, this message translates to:
  /// **'Erişilebilirlik'**
  String get sectionAccessibility;

  /// No description provided for @sectionProgress.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme'**
  String get sectionProgress;

  /// No description provided for @labelMasterVolume.
  ///
  /// In tr, this message translates to:
  /// **'Ana ses'**
  String get labelMasterVolume;

  /// No description provided for @labelMusicVolume.
  ///
  /// In tr, this message translates to:
  /// **'Müzik'**
  String get labelMusicVolume;

  /// No description provided for @labelSfxVolume.
  ///
  /// In tr, this message translates to:
  /// **'Efekt (SFX)'**
  String get labelSfxVolume;

  /// No description provided for @labelMute.
  ///
  /// In tr, this message translates to:
  /// **'Sessize al'**
  String get labelMute;

  /// No description provided for @labelTapMode.
  ///
  /// In tr, this message translates to:
  /// **'Tap modu (tarama)'**
  String get labelTapMode;

  /// No description provided for @subtitleTapMode.
  ///
  /// In tr, this message translates to:
  /// **'Swipe yerine tek tap ile tara'**
  String get subtitleTapMode;

  /// No description provided for @labelHaptic.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim feedback'**
  String get labelHaptic;

  /// No description provided for @labelReduceAnimations.
  ///
  /// In tr, this message translates to:
  /// **'Animasyonları azalt'**
  String get labelReduceAnimations;

  /// No description provided for @buttonResetTutorial.
  ///
  /// In tr, this message translates to:
  /// **'Tutorial\'ı tekrar göster'**
  String get buttonResetTutorial;

  /// No description provided for @snackTutorialReset.
  ///
  /// In tr, this message translates to:
  /// **'Tutorial sıfırlandı.'**
  String get snackTutorialReset;

  /// No description provided for @tooltipTest.
  ///
  /// In tr, this message translates to:
  /// **'Test'**
  String get tooltipTest;

  /// No description provided for @summaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'🎉 Kepenk Kapandı!'**
  String get summaryTitle;

  /// No description provided for @labelCustomersServed.
  ///
  /// In tr, this message translates to:
  /// **'İşlenen müşteri'**
  String get labelCustomersServed;

  /// No description provided for @labelCustomersLost.
  ///
  /// In tr, this message translates to:
  /// **'Kaybedilen müşteri'**
  String get labelCustomersLost;

  /// No description provided for @labelMissedDemand.
  ///
  /// In tr, this message translates to:
  /// **'Kaçırılan talep'**
  String get labelMissedDemand;

  /// No description provided for @labelWrongChange.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış para üstü'**
  String get labelWrongChange;

  /// No description provided for @labelSatisfaction.
  ///
  /// In tr, this message translates to:
  /// **'Memnuniyet'**
  String get labelSatisfaction;

  /// No description provided for @labelRevenue.
  ///
  /// In tr, this message translates to:
  /// **'Ciro'**
  String get labelRevenue;

  /// No description provided for @labelCost.
  ///
  /// In tr, this message translates to:
  /// **'Maliyet'**
  String get labelCost;

  /// No description provided for @labelNet.
  ///
  /// In tr, this message translates to:
  /// **'Net kâr'**
  String get labelNet;

  /// No description provided for @labelXp.
  ///
  /// In tr, this message translates to:
  /// **'XP'**
  String get labelXp;

  /// No description provided for @buttonBackToPrep.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlık Ekranına Dön'**
  String get buttonBackToPrep;

  /// No description provided for @emptyShiftRecord.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tamamlanmış gün yok.'**
  String get emptyShiftRecord;

  /// No description provided for @labelTutorialBonus.
  ///
  /// In tr, this message translates to:
  /// **'Yeni başlayan bonusu'**
  String get labelTutorialBonus;

  /// No description provided for @labelAdvanceRepayment.
  ///
  /// In tr, this message translates to:
  /// **'Avans geri ödemesi'**
  String get labelAdvanceRepayment;

  /// No description provided for @labelEmergencyAdvance.
  ///
  /// In tr, this message translates to:
  /// **'Acil avans'**
  String get labelEmergencyAdvance;

  /// No description provided for @emergencyAdvanceDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Acil avans aldın!'**
  String get emergencyAdvanceDialogTitle;

  /// No description provided for @emergencyAdvanceDialogBody.
  ///
  /// In tr, this message translates to:
  /// **'{amount} bakiyene eklendi. Sonraki 3 günde net kazancının %20\'si kesilecek (gün başına max 🪙 200).'**
  String emergencyAdvanceDialogBody(String amount);

  /// No description provided for @emergencyAdvanceDialogClose.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get emergencyAdvanceDialogClose;

  /// No description provided for @stockZeroDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm stoğun bitti'**
  String get stockZeroDialogTitle;

  /// No description provided for @stockZeroDialogBody.
  ///
  /// In tr, this message translates to:
  /// **'Günü başlatamazsın. Önce Sipariş sekmesinden mal getirt.'**
  String get stockZeroDialogBody;

  /// No description provided for @stockZeroDialogBodyWithAdvance.
  ///
  /// In tr, this message translates to:
  /// **'Günü başlatamazsın. Önce Sipariş sekmesinden mal getirt. Sana bir kerelik {amount} avans verildi.'**
  String stockZeroDialogBodyWithAdvance(String amount);

  /// No description provided for @stockZeroDialogClose.
  ///
  /// In tr, this message translates to:
  /// **'Sipariş ekranına git'**
  String get stockZeroDialogClose;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
