import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mesh BLE Scanner'**
  String get appTitle;

  /// No description provided for @nearbyDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Bluetooth Devices'**
  String get nearbyDevicesTitle;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @toggleThemeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleThemeTooltip;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get languageTooltip;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @identifier.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get identifier;

  /// No description provided for @platformName.
  ///
  /// In en, this message translates to:
  /// **'Platform name'**
  String get platformName;

  /// No description provided for @signalRssi.
  ///
  /// In en, this message translates to:
  /// **'Signal (RSSI)'**
  String get signalRssi;

  /// No description provided for @advertisement.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get advertisement;

  /// No description provided for @advertisedName.
  ///
  /// In en, this message translates to:
  /// **'Advertised name'**
  String get advertisedName;

  /// No description provided for @connectable.
  ///
  /// In en, this message translates to:
  /// **'Connectable'**
  String get connectable;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @serviceUuids.
  ///
  /// In en, this message translates to:
  /// **'Service UUIDs'**
  String get serviceUuids;

  /// No description provided for @serviceUuidsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Service UUIDs ({count})'**
  String serviceUuidsWithCount(Object count);

  /// No description provided for @manufacturerData.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Data'**
  String get manufacturerData;

  /// No description provided for @manufacturerDataWithCount.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Data ({count})'**
  String manufacturerDataWithCount(Object count);

  /// No description provided for @serviceData.
  ///
  /// In en, this message translates to:
  /// **'Service Data'**
  String get serviceData;

  /// No description provided for @serviceDataWithCount.
  ///
  /// In en, this message translates to:
  /// **'Service Data ({count})'**
  String serviceDataWithCount(Object count);

  /// No description provided for @noneAdvertised.
  ///
  /// In en, this message translates to:
  /// **'None advertised'**
  String get noneAdvertised;

  /// No description provided for @bluetoothOn.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is ON'**
  String get bluetoothOn;

  /// No description provided for @bluetoothOff.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is OFF'**
  String get bluetoothOff;

  /// No description provided for @bluetoothState.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth state: {state}'**
  String bluetoothState(Object state);

  /// No description provided for @webNote.
  ///
  /// In en, this message translates to:
  /// **'On Web, scanning shows a chooser after tapping Scan (HTTPS required).'**
  String get webNote;

  /// No description provided for @tapScanToDiscover.
  ///
  /// In en, this message translates to:
  /// **'Tap Scan to discover nearby Bluetooth devices'**
  String get tapScanToDiscover;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknown;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search devices by name or ID'**
  String get searchHint;

  /// No description provided for @loraOnlyFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'LoRa only'**
  String get loraOnlyFilterLabel;

  /// No description provided for @meshtasticLabel.
  ///
  /// In en, this message translates to:
  /// **'Meshtastic'**
  String get meshtasticLabel;

  /// No description provided for @settingsButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsButtonLabel;
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
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
