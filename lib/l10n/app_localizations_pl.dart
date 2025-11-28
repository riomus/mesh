// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Mesh Skaner BLE';

  @override
  String get nearbyDevicesTitle => 'Bliskie urządzenia Bluetooth';

  @override
  String get scan => 'Skanuj';

  @override
  String get stop => 'Zatrzymaj';

  @override
  String get toggleThemeTooltip => 'Przełącz motyw';

  @override
  String get languageTooltip => 'Zmień język';

  @override
  String get general => 'Ogólne';

  @override
  String get identifier => 'Identyfikator';

  @override
  String get platformName => 'Nazwa platformy';

  @override
  String get signalRssi => 'Sygnał (RSSI)';

  @override
  String get advertisement => 'Reklama (Advertising)';

  @override
  String get advertisedName => 'Nazwa reklamowana';

  @override
  String get connectable => 'Możliwość połączenia';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get service => 'Usługa';

  @override
  String get serviceUuids => 'UUID usług';

  @override
  String serviceUuidsWithCount(Object count) {
    return 'UUID usług ($count)';
  }

  @override
  String get manufacturerData => 'Dane producenta';

  @override
  String manufacturerDataWithCount(Object count) {
    return 'Dane producenta ($count)';
  }

  @override
  String get serviceData => 'Dane usług';

  @override
  String serviceDataWithCount(Object count) {
    return 'Dane usług ($count)';
  }

  @override
  String get noneAdvertised => 'Brak w reklamie';

  @override
  String get bluetoothOn => 'Bluetooth jest WŁĄCZONY';

  @override
  String get bluetoothOff => 'Bluetooth jest WYŁĄCZONY';

  @override
  String bluetoothState(Object state) {
    return 'Stan Bluetooth: $state';
  }

  @override
  String get webNote =>
      'W przeglądarce, po naciśnięciu Skanuj pojawi się wybór urządzenia (wymagany HTTPS).';

  @override
  String get tapScanToDiscover =>
      'Naciśnij Skanuj, aby wyszukać pobliskie urządzenia Bluetooth';

  @override
  String get unknown => 'nieznany';
}
