import 'dart:typed_data';

// Typed internal DTOs for Meshtastic. No protobuf types are exposed here.

// Small shared primitives
typedef NodeNum = int;

class PortNumInternal {
  final int id;
  final String name;
  const PortNumInternal(this.id, this.name);
  @override
  String toString() => 'PortNumInternal($name:$id)';
}

// Mesh packet envelope
class MeshPacketDto {
  final int? from;
  final int? to;
  final int? channel;
  final int? id;
  final int? rxTime;
  final double? rxSnr;
  final int? hopLimit;
  final bool? wantAck;
  final String? priority; // enum name
  final int? rxRssi;
  final bool? viaMqtt;
  final int? hopStart;
  final Uint8List? encrypted;
  final Uint8List? publicKey;
  final bool? pkiEncrypted;
  final int? nextHop;
  final int? relayNode;
  final int? txAfter;
  final String? transportMechanism; // enum name
  final DecodedPayloadDto? decoded;
  // Full raw protobuf as JSON (proto3) for lossless transport/debugging
  final Map<String, dynamic>? rawProto;
  // Raw serialized protobuf bytes for complete lossless preservation
  final Uint8List? rawBytes;

  const MeshPacketDto({
    this.from,
    this.to,
    this.channel,
    this.id,
    this.rxTime,
    this.rxSnr,
    this.hopLimit,
    this.wantAck,
    this.priority,
    this.rxRssi,
    this.viaMqtt,
    this.hopStart,
    this.encrypted,
    this.publicKey,
    this.pkiEncrypted,
    this.nextHop,
    this.relayNode,
    this.txAfter,
    this.transportMechanism,
    this.decoded,
    this.rawProto,
    this.rawBytes,
  });
}

// Decoded payloads
sealed class DecodedPayloadDto {
  const DecodedPayloadDto();
}

class TextPayloadDto extends DecodedPayloadDto {
  final String text;
  final int? emoji;
  const TextPayloadDto(this.text, {this.emoji});
}

class PositionDto {
  final int? latitudeI; // 1e-7 degrees
  final int? longitudeI; // 1e-7 degrees
  final int? altitude;
  final int? time;
  final String? locationSource; // enum name
  final String? altitudeSource; // enum name
  final int? timestamp;
  final int? timestampMillisAdjust;
  final int? altitudeHae;
  final int? altitudeGeoidalSeparation;
  final int? pDOP;
  final int? hDOP;
  final int? vDOP;
  final int? gpsAccuracy;
  final int? groundSpeed;
  final int? groundTrack;
  final int? fixQuality;
  final int? fixType;
  final int? satsInView;
  final int? sensorId;
  final int? nextUpdate;
  final int? seqNumber;
  final int? precisionBits;
  const PositionDto({
    this.latitudeI,
    this.longitudeI,
    this.altitude,
    this.time,
    this.locationSource,
    this.altitudeSource,
    this.timestamp,
    this.timestampMillisAdjust,
    this.altitudeHae,
    this.altitudeGeoidalSeparation,
    this.pDOP,
    this.hDOP,
    this.vDOP,
    this.gpsAccuracy,
    this.groundSpeed,
    this.groundTrack,
    this.fixQuality,
    this.fixType,
    this.satsInView,
    this.sensorId,
    this.nextUpdate,
    this.seqNumber,
    this.precisionBits,
  });
}

class PositionPayloadDto extends DecodedPayloadDto {
  final PositionDto position;
  const PositionPayloadDto(this.position);

  // Backward-compatible helpers for existing UI code
  int? get latitudeI => position.latitudeI;
  int? get longitudeI => position.longitudeI;
}

class UserDto {
  final String? id;
  final String? longName;
  final String? shortName;
  final Uint8List? macaddr;
  final String? hwModel; // enum name
  final bool? isLicensed;
  final String? role; // enum name
  final Uint8List? publicKey;
  final bool? isUnmessagable;
  const UserDto({
    this.id,
    this.longName,
    this.shortName,
    this.macaddr,
    this.hwModel,
    this.isLicensed,
    this.role,
    this.publicKey,
    this.isUnmessagable,
  });
}

class UserPayloadDto extends DecodedPayloadDto {
  final UserDto user;
  const UserPayloadDto(this.user);
}

class RoutingPayloadDto extends DecodedPayloadDto {
  const RoutingPayloadDto(); // details can be added later as needed
}

class AdminPayloadDto extends DecodedPayloadDto {
  const AdminPayloadDto(); // details can be added later as needed
}

class RawPayloadDto extends DecodedPayloadDto {
  final PortNumInternal portnum;
  final Uint8List bytes;
  const RawPayloadDto(this.portnum, this.bytes);
}

// FromRadio variant DTOs (typed, minimal fields used by UI)
class MyInfoDto {
  final NodeNum? myNodeNum;
  final int? rebootCount;
  final int? minAppVersion;
  final Uint8List? deviceId;
  final String? pioEnv;
  final String? firmwareEdition; // enum name
  final int? nodedbCount;
  const MyInfoDto({
    this.myNodeNum,
    this.rebootCount,
    this.minAppVersion,
    this.deviceId,
    this.pioEnv,
    this.firmwareEdition,
    this.nodedbCount,
  });
}

class DeviceMetricsDto {
  final int? batteryLevel;
  final double? voltage;
  final double? channelUtilization;
  final double? airUtilTx;
  final int? uptimeSeconds;
  const DeviceMetricsDto({
    this.batteryLevel,
    this.voltage,
    this.channelUtilization,
    this.airUtilTx,
    this.uptimeSeconds,
  });
}

