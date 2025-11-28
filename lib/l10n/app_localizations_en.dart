// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mesh BLE Scanner';

  @override
  String get nearbyDevicesTitle => 'Nearby Bluetooth Devices';

  @override
  String get scan => 'Scan';

  @override
  String get stop => 'Stop';

  @override
  String get toggleThemeTooltip => 'Toggle theme';

  @override
  String get languageTooltip => 'Change language';

  @override
  String get general => 'General';

  @override
  String get identifier => 'Identifier';

  @override
  String get platformName => 'Platform name';

  @override
  String get signalRssi => 'Signal (RSSI)';

  @override
  String get advertisement => 'Advertisement';

  @override
  String get advertisedName => 'Advertised name';

  @override
  String get connectable => 'Connectable';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get service => 'Service';

  @override
  String get serviceUuids => 'Service UUIDs';

  @override
  String serviceUuidsWithCount(Object count) {
    return 'Service UUIDs ($count)';
  }

  @override
  String get manufacturerData => 'Manufacturer Data';

  @override
  String manufacturerDataWithCount(Object count) {
    return 'Manufacturer Data ($count)';
  }

  @override
  String get serviceData => 'Service Data';

  @override
  String serviceDataWithCount(Object count) {
    return 'Service Data ($count)';
  }

  @override
  String get noneAdvertised => 'None advertised';

  @override
  String get bluetoothOn => 'Bluetooth is ON';

  @override
  String get bluetoothOff => 'Bluetooth is OFF';

  @override
  String bluetoothState(Object state) {
    return 'Bluetooth state: $state';
  }

  @override
  String get webNote =>
      'On Web, scanning shows a chooser after tapping Scan (HTTPS required).';

  @override
  String get tapScanToDiscover =>
      'Tap Scan to discover nearby Bluetooth devices';

  @override
  String get unknown => 'unknown';
}
