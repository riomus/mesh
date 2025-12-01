
import 'dart:convert';
import 'dart:typed_data';

import '../../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../../generated/meshtastic/meshtastic/portnums.pbenum.dart' as port;
import '../../generated/meshtastic/meshtastic/module_config.pb.dart' as module;
import '../../generated/meshtastic/meshtastic/admin.pb.dart' as admin;
import '../../generated/meshtastic/meshtastic/telemetry.pb.dart' as telem;
import 'meshtastic_event.dart';
import 'meshtastic_models.dart';

/// Helpers to convert protobuf messages to domain events and decoded payloads
/// without exposing any protobuf-generated types to consumers.
class MeshtasticMappers {
  static MeshtasticEvent fromFromRadio(mesh.FromRadio fr) {
    switch (fr.whichPayloadVariant()) {
      case mesh.FromRadio_PayloadVariant.packet:
        final pkt = _toMeshPacketDto(fr.packet);
        return MeshPacketEvent(packet: pkt, decoded: pkt.decoded);
      case mesh.FromRadio_PayloadVariant.myInfo:
        final mi = fr.myInfo;
        return MyInfoEvent(MyInfoDto(
          myNodeNum: mi.hasMyNodeNum() ? mi.myNodeNum : null,
          rebootCount: mi.hasRebootCount() ? mi.rebootCount : null,
          minAppVersion: mi.hasMinAppVersion() ? mi.minAppVersion : null,
          deviceId: mi.hasDeviceId() ? Uint8List.fromList(mi.deviceId) : null,
          pioEnv: mi.hasPioEnv() ? mi.pioEnv : null,
          firmwareEdition: mi.hasFirmwareEdition() ? mi.firmwareEdition.name : null,
          nodedbCount: mi.hasNodedbCount() ? mi.nodedbCount : null,
        ));
      case mesh.FromRadio_PayloadVariant.nodeInfo:
        final n = fr.nodeInfo;
        return NodeInfoEvent(NodeInfoDto(
          num: n.hasNum() ? n.num : null,
          user: n.hasUser() ? _toUserDto(n.user) : null,
          position: n.hasPosition() ? _toPositionDto(n.position) : null,
          snr: n.hasSnr() ? n.snr : null,
          lastHeard: n.hasLastHeard() ? n.lastHeard : null,
          deviceMetrics: n.hasDeviceMetrics() ? _toDeviceMetricsDto(n.deviceMetrics) : null,
          channel: n.hasChannel() ? n.channel : null,
          viaMqtt: n.hasViaMqtt() ? n.viaMqtt : null,
          hopsAway: n.hasHopsAway() ? n.hopsAway : null,
          isFavorite: n.hasIsFavorite() ? n.isFavorite : null,
          isIgnored: n.hasIsIgnored() ? n.isIgnored : null,
          isKeyManuallyVerified: n.hasIsKeyManuallyVerified() ? n.isKeyManuallyVerified : null,
        ));
      case mesh.FromRadio_PayloadVariant.config:
        return ConfigEvent(ConfigDto(
          rawBytes: Uint8List.fromList(fr.config.writeToBuffer()),
          rawProto: fr.config.toProto3Json() as Map<String, dynamic>,
        ));
      case mesh.FromRadio_PayloadVariant.logRecord:
        return LogRecordEvent(LogRecordDto(
          level: fr.logRecord.hasLevel() ? fr.logRecord.level.name : null,
          message: fr.logRecord.hasMessage() ? fr.logRecord.message : null,
          source: fr.logRecord.hasSource() ? fr.logRecord.source : null,
        ));
      case mesh.FromRadio_PayloadVariant.configCompleteId:
        return ConfigCompleteEvent(fr.configCompleteId);
      case mesh.FromRadio_PayloadVariant.rebooted:
        return RebootedEvent(fr.rebooted);
      case mesh.FromRadio_PayloadVariant.moduleConfig:
        return ModuleConfigEvent(_toModuleConfigDto(fr.moduleConfig));
      case mesh.FromRadio_PayloadVariant.channel:
        return ChannelEvent(ChannelDto(index: fr.channel.hasIndex() ? fr.channel.index : null));
      case mesh.FromRadio_PayloadVariant.queueStatus:
        return QueueStatusEvent(QueueStatusDto(
          // Proto has `free` (entries free); we surface as `size` for UI brevity
          size: fr.queueStatus.hasFree() ? fr.queueStatus.free : null,
          maxlen: fr.queueStatus.hasMaxlen() ? fr.queueStatus.maxlen : null,
          meshPacketId:
              fr.queueStatus.hasMeshPacketId() ? fr.queueStatus.meshPacketId : null,
        ));
      case mesh.FromRadio_PayloadVariant.metadata:
        // Preserve full bytes; specific fields can be added later.
        return DeviceMetadataEvent(DeviceMetadataDto(
          rawBytes: Uint8List.fromList(fr.metadata.writeToBuffer()),
          rawProto: fr.metadata.toProto3Json() as Map<String, dynamic>,
        ));
      case mesh.FromRadio_PayloadVariant.mqttClientProxyMessage:
        return MqttClientProxyEvent(MqttClientProxyMessageDto(
          rawBytes: Uint8List.fromList(fr.mqttClientProxyMessage.writeToBuffer()),
          rawProto:
              fr.mqttClientProxyMessage.toProto3Json() as Map<String, dynamic>,
        ));
      case mesh.FromRadio_PayloadVariant.fileInfo:
        return FileInfoEvent(FileInfoDto(
          fileName: fr.fileInfo.hasFileName() ? fr.fileInfo.fileName : null,
          sizeBytes: fr.fileInfo.hasSizeBytes() ? fr.fileInfo.sizeBytes : null,
        ));
      case mesh.FromRadio_PayloadVariant.clientNotification:
        return ClientNotificationEvent(ClientNotificationDto(
            message: fr.clientNotification.hasMessage()
                ? fr.clientNotification.message
                : null));
      case mesh.FromRadio_PayloadVariant.deviceuiConfig:
        return DeviceUiConfigEvent(DeviceUiConfigDto(
          rawBytes: Uint8List.fromList(fr.deviceuiConfig.writeToBuffer()),
          rawProto: fr.deviceuiConfig.toProto3Json() as Map<String, dynamic>,
        ));
      case mesh.FromRadio_PayloadVariant.xmodemPacket:
        // Not exposed directly; surface as log record with a descriptive message.
        return const LogRecordEvent(
            LogRecordDto(level: 'INFO', message: 'XModem packet received'));
      case mesh.FromRadio_PayloadVariant.notSet:
        return const LogRecordEvent(
            LogRecordDto(level: 'WARN', message: 'FromRadio payload not set'));
    }
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
          publishIntervalSecs:
              s.hasPublishIntervalSecs() ? s.publishIntervalSecs : null,
          positionPrecision:
              s.hasPositionPrecision() ? s.positionPrecision : null,
          shouldReportLocation:
              s.hasShouldReportLocation() ? s.shouldReportLocation : null,
        );
      }
      mqtt = MqttConfigDto(
        enabled: m.hasEnabled() ? m.enabled : null,
        address: m.hasAddress() ? m.address : null,
        username: m.hasUsername() ? m.username : null,
        password: m.hasPassword() ? m.password : null,
        encryptionEnabled: m.hasEncryptionEnabled() ? m.encryptionEnabled : null,
        jsonEnabled: m.hasJsonEnabled() ? m.jsonEnabled : null,
        tlsEnabled: m.hasTlsEnabled() ? m.tlsEnabled : null,
        root: m.hasRoot() ? m.root : null,
        proxyToClientEnabled:
            m.hasProxyToClientEnabled() ? m.proxyToClientEnabled : null,
        mapReportingEnabled:
            m.hasMapReportingEnabled() ? m.mapReportingEnabled : null,
        mapReportSettings: mapReport,
      );
    }
    if (mc.hasTelemetry()) {
      final t = mc.telemetry;
      telemetry = TelemetryConfigDto(
        deviceUpdateInterval:
            t.hasDeviceUpdateInterval() ? t.deviceUpdateInterval : null,
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
        airQualityEnabled:
            t.hasAirQualityEnabled() ? t.airQualityEnabled : null,
        airQualityInterval:
            t.hasAirQualityInterval() ? t.airQualityInterval : null,
        powerMeasurementEnabled: t.hasPowerMeasurementEnabled()
            ? t.powerMeasurementEnabled
            : null,
        powerUpdateInterval:
            t.hasPowerUpdateInterval() ? t.powerUpdateInterval : null,
        powerScreenEnabled:
            t.hasPowerScreenEnabled() ? t.powerScreenEnabled : null,
        healthMeasurementEnabled: t.hasHealthMeasurementEnabled()
            ? t.healthMeasurementEnabled
            : null,
        healthUpdateInterval:
            t.hasHealthUpdateInterval() ? t.healthUpdateInterval : null,
        healthScreenEnabled:
            t.hasHealthScreenEnabled() ? t.healthScreenEnabled : null,
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
    return ModuleConfigDto(mqtt: mqtt, telemetry: telemetry, serial: serial);
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
      encrypted: packet.hasEncrypted() ? Uint8List.fromList(packet.encrypted) : null,
      publicKey: packet.hasPublicKey() ? Uint8List.fromList(packet.publicKey) : null,
      pkiEncrypted: packet.hasPkiEncrypted() ? packet.pkiEncrypted : null,
      nextHop: packet.hasNextHop() ? packet.nextHop : null,
      relayNode: packet.hasRelayNode() ? packet.relayNode : null,
      txAfter: packet.hasTxAfter() ? packet.txAfter : null,
      transportMechanism:
          packet.hasTransportMechanism() ? packet.transportMechanism.name : null,
      decoded: decoded,
      rawProto: packet.toProto3Json() as Map<String, dynamic>,
      rawBytes: Uint8List.fromList(packet.writeToBuffer()),
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
        return TextPayloadDto(text,
            emoji: data.hasEmoji() ? data.emoji : null);
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
          mesh.Routing.fromBuffer(bytes);
          return const RoutingPayloadDto();
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
    timestampMillisAdjust:
        pos.hasTimestampMillisAdjust() ? pos.timestampMillisAdjust : null,
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
    channelUtilization:
        dm.hasChannelUtilization() ? dm.channelUtilization : null,
    airUtilTx: dm.hasAirUtilTx() ? dm.airUtilTx : null,
    uptimeSeconds: dm.hasUptimeSeconds() ? dm.uptimeSeconds : null,
  );
}
