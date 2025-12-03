import 'package:flutter/material.dart';
import '../models/device_state.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../l10n/app_localizations.dart';

class DeviceStateWidget extends StatelessWidget {
  final DeviceState state;

  const DeviceStateWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Device Configs - show all types
        _buildConfigSection(
          context,
          'Device Config',
          state.config?.device,
          (d) => _buildDeviceConfig(d),
        ),
        _buildConfigSection(
          context,
          'Position Config',
          state.config?.position,
          (p) => _buildPositionConfig(p),
        ),
        _buildConfigSection(
          context,
          'Power Config',
          state.config?.power,
          (p) => _buildPowerConfig(p),
        ),
        _buildConfigSection(
          context,
          'Network Config',
          state.config?.network,
          (n) => _buildNetworkConfig(n),
        ),
        _buildConfigSection(
          context,
          'Display Config',
          state.config?.display,
          (d) => _buildDisplayConfig(d),
        ),
        _buildConfigSection(
          context,
          'LoRa Config',
          state.config?.lora,
          (l) => _buildLoraConfig(l),
        ),
        _buildConfigSection(
          context,
          'Bluetooth Config',
          state.config?.bluetooth,
          (b) => _buildBluetoothConfig(b),
        ),
        _buildConfigSection(
          context,
          'Security Config',
          state.config?.security,
          (s) => _buildSecurityConfig(s),
        ),

        // Module Configs - show all types
        _buildConfigSection(
          context,
          'MQTT Config',
          state.moduleConfig?.mqtt,
          (m) => _buildMqttConfig(m),
        ),
        _buildConfigSection(
          context,
          'Telemetry Config',
          state.moduleConfig?.telemetry,
          (t) => _buildTelemetryConfig(t),
        ),
        _buildConfigSection(
          context,
          'Serial Config',
          state.moduleConfig?.serial,
          (s) => _buildSerialConfig(s),
        ),
        _buildConfigSection(
          context,
          'Store & Forward Config',
          state.moduleConfig?.storeForward,
          (sf) => _buildStoreForwardConfig(sf),
        ),
        _buildConfigSection(
          context,
          'Range Test Config',
          state.moduleConfig?.rangeTest,
          (rt) => _buildRangeTestConfig(rt),
        ),
        _buildConfigSection(
          context,
          'External Notification Config',
          state.moduleConfig?.externalNotification,
          (en) => _buildExternalNotificationConfig(en),
        ),
        _buildConfigSection(
          context,
          'Audio Config',
          state.moduleConfig?.audio,
          (a) => _buildAudioConfig(a),
        ),
        _buildConfigSection(
          context,
          'Neighbor Info Config',
          state.moduleConfig?.neighborInfo,
          (ni) => _buildNeighborInfoConfig(ni),
        ),
        _buildConfigSection(
          context,
          'Remote Hardware Config',
          state.moduleConfig?.remoteHardware,
          (rh) => _buildRemoteHardwareConfig(rh),
        ),
        _buildConfigSection(
          context,
          'Paxcounter Config',
          state.moduleConfig?.paxcounter,
          (pc) => _buildPaxcounterConfig(pc),
        ),
        _buildConfigSection(
          context,
          'Canned Message Config',
          state.moduleConfig?.cannedMessage,
          (cm) => _buildCannedMessageConfig(cm),
        ),
        _buildConfigSection(
          context,
          'Ambient Lighting Config',
          state.moduleConfig?.ambientLighting,
          (al) => _buildAmbientLightingConfig(al),
        ),
        _buildConfigSection(
          context,
          'Detection Sensor Config',
          state.moduleConfig?.detectionSensor,
          (ds) => _buildDetectionSensorConfig(ds),
        ),
        _buildConfigSection(
          context,
          'DTN Overlay Config',
          state.moduleConfig?.dtnOverlay,
          (dtn) => _buildDtnOverlayConfig(dtn),
        ),
        _buildConfigSection(
          context,
          'Broadcast Assist Config',
          state.moduleConfig?.broadcastAssist,
          (ba) => _buildBroadcastAssistConfig(ba),
        ),
        _buildConfigSection(
          context,
          'Node Mod Config',
          state.moduleConfig?.nodeMod,
          (nm) => _buildNodeModConfig(nm),
        ),
        _buildConfigSection(
          context,
          'Node Mod Admin Config',
          state.moduleConfig?.nodeModAdmin,
          (nma) => _buildNodeModAdminConfig(nma),
        ),
        _buildConfigSection(
          context,
          'Idle Game Config',
          state.moduleConfig?.idleGame,
          (ig) => _buildIdleGameConfig(ig),
        ),

