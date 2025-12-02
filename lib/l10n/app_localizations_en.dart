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

  @override
  String get buildPrefix => 'Build: ';

  @override
  String get builtPrefix => 'Built: ';

  @override
  String agoSeconds(Object seconds) {
    return '${seconds}s ago';
  }

  @override
  String agoMinutes(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String agoHours(Object hours) {
    return '${hours}h ago';
  }

  @override
  String agoDays(Object days) {
    return '${days}d ago';
  }

  @override
  String get sortAsc => 'ASC';

  @override
  String get sortDesc => 'DESC';

  @override
  String get unknownState => 'Unknown';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageFollowSystem => 'Follow system language';

  @override
  String languageAppLanguage(Object language) {
    return 'App language: $language';
  }

  @override
  String get eventDetails => 'Event details';

  @override
  String get myInfo => 'MyInfo';

  @override
  String get config => 'Config';

  @override
  String get configComplete => 'Config complete';

  @override
  String get rebooted => 'Rebooted';

  @override
  String get moduleConfig => 'Module config';

  @override
  String get channel => 'Channel';

  @override
  String get channels => 'Channels';

  @override
  String get queueStatus => 'Queue status';

  @override
  String get deviceMetadata => 'Device metadata';

  @override
  String get mqttProxy => 'MQTT proxy';

  @override
  String get fileInfo => 'File info';

  @override
  String get clientNotification => 'Client notification';

  @override
  String get deviceUiConfig => 'Device UI config';

  @override
  String get logRecord => 'Log record';

  @override
  String get packet => 'Packet';

  @override
  String get textPayload => 'Text payload';

  @override
  String get position => 'Position';

  @override
  String rawPayloadDetails(Object bytes, Object id, Object name) {
    return 'Raw payload ($name:$id, $bytes bytes)';
  }

  @override
  String get encryptedUnknownPayload => 'Encrypted/unknown payload';

  @override
  String get configUpdate => 'Config update';

  @override
  String get configStreamComplete => 'Config stream complete';

  @override
  String get deviceReportedReboot => 'Device reported reboot';

  @override
  String get noReboot => 'No reboot';

  @override
  String get channelUpdate => 'Channel update';

  @override
  String get routingMessage => 'Routing message';

  @override
  String get adminMessage => 'Admin message';

  @override
  String get positionUpdate => 'Position update';

  @override
  String get userInfo => 'User info';

  @override
  String remoteHw(Object mask, Object type, Object value) {
    return 'Remote HW: $type mask=$mask value=$value';
  }

  @override
  String storeForwardVariant(Object variant) {
    return 'Store & Forward ($variant)';
  }

  @override
  String telemetryVariant(Object variant) {
    return 'Telemetry ($variant)';
  }

  @override
  String get device => 'Device';

  @override
  String get serial => 'Serial';

  @override
  String get rangeTest => 'Range test';

  @override
  String get externalNotification => 'External notification';

  @override
  String get audio => 'Audio';

  @override
  String get cannedMessage => 'Canned message';

  @override
  String get ambientLighting => 'Ambient lighting';

  @override
  String get detectionSensor => 'Detection sensor';

  @override
  String get dtnOverlay => 'DTN overlay';

  @override
  String get broadcastAssist => 'Broadcast assist';

  @override
  String get nodeFilter => 'Node filter';

  @override
  String get nodeHighlight => 'Node highlight';

  @override
  String get map => 'Map';

  @override
  String snrDb(Object value) {
    return 'SNR $value dB';
  }

  @override
  String nodeTitle(Object name) {
    return 'Node $name';
  }

  @override
  String nodeTitleId(Object id) {
    return 'Node ($id)';
  }

  @override
  String get nodeInfo => 'NodeInfo';

  @override
  String batteryLevel(Object percentage) {
    return '🔋$percentage%';
  }

  @override
  String viaNameId(Object id, Object name) {
    return 'via $name (0x$id)';
  }

  @override
  String viaName(Object name) {
    return 'via $name';
  }

  @override
  String viaId(Object id) {
    return 'via 0x$id';
  }

  @override
  String get devicesTab => 'Devices';

  @override
  String get searchLogs => 'Search logs';

  @override
  String get searchLogsHint => 'Search in time, level, tags or message';

  @override
  String get logsTitle => 'Logs';

  @override
  String get tag => 'Tag';

  @override
  String get level => 'Level';

  @override
  String get valueEmptyPresence => 'Value (empty = presence only for exact)';

  @override
  String get regexTip =>
      'Tip: regex uses Dart syntax and is case-insensitive by default';

  @override
  String get selectLevels => 'Select levels';

  @override
  String get unspecified => '(unspecified)';

  @override
  String connectFailedError(Object error) {
    return 'Connect failed: $error';
  }

  @override
  String get power => 'Power';

  @override
  String get network => 'Network';

  @override
  String get display => 'Display';

  @override
  String get lora => 'LoRa';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get security => 'Security';

  @override
  String get sessionKey => 'Session key';

  @override
  String get nodeMod => 'Node mod';

  @override
  String get nodeModAdmin => 'Node mod admin';

  @override
  String get idleGame => 'Idle game';

  @override
  String get deviceState => 'Device State';

  @override
  String get noDeviceState => 'No device state';

  @override
  String get connectToViewState => 'Connect to the device to view its state';
}
