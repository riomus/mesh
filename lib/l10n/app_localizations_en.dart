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
  String statusReconnecting(Object attempt, Object max) {
    return 'Reconnecting (attempt $attempt/$max)...';
  }

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
  String get scanRequiredFirst =>
      'Device not found. Please scan for devices first.';

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

  @override
  String get loadingConfig => 'Loading Config';

  @override
  String get pleaseWaitFetchingConfig =>
      'Please wait while fetching device configuration...';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String roleWithRole(Object role) {
    return 'Role: $role';
  }

  @override
  String get knownNodes => 'Known nodes';

  @override
  String get notConfigured => 'Not configured';

  @override
  String get noConfigurationData => 'No configuration data received';

  @override
  String nodesWithCount(Object count) {
    return 'Nodes ($count)';
  }

  @override
  String get messageDetails => 'Message Details';

  @override
  String statusWithStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String packetIdWithId(Object id) {
    return 'Packet ID: $id';
  }

  @override
  String get messageInfo => 'Message Info';

  @override
  String get sessionKeyRequested => 'sessionKeyRequested';

  @override
  String get stateMissing => 'State Missing';

  @override
  String idWithId(Object id) {
    return 'id=$id';
  }

  @override
  String get xmodem => 'XModem';

  @override
  String xmodemStatus(Object control, Object seq) {
    return 'seq=$seq control=$control';
  }

  @override
  String get idTitle => 'ID';

  @override
  String get protectApp => 'Protect App';

  @override
  String get setPassword => 'Set Password';

  @override
  String get enterPassword => 'Enter Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'save';

  @override
  String get hostInputLabel => 'Host (IP address or hostname)';

  @override
  String get portInputLabel => 'Port';

  @override
  String get invalidHostPort => 'Please enter valid host and port';

  @override
  String get connectedToIpDevice => 'Connected to IP device';

  @override
  String get connectedToUsbDevice => 'Connected to USB device';

  @override
  String get refreshPorts => 'Refresh Ports';

  @override
  String get noSerialPortsFound => 'No serial ports found';

  @override
  String get selectSerialPort => 'Select Serial Port';

  @override
  String get xmodemTitle => 'XModem';

  @override
  String get emptyState => '—';

  @override
  String get filterKey => 'Key';

  @override
  String get satelliteEmoji => '📡';

  @override
  String get puzzleEmoji => '🧩';

  @override
  String get appProtected => 'App is protected. Advanced features are hidden.';

  @override
  String get disableProtection => 'Disable Protection';

  @override
  String get password => 'password';

  @override
  String get connectToIpDevice => 'Connect to Meshtastic Device via IP';

  @override
  String get connectViaUsb => 'Connect via USB';

  @override
  String get event => 'Event';

  @override
  String get defaultChannel => 'Default';

  @override
  String rssiDbm(Object value) {
    return '$value dBm';
  }

  @override
  String get sendingToRadio => 'Sending to radio...';

  @override
  String get sentToRadio => 'Sent to radio';

  @override
  String get acknowledgedByReceiver => 'Acknowledged by receiver';

  @override
  String get acknowledgedByRelay => 'Acknowledged by relay node';

  @override
  String get notAcknowledgedTimeout => 'Not acknowledged (Timeout)';

  @override
  String get received => 'Received';

  @override
  String get packetInfo => 'Packet Info:';

  @override
  String nodeName(Object name) {
    return 'Node $name';
  }

  @override
  String unknownNode(Object id) {
    return 'Node $id (Unknown)';
  }

  @override
  String get deviceConfig => 'Device Config';

  @override
  String get positionConfig => 'Position Config';

  @override
  String get powerConfig => 'Power Config';

  @override
  String get networkConfig => 'Network Config';

  @override
  String get displayConfig => 'Display Config';

  @override
  String get loraConfig => 'LoRa Config';

  @override
  String get bluetoothConfig => 'Bluetooth Config';

  @override
  String get securityConfig => 'Security Config';

  @override
  String get mqttConfig => 'MQTT Config';

  @override
  String get telemetryConfig => 'Telemetry Config';

  @override
  String get serialConfig => 'Serial Config';

  @override
  String get storeForwardConfig => 'Store & Forward Config';

  @override
  String get rangeTestConfig => 'Range Test Config';

  @override
  String get externalNotificationConfig => 'External Notification Config';

  @override
  String get audioConfig => 'Audio Config';

  @override
  String get neighborInfoConfig => 'Neighbor Info Config';

  @override
  String get remoteHardwareConfig => 'Remote Hardware Config';

  @override
  String get paxcounterConfig => 'Paxcounter Config';

  @override
  String get cannedMessageConfig => 'Canned Message Config';

  @override
  String get ambientLightingConfig => 'Ambient Lighting Config';

  @override
  String get detectionSensorConfig => 'Detection Sensor Config';

  @override
  String get dtnOverlayConfig => 'DTN Overlay Config';

  @override
  String get broadcastAssistConfig => 'Broadcast Assist Config';

  @override
  String get nodeModConfig => 'Node Mod Config';

  @override
  String get nodeModAdminConfig => 'Node Mod Admin Config';

  @override
  String get idleGameConfig => 'Idle Game Config';

  @override
  String get serialEnabled => 'serialEnabled';

  @override
  String get buttonGpio => 'Button GPIO';

  @override
  String get buzzerGpio => 'Buzzer GPIO';

  @override
  String get rebroadcastMode => 'Rebroadcast Mode';

  @override
  String get nodeInfoBroadcastSecs => 'Node Info Broadcast Secs';

  @override
  String get doubleTapAsButtonPress => 'Double Tap As Button Press';

  @override
  String get isManaged => 'isManaged';

  @override
  String get disableTripleClick => 'Disable Triple Click';

  @override
  String get timezone => 'Timezone';

  @override
  String get ledHeartbeatDisabled => 'LED Heartbeat Disabled';

  @override
  String get buzzerMode => 'Buzzer Mode';

  @override
  String get positionBroadcastSecs => 'Position Broadcast Secs';

  @override
  String get positionBroadcastSmartEnabled =>
      'Position Broadcast Smart Enabled';

  @override
  String get fixedPosition => 'Fixed Position';

  @override
  String get gpsEnabled => 'GPS Enabled';

  @override
  String get gpsUpdateInterval => 'GPS Update Interval';

  @override
  String get gpsAttemptTime => 'GPS Attempt Time';

  @override
  String get positionFlags => 'Position Flags';

  @override
  String get rxGpio => 'RX GPIO';

  @override
  String get txGpio => 'TX GPIO';

  @override
  String get broadcastSmartMinimumDistance =>
      'Broadcast Smart Minimum Distance';

  @override
  String get broadcastSmartMinimumIntervalSecs =>
      'Broadcast Smart Minimum Interval Secs';

  @override
  String get gpsEnableGpio => 'GPS Enable GPIO';

  @override
  String get gpsMode => 'GPS Mode';

  @override
  String get isPowerSaving => 'Is Power Saving';

  @override
  String get onBatteryShutdownAfterSecs => 'On Battery Shutdown After Secs';

  @override
  String get adcMultiplierOverride => 'ADC Multiplier Override';

  @override
  String get waitBluetoothSecs => 'Wait Bluetooth Secs';

  @override
  String get sdsSecs => 'SDS Secs';

  @override
  String get lsSecs => 'LS Secs';

  @override
  String get minWakeSecs => 'Min Wake Secs';

  @override
  String get deviceBatteryInaAddress => 'Device Battery INA Address';

  @override
  String get powermonEnables => 'Powermon Enables';

  @override
  String get wifiEnabled => 'WiFi Enabled';

  @override
  String get wifiSsid => 'WiFi SSID';

  @override
  String get screenOnSecs => 'screenOnSecs';

  @override
  String get autoScreenCarouselSecs => 'autoScreenCarouselSecs';

  @override
  String get compassNorthTop => 'compassNorthTop';

  @override
  String get flipScreen => 'flipScreen';

  @override
  String get units => 'units';

  @override
  String get oled => 'oled';

  @override
  String get displayMode => 'Display Mode';

  @override
  String get headingBold => 'headingBold';

  @override
  String get wakeOnTapOrMotion => 'wakeOnTapOrMotion';

  @override
  String get compassOrientation => 'compassOrientation';

  @override
  String get use12hClock => 'use12hClock';

  @override
  String get useLongNodeName => 'useLongNodeName';

  @override
  String get region => 'region';

  @override
  String get modemPreset => 'modemPreset';

  @override
  String get hopLimit => 'hopLimit';

  @override
  String get txEnabled => 'txEnabled';

  @override
  String get txPower => 'txPower';

  @override
  String get enabled => 'enabled';

  @override
  String get mode => 'mode';

  @override
  String get fixedPin => 'fixedPin';

  @override
  String get publicKey => 'publicKey';

  @override
  String get privateKey => 'privateKey';

  @override
  String get adminKeys => 'Admin Keys';

  @override
  String get debugLogApiEnabled => 'debugLogApiEnabled';

  @override
  String get adminChannelEnabled => 'adminChannelEnabled';

  @override
  String get address => 'address';

  @override
  String get username => 'username';

  @override
  String get encryption => 'Encryption';

  @override
  String get json => 'JSON';

  @override
  String get tls => 'TLS';

  @override
  String get rootTopic => 'Root Topic';

  @override
  String get proxyToClient => 'Proxy to Client';

  @override
  String get mapReporting => 'Map Reporting';

  @override
  String get deviceUpdateInterval => 'deviceUpdateInterval';

  @override
  String get environmentUpdateInterval => 'environmentUpdateInterval';

  @override
  String get environmentMeasurement => 'Environment Measurement';

  @override
  String get environmentScreen => 'Environment Screen';

  @override
  String get airQuality => 'Air Quality';

  @override
  String get airQualityInterval => 'airQualityInterval';

  @override
  String get powerMeasurement => 'Power Measurement';

  @override
  String get powerUpdateInterval => 'powerUpdateInterval';

  @override
  String get powerScreen => 'Power Screen';

  @override
  String get healthMeasurement => 'Health Measurement';

  @override
  String get healthUpdateInterval => 'healthUpdateInterval';

  @override
  String get healthScreen => 'Health Screen';

  @override
  String get deviceTelemetry => 'Device Telemetry';

  @override
  String get echo => 'echo';

  @override
  String get rxd => 'rxd';

  @override
  String get txd => 'txd';

  @override
  String get baud => 'baud';

  @override
  String get timeout => 'timeout';

  @override
  String get overrideConsole => 'Override Console';

  @override
  String get heartbeat => 'heartbeat';

  @override
  String get records => 'records';

  @override
  String get historyReturnMax => 'historyReturnMax';

  @override
  String get historyReturnWindow => 'historyReturnWindow';

  @override
  String get isServer => 'isServer';

  @override
  String get emitControlSignals => 'emitControlSignals';

  @override
  String get sender => 'sender';

  @override
  String get clearOnReboot => 'clearOnReboot';

  @override
  String get outputMs => 'outputMs';

  @override
  String get output => 'output';

  @override
  String get active => 'active';

  @override
  String get alertMessage => 'alertMessage';

  @override
  String get alertBell => 'alertBell';

  @override
  String get usePwm => 'usePwm';

  @override
  String get outputVibra => 'outputVibra';

  @override
  String get outputBuzzer => 'outputBuzzer';

  @override
  String get nagTimeout => 'nagTimeout';

  @override
  String get useI2sAsBuzzer => 'useI2sAsBuzzer';

  @override
  String get codec2Enabled => 'codec2Enabled';

  @override
  String get pttPin => 'pttPin';

  @override
  String get bitrate => 'bitrate';

  @override
  String get i2sWs => 'i2sWs';

  @override
  String get i2sSd => 'i2sSd';

  @override
  String get i2sDin => 'i2sDin';

  @override
  String get i2sSck => 'i2sSck';

  @override
  String get updateInterval => 'updateInterval';

  @override
  String get transmitOverLora => 'transmitOverLora';

  @override
  String get allowUndefinedPinAccess => 'allowUndefinedPinAccess';

  @override
  String get paxcounterUpdateInterval => 'paxcounterUpdateInterval';

  @override
  String get wifiThreshold => 'wifiThreshold';

  @override
  String get bleThreshold => 'bleThreshold';

  @override
  String get rotary1Enabled => 'rotary1Enabled';

  @override
  String get inputBrokerPinA => 'Input Broker Pin A';

  @override
  String get inputBrokerPinB => 'Input Broker Pin B';

  @override
  String get inputBrokerPinPress => 'Input Broker Pin Press';

  @override
  String get upDown1Enabled => 'Up/Down 1 Enabled';

  @override
  String get allowInputSource => 'allowInputSource';

  @override
  String get sendBell => 'sendBell';

  @override
  String get ledState => 'ledState';

  @override
  String get current => 'current';

  @override
  String get red => 'red';

  @override
  String get green => 'green';

  @override
  String get blue => 'blue';

  @override
  String get minBroadcastSecs => 'Min Broadcast Secs';

  @override
  String get stateBroadcastSecs => 'stateBroadcastSecs';

  @override
  String get monitorPin => 'monitorPin';

  @override
  String get triggerType => 'Trigger Type';

  @override
  String get usePullup => 'usePullup';

  @override
  String get ttlMinutes => 'ttlMinutes';

  @override
  String get initialDelayBaseMs => 'initialDelayBaseMs';

  @override
  String get retryBackoffMs => 'retryBackoffMs';

  @override
  String get maxTries => 'maxTries';

  @override
  String get degreeThreshold => 'degreeThreshold';

  @override
  String get dupThreshold => 'dupThreshold';

  @override
  String get windowMs => 'windowMs';

  @override
  String get maxExtraHops => 'maxExtraHops';

  @override
  String get jitterMs => 'jitterMs';

  @override
  String get airtimeGuard => 'airtimeGuard';

  @override
  String get textStatus => 'textStatus';

  @override
  String get emoji => 'emoji';

  @override
  String get snifferEnabled => 'snifferEnabled';

  @override
  String get doNotSendPrvOverMqtt => 'doNotSendPrvOverMqtt';

  @override
  String get localStatsOverMesh => 'Local Stats Over Mesh';

  @override
  String get idlegameEnabled => 'idlegameEnabled';

  @override
  String get autoResponderEnabled => 'autoResponderEnabled';

  @override
  String get autoResponderText => 'autoResponderText';

  @override
  String get autoRedirectMessages => 'autoRedirectMessages';

  @override
  String get autoRedirectTarget => 'Auto Redirect Target';

  @override
  String get telemetryLimiter => 'Telemetry Limiter';

  @override
  String get positionLimiter => 'Position Limiter';

  @override
  String get opportunisticFlooding => 'Opportunistic Flooding';

  @override
  String get idleGameVariant => 'Idle Game Variant';

  @override
  String get telemetryTitle => 'Telemetry';

  @override
  String get noTelemetryData => 'No telemetry data available';

  @override
  String get telemetryBattery => 'Battery';

  @override
  String get telemetryVoltage => 'Voltage';

  @override
  String get telemetryChannelUtil => 'Channel Util';

  @override
  String get telemetryAirUtilTx => 'Air Util Tx';

  @override
  String get telemetryTemperature => 'Temperature';

  @override
  String get telemetryHumidity => 'Humidity';

  @override
  String get telemetryPressure => 'Pressure';

  @override
  String get telemetryPm25 => 'PM2.5';

  @override
  String get telemetryCo2 => 'CO2';

  @override
  String telemetryChVoltage(Object channel) {
    return 'Ch$channel Voltage';
  }

  @override
  String telemetryHistory(Object count) {
    return 'History: $count points';
  }

  @override
  String get traces => 'Traceroutes';

  @override
  String get traceRoute => 'Trace Route';

  @override
  String get startTrace => 'Start Trace';

  @override
  String get traceTarget => 'Target';

  @override
  String get tracePending => 'Pending';

  @override
  String get traceCompleted => 'Completed';

  @override
  String get traceFailed => 'Failed';

  @override
  String get traceTimeout => 'Timeout';

  @override
  String get traceNoHistory => 'No traces yet';

  @override
  String get traceEvents => 'Trace Events';

  @override
  String get traceForwardRoute => 'Forward Route';

  @override
  String get traceReturnRoute => 'Return Route';

  @override
  String traceHopCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hops',
      one: '1 hop',
      zero: '0 hops',
    );
    return '$_temp0';
  }

  @override
  String get traceShowOnMap => 'Show on Map';

  @override
  String get traceSelectNode => 'Select node to trace';

  @override
  String get traceSent => 'Trace request sent';

  @override
  String get traceToggleVisualization => 'Toggle Trace Visualization';

  @override
  String get noNodesAvailable => 'No nodes available';

  @override
  String get refresh => 'Refresh';

  @override
  String get noDeviceConnected => 'No device connected';

  @override
  String get selectDevice => 'Select Device';

  @override
  String get bleHeartbeatInterval => 'BLE Heartbeat Interval';

  @override
  String get bleHeartbeatIntervalDescription =>
      'Time between heartbeat messages sent to BLE devices (in seconds)';

  @override
  String get tracerouteMinInterval => 'Traceroute Rate Limit';

  @override
  String get tracerouteMinIntervalDescription =>
      'Minimum seconds between traceroute requests to the same node. The firmware also enforces rate limits to prevent network congestion.';

  @override
  String get configTimeout => 'Config Download Timeout';

  @override
  String get configTimeoutDescription =>
      'Maximum time without activity when downloading device configuration (in seconds)';

  @override
  String get autoReconnect => 'Automatic Reconnection';

  @override
  String get autoReconnectDescription =>
      'Automatically reconnect when Bluetooth connection is lost unexpectedly';

  @override
  String get autoReconnectEnabled => 'Enable Auto-Reconnect';

  @override
  String get maxReconnectAttempts => 'Max Reconnect Attempts';

  @override
  String get maxReconnectAttemptsDescription =>
      'Maximum number of reconnection attempts (1-10)';

  @override
  String get reconnectBaseDelay => 'Reconnect Base Delay';

  @override
  String get reconnectBaseDelayDescription =>
      'Base delay for exponential backoff in seconds (backoff: 1s, 2s, 4s, 8s, 16s...)';

  @override
  String get nodesWithoutLocation => 'Nodes without location';

  @override
  String targetNodeNoLocation(Object id) {
    return 'Target node $id has no location data. Trace line cannot be drawn.';
  }

  @override
  String get startLocal => 'Start (Local)';

  @override
  String get traceTooltip => 'Trace';

  @override
  String get ackTooltip => 'Ack';

  @override
  String get localDevice => 'Local Device';

  @override
  String get deviceMetricsTitle => 'Device Metrics';

  @override
  String get environmentMetricsTitle => 'Environment Metrics';

  @override
  String get airQualityMetricsTitle => 'Air Quality Metrics';

  @override
  String get powerMetricsTitle => 'Power Metrics';

  @override
  String get localStatsTitle => 'Local Stats';

  @override
  String get healthMetricsTitle => 'Health Metrics';

  @override
  String get hostMetricsTitle => 'Host Metrics';

  @override
  String errorPrefix(Object error) {
    return 'Error: $error';
  }

  @override
  String get tabBle => 'BLE';

  @override
  String get tabIp => 'IP';

  @override
  String get tabUsb => 'USB';

  @override
  String get tabSim => 'Sim';

  @override
  String get simulationEnvironment => 'Simulation Environment';

  @override
  String get simulationDescription =>
      'Connect to a simulated device to test UI components with fake data (nodes, chat, traces, etc).';

  @override
  String get startSimulation => 'Start Simulation';

  @override
  String get connectedToSimulation => 'Connected to Simulation Device';

  @override
  String simulationFailed(Object error) {
    return 'Simulation failed: $error';
  }

  @override
  String get statusHistory => 'Status History';

  @override
  String sourceNodePrefix(Object name) {
    return 'Source: $name';
  }

  @override
  String get me => 'ME';

  @override
  String get targetLabel => '[Target]';

  @override
  String get sourceLabel => '[Source]';

  @override
  String get ackLabel => '[Ack]';

  @override
  String traceStreamError(Object error) {
    return 'Error in trace stream: $error';
  }

  @override
  String errorLoadingMessages(Object error) {
    return 'Error loading messages: $error';
  }

  @override
  String configSaveError(Object error) {
    return 'Error saving config: $error';
  }

  @override
  String myNodeNumLabel(Object num) {
    return 'myNodeNum=$num';
  }

  @override
  String nodeNumLabel(Object num) {
    return 'num=$num';
  }

  @override
  String idLabel(Object id) {
    return 'id=$id';
  }

  @override
  String channelIndexLabel(Object index) {
    return 'index=$index';
  }

  @override
  String freeLabel(Object value) {
    return 'free=$value';
  }

  @override
  String maxLabel(Object value) {
    return 'max=$value';
  }

  @override
  String fwLabel(Object value) {
    return 'fw=$value';
  }

  @override
  String hwLabel(Object value) {
    return 'hw=$value';
  }

  @override
  String roleKey(Object value) {
    return 'role=$value';
  }

  @override
  String get wifiLabel => 'wifi';

  @override
  String get btLabel => 'bt';

  @override
  String get ethLabel => 'eth';

  @override
  String bytesLabel(Object value) {
    return '$value bytes';
  }

  @override
  String fromLabel(Object value) {
    return 'from=$value';
  }

  @override
  String toLabel(Object value) {
    return 'to=$value';
  }

  @override
  String chLabel(Object value) {
    return 'ch=$value';
  }

  @override
  String nonceLabel(Object value) {
    return 'nonce=$value';
  }

  @override
  String get nA => 'N/A';

  @override
  String secondsSuffix(Object value) {
    return '${value}s';
  }

  @override
  String get myNodeNum => 'myNodeNum';

  @override
  String get rebootCount => 'rebootCount';

  @override
  String get minAppVersion => 'minAppVersion';

  @override
  String get firmwareEdition => 'firmwareEdition';

  @override
  String get nodedbCount => 'nodedbCount';

  @override
  String get pioEnv => 'pioEnv';

  @override
  String get deviceId => 'deviceId';

  @override
  String get nodeNum => 'num';

  @override
  String get userLongName => 'user.longName';

  @override
  String get userShortName => 'user.shortName';

  @override
  String get positionLat => 'position.lat';

  @override
  String get positionLon => 'position.lon';

  @override
  String get lastHeard => 'lastHeard';

  @override
  String get isFavorite => 'isFavorite';

  @override
  String get isIgnored => 'isIgnored';

  @override
  String get isKeyManuallyVerified => 'isKeyManuallyVerified';

  @override
  String get volt => 'volt';

  @override
  String get chUtil => 'chUtil';

  @override
  String get airUtil => 'airUtil';

  @override
  String get uptime => 'uptime';

  @override
  String get res => 'res';

  @override
  String get size => 'size';

  @override
  String get maxlen => 'maxlen';

  @override
  String get meshPacketId => 'meshPacketId';

  @override
  String get firmware => 'fw';

  @override
  String get hardware => 'hw';

  @override
  String get wifi => 'wifi';

  @override
  String get ethernet => 'eth';

  @override
  String get stateVersion => 'stateVer';

  @override
  String get canShutdown => 'canShutdown';

  @override
  String get hasRemoteHw => 'hasRemoteHw';

  @override
  String get hasPKC => 'hasPKC';

  @override
  String get excluded => 'excluded';

  @override
  String get hasFwPlus => 'hasFwPlus';

  @override
  String get hasNodemod => 'hasNodemod';

  @override
  String get topic => 'topic';

  @override
  String get retained => 'retained';

  @override
  String get text => 'text';

  @override
  String get dataLength => 'dataLen';

  @override
  String get fileName => 'name';

  @override
  String get sizeBytes => 'sizeBytes';

  @override
  String get message => 'message';

  @override
  String get replyId => 'replyId';

  @override
  String get time => 'time';

  @override
  String get payloadVariant => 'payloadVariant';

  @override
  String get source => 'source';

  @override
  String get control => 'control';

  @override
  String get seq => 'seq';

  @override
  String get crc16 => 'crc16';

  @override
  String get buffer => 'buffer';

  @override
  String get from => 'from';

  @override
  String get to => 'to';

  @override
  String get rxTime => 'rxTime';

  @override
  String get rxRssi => 'rxRssi';

  @override
  String get rxSnr => 'rxSnr';

  @override
  String get wantAck => 'wantAck';

  @override
  String get priority => 'priority';

  @override
  String get transport => 'transport';

  @override
  String get hopStart => 'hopStart';

  @override
  String get encrypted => 'encrypted';

  @override
  String get pkiEncrypted => 'pkiEncrypted';

  @override
  String get nextHop => 'nextHop';

  @override
  String get relayNode => 'relayNode';

  @override
  String get txAfter => 'txAfter';

  @override
  String get latI => 'latI';

  @override
  String get lonI => 'lonI';

  @override
  String get altitude => 'alt';

  @override
  String get gpsAccuracy => 'gpsAcc';

  @override
  String get sats => 'sats';

  @override
  String get locationSource => 'locSource';

  @override
  String get altitudeSource => 'altSource';

  @override
  String get tsMillisAdj => 'tsMillisAdj';

  @override
  String get altHae => 'altHae';

  @override
  String get altGeoSep => 'altGeoSep';

  @override
  String get pDOP => 'pDOP';

  @override
  String get hDOP => 'hDOP';

  @override
  String get vDOP => 'vDOP';

  @override
  String get groundSpeed => 'groundSpeed';

  @override
  String get groundTrack => 'groundTrack';

  @override
  String get fixQuality => 'fixQuality';

  @override
  String get fixType => 'fixType';

  @override
  String get sensorId => 'sensorId';

  @override
  String get nextUpdate => 'nextUpdate';

  @override
  String get seqNumber => 'seqNumber';

  @override
  String get precisionBits => 'precisionBits';

  @override
  String get expire => 'expire';

  @override
  String get lockedTo => 'lockedTo';

  @override
  String get description => 'desc';

  @override
  String get icon => 'icon';

  @override
  String get mac => 'mac';

  @override
  String get isLicensed => 'isLicensed';

  @override
  String get isUnmessagable => 'isUnmessagable';

  @override
  String get variant => 'variant';

  @override
  String get errorReason => 'errorReason';

  @override
  String get requestId => 'requestId';

  @override
  String get type => 'type';

  @override
  String get gpioMask => 'gpioMask';

  @override
  String get gpioValue => 'gpioValue';

  @override
  String get nodeId => 'nodeId';

  @override
  String get lastSentById => 'lastSentById';

  @override
  String get nodeBroadcastIntervalSecs => 'nodeBroadcastIntervalSecs';

  @override
  String get lastRxTime => 'lastRxTime';

  @override
  String get broadcastIntSecs => 'broadcastIntSecs';

  @override
  String get routeLen => 'routeLen';

  @override
  String get snrTowards => 'snrTowards';

  @override
  String get routeBackLen => 'routeBackLen';

  @override
  String get snrBack => 'snrBack';

  @override
  String get nonce => 'nonce';

  @override
  String get hash1 => 'hash1';

  @override
  String get hash2 => 'hash2';

  @override
  String get port => 'port';

  @override
  String get bytes => 'bytes';

  @override
  String get relativeHumidity => 'relativeHumidity';

  @override
  String get barometricPressure => 'barometricPressure';

  @override
  String get gasResistance => 'gasResistance';

  @override
  String get iaq => 'iaq';

  @override
  String get lux => 'lux';

  @override
  String get whiteLux => 'whiteLux';

  @override
  String get irLux => 'irLux';

  @override
  String get uvLux => 'uvLux';

  @override
  String get windDirection => 'windDirection';

  @override
  String get windSpeed => 'windSpeed';

  @override
  String get weight => 'weight';

  @override
  String get windGust => 'windGust';

  @override
  String get windLull => 'windLull';

  @override
  String get pm10Standard => 'pm10Standard';

  @override
  String get pm25Standard => 'pm25Standard';

  @override
  String get pm100Standard => 'pm100Standard';

  @override
  String get pm10Environmental => 'pm10Environmental';

  @override
  String get pm25Environmental => 'pm25Environmental';

  @override
  String get pm100Environmental => 'pm100Environmental';

  @override
  String get particles03um => 'particles03um';

  @override
  String get particles05um => 'particles05um';

  @override
  String get particles10um => 'particles10um';

  @override
  String get particles25um => 'particles25um';

  @override
  String get particles50um => 'particles50um';

  @override
  String get particles100um => 'particles100um';

  @override
  String get co2Temperature => 'co2Temperature';

  @override
  String get co2Humidity => 'co2Humidity';

  @override
  String get formaldehyde => 'formFormaldehyde';

  @override
  String get formaldehydeHumidity => 'formHumidity';

  @override
  String get formaldehydeTemperature => 'formTemperature';

  @override
  String get pm40Standard => 'pm40Standard';

  @override
  String get ch1Voltage => 'ch1Voltage';

  @override
  String get ch1Current => 'ch1Current';

  @override
  String get ch2Voltage => 'ch2Voltage';

  @override
  String get ch2Current => 'ch2Current';

  @override
  String get ch3Voltage => 'ch3Voltage';

  @override
  String get ch3Current => 'ch3Current';

  @override
  String get numPacketsTx => 'numPacketsTx';

  @override
  String get numPacketsRx => 'numPacketsRx';

  @override
  String get numPacketsRxBad => 'numPacketsRxBad';

  @override
  String get numOnlineNodes => 'numOnlineNodes';

  @override
  String get heartBpm => 'heartBpm';

  @override
  String get spO2 => 'spO2';

  @override
  String get freememBytes => 'freememBytes';

  @override
  String get diskfree1Bytes => 'diskfree1Bytes';

  @override
  String get diskfree2Bytes => 'diskfree2Bytes';

  @override
  String get diskfree3Bytes => 'diskfree3Bytes';

  @override
  String get load1 => 'load1';

  @override
  String get load5 => 'load5';

  @override
  String get load15 => 'load15';

  @override
  String get userString => 'userString';

  @override
  String get wifiPsk => 'wifiPsk';

  @override
  String get ntpServer => 'ntpServer';

  @override
  String get ethEnabled => 'ethEnabled';

  @override
  String get addressMode => 'addressMode';

  @override
  String get rsyslogServer => 'rsyslogServer';

  @override
  String get enabledProtocols => 'enabledProtocols';

  @override
  String get ipv6Enabled => 'ipv6Enabled';

  @override
  String get ip => 'ip';

  @override
  String get gateway => 'gateway';

  @override
  String get subnet => 'subnet';

  @override
  String get dns => 'dns';

  @override
  String get displaymode => 'displaymode';

  @override
  String get usePreset => 'usePreset';

  @override
  String get bandwidth => 'bandwidth';

  @override
  String get spreadFactor => 'spreadFactor';

  @override
  String get codingRate => 'codingRate';

  @override
  String get frequencyOffset => 'frequencyOffset';

  @override
  String get channelNum => 'channelNum';

  @override
  String get overrideDutyCycle => 'overrideDutyCycle';

  @override
  String get sx126xRxBoostedGain => 'sx126xRxBoostedGain';

  @override
  String get overrideFrequency => 'overrideFrequency';

  @override
  String get paFanDisabled => 'paFanDisabled';

  @override
  String get ignoreIncoming => 'ignoreIncoming';

  @override
  String get ignoreMqtt => 'ignoreMqtt';

  @override
  String get configOkToMqtt => 'configOkToMqtt';

  @override
  String get adminKeyCount => 'adminKeyCount';

  @override
  String get encryptionEnabled => 'encryptionEnabled';

  @override
  String get jsonEnabled => 'jsonEnabled';

  @override
  String get tlsEnabled => 'tlsEnabled';

  @override
  String get root => 'root';

  @override
  String get proxyToClientEnabled => 'proxyToClientEnabled';

  @override
  String get mapReportingEnabled => 'mapReportingEnabled';

  @override
  String get publishIntervalSecs => 'publishIntervalSecs';

  @override
  String get positionPrecision => 'positionPrecision';

  @override
  String get shouldReportLocation => 'shouldReportLocation';

  @override
  String get environmentMeasurementEnabled => 'environmentMeasurementEnabled';

  @override
  String get environmentScreenEnabled => 'environmentScreenEnabled';

  @override
  String get environmentDisplayFahrenheit => 'environmentDisplayFahrenheit';

  @override
  String get airQualityEnabled => 'airQualityEnabled';

  @override
  String get powerMeasurementEnabled => 'powerMeasurementEnabled';

  @override
  String get powerScreenEnabled => 'powerScreenEnabled';

  @override
  String get healthMeasurementEnabled => 'healthMeasurementEnabled';

  @override
  String get healthScreenEnabled => 'healthScreenEnabled';

  @override
  String get deviceTelemetryEnabled => 'deviceTelemetryEnabled';

  @override
  String get overrideConsoleSerialPort => 'overrideConsoleSerialPort';

  @override
  String get alertMessageVibra => 'alertMessageVibra';

  @override
  String get alertMessageBuzzer => 'alertMessageBuzzer';

  @override
  String get alertBellVibra => 'alertBellVibra';

  @override
  String get alertBellBuzzer => 'alertBellBuzzer';

  @override
  String get availablePinsCount => 'availablePinsCount';

  @override
  String get gpioPin => 'gpioPin';

  @override
  String get inputbrokerPinA => 'inputbrokerPinA';

  @override
  String get inputbrokerPinB => 'inputbrokerPinB';

  @override
  String get inputbrokerPinPress => 'inputbrokerPinPress';

  @override
  String get inputbrokerEventCw => 'inputbrokerEventCw';

  @override
  String get inputbrokerEventCcw => 'inputbrokerEventCcw';

  @override
  String get inputbrokerEventPress => 'inputbrokerEventPress';

  @override
  String get updown1Enabled => 'updown1Enabled';

  @override
  String get enabledDeprecated => 'enabled(deprecated)';

  @override
  String get minimumBroadcastSecs => 'minimumBroadcastSecs';

  @override
  String get detectionTriggerType => 'detectionTriggerType';

  @override
  String get lateFallbackEnabled => 'lateFallbackEnabled';

  @override
  String get fallbackTailPercent => 'fallbackTailPercent';

  @override
  String get milestonesEnabled => 'milestonesEnabled';

  @override
  String get perDestMinSpacingMs => 'perDestMinSpacingMs';

  @override
  String get maxActiveDm => 'maxActiveDm';

  @override
  String get probeFwplusNearDeadline => 'probeFwplusNearDeadline';

  @override
  String get allowedPorts => 'allowedPorts';

  @override
  String get localStatsOverMeshEnabled => 'localStatsOverMeshEnabled';

  @override
  String get localStatsExtendedOverMeshEnabled =>
      'localStatsExtendedOverMeshEnabled';

  @override
  String get additionalChutil => 'additionalChutil';

  @override
  String get additionalTxutil => 'additionalTxutil';

  @override
  String get additionalPoliteChannelPercent => 'additionalPoliteChannelPercent';

  @override
  String get additionalPoliteDutyCyclePercent =>
      'additionalPoliteDutyCyclePercent';

  @override
  String get currentTxUtilLimit => 'currentTxUtilLimit';

  @override
  String get currentMaxChannelUtilPercent => 'currentMaxChannelUtilPercent';

  @override
  String get currentPoliteChannelUtilPercent =>
      'currentPoliteChannelUtilPercent';

  @override
  String get currentPoliteDutyCyclePercent => 'currentPoliteDutyCyclePercent';

  @override
  String get autoRedirectTargetNodeId => 'autoRedirectTargetNodeId';

  @override
  String get telemetryLimiterEnabled => 'telemetryLimiterEnabled';

  @override
  String get telemetryLimiterPacketsPerMinute =>
      'telemetryLimiterPacketsPerMinute';

  @override
  String get telemetryLimiterAutoChanutilEnabled =>
      'telemetryLimiterAutoChanutilEnabled';

  @override
  String get telemetryLimiterAutoChanutilThreshold =>
      'telemetryLimiterAutoChanutilThreshold';

  @override
  String get positionLimiterEnabled => 'positionLimiterEnabled';

  @override
  String get positionLimiterTimeMinutesThreshold =>
      'positionLimiterTimeMinutesThreshold';

  @override
  String get opportunisticFloodingEnabled => 'opportunisticFloodingEnabled';

  @override
  String get opportunisticBaseDelayMs => 'opportunisticBaseDelayMs';

  @override
  String get opportunisticHopDelayMs => 'opportunisticHopDelayMs';

  @override
  String get opportunisticSnrGainMs => 'opportunisticSnrGainMs';

  @override
  String get opportunisticJitterMs => 'opportunisticJitterMs';

  @override
  String get opportunisticCancelOnFirstHear => 'opportunisticCancelOnFirstHear';

  @override
  String get opportunisticAuto => 'opportunisticAuto';

  @override
  String get version => 'version';

  @override
  String get screenBrightness => 'screenBrightness';

  @override
  String get screenTimeout => 'screenTimeout';

  @override
  String get screenLock => 'screenLock';

  @override
  String get settingsLock => 'settingsLock';

  @override
  String get pinCode => 'pinCode';

  @override
  String get theme => 'theme';

  @override
  String get alertEnabled => 'alertEnabled';

  @override
  String get bannerEnabled => 'bannerEnabled';

  @override
  String get ringToneId => 'ringToneId';

  @override
  String get language => 'language';

  @override
  String get compassMode => 'compassMode';

  @override
  String get screenRgbColor => 'screenRgbColor';

  @override
  String get isClockfaceAnalog => 'isClockfaceAnalog';

  @override
  String get gpsFormat => 'gpsFormat';

  @override
  String get calibrationDataLen => 'calibrationDataLen';

  @override
  String get filterEnabled => 'filterEnabled';

  @override
  String get minSnr => 'minSnr';

  @override
  String get hideIgnoredNodes => 'hideIgnoredNodes';

  @override
  String get highlightEnabled => 'highlightEnabled';

  @override
  String get zoom => 'zoom';

  @override
  String get centerLatI => 'centerLatI';

  @override
  String get centerLonI => 'centerLonI';

  @override
  String get followMe => 'followMe';

  @override
  String get psk => 'psk';

  @override
  String get uplinkEnabled => 'uplinkEnabled';

  @override
  String get downlinkEnabled => 'downlinkEnabled';

  @override
  String get ownerEditTitle => 'Edit Owner';

  @override
  String get ownerLongName => 'Long Name';

  @override
  String get ownerShortName => 'Short Name';

  @override
  String get ownerLongNameHint => 'e.g. Kevin Hester';

  @override
  String get ownerShortNameHint => 'e.g. KH';

  @override
  String get ownerLongNameHelper => 'Full name for this device';

  @override
  String get ownerShortNameHelper => 'Short name (max 4 characters)';

  @override
  String get ownerEditAtLeastOneName =>
      'Please provide at least one name (long or short)';

  @override
  String get ownerUpdateSuccess => 'Owner info updated successfully';

  @override
  String ownerUpdateFailed(Object error) {
    return 'Failed to update owner info: $error';
  }

  @override
  String get configHelpTitle => 'Configuration Help';

  @override
  String get readMoreDocumentation => 'Read more in documentation';

  @override
  String get editTooltip => 'Edit';

  @override
  String get deviceRoleLabel => 'Role';

  @override
  String get serialEnabledLabel => 'Serial Enabled';

  @override
  String get serialEnabledSubtitle => 'Deprecated upstream';

  @override
  String get buttonGpioLabel => 'Button GPIO';

  @override
  String get buzzerGpioLabel => 'Buzzer GPIO';

  @override
  String get rebroadcastModeLabel => 'Rebroadcast Mode';

  @override
  String get nodeInfoBroadcastIntervalLabel =>
      'Node Info Broadcast Interval (seconds)';

  @override
  String get nodeInfoBroadcastIntervalHint =>
      'How often to broadcast node info';

  @override
  String get doubleTapAsButtonPressLabel => 'Double Tap as Button Press';

  @override
  String get isManagedLabel => 'Is Managed';

  @override
  String get disableTripleClickLabel => 'Disable Triple Click';

  @override
  String get timezoneDefinitionLabel => 'Timezone Definition';

  @override
  String get timezoneDefinitionHint => 'e.g., PST8PDT,M3.2.0,M11.1.0';

  @override
  String get ledHeartbeatDisabledLabel => 'LED Heartbeat Disabled';

  @override
  String get buzzerModeLabel => 'Buzzer Mode';

  @override
  String get positionBroadcastIntervalLabel =>
      'Position Broadcast Interval (seconds)';

  @override
  String get smartPositionBroadcastLabel => 'Smart Position Broadcast';

  @override
  String get fixedPositionLabel => 'Fixed Position';

  @override
  String get gpsEnabledLabel => 'GPS Enabled';

  @override
  String get gpsUpdateIntervalLabel => 'GPS Update Interval (seconds)';

  @override
  String get gpsAttemptTimeLabel => 'GPS Attempt Time (seconds)';

  @override
  String get positionFlagsLabel => 'Position Flags';

  @override
  String get rxGpioLabel => 'RX GPIO';

  @override
  String get txGpioLabel => 'TX GPIO';

  @override
  String get smartBroadcastMinDistanceLabel => 'Smart Broadcast Min Distance';

  @override
  String get smartBroadcastMinIntervalLabel =>
      'Smart Broadcast Min Interval (seconds)';

  @override
  String get gpsEnableGpioLabel => 'GPS Enable GPIO';

  @override
  String get gpsModeLabel => 'GPS Mode';

  @override
  String get deviceRemoved => 'Device removed';

  @override
  String get undo => 'Undo';
}
