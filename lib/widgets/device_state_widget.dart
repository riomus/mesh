import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/device_state.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../l10n/app_localizations.dart';
import '../utils/text_sanitize.dart';
import '../pages/config_edit_page.dart';
import '../services/device_status_store.dart';
import 'config_form_helpers.dart';
import 'owner_edit_dialog.dart';

class DeviceStateWidget extends StatelessWidget {
  final DeviceState state;
  final String? deviceId;

  const DeviceStateWidget({super.key, required this.state, this.deviceId});

  @override
  Widget build(BuildContext context) {
    // Find the local node
    final localNode = state.myNodeInfo?.myNodeNum != null
        ? state.nodes.firstWhereOrNull(
            (n) => n.num == state.myNodeInfo!.myNodeNum,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Owner Info - displayed first
        if (localNode?.user != null)
          _Section(
            title: 'Owner',
            onEdit: deviceId != null ? () => _openOwnerEdit(context) : null,
            children: [
              ListTile(
                dense: true,
                leading: const Icon(Icons.person),
                title: Text(localNode!.user!.longName ?? '—'),
                subtitle: Text('Short: ${localNode.user!.shortName ?? '—'}'),
              ),
            ],
          ),
        // Device Configs - show all types
        _buildConfigSection(
          context,
          AppLocalizations.of(context).deviceConfig,
          state.config?.device,
          (d) => _buildDeviceConfig(context, d),
          onEdit: deviceId != null
              ? () => _openDeviceConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).positionConfig,
          state.config?.position,
          (p) => _buildPositionConfig(context, p),
          onEdit: deviceId != null
              ? () => _openPositionConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).powerConfig,
          state.config?.power,
          (p) => _buildPowerConfig(context, p),
          onEdit: deviceId != null ? () => _openPowerConfigEdit(context) : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).networkConfig,
          state.config?.network,
          (n) => _buildNetworkConfig(context, n),
          onEdit: deviceId != null
              ? () => _openNetworkConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).displayConfig,
          state.config?.display,
          (d) => _buildDisplayConfig(context, d),
          onEdit: deviceId != null
              ? () => _openDisplayConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).loraConfig,
          state.config?.lora,
          (l) => _buildLoraConfig(context, l),
          onEdit: deviceId != null ? () => _openLoraConfigEdit(context) : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).bluetoothConfig,
          state.config?.bluetooth,
          (b) => _buildBluetoothConfig(context, b),
          onEdit: deviceId != null
              ? () => _openBluetoothConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).securityConfig,
          state.config?.security,
          (s) => _buildSecurityConfig(context, s),
          onEdit: deviceId != null
              ? () => _openSecurityConfigEdit(context)
              : null,
        ),

        // Module Configs - show all types
        _buildConfigSection(
          context,
          AppLocalizations.of(context).mqttConfig,
          state.moduleConfig?.mqtt,
          (m) => _buildMqttConfig(context, m),
          onEdit: deviceId != null ? () => _openMqttConfigEdit(context) : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).telemetryConfig,
          state.moduleConfig?.telemetry,
          (t) => _buildTelemetryConfig(context, t),
          onEdit: deviceId != null
              ? () => _openTelemetryConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).serialConfig,
          state.moduleConfig?.serial,
          (s) => _buildSerialConfig(context, s),
          onEdit: deviceId != null
              ? () => _openSerialConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).storeForwardConfig,
          state.moduleConfig?.storeForward,
          (sf) => _buildStoreForwardConfig(context, sf),
          onEdit: deviceId != null
              ? () => _openStoreForwardConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).rangeTestConfig,
          state.moduleConfig?.rangeTest,
          (rt) => _buildRangeTestConfig(context, rt),
          onEdit: deviceId != null
              ? () => _openRangeTestConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).externalNotificationConfig,
          state.moduleConfig?.externalNotification,
          (en) => _buildExternalNotificationConfig(context, en),
          onEdit: deviceId != null
              ? () => _openExternalNotificationConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).audioConfig,
          state.moduleConfig?.audio,
          (a) => _buildAudioConfig(context, a),
          onEdit: deviceId != null ? () => _openAudioConfigEdit(context) : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).neighborInfoConfig,
          state.moduleConfig?.neighborInfo,
          (ni) => _buildNeighborInfoConfig(context, ni),
          onEdit: deviceId != null
              ? () => _openNeighborInfoConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).remoteHardwareConfig,
          state.moduleConfig?.remoteHardware,
          (rh) => _buildRemoteHardwareConfig(context, rh),
          onEdit: deviceId != null
              ? () => _openRemoteHardwareConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).paxcounterConfig,
          state.moduleConfig?.paxcounter,
          (pc) => _buildPaxcounterConfig(context, pc),
          onEdit: deviceId != null
              ? () => _openPaxcounterConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).cannedMessageConfig,
          state.moduleConfig?.cannedMessage,
          (cm) => _buildCannedMessageConfig(context, cm),
          onEdit: deviceId != null
              ? () => _openCannedMessageConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).ambientLightingConfig,
          state.moduleConfig?.ambientLighting,
          (al) => _buildAmbientLightingConfig(context, al),
          onEdit: deviceId != null
              ? () => _openAmbientLightingConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).detectionSensorConfig,
          state.moduleConfig?.detectionSensor,
          (ds) => _buildDetectionSensorConfig(context, ds),
          onEdit: deviceId != null
              ? () => _openDetectionSensorConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).dtnOverlayConfig,
          state.moduleConfig?.dtnOverlay,
          (dtn) => _buildDtnOverlayConfig(context, dtn),
          onEdit: deviceId != null
              ? () => _openDtnOverlayConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).broadcastAssistConfig,
          state.moduleConfig?.broadcastAssist,
          (ba) => _buildBroadcastAssistConfig(context, ba),
          onEdit: deviceId != null
              ? () => _openBroadcastAssistConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).nodeModConfig,
          state.moduleConfig?.nodeMod,
          (nm) => _buildNodeModConfig(context, nm),
          onEdit: deviceId != null
              ? () => _openNodeModConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).nodeModAdminConfig,
          state.moduleConfig?.nodeModAdmin,
          (nma) => _buildNodeModAdminConfig(context, nma),
          onEdit: deviceId != null
              ? () => _openNodeModAdminConfigEdit(context)
              : null,
        ),
        _buildConfigSection(
          context,
          AppLocalizations.of(context).idleGameConfig,
          state.moduleConfig?.idleGame,
          (ig) => _buildIdleGameConfig(context, ig),
          onEdit: deviceId != null
              ? () => _openIdleGameConfigEdit(context)
              : null,
        ),
        if (state.deviceUiConfig != null)
          _buildConfigSection(
            context,
            AppLocalizations.of(context).deviceUiConfig,
            state.deviceUiConfig,
            (c) => _buildDeviceUiConfig(context, c),
            // onEdit: null, // Read-only for now due to proto issues
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
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openChannelConfigEdit(context, c),
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
    List<Widget> Function(T) builder, {
    VoidCallback? onEdit,
  }) {
    return _Section(
      title: title,
      onEdit: onEdit,
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
      _kv(context, AppLocalizations.of(context).role, device.role),
      _kv(
        context,
        AppLocalizations.of(context).serialEnabled,
        device.serialEnabled,
      ),
      _kv(context, AppLocalizations.of(context).buttonGpio, device.buttonGpio),
      _kv(context, AppLocalizations.of(context).buzzerGpio, device.buzzerGpio),
      _kv(
        context,
        AppLocalizations.of(context).rebroadcastMode,
        device.rebroadcastMode,
      ),
      _kv(
        context,
        AppLocalizations.of(context).nodeInfoBroadcastSecs,
        device.nodeInfoBroadcastSecs,
      ),
      _kv(
        context,
        AppLocalizations.of(context).doubleTapAsButtonPress,
        device.doubleTapAsButtonPress,
      ),
      _kv(context, AppLocalizations.of(context).isManaged, device.isManaged),
      _kv(
        context,
        AppLocalizations.of(context).disableTripleClick,
        device.disableTripleClick,
      ),
      _kv(context, AppLocalizations.of(context).timezone, device.tzdef),
      _kv(
        context,
        AppLocalizations.of(context).ledHeartbeatDisabled,
        device.ledHeartbeatDisabled,
      ),
      _kv(context, AppLocalizations.of(context).buzzerMode, device.buzzerMode),
    ];
  }

  List<Widget> _buildPositionConfig(
    BuildContext context,
    PositionConfigDto position,
  ) {
    return [
      _kv(
        context,
        AppLocalizations.of(context).positionBroadcastSecs,
        position.positionBroadcastSecs,
      ),
      _kv(
        context,
        AppLocalizations.of(context).positionBroadcastSmartEnabled,
        position.positionBroadcastSmartEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).fixedPosition,
        position.fixedPosition,
      ),
      _kv(
        context,
        AppLocalizations.of(context).gpsEnabled,
        position.gpsEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).gpsUpdateInterval,
        position.gpsUpdateInterval,
      ),
      _kv(
        context,
        AppLocalizations.of(context).gpsAttemptTime,
        position.gpsAttemptTime,
      ),
      _kv(
        context,
        AppLocalizations.of(context).positionFlags,
        position.positionFlags,
      ),
      _kv(context, AppLocalizations.of(context).rxGpio, position.rxGpio),
      _kv(context, AppLocalizations.of(context).txGpio, position.txGpio),
      _kv(
        context,
        AppLocalizations.of(context).broadcastSmartMinimumDistance,
        position.broadcastSmartMinimumDistance,
      ),
      _kv(
        context,
        AppLocalizations.of(context).broadcastSmartMinimumIntervalSecs,
        position.broadcastSmartMinimumIntervalSecs,
      ),
      _kv(
        context,
        AppLocalizations.of(context).gpsEnableGpio,
        position.gpsEnGpio,
      ),
      _kv(context, AppLocalizations.of(context).gpsMode, position.gpsMode),
    ];
  }

  List<Widget> _buildPowerConfig(BuildContext context, PowerConfigDto power) {
    return [
      _kv(
        context,
        AppLocalizations.of(context).isPowerSaving,
        power.isPowerSaving,
      ),
      _kv(
        context,
        AppLocalizations.of(context).onBatteryShutdownAfterSecs,
        power.onBatteryShutdownAfterSecs,
      ),
      _kv(
        context,
        AppLocalizations.of(context).adcMultiplierOverride,
        power.adcMultiplierOverride,
      ),
      _kv(
        context,
        AppLocalizations.of(context).waitBluetoothSecs,
        power.waitBluetoothSecs,
      ),
      _kv(context, AppLocalizations.of(context).sdsSecs, power.sdsSecs),
      _kv(context, AppLocalizations.of(context).lsSecs, power.lsSecs),
      _kv(context, AppLocalizations.of(context).minWakeSecs, power.minWakeSecs),
      _kv(
        context,
        AppLocalizations.of(context).deviceBatteryInaAddress,
        power.deviceBatteryInaAddress,
      ),
      _kv(
        context,
        AppLocalizations.of(context).powermonEnables,
        power.powermonEnables,
      ),
    ];
  }

  List<Widget> _buildDisplayConfig(
    BuildContext context,
    DisplayConfigDto display,
  ) {
    return [
      _kv(
        context,
        AppLocalizations.of(context).screenOnSecs,
        display.screenOnSecs,
      ),
      _kv(
        context,
        AppLocalizations.of(context).autoScreenCarouselSecs,
        display.autoScreenCarouselSecs,
      ),
      _kv(
        context,
        AppLocalizations.of(context).compassNorthTop,
        display.compassNorthTop,
      ),
      _kv(context, AppLocalizations.of(context).flipScreen, display.flipScreen),
      _kv(context, AppLocalizations.of(context).units, display.units),
      _kv(context, AppLocalizations.of(context).oled, display.oled),
      _kv(
        context,
        AppLocalizations.of(context).displayMode,
        display.displaymode,
      ),
      _kv(
        context,
        AppLocalizations.of(context).headingBold,
        display.headingBold,
      ),
      _kv(
        context,
        AppLocalizations.of(context).wakeOnTapOrMotion,
        display.wakeOnTapOrMotion,
      ),
      _kv(
        context,
        AppLocalizations.of(context).compassOrientation,
        display.compassOrientation,
      ),
      _kv(
        context,
        AppLocalizations.of(context).use12hClock,
        display.use12hClock,
      ),
      _kv(
        context,
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
      _kv(context, AppLocalizations.of(context).enabled, bluetooth.enabled),
      _kv(context, AppLocalizations.of(context).mode, bluetooth.mode),
      _kv(context, AppLocalizations.of(context).fixedPin, bluetooth.fixedPin),
    ];
  }

  List<Widget> _buildSecurityConfig(
    BuildContext context,
    SecurityConfigDto security,
  ) {
    return [
      _kv(
        context,
        AppLocalizations.of(context).publicKey,
        security.publicKey != null ? '***' : null,
      ),
      _kv(
        context,
        AppLocalizations.of(context).privateKey,
        security.privateKey != null ? '***' : null,
      ),
      _kv(
        context,
        AppLocalizations.of(context).adminKeys,
        security.adminKey?.length,
      ),
      _kv(context, AppLocalizations.of(context).isManaged, security.isManaged),
      _kv(
        context,
        AppLocalizations.of(context).serialEnabled,
        security.serialEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).debugLogApiEnabled,
        security.debugLogApiEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).adminChannelEnabled,
        security.adminChannelEnabled,
      ),
    ];
  }

  List<Widget> _buildLoraConfig(BuildContext context, LoRaConfigDto lora) {
    return [
      _kv(context, AppLocalizations.of(context).region, lora.region),
      _kv(context, AppLocalizations.of(context).modemPreset, lora.modemPreset),
      _kv(context, AppLocalizations.of(context).hopLimit, lora.hopLimit),
      _kv(context, AppLocalizations.of(context).txEnabled, lora.txEnabled),
      _kv(context, AppLocalizations.of(context).txPower, lora.txPower),
    ];
  }

  List<Widget> _buildNetworkConfig(BuildContext context, NetworkConfigDto net) {
    return [
      _kv(context, AppLocalizations.of(context).wifiEnabled, net.wifiEnabled),
      _kv(context, AppLocalizations.of(context).wifiSsid, net.wifiSsid),
    ];
  }

  List<Widget> _buildMqttConfig(BuildContext context, MqttConfigDto mqtt) {
    return [
      _kv(context, AppLocalizations.of(context).enabled, mqtt.enabled),
      _kv(context, AppLocalizations.of(context).address, mqtt.address),
      _kv(context, AppLocalizations.of(context).username, mqtt.username),
      _kv(
        context,
        AppLocalizations.of(context).encryption,
        mqtt.encryptionEnabled,
      ),
      _kv(context, AppLocalizations.of(context).json, mqtt.jsonEnabled),
      _kv(context, AppLocalizations.of(context).tls, mqtt.tlsEnabled),
      _kv(context, AppLocalizations.of(context).rootTopic, mqtt.root),
      _kv(
        context,
        AppLocalizations.of(context).proxyToClient,
        mqtt.proxyToClientEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).mapReporting,
        mqtt.mapReportingEnabled,
      ),
    ];
  }

  List<Widget> _buildTelemetryConfig(
    BuildContext context,
    TelemetryConfigDto tel,
  ) {
    return [
      _kv(
        context,
        AppLocalizations.of(context).deviceUpdateInterval,
        tel.deviceUpdateInterval,
      ),
      _kv(
        context,
        AppLocalizations.of(context).environmentUpdateInterval,
        tel.environmentUpdateInterval,
      ),
      _kv(
        context,
        AppLocalizations.of(context).environmentMeasurement,
        tel.environmentMeasurementEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).environmentScreen,
        tel.environmentScreenEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).airQuality,
        tel.airQualityEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).airQualityInterval,
        tel.airQualityInterval,
      ),
      _kv(
        context,
        AppLocalizations.of(context).powerMeasurement,
        tel.powerMeasurementEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).powerUpdateInterval,
        tel.powerUpdateInterval,
      ),
      _kv(
        context,
        AppLocalizations.of(context).powerScreen,
        tel.powerScreenEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).healthMeasurement,
        tel.healthMeasurementEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).healthUpdateInterval,
        tel.healthUpdateInterval,
      ),
      _kv(
        context,
        AppLocalizations.of(context).healthScreen,
        tel.healthScreenEnabled,
      ),
      _kv(
        context,
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
      _kv(context, AppLocalizations.of(context).serialEnabled, serial.enabled),
      _kv(context, AppLocalizations.of(context).echo, serial.echo),
      _kv(context, AppLocalizations.of(context).rxd, serial.rxd),
      _kv(context, AppLocalizations.of(context).txd, serial.txd),
      _kv(context, AppLocalizations.of(context).baud, serial.baud),
      _kv(context, AppLocalizations.of(context).timeout, serial.timeout),
      _kv(context, AppLocalizations.of(context).mode, serial.mode),
      _kv(
        context,
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
      _kv(context, AppLocalizations.of(context).enabled, sf.enabled),
      _kv(context, AppLocalizations.of(context).heartbeat, sf.heartbeat),
      _kv(context, AppLocalizations.of(context).records, sf.records),
      _kv(
        context,
        AppLocalizations.of(context).historyReturnMax,
        sf.historyReturnMax,
      ),
      _kv(
        context,
        AppLocalizations.of(context).historyReturnWindow,
        sf.historyReturnWindow,
      ),
      _kv(context, AppLocalizations.of(context).isServer, sf.isServer),
      _kv(
        context,
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
      _kv(context, AppLocalizations.of(context).enabled, rt.enabled),
      _kv(context, AppLocalizations.of(context).sender, rt.sender),
      _kv(context, AppLocalizations.of(context).save, rt.save),
      _kv(
        context,
        AppLocalizations.of(context).clearOnReboot,
        rt.clearOnReboot,
      ),
    ];
  }

  List<Widget> _buildExternalNotificationConfig(
    BuildContext context,
    ExternalNotificationConfigDto en,
  ) {
    return [
      _kv(context, AppLocalizations.of(context).enabled, en.enabled),
      _kv(context, AppLocalizations.of(context).outputMs, en.outputMs),
      _kv(context, AppLocalizations.of(context).output, en.output),
      _kv(context, AppLocalizations.of(context).active, en.active),
      _kv(context, AppLocalizations.of(context).alertMessage, en.alertMessage),
      _kv(context, AppLocalizations.of(context).alertBell, en.alertBell),
      _kv(context, AppLocalizations.of(context).usePwm, en.usePwm),
      _kv(context, AppLocalizations.of(context).outputVibra, en.outputVibra),
      _kv(context, AppLocalizations.of(context).outputBuzzer, en.outputBuzzer),
      _kv(context, AppLocalizations.of(context).nagTimeout, en.nagTimeout),
      _kv(
        context,
        AppLocalizations.of(context).useI2sAsBuzzer,
        en.useI2sAsBuzzer,
      ),
    ];
  }

  List<Widget> _buildAudioConfig(BuildContext context, AudioConfigDto audio) {
    return [
      _kv(
        context,
        AppLocalizations.of(context).codec2Enabled,
        audio.codec2Enabled,
      ),
      _kv(context, AppLocalizations.of(context).pttPin, audio.pttPin),
      _kv(context, AppLocalizations.of(context).bitrate, audio.bitrate),
      _kv(context, AppLocalizations.of(context).i2sWs, audio.i2sWs),
      _kv(context, AppLocalizations.of(context).i2sSd, audio.i2sSd),
      _kv(context, AppLocalizations.of(context).i2sDin, audio.i2sDin),
      _kv(context, AppLocalizations.of(context).i2sSck, audio.i2sSck),
    ];
  }

  List<Widget> _buildNeighborInfoConfig(
    BuildContext context,
    NeighborInfoConfigDto ni,
  ) {
    return [
      _kv(context, AppLocalizations.of(context).enabled, ni.enabled),
      _kv(
        context,
        AppLocalizations.of(context).updateInterval,
        ni.updateInterval,
      ),
      _kv(
        context,
        AppLocalizations.of(context).transmitOverLora,
        ni.transmitOverLora,
      ),
    ];
  }

  List<Widget> _buildRemoteHardwareConfig(
    BuildContext context,
    RemoteHardwareConfigDto rh,
  ) {
    return [
      _kv(context, AppLocalizations.of(context).enabled, rh.enabled),
      _kv(
        context,
        AppLocalizations.of(context).allowUndefinedPinAccess,
        rh.allowUndefinedPinAccess,
      ),
      if (rh.availablePins != null)
        ...rh.availablePins!.map(
          (p) => _kv(
            context,
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
      _kv(context, AppLocalizations.of(context).enabled, pc.enabled),
      _kv(
        context,
        AppLocalizations.of(context).paxcounterUpdateInterval,
        pc.paxcounterUpdateInterval,
      ),
      _kv(
        context,
        AppLocalizations.of(context).wifiThreshold,
        pc.wifiThreshold,
      ),
      _kv(context, AppLocalizations.of(context).bleThreshold, pc.bleThreshold),
    ];
  }

  List<Widget> _buildCannedMessageConfig(
    BuildContext context,
    CannedMessageConfigDto cm,
  ) {
    return [
      _kv(
        context,
        AppLocalizations.of(context).rotary1Enabled,
        cm.rotary1Enabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).inputBrokerPinA,
        cm.inputbrokerPinA,
      ),
      _kv(
        context,
        AppLocalizations.of(context).inputBrokerPinB,
        cm.inputbrokerPinB,
      ),
      _kv(
        context,
        AppLocalizations.of(context).inputBrokerPinPress,
        cm.inputbrokerPinPress,
      ),
      _kv(
        context,
        AppLocalizations.of(context).upDown1Enabled,
        cm.updown1Enabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).allowInputSource,
        cm.allowInputSource,
      ),
      _kv(context, AppLocalizations.of(context).sendBell, cm.sendBell),
    ];
  }

  List<Widget> _buildAmbientLightingConfig(
    BuildContext context,
    AmbientLightingConfigDto al,
  ) {
    return [
      _kv(context, AppLocalizations.of(context).ledState, al.ledState),
      _kv(context, AppLocalizations.of(context).current, al.current),
      _kv(context, AppLocalizations.of(context).red, al.red),
      _kv(context, AppLocalizations.of(context).green, al.green),
      _kv(context, AppLocalizations.of(context).blue, al.blue),
    ];
  }

  List<Widget> _buildDetectionSensorConfig(
    BuildContext context,
    DetectionSensorConfigDto ds,
  ) {
    return [
      _kv(context, AppLocalizations.of(context).enabled, ds.enabled),
      _kv(
        context,
        AppLocalizations.of(context).minBroadcastSecs,
        ds.minimumBroadcastSecs,
      ),
      _kv(
        context,
        AppLocalizations.of(context).stateBroadcastSecs,
        ds.stateBroadcastSecs,
      ),
      _kv(context, AppLocalizations.of(context).sendBell, ds.sendBell),
      _kv(context, AppLocalizations.of(context).name, ds.name),
      _kv(context, AppLocalizations.of(context).monitorPin, ds.monitorPin),
      _kv(
        context,
        AppLocalizations.of(context).triggerType,
        ds.detectionTriggerType,
      ),
      _kv(context, AppLocalizations.of(context).usePullup, ds.usePullup),
    ];
  }

  List<Widget> _buildDtnOverlayConfig(
    BuildContext context,
    DtnOverlayConfigDto dtn,
  ) {
    return [
      _kv(context, AppLocalizations.of(context).enabled, dtn.enabled),
      _kv(context, AppLocalizations.of(context).ttlMinutes, dtn.ttlMinutes),
      _kv(
        context,
        AppLocalizations.of(context).initialDelayBaseMs,
        dtn.initialDelayBaseMs,
      ),
      _kv(
        context,
        AppLocalizations.of(context).retryBackoffMs,
        dtn.retryBackoffMs,
      ),
      _kv(context, AppLocalizations.of(context).maxTries, dtn.maxTries),
    ];
  }

  List<Widget> _buildBroadcastAssistConfig(
    BuildContext context,
    BroadcastAssistConfigDto ba,
  ) {
    return [
      _kv(context, AppLocalizations.of(context).enabled, ba.enabled),
      _kv(
        context,
        AppLocalizations.of(context).degreeThreshold,
        ba.degreeThreshold,
      ),
      _kv(context, AppLocalizations.of(context).dupThreshold, ba.dupThreshold),
      _kv(context, AppLocalizations.of(context).windowMs, ba.windowMs),
      _kv(context, AppLocalizations.of(context).maxExtraHops, ba.maxExtraHops),
      _kv(context, AppLocalizations.of(context).jitterMs, ba.jitterMs),
      _kv(context, AppLocalizations.of(context).airtimeGuard, ba.airtimeGuard),
    ];
  }

  List<Widget> _buildNodeModConfig(BuildContext context, NodeModConfigDto nm) {
    return [
      _kv(context, AppLocalizations.of(context).textStatus, nm.textStatus),
      _kv(context, AppLocalizations.of(context).emoji, nm.emoji),
    ];
  }

  List<Widget> _buildNodeModAdminConfig(
    BuildContext context,
    NodeModAdminConfigDto nma,
  ) {
    return [
      _kv(
        context,
        AppLocalizations.of(context).snifferEnabled,
        nma.snifferEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).doNotSendPrvOverMqtt,
        nma.doNotSendPrvOverMqtt,
      ),
      _kv(
        context,
        AppLocalizations.of(context).localStatsOverMesh,
        nma.localStatsOverMeshEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).idlegameEnabled,
        nma.idlegameEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).autoResponderEnabled,
        nma.autoResponderEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).autoResponderText,
        nma.autoResponderText,
      ),
      _kv(
        context,
        AppLocalizations.of(context).autoRedirectMessages,
        nma.autoRedirectMessages,
      ),
      _kv(
        context,
        AppLocalizations.of(context).autoRedirectTarget,
        nma.autoRedirectTargetNodeId,
      ),
      _kv(
        context,
        AppLocalizations.of(context).telemetryLimiter,
        nma.telemetryLimiterEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).positionLimiter,
        nma.positionLimiterEnabled,
      ),
      _kv(
        context,
        AppLocalizations.of(context).opportunisticFlooding,
        nma.opportunisticFloodingEnabled,
      ),
    ];
  }

  List<Widget> _buildIdleGameConfig(
    BuildContext context,
    IdleGameConfigDto ig,
  ) {
    return [
      _kv(context, AppLocalizations.of(context).idleGameVariant, ig.variant),
    ];
  }

  List<Widget> _buildDeviceUiConfig(
    BuildContext context,
    DeviceUiConfigDto ui,
  ) {
    return [
      _kv(
        context,
        AppLocalizations.of(context).screenBrightness,
        ui.screenBrightness,
      ),
      _kv(
        context,
        AppLocalizations.of(context).screenTimeout,
        ui.screenTimeout,
      ),
      _kv(context, AppLocalizations.of(context).screenLock, ui.screenLock),
      _kv(context, AppLocalizations.of(context).settingsLock, ui.settingsLock),
      _kv(context, AppLocalizations.of(context).pinCode, ui.pinCode),
      _kv(context, AppLocalizations.of(context).theme, ui.theme),
      _kv(context, AppLocalizations.of(context).alertEnabled, ui.alertEnabled),
      _kv(
        context,
        AppLocalizations.of(context).bannerEnabled,
        ui.bannerEnabled,
      ),
      _kv(context, AppLocalizations.of(context).ringToneId, ui.ringToneId),
      _kv(context, AppLocalizations.of(context).language, ui.language),
    ];
  }

  Widget _kv(BuildContext context, String key, Object? value) {
    return ListTile(
      dense: true,
      title: Text(key),
      subtitle: Text(
        safeText(value?.toString() ?? AppLocalizations.of(context).nA),
      ),
    );
  }

  void _openOwnerEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Find the local node to get current values
    final localNode = state.myNodeInfo?.myNodeNum != null
        ? state.nodes.firstWhereOrNull(
            (n) => n.num == state.myNodeInfo!.myNodeNum,
          )
        : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => OwnerEditDialog(
        currentLongName: localNode?.user?.longName,
        currentShortName: localNode?.user?.shortName,
        onSave: ({String? longName, String? shortName}) async {
          await client.setOwner(
            longName: longName,
            shortName: shortName,
            nodeId: null, // null = local node
          );
        },
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).ownerUpdateSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _openDeviceConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.config?.device ?? const DeviceConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<DeviceConfigDto>(
          title: AppLocalizations.of(context).deviceConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ConfigDto(device: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildEnumDropdown(
                label: AppLocalizations.of(context).deviceRoleLabel,
                value: config.role,
                options: [
                  'CLIENT',
                  'CLIENT_MUTE',
                  'ROUTER',
                  'ROUTER_CLIENT',
                  'REPEATER',
                  'TRACKER',
                  'SENSOR',
                  'TAK',
                  'CLIENT_HIDDEN',
                  'LOST_AND_FOUND',
                  'TAK_TRACKER',
                ],
                configKey: 'device.role',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: val,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: AppLocalizations.of(context).serialEnabledLabel,
                value: config.serialEnabled,
                subtitle: AppLocalizations.of(context).serialEnabledSubtitle,
                configKey: 'device.serialEnabled',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: val,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(context).buttonGpioLabel,
                value: config.buttonGpio,
                min: 0,
                max: 39,
                configKey: 'device.buttonGpio',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: val,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(context).buzzerGpioLabel,
                value: config.buzzerGpio,
                min: 0,
                max: 39,
                configKey: 'device.buzzerGpio',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: val,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: AppLocalizations.of(context).rebroadcastModeLabel,
                value: config.rebroadcastMode,
                options: [
                  'ALL',
                  'ALL_SKIP_DECODING',
                  'LOCAL_ONLY',
                  'KNOWN_ONLY',
                ],
                configKey: 'device.rebroadcastMode',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: val,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(
                  context,
                ).nodeInfoBroadcastIntervalLabel,
                value: config.nodeInfoBroadcastSecs,
                min: 0,
                hint: AppLocalizations.of(
                  context,
                ).nodeInfoBroadcastIntervalHint,
                configKey: 'device.nodeInfoBroadcastSecs',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: val,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: AppLocalizations.of(context).doubleTapAsButtonPressLabel,
                value: config.doubleTapAsButtonPress,
                configKey: 'device.doubleTapAsButtonPress',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: val,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: AppLocalizations.of(context).isManagedLabel,
                value: config.isManaged,
                configKey: 'device.isManaged',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: val,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: AppLocalizations.of(context).disableTripleClickLabel,
                value: config.disableTripleClick,
                configKey: 'device.disableTripleClick',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: val,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildTextField(
                label: AppLocalizations.of(context).timezoneDefinitionLabel,
                value: config.tzdef,
                hint: AppLocalizations.of(context).timezoneDefinitionHint,
                configKey: 'device.tzdef',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: val.isEmpty ? null : val,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: AppLocalizations.of(context).ledHeartbeatDisabledLabel,
                value: config.ledHeartbeatDisabled,
                configKey: 'device.ledHeartbeatDisabled',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: val,
                    buzzerMode: config.buzzerMode,
                  ),
                ),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: AppLocalizations.of(context).buzzerModeLabel,
                value: config.buzzerMode,
                options: ['OFF', 'ON', 'ALL_ENABLED'],
                configKey: 'device.buzzerMode',
                onChanged: (val) => onChanged(
                  DeviceConfigDto(
                    role: config.role,
                    serialEnabled: config.serialEnabled,
                    buttonGpio: config.buttonGpio,
                    buzzerGpio: config.buzzerGpio,
                    rebroadcastMode: config.rebroadcastMode,
                    nodeInfoBroadcastSecs: config.nodeInfoBroadcastSecs,
                    doubleTapAsButtonPress: config.doubleTapAsButtonPress,
                    isManaged: config.isManaged,
                    disableTripleClick: config.disableTripleClick,
                    tzdef: config.tzdef,
                    ledHeartbeatDisabled: config.ledHeartbeatDisabled,
                    buzzerMode: val,
                  ),
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openPositionConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    print(
      '[DeviceStateWidget] Requesting session key for node ${state.myNodeInfo?.myNodeNum}',
    );
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.config?.position ?? const PositionConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<PositionConfigDto>(
          title: AppLocalizations.of(context).positionConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            print(
              '[DeviceStateWidget] Saving position config. Passkey length: ${state.sessionPasskey?.length}',
            );
            // Send ONLY the position config, not the entire config object
            // This matches Python's behavior: p.set_config.position.CopyFrom(...)
            final newConfig = ConfigDto(position: updatedConfig);
            // Begin transaction
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            // Send config
            await client.sendConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            // Commit transaction
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(
                  context,
                ).positionBroadcastIntervalLabel,
                value: config.positionBroadcastSecs,
                min: 0,
                configKey: 'position.positionBroadcastSecs',
                onChanged: (val) =>
                    onChanged(config.copyWith(positionBroadcastSecs: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: AppLocalizations.of(context).smartPositionBroadcastLabel,
                value: config.positionBroadcastSmartEnabled,
                configKey: 'position.positionBroadcastSmartEnabled',
                onChanged: (val) => onChanged(
                  config.copyWith(positionBroadcastSmartEnabled: val),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: AppLocalizations.of(context).fixedPositionLabel,
                value: config.fixedPosition,
                configKey: 'position.fixedPosition',
                onChanged: (val) =>
                    onChanged(config.copyWith(fixedPosition: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: AppLocalizations.of(context).gpsEnabledLabel,
                value: config.gpsEnabled,
                configKey: 'position.gpsEnabled',
                onChanged: (val) => onChanged(config.copyWith(gpsEnabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(context).gpsUpdateIntervalLabel,
                value: config.gpsUpdateInterval,
                min: 0,
                configKey: 'position.gpsUpdateInterval',
                onChanged: (val) =>
                    onChanged(config.copyWith(gpsUpdateInterval: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(context).gpsAttemptTimeLabel,
                value: config.gpsAttemptTime,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(gpsAttemptTime: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(context).positionFlagsLabel,
                value: config.positionFlags,
                configKey: 'position.positionFlags',
                onChanged: (val) =>
                    onChanged(config.copyWith(positionFlags: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(context).rxGpioLabel,
                value: config.rxGpio,
                configKey: 'position.rxGpio',
                onChanged: (val) => onChanged(config.copyWith(rxGpio: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(context).txGpioLabel,
                value: config.txGpio,
                configKey: 'position.txGpio',
                onChanged: (val) => onChanged(config.copyWith(txGpio: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(
                  context,
                ).smartBroadcastMinDistanceLabel,
                value: config.broadcastSmartMinimumDistance,
                min: 0,
                configKey: 'position.broadcastSmartMinimumDistance',
                onChanged: (val) => onChanged(
                  config.copyWith(broadcastSmartMinimumDistance: val),
                ),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(
                  context,
                ).smartBroadcastMinIntervalLabel,
                value: config.broadcastSmartMinimumIntervalSecs,
                min: 0,
                configKey: 'position.broadcastSmartMinimumIntervalSecs',
                onChanged: (val) => onChanged(
                  config.copyWith(broadcastSmartMinimumIntervalSecs: val),
                ),
              ),
              ConfigFormHelpers.buildIntField(
                label: AppLocalizations.of(context).gpsEnableGpioLabel,
                value: config.gpsEnGpio,
                configKey: 'position.gpsEnGpio',
                onChanged: (val) => onChanged(config.copyWith(gpsEnGpio: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: AppLocalizations.of(context).gpsModeLabel,
                value: config.gpsMode,
                options: ['DISABLED', 'ENABLED', 'NOT_PRESENT'],
                configKey: 'position.gpsMode',
                onChanged: (val) => onChanged(config.copyWith(gpsMode: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openPowerConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.config?.power ?? const PowerConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<PowerConfigDto>(
          title: AppLocalizations.of(context).powerConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ConfigDto(power: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Power Saving',
                value: config.isPowerSaving,
                configKey: 'power.isPowerSaving',
                onChanged: (val) =>
                    onChanged(config.copyWith(isPowerSaving: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Shutdown After (seconds)',
                value: config.onBatteryShutdownAfterSecs,
                min: 0,
                configKey: 'power.onBatteryShutdownAfterSecs',
                onChanged: (val) =>
                    onChanged(config.copyWith(onBatteryShutdownAfterSecs: val)),
              ),
              ConfigFormHelpers.buildDoubleField(
                label: 'ADC Multiplier Override',
                value: config.adcMultiplierOverride,
                configKey: 'power.adcMultiplierOverride',
                onChanged: (val) =>
                    onChanged(config.copyWith(adcMultiplierOverride: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Wait Bluetooth (seconds)',
                value: config.waitBluetoothSecs,
                min: 0,
                configKey: 'power.waitBluetoothSecs',
                onChanged: (val) =>
                    onChanged(config.copyWith(waitBluetoothSecs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'SDS (seconds)',
                value: config.sdsSecs,
                min: 0,
                configKey: 'power.sdsSecs',
                onChanged: (val) => onChanged(config.copyWith(sdsSecs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'LS (seconds)',
                value: config.lsSecs,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(lsSecs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Min Wake (seconds)',
                value: config.minWakeSecs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(minWakeSecs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Device Battery INA Address',
                value: config.deviceBatteryInaAddress,
                onChanged: (val) =>
                    onChanged(config.copyWith(deviceBatteryInaAddress: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Powermon Enables',
                value: config.powermonEnables,
                onChanged: (val) =>
                    onChanged(config.copyWith(powermonEnables: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openNetworkConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.config?.network ?? const NetworkConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<NetworkConfigDto>(
          title: AppLocalizations.of(context).networkConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ConfigDto(network: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'WiFi Enabled',
                value: config.wifiEnabled,
                configKey: 'network.wifiEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(wifiEnabled: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'WiFi SSID',
                value: config.wifiSsid,
                configKey: 'network.wifiSsid',
                onChanged: (val) => onChanged(config.copyWith(wifiSsid: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'WiFi PSK',
                value: config.wifiPsk,
                obscureText: true,
                configKey: 'network.wifiPsk',
                onChanged: (val) => onChanged(config.copyWith(wifiPsk: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'NTP Server',
                value: config.ntpServer,
                configKey: 'network.ntpServer',
                onChanged: (val) => onChanged(config.copyWith(ntpServer: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Ethernet Enabled',
                value: config.ethEnabled,
                configKey: 'network.ethEnabled',
                onChanged: (val) => onChanged(config.copyWith(ethEnabled: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Address Mode',
                value: config.addressMode,
                options: ['DHCP', 'STATIC'],
                configKey: 'network.addressMode',
                onChanged: (val) =>
                    onChanged(config.copyWith(addressMode: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Rsyslog Server',
                value: config.rsyslogServer,
                configKey: 'network.rsyslogServer',
                onChanged: (val) =>
                    onChanged(config.copyWith(rsyslogServer: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'IPv6 Enabled',
                value: config.ipv6Enabled,
                configKey: 'network.ipv6Enabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(ipv6Enabled: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openDisplayConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.config?.display ?? const DisplayConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<DisplayConfigDto>(
          title: AppLocalizations.of(context).displayConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ConfigDto(display: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildIntField(
                label: 'Screen On (seconds)',
                value: config.screenOnSecs,
                min: 0,
                configKey: 'display.screenOnSecs',
                onChanged: (val) =>
                    onChanged(config.copyWith(screenOnSecs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Auto Screen Carousel (seconds)',
                value: config.autoScreenCarouselSecs,
                min: 0,
                configKey: 'display.autoScreenCarouselSecs',
                onChanged: (val) =>
                    onChanged(config.copyWith(autoScreenCarouselSecs: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Compass North Top',
                value: config.compassNorthTop,
                configKey: 'display.compassNorthTop',
                onChanged: (val) =>
                    onChanged(config.copyWith(compassNorthTop: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Flip Screen',
                value: config.flipScreen,
                configKey: 'display.flipScreen',
                onChanged: (val) => onChanged(config.copyWith(flipScreen: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Units',
                value: config.units,
                options: ['METRIC', 'IMPERIAL'],
                configKey: 'display.units',
                onChanged: (val) => onChanged(config.copyWith(units: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'OLED Type',
                value: config.oled,
                options: ['OLED_128x64', 'OLED_128x32', 'OLED_UNKNOWN'],
                configKey: 'display.oled',
                onChanged: (val) => onChanged(config.copyWith(oled: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Display Mode',
                value: config.displaymode,
                options: ['DEFAULT', 'TWOCOLOR', 'INVERTED', 'COLOR'],
                configKey: 'display.displaymode',
                onChanged: (val) =>
                    onChanged(config.copyWith(displaymode: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Heading Bold',
                value: config.headingBold,
                configKey: 'display.headingBold',
                onChanged: (val) =>
                    onChanged(config.copyWith(headingBold: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Wake on Tap or Motion',
                value: config.wakeOnTapOrMotion,
                configKey: 'display.wakeOnTapOrMotion',
                onChanged: (val) =>
                    onChanged(config.copyWith(wakeOnTapOrMotion: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Compass Orientation',
                value: config.compassOrientation,
                options: [
                  'DEGREES_0',
                  'DEGREES_90',
                  'DEGREES_180',
                  'DEGREES_270',
                ],
                configKey: 'display.compassOrientation',
                onChanged: (val) =>
                    onChanged(config.copyWith(compassOrientation: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Use 12h Clock',
                value: config.use12hClock,
                configKey: 'display.use12hClock',
                onChanged: (val) =>
                    onChanged(config.copyWith(use12hClock: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Use Long Node Name',
                value: config.useLongNodeName,
                configKey: 'display.useLongNodeName',
                onChanged: (val) =>
                    onChanged(config.copyWith(useLongNodeName: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openLoraConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.config?.lora ?? const LoRaConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<LoRaConfigDto>(
          title: AppLocalizations.of(context).loraConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ConfigDto(lora: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Use Preset',
                value: config.usePreset,
                configKey: 'lora.usePreset',
                onChanged: (val) => onChanged(config.copyWith(usePreset: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Modem Preset',
                value: config.modemPreset,
                options: [
                  'LONG_FAST',
                  'LONG_SLOW',
                  'VERY_LONG_SLOW',
                  'MEDIUM_SLOW',
                  'MEDIUM_FAST',
                  'SHORT_SLOW',
                  'SHORT_FAST',
                  'LONG_MODERATE',
                ],
                configKey: 'lora.modemPreset',
                onChanged: (val) =>
                    onChanged(config.copyWith(modemPreset: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Bandwidth',
                value: config.bandwidth,
                min: 0,
                configKey: 'lora.bandwidth',
                onChanged: (val) => onChanged(config.copyWith(bandwidth: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Spread Factor',
                value: config.spreadFactor,
                min: 0,
                configKey: 'lora.spreadFactor',
                onChanged: (val) =>
                    onChanged(config.copyWith(spreadFactor: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Coding Rate',
                value: config.codingRate,
                min: 0,
                configKey: 'lora.codingRate',
                onChanged: (val) => onChanged(config.copyWith(codingRate: val)),
              ),
              ConfigFormHelpers.buildDoubleField(
                label: 'Frequency Offset',
                value: config.frequencyOffset,
                configKey: 'lora.frequencyOffset',
                onChanged: (val) =>
                    onChanged(config.copyWith(frequencyOffset: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Region',
                value: config.region,
                options: [
                  'UNSET',
                  'US',
                  'EU_433',
                  'EU_868',
                  'CN',
                  'JP',
                  'ANZ',
                  'KR',
                  'TW',
                  'RU',
                  'IN',
                  'NZ_865',
                  'TH',
                  'LORA_24',
                  'UA_433',
                  'UA_868',
                  'MY_433',
                  'MY_919',
                  'SG_923',
                ],
                configKey: 'lora.region',
                onChanged: (val) => onChanged(config.copyWith(region: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Hop Limit',
                value: config.hopLimit,
                min: 0,
                configKey: 'lora.hopLimit',
                onChanged: (val) => onChanged(config.copyWith(hopLimit: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'TX Enabled',
                value: config.txEnabled,
                configKey: 'lora.txEnabled',
                onChanged: (val) => onChanged(config.copyWith(txEnabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'TX Power',
                value: config.txPower,
                configKey: 'lora.txPower',
                onChanged: (val) => onChanged(config.copyWith(txPower: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Channel Utilization Limit',
                value: config.channelNum,
                configKey: 'lora.channelNum',
                onChanged: (val) => onChanged(config.copyWith(channelNum: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Override Duty Cycle',
                value: config.overrideDutyCycle,
                configKey: 'lora.overrideDutyCycle',
                onChanged: (val) =>
                    onChanged(config.copyWith(overrideDutyCycle: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'SX126x RX Boosted Gain',
                value: config.sx126xRxBoostedGain,
                configKey: 'lora.sx126xRxBoostedGain',
                onChanged: (val) =>
                    onChanged(config.copyWith(sx126xRxBoostedGain: val)),
              ),
              ConfigFormHelpers.buildDoubleField(
                label: 'Override Frequency',
                value: config.overrideFrequency,
                configKey: 'lora.overrideFrequency',
                onChanged: (val) =>
                    onChanged(config.copyWith(overrideFrequency: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'PA Fan Disabled',
                value: config.paFanDisabled,
                configKey: 'lora.paFanDisabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(paFanDisabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Ignore MQTT',
                value: config.ignoreMqtt,
                configKey: 'lora.ignoreMqtt',
                onChanged: (val) => onChanged(config.copyWith(ignoreMqtt: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Config OK to MQTT',
                value: config.configOkToMqtt,
                configKey: 'lora.configOkToMqtt',
                onChanged: (val) =>
                    onChanged(config.copyWith(configOkToMqtt: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openBluetoothConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.config?.bluetooth ?? const BluetoothConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<BluetoothConfigDto>(
          title: AppLocalizations.of(context).bluetoothConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ConfigDto(bluetooth: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Mode',
                value: config.mode,
                options: ['FIXED_PIN', 'RANDOM_PIN', 'NO_PIN'],
                configKey: 'bluetooth.mode',
                onChanged: (val) => onChanged(config.copyWith(mode: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Fixed Pin',
                value: config.fixedPin,
                configKey: 'bluetooth.fixedPin',
                onChanged: (val) => onChanged(config.copyWith(fixedPin: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openSecurityConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.config?.security ?? const SecurityConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<SecurityConfigDto>(
          title: AppLocalizations.of(context).securityConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ConfigDto(security: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildTextField(
                label: 'Public Key (Base64)',
                value: config.publicKey != null
                    ? base64Encode(config.publicKey!)
                    : '',
                configKey: 'security.publicKey',
                onChanged: (val) {
                  try {
                    onChanged(config.copyWith(publicKey: base64Decode(val)));
                  } catch (_) {}
                },
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Private Key (Base64)',
                value: config.privateKey != null
                    ? base64Encode(config.privateKey!)
                    : '',
                obscureText: true,
                configKey: 'security.privateKey',
                onChanged: (val) {
                  try {
                    onChanged(config.copyWith(privateKey: base64Decode(val)));
                  } catch (_) {}
                },
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Admin Key (Base64, comma separated)',
                value:
                    config.adminKey?.map((k) => base64Encode(k)).join(',') ??
                    '',
                configKey: 'security.adminKey',
                onChanged: (val) {
                  try {
                    final list = val
                        .split(',')
                        .map((e) => base64Decode(e.trim()))
                        .toList();
                    onChanged(config.copyWith(adminKey: list));
                  } catch (_) {}
                },
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Is Managed',
                value: config.isManaged,
                configKey: 'security.isManaged',
                onChanged: (val) => onChanged(config.copyWith(isManaged: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Serial Enabled',
                value: config.serialEnabled,
                configKey: 'security.serialEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(serialEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Debug Log API Enabled',
                value: config.debugLogApiEnabled,
                configKey: 'security.debugLogApiEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(debugLogApiEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Admin Channel Enabled',
                value: config.adminChannelEnabled,
                configKey: 'security.adminChannelEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(adminChannelEnabled: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openMqttConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.moduleConfig?.mqtt ?? const MqttConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<MqttConfigDto>(
          title: AppLocalizations.of(context).mqttConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(mqtt: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Address',
                value: config.address,
                configKey: 'mqtt.address',
                onChanged: (val) => onChanged(config.copyWith(address: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Username',
                value: config.username,
                configKey: 'mqtt.username',
                onChanged: (val) => onChanged(config.copyWith(username: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Password',
                value: config.password,
                obscureText: true,
                configKey: 'mqtt.password',
                onChanged: (val) => onChanged(config.copyWith(password: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Encryption Enabled',
                value: config.encryptionEnabled,
                configKey: 'mqtt.encryptionEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(encryptionEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'JSON Enabled',
                value: config.jsonEnabled,
                configKey: 'mqtt.jsonEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(jsonEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'TLS Enabled',
                value: config.tlsEnabled,
                configKey: 'mqtt.tlsEnabled',
                onChanged: (val) => onChanged(config.copyWith(tlsEnabled: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Root Topic',
                value: config.root,
                configKey: 'mqtt.root',
                onChanged: (val) => onChanged(config.copyWith(root: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Proxy to Client Enabled',
                value: config.proxyToClientEnabled,
                configKey: 'mqtt.proxyToClientEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(proxyToClientEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Map Reporting Enabled',
                value: config.mapReportingEnabled,
                configKey: 'mqtt.mapReportingEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(mapReportingEnabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Map Report Position Precision',
                value: config.mapReportSettings?.positionPrecision,
                configKey: 'mqtt.mapReportPositionPrecision',
                onChanged: (val) {
                  final currentSettings =
                      config.mapReportSettings ?? const MapReportSettingsDto();
                  onChanged(
                    config.copyWith(
                      mapReportSettings: MapReportSettingsDto(
                        publishIntervalSecs:
                            currentSettings.publishIntervalSecs,
                        positionPrecision: val,
                        shouldReportLocation:
                            currentSettings.shouldReportLocation,
                      ),
                    ),
                  );
                },
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Map Report Publish Interval (seconds)',
                value: config.mapReportSettings?.publishIntervalSecs,
                configKey: 'mqtt.mapReportPublishIntervalSecs',
                onChanged: (val) {
                  final currentSettings =
                      config.mapReportSettings ?? const MapReportSettingsDto();
                  onChanged(
                    config.copyWith(
                      mapReportSettings: MapReportSettingsDto(
                        publishIntervalSecs: val,
                        positionPrecision: currentSettings.positionPrecision,
                        shouldReportLocation:
                            currentSettings.shouldReportLocation,
                      ),
                    ),
                  );
                },
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openTelemetryConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.telemetry ?? const TelemetryConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<TelemetryConfigDto>(
          title: AppLocalizations.of(context).telemetryConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(telemetry: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildIntField(
                label: 'Device Update Interval (seconds)',
                value: config.deviceUpdateInterval,
                min: 0,
                configKey: 'telemetry.deviceUpdateInterval',
                onChanged: (val) =>
                    onChanged(config.copyWith(deviceUpdateInterval: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Environment Update Interval (seconds)',
                value: config.environmentUpdateInterval,
                min: 0,
                configKey: 'telemetry.environmentUpdateInterval',
                onChanged: (val) =>
                    onChanged(config.copyWith(environmentUpdateInterval: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Environment Measurement Enabled',
                value: config.environmentMeasurementEnabled,
                configKey: 'telemetry.environmentMeasurementEnabled',
                onChanged: (val) => onChanged(
                  config.copyWith(environmentMeasurementEnabled: val),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Environment Screen Enabled',
                value: config.environmentScreenEnabled,
                configKey: 'telemetry.environmentScreenEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(environmentScreenEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Environment Display Fahrenheit',
                value: config.environmentDisplayFahrenheit,
                configKey: 'telemetry.environmentDisplayFahrenheit',
                onChanged: (val) => onChanged(
                  config.copyWith(environmentDisplayFahrenheit: val),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Air Quality Enabled',
                value: config.airQualityEnabled,
                configKey: 'telemetry.airQualityEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(airQualityEnabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Air Quality Interval (seconds)',
                value: config.airQualityInterval,
                min: 0,
                configKey: 'telemetry.airQualityInterval',
                onChanged: (val) =>
                    onChanged(config.copyWith(airQualityInterval: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Power Measurement Enabled',
                value: config.powerMeasurementEnabled,
                configKey: 'telemetry.powerMeasurementEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(powerMeasurementEnabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Power Update Interval (seconds)',
                value: config.powerUpdateInterval,
                min: 0,
                configKey: 'telemetry.powerUpdateInterval',
                onChanged: (val) =>
                    onChanged(config.copyWith(powerUpdateInterval: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Power Screen Enabled',
                value: config.powerScreenEnabled,
                configKey: 'telemetry.powerScreenEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(powerScreenEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Health Measurement Enabled',
                value: config.healthMeasurementEnabled,
                configKey: 'telemetry.healthMeasurementEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(healthMeasurementEnabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Health Update Interval (seconds)',
                value: config.healthUpdateInterval,
                min: 0,
                configKey: 'telemetry.healthUpdateInterval',
                onChanged: (val) =>
                    onChanged(config.copyWith(healthUpdateInterval: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Health Screen Enabled',
                value: config.healthScreenEnabled,
                configKey: 'telemetry.healthScreenEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(healthScreenEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Device Telemetry Enabled',
                value: config.deviceTelemetryEnabled,
                configKey: 'telemetry.deviceTelemetryEnabled',
                onChanged: (val) =>
                    onChanged(config.copyWith(deviceTelemetryEnabled: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openSerialConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.moduleConfig?.serial ?? const SerialConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<SerialConfigDto>(
          title: AppLocalizations.of(context).serialConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(serial: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                configKey: 'serial.enabled',
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Echo',
                value: config.echo,
                configKey: 'serial.echo',
                onChanged: (val) => onChanged(config.copyWith(echo: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'RXD',
                value: config.rxd,
                configKey: 'serial.rxd',
                onChanged: (val) => onChanged(config.copyWith(rxd: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'TXD',
                value: config.txd,
                configKey: 'serial.txd',
                onChanged: (val) => onChanged(config.copyWith(txd: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Baud Rate',
                value: config.baud,
                options: [
                  'BAUD_115200',
                  'BAUD_19200',
                  'BAUD_9600',
                  'BAUD_57600',
                  'BAUD_230400',
                  'BAUD_460800',
                  'BAUD_921600',
                ],
                configKey: 'serial.baud',
                onChanged: (val) => onChanged(config.copyWith(baud: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Timeout (seconds)',
                value: config.timeout,
                min: 0,
                configKey: 'serial.timeout',
                onChanged: (val) => onChanged(config.copyWith(timeout: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Mode',
                value: config.mode,
                options: [
                  'DEFAULT',
                  'SIMPLE',
                  'PROTO',
                  'TEXTMSG',
                  'NMEA',
                  'CALIBRATION',
                  'WIFI',
                  'IP',
                  'MAVLINK',
                ],
                configKey: 'serial.mode',
                onChanged: (val) => onChanged(config.copyWith(mode: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Override Console Serial Port',
                value: config.overrideConsoleSerialPort,
                configKey: 'serial.overrideConsoleSerialPort',
                onChanged: (val) =>
                    onChanged(config.copyWith(overrideConsoleSerialPort: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openStoreForwardConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.storeForward ?? const StoreForwardConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<StoreForwardConfigDto>(
          title: AppLocalizations.of(context).storeForwardConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(storeForward: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Heartbeat',
                value: config.heartbeat,
                onChanged: (val) => onChanged(config.copyWith(heartbeat: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Records',
                value: config.records,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(records: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'History Return Max',
                value: config.historyReturnMax,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(historyReturnMax: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'History Return Window',
                value: config.historyReturnWindow,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(historyReturnWindow: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Is Server',
                value: config.isServer,
                onChanged: (val) => onChanged(config.copyWith(isServer: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Emit Control Signals',
                value: config.emitControlSignals,
                onChanged: (val) =>
                    onChanged(config.copyWith(emitControlSignals: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openRangeTestConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.rangeTest ?? const RangeTestConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<RangeTestConfigDto>(
          title: AppLocalizations.of(context).rangeTestConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(rangeTest: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Sender',
                value: config.sender,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(sender: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Save',
                value: config.save,
                onChanged: (val) => onChanged(config.copyWith(save: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Clear on Reboot',
                value: config.clearOnReboot,
                onChanged: (val) =>
                    onChanged(config.copyWith(clearOnReboot: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openExternalNotificationConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.externalNotification ??
        const ExternalNotificationConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<ExternalNotificationConfigDto>(
          title: AppLocalizations.of(context).externalNotificationConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(
              externalNotification: updatedConfig,
            );
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Output MS',
                value: config.outputMs,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(outputMs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Output',
                value: config.output,
                onChanged: (val) => onChanged(config.copyWith(output: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Active',
                value: config.active,
                onChanged: (val) => onChanged(config.copyWith(active: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Alert Message',
                value: config.alertMessage,
                onChanged: (val) =>
                    onChanged(config.copyWith(alertMessage: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Alert Bell',
                value: config.alertBell,
                onChanged: (val) => onChanged(config.copyWith(alertBell: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Use PWM',
                value: config.usePwm,
                onChanged: (val) => onChanged(config.copyWith(usePwm: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Output Vibra',
                value: config.outputVibra,
                onChanged: (val) =>
                    onChanged(config.copyWith(outputVibra: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Output Buzzer',
                value: config.outputBuzzer,
                onChanged: (val) =>
                    onChanged(config.copyWith(outputBuzzer: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Alert Message Vibra',
                value: config.alertMessageVibra,
                onChanged: (val) =>
                    onChanged(config.copyWith(alertMessageVibra: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Alert Message Buzzer',
                value: config.alertMessageBuzzer,
                onChanged: (val) =>
                    onChanged(config.copyWith(alertMessageBuzzer: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Alert Bell Vibra',
                value: config.alertBellVibra,
                onChanged: (val) =>
                    onChanged(config.copyWith(alertBellVibra: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Alert Bell Buzzer',
                value: config.alertBellBuzzer,
                onChanged: (val) =>
                    onChanged(config.copyWith(alertBellBuzzer: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Nag Timeout (seconds)',
                value: config.nagTimeout,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(nagTimeout: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Use I2S as Buzzer',
                value: config.useI2sAsBuzzer,
                onChanged: (val) =>
                    onChanged(config.copyWith(useI2sAsBuzzer: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openAudioConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig = state.moduleConfig?.audio ?? const AudioConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<AudioConfigDto>(
          title: AppLocalizations.of(context).audioConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(audio: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Codec2 Enabled',
                value: config.codec2Enabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(codec2Enabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'PTT Pin',
                value: config.pttPin,
                onChanged: (val) => onChanged(config.copyWith(pttPin: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Bitrate',
                value: config.bitrate,
                options: [
                  'AT_DEFAULT',
                  'AT_3200',
                  'AT_2400',
                  'AT_1600',
                  'AT_1400',
                  'AT_1300',
                  'AT_1200',
                  'AT_700',
                  'AT_450',
                ], // Assuming these are valid options
                onChanged: (val) => onChanged(config.copyWith(bitrate: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'I2S WS',
                value: config.i2sWs,
                onChanged: (val) => onChanged(config.copyWith(i2sWs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'I2S SD',
                value: config.i2sSd,
                onChanged: (val) => onChanged(config.copyWith(i2sSd: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'I2S DIN',
                value: config.i2sDin,
                onChanged: (val) => onChanged(config.copyWith(i2sDin: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'I2S SCK',
                value: config.i2sSck,
                onChanged: (val) => onChanged(config.copyWith(i2sSck: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openNeighborInfoConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.neighborInfo ?? const NeighborInfoConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<NeighborInfoConfigDto>(
          title: AppLocalizations.of(context).neighborInfoConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(neighborInfo: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Update Interval (seconds)',
                value: config.updateInterval,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(updateInterval: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Transmit Over LoRa',
                value: config.transmitOverLora,
                onChanged: (val) =>
                    onChanged(config.copyWith(transmitOverLora: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openRemoteHardwareConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.remoteHardware ?? const RemoteHardwareConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<RemoteHardwareConfigDto>(
          title: AppLocalizations.of(context).remoteHardwareConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(remoteHardware: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Allow Undefined Pin Access',
                value: config.allowUndefinedPinAccess,
                onChanged: (val) =>
                    onChanged(config.copyWith(allowUndefinedPinAccess: val)),
              ),
              // Available Pins editing skipped for now as it's a list
            ];
          },
        ),
      ),
    );
  }

  void _openPaxcounterConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.paxcounter ?? const PaxcounterConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<PaxcounterConfigDto>(
          title: AppLocalizations.of(context).paxcounterConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(paxcounter: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Update Interval (seconds)',
                value: config.paxcounterUpdateInterval,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(paxcounterUpdateInterval: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'WiFi Threshold',
                value: config.wifiThreshold,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(wifiThreshold: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'BLE Threshold',
                value: config.bleThreshold,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(bleThreshold: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openCannedMessageConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.cannedMessage ?? const CannedMessageConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<CannedMessageConfigDto>(
          title: AppLocalizations.of(context).cannedMessageConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(cannedMessage: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Rotary1 Enabled',
                value: config.rotary1Enabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(rotary1Enabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Input Broker Pin A',
                value: config.inputbrokerPinA,
                onChanged: (val) =>
                    onChanged(config.copyWith(inputbrokerPinA: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Input Broker Pin B',
                value: config.inputbrokerPinB,
                onChanged: (val) =>
                    onChanged(config.copyWith(inputbrokerPinB: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Input Broker Pin Press',
                value: config.inputbrokerPinPress,
                onChanged: (val) =>
                    onChanged(config.copyWith(inputbrokerPinPress: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Input Broker Event CW',
                value: config.inputbrokerEventCw,
                options: [
                  'NONE',
                  'PRESS',
                  'LONG_PRESS',
                  'DOUBLE_PRESS',
                ], // Assuming these are valid options
                onChanged: (val) =>
                    onChanged(config.copyWith(inputbrokerEventCw: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Input Broker Event CCW',
                value: config.inputbrokerEventCcw,
                options: ['NONE', 'PRESS', 'LONG_PRESS', 'DOUBLE_PRESS'],
                onChanged: (val) =>
                    onChanged(config.copyWith(inputbrokerEventCcw: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Input Broker Event Press',
                value: config.inputbrokerEventPress,
                options: ['NONE', 'PRESS', 'LONG_PRESS', 'DOUBLE_PRESS'],
                onChanged: (val) =>
                    onChanged(config.copyWith(inputbrokerEventPress: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Up/Down 1 Enabled',
                value: config.updown1Enabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(updown1Enabled: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Allow Input Source',
                value: config.allowInputSource,
                options: [
                  'ALL',
                  'LOCAL_ONLY',
                  'REMOTE_ONLY',
                ], // Assuming these are valid options
                onChanged: (val) =>
                    onChanged(config.copyWith(allowInputSource: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Send Bell',
                value: config.sendBell,
                onChanged: (val) => onChanged(config.copyWith(sendBell: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openAmbientLightingConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.ambientLighting ?? const AmbientLightingConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<AmbientLightingConfigDto>(
          title: AppLocalizations.of(context).ambientLightingConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(ambientLighting: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'LED State',
                value: config.ledState,
                onChanged: (val) => onChanged(config.copyWith(ledState: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Current',
                value: config.current,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(current: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Red',
                value: config.red,
                min: 0,
                max: 255,
                onChanged: (val) => onChanged(config.copyWith(red: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Green',
                value: config.green,
                min: 0,
                max: 255,
                onChanged: (val) => onChanged(config.copyWith(green: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Blue',
                value: config.blue,
                min: 0,
                max: 255,
                onChanged: (val) => onChanged(config.copyWith(blue: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openDetectionSensorConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.detectionSensor ?? const DetectionSensorConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<DetectionSensorConfigDto>(
          title: AppLocalizations.of(context).detectionSensorConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(detectionSensor: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Minimum Broadcast (seconds)',
                value: config.minimumBroadcastSecs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(minimumBroadcastSecs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'State Broadcast (seconds)',
                value: config.stateBroadcastSecs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(stateBroadcastSecs: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Send Bell',
                value: config.sendBell,
                onChanged: (val) => onChanged(config.copyWith(sendBell: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Name',
                value: config.name,
                onChanged: (val) => onChanged(config.copyWith(name: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Monitor Pin',
                value: config.monitorPin,
                onChanged: (val) => onChanged(config.copyWith(monitorPin: val)),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Detection Trigger Type',
                value: config.detectionTriggerType,
                options: [
                  'LOGIC_LOW',
                  'LOGIC_HIGH',
                  'FALLING_EDGE',
                  'RISING_EDGE',
                  'EITHER_EDGE',
                ], // Assuming these are valid options
                onChanged: (val) =>
                    onChanged(config.copyWith(detectionTriggerType: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Use Pullup',
                value: config.usePullup,
                onChanged: (val) => onChanged(config.copyWith(usePullup: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openDtnOverlayConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.dtnOverlay ?? const DtnOverlayConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<DtnOverlayConfigDto>(
          title: AppLocalizations.of(context).dtnOverlayConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(dtnOverlay: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'TTL Minutes',
                value: config.ttlMinutes,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(ttlMinutes: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Initial Delay Base MS',
                value: config.initialDelayBaseMs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(initialDelayBaseMs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Retry Backoff MS',
                value: config.retryBackoffMs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(retryBackoffMs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Max Tries',
                value: config.maxTries,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(maxTries: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Late Fallback Enabled',
                value: config.lateFallbackEnabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(lateFallbackEnabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Fallback Tail Percent',
                value: config.fallbackTailPercent,
                min: 0,
                max: 100,
                onChanged: (val) =>
                    onChanged(config.copyWith(fallbackTailPercent: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Milestones Enabled',
                value: config.milestonesEnabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(milestonesEnabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Per Dest Min Spacing MS',
                value: config.perDestMinSpacingMs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(perDestMinSpacingMs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Max Active DM',
                value: config.maxActiveDm,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(maxActiveDm: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Probe FW+ Near Deadline',
                value: config.probeFwplusNearDeadline,
                onChanged: (val) =>
                    onChanged(config.copyWith(probeFwplusNearDeadline: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openBroadcastAssistConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.broadcastAssist ?? const BroadcastAssistConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<BroadcastAssistConfigDto>(
          title: AppLocalizations.of(context).broadcastAssistConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(broadcastAssist: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Enabled',
                value: config.enabled,
                onChanged: (val) => onChanged(config.copyWith(enabled: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Degree Threshold',
                value: config.degreeThreshold,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(degreeThreshold: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Dup Threshold',
                value: config.dupThreshold,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(dupThreshold: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Window MS',
                value: config.windowMs,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(windowMs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Max Extra Hops',
                value: config.maxExtraHops,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(maxExtraHops: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Jitter MS',
                value: config.jitterMs,
                min: 0,
                onChanged: (val) => onChanged(config.copyWith(jitterMs: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Airtime Guard',
                value: config.airtimeGuard,
                onChanged: (val) =>
                    onChanged(config.copyWith(airtimeGuard: val)),
              ),
              // Allowed Ports editing skipped for now as it's a list
            ];
          },
        ),
      ),
    );
  }

  void _openNodeModConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.nodeMod ?? const NodeModConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<NodeModConfigDto>(
          title: AppLocalizations.of(context).nodeModConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(nodeMod: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildTextField(
                label: 'Text Status',
                value: config.textStatus,
                onChanged: (val) => onChanged(config.copyWith(textStatus: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Emoji',
                value: config.emoji,
                onChanged: (val) => onChanged(config.copyWith(emoji: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openNodeModAdminConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.nodeModAdmin ?? const NodeModAdminConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<NodeModAdminConfigDto>(
          title: AppLocalizations.of(context).nodeModAdminConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(nodeModAdmin: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildCheckbox(
                label: 'Sniffer Enabled',
                value: config.snifferEnabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(snifferEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Do Not Send Private Messages Over MQTT',
                value: config.doNotSendPrvOverMqtt,
                onChanged: (val) =>
                    onChanged(config.copyWith(doNotSendPrvOverMqtt: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Local Stats Over Mesh Enabled',
                value: config.localStatsOverMeshEnabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(localStatsOverMeshEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Local Stats Extended Over Mesh Enabled',
                value: config.localStatsExtendedOverMeshEnabled,
                onChanged: (val) => onChanged(
                  config.copyWith(localStatsExtendedOverMeshEnabled: val),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Idle Game Enabled',
                value: config.idlegameEnabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(idlegameEnabled: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Auto Responder Enabled',
                value: config.autoResponderEnabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(autoResponderEnabled: val)),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'Auto Responder Text',
                value: config.autoResponderText,
                onChanged: (val) =>
                    onChanged(config.copyWith(autoResponderText: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Auto Redirect Messages',
                value: config.autoRedirectMessages,
                onChanged: (val) =>
                    onChanged(config.copyWith(autoRedirectMessages: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Auto Redirect Target Node ID',
                value: config.autoRedirectTargetNodeId,
                onChanged: (val) =>
                    onChanged(config.copyWith(autoRedirectTargetNodeId: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Telemetry Limiter Enabled',
                value: config.telemetryLimiterEnabled,
                onChanged: (val) =>
                    onChanged(config.copyWith(telemetryLimiterEnabled: val)),
              ),

              ConfigFormHelpers.buildCheckbox(
                label: 'Opportunistic Flooding Enabled',
                value: config.opportunisticFloodingEnabled,
                onChanged: (val) => onChanged(
                  config.copyWith(opportunisticFloodingEnabled: val),
                ),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Opportunistic Base Delay MS',
                value: config.opportunisticBaseDelayMs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(opportunisticBaseDelayMs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Opportunistic Hop Delay MS',
                value: config.opportunisticHopDelayMs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(opportunisticHopDelayMs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Opportunistic SNR Gain MS',
                value: config.opportunisticSnrGainMs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(opportunisticSnrGainMs: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Opportunistic Jitter MS',
                value: config.opportunisticJitterMs,
                min: 0,
                onChanged: (val) =>
                    onChanged(config.copyWith(opportunisticJitterMs: val)),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Opportunistic Cancel on First Hear',
                value: config.opportunisticCancelOnFirstHear,
                onChanged: (val) => onChanged(
                  config.copyWith(opportunisticCancelOnFirstHear: val),
                ),
              ),

              ConfigFormHelpers.buildCheckbox(
                label: 'Opportunistic Auto',
                value: config.opportunisticAuto,
                onChanged: (val) =>
                    onChanged(config.copyWith(opportunisticAuto: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openIdleGameConfigEdit(BuildContext context) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    final currentConfig =
        state.moduleConfig?.idleGame ?? const IdleGameConfigDto();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<IdleGameConfigDto>(
          title: AppLocalizations.of(context).idleGameConfig,
          config: currentConfig,
          onSave: (updatedConfig) async {
            final newConfig = ModuleConfigDto(idleGame: updatedConfig);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendModuleConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            return [
              ConfigFormHelpers.buildTextField(
                label: 'Variant',
                value: config.variant,
                onChanged: (val) => onChanged(config.copyWith(variant: val)),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _openChannelConfigEdit(BuildContext context, ChannelDto channel) async {
    if (deviceId == null) return;

    final client =
        DeviceStatusStore.instance.statusNow(deviceId!)?.state ==
            DeviceConnectionState.connected
        ? await DeviceStatusStore.instance.connectToId(deviceId!)
        : null;

    if (client == null || !context.mounted) return;

    // Request session key to ensure we can save changes
    await client.requestSessionKey(state.myNodeInfo?.myNodeNum);
    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigEditPage<ChannelDto>(
          title: '${AppLocalizations.of(context).channel} ${channel.index}',
          config: channel,
          onSave: (updatedConfig) async {
            // We need to ensure the index is preserved as it might not be editable or could be lost
            final newConfig = updatedConfig.copyWith(index: channel.index);
            await client.beginEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.sendChannelConfig(
              newConfig,
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
            await client.commitEditSettings(
              sessionPasskey: state.sessionPasskey,
              nodeId: state.myNodeInfo?.myNodeNum,
            );
          },
          buildFields: (context, config, onChanged) {
            final settings = config.settings ?? const ChannelSettingsDto();
            return [
              ConfigFormHelpers.buildTextField(
                label: 'Name',
                value: settings.name,
                onChanged: (val) => onChanged(
                  config.copyWith(settings: settings.copyWith(name: val)),
                ),
              ),
              ConfigFormHelpers.buildTextField(
                label: 'PSK (Base64)',
                value: settings.psk != null ? base64Encode(settings.psk!) : '',
                onChanged: (val) {
                  try {
                    final bytes = base64Decode(val);
                    onChanged(
                      config.copyWith(settings: settings.copyWith(psk: bytes)),
                    );
                  } catch (_) {
                    // Ignore invalid base64 input
                  }
                },
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Uplink Enabled',
                value: settings.uplinkEnabled,
                onChanged: (val) => onChanged(
                  config.copyWith(
                    settings: settings.copyWith(uplinkEnabled: val),
                  ),
                ),
              ),
              ConfigFormHelpers.buildCheckbox(
                label: 'Downlink Enabled',
                value: settings.downlinkEnabled,
                onChanged: (val) => onChanged(
                  config.copyWith(
                    settings: settings.copyWith(downlinkEnabled: val),
                  ),
                ),
              ),
              ConfigFormHelpers.buildEnumDropdown(
                label: 'Role',
                value: config.role,
                options: ['DISABLED', 'PRIMARY', 'SECONDARY'],
                onChanged: (val) => onChanged(config.copyWith(role: val)),
              ),
              ConfigFormHelpers.buildIntField(
                label: 'Position Precision',
                value: settings.moduleSettings?.positionPrecision,
                onChanged: (val) => onChanged(
                  config.copyWith(
                    settings: settings.copyWith(
                      moduleSettings:
                          (settings.moduleSettings ?? const ModuleSettingsDto())
                              .copyWith(positionPrecision: val),
                    ),
                  ),
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;
  const _Section({required this.title, required this.children, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(title)),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: AppLocalizations.of(context).editTooltip,
              ),
          ],
        ),
        initiallyExpanded: false,
        children: children,
      ),
    );
  }
}
