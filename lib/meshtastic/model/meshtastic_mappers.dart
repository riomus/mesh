// ignore_for_file: deprecated_member_use_from_same_package, deprecated_member_use
// We intentionally access some deprecated members from generated protobufs to
// preserve compatibility with older device firmware. Upstream protos may keep
// deprecated fields during transitions; our mapper reads them for best‑effort
// decoding and to support a wider range of devices.
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fixnum/fixnum.dart';

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
      bandwidth: l.hasBandwidth() ? l.bandwidth.toDouble() : null,
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

  // --- DTO -> Protobuf Mappers ---

  static cfgpb.Config toConfig(ConfigDto dto) {
    final config = cfgpb.Config();
    if (dto.device != null) {
      config.device = _toDeviceConfig(dto.device!);
    }
    if (dto.position != null) {
      config.position = _toPositionConfig(dto.position!);
    }
    if (dto.power != null) {
      config.power = _toPowerConfig(dto.power!);
    }
    if (dto.network != null) {
      config.network = _toNetworkConfig(dto.network!);
    }
    if (dto.display != null) {
      config.display = _toDisplayConfig(dto.display!);
    }
    if (dto.lora != null) {
      config.lora = _toLoRaConfig(dto.lora!);
    }
    if (dto.bluetooth != null) {
      config.bluetooth = _toBluetoothConfig(dto.bluetooth!);
    }
    if (dto.security != null) {
      config.security = _toSecurityConfig(dto.security!);
    }
    // Sessionkey is read-only / handled differently usually, but we can add if needed
    return config;
  }

  static cfgpb.Config_DeviceConfig _toDeviceConfig(DeviceConfigDto d) {
    final c = cfgpb.Config_DeviceConfig();
    if (d.role != null) {
      c.role =
          cfgpb.Config_DeviceConfig_Role.valueOf(
            cfgpb.Config_DeviceConfig_Role.values.indexWhere(
              (e) => e.name == d.role,
            ),
          ) ??
          cfgpb.Config_DeviceConfig_Role.CLIENT;
    }
    if (d.serialEnabled != null) c.serialEnabled = d.serialEnabled!;
    if (d.buttonGpio != null) c.buttonGpio = d.buttonGpio!;
    if (d.buzzerGpio != null) c.buzzerGpio = d.buzzerGpio!;
    if (d.rebroadcastMode != null) {
      c.rebroadcastMode =
          cfgpb.Config_DeviceConfig_RebroadcastMode.valueOf(
            cfgpb.Config_DeviceConfig_RebroadcastMode.values.indexWhere(
              (e) => e.name == d.rebroadcastMode,
            ),
          ) ??
          cfgpb.Config_DeviceConfig_RebroadcastMode.ALL;
    }
    if (d.nodeInfoBroadcastSecs != null) {
      c.nodeInfoBroadcastSecs = d.nodeInfoBroadcastSecs!;
    }
    if (d.doubleTapAsButtonPress != null) {
      c.doubleTapAsButtonPress = d.doubleTapAsButtonPress!;
    }
    if (d.isManaged != null) {
      c.isManaged = d.isManaged!;
    }
    if (d.disableTripleClick != null) {
      c.disableTripleClick = d.disableTripleClick!;
    }
    if (d.tzdef != null) {
      c.tzdef = d.tzdef!;
    }
    if (d.ledHeartbeatDisabled != null) {
      c.ledHeartbeatDisabled = d.ledHeartbeatDisabled!;
    }
    if (d.buzzerMode != null) {
      c.buzzerMode =
          cfgpb.Config_DeviceConfig_BuzzerMode.valueOf(
            cfgpb.Config_DeviceConfig_BuzzerMode.values.indexWhere(
              (e) => e.name == d.buzzerMode,
            ),
          ) ??
          cfgpb.Config_DeviceConfig_BuzzerMode.ALL_ENABLED;
    }
    return c;
  }

  static cfgpb.Config_PositionConfig _toPositionConfig(PositionConfigDto p) {
    final c = cfgpb.Config_PositionConfig();
    if (p.positionBroadcastSecs != null) {
      c.positionBroadcastSecs = p.positionBroadcastSecs!;
    }
    if (p.positionBroadcastSmartEnabled != null) {
      c.positionBroadcastSmartEnabled = p.positionBroadcastSmartEnabled!;
    }
    if (p.fixedPosition != null) {
      c.fixedPosition = p.fixedPosition!;
    }
    if (p.gpsEnabled != null) {
      c.gpsEnabled = p.gpsEnabled!;
    }
    if (p.gpsUpdateInterval != null) {
      c.gpsUpdateInterval = p.gpsUpdateInterval!;
    }
    if (p.gpsAttemptTime != null) {
      c.gpsAttemptTime = p.gpsAttemptTime!;
    }
    if (p.positionFlags != null) {
      c.positionFlags = p.positionFlags!;
    }
    if (p.rxGpio != null) {
      c.rxGpio = p.rxGpio!;
    }
    if (p.txGpio != null) {
      c.txGpio = p.txGpio!;
    }
    if (p.broadcastSmartMinimumDistance != null) {
      c.broadcastSmartMinimumDistance = p.broadcastSmartMinimumDistance!;
    }
    if (p.broadcastSmartMinimumIntervalSecs != null) {
      c.broadcastSmartMinimumIntervalSecs =
          p.broadcastSmartMinimumIntervalSecs!;
    }
    if (p.gpsEnGpio != null) {
      c.gpsEnGpio = p.gpsEnGpio!;
    }
    if (p.gpsMode != null) {
      c.gpsMode =
          cfgpb.Config_PositionConfig_GpsMode.valueOf(
            cfgpb.Config_PositionConfig_GpsMode.values.indexWhere(
              (e) => e.name == p.gpsMode,
            ),
          ) ??
          cfgpb.Config_PositionConfig_GpsMode.DISABLED;
    }
    return c;
  }

  static cfgpb.Config_PowerConfig _toPowerConfig(PowerConfigDto p) {
    final c = cfgpb.Config_PowerConfig();
    if (p.isPowerSaving != null) c.isPowerSaving = p.isPowerSaving!;
    if (p.onBatteryShutdownAfterSecs != null) {
      c.onBatteryShutdownAfterSecs = p.onBatteryShutdownAfterSecs!;
    }
    if (p.adcMultiplierOverride != null) {
      c.adcMultiplierOverride = p.adcMultiplierOverride!;
    }
    if (p.waitBluetoothSecs != null) c.waitBluetoothSecs = p.waitBluetoothSecs!;
    if (p.sdsSecs != null) c.sdsSecs = p.sdsSecs!;
    if (p.lsSecs != null) c.lsSecs = p.lsSecs!;
    if (p.minWakeSecs != null) c.minWakeSecs = p.minWakeSecs!;
    if (p.deviceBatteryInaAddress != null) {
      c.deviceBatteryInaAddress = p.deviceBatteryInaAddress!;
    }
    if (p.powermonEnables != null) {
      c.powermonEnables = Int64.parseInt(p.powermonEnables.toString());
    }
    return c;
  }

  static cfgpb.Config_NetworkConfig _toNetworkConfig(NetworkConfigDto n) {
    final c = cfgpb.Config_NetworkConfig();
    if (n.wifiEnabled != null) c.wifiEnabled = n.wifiEnabled!;
    if (n.wifiSsid != null) c.wifiSsid = n.wifiSsid!;
    if (n.wifiPsk != null) {
      c.wifiPsk = n.wifiPsk!;
    }
    if (n.ntpServer != null) c.ntpServer = n.ntpServer!;
    if (n.ethEnabled != null) {
      c.ethEnabled = n.ethEnabled!;
    }
    if (n.addressMode != null) {
      c.addressMode =
          cfgpb.Config_NetworkConfig_AddressMode.valueOf(
            cfgpb.Config_NetworkConfig_AddressMode.values.indexWhere(
              (e) => e.name == n.addressMode,
            ),
          ) ??
          cfgpb.Config_NetworkConfig_AddressMode.DHCP;
    }
    if (n.ipv4Config != null) {
      c.ipv4Config = cfgpb.Config_NetworkConfig_IpV4Config();
      if (n.ipv4Config!.ip != null) {
        c.ipv4Config.ip = n.ipv4Config!.ip!;
      }
      if (n.ipv4Config!.gateway != null) {
        c.ipv4Config.gateway = n.ipv4Config!.gateway!;
      }
      if (n.ipv4Config!.subnet != null) {
        c.ipv4Config.subnet = n.ipv4Config!.subnet!;
      }
      if (n.ipv4Config!.dns != null) {
        c.ipv4Config.dns = n.ipv4Config!.dns!;
      }
    }
    if (n.rsyslogServer != null) {
      c.rsyslogServer = n.rsyslogServer!;
    }
    if (n.enabledProtocols != null) {
      c.enabledProtocols = n.enabledProtocols!;
    }
    if (n.ipv6Enabled != null) {
      c.ipv6Enabled = n.ipv6Enabled!;
    }
    return c;
  }

  static cfgpb.Config_DisplayConfig _toDisplayConfig(DisplayConfigDto d) {
    final c = cfgpb.Config_DisplayConfig();
    if (d.screenOnSecs != null) {
      c.screenOnSecs = d.screenOnSecs!;
    }
    if (d.autoScreenCarouselSecs != null) {
      c.autoScreenCarouselSecs = d.autoScreenCarouselSecs!;
    }
    if (d.compassNorthTop != null) {
      c.compassNorthTop = d.compassNorthTop!;
    }
    if (d.flipScreen != null) {
      c.flipScreen = d.flipScreen!;
    }
    if (d.units != null) {
      c.units =
          cfgpb.Config_DisplayConfig_DisplayUnits.valueOf(
            cfgpb.Config_DisplayConfig_DisplayUnits.values.indexWhere(
              (e) => e.name == d.units,
            ),
          ) ??
          cfgpb.Config_DisplayConfig_DisplayUnits.METRIC;
    }
    if (d.oled != null) {
      c.oled =
          cfgpb.Config_DisplayConfig_OledType.valueOf(
            cfgpb.Config_DisplayConfig_OledType.values.indexWhere(
              (e) => e.name == d.oled,
            ),
          ) ??
          cfgpb.Config_DisplayConfig_OledType.OLED_AUTO;
    }
    if (d.displaymode != null) {
      c.displaymode =
          cfgpb.Config_DisplayConfig_DisplayMode.valueOf(
            cfgpb.Config_DisplayConfig_DisplayMode.values.indexWhere(
              (e) => e.name == d.displaymode,
            ),
          ) ??
          cfgpb.Config_DisplayConfig_DisplayMode.DEFAULT;
    }
    if (d.headingBold != null) {
      c.headingBold = d.headingBold!;
    }
    if (d.wakeOnTapOrMotion != null) {
      c.wakeOnTapOrMotion = d.wakeOnTapOrMotion!;
    }
    if (d.compassOrientation != null) {
      c.compassOrientation =
          cfgpb.Config_DisplayConfig_CompassOrientation.valueOf(
            cfgpb.Config_DisplayConfig_CompassOrientation.values.indexWhere(
              (e) => e.name == d.compassOrientation,
            ),
          ) ??
          cfgpb.Config_DisplayConfig_CompassOrientation.DEGREES_0;
    }
    if (d.use12hClock != null) {
      c.use12hClock = d.use12hClock!;
    }
    if (d.useLongNodeName != null) {
      c.useLongNodeName = d.useLongNodeName!;
    }
    return c;
  }

  static cfgpb.Config_LoRaConfig _toLoRaConfig(LoRaConfigDto l) {
    final c = cfgpb.Config_LoRaConfig();
    if (l.usePreset != null) {
      c.usePreset = l.usePreset!;
    }
    if (l.modemPreset != null) {
      c.modemPreset =
          cfgpb.Config_LoRaConfig_ModemPreset.valueOf(
            cfgpb.Config_LoRaConfig_ModemPreset.values.indexWhere(
              (e) => e.name == l.modemPreset,
            ),
          ) ??
          cfgpb.Config_LoRaConfig_ModemPreset.LONG_FAST;
    }
    if (l.bandwidth != null) {
      c.bandwidth = l.bandwidth!.round();
    }
    if (l.spreadFactor != null) {
      c.spreadFactor = l.spreadFactor!;
    }
    if (l.codingRate != null) {
      c.codingRate = l.codingRate!;
    }
    if (l.frequencyOffset != null) {
      c.frequencyOffset = l.frequencyOffset!;
    }
    if (l.region != null) {
      c.region =
          cfgpb.Config_LoRaConfig_RegionCode.valueOf(
            cfgpb.Config_LoRaConfig_RegionCode.values.indexWhere(
              (e) => e.name == l.region,
            ),
          ) ??
          cfgpb.Config_LoRaConfig_RegionCode.US;
    }
    if (l.hopLimit != null) {
      c.hopLimit = l.hopLimit!;
    }
    if (l.txEnabled != null) {
      c.txEnabled = l.txEnabled!;
    }
    if (l.txPower != null) {
      c.txPower = l.txPower!;
    }
    if (l.channelNum != null) {
      c.channelNum = l.channelNum!;
    }
    if (l.overrideDutyCycle != null) {
      c.overrideDutyCycle = l.overrideDutyCycle!;
    }
    if (l.sx126xRxBoostedGain != null) {
      c.sx126xRxBoostedGain = l.sx126xRxBoostedGain!;
    }
    if (l.overrideFrequency != null) {
      c.overrideFrequency = l.overrideFrequency!;
    }
    if (l.paFanDisabled != null) {
      c.paFanDisabled = l.paFanDisabled!;
    }
    if (l.ignoreIncoming != null) {
      c.ignoreIncoming.addAll(l.ignoreIncoming!);
    }
    if (l.ignoreMqtt != null) {
      c.ignoreMqtt = l.ignoreMqtt!;
    }
    if (l.configOkToMqtt != null) {
      c.configOkToMqtt = l.configOkToMqtt!;
    }
    return c;
  }

  static cfgpb.Config_BluetoothConfig _toBluetoothConfig(BluetoothConfigDto b) {
    final c = cfgpb.Config_BluetoothConfig();
    if (b.enabled != null) {
      c.enabled = b.enabled!;
    }
    if (b.mode != null) {
      c.mode =
          cfgpb.Config_BluetoothConfig_PairingMode.valueOf(
            cfgpb.Config_BluetoothConfig_PairingMode.values.indexWhere(
              (e) => e.name == b.mode,
            ),
          ) ??
          cfgpb.Config_BluetoothConfig_PairingMode.RANDOM_PIN;
    }
    if (b.fixedPin != null) {
      c.fixedPin = b.fixedPin!;
    }
    return c;
  }

  static cfgpb.Config_SecurityConfig _toSecurityConfig(SecurityConfigDto s) {
    final c = cfgpb.Config_SecurityConfig();
    if (s.publicKey != null) {
      c.publicKey = s.publicKey!;
    }
    if (s.privateKey != null) {
      c.privateKey = s.privateKey!;
    }
    if (s.adminKey != null) {
      c.adminKey.addAll(s.adminKey!);
    }
    if (s.isManaged != null) {
      c.isManaged = s.isManaged!;
    }
    if (s.serialEnabled != null) {
      c.serialEnabled = s.serialEnabled!;
    }
    if (s.debugLogApiEnabled != null) {
      c.debugLogApiEnabled = s.debugLogApiEnabled!;
    }
    if (s.adminChannelEnabled != null) {
      c.adminChannelEnabled = s.adminChannelEnabled!;
    }
    return c;
  }

  static module.ModuleConfig toModuleConfig(ModuleConfigDto dto) {
    final config = module.ModuleConfig();
    if (dto.mqtt != null) {
      config.mqtt = _toMqttConfig(dto.mqtt!);
    }
    if (dto.telemetry != null) {
      config.telemetry = _toTelemetryConfig(dto.telemetry!);
    }
    if (dto.serial != null) {
      config.serial = _toSerialConfig(dto.serial!);
    }
    if (dto.storeForward != null) {
      config.storeForward = _toStoreForwardConfig(dto.storeForward!);
    }
    if (dto.rangeTest != null) {
      config.rangeTest = _toRangeTestConfig(dto.rangeTest!);
    }
    if (dto.externalNotification != null) {
      config.externalNotification = _toExternalNotificationConfig(
        dto.externalNotification!,
      );
    }
    if (dto.audio != null) {
      config.audio = _toAudioConfig(dto.audio!);
    }
    if (dto.neighborInfo != null) {
      config.neighborInfo = _toNeighborInfoConfig(dto.neighborInfo!);
    }
    if (dto.remoteHardware != null) {
      config.remoteHardware = _toRemoteHardwareConfig(dto.remoteHardware!);
    }
    if (dto.paxcounter != null) {
      config.paxcounter = _toPaxcounterConfig(dto.paxcounter!);
    }
    if (dto.cannedMessage != null) {
      config.cannedMessage = _toCannedMessageConfig(dto.cannedMessage!);
    }
    if (dto.ambientLighting != null) {
      config.ambientLighting = _toAmbientLightingConfig(dto.ambientLighting!);
    }
    if (dto.detectionSensor != null) {
      config.detectionSensor = _toDetectionSensorConfig(dto.detectionSensor!);
    }
    if (dto.dtnOverlay != null) {
      config.dtnOverlay = _toDtnOverlayConfig(dto.dtnOverlay!);
    }
    if (dto.broadcastAssist != null) {
      config.broadcastAssist = _toBroadcastAssistConfig(dto.broadcastAssist!);
    }
    if (dto.nodeMod != null) {
      config.nodeMod = _toNodeModConfig(dto.nodeMod!);
    }
    if (dto.nodeModAdmin != null) {
      config.nodeModAdmin = _toNodeModAdminConfig(dto.nodeModAdmin!);
    }
    if (dto.idleGame != null) {
      config.idleGame = _toIdleGameConfig(dto.idleGame!);
    }
    return config;
  }

  static module.ModuleConfig_MQTTConfig _toMqttConfig(MqttConfigDto m) {
    final c = module.ModuleConfig_MQTTConfig();
    if (m.enabled != null) {
      c.enabled = m.enabled!;
    }
    if (m.address != null) {
      c.address = m.address!;
    }
    if (m.username != null) {
      c.username = m.username!;
    }
    if (m.password != null) {
      c.password = m.password!;
    }
    if (m.encryptionEnabled != null) {
      c.encryptionEnabled = m.encryptionEnabled!;
    }
    if (m.jsonEnabled != null) {
      c.jsonEnabled = m.jsonEnabled!;
    }
    if (m.tlsEnabled != null) {
      c.tlsEnabled = m.tlsEnabled!;
    }
    if (m.root != null) {
      c.root = m.root!;
    }
    if (m.proxyToClientEnabled != null) {
      c.proxyToClientEnabled = m.proxyToClientEnabled!;
    }
    if (m.mapReportingEnabled != null) {
      c.mapReportingEnabled = m.mapReportingEnabled!;
    }
    if (m.mapReportSettings != null) {
      c.mapReportSettings = module.ModuleConfig_MapReportSettings();
      if (m.mapReportSettings!.publishIntervalSecs != null) {
        c.mapReportSettings.publishIntervalSecs =
            m.mapReportSettings!.publishIntervalSecs!;
      }
      if (m.mapReportSettings!.positionPrecision != null) {
        c.mapReportSettings.positionPrecision =
            m.mapReportSettings!.positionPrecision!;
      }
      if (m.mapReportSettings!.shouldReportLocation != null) {
        c.mapReportSettings.shouldReportLocation =
            m.mapReportSettings!.shouldReportLocation!;
      }
    }
    return c;
  }

  static module.ModuleConfig_TelemetryConfig _toTelemetryConfig(
    TelemetryConfigDto t,
  ) {
    final c = module.ModuleConfig_TelemetryConfig();
    if (t.deviceUpdateInterval != null) {
      c.deviceUpdateInterval = t.deviceUpdateInterval!;
    }
    if (t.environmentUpdateInterval != null) {
      c.environmentUpdateInterval = t.environmentUpdateInterval!;
    }
    if (t.environmentMeasurementEnabled != null) {
      c.environmentMeasurementEnabled = t.environmentMeasurementEnabled!;
    }
    if (t.environmentScreenEnabled != null) {
      c.environmentScreenEnabled = t.environmentScreenEnabled!;
    }
    if (t.environmentDisplayFahrenheit != null) {
      c.environmentDisplayFahrenheit = t.environmentDisplayFahrenheit!;
    }
    if (t.airQualityEnabled != null) {
      c.airQualityEnabled = t.airQualityEnabled!;
    }
    if (t.airQualityInterval != null) {
      c.airQualityInterval = t.airQualityInterval!;
    }
    if (t.powerMeasurementEnabled != null) {
      c.powerMeasurementEnabled = t.powerMeasurementEnabled!;
    }
    if (t.powerUpdateInterval != null) {
      c.powerUpdateInterval = t.powerUpdateInterval!;
    }
    if (t.powerScreenEnabled != null) {
      c.powerScreenEnabled = t.powerScreenEnabled!;
    }
    if (t.healthMeasurementEnabled != null) {
      c.healthMeasurementEnabled = t.healthMeasurementEnabled!;
    }
    if (t.healthUpdateInterval != null) {
      c.healthUpdateInterval = t.healthUpdateInterval!;
    }
    if (t.healthScreenEnabled != null) {
      c.healthScreenEnabled = t.healthScreenEnabled!;
    }
    if (t.deviceTelemetryEnabled != null) {
      c.deviceTelemetryEnabled = t.deviceTelemetryEnabled!;
    }
    return c;
  }

  static module.ModuleConfig_SerialConfig _toSerialConfig(SerialConfigDto s) {
    final c = module.ModuleConfig_SerialConfig();
    if (s.enabled != null) {
      c.enabled = s.enabled!;
    }
    if (s.echo != null) {
      c.echo = s.echo!;
    }
    if (s.rxd != null) {
      c.rxd = s.rxd!;
    }
    if (s.txd != null) {
      c.txd = s.txd!;
    }
    if (s.baud != null) {
      c.baud =
          module.ModuleConfig_SerialConfig_Serial_Baud.valueOf(
            module.ModuleConfig_SerialConfig_Serial_Baud.values.indexWhere(
              (e) => e.name == s.baud,
            ),
          ) ??
          module.ModuleConfig_SerialConfig_Serial_Baud.BAUD_115200;
    }
    if (s.timeout != null) {
      c.timeout = s.timeout!;
    }
    if (s.mode != null) {
      c.mode =
          module.ModuleConfig_SerialConfig_Serial_Mode.valueOf(
            module.ModuleConfig_SerialConfig_Serial_Mode.values.indexWhere(
              (e) => e.name == s.mode,
            ),
          ) ??
          module.ModuleConfig_SerialConfig_Serial_Mode.DEFAULT;
    }
    if (s.overrideConsoleSerialPort != null) {
      c.overrideConsoleSerialPort = s.overrideConsoleSerialPort!;
    }
    return c;
  }

  static module.ModuleConfig_StoreForwardConfig _toStoreForwardConfig(
    StoreForwardConfigDto sf,
  ) {
    final c = module.ModuleConfig_StoreForwardConfig();
    if (sf.enabled != null) {
      c.enabled = sf.enabled!;
    }
    if (sf.heartbeat != null) {
      c.heartbeat = sf.heartbeat!;
    }
    if (sf.records != null) {
      c.records = sf.records!;
    }
    if (sf.historyReturnMax != null) {
      c.historyReturnMax = sf.historyReturnMax!;
    }
    if (sf.historyReturnWindow != null) {
      c.historyReturnWindow = sf.historyReturnWindow!;
    }
    if (sf.isServer != null) {
      c.isServer = sf.isServer!;
    }
    if (sf.emitControlSignals != null) {
      c.emitControlSignals = sf.emitControlSignals!;
    }
    return c;
  }

  static module.ModuleConfig_RangeTestConfig _toRangeTestConfig(
    RangeTestConfigDto rt,
  ) {
    final c = module.ModuleConfig_RangeTestConfig();
    if (rt.enabled != null) {
      c.enabled = rt.enabled!;
    }
    if (rt.sender != null) {
      c.sender = rt.sender!;
    }
    if (rt.save != null) {
      c.save = rt.save!;
    }
    if (rt.clearOnReboot != null) {
      c.clearOnReboot = rt.clearOnReboot!;
    }
    return c;
  }

  static module.ModuleConfig_ExternalNotificationConfig
  _toExternalNotificationConfig(ExternalNotificationConfigDto en) {
    final c = module.ModuleConfig_ExternalNotificationConfig();
    if (en.enabled != null) {
      c.enabled = en.enabled!;
    }
    if (en.outputMs != null) {
      c.outputMs = en.outputMs!;
    }
    if (en.output != null) {
      c.output = en.output!;
    }
    if (en.active != null) {
      c.active = en.active!;
    }
    if (en.alertMessage != null) {
      c.alertMessage = en.alertMessage!;
    }
    if (en.alertBell != null) {
      c.alertBell = en.alertBell!;
    }
    if (en.usePwm != null) {
      c.usePwm = en.usePwm!;
    }
    if (en.outputVibra != null) {
      c.outputVibra = en.outputVibra!;
    }
    if (en.outputBuzzer != null) {
      c.outputBuzzer = en.outputBuzzer!;
    }
    if (en.alertMessageVibra != null) {
      c.alertMessageVibra = en.alertMessageVibra!;
    }
    if (en.alertMessageBuzzer != null) {
      c.alertMessageBuzzer = en.alertMessageBuzzer!;
    }
    if (en.alertBellVibra != null) {
      c.alertBellVibra = en.alertBellVibra!;
    }
    if (en.alertBellBuzzer != null) {
      c.alertBellBuzzer = en.alertBellBuzzer!;
    }
    if (en.nagTimeout != null) {
      c.nagTimeout = en.nagTimeout!;
    }
    if (en.useI2sAsBuzzer != null) {
      c.useI2sAsBuzzer = en.useI2sAsBuzzer!;
    }
    return c;
  }

  static module.ModuleConfig_AudioConfig _toAudioConfig(AudioConfigDto a) {
    final c = module.ModuleConfig_AudioConfig();
    if (a.codec2Enabled != null) {
      c.codec2Enabled = a.codec2Enabled!;
    }
    if (a.pttPin != null) {
      c.pttPin = a.pttPin!;
    }
    if (a.bitrate != null) {
      c.bitrate =
          module.ModuleConfig_AudioConfig_Audio_Baud.valueOf(
            module.ModuleConfig_AudioConfig_Audio_Baud.values.indexWhere(
              (e) => e.name == a.bitrate,
            ),
          ) ??
          module.ModuleConfig_AudioConfig_Audio_Baud.CODEC2_3200;
    }
    if (a.i2sWs != null) {
      c.i2sWs = a.i2sWs!;
    }
    if (a.i2sSd != null) {
      c.i2sSd = a.i2sSd!;
    }
    if (a.i2sDin != null) {
      c.i2sDin = a.i2sDin!;
    }
    if (a.i2sSck != null) {
      c.i2sSck = a.i2sSck!;
    }
    return c;
  }

  static module.ModuleConfig_NeighborInfoConfig _toNeighborInfoConfig(
    NeighborInfoConfigDto ni,
  ) {
    final c = module.ModuleConfig_NeighborInfoConfig();
    if (ni.enabled != null) {
      c.enabled = ni.enabled!;
    }
    if (ni.updateInterval != null) {
      c.updateInterval = ni.updateInterval!;
    }
    if (ni.transmitOverLora != null) {
      c.transmitOverLora = ni.transmitOverLora!;
    }
    return c;
  }

  static module.ModuleConfig_RemoteHardwareConfig _toRemoteHardwareConfig(
    RemoteHardwareConfigDto rh,
  ) {
    final c = module.ModuleConfig_RemoteHardwareConfig();
    if (rh.enabled != null) {
      c.enabled = rh.enabled!;
    }
    if (rh.allowUndefinedPinAccess != null) {
      c.allowUndefinedPinAccess = rh.allowUndefinedPinAccess!;
    }
    if (rh.availablePins != null) {
      c.availablePins.addAll(
        rh.availablePins!.map((p) {
          final pin = module.RemoteHardwarePin();
          if (p.gpioPin != null) {
            pin.gpioPin = p.gpioPin!;
          }
          if (p.name != null) {
            pin.name = p.name!;
          }
          if (p.type != null) {
            pin.type =
                module.RemoteHardwarePinType.valueOf(
                  module.RemoteHardwarePinType.values.indexWhere(
                    (e) => e.name == p.type,
                  ),
                ) ??
                module.RemoteHardwarePinType.UNKNOWN;
          }
          return pin;
        }),
      );
    }
    return c;
  }

  static module.ModuleConfig_PaxcounterConfig _toPaxcounterConfig(
    PaxcounterConfigDto px,
  ) {
    final c = module.ModuleConfig_PaxcounterConfig();
    if (px.enabled != null) {
      c.enabled = px.enabled!;
    }
    if (px.paxcounterUpdateInterval != null) {
      c.paxcounterUpdateInterval = px.paxcounterUpdateInterval!;
    }
    if (px.wifiThreshold != null) {
      c.wifiThreshold = px.wifiThreshold!;
    }
    if (px.bleThreshold != null) {
      c.bleThreshold = px.bleThreshold!;
    }
    return c;
  }

  static module.ModuleConfig_CannedMessageConfig _toCannedMessageConfig(
    CannedMessageConfigDto cm,
  ) {
    final c = module.ModuleConfig_CannedMessageConfig();
    if (cm.rotary1Enabled != null) {
      c.rotary1Enabled = cm.rotary1Enabled!;
    }
    if (cm.inputbrokerPinA != null) {
      c.inputbrokerPinA = cm.inputbrokerPinA!;
    }
    if (cm.inputbrokerPinB != null) {
      c.inputbrokerPinB = cm.inputbrokerPinB!;
    }
    if (cm.inputbrokerPinPress != null) {
      c.inputbrokerPinPress = cm.inputbrokerPinPress!;
    }
    if (cm.inputbrokerEventCw != null) {
      c.inputbrokerEventCw =
          module.ModuleConfig_CannedMessageConfig_InputEventChar.valueOf(
            module.ModuleConfig_CannedMessageConfig_InputEventChar.values
                .indexWhere((e) => e.name == cm.inputbrokerEventCw),
          ) ??
          module.ModuleConfig_CannedMessageConfig_InputEventChar.NONE;
    }
    if (cm.inputbrokerEventCcw != null) {
      c.inputbrokerEventCcw =
          module.ModuleConfig_CannedMessageConfig_InputEventChar.valueOf(
            module.ModuleConfig_CannedMessageConfig_InputEventChar.values
                .indexWhere((e) => e.name == cm.inputbrokerEventCcw),
          ) ??
          module.ModuleConfig_CannedMessageConfig_InputEventChar.NONE;
    }
    if (cm.inputbrokerEventPress != null) {
      c.inputbrokerEventPress =
          module.ModuleConfig_CannedMessageConfig_InputEventChar.valueOf(
            module.ModuleConfig_CannedMessageConfig_InputEventChar.values
                .indexWhere((e) => e.name == cm.inputbrokerEventPress),
          ) ??
          module.ModuleConfig_CannedMessageConfig_InputEventChar.NONE;
    }
    if (cm.updown1Enabled != null) {
      c.updown1Enabled = cm.updown1Enabled!;
    }
    if (cm.enabled != null) {
      c.enabled = cm.enabled!;
    }
    if (cm.allowInputSource != null) {
      c.allowInputSource = cm.allowInputSource!;
    }
    if (cm.sendBell != null) {
      c.sendBell = cm.sendBell!;
    }
    return c;
  }

  static module.ModuleConfig_AmbientLightingConfig _toAmbientLightingConfig(
    AmbientLightingConfigDto al,
  ) {
    final c = module.ModuleConfig_AmbientLightingConfig();
    if (al.ledState != null) {
      c.ledState = al.ledState!;
    }
    if (al.current != null) {
      c.current = al.current!;
    }
    if (al.red != null) {
      c.red = al.red!;
    }
    if (al.green != null) {
      c.green = al.green!;
    }
    if (al.blue != null) {
      c.blue = al.blue!;
    }
    return c;
  }

  static module.ModuleConfig_DetectionSensorConfig _toDetectionSensorConfig(
    DetectionSensorConfigDto ds,
  ) {
    final c = module.ModuleConfig_DetectionSensorConfig();
    if (ds.enabled != null) c.enabled = ds.enabled!;
    if (ds.minimumBroadcastSecs != null) {
      c.minimumBroadcastSecs = ds.minimumBroadcastSecs!;
    }
    if (ds.stateBroadcastSecs != null) {
      c.stateBroadcastSecs = ds.stateBroadcastSecs!;
    }
    if (ds.sendBell != null) {
      c.sendBell = ds.sendBell!;
    }
    if (ds.name != null) {
      c.name = ds.name!;
    }
    if (ds.monitorPin != null) {
      c.monitorPin = ds.monitorPin!;
    }
    if (ds.detectionTriggerType != null) {
      c.detectionTriggerType =
          module.ModuleConfig_DetectionSensorConfig_TriggerType.valueOf(
            module.ModuleConfig_DetectionSensorConfig_TriggerType.values
                .indexWhere((e) => e.name == ds.detectionTriggerType),
          ) ??
          module.ModuleConfig_DetectionSensorConfig_TriggerType.LOGIC_LOW;
    }
    if (ds.usePullup != null) c.usePullup = ds.usePullup!;
    return c;
  }

  static module.ModuleConfig_DtnOverlayConfig _toDtnOverlayConfig(
    DtnOverlayConfigDto d,
  ) {
    final c = module.ModuleConfig_DtnOverlayConfig();
    if (d.enabled != null) c.enabled = d.enabled!;
    if (d.ttlMinutes != null) c.ttlMinutes = d.ttlMinutes!;
    if (d.initialDelayBaseMs != null) {
      c.initialDelayBaseMs = d.initialDelayBaseMs!;
    }
    if (d.retryBackoffMs != null) c.retryBackoffMs = d.retryBackoffMs!;
    if (d.maxTries != null) c.maxTries = d.maxTries!;
    if (d.lateFallbackEnabled != null) {
      c.lateFallbackEnabled = d.lateFallbackEnabled!;
    }
    if (d.fallbackTailPercent != null) {
      c.fallbackTailPercent = d.fallbackTailPercent!;
    }
    if (d.milestonesEnabled != null) c.milestonesEnabled = d.milestonesEnabled!;
    if (d.perDestMinSpacingMs != null) {
      c.perDestMinSpacingMs = d.perDestMinSpacingMs!;
    }
    if (d.maxActiveDm != null) c.maxActiveDm = d.maxActiveDm!;
    if (d.probeFwplusNearDeadline != null) {
      c.probeFwplusNearDeadline = d.probeFwplusNearDeadline!;
    }
    return c;
  }

  static module.ModuleConfig_BroadcastAssistConfig _toBroadcastAssistConfig(
    BroadcastAssistConfigDto b,
  ) {
    final c = module.ModuleConfig_BroadcastAssistConfig();
    if (b.enabled != null) c.enabled = b.enabled!;
    if (b.degreeThreshold != null) c.degreeThreshold = b.degreeThreshold!;
    if (b.dupThreshold != null) c.dupThreshold = b.dupThreshold!;
    if (b.windowMs != null) c.windowMs = b.windowMs!;
    if (b.maxExtraHops != null) c.maxExtraHops = b.maxExtraHops!;
    if (b.jitterMs != null) c.jitterMs = b.jitterMs!;
    if (b.airtimeGuard != null) c.airtimeGuard = b.airtimeGuard!;
    if (b.allowedPorts != null) c.allowedPorts.addAll(b.allowedPorts!);
    return c;
  }

  static module.ModuleConfig_NodeModConfig _toNodeModConfig(
    NodeModConfigDto n,
  ) {
    final c = module.ModuleConfig_NodeModConfig();
    if (n.textStatus != null) c.textStatus = n.textStatus!;
    if (n.emoji != null) c.emoji = n.emoji!;
    return c;
  }

  static module.ModuleConfig_NodeModAdminConfig _toNodeModAdminConfig(
    NodeModAdminConfigDto n,
  ) {
    final c = module.ModuleConfig_NodeModAdminConfig();
    if (n.snifferEnabled != null) c.snifferEnabled = n.snifferEnabled!;
    if (n.doNotSendPrvOverMqtt != null) {
      c.doNotSendPrvOverMqtt = n.doNotSendPrvOverMqtt!;
    }
    if (n.localStatsOverMeshEnabled != null) {
      c.localStatsOverMeshEnabled = n.localStatsOverMeshEnabled!;
    }
    if (n.localStatsExtendedOverMeshEnabled != null) {
      c.localStatsExtendedOverMeshEnabled =
          n.localStatsExtendedOverMeshEnabled!;
    }
    if (n.idlegameEnabled != null) c.idlegameEnabled = n.idlegameEnabled!;
    if (n.additionalChutil != null) c.additionalChutil = n.additionalChutil!;
    if (n.additionalTxutil != null) c.additionalTxutil = n.additionalTxutil!;
    if (n.additionalPoliteChannelPercent != null) {
      c.additionalPoliteChannelPercent = n.additionalPoliteChannelPercent!;
    }
    if (n.additionalPoliteDutyCyclePercent != null) {
      c.additionalPoliteDutyCyclePercent = n.additionalPoliteDutyCyclePercent!;
    }
    if (n.currentTxUtilLimit != null) {
      c.currentTxUtilLimit = n.currentTxUtilLimit!;
    }
    if (n.currentMaxChannelUtilPercent != null) {
      c.currentMaxChannelUtilPercent = n.currentMaxChannelUtilPercent!;
    }
    if (n.currentPoliteChannelUtilPercent != null) {
      c.currentPoliteChannelUtilPercent = n.currentPoliteChannelUtilPercent!;
    }
    if (n.currentPoliteDutyCyclePercent != null) {
      c.currentPoliteDutyCyclePercent = n.currentPoliteDutyCyclePercent!;
    }
    if (n.autoResponderEnabled != null) {
      c.autoResponderEnabled = n.autoResponderEnabled!;
    }
    if (n.autoResponderText != null) {
      c.autoResponderText = n.autoResponderText!;
    }
    if (n.autoRedirectMessages != null) {
      c.autoRedirectMessages = n.autoRedirectMessages!;
    }
    if (n.autoRedirectTargetNodeId != null) {
      c.autoRedirectTargetNodeId = n.autoRedirectTargetNodeId!;
    }
    if (n.telemetryLimiterEnabled != null) {
      c.telemetryLimiterEnabled = n.telemetryLimiterEnabled!;
    }
    if (n.telemetryLimiterPacketsPerMinute != null) {
      c.telemetryLimiterPacketsPerMinute = n.telemetryLimiterPacketsPerMinute!;
    }
    if (n.telemetryLimiterAutoChanutilEnabled != null) {
      c.telemetryLimiterAutoChanutilEnabled =
          n.telemetryLimiterAutoChanutilEnabled!;
    }
    if (n.telemetryLimiterAutoChanutilThreshold != null) {
      c.telemetryLimiterAutoChanutilThreshold =
          n.telemetryLimiterAutoChanutilThreshold!;
    }
    if (n.positionLimiterEnabled != null) {
      c.positionLimiterEnabled = n.positionLimiterEnabled!;
    }
    if (n.positionLimiterTimeMinutesThreshold != null) {
      c.positionLimiterTimeMinutesThreshold =
          n.positionLimiterTimeMinutesThreshold!;
    }
    if (n.opportunisticFloodingEnabled != null) {
      c.opportunisticFloodingEnabled = n.opportunisticFloodingEnabled!;
    }
    if (n.opportunisticBaseDelayMs != null) {
      c.opportunisticBaseDelayMs = n.opportunisticBaseDelayMs!;
    }
    if (n.opportunisticHopDelayMs != null) {
      c.opportunisticHopDelayMs = n.opportunisticHopDelayMs!;
    }
    if (n.opportunisticSnrGainMs != null) {
      c.opportunisticSnrGainMs = n.opportunisticSnrGainMs!;
    }
    if (n.opportunisticJitterMs != null) {
      c.opportunisticJitterMs = n.opportunisticJitterMs!;
    }
    if (n.opportunisticCancelOnFirstHear != null) {
      c.opportunisticCancelOnFirstHear = n.opportunisticCancelOnFirstHear!;
    }
    if (n.opportunisticAuto != null) {
      c.opportunisticAuto = n.opportunisticAuto!;
    }
    return c;
  }

  static module.ModuleConfig_IdleGameConfig _toIdleGameConfig(
    IdleGameConfigDto i,
  ) {
    final c = module.ModuleConfig_IdleGameConfig();
    // IdleGameConfig in proto only has oneof variant, which is tricky to map back if we only have the name.
    // Assuming 'variant' maps to one of the fields.
    // For now, we might skip this or implement if needed.
    return c;
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
          final a = admin.AdminMessage.fromBuffer(bytes);
          debugPrint(
            '[MeshtasticMappers] Received ADMIN_APP message. Variant: ${a.whichPayloadVariant().name}',
          );
          debugPrint(
            '[MeshtasticMappers]   hasSessionPasskey: ${a.hasSessionPasskey()}',
          );
          debugPrint(
            '[MeshtasticMappers]   hasGetConfigResponse: ${a.hasGetConfigResponse()}',
          );
          debugPrint(
            '[MeshtasticMappers]   hasGetModuleConfigResponse: ${a.hasGetModuleConfigResponse()}',
          );
          return AdminPayloadDto(
            variant: a.whichPayloadVariant().name,
            sessionPasskey: a.hasSessionPasskey()
                ? Uint8List.fromList(a.sessionPasskey)
                : null,
            config: a.hasGetConfigResponse()
                ? _toConfigDto(a.getConfigResponse)
                : null,
            moduleConfig: a.hasGetModuleConfigResponse()
                ? _toModuleConfigDto(a.getModuleConfigResponse)
                : null,
            channel: a.hasGetChannelResponse()
                ? _toChannelDto(a.getChannelResponse)
                : null,
            owner: a.hasGetOwnerResponse()
                ? _toUserDto(a.getOwnerResponse)
                : null,
            deviceUiConfig: a.hasGetUiConfigResponse()
                ? _toDeviceUiConfigDto(a.getUiConfigResponse)
                : null,
          );
        } catch (e) {
          debugPrint('[MeshtasticMappers] Error parsing ADMIN_APP: $e');
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
          return TelemetryPayloadDto(
            variant: v,
            time: t.hasTime() ? t.time.toInt() : null,
            deviceMetrics: t.hasDeviceMetrics()
                ? _toDeviceMetricsDto(t.deviceMetrics)
                : null,
            environmentMetrics: t.hasEnvironmentMetrics()
                ? _toEnvironmentMetricsDto(t.environmentMetrics)
                : null,
            airQualityMetrics: t.hasAirQualityMetrics()
                ? _toAirQualityMetricsDto(t.airQualityMetrics)
                : null,
            powerMetrics: t.hasPowerMetrics()
                ? _toPowerMetricsDto(t.powerMetrics)
                : null,
            localStats: t.hasLocalStats()
                ? _toLocalStatsDto(t.localStats)
                : null,
            healthMetrics: t.hasHealthMetrics()
                ? _toHealthMetricsDto(t.healthMetrics)
                : null,
            hostMetrics: t.hasHostMetrics()
                ? _toHostMetricsDto(t.hostMetrics)
                : null,
            localStatsExtended: t.hasLocalStatsExtended()
                ? const LocalStatsExtendedDto()
                : null,
          );
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

  static channel.Channel toChannel(ChannelDto c) {
    final ch = channel.Channel();
    if (c.index != null) ch.index = c.index!;
    if (c.role != null) {
      try {
        ch.role = channel.Channel_Role.values.firstWhere(
          (e) => e.name == c.role,
        );
      } catch (_) {}
    }
    if (c.settings != null) {
      ch.settings = toChannelSettings(c.settings!);
    }
    return ch;
  }

  static channel.ChannelSettings toChannelSettings(ChannelSettingsDto s) {
    final cs = channel.ChannelSettings();
    if (s.channelNum != null) cs.channelNum = s.channelNum!;
    if (s.psk != null) cs.psk = s.psk!;
    if (s.name != null) cs.name = s.name!;
    if (s.id != null) {
      cs.id = s.id!;
    }
    if (s.uplinkEnabled != null) cs.uplinkEnabled = s.uplinkEnabled!;
    if (s.downlinkEnabled != null) cs.downlinkEnabled = s.downlinkEnabled!;
    if (s.moduleSettings != null) {
      cs.moduleSettings = toModuleSettings(s.moduleSettings!);
    }
    return cs;
  }

  static channel.ModuleSettings toModuleSettings(ModuleSettingsDto m) {
    final ms = channel.ModuleSettings();
    if (m.positionPrecision != null) {
      ms.positionPrecision = m.positionPrecision!;
    }
    return ms;
  }

  static dui.DeviceUIConfig toDeviceUiConfig(DeviceUiConfigDto c) {
    final d = dui.DeviceUIConfig();
    if (c.version != null) d.version = c.version!;
    if (c.screenBrightness != null) d.screenBrightness = c.screenBrightness!;
    if (c.screenTimeout != null) d.screenTimeout = c.screenTimeout!;
    if (c.screenLock != null) d.screenLock = c.screenLock!;
    if (c.settingsLock != null) d.settingsLock = c.settingsLock!;
    if (c.pinCode != null) d.pinCode = c.pinCode!;
    if (c.theme != null) {
      try {
        d.theme = dui.Theme.values.firstWhere((e) => e.name == c.theme);
      } catch (_) {}
    }
    if (c.alertEnabled != null) d.alertEnabled = c.alertEnabled!;
    if (c.bannerEnabled != null) d.bannerEnabled = c.bannerEnabled!;
    if (c.ringToneId != null) d.ringToneId = c.ringToneId!;
    if (c.language != null) {
      try {
        d.language = dui.Language.values.firstWhere(
          (e) => e.name == c.language,
        );
      } catch (_) {}
    }
    // Skipping complex nested objects for now (nodeFilter, nodeHighlight, mapData) as they are less likely to be edited manually
    if (c.calibrationData != null) d.calibrationData = c.calibrationData!;
    if (c.compassMode != null) {
      try {
        d.compassMode = dui.CompassMode.values.firstWhere(
          (e) => e.name == c.compassMode,
        );
      } catch (_) {}
    }
    if (c.screenRgbColor != null) d.screenRgbColor = c.screenRgbColor!;
    if (c.isClockfaceAnalog != null) d.isClockfaceAnalog = c.isClockfaceAnalog!;
    // if (c.gpsFormat != null) {
    //   try {
    //     d.gpsFormat = dui.GPSFormat.values.firstWhere(
    //       (e) => e.name == c.gpsFormat,
    //     );
    //   } catch (_) {}
    // }
    return d;
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

EnvironmentMetricsDto _toEnvironmentMetricsDto(telem.EnvironmentMetrics e) {
  return EnvironmentMetricsDto(
    temperature: e.hasTemperature() ? e.temperature : null,
    relativeHumidity: e.hasRelativeHumidity() ? e.relativeHumidity : null,
    barometricPressure: e.hasBarometricPressure() ? e.barometricPressure : null,
    gasResistance: e.hasGasResistance() ? e.gasResistance : null,
    voltage: e.hasVoltage() ? e.voltage : null,
    current: e.hasCurrent() ? e.current : null,
    iaq: e.hasIaq() ? e.iaq : null,
    distance: e.hasDistance() ? e.distance : null,
    lux: e.hasLux() ? e.lux : null,
    whiteLux: e.hasWhiteLux() ? e.whiteLux : null,
    irLux: e.hasIrLux() ? e.irLux : null,
    uvLux: e.hasUvLux() ? e.uvLux : null,
    windDirection: e.hasWindDirection() ? e.windDirection.toDouble() : null,
    windSpeed: e.hasWindSpeed() ? e.windSpeed : null,
    weight: e.hasWeight() ? e.weight : null,
    windGust: e.hasWindGust() ? e.windGust : null,
    windLull: e.hasWindLull() ? e.windLull : null,
  );
}

AirQualityMetricsDto _toAirQualityMetricsDto(telem.AirQualityMetrics a) {
  return AirQualityMetricsDto(
    pm10Standard: a.hasPm10Standard() ? a.pm10Standard : null,
    pm25Standard: a.hasPm25Standard() ? a.pm25Standard : null,
    pm100Standard: a.hasPm100Standard() ? a.pm100Standard : null,
    pm10Environmental: a.hasPm10Environmental() ? a.pm10Environmental : null,
    pm25Environmental: a.hasPm25Environmental() ? a.pm25Environmental : null,
    pm100Environmental: a.hasPm100Environmental() ? a.pm100Environmental : null,
    particles03um: a.hasParticles03um() ? a.particles03um : null,
    particles05um: a.hasParticles05um() ? a.particles05um : null,
    particles10um: a.hasParticles10um() ? a.particles10um : null,
    particles25um: a.hasParticles25um() ? a.particles25um : null,
    particles50um: a.hasParticles50um() ? a.particles50um : null,
    particles100um: a.hasParticles100um() ? a.particles100um : null,
    co2: a.hasCo2() ? a.co2 : null,
    co2Temperature: a.hasCo2Temperature() ? a.co2Temperature : null,
    co2Humidity: a.hasCo2Humidity() ? a.co2Humidity : null,
    formFormaldehyde: a.hasFormFormaldehyde() ? a.formFormaldehyde : null,
    formHumidity: a.hasFormHumidity() ? a.formHumidity : null,
    formTemperature: a.hasFormTemperature() ? a.formTemperature : null,
    pm40Standard: a.hasPm40Standard() ? a.pm40Standard : null,
  );
}

PowerMetricsDto _toPowerMetricsDto(telem.PowerMetrics p) {
  return PowerMetricsDto(
    ch1Voltage: p.hasCh1Voltage() ? p.ch1Voltage : null,
    ch1Current: p.hasCh1Current() ? p.ch1Current : null,
    ch2Voltage: p.hasCh2Voltage() ? p.ch2Voltage : null,
    ch2Current: p.hasCh2Current() ? p.ch2Current : null,
    ch3Voltage: p.hasCh3Voltage() ? p.ch3Voltage : null,
    ch3Current: p.hasCh3Current() ? p.ch3Current : null,
  );
}

LocalStatsDto _toLocalStatsDto(telem.LocalStats l) {
  return LocalStatsDto(
    uptimeSeconds: l.hasUptimeSeconds() ? l.uptimeSeconds : null,
    channelUtilization: l.hasChannelUtilization() ? l.channelUtilization : null,
    airUtilTx: l.hasAirUtilTx() ? l.airUtilTx : null,
    numPacketsTx: l.hasNumPacketsTx() ? l.numPacketsTx : null,
    numPacketsRx: l.hasNumPacketsRx() ? l.numPacketsRx : null,
    numPacketsRxBad: l.hasNumPacketsRxBad() ? l.numPacketsRxBad : null,
    numOnlineNodes: l.hasNumOnlineNodes() ? l.numOnlineNodes : null,
  );
}

HealthMetricsDto _toHealthMetricsDto(telem.HealthMetrics h) {
  return HealthMetricsDto(
    heartBpm: h.hasHeartBpm() ? h.heartBpm : null,
    spO2: h.hasSpO2() ? h.spO2 : null,
    temperature: h.hasTemperature() ? h.temperature : null,
  );
}

HostMetricsDto _toHostMetricsDto(telem.HostMetrics h) {
  return HostMetricsDto(
    uptimeSeconds: h.hasUptimeSeconds() ? h.uptimeSeconds : null,
    freememBytes: h.hasFreememBytes() ? h.freememBytes.toInt() : null,
    diskfree1Bytes: h.hasDiskfree1Bytes() ? h.diskfree1Bytes.toInt() : null,
    diskfree2Bytes: h.hasDiskfree2Bytes() ? h.diskfree2Bytes.toInt() : null,
    diskfree3Bytes: h.hasDiskfree3Bytes() ? h.diskfree3Bytes.toInt() : null,
    load1: h.hasLoad1() ? h.load1 : null,
    load5: h.hasLoad5() ? h.load5 : null,
    load15: h.hasLoad15() ? h.load15 : null,
    userString: h.hasUserString() ? h.userString : null,
  );
}
