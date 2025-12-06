import 'package:flutter/material.dart';
import '../models/device_state.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../l10n/app_localizations.dart';
import '../utils/text_sanitize.dart';

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
          AppLocalizations.of(context).deviceConfig,
          state.config?.device,
          (d) => _buildDeviceConfig(context, d),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).positionConfig,
          state.config?.position,
          (p) => _buildPositionConfig(context, p),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).powerConfig,
          state.config?.power,
          (p) => _buildPowerConfig(context, p),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).networkConfig,
          state.config?.network,
          (n) => _buildNetworkConfig(context, n),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).displayConfig,
          state.config?.display,
          (d) => _buildDisplayConfig(context, d),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).loraConfig,
          state.config?.lora,
          (l) => _buildLoraConfig(context, l),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).bluetoothConfig,
          state.config?.bluetooth,
          (b) => _buildBluetoothConfig(context, b),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).securityConfig,
          state.config?.security,
          (s) => _buildSecurityConfig(context, s),
        ),

        // Module Configs - show all types
        _buildConfigSection(
          context,
          AppLocalizations.of(context).mqttConfig,
          state.moduleConfig?.mqtt,
          (m) => _buildMqttConfig(context, m),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).telemetryConfig,
          state.moduleConfig?.telemetry,
          (t) => _buildTelemetryConfig(context, t),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).serialConfig,
          state.moduleConfig?.serial,
          (s) => _buildSerialConfig(context, s),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).storeForwardConfig,
          state.moduleConfig?.storeForward,
          (sf) => _buildStoreForwardConfig(context, sf),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).rangeTestConfig,
          state.moduleConfig?.rangeTest,
          (rt) => _buildRangeTestConfig(context, rt),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).externalNotificationConfig,
          state.moduleConfig?.externalNotification,
          (en) => _buildExternalNotificationConfig(context, en),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).audioConfig,
          state.moduleConfig?.audio,
          (a) => _buildAudioConfig(context, a),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).neighborInfoConfig,
          state.moduleConfig?.neighborInfo,
          (ni) => _buildNeighborInfoConfig(context, ni),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).remoteHardwareConfig,
          state.moduleConfig?.remoteHardware,
          (rh) => _buildRemoteHardwareConfig(context, rh),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).paxcounterConfig,
          state.moduleConfig?.paxcounter,
          (pc) => _buildPaxcounterConfig(context, pc),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).cannedMessageConfig,
          state.moduleConfig?.cannedMessage,
          (cm) => _buildCannedMessageConfig(context, cm),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).ambientLightingConfig,
          state.moduleConfig?.ambientLighting,
          (al) => _buildAmbientLightingConfig(context, al),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).detectionSensorConfig,
          state.moduleConfig?.detectionSensor,
          (ds) => _buildDetectionSensorConfig(context, ds),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).dtnOverlayConfig,
          state.moduleConfig?.dtnOverlay,
          (dtn) => _buildDtnOverlayConfig(context, dtn),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).broadcastAssistConfig,
          state.moduleConfig?.broadcastAssist,
          (ba) => _buildBroadcastAssistConfig(context, ba),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).nodeModConfig,
          state.moduleConfig?.nodeMod,
          (nm) => _buildNodeModConfig(context, nm),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).nodeModAdminConfig,
          state.moduleConfig?.nodeModAdmin,
          (nma) => _buildNodeModAdminConfig(context, nma),
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).idleGameConfig,
          state.moduleConfig?.idleGame,
          (ig) => _buildIdleGameConfig(context, ig),
        ),

        // Channels and Nodes
        if (state.channels.isNotEmpty)
          _Section(
            title: AppLocalizations.of(context).channels,
            children: state.channels
                .map(
                  (c) => ListTile(
                    title: Text(() {
                      final name = c.settings?.name;
                      if (name != null && name.isNotEmpty) return name;
                      return safeText(
                        c.index == 0
                            ? AppLocalizations.of(context).defaultChannel
                            : '${AppLocalizations.of(context).channel} ${c.index}',
                      );
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
                  safeText(
                    state.nodes
                        .map((n) => n.user?.shortName ?? n.num)
                        .join(', '),
                  ),
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

  List<Widget> _buildDeviceConfig(
    BuildContext context,
    DeviceConfigDto device,
  ) {
    return [
      _kv(AppLocalizations.of(context).role, device.role),
      _kv(AppLocalizations.of(context).serialEnabled, device.serialEnabled),
      _kv(AppLocalizations.of(context).buttonGpio, device.buttonGpio),
      _kv(AppLocalizations.of(context).buzzerGpio, device.buzzerGpio),
      _kv(AppLocalizations.of(context).rebroadcastMode, device.rebroadcastMode),
      _kv(
        AppLocalizations.of(context).nodeInfoBroadcastSecs,
        device.nodeInfoBroadcastSecs,
      ),
      _kv(
        AppLocalizations.of(context).doubleTapAsButtonPress,
        device.doubleTapAsButtonPress,
      ),
      _kv(AppLocalizations.of(context).isManaged, device.isManaged),
      _kv(
        AppLocalizations.of(context).disableTripleClick,
        device.disableTripleClick,
      ),
      _kv(AppLocalizations.of(context).timezone, device.tzdef),
      _kv(
        AppLocalizations.of(context).ledHeartbeatDisabled,
        device.ledHeartbeatDisabled,
      ),
      _kv(AppLocalizations.of(context).buzzerMode, device.buzzerMode),
    ];
  }

  List<Widget> _buildPositionConfig(
    BuildContext context,
    PositionConfigDto position,
  ) {
    return [
      _kv(
        AppLocalizations.of(context).positionBroadcastSecs,
        position.positionBroadcastSecs,
      ),
      _kv(
        AppLocalizations.of(context).positionBroadcastSmartEnabled,
        position.positionBroadcastSmartEnabled,
      ),
      _kv(AppLocalizations.of(context).fixedPosition, position.fixedPosition),
      _kv(AppLocalizations.of(context).gpsEnabled, position.gpsEnabled),
      _kv(
        AppLocalizations.of(context).gpsUpdateInterval,
        position.gpsUpdateInterval,
      ),
      _kv(AppLocalizations.of(context).gpsAttemptTime, position.gpsAttemptTime),
      _kv(AppLocalizations.of(context).positionFlags, position.positionFlags),
      _kv(AppLocalizations.of(context).rxGpio, position.rxGpio),
      _kv(AppLocalizations.of(context).txGpio, position.txGpio),
      _kv(
        AppLocalizations.of(context).broadcastSmartMinimumDistance,
        position.broadcastSmartMinimumDistance,
      ),
      _kv(
        AppLocalizations.of(context).broadcastSmartMinimumIntervalSecs,
        position.broadcastSmartMinimumIntervalSecs,
      ),
      _kv(AppLocalizations.of(context).gpsEnableGpio, position.gpsEnGpio),
      _kv(AppLocalizations.of(context).gpsMode, position.gpsMode),
    ];
  }

  List<Widget> _buildPowerConfig(BuildContext context, PowerConfigDto power) {
    return [
      _kv(AppLocalizations.of(context).isPowerSaving, power.isPowerSaving),
      _kv(
        AppLocalizations.of(context).onBatteryShutdownAfterSecs,
        power.onBatteryShutdownAfterSecs,
      ),
      _kv(
        AppLocalizations.of(context).adcMultiplierOverride,
        power.adcMultiplierOverride,
      ),
      _kv(
        AppLocalizations.of(context).waitBluetoothSecs,
        power.waitBluetoothSecs,
      ),
      _kv(AppLocalizations.of(context).sdsSecs, power.sdsSecs),
      _kv(AppLocalizations.of(context).lsSecs, power.lsSecs),
      _kv(AppLocalizations.of(context).minWakeSecs, power.minWakeSecs),
      _kv(
        AppLocalizations.of(context).deviceBatteryInaAddress,
        power.deviceBatteryInaAddress,
      ),
      _kv(AppLocalizations.of(context).powermonEnables, power.powermonEnables),
    ];
  }

  List<Widget> _buildDisplayConfig(
    BuildContext context,
    DisplayConfigDto display,
  ) {
    return [
      _kv(AppLocalizations.of(context).screenOnSecs, display.screenOnSecs),
      _kv(
        AppLocalizations.of(context).autoScreenCarouselSecs,
        display.autoScreenCarouselSecs,
      ),
      _kv(
        AppLocalizations.of(context).compassNorthTop,
        display.compassNorthTop,
      ),
      _kv(AppLocalizations.of(context).flipScreen, display.flipScreen),
      _kv(AppLocalizations.of(context).units, display.units),
      _kv(AppLocalizations.of(context).oled, display.oled),
      _kv(AppLocalizations.of(context).displayMode, display.displaymode),
      _kv(AppLocalizations.of(context).headingBold, display.headingBold),
      _kv(
        AppLocalizations.of(context).wakeOnTapOrMotion,
        display.wakeOnTapOrMotion,
      ),
      _kv(
        AppLocalizations.of(context).compassOrientation,
        display.compassOrientation,
      ),
      _kv(AppLocalizations.of(context).use12hClock, display.use12hClock),
      _kv(
        AppLocalizations.of(context).useLongNodeName,
        display.useLongNodeName,
      ),
    ];
  }

  List<Widget> _buildBluetoothConfig(
    BuildContext context,
    BluetoothConfigDto bluetooth,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, bluetooth.enabled),
      _kv(AppLocalizations.of(context).mode, bluetooth.mode),
      _kv(AppLocalizations.of(context).fixedPin, bluetooth.fixedPin),
    ];
  }

  List<Widget> _buildSecurityConfig(
    BuildContext context,
    SecurityConfigDto security,
  ) {
    return [
      _kv(
        AppLocalizations.of(context).publicKey,
        security.publicKey != null ? '***' : null,
      ),
      _kv(
        AppLocalizations.of(context).privateKey,
        security.privateKey != null ? '***' : null,
      ),
      _kv(AppLocalizations.of(context).adminKeys, security.adminKey?.length),
      _kv(AppLocalizations.of(context).isManaged, security.isManaged),
      _kv(AppLocalizations.of(context).serialEnabled, security.serialEnabled),
      _kv(
        AppLocalizations.of(context).debugLogApiEnabled,
        security.debugLogApiEnabled,
      ),
      _kv(
        AppLocalizations.of(context).adminChannelEnabled,
        security.adminChannelEnabled,
      ),
    ];
  }

  List<Widget> _buildLoraConfig(BuildContext context, LoRaConfigDto lora) {
    return [
      _kv(AppLocalizations.of(context).region, lora.region),
      _kv(AppLocalizations.of(context).modemPreset, lora.modemPreset),
      _kv(AppLocalizations.of(context).hopLimit, lora.hopLimit),
      _kv(AppLocalizations.of(context).txEnabled, lora.txEnabled),
      _kv(AppLocalizations.of(context).txPower, lora.txPower),
    ];
  }

  List<Widget> _buildNetworkConfig(BuildContext context, NetworkConfigDto net) {
    return [
      _kv(AppLocalizations.of(context).wifiEnabled, net.wifiEnabled),
      _kv(AppLocalizations.of(context).wifiSsid, net.wifiSsid),
    ];
  }

  List<Widget> _buildMqttConfig(BuildContext context, MqttConfigDto mqtt) {
    return [
      _kv(AppLocalizations.of(context).enabled, mqtt.enabled),
      _kv(AppLocalizations.of(context).address, mqtt.address),
      _kv(AppLocalizations.of(context).username, mqtt.username),
      _kv(AppLocalizations.of(context).encryption, mqtt.encryptionEnabled),
      _kv(AppLocalizations.of(context).json, mqtt.jsonEnabled),
      _kv(AppLocalizations.of(context).tls, mqtt.tlsEnabled),
      _kv(AppLocalizations.of(context).rootTopic, mqtt.root),
      _kv(
        AppLocalizations.of(context).proxyToClient,
        mqtt.proxyToClientEnabled,
      ),
      _kv(AppLocalizations.of(context).mapReporting, mqtt.mapReportingEnabled),
    ];
  }

  List<Widget> _buildTelemetryConfig(
    BuildContext context,
    TelemetryConfigDto tel,
  ) {
    return [
      _kv(
        AppLocalizations.of(context).deviceUpdateInterval,
        tel.deviceUpdateInterval,
      ),
      _kv(
        AppLocalizations.of(context).environmentUpdateInterval,
        tel.environmentUpdateInterval,
      ),
      _kv(
        AppLocalizations.of(context).environmentMeasurement,
        tel.environmentMeasurementEnabled,
      ),
      _kv(
        AppLocalizations.of(context).environmentScreen,
        tel.environmentScreenEnabled,
      ),
      _kv(AppLocalizations.of(context).airQuality, tel.airQualityEnabled),
      _kv(
        AppLocalizations.of(context).airQualityInterval,
        tel.airQualityInterval,
      ),
      _kv(
        AppLocalizations.of(context).powerMeasurement,
        tel.powerMeasurementEnabled,
      ),
      _kv(
        AppLocalizations.of(context).powerUpdateInterval,
        tel.powerUpdateInterval,
      ),
      _kv(AppLocalizations.of(context).powerScreen, tel.powerScreenEnabled),
      _kv(
        AppLocalizations.of(context).healthMeasurement,
        tel.healthMeasurementEnabled,
      ),
      _kv(
        AppLocalizations.of(context).healthUpdateInterval,
        tel.healthUpdateInterval,
      ),
      _kv(AppLocalizations.of(context).healthScreen, tel.healthScreenEnabled),
      _kv(
        AppLocalizations.of(context).deviceTelemetry,
        tel.deviceTelemetryEnabled,
      ),
    ];
  }

  List<Widget> _buildSerialConfig(
    BuildContext context,
    SerialConfigDto serial,
  ) {
    return [
      _kv(AppLocalizations.of(context).serialEnabled, serial.enabled),
      _kv(AppLocalizations.of(context).echo, serial.echo),
      _kv(AppLocalizations.of(context).rxd, serial.rxd),
      _kv(AppLocalizations.of(context).txd, serial.txd),
      _kv(AppLocalizations.of(context).baud, serial.baud),
      _kv(AppLocalizations.of(context).timeout, serial.timeout),
      _kv(AppLocalizations.of(context).mode, serial.mode),
      _kv(
        AppLocalizations.of(context).overrideConsole,
        serial.overrideConsoleSerialPort,
      ),
    ];
  }

  List<Widget> _buildStoreForwardConfig(
    BuildContext context,
    StoreForwardConfigDto sf,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, sf.enabled),
      _kv(AppLocalizations.of(context).heartbeat, sf.heartbeat),
      _kv(AppLocalizations.of(context).records, sf.records),
      _kv(AppLocalizations.of(context).historyReturnMax, sf.historyReturnMax),
      _kv(
        AppLocalizations.of(context).historyReturnWindow,
        sf.historyReturnWindow,
      ),
      _kv(AppLocalizations.of(context).isServer, sf.isServer),
      _kv(
        AppLocalizations.of(context).emitControlSignals,
        sf.emitControlSignals,
      ),
    ];
  }

  List<Widget> _buildRangeTestConfig(
    BuildContext context,
    RangeTestConfigDto rt,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, rt.enabled),
      _kv(AppLocalizations.of(context).sender, rt.sender),
      _kv(AppLocalizations.of(context).save, rt.save),
      _kv(AppLocalizations.of(context).clearOnReboot, rt.clearOnReboot),
    ];
  }

  List<Widget> _buildExternalNotificationConfig(
    BuildContext context,
    ExternalNotificationConfigDto en,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, en.enabled),
      _kv(AppLocalizations.of(context).outputMs, en.outputMs),
      _kv(AppLocalizations.of(context).output, en.output),
      _kv(AppLocalizations.of(context).active, en.active),
      _kv(AppLocalizations.of(context).alertMessage, en.alertMessage),
      _kv(AppLocalizations.of(context).alertBell, en.alertBell),
      _kv(AppLocalizations.of(context).usePwm, en.usePwm),
      _kv(AppLocalizations.of(context).outputVibra, en.outputVibra),
      _kv(AppLocalizations.of(context).outputBuzzer, en.outputBuzzer),
      _kv(AppLocalizations.of(context).nagTimeout, en.nagTimeout),
      _kv(AppLocalizations.of(context).useI2sAsBuzzer, en.useI2sAsBuzzer),
    ];
  }

  List<Widget> _buildAudioConfig(BuildContext context, AudioConfigDto audio) {
    return [
      _kv(AppLocalizations.of(context).codec2Enabled, audio.codec2Enabled),
      _kv(AppLocalizations.of(context).pttPin, audio.pttPin),
      _kv(AppLocalizations.of(context).bitrate, audio.bitrate),
      _kv(AppLocalizations.of(context).i2sWs, audio.i2sWs),
      _kv(AppLocalizations.of(context).i2sSd, audio.i2sSd),
      _kv(AppLocalizations.of(context).i2sDin, audio.i2sDin),
      _kv(AppLocalizations.of(context).i2sSck, audio.i2sSck),
    ];
  }

  List<Widget> _buildNeighborInfoConfig(
    BuildContext context,
    NeighborInfoConfigDto ni,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, ni.enabled),
      _kv(AppLocalizations.of(context).updateInterval, ni.updateInterval),
      _kv(AppLocalizations.of(context).transmitOverLora, ni.transmitOverLora),
    ];
  }

  List<Widget> _buildRemoteHardwareConfig(
    BuildContext context,
    RemoteHardwareConfigDto rh,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, rh.enabled),
      _kv(
        AppLocalizations.of(context).allowUndefinedPinAccess,
        rh.allowUndefinedPinAccess,
      ),
      if (rh.availablePins != null)
        ...rh.availablePins!.map(
          (p) => _kv(
            'Pin ${p.gpioPin} ${p.name != null ? "(${p.name})" : ""}',
            p.type,
          ),
        ),
    ];
  }

  List<Widget> _buildPaxcounterConfig(
    BuildContext context,
    PaxcounterConfigDto pc,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, pc.enabled),
      _kv(
        AppLocalizations.of(context).paxcounterUpdateInterval,
        pc.paxcounterUpdateInterval,
      ),
      _kv(AppLocalizations.of(context).wifiThreshold, pc.wifiThreshold),
      _kv(AppLocalizations.of(context).bleThreshold, pc.bleThreshold),
    ];
  }

  List<Widget> _buildCannedMessageConfig(
    BuildContext context,
    CannedMessageConfigDto cm,
  ) {
    return [
      _kv(AppLocalizations.of(context).rotary1Enabled, cm.rotary1Enabled),
      _kv(AppLocalizations.of(context).inputBrokerPinA, cm.inputbrokerPinA),
      _kv(AppLocalizations.of(context).inputBrokerPinB, cm.inputbrokerPinB),
      _kv(
        AppLocalizations.of(context).inputBrokerPinPress,
        cm.inputbrokerPinPress,
      ),
      _kv(AppLocalizations.of(context).upDown1Enabled, cm.updown1Enabled),
      _kv(AppLocalizations.of(context).allowInputSource, cm.allowInputSource),
      _kv(AppLocalizations.of(context).sendBell, cm.sendBell),
    ];
  }

  List<Widget> _buildAmbientLightingConfig(
    BuildContext context,
    AmbientLightingConfigDto al,
  ) {
    return [
      _kv(AppLocalizations.of(context).ledState, al.ledState),
      _kv(AppLocalizations.of(context).current, al.current),
      _kv(AppLocalizations.of(context).red, al.red),
      _kv(AppLocalizations.of(context).green, al.green),
      _kv(AppLocalizations.of(context).blue, al.blue),
    ];
  }

  List<Widget> _buildDetectionSensorConfig(
    BuildContext context,
    DetectionSensorConfigDto ds,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, ds.enabled),
      _kv(
        AppLocalizations.of(context).minBroadcastSecs,
        ds.minimumBroadcastSecs,
      ),
      _kv(
        AppLocalizations.of(context).stateBroadcastSecs,
        ds.stateBroadcastSecs,
      ),
      _kv(AppLocalizations.of(context).sendBell, ds.sendBell),
      _kv(AppLocalizations.of(context).name, ds.name),
      _kv(AppLocalizations.of(context).monitorPin, ds.monitorPin),
      _kv(AppLocalizations.of(context).triggerType, ds.detectionTriggerType),
      _kv(AppLocalizations.of(context).usePullup, ds.usePullup),
    ];
  }

  List<Widget> _buildDtnOverlayConfig(
    BuildContext context,
    DtnOverlayConfigDto dtn,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, dtn.enabled),
      _kv(AppLocalizations.of(context).ttlMinutes, dtn.ttlMinutes),
      _kv(
        AppLocalizations.of(context).initialDelayBaseMs,
        dtn.initialDelayBaseMs,
      ),
      _kv(AppLocalizations.of(context).retryBackoffMs, dtn.retryBackoffMs),
      _kv(AppLocalizations.of(context).maxTries, dtn.maxTries),
    ];
  }

  List<Widget> _buildBroadcastAssistConfig(
    BuildContext context,
    BroadcastAssistConfigDto ba,
  ) {
    return [
      _kv(AppLocalizations.of(context).enabled, ba.enabled),
      _kv(AppLocalizations.of(context).degreeThreshold, ba.degreeThreshold),
      _kv(AppLocalizations.of(context).dupThreshold, ba.dupThreshold),
      _kv(AppLocalizations.of(context).windowMs, ba.windowMs),
      _kv(AppLocalizations.of(context).maxExtraHops, ba.maxExtraHops),
      _kv(AppLocalizations.of(context).jitterMs, ba.jitterMs),
      _kv(AppLocalizations.of(context).airtimeGuard, ba.airtimeGuard),
    ];
  }

  List<Widget> _buildNodeModConfig(BuildContext context, NodeModConfigDto nm) {
    return [
      _kv(AppLocalizations.of(context).textStatus, nm.textStatus),
      _kv(AppLocalizations.of(context).emoji, nm.emoji),
    ];
  }

  List<Widget> _buildNodeModAdminConfig(
    BuildContext context,
    NodeModAdminConfigDto nma,
  ) {
    return [
      _kv(AppLocalizations.of(context).snifferEnabled, nma.snifferEnabled),
      _kv(
        AppLocalizations.of(context).doNotSendPrvOverMqtt,
        nma.doNotSendPrvOverMqtt,
      ),
      _kv(
        AppLocalizations.of(context).localStatsOverMesh,
        nma.localStatsOverMeshEnabled,
      ),
      _kv(AppLocalizations.of(context).idlegameEnabled, nma.idlegameEnabled),
      _kv(
        AppLocalizations.of(context).autoResponderEnabled,
        nma.autoResponderEnabled,
      ),
      _kv(
        AppLocalizations.of(context).autoResponderText,
        nma.autoResponderText,
      ),
      _kv(
        AppLocalizations.of(context).autoRedirectMessages,
        nma.autoRedirectMessages,
      ),
      _kv(
        AppLocalizations.of(context).autoRedirectTarget,
        nma.autoRedirectTargetNodeId,
      ),
      _kv(
        AppLocalizations.of(context).telemetryLimiter,
        nma.telemetryLimiterEnabled,
      ),
      _kv(
        AppLocalizations.of(context).positionLimiter,
        nma.positionLimiterEnabled,
      ),
      _kv(
        AppLocalizations.of(context).opportunisticFlooding,
        nma.opportunisticFloodingEnabled,
      ),
    ];
  }

  List<Widget> _buildIdleGameConfig(
    BuildContext context,
    IdleGameConfigDto ig,
  ) {
    return [_kv(AppLocalizations.of(context).idleGameVariant, ig.variant)];
  }

  Widget _kv(String key, Object? value) {
    return ListTile(
      dense: true,
      title: Text(key),
      subtitle: Text(safeText(value?.toString() ?? 'N/A')),
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
