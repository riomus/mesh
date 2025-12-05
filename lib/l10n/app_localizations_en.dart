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
  String get sessionKeyRequested => 'Session key requested';

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
  String get save => 'Save';

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
  String get password => 'Password';

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
  String get serialEnabled => 'Serial Enabled';

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
  String get isManaged => 'Is Managed';

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
  String get screenOnSecs => 'Screen On Secs';

  @override
  String get autoScreenCarouselSecs => 'Auto Screen Carousel Secs';

  @override
  String get compassNorthTop => 'Compass North Top';

  @override
  String get flipScreen => 'Flip Screen';

  @override
  String get units => 'Units';

  @override
  String get oled => 'OLED';

  @override
  String get displayMode => 'Display Mode';

  @override
  String get headingBold => 'Heading Bold';

  @override
  String get wakeOnTapOrMotion => 'Wake On Tap Or Motion';

  @override
  String get compassOrientation => 'Compass Orientation';

  @override
  String get use12hClock => 'Use 12h Clock';

  @override
  String get useLongNodeName => 'Use Long Node Name';

  @override
  String get region => 'Region';

  @override
  String get modemPreset => 'Modem Preset';

  @override
  String get hopLimit => 'Hop Limit';

  @override
  String get txEnabled => 'TX Enabled';

  @override
  String get txPower => 'TX Power';

  @override
  String get enabled => 'Enabled';

  @override
  String get mode => 'Mode';

  @override
  String get fixedPin => 'Fixed PIN';

  @override
  String get publicKey => 'Public Key';

  @override
  String get privateKey => 'Private Key';

  @override
  String get adminKeys => 'Admin Keys';

  @override
  String get debugLogApiEnabled => 'Debug Log API Enabled';

  @override
  String get adminChannelEnabled => 'Admin Channel Enabled';

  @override
  String get address => 'Address';

  @override
  String get username => 'Username';

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
  String get deviceUpdateInterval => 'Device Update Interval';

  @override
  String get environmentUpdateInterval => 'Environment Update Interval';

  @override
  String get environmentMeasurement => 'Environment Measurement';

  @override
  String get environmentScreen => 'Environment Screen';

  @override
  String get airQuality => 'Air Quality';

  @override
  String get airQualityInterval => 'Air Quality Interval';

  @override
  String get powerMeasurement => 'Power Measurement';

  @override
  String get powerUpdateInterval => 'Power Update Interval';

  @override
  String get powerScreen => 'Power Screen';

  @override
  String get healthMeasurement => 'Health Measurement';

  @override
  String get healthUpdateInterval => 'Health Update Interval';

  @override
  String get healthScreen => 'Health Screen';

  @override
  String get deviceTelemetry => 'Device Telemetry';

  @override
  String get echo => 'Echo';

  @override
  String get rxd => 'RXD';

  @override
  String get txd => 'TXD';

  @override
  String get baud => 'Baud';

  @override
  String get timeout => 'Timeout';

  @override
  String get overrideConsole => 'Override Console';

  @override
  String get heartbeat => 'Heartbeat';

  @override
  String get records => 'Records';

  @override
  String get historyReturnMax => 'History Return Max';

  @override
  String get historyReturnWindow => 'History Return Window';

  @override
  String get isServer => 'Is Server';

  @override
  String get emitControlSignals => 'Emit Control Signals';

  @override
  String get sender => 'Sender';

  @override
  String get clearOnReboot => 'Clear on Reboot';

  @override
  String get outputMs => 'Output MS';

  @override
  String get output => 'Output';

  @override
  String get active => 'Active';

  @override
  String get alertMessage => 'Alert Message';

  @override
  String get alertBell => 'Alert Bell';

  @override
  String get usePwm => 'Use PWM';

  @override
  String get outputVibra => 'Output Vibra';

  @override
  String get outputBuzzer => 'Output Buzzer';

  @override
  String get nagTimeout => 'Nag Timeout';

  @override
  String get useI2sAsBuzzer => 'Use I2S as Buzzer';

  @override
  String get codec2Enabled => 'Codec2 Enabled';

  @override
  String get pttPin => 'PTT Pin';

  @override
  String get bitrate => 'Bitrate';

  @override
  String get i2sWs => 'I2S WS';

  @override
  String get i2sSd => 'I2S SD';

  @override
  String get i2sDin => 'I2S DIN';

  @override
  String get i2sSck => 'I2S SCK';

  @override
  String get updateInterval => 'Update Interval';

  @override
  String get transmitOverLora => 'Transmit Over LoRa';

  @override
  String get allowUndefinedPinAccess => 'Allow Undefined Pin Access';

  @override
  String get paxcounterUpdateInterval => 'Paxcounter Update Interval';

  @override
  String get wifiThreshold => 'WiFi Threshold';

  @override
  String get bleThreshold => 'BLE Threshold';

  @override
  String get rotary1Enabled => 'Rotary1 Enabled';

  @override
  String get inputBrokerPinA => 'Input Broker Pin A';

  @override
  String get inputBrokerPinB => 'Input Broker Pin B';

  @override
  String get inputBrokerPinPress => 'Input Broker Pin Press';

  @override
  String get upDown1Enabled => 'Up/Down 1 Enabled';

  @override
  String get allowInputSource => 'Allow Input Source';

  @override
  String get sendBell => 'Send Bell';

  @override
  String get ledState => 'LED State';

  @override
  String get current => 'Current';

  @override
  String get red => 'Red';

  @override
  String get green => 'Green';

  @override
  String get blue => 'Blue';

  @override
  String get minBroadcastSecs => 'Min Broadcast Secs';

  @override
  String get stateBroadcastSecs => 'State Broadcast Secs';

  @override
  String get monitorPin => 'Monitor Pin';

  @override
  String get triggerType => 'Trigger Type';

  @override
  String get usePullup => 'Use Pullup';

  @override
  String get ttlMinutes => 'TTL Minutes';

  @override
  String get initialDelayBaseMs => 'Initial Delay Base MS';

  @override
  String get retryBackoffMs => 'Retry Backoff MS';

  @override
  String get maxTries => 'Max Tries';

  @override
  String get degreeThreshold => 'Degree Threshold';

  @override
  String get dupThreshold => 'Dup Threshold';

  @override
  String get windowMs => 'Window MS';

  @override
  String get maxExtraHops => 'Max Extra Hops';

  @override
  String get jitterMs => 'Jitter MS';

  @override
  String get airtimeGuard => 'Airtime Guard';

  @override
  String get textStatus => 'Text Status';

  @override
  String get emoji => 'Emoji';

  @override
  String get snifferEnabled => 'Sniffer Enabled';

  @override
  String get doNotSendPrvOverMqtt => 'Do Not Send PRV Over MQTT';

  @override
  String get localStatsOverMesh => 'Local Stats Over Mesh';

  @override
  String get idlegameEnabled => 'Idle Game Enabled';

  @override
  String get autoResponderEnabled => 'Auto Responder Enabled';

  @override
  String get autoResponderText => 'Auto Responder Text';

  @override
  String get autoRedirectMessages => 'Auto Redirect Messages';

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
}
