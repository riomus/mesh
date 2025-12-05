// ignore_for_file: deprecated_member_use_from_same_package, deprecated_member_use
// We intentionally access some deprecated members from generated protobufs to
// preserve compatibility with older device firmware. Upstream protos may keep
// deprecated fields during transitions; our mapper reads them for best‑effort
// decoding and to support a wider range of devices.
import 'dart:convert';
import 'dart:typed_data';

import '../../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../../generated/meshtastic/meshtastic/portnums.pbenum.dart' as port;
import '../../generated/meshtastic/meshtastic/module_config.pb.dart' as module;
import '../../generated/meshtastic/meshtastic/device_ui.pb.dart' as dui;
import '../../generated/meshtastic/meshtastic/config.pb.dart' as cfgpb;
import '../../generated/meshtastic/meshtastic/admin.pb.dart' as admin;
import '../../generated/meshtastic/meshtastic/telemetry.pb.dart' as telem;
import '../../generated/meshtastic/meshtastic/remote_hardware.pb.dart' as rhw;
import '../../generated/meshtastic/meshtastic/storeforward.pb.dart' as sfwd;
import '../../generated/meshtastic/meshtastic/paxcount.pb.dart' as pax;
import '../../generated/meshtastic/meshtastic/channel.pb.dart' as channel;
import 'meshtastic_event.dart';
import 'meshtastic_models.dart';