class NodeInfoDto {
  final NodeNum? num;
  final UserDto? user;
  final PositionDto? position;
  final double? snr;
  final int? lastHeard;
  final DeviceMetricsDto? deviceMetrics;
  final int? channel;
  final bool? viaMqtt;
  final int? hopsAway;
  final bool? isFavorite;
  final bool? isIgnored;
  final bool? isKeyManuallyVerified;
  const NodeInfoDto({
    this.num,
    this.user,
    this.position,
    this.snr,
    this.lastHeard,
    this.deviceMetrics,
    this.channel,
    this.viaMqtt,
    this.hopsAway,
    this.isFavorite,
    this.isIgnored,
    this.isKeyManuallyVerified,
  });
}

class ConfigDto {
  // Raw JSON (proto3) of meshtastic.Config
  final Map<String, dynamic>? rawProto;
  // Raw serialized bytes
  final Uint8List? rawBytes;
  const ConfigDto({this.rawProto, this.rawBytes});
}

// Structured ModuleConfig DTO (incremental: starts with MQTT fields)
class ModuleConfigDto {
  final MqttConfigDto? mqtt;
  final TelemetryConfigDto? telemetry;
  final SerialConfigDto? serial;
  const ModuleConfigDto({this.mqtt, this.telemetry, this.serial});
}

class MqttConfigDto {
  final bool? enabled;
  final String? address;
  final String? username;
  final String? password;
  final bool? encryptionEnabled;
  final bool? jsonEnabled;
  final bool? tlsEnabled;
  final String? root;
  final bool? proxyToClientEnabled;
  final bool? mapReportingEnabled;
  final MapReportSettingsDto? mapReportSettings;

  const MqttConfigDto({
    this.enabled,
    this.address,
    this.username,
    this.password,
    this.encryptionEnabled,
    this.jsonEnabled,
    this.tlsEnabled,
    this.root,
    this.proxyToClientEnabled,
    this.mapReportingEnabled,
    this.mapReportSettings,
  });
}

class MapReportSettingsDto {
  final int? publishIntervalSecs;
  final int? positionPrecision;
  final bool? shouldReportLocation;

  const MapReportSettingsDto({
    this.publishIntervalSecs,
    this.positionPrecision,
    this.shouldReportLocation,
  });
}

class TelemetryConfigDto {
  final int? deviceUpdateInterval;
  final int? environmentUpdateInterval;
  final bool? environmentMeasurementEnabled;
  final bool? environmentScreenEnabled;
  final bool? environmentDisplayFahrenheit;
  final bool? airQualityEnabled;
  final int? airQualityInterval;
  final bool? powerMeasurementEnabled;
  final int? powerUpdateInterval;
  final bool? powerScreenEnabled;
  final bool? healthMeasurementEnabled;
  final int? healthUpdateInterval;
  final bool? healthScreenEnabled;
  final bool? deviceTelemetryEnabled;

  const TelemetryConfigDto({
    this.deviceUpdateInterval,
    this.environmentUpdateInterval,
    this.environmentMeasurementEnabled,
    this.environmentScreenEnabled,
    this.environmentDisplayFahrenheit,
    this.airQualityEnabled,
    this.airQualityInterval,
    this.powerMeasurementEnabled,
    this.powerUpdateInterval,
    this.powerScreenEnabled,
    this.healthMeasurementEnabled,
    this.healthUpdateInterval,
    this.healthScreenEnabled,
    this.deviceTelemetryEnabled,
  });
}

class SerialConfigDto {
  final bool? enabled;
  final bool? echo;
  final int? rxd;
  final int? txd;
  final String? baud; // enum name
  final int? timeout;
  final String? mode; // enum name
  final bool? overrideConsoleSerialPort;

  const SerialConfigDto({
    this.enabled,
    this.echo,
    this.rxd,
    this.txd,
    this.baud,
    this.timeout,
    this.mode,
    this.overrideConsoleSerialPort,
  });
}

class ChannelDto {
  final int? index;
  const ChannelDto({this.index});
}

class QueueStatusDto {
  final int? size;
  final int? maxlen;
  final int? meshPacketId;
  const QueueStatusDto({this.size, this.maxlen, this.meshPacketId});
}

class DeviceMetadataDto {
  final NodeNum? myNodeNum;
  // Raw JSON (proto3) of meshtastic.DeviceMetadata
  final Map<String, dynamic>? rawProto;
  // Raw serialized bytes
  final Uint8List? rawBytes;
  const DeviceMetadataDto({this.myNodeNum, this.rawProto, this.rawBytes});
}

class MqttClientProxyMessageDto {
  // Raw JSON (proto3) of meshtastic.MqttClientProxyMessage
  final Map<String, dynamic>? rawProto;
  // Raw serialized bytes
  final Uint8List? rawBytes;
  const MqttClientProxyMessageDto({this.rawProto, this.rawBytes});
}

class FileInfoDto {
  final String? fileName;
  final int? sizeBytes;
  const FileInfoDto({this.fileName, this.sizeBytes});
}

class ClientNotificationDto {
  final String? message;
  const ClientNotificationDto({this.message});
}

class DeviceUiConfigDto {
  // Raw JSON (proto3) of meshtastic.DeviceUIConfig
  final Map<String, dynamic>? rawProto;
  // Raw serialized bytes
  final Uint8List? rawBytes;
  const DeviceUiConfigDto({this.rawProto, this.rawBytes});
}

class LogRecordDto {
  final String? level;
  final String? message;
  final String? source;
  const LogRecordDto({this.level, this.message, this.source});
}