        // Channels and Nodes
        if (state.channels.isNotEmpty)
          _Section(
            title: 'Channels',
            children: state.channels
                .map(
                  (c) => ListTile(
                    title: Text(() {
                      final name = c.settings?.name;
                      if (name != null && name.isNotEmpty) return name;
                      return c.index == 0 ? 'Default' : 'Channel ${c.index}';
                    }()),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      ).roleWithRole(c.role ?? "UNKNOWN"),
                    ),
                  ),
                )
                .toList(),
          ),
        if (state.nodes.isNotEmpty)
          _Section(
            title: AppLocalizations.of(
              context,
            ).nodesWithCount(state.nodes.length),
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context).knownNodes),
                subtitle: Text(
                  state.nodes.map((n) => n.user?.shortName ?? n.num).join(', '),
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Helper to build config section with fallback for missing configs
  Widget _buildConfigSection<T>(
    BuildContext context,
    String title,
    T? config,
    List<Widget> Function(T) builder,
  ) {
    return _Section(
      title: title,
      children: config != null
          ? builder(config)
          : [
              ListTile(
                dense: true,
                title: Text(AppLocalizations.of(context).notConfigured),
                subtitle: Text(
                  AppLocalizations.of(context).noConfigurationData,
                ),
              ),
            ],
    );
  }

  List<Widget> _buildDeviceConfig(DeviceConfigDto device) {
    return [
      _kv('Role', device.role),
      _kv('Serial Enabled', device.serialEnabled),
      _kv('Button GPIO', device.buttonGpio),
      _kv('Buzzer GPIO', device.buzzerGpio),
      _kv('Rebroadcast Mode', device.rebroadcastMode),
      _kv('Node Info Broadcast Secs', device.nodeInfoBroadcastSecs),
      _kv('Double Tap As Button Press', device.doubleTapAsButtonPress),
      _kv('Is Managed', device.isManaged),
      _kv('Disable Triple Click', device.disableTripleClick),
      _kv('Timezone', device.tzdef),
      _kv('LED Heartbeat Disabled', device.ledHeartbeatDisabled),
      _kv('Buzzer Mode', device.buzzerMode),
    ];
  }

  List<Widget> _buildPositionConfig(PositionConfigDto position) {
    return [
      _kv('Position Broadcast Secs', position.positionBroadcastSecs),
      _kv(
        'Position Broadcast Smart Enabled',
        position.positionBroadcastSmartEnabled,
      ),
      _kv('Fixed Position', position.fixedPosition),
      _kv('GPS Enabled', position.gpsEnabled),
      _kv('GPS Update Interval', position.gpsUpdateInterval),
      _kv('GPS Attempt Time', position.gpsAttemptTime),
      _kv('Position Flags', position.positionFlags),
      _kv('RX GPIO', position.rxGpio),
      _kv('TX GPIO', position.txGpio),
      _kv(
        'Broadcast Smart Minimum Distance',
        position.broadcastSmartMinimumDistance,
      ),
      _kv(
        'Broadcast Smart Minimum Interval Secs',
        position.broadcastSmartMinimumIntervalSecs,
      ),
      _kv('GPS Enable GPIO', position.gpsEnGpio),
      _kv('GPS Mode', position.gpsMode),
    ];
  }

  List<Widget> _buildPowerConfig(PowerConfigDto power) {
    return [
      _kv('Is Power Saving', power.isPowerSaving),
      _kv('On Battery Shutdown After Secs', power.onBatteryShutdownAfterSecs),
      _kv('ADC Multiplier Override', power.adcMultiplierOverride),
      _kv('Wait Bluetooth Secs', power.waitBluetoothSecs),
      _kv('SDS Secs', power.sdsSecs),
      _kv('LS Secs', power.lsSecs),
      _kv('Min Wake Secs', power.minWakeSecs),
      _kv('Device Battery INA Address', power.deviceBatteryInaAddress),
      _kv('Powermon Enables', power.powermonEnables),
    ];
  }

  List<Widget> _buildDisplayConfig(DisplayConfigDto display) {
    return [
      _kv('Screen On Secs', display.screenOnSecs),
      _kv('Auto Screen Carousel Secs', display.autoScreenCarouselSecs),
      _kv('Compass North Top', display.compassNorthTop),
      _kv('Flip Screen', display.flipScreen),
      _kv('Units', display.units),
      _kv('OLED', display.oled),
      _kv('Display Mode', display.displaymode),
      _kv('Heading Bold', display.headingBold),
      _kv('Wake On Tap Or Motion', display.wakeOnTapOrMotion),
      _kv('Compass Orientation', display.compassOrientation),
      _kv('Use 12h Clock', display.use12hClock),
      _kv('Use Long Node Name', display.useLongNodeName),
    ];
  }

  List<Widget> _buildBluetoothConfig(BluetoothConfigDto bluetooth) {
    return [
      _kv('Enabled', bluetooth.enabled),
      _kv('Mode', bluetooth.mode),
      _kv('Fixed PIN', bluetooth.fixedPin),
    ];
  }

  List<Widget> _buildSecurityConfig(SecurityConfigDto security) {
    return [
      _kv('Public Key', security.publicKey != null ? '***' : null),
      _kv('Private Key', security.privateKey != null ? '***' : null),
      _kv('Admin Keys', security.adminKey?.length),
      _kv('Is Managed', security.isManaged),
      _kv('Serial Enabled', security.serialEnabled),
      _kv('Debug Log API Enabled', security.debugLogApiEnabled),
      _kv('Admin Channel Enabled', security.adminChannelEnabled),
    ];
  }

  List<Widget> _buildLoraConfig(LoRaConfigDto lora) {
    return [
      _kv('Region', lora.region),
      _kv('Modem Preset', lora.modemPreset),
      _kv('Hop Limit', lora.hopLimit),
      _kv('TX Enabled', lora.txEnabled),
      _kv('TX Power', lora.txPower),
    ];
  }

  List<Widget> _buildNetworkConfig(NetworkConfigDto net) {
    return [
      _kv('WiFi Enabled', net.wifiEnabled),
      _kv('WiFi SSID', net.wifiSsid),
    ];
  }

  List<Widget> _buildMqttConfig(MqttConfigDto mqtt) {
    return [
      _kv('MQTT Enabled', mqtt.enabled),
      _kv('Address', mqtt.address),
      _kv('Username', mqtt.username),
      _kv('Encryption', mqtt.encryptionEnabled),
      _kv('JSON', mqtt.jsonEnabled),
      _kv('TLS', mqtt.tlsEnabled),
      _kv('Root Topic', mqtt.root),
      _kv('Proxy to Client', mqtt.proxyToClientEnabled),
      _kv('Map Reporting', mqtt.mapReportingEnabled),
    ];
  }

  List<Widget> _buildTelemetryConfig(TelemetryConfigDto tel) {
    return [
      _kv('Device Update Interval', tel.deviceUpdateInterval),
      _kv('Environment Update Interval', tel.environmentUpdateInterval),
      _kv('Environment Measurement', tel.environmentMeasurementEnabled),
      _kv('Environment Screen', tel.environmentScreenEnabled),
      _kv('Air Quality', tel.airQualityEnabled),
      _kv('Air Quality Interval', tel.airQualityInterval),
      _kv('Power Measurement', tel.powerMeasurementEnabled),
      _kv('Power Update Interval', tel.powerUpdateInterval),
      _kv('Power Screen', tel.powerScreenEnabled),
      _kv('Health Measurement', tel.healthMeasurementEnabled),
      _kv('Health Update Interval', tel.healthUpdateInterval),
      _kv('Health Screen', tel.healthScreenEnabled),
      _kv('Device Telemetry', tel.deviceTelemetryEnabled),
    ];
  }

  List<Widget> _buildSerialConfig(SerialConfigDto serial) {
    return [
      _kv('Serial Enabled', serial.enabled),
      _kv('Echo', serial.echo),
      _kv('RXD', serial.rxd),
      _kv('TXD', serial.txd),
      _kv('Baud', serial.baud),
      _kv('Timeout', serial.timeout),
      _kv('Mode', serial.mode),
      _kv('Override Console', serial.overrideConsoleSerialPort),
    ];
  }

  List<Widget> _buildStoreForwardConfig(StoreForwardConfigDto sf) {
    return [
      _kv('Store & Forward Enabled', sf.enabled),
      _kv('Heartbeat', sf.heartbeat),
      _kv('Records', sf.records),
      _kv('History Return Max', sf.historyReturnMax),
      _kv('History Return Window', sf.historyReturnWindow),
      _kv('Is Server', sf.isServer),
      _kv('Emit Control Signals', sf.emitControlSignals),
    ];
  }

  List<Widget> _buildRangeTestConfig(RangeTestConfigDto rt) {
    return [
      _kv('Range Test Enabled', rt.enabled),
      _kv('Sender', rt.sender),
      _kv('Save', rt.save),
      _kv('Clear on Reboot', rt.clearOnReboot),
    ];
  }

  List<Widget> _buildExternalNotificationConfig(
    ExternalNotificationConfigDto en,
  ) {
    return [
      _kv('Ext Notification Enabled', en.enabled),
      _kv('Output MS', en.outputMs),
      _kv('Output', en.output),
      _kv('Active', en.active),
      _kv('Alert Message', en.alertMessage),
      _kv('Alert Bell', en.alertBell),
      _kv('Use PWM', en.usePwm),
      _kv('Output Vibra', en.outputVibra),
      _kv('Output Buzzer', en.outputBuzzer),
      _kv('Nag Timeout', en.nagTimeout),
      _kv('Use I2S as Buzzer', en.useI2sAsBuzzer),
    ];
  }

  List<Widget> _buildAudioConfig(AudioConfigDto audio) {
    return [
      _kv('Codec2 Enabled', audio.codec2Enabled),
      _kv('PTT Pin', audio.pttPin),
      _kv('Bitrate', audio.bitrate),
      _kv('I2S WS', audio.i2sWs),
      _kv('I2S SD', audio.i2sSd),
      _kv('I2S DIN', audio.i2sDin),
      _kv('I2S SCK', audio.i2sSck),
    ];
  }

  List<Widget> _buildNeighborInfoConfig(NeighborInfoConfigDto ni) {
    return [
      _kv('Neighbor Info Enabled', ni.enabled),
      _kv('Update Interval', ni.updateInterval),
      _kv('Transmit Over LoRa', ni.transmitOverLora),
    ];
  }

  List<Widget> _buildRemoteHardwareConfig(RemoteHardwareConfigDto rh) {
    return [
      _kv('Remote Hardware Enabled', rh.enabled),
      _kv('Allow Undefined Pin Access', rh.allowUndefinedPinAccess),
      if (rh.availablePins != null)
        ...rh.availablePins!.map(
          (p) => _kv(
            'Pin ${p.gpioPin} ${p.name != null ? "(${p.name})" : ""}',
            p.type,
          ),
        ),
    ];
  }

  List<Widget> _buildPaxcounterConfig(PaxcounterConfigDto pc) {
    return [
      _kv('Paxcounter Enabled', pc.enabled),
      _kv('Update Interval', pc.paxcounterUpdateInterval),
      _kv('WiFi Threshold', pc.wifiThreshold),
      _kv('BLE Threshold', pc.bleThreshold),
    ];
  }

  List<Widget> _buildCannedMessageConfig(CannedMessageConfigDto cm) {
    return [
      _kv('Rotary1 Enabled', cm.rotary1Enabled),
      _kv('Input Broker Pin A', cm.inputbrokerPinA),
      _kv('Input Broker Pin B', cm.inputbrokerPinB),
      _kv('Input Broker Pin Press', cm.inputbrokerPinPress),
      _kv('Up/Down 1 Enabled', cm.updown1Enabled),
      _kv('Allow Input Source', cm.allowInputSource),
      _kv('Send Bell', cm.sendBell),
    ];
  }

  List<Widget> _buildAmbientLightingConfig(AmbientLightingConfigDto al) {
    return [
      _kv('LED State', al.ledState),
      _kv('Current', al.current),
      _kv('Red', al.red),
      _kv('Green', al.green),
      _kv('Blue', al.blue),
    ];
  }

  List<Widget> _buildDetectionSensorConfig(DetectionSensorConfigDto ds) {
    return [
      _kv('Detection Sensor Enabled', ds.enabled),
      _kv('Min Broadcast Secs', ds.minimumBroadcastSecs),
      _kv('State Broadcast Secs', ds.stateBroadcastSecs),
      _kv('Send Bell', ds.sendBell),
      _kv('Name', ds.name),
      _kv('Monitor Pin', ds.monitorPin),
      _kv('Trigger Type', ds.detectionTriggerType),
      _kv('Use Pullup', ds.usePullup),
    ];
  }

  List<Widget> _buildDtnOverlayConfig(DtnOverlayConfigDto dtn) {
    return [
      _kv('DTN Enabled', dtn.enabled),
      _kv('TTL Minutes', dtn.ttlMinutes),
      _kv('Initial Delay Base MS', dtn.initialDelayBaseMs),
      _kv('Retry Backoff MS', dtn.retryBackoffMs),
      _kv('Max Tries', dtn.maxTries),
    ];
  }

  List<Widget> _buildBroadcastAssistConfig(BroadcastAssistConfigDto ba) {
    return [
      _kv('Broadcast Assist Enabled', ba.enabled),
      _kv('Degree Threshold', ba.degreeThreshold),
      _kv('Dup Threshold', ba.dupThreshold),
      _kv('Window MS', ba.windowMs),
      _kv('Max Extra Hops', ba.maxExtraHops),
      _kv('Jitter MS', ba.jitterMs),
      _kv('Airtime Guard', ba.airtimeGuard),
    ];
  }

  List<Widget> _buildNodeModConfig(NodeModConfigDto nm) {
    return [_kv('Text Status', nm.textStatus), _kv('Emoji', nm.emoji)];
  }

  List<Widget> _buildNodeModAdminConfig(NodeModAdminConfigDto nma) {
    return [
      _kv('Sniffer Enabled', nma.snifferEnabled),
      _kv('Do Not Send PRV Over MQTT', nma.doNotSendPrvOverMqtt),
      _kv('Local Stats Over Mesh', nma.localStatsOverMeshEnabled),
      _kv('Idle Game Enabled', nma.idlegameEnabled),
      _kv('Auto Responder Enabled', nma.autoResponderEnabled),
      _kv('Auto Responder Text', nma.autoResponderText),
      _kv('Auto Redirect Messages', nma.autoRedirectMessages),
      _kv('Auto Redirect Target', nma.autoRedirectTargetNodeId),
      _kv('Telemetry Limiter', nma.telemetryLimiterEnabled),
      _kv('Position Limiter', nma.positionLimiterEnabled),
      _kv('Opportunistic Flooding', nma.opportunisticFloodingEnabled),
    ];
  }

  List<Widget> _buildIdleGameConfig(IdleGameConfigDto ig) {
    return [_kv('Idle Game Variant', ig.variant)];
  }

  Widget _kv(String key, Object? value) {
    return ListTile(
      dense: true,
      title: Text(key),
      subtitle: Text(value?.toString() ?? 'N/A'),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Text(title),
        initiallyExpanded: false,
        children: children,
      ),
    );
  }
}