/// Helpers to convert protobuf messages to domain events and decoded payloads
/// without exposing any protobuf-generated types to consumers.
class MeshtasticMappers {
  static MeshtasticEvent fromFromRadio(mesh.FromRadio fr) {
    switch (fr.whichPayloadVariant()) {
      case mesh.FromRadio_PayloadVariant.packet:
        final pkt = _toMeshPacketDto(fr.packet);
        return MeshPacketEvent(
          packet: pkt,
          decoded: pkt.decoded,
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.myInfo:
        final mi = fr.myInfo;
        return MyInfoEvent(
          MyInfoDto(
            myNodeNum: mi.hasMyNodeNum() ? mi.myNodeNum : null,
            rebootCount: mi.hasRebootCount() ? mi.rebootCount : null,
            minAppVersion: mi.hasMinAppVersion() ? mi.minAppVersion : null,
            deviceId: mi.hasDeviceId() ? Uint8List.fromList(mi.deviceId) : null,
            pioEnv: mi.hasPioEnv() ? mi.pioEnv : null,
            firmwareEdition: mi.hasFirmwareEdition()
                ? mi.firmwareEdition.name
                : null,
            nodedbCount: mi.hasNodedbCount() ? mi.nodedbCount : null,
          ),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.nodeInfo:
        final n = fr.nodeInfo;
        return NodeInfoEvent(
          NodeInfoDto(
            num: n.hasNum() ? n.num : null,
            user: n.hasUser() ? _toUserDto(n.user) : null,
            position: n.hasPosition() ? _toPositionDto(n.position) : null,
            snr: n.hasSnr() ? n.snr : null,
            lastHeard: n.hasLastHeard() ? n.lastHeard : null,
            deviceMetrics: n.hasDeviceMetrics()
                ? _toDeviceMetricsDto(n.deviceMetrics)
                : null,
            channel: n.hasChannel() ? n.channel : null,
            viaMqtt: n.hasViaMqtt() ? n.viaMqtt : null,
            hopsAway: n.hasHopsAway() ? n.hopsAway : null,
            isFavorite: n.hasIsFavorite() ? n.isFavorite : null,
            isIgnored: n.hasIsIgnored() ? n.isIgnored : null,
            isKeyManuallyVerified: n.hasIsKeyManuallyVerified()
                ? n.isKeyManuallyVerified
                : null,
          ),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.config:
        return ConfigEvent(
          _toConfigDto(fr.config),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.logRecord:
        return LogRecordEvent(
          LogRecordDto(
            level: fr.logRecord.hasLevel() ? fr.logRecord.level.name : null,
            message: fr.logRecord.hasMessage() ? fr.logRecord.message : null,
            source: fr.logRecord.hasSource() ? fr.logRecord.source : null,
          ),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.configCompleteId:
        return ConfigCompleteEvent(
          fr.configCompleteId,
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.rebooted:
        return RebootedEvent(fr.rebooted, id: fr.hasId() ? fr.id : null);
      case mesh.FromRadio_PayloadVariant.moduleConfig:
        return ModuleConfigEvent(
          _toModuleConfigDto(fr.moduleConfig),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.channel:
        return ChannelEvent(
          _toChannelDto(fr.channel),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.queueStatus:
        return QueueStatusEvent(
          QueueStatusDto(
            res: fr.queueStatus.hasRes() ? fr.queueStatus.res : null,
            free: fr.queueStatus.hasFree() ? fr.queueStatus.free : null,
            maxlen: fr.queueStatus.hasMaxlen() ? fr.queueStatus.maxlen : null,
            meshPacketId: fr.queueStatus.hasMeshPacketId()
                ? fr.queueStatus.meshPacketId
                : null,
          ),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.metadata:
        final m = fr.metadata;
        return DeviceMetadataEvent(
          DeviceMetadataDto(
            firmwareVersion: m.hasFirmwareVersion() ? m.firmwareVersion : null,
            deviceStateVersion: m.hasDeviceStateVersion()
                ? m.deviceStateVersion
                : null,
            canShutdown: m.hasCanShutdown() ? m.canShutdown : null,
            hasWifi: m.hasHasWifi() ? m.hasWifi : null,
            hasBluetooth: m.hasHasBluetooth() ? m.hasBluetooth : null,
            hasEthernet: m.hasHasEthernet() ? m.hasEthernet : null,
            role: m.hasRole() ? m.role.name : null,
            positionFlags: m.hasPositionFlags() ? m.positionFlags : null,
            hwModel: m.hasHwModel() ? m.hwModel.name : null,
            hasRemoteHardware: m.hasHasRemoteHardware()
                ? m.hasRemoteHardware
                : null,
            hasPKC: m.hasHasPKC() ? m.hasPKC : null,
            excludedModules: m.hasExcludedModules() ? m.excludedModules : null,
            hasFwPlus: m.hasHasFwPlus() ? m.hasFwPlus : null,
            hasNodemod: m.hasHasNodemod() ? m.hasNodemod : null,
          ),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.mqttClientProxyMessage:
        final mq = fr.mqttClientProxyMessage;
        return MqttClientProxyEvent(
          MqttClientProxyMessageDto(
            topic: mq.hasTopic() ? mq.topic : null,
            data: mq.hasData() ? Uint8List.fromList(mq.data) : null,
            text: mq.hasText() ? mq.text : null,
            retained: mq.hasRetained() ? mq.retained : null,
          ),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.fileInfo:
        return FileInfoEvent(
          FileInfoDto(
            fileName: fr.fileInfo.hasFileName() ? fr.fileInfo.fileName : null,
            sizeBytes: fr.fileInfo.hasSizeBytes()
                ? fr.fileInfo.sizeBytes
                : null,
          ),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.clientNotification:
        return ClientNotificationEvent(
          ClientNotificationDto(
            message: fr.clientNotification.hasMessage()
                ? fr.clientNotification.message
                : null,
            replyId: fr.clientNotification.hasReplyId()
                ? fr.clientNotification.replyId
                : null,
            time: fr.clientNotification.hasTime()
                ? fr.clientNotification.time.toInt()
                : null,
            level: fr.clientNotification.hasLevel()
                ? fr.clientNotification.level.name
                : null,
            payloadVariant: fr.clientNotification.whichPayloadVariant().name,
          ),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.deviceuiConfig:
        return DeviceUiConfigEvent(
          _toDeviceUiConfigDto(fr.deviceuiConfig),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.xmodemPacket:
        final x = fr.xmodemPacket;
        return XModemEvent(
          XModemDto(
            control: x.hasControl() ? x.control.name : null,
            seq: x.hasSeq() ? x.seq : null,
            crc16: x.hasCrc16() ? x.crc16 : null,
            buffer: x.hasBuffer() ? Uint8List.fromList(x.buffer) : null,
          ),
          id: fr.hasId() ? fr.id : null,
        );
      case mesh.FromRadio_PayloadVariant.notSet:
        return LogRecordEvent(
          const LogRecordDto(
            level: 'WARN',
            message: 'FromRadio payload not set',
          ),
          id: fr.hasId() ? fr.id : null,
        );
    }
  }

  static ConfigDto _toConfigDto(cfgpb.Config cfg) {
    DeviceConfigDto? device;
    if (cfg.hasDevice()) {
      final d = cfg.device;
      device = DeviceConfigDto(
        role: d.hasRole() ? d.role.name : null,
        serialEnabled: d.hasSerialEnabled() ? d.serialEnabled : null,
        buttonGpio: d.hasButtonGpio() ? d.buttonGpio : null,
        buzzerGpio: d.hasBuzzerGpio() ? d.buzzerGpio : null,
        rebroadcastMode: d.hasRebroadcastMode() ? d.rebroadcastMode.name : null,
        nodeInfoBroadcastSecs: d.hasNodeInfoBroadcastSecs()
            ? d.nodeInfoBroadcastSecs
            : null,
        doubleTapAsButtonPress: d.hasDoubleTapAsButtonPress()
            ? d.doubleTapAsButtonPress
            : null,
        isManaged: d.hasIsManaged() ? d.isManaged : null,
        disableTripleClick: d.hasDisableTripleClick()
            ? d.disableTripleClick
            : null,
        tzdef: d.hasTzdef() ? d.tzdef : null,
        ledHeartbeatDisabled: d.hasLedHeartbeatDisabled()
            ? d.ledHeartbeatDisabled
            : null,
        buzzerMode: d.hasBuzzerMode() ? d.buzzerMode.name : null,
      );
    }
    PositionConfigDto? position;
    if (cfg.hasPosition()) {
      final p = cfg.position;
      position = PositionConfigDto(
        positionBroadcastSecs: p.hasPositionBroadcastSecs()
            ? p.positionBroadcastSecs
            : null,
        positionBroadcastSmartEnabled: p.hasPositionBroadcastSmartEnabled()
            ? p.positionBroadcastSmartEnabled
            : null,
        fixedPosition: p.hasFixedPosition() ? p.fixedPosition : null,
        gpsEnabled: p.hasGpsEnabled() ? p.gpsEnabled : null,
        gpsUpdateInterval: p.hasGpsUpdateInterval()
            ? p.gpsUpdateInterval
            : null,
        gpsAttemptTime: p.hasGpsAttemptTime() ? p.gpsAttemptTime : null,
        positionFlags: p.hasPositionFlags() ? p.positionFlags : null,
        rxGpio: p.hasRxGpio() ? p.rxGpio : null,
        txGpio: p.hasTxGpio() ? p.txGpio : null,
        broadcastSmartMinimumDistance: p.hasBroadcastSmartMinimumDistance()
            ? p.broadcastSmartMinimumDistance
            : null,
        broadcastSmartMinimumIntervalSecs:
            p.hasBroadcastSmartMinimumIntervalSecs()
            ? p.broadcastSmartMinimumIntervalSecs
            : null,
        gpsEnGpio: p.hasGpsEnGpio() ? p.gpsEnGpio : null,
        gpsMode: p.hasGpsMode() ? p.gpsMode.name : null,
      );
    }
    PowerConfigDto? power;
    if (cfg.hasPower()) {
      power = _toPowerConfigDto(cfg.power);
    }
    NetworkConfigDto? network;
    if (cfg.hasNetwork()) {
      network = _toNetworkConfigDto(cfg.network);
    }
    DisplayConfigDto? display;
    if (cfg.hasDisplay()) {
      display = _toDisplayConfigDto(cfg.display);
    }
    LoRaConfigDto? lora;
    if (cfg.hasLora()) {
      lora = _toLoRaConfigDto(cfg.lora);
    }
    BluetoothConfigDto? bluetooth;
    if (cfg.hasBluetooth()) {
      bluetooth = _toBluetoothConfigDto(cfg.bluetooth);
    }
    SecurityConfigDto? security;
    if (cfg.hasSecurity()) {
      security = _toSecurityConfigDto(cfg.security);
    }
    SessionkeyConfigDto? sessionkey;
    if (cfg.hasSessionkey()) {
      sessionkey = const SessionkeyConfigDto();
    }

    return ConfigDto(
      device: device,
      position: position,
      power: power,
      network: network,
      display: display,
      lora: lora,
      bluetooth: bluetooth,
      security: security,
      sessionkey: sessionkey,
    );
  }

  static PowerConfigDto _toPowerConfigDto(cfgpb.Config_PowerConfig p) {
    return PowerConfigDto(
      isPowerSaving: p.hasIsPowerSaving() ? p.isPowerSaving : null,
      onBatteryShutdownAfterSecs: p.hasOnBatteryShutdownAfterSecs()
          ? p.onBatteryShutdownAfterSecs
          : null,
      adcMultiplierOverride: p.hasAdcMultiplierOverride()
          ? p.adcMultiplierOverride
          : null,
      waitBluetoothSecs: p.hasWaitBluetoothSecs() ? p.waitBluetoothSecs : null,
      sdsSecs: p.hasSdsSecs() ? p.sdsSecs : null,
      lsSecs: p.hasLsSecs() ? p.lsSecs : null,
      minWakeSecs: p.hasMinWakeSecs() ? p.minWakeSecs : null,
      deviceBatteryInaAddress: p.hasDeviceBatteryInaAddress()
          ? p.deviceBatteryInaAddress
          : null,
      powermonEnables: p.hasPowermonEnables()
          ? p.powermonEnables.toInt()
          : null,
    );
  }

  static NetworkConfigDto _toNetworkConfigDto(cfgpb.Config_NetworkConfig n) {
    return NetworkConfigDto(
      wifiEnabled: n.hasWifiEnabled() ? n.wifiEnabled : null,
      wifiSsid: n.hasWifiSsid() ? n.wifiSsid : null,
      wifiPsk: n.hasWifiPsk() ? n.wifiPsk : null,
      ntpServer: n.hasNtpServer() ? n.ntpServer : null,
      ethEnabled: n.hasEthEnabled() ? n.ethEnabled : null,
      addressMode: n.hasAddressMode() ? n.addressMode.name : null,
      ipv4Config: n.hasIpv4Config()
          ? IpV4ConfigDto(
              ip: n.ipv4Config.hasIp() ? n.ipv4Config.ip : null,
              gateway: n.ipv4Config.hasGateway() ? n.ipv4Config.gateway : null,
              subnet: n.ipv4Config.hasSubnet() ? n.ipv4Config.subnet : null,
              dns: n.ipv4Config.hasDns() ? n.ipv4Config.dns : null,
            )
          : null,
      rsyslogServer: n.hasRsyslogServer() ? n.rsyslogServer : null,
      enabledProtocols: n.hasEnabledProtocols() ? n.enabledProtocols : null,
      ipv6Enabled: n.hasIpv6Enabled() ? n.ipv6Enabled : null,
    );
  }

  static DisplayConfigDto _toDisplayConfigDto(cfgpb.Config_DisplayConfig d) {
    return DisplayConfigDto(
      screenOnSecs: d.hasScreenOnSecs() ? d.screenOnSecs : null,
      autoScreenCarouselSecs: d.hasAutoScreenCarouselSecs()
          ? d.autoScreenCarouselSecs
          : null,
      compassNorthTop: d.hasCompassNorthTop() ? d.compassNorthTop : null,
      flipScreen: d.hasFlipScreen() ? d.flipScreen : null,
      units: d.hasUnits() ? d.units.name : null,
      oled: d.hasOled() ? d.oled.name : null,
      displaymode: d.hasDisplaymode() ? d.displaymode.name : null,
      headingBold: d.hasHeadingBold() ? d.headingBold : null,
      wakeOnTapOrMotion: d.hasWakeOnTapOrMotion() ? d.wakeOnTapOrMotion : null,
      compassOrientation: d.hasCompassOrientation()
          ? d.compassOrientation.name
          : null,
      use12hClock: d.hasUse12hClock() ? d.use12hClock : null,
      useLongNodeName: d.hasUseLongNodeName() ? d.useLongNodeName : null,
    );
  }

  static LoRaConfigDto _toLoRaConfigDto(cfgpb.Config_LoRaConfig l) {
    return LoRaConfigDto(
      usePreset: l.hasUsePreset() ? l.usePreset : null,
      modemPreset: l.hasModemPreset() ? l.modemPreset.name : null,
      bandwidth: l.hasBandwidth() ? l.bandwidth : null,
      spreadFactor: l.hasSpreadFactor() ? l.spreadFactor : null,
      codingRate: l.hasCodingRate() ? l.codingRate : null,
      frequencyOffset: l.hasFrequencyOffset() ? l.frequencyOffset : null,
      region: l.hasRegion() ? l.region.name : null,
      hopLimit: l.hasHopLimit() ? l.hopLimit : null,
      txEnabled: l.hasTxEnabled() ? l.txEnabled : null,
      txPower: l.hasTxPower() ? l.txPower : null,
      channelNum: l.hasChannelNum() ? l.channelNum : null,
      overrideDutyCycle: l.hasOverrideDutyCycle() ? l.overrideDutyCycle : null,
      sx126xRxBoostedGain: l.hasSx126xRxBoostedGain()
          ? l.sx126xRxBoostedGain
          : null,
      overrideFrequency: l.hasOverrideFrequency() ? l.overrideFrequency : null,
      paFanDisabled: l.hasPaFanDisabled() ? l.paFanDisabled : null,
      ignoreIncoming: l.ignoreIncoming.isNotEmpty
          ? List.from(l.ignoreIncoming)
          : null,
      ignoreMqtt: l.hasIgnoreMqtt() ? l.ignoreMqtt : null,
      configOkToMqtt: l.hasConfigOkToMqtt() ? l.configOkToMqtt : null,
    );
  }

  static BluetoothConfigDto _toBluetoothConfigDto(
    cfgpb.Config_BluetoothConfig b,
  ) {
    return BluetoothConfigDto(
      enabled: b.hasEnabled() ? b.enabled : null,
      mode: b.hasMode() ? b.mode.name : null,
      fixedPin: b.hasFixedPin() ? b.fixedPin : null,
    );
  }

  static SecurityConfigDto _toSecurityConfigDto(cfgpb.Config_SecurityConfig s) {
    return SecurityConfigDto(
      publicKey: s.hasPublicKey() ? Uint8List.fromList(s.publicKey) : null,
      privateKey: s.hasPrivateKey() ? Uint8List.fromList(s.privateKey) : null,
      adminKey: s.adminKey.isNotEmpty
          ? s.adminKey.map((k) => Uint8List.fromList(k)).toList()
          : null,
      isManaged: s.hasIsManaged() ? s.isManaged : null,
      serialEnabled: s.hasSerialEnabled() ? s.serialEnabled : null,
      debugLogApiEnabled: s.hasDebugLogApiEnabled()
          ? s.debugLogApiEnabled
          : null,
      adminChannelEnabled: s.hasAdminChannelEnabled()
          ? s.adminChannelEnabled
          : null,
    );
  }

  static ModuleConfigDto _toModuleConfigDto(module.ModuleConfig mc) {
    MqttConfigDto? mqtt;
    TelemetryConfigDto? telemetry;
    SerialConfigDto? serial;
    if (mc.hasMqtt()) {
      final m = mc.mqtt;
      MapReportSettingsDto? mapReport;
      if (m.hasMapReportSettings()) {
        final s = m.mapReportSettings;
        mapReport = MapReportSettingsDto(
          publishIntervalSecs: s.hasPublishIntervalSecs()
              ? s.publishIntervalSecs
              : null,
          positionPrecision: s.hasPositionPrecision()
              ? s.positionPrecision
              : null,
          shouldReportLocation: s.hasShouldReportLocation()
              ? s.shouldReportLocation
              : null,
        );
      }
      mqtt = MqttConfigDto(
        enabled: m.hasEnabled() ? m.enabled : null,
        address: m.hasAddress() ? m.address : null,
        username: m.hasUsername() ? m.username : null,
        password: m.hasPassword() ? m.password : null,
        encryptionEnabled: m.hasEncryptionEnabled()
            ? m.encryptionEnabled
            : null,
        jsonEnabled: m.hasJsonEnabled() ? m.jsonEnabled : null,
        tlsEnabled: m.hasTlsEnabled() ? m.tlsEnabled : null,
        root: m.hasRoot() ? m.root : null,
        proxyToClientEnabled: m.hasProxyToClientEnabled()
            ? m.proxyToClientEnabled
            : null,
        mapReportingEnabled: m.hasMapReportingEnabled()
            ? m.mapReportingEnabled
            : null,
        mapReportSettings: mapReport,
      );
    }
    if (mc.hasTelemetry()) {
      final t = mc.telemetry;
      telemetry = TelemetryConfigDto(
        deviceUpdateInterval: t.hasDeviceUpdateInterval()
            ? t.deviceUpdateInterval
            : null,
        environmentUpdateInterval: t.hasEnvironmentUpdateInterval()
            ? t.environmentUpdateInterval
            : null,
        environmentMeasurementEnabled: t.hasEnvironmentMeasurementEnabled()
            ? t.environmentMeasurementEnabled
            : null,
        environmentScreenEnabled: t.hasEnvironmentScreenEnabled()
            ? t.environmentScreenEnabled
            : null,
        environmentDisplayFahrenheit: t.hasEnvironmentDisplayFahrenheit()
            ? t.environmentDisplayFahrenheit
            : null,
        airQualityEnabled: t.hasAirQualityEnabled()
            ? t.airQualityEnabled
            : null,
        airQualityInterval: t.hasAirQualityInterval()
            ? t.airQualityInterval
            : null,
        powerMeasurementEnabled: t.hasPowerMeasurementEnabled()
            ? t.powerMeasurementEnabled
            : null,
        powerUpdateInterval: t.hasPowerUpdateInterval()
            ? t.powerUpdateInterval
            : null,
        powerScreenEnabled: t.hasPowerScreenEnabled()
            ? t.powerScreenEnabled
            : null,
        healthMeasurementEnabled: t.hasHealthMeasurementEnabled()
            ? t.healthMeasurementEnabled
            : null,
        healthUpdateInterval: t.hasHealthUpdateInterval()
            ? t.healthUpdateInterval
            : null,
        healthScreenEnabled: t.hasHealthScreenEnabled()
            ? t.healthScreenEnabled
            : null,
        deviceTelemetryEnabled: t.hasDeviceTelemetryEnabled()
            ? t.deviceTelemetryEnabled
            : null,
      );
    }
    if (mc.hasSerial()) {
      final s = mc.serial;
      serial = SerialConfigDto(
        enabled: s.hasEnabled() ? s.enabled : null,
        echo: s.hasEcho() ? s.echo : null,
        rxd: s.hasRxd() ? s.rxd : null,
        txd: s.hasTxd() ? s.txd : null,
        baud: s.hasBaud() ? s.baud.name : null,
        timeout: s.hasTimeout() ? s.timeout : null,
        mode: s.hasMode() ? s.mode.name : null,
        overrideConsoleSerialPort: s.hasOverrideConsoleSerialPort()
            ? s.overrideConsoleSerialPort
            : null,
      );
    }
    StoreForwardConfigDto? storeForward;
    if (mc.hasStoreForward()) {
      final sf = mc.storeForward;
      storeForward = StoreForwardConfigDto(
        enabled: sf.hasEnabled() ? sf.enabled : null,
        heartbeat: sf.hasHeartbeat() ? sf.heartbeat : null,
        records: sf.hasRecords() ? sf.records : null,
        historyReturnMax: sf.hasHistoryReturnMax() ? sf.historyReturnMax : null,
        historyReturnWindow: sf.hasHistoryReturnWindow()
            ? sf.historyReturnWindow
            : null,
        isServer: sf.hasIsServer() ? sf.isServer : null,
        emitControlSignals: sf.hasEmitControlSignals()
            ? sf.emitControlSignals
            : null,
      );
    }
    RangeTestConfigDto? rangeTest;
    if (mc.hasRangeTest()) {
      final rt = mc.rangeTest;
      rangeTest = RangeTestConfigDto(
        enabled: rt.hasEnabled() ? rt.enabled : null,
        sender: rt.hasSender() ? rt.sender : null,
        save: rt.hasSave() ? rt.save : null,
        clearOnReboot: rt.hasClearOnReboot() ? rt.clearOnReboot : null,
      );
    }
    ExternalNotificationConfigDto? externalNotification;
    if (mc.hasExternalNotification()) {
      final en = mc.externalNotification;
      externalNotification = ExternalNotificationConfigDto(
        enabled: en.hasEnabled() ? en.enabled : null,
        outputMs: en.hasOutputMs() ? en.outputMs : null,
        output: en.hasOutput() ? en.output : null,
        active: en.hasActive() ? en.active : null,
        alertMessage: en.hasAlertMessage() ? en.alertMessage : null,
        alertBell: en.hasAlertBell() ? en.alertBell : null,
        usePwm: en.hasUsePwm() ? en.usePwm : null,
        outputVibra: en.hasOutputVibra() ? en.outputVibra : null,
        outputBuzzer: en.hasOutputBuzzer() ? en.outputBuzzer : null,
        alertMessageVibra: en.hasAlertMessageVibra()
            ? en.alertMessageVibra
            : null,
        alertMessageBuzzer: en.hasAlertMessageBuzzer()
            ? en.alertMessageBuzzer
            : null,
        alertBellVibra: en.hasAlertBellVibra() ? en.alertBellVibra : null,
        alertBellBuzzer: en.hasAlertBellBuzzer() ? en.alertBellBuzzer : null,
        nagTimeout: en.hasNagTimeout() ? en.nagTimeout : null,
        useI2sAsBuzzer: en.hasUseI2sAsBuzzer() ? en.useI2sAsBuzzer : null,
      );
    }
    AudioConfigDto? audio;
    if (mc.hasAudio()) {
      final a = mc.audio;
      audio = AudioConfigDto(
        codec2Enabled: a.hasCodec2Enabled() ? a.codec2Enabled : null,
        pttPin: a.hasPttPin() ? a.pttPin : null,
        bitrate: a.hasBitrate() ? a.bitrate.name : null,
        i2sWs: a.hasI2sWs() ? a.i2sWs : null,
        i2sSd: a.hasI2sSd() ? a.i2sSd : null,
        i2sDin: a.hasI2sDin() ? a.i2sDin : null,
        i2sSck: a.hasI2sSck() ? a.i2sSck : null,
      );
    }
    AmbientLightingConfigDto? ambientLighting;
    if (mc.hasAmbientLighting()) {
      final al = mc.ambientLighting;
      ambientLighting = AmbientLightingConfigDto(
        ledState: al.hasLedState() ? al.ledState : null,
        current: al.hasCurrent() ? al.current : null,
        red: al.hasRed() ? al.red : null,
        green: al.hasGreen() ? al.green : null,
        blue: al.hasBlue() ? al.blue : null,
      );
    }
    DetectionSensorConfigDto? detectionSensor;
    if (mc.hasDetectionSensor()) {
      final ds = mc.detectionSensor;
      detectionSensor = DetectionSensorConfigDto(
        enabled: ds.hasEnabled() ? ds.enabled : null,
        minimumBroadcastSecs: ds.hasMinimumBroadcastSecs()
            ? ds.minimumBroadcastSecs
            : null,
        stateBroadcastSecs: ds.hasStateBroadcastSecs()
            ? ds.stateBroadcastSecs
            : null,
        sendBell: ds.hasSendBell() ? ds.sendBell : null,
        name: ds.hasName() ? ds.name : null,
        monitorPin: ds.hasMonitorPin() ? ds.monitorPin : null,
        detectionTriggerType: ds.hasDetectionTriggerType()
            ? ds.detectionTriggerType.name
            : null,
        usePullup: ds.hasUsePullup() ? ds.usePullup : null,
      );
    }
    NeighborInfoConfigDto? neighborInfo;
    if (mc.hasNeighborInfo()) {
      final ni = mc.neighborInfo;
      neighborInfo = NeighborInfoConfigDto(
        enabled: ni.hasEnabled() ? ni.enabled : null,
        updateInterval: ni.hasUpdateInterval() ? ni.updateInterval : null,
        transmitOverLora: ni.hasTransmitOverLora() ? ni.transmitOverLora : null,
      );
    }
    RemoteHardwareConfigDto? remoteHardware;
    if (mc.hasRemoteHardware()) {
      final rh = mc.remoteHardware;
      List<RemoteHardwarePinDto>? pins;
      if (rh.availablePins.isNotEmpty) {
        pins = rh.availablePins
            .map(
              (p) => RemoteHardwarePinDto(
                gpioPin: p.hasGpioPin() ? p.gpioPin : null,
                name: p.hasName() ? p.name : null,
                type: p.hasType() ? p.type.name : null,
              ),
            )
            .toList(growable: false);
      }
      remoteHardware = RemoteHardwareConfigDto(
        enabled: rh.hasEnabled() ? rh.enabled : null,
        allowUndefinedPinAccess: rh.hasAllowUndefinedPinAccess()
            ? rh.allowUndefinedPinAccess
            : null,
        availablePins: pins,
      );
    }
    PaxcounterConfigDto? paxcounter;
    if (mc.hasPaxcounter()) {
      final px = mc.paxcounter;
      paxcounter = PaxcounterConfigDto(
        enabled: px.hasEnabled() ? px.enabled : null,
        paxcounterUpdateInterval: px.hasPaxcounterUpdateInterval()
            ? px.paxcounterUpdateInterval
            : null,
        wifiThreshold: px.hasWifiThreshold() ? px.wifiThreshold : null,
        bleThreshold: px.hasBleThreshold() ? px.bleThreshold : null,
      );
    }
    CannedMessageConfigDto? cannedMessage;
    if (mc.hasCannedMessage()) {
      final cm = mc.cannedMessage;
      cannedMessage = CannedMessageConfigDto(
        rotary1Enabled: cm.hasRotary1Enabled() ? cm.rotary1Enabled : null,
        inputbrokerPinA: cm.hasInputbrokerPinA() ? cm.inputbrokerPinA : null,
        inputbrokerPinB: cm.hasInputbrokerPinB() ? cm.inputbrokerPinB : null,
        inputbrokerPinPress: cm.hasInputbrokerPinPress()
            ? cm.inputbrokerPinPress
            : null,
        inputbrokerEventCw: cm.hasInputbrokerEventCw()
            ? cm.inputbrokerEventCw.name
            : null,
        inputbrokerEventCcw: cm.hasInputbrokerEventCcw()
            ? cm.inputbrokerEventCcw.name
            : null,
        inputbrokerEventPress: cm.hasInputbrokerEventPress()
            ? cm.inputbrokerEventPress.name
            : null,
        updown1Enabled: cm.hasUpdown1Enabled() ? cm.updown1Enabled : null,
        enabled: cm.hasEnabled() ? cm.enabled : null,
        allowInputSource: cm.hasAllowInputSource() ? cm.allowInputSource : null,
        sendBell: cm.hasSendBell() ? cm.sendBell : null,
      );
    }
    DtnOverlayConfigDto? dtnOverlay;
    if (mc.hasDtnOverlay()) {
      final d = mc.dtnOverlay;
      dtnOverlay = DtnOverlayConfigDto(
        enabled: d.hasEnabled() ? d.enabled : null,
        ttlMinutes: d.hasTtlMinutes() ? d.ttlMinutes : null,
        initialDelayBaseMs: d.hasInitialDelayBaseMs()
            ? d.initialDelayBaseMs
            : null,
        retryBackoffMs: d.hasRetryBackoffMs() ? d.retryBackoffMs : null,
        maxTries: d.hasMaxTries() ? d.maxTries : null,
        lateFallbackEnabled: d.hasLateFallbackEnabled()
            ? d.lateFallbackEnabled
            : null,
        fallbackTailPercent: d.hasFallbackTailPercent()
            ? d.fallbackTailPercent
            : null,
        milestonesEnabled: d.hasMilestonesEnabled()
            ? d.milestonesEnabled
            : null,
        perDestMinSpacingMs: d.hasPerDestMinSpacingMs()
            ? d.perDestMinSpacingMs
            : null,
        maxActiveDm: d.hasMaxActiveDm() ? d.maxActiveDm : null,
        probeFwplusNearDeadline: d.hasProbeFwplusNearDeadline()
            ? d.probeFwplusNearDeadline
            : null,
      );
    }
    BroadcastAssistConfigDto? broadcastAssist;
    if (mc.hasBroadcastAssist()) {
      final b = mc.broadcastAssist;
      broadcastAssist = BroadcastAssistConfigDto(
        enabled: b.hasEnabled() ? b.enabled : null,
        degreeThreshold: b.hasDegreeThreshold() ? b.degreeThreshold : null,
        dupThreshold: b.hasDupThreshold() ? b.dupThreshold : null,
        windowMs: b.hasWindowMs() ? b.windowMs : null,
        maxExtraHops: b.hasMaxExtraHops() ? b.maxExtraHops : null,
        jitterMs: b.hasJitterMs() ? b.jitterMs : null,
        airtimeGuard: b.hasAirtimeGuard() ? b.airtimeGuard : null,
        allowedPorts: b.allowedPorts.isNotEmpty
            ? List<int>.from(b.allowedPorts)
            : null,
      );
    }
    NodeModConfigDto? nodeMod;
    if (mc.hasNodeMod()) {
      nodeMod = _toNodeModConfigDto(mc.nodeMod);
    }
    NodeModAdminConfigDto? nodeModAdmin;
    if (mc.hasNodeModAdmin()) {
      nodeModAdmin = _toNodeModAdminConfigDto(mc.nodeModAdmin);
    }
    IdleGameConfigDto? idleGame;
    if (mc.hasIdleGame()) {
      idleGame = _toIdleGameConfigDto(mc.idleGame);
    }

    return ModuleConfigDto(
      mqtt: mqtt,
      telemetry: telemetry,
      serial: serial,
      storeForward: storeForward,
      rangeTest: rangeTest,
      externalNotification: externalNotification,
      audio: audio,
      neighborInfo: neighborInfo,
      remoteHardware: remoteHardware,
      paxcounter: paxcounter,
      cannedMessage: cannedMessage,
      ambientLighting: ambientLighting,
      detectionSensor: detectionSensor,
      dtnOverlay: dtnOverlay,
      broadcastAssist: broadcastAssist,
      nodeMod: nodeMod,
      nodeModAdmin: nodeModAdmin,
      idleGame: idleGame,
    );
  }

  static NodeModConfigDto _toNodeModConfigDto(
    module.ModuleConfig_NodeModConfig n,
  ) {
    return NodeModConfigDto(
      textStatus: n.hasTextStatus() ? n.textStatus : null,
      emoji: n.hasEmoji() ? n.emoji : null,
    );
  }

  static NodeModAdminConfigDto _toNodeModAdminConfigDto(
    module.ModuleConfig_NodeModAdminConfig n,
  ) {
    return NodeModAdminConfigDto(
      snifferEnabled: n.hasSnifferEnabled() ? n.snifferEnabled : null,
      doNotSendPrvOverMqtt: n.hasDoNotSendPrvOverMqtt()
          ? n.doNotSendPrvOverMqtt
          : null,
      localStatsOverMeshEnabled: n.hasLocalStatsOverMeshEnabled()
          ? n.localStatsOverMeshEnabled
          : null,
      localStatsExtendedOverMeshEnabled:
          n.hasLocalStatsExtendedOverMeshEnabled()
          ? n.localStatsExtendedOverMeshEnabled
          : null,
      idlegameEnabled: n.hasIdlegameEnabled() ? n.idlegameEnabled : null,
      additionalChutil: n.hasAdditionalChutil() ? n.additionalChutil : null,
      additionalTxutil: n.hasAdditionalTxutil() ? n.additionalTxutil : null,
      additionalPoliteChannelPercent: n.hasAdditionalPoliteChannelPercent()
          ? n.additionalPoliteChannelPercent
          : null,
      additionalPoliteDutyCyclePercent: n.hasAdditionalPoliteDutyCyclePercent()
          ? n.additionalPoliteDutyCyclePercent
          : null,
      currentTxUtilLimit: n.hasCurrentTxUtilLimit()
          ? n.currentTxUtilLimit
          : null,
      currentMaxChannelUtilPercent: n.hasCurrentMaxChannelUtilPercent()
          ? n.currentMaxChannelUtilPercent
          : null,
      currentPoliteChannelUtilPercent: n.hasCurrentPoliteChannelUtilPercent()
          ? n.currentPoliteChannelUtilPercent
          : null,
      currentPoliteDutyCyclePercent: n.hasCurrentPoliteDutyCyclePercent()
          ? n.currentPoliteDutyCyclePercent
          : null,
      autoResponderEnabled: n.hasAutoResponderEnabled()
          ? n.autoResponderEnabled
          : null,
      autoResponderText: n.hasAutoResponderText() ? n.autoResponderText : null,
      autoRedirectMessages: n.hasAutoRedirectMessages()
          ? n.autoRedirectMessages
          : null,
      autoRedirectTargetNodeId: n.hasAutoRedirectTargetNodeId()
          ? n.autoRedirectTargetNodeId
          : null,
      telemetryLimiterEnabled: n.hasTelemetryLimiterEnabled()
          ? n.telemetryLimiterEnabled
          : null,
      telemetryLimiterPacketsPerMinute: n.hasTelemetryLimiterPacketsPerMinute()
          ? n.telemetryLimiterPacketsPerMinute
          : null,
      telemetryLimiterAutoChanutilEnabled:
          n.hasTelemetryLimiterAutoChanutilEnabled()
          ? n.telemetryLimiterAutoChanutilEnabled
          : null,
      telemetryLimiterAutoChanutilThreshold:
          n.hasTelemetryLimiterAutoChanutilThreshold()
          ? n.telemetryLimiterAutoChanutilThreshold
          : null,
      positionLimiterEnabled: n.hasPositionLimiterEnabled()
          ? n.positionLimiterEnabled
          : null,
      positionLimiterTimeMinutesThreshold:
          n.hasPositionLimiterTimeMinutesThreshold()
          ? n.positionLimiterTimeMinutesThreshold
          : null,
      opportunisticFloodingEnabled: n.hasOpportunisticFloodingEnabled()
          ? n.opportunisticFloodingEnabled
          : null,
      opportunisticBaseDelayMs: n.hasOpportunisticBaseDelayMs()
          ? n.opportunisticBaseDelayMs
          : null,
      opportunisticHopDelayMs: n.hasOpportunisticHopDelayMs()
          ? n.opportunisticHopDelayMs
          : null,
      opportunisticSnrGainMs: n.hasOpportunisticSnrGainMs()
          ? n.opportunisticSnrGainMs
          : null,
      opportunisticJitterMs: n.hasOpportunisticJitterMs()
          ? n.opportunisticJitterMs
          : null,
      opportunisticCancelOnFirstHear: n.hasOpportunisticCancelOnFirstHear()
          ? n.opportunisticCancelOnFirstHear
          : null,
      opportunisticAuto: n.hasOpportunisticAuto() ? n.opportunisticAuto : null,
    );
  }

  static IdleGameConfigDto _toIdleGameConfigDto(
    module.ModuleConfig_IdleGameConfig i,
  ) {
    return IdleGameConfigDto(variant: i.whichVariant().name);
  }

  static ChannelDto _toChannelDto(channel.Channel c) {
    return ChannelDto(
      index: c.hasIndex() ? c.index : 0,
      role: c.hasRole() ? c.role.name : null,
      settings: c.hasSettings() ? _toChannelSettingsDto(c.settings) : null,
    );
  }

  static ChannelSettingsDto _toChannelSettingsDto(channel.ChannelSettings s) {
    return ChannelSettingsDto(
      channelNum: s.hasChannelNum() ? s.channelNum : null,
      psk: s.hasPsk() ? Uint8List.fromList(s.psk) : null,
      name: s.hasName() ? s.name : null,
      id: s.hasId() ? s.id : null,
      uplinkEnabled: s.hasUplinkEnabled() ? s.uplinkEnabled : null,
      downlinkEnabled: s.hasDownlinkEnabled() ? s.downlinkEnabled : null,
      moduleSettings: s.hasModuleSettings()
          ? _toModuleSettingsDto(s.moduleSettings)
          : null,
    );
  }

  static ModuleSettingsDto _toModuleSettingsDto(channel.ModuleSettings m) {
    return ModuleSettingsDto(
      positionPrecision: m.hasPositionPrecision() ? m.positionPrecision : null,
    );
  }

  static MeshPacketDto _toMeshPacketDto(mesh.MeshPacket packet) {
    final decoded = _decodePayload(packet);
    return MeshPacketDto(
      from: packet.hasFrom() ? packet.from : null,
      to: packet.hasTo() ? packet.to : null,
      channel: packet.hasChannel() ? packet.channel : null,
      id: packet.hasId() ? packet.id : null,
      rxTime: packet.hasRxTime() ? packet.rxTime : null,
      rxSnr: packet.hasRxSnr() ? packet.rxSnr : null,
      hopLimit: packet.hasHopLimit() ? packet.hopLimit : null,
      wantAck: packet.hasWantAck() ? packet.wantAck : null,
      priority: packet.hasPriority() ? packet.priority.name : null,
      rxRssi: packet.hasRxRssi() ? packet.rxRssi : null,
      viaMqtt: packet.hasViaMqtt() ? packet.viaMqtt : null,
      hopStart: packet.hasHopStart() ? packet.hopStart : null,
      encrypted: packet.hasEncrypted()
          ? Uint8List.fromList(packet.encrypted)
          : null,
      publicKey: packet.hasPublicKey()
          ? Uint8List.fromList(packet.publicKey)
          : null,
      pkiEncrypted: packet.hasPkiEncrypted() ? packet.pkiEncrypted : null,
      nextHop: packet.hasNextHop() ? packet.nextHop : null,
      relayNode: packet.hasRelayNode() ? packet.relayNode : null,
      txAfter: packet.hasTxAfter() ? packet.txAfter : null,
      transportMechanism: packet.hasTransportMechanism()
          ? packet.transportMechanism.name
          : null,
      decoded: decoded,
    );
  }

  static DecodedPayloadDto? _decodePayload(mesh.MeshPacket packet) {
    if (!packet.hasDecoded()) return null;
    final data = packet.decoded;
    final pn = data.portnum;
    final bytes = Uint8List.fromList(data.payload);
    final portInternal = PortNumInternal(pn.value, pn.name);
    switch (pn) {
      case port.PortNum.TEXT_MESSAGE_APP:
      case port.PortNum.TEXT_MESSAGE_COMPRESSED_APP:
        final text = _safeUtf8(bytes);
        return TextPayloadDto(text, emoji: data.hasEmoji() ? data.emoji : null);
      case port.PortNum.POSITION_APP:
        try {
          final pos = mesh.Position.fromBuffer(bytes);
          return PositionPayloadDto(_toPositionDto(pos));
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.NODEINFO_APP:
        try {
          final user = mesh.User.fromBuffer(bytes);
          return UserPayloadDto(_toUserDto(user));
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.ROUTING_APP:
        try {
          // Parse to validate bytes shape; we don't expose fields yet
          final r = mesh.Routing.fromBuffer(bytes);
          return RoutingPayloadDto(
            variant: r.whichVariant().name,
            errorReason: r.hasErrorReason() ? r.errorReason.name : null,
            requestId: data.hasRequestId() ? data.requestId : null,
          );
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.ADMIN_APP:
        try {
          final _ = admin.AdminMessage.fromBuffer(bytes);
          return const AdminPayloadDto();
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.WAYPOINT_APP:
        try {
          final w = mesh.Waypoint.fromBuffer(bytes);
          return WaypointPayloadDto(
            WaypointDto(
              id: w.hasId() ? w.id : null,
              latitudeI: w.hasLatitudeI() ? w.latitudeI : null,
              longitudeI: w.hasLongitudeI() ? w.longitudeI : null,
              expire: w.hasExpire() ? w.expire : null,
              lockedTo: w.hasLockedTo() ? w.lockedTo : null,
              name: w.hasName() ? w.name : null,
              description: w.hasDescription() ? w.description : null,
              icon: w.hasIcon() ? w.icon : null,
            ),
          );
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.REMOTE_HARDWARE_APP:
        try {
          final m = rhw.HardwareMessage.fromBuffer(bytes);
          return RemoteHardwarePayloadDto(
            type: m.hasType() ? m.type.name : null,
            gpioMask: m.hasGpioMask() ? m.gpioMask.toInt() : null,
            gpioValue: m.hasGpioValue() ? m.gpioValue.toInt() : null,
          );
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.NEIGHBORINFO_APP:
        try {
          final ni = mesh.NeighborInfo.fromBuffer(bytes);
          return NeighborInfoPayloadDto(
            nodeId: ni.hasNodeId() ? ni.nodeId : null,
            lastSentById: ni.hasLastSentById() ? ni.lastSentById : null,
            nodeBroadcastIntervalSecs: ni.hasNodeBroadcastIntervalSecs()
                ? ni.nodeBroadcastIntervalSecs
                : null,
            neighbors: ni.neighbors.isNotEmpty
                ? ni.neighbors
                      .map(
                        (n) => NeighborEntryDto(
                          nodeId: n.hasNodeId() ? n.nodeId : null,
                          snr: n.hasSnr() ? n.snr : null,
                          lastRxTime: n.hasLastRxTime() ? n.lastRxTime : null,
                          nodeBroadcastIntervalSecs:
                              n.hasNodeBroadcastIntervalSecs()
                              ? n.nodeBroadcastIntervalSecs
                              : null,
                        ),
                      )
                      .toList()
                : null,
          );
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.STORE_FORWARD_APP:
        try {
          final s = sfwd.StoreAndForward.fromBuffer(bytes);
          final v = s.whichVariant().name;
          return StoreForwardPayloadDto(variant: v);
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.TELEMETRY_APP:
        try {
          final t = telem.Telemetry.fromBuffer(bytes);
          final v = t.whichVariant().name;
          return TelemetryPayloadDto(variant: v);
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.PAXCOUNTER_APP:
        try {
          final p = pax.Paxcount.fromBuffer(bytes);
          return PaxcounterPayloadDto(
            wifi: p.hasWifi() ? p.wifi : null,
            ble: p.hasBle() ? p.ble : null,
            uptime: p.hasUptime() ? p.uptime : null,
          );
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.DETECTION_SENSOR_APP:
      case port.PortNum.ALERT_APP:
      case port.PortNum.REPLY_APP:
      case port.PortNum.RANGE_TEST_APP:
        // Treat these as simple text messages when possible
        final text = _safeUtf8(bytes);
        return TextPayloadDto(text, emoji: data.hasEmoji() ? data.emoji : null);
      case port.PortNum.TRACEROUTE_APP:
        // Parse RouteDiscovery and expose all available fields
        try {
          final rd = mesh.RouteDiscovery.fromBuffer(bytes);
          return TraceroutePayloadDto(
            route: rd.route.isNotEmpty ? List<int>.from(rd.route) : null,
            snrTowards: rd.snrTowards.isNotEmpty
                ? List<int>.from(rd.snrTowards)
                : null,
            routeBack: rd.routeBack.isNotEmpty
                ? List<int>.from(rd.routeBack)
                : null,
            snrBack: rd.snrBack.isNotEmpty ? List<int>.from(rd.snrBack) : null,
          );
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.KEY_VERIFICATION_APP:
        // Expose main fields of KeyVerification
        try {
          final kv = mesh.KeyVerification.fromBuffer(bytes);
          return KeyVerificationPayloadDto(
            nonce: kv.hasNonce() ? kv.nonce.toInt() : null,
            hash1: kv.hasHash1() ? Uint8List.fromList(kv.hash1) : null,
            hash2: kv.hasHash2() ? Uint8List.fromList(kv.hash2) : null,
          );
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.AUDIO_APP:
      case port.PortNum.IP_TUNNEL_APP:
      case port.PortNum.ZPS_APP:
      case port.PortNum.SIMULATOR_APP:
      case port.PortNum.ATAK_PLUGIN:
      case port.PortNum.SERIAL_APP:
        // For now surface raw bytes for these less common or opaque types
        return RawPayloadDto(portInternal, bytes);
      default:
        return RawPayloadDto(portInternal, bytes);
    }
  }

  static String _safeUtf8(Uint8List bytes) {
    try {
      return const Utf8Decoder().convert(bytes);
    } catch (_) {
      // Return replacement string showing byte length in case of failure
      return '<<invalid utf8: ${bytes.length} bytes>>';
    }
  }

  // Removed JSON map conversion: we now return typed DTOs only.
}

DeviceUiConfigDto _toDeviceUiConfigDto(dui.DeviceUIConfig c) {
  return DeviceUiConfigDto(
    version: c.hasVersion() ? c.version : null,
    screenBrightness: c.hasScreenBrightness() ? c.screenBrightness : null,
    screenTimeout: c.hasScreenTimeout() ? c.screenTimeout : null,
    screenLock: c.hasScreenLock() ? c.screenLock : null,
    settingsLock: c.hasSettingsLock() ? c.settingsLock : null,
    pinCode: c.hasPinCode() ? c.pinCode : null,
    theme: c.hasTheme() ? c.theme.name : null,
    alertEnabled: c.hasAlertEnabled() ? c.alertEnabled : null,
    bannerEnabled: c.hasBannerEnabled() ? c.bannerEnabled : null,
    ringToneId: c.hasRingToneId() ? c.ringToneId : null,
    language: c.hasLanguage() ? c.language.name : null,
    nodeFilter: c.hasNodeFilter()
        ? DeviceUiNodeFilterDto(
            filterEnabled: c.nodeFilter.hasUnknownSwitch()
                ? c.nodeFilter.unknownSwitch
                : null,
            // Map min SNR using hopsAway as not available; leave null if not provided
            minSnr: c.nodeFilter.hasHopsAway() ? c.nodeFilter.hopsAway : null,
            hideIgnoredNodes: c.nodeFilter.hasOfflineSwitch()
                ? c.nodeFilter.offlineSwitch
                : null,
          )
        : null,
    nodeHighlight: c.hasNodeHighlight()
        ? DeviceUiNodeHighlightDto(
            highlightEnabled: c.nodeHighlight.hasChatSwitch()
                ? c.nodeHighlight.chatSwitch
                : (c.nodeHighlight.hasPositionSwitch()
                      ? c.nodeHighlight.positionSwitch
                      : (c.nodeHighlight.hasTelemetrySwitch()
                            ? c.nodeHighlight.telemetrySwitch
                            : (c.nodeHighlight.hasIaqSwitch()
                                  ? c.nodeHighlight.iaqSwitch
                                  : null))),
            minSnr: null,
          )
        : null,
    calibrationData: c.hasCalibrationData()
        ? Uint8List.fromList(c.calibrationData)
        : null,
    mapData: c.hasMapData()
        ? DeviceUiMapDto(
            zoom: c.mapData.hasHome() && c.mapData.home.hasZoom()
                ? c.mapData.home.zoom
                : null,
            centerLatI: c.mapData.hasHome() && c.mapData.home.hasLatitude()
                ? c.mapData.home.latitude
                : null,
            centerLonI: c.mapData.hasHome() && c.mapData.home.hasLongitude()
                ? c.mapData.home.longitude
                : null,
            followMe: c.mapData.hasFollowGps() ? c.mapData.followGps : null,
          )
        : null,
    compassMode: c.hasCompassMode() ? c.compassMode.name : null,
    screenRgbColor: c.hasScreenRgbColor() ? c.screenRgbColor : null,
    isClockfaceAnalog: c.hasIsClockfaceAnalog() ? c.isClockfaceAnalog : null,
    gpsFormat: c.hasGpsFormat() ? c.gpsFormat.name : null,
  );
}

UserDto _toUserDto(mesh.User user) {
  return UserDto(
    id: user.hasId() ? user.id : null,
    longName: user.hasLongName() ? user.longName : null,
    shortName: user.hasShortName() ? user.shortName : null,
    macaddr: user.hasMacaddr() ? Uint8List.fromList(user.macaddr) : null,
    hwModel: user.hasHwModel() ? user.hwModel.name : null,
    isLicensed: user.hasIsLicensed() ? user.isLicensed : null,
    role: user.hasRole() ? user.role.name : null,
    publicKey: user.hasPublicKey() ? Uint8List.fromList(user.publicKey) : null,
    isUnmessagable: user.hasIsUnmessagable() ? user.isUnmessagable : null,
  );
}

PositionDto _toPositionDto(mesh.Position pos) {
  return PositionDto(
    latitudeI: pos.hasLatitudeI() ? pos.latitudeI : null,
    longitudeI: pos.hasLongitudeI() ? pos.longitudeI : null,
    altitude: pos.hasAltitude() ? pos.altitude : null,
    time: pos.hasTime() ? pos.time : null,
    locationSource: pos.hasLocationSource() ? pos.locationSource.name : null,
    altitudeSource: pos.hasAltitudeSource() ? pos.altitudeSource.name : null,
    timestamp: pos.hasTimestamp() ? pos.timestamp : null,
    timestampMillisAdjust: pos.hasTimestampMillisAdjust()
        ? pos.timestampMillisAdjust
        : null,
    altitudeHae: pos.hasAltitudeHae() ? pos.altitudeHae : null,
    altitudeGeoidalSeparation: pos.hasAltitudeGeoidalSeparation()
        ? pos.altitudeGeoidalSeparation
        : null,
    pDOP: pos.hasPDOP() ? pos.pDOP : null,
    hDOP: pos.hasHDOP() ? pos.hDOP : null,
    vDOP: pos.hasVDOP() ? pos.vDOP : null,
    gpsAccuracy: pos.hasGpsAccuracy() ? pos.gpsAccuracy : null,
    groundSpeed: pos.hasGroundSpeed() ? pos.groundSpeed : null,
    groundTrack: pos.hasGroundTrack() ? pos.groundTrack : null,
    fixQuality: pos.hasFixQuality() ? pos.fixQuality : null,
    fixType: pos.hasFixType() ? pos.fixType : null,
    satsInView: pos.hasSatsInView() ? pos.satsInView : null,
    sensorId: pos.hasSensorId() ? pos.sensorId : null,
    nextUpdate: pos.hasNextUpdate() ? pos.nextUpdate : null,
    seqNumber: pos.hasSeqNumber() ? pos.seqNumber : null,
    precisionBits: pos.hasPrecisionBits() ? pos.precisionBits : null,
  );
}

DeviceMetricsDto _toDeviceMetricsDto(telem.DeviceMetrics dm) {
  return DeviceMetricsDto(
    batteryLevel: dm.hasBatteryLevel() ? dm.batteryLevel : null,
    voltage: dm.hasVoltage() ? dm.voltage : null,
    channelUtilization: dm.hasChannelUtilization()
        ? dm.channelUtilization
        : null,
    airUtilTx: dm.hasAirUtilTx() ? dm.airUtilTx : null,
    uptimeSeconds: dm.hasUptimeSeconds() ? dm.uptimeSeconds : null,
  );
}
