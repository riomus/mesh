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
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

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

  @override
  String get searchHint => 'Search devices by name or ID';

  @override
  String get loraOnlyFilterLabel => 'LoRa only';

  @override
  String get meshtasticLabel => 'Meshtastic';

  @override
  String get settingsButtonLabel => 'Settings';

  @override
  String get nodesTitle => 'Nodes';

  @override
  String get tabList => 'List';

  @override
  String get tabMap => 'Map';

  @override
  String get logs => 'Logs';

  @override
  String get liveEvents => 'Live events';

  @override
  String get serviceAvailable => 'Service available';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusConnecting => 'Connecting...';

  @override
  String get statusDisconnected => 'Disconnected';

  @override
  String get mapRefPrefix => 'Ref';

  @override
  String get clearRef => 'Clear ref';

  @override
  String get fitBounds => 'Fit bounds';

  @override
  String get center => 'Center';

  @override
  String get useAsRef => 'Use as ref';

  @override
  String get details => 'Details';

  @override
  String get copyCoords => 'Copy coords';

  @override
  String get coordsCopied => 'Coordinates copied';

  @override
  String get noNodesWithLocation =>
      'No nodes with location yet.\nLong‑press on the map to set a custom distance reference.';

  @override
  String customRefSet(Object lat, Object lon) {
    return 'Custom distance reference set to $lat, $lon';
  }

  @override
  String get coordinates => 'Coordinates';

  @override
  String get searchNodes => 'Search nodes';

  @override
  String get findByNameOrId => 'Find by name or id ...';

  @override
  String get clear => 'Clear';

  @override
  String get addFilter => 'Add filter';

  @override
  String get sorting => 'Sorting';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get favoritesFirst => 'Favorites first';

  @override
  String get distance => 'Distance';

  @override
  String get snr => 'SNR';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get role => 'Role';

  @override
  String get name => 'Name';

  @override
  String get hops => 'hops';

  @override
  String get via => 'via';

  @override
  String get addFilterTitle => 'Add filter';

  @override
  String get key => 'Key';

  @override
  String get exact => 'Exact';

  @override
  String get regex => 'Regex';

  @override
  String hasValueFor(Object key) {
    return 'has $key';
  }

  @override
  String get customValueOptional => 'Custom value (optional)';

  @override
  String get regexCaseInsensitive => 'Regex (case-insensitive)';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String get useSourceAsRef => 'Use source device as distance ref';

  @override
  String get tipSetCustomRef =>
      'Tip: set a custom reference by long‑pressing on the Map tab';

  @override
  String get cancel => 'Cancel';

  @override
  String get addAction => 'Add';

  @override
  String get apply => 'Apply';

  @override
  String get searchEvents => 'Search events';

  @override
  String get searchInSummaryOrTags => 'Search in summary or tags';

  @override
  String get battery => 'Battery';

  @override
  String get charging => 'charging';

  @override
  String get location => 'Location';

  @override
  String get locationUnavailable => 'Location is not available for this node';

  @override
  String get sourceDevice => 'Source device';

  @override
  String get viaMqtt => 'via MQTT';

  @override
  String get connectFailed => 'Connect failed';

  @override
  String get meshtasticConnectFailed => 'Meshtastic connect failed';

  @override
  String get deviceError => 'Device error';

  @override
  String get eventsTitle => 'Events';

  @override
  String failedToShareEvents(Object error) {
    return 'Failed to share events: $error';
  }

  @override
  String get noEventsYet => 'No events yet';

  @override
  String get eventDetailsTitle => 'Event details';

  @override
  String get timestamp => 'Timestamp';

  @override
  String get summary => 'Summary';

  @override
  String get tags => 'Tags';

  @override
  String get payload => 'Payload';

  @override
  String get waypoint => 'Waypoint';

  @override
  String get user => 'User';

  @override
  String get routing => 'Routing';

  @override
  String get routingPayload => 'Routing payload';

  @override
  String get admin => 'Admin';

  @override
  String get remoteHardware => 'Remote hardware';

  @override
  String get neighborInfo => 'Neighbor info';

  @override
  String get neighbors => 'Neighbors';

  @override
  String get storeForward => 'Store & Forward';

  @override
  String get telemetry => 'Telemetry';

  @override
  String get paxcounter => 'Paxcounter';

  @override
  String get traceroute => 'Traceroute';

  @override
  String get keyVerification => 'Key verification';

  @override
  String get rawPayload => 'Raw payload';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get close => 'Close';

  @override
  String get shareEvents => 'Share events (JSON)';

  @override
  String get eventsExport => 'Events export';

  @override
  String get shareLogs => 'Share logs (JSON)';

  @override
  String get logsExport => 'Logs export';

  @override
  String get addFilters => 'Add filters';

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get clearAll => 'Clear';

  @override
  String failedToShareLogs(Object error) {
    return 'Failed to share logs: $error';
  }

  @override
  String get mapAttribution => '© OpenStreetMap contributors';

  @override
  String nodeIdHex(Object hex) {
    return 'ID: 0x$hex';
  }

  @override
  String nodeTitleHex(Object hex) {
    return 'Node 0x$hex';
  }

  @override
  String get roleLabel => 'Role';

  @override
  String get hopsAway => 'Hops away';

  @override
  String get snrLabel => 'SNR';

  @override
  String get lastSeenLabel => 'Last seen';

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get messageTooLong => 'Message too long';

  @override
  String sendFailed(Object error) {
    return 'Failed to send: $error';
  }
}
