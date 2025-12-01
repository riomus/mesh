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

// Additional Meshtastic app payloads

class WaypointDto {
  final int? id;
  final int? latitudeI;
  final int? longitudeI;
  final int? expire;
  final int? lockedTo;
  final String? name;
  final String? description;
  final int? icon;
  const WaypointDto({
    this.id,
    this.latitudeI,
    this.longitudeI,
    this.expire,
    this.lockedTo,
    this.name,
    this.description,
    this.icon,
  });
}

class WaypointPayloadDto extends DecodedPayloadDto {
  final WaypointDto waypoint;
  const WaypointPayloadDto(this.waypoint);
}

class RemoteHardwarePayloadDto extends DecodedPayloadDto {
  final String? type; // enum name
  final int? gpioMask;
  final int? gpioValue;
  const RemoteHardwarePayloadDto({this.type, this.gpioMask, this.gpioValue});
}

class NeighborEntryDto {
  final int? nodeId;
  final double? snr;
  final int? lastRxTime;
  final int? nodeBroadcastIntervalSecs;
  const NeighborEntryDto({
    this.nodeId,
    this.snr,
    this.lastRxTime,
    this.nodeBroadcastIntervalSecs,
  });
}

class NeighborInfoPayloadDto extends DecodedPayloadDto {
  final int? nodeId;
  final int? lastSentById;
  final int? nodeBroadcastIntervalSecs;
  final List<NeighborEntryDto>? neighbors;
  const NeighborInfoPayloadDto({
    this.nodeId,
    this.lastSentById,
    this.nodeBroadcastIntervalSecs,
    this.neighbors,
  });
}

class StoreForwardPayloadDto extends DecodedPayloadDto {
  final String? variant; // stats/history/heartbeat/text
  const StoreForwardPayloadDto({this.variant});
}

class TelemetryPayloadDto extends DecodedPayloadDto {
  final String? variant; // which telemetry message variant
  const TelemetryPayloadDto({this.variant});
}

class PaxcounterPayloadDto extends DecodedPayloadDto {
  final int? wifi;
  final int? ble;
  final int? uptime;
  const PaxcounterPayloadDto({this.wifi, this.ble, this.uptime});
}

class TraceroutePayloadDto extends DecodedPayloadDto {
  /// The list of nodenums this packet has visited so far to the destination.
  final List<int>? route;

  /// The list of SNRs (in dB, scaled by 4) in the route towards the destination.
  final List<int>? snrTowards;

  /// The list of nodenums the packet has visited on the way back from the destination.
  final List<int>? routeBack;

  /// The list of SNRs (in dB, scaled by 4) in the route back from the destination.
  final List<int>? snrBack;

  const TraceroutePayloadDto({
    this.route,
    this.snrTowards,
    this.routeBack,
    this.snrBack,
  });
}

class KeyVerificationPayloadDto extends DecodedPayloadDto {
  final int? nonce;
  final Uint8List? hash1;
  final Uint8List? hash2;
  const KeyVerificationPayloadDto({this.nonce, this.hash1, this.hash2});
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
  final DeviceConfigDto? device;
  final PositionConfigDto? position;
  const ConfigDto({this.device, this.position});
}

class DeviceConfigDto {
  final String? role; // enum name
  final bool? serialEnabled; // deprecated upstream
  final int? buttonGpio;
  final int? buzzerGpio;
  final String? rebroadcastMode; // enum name
  final int? nodeInfoBroadcastSecs;
  final bool? doubleTapAsButtonPress;
  final bool? isManaged; // deprecated upstream
  final bool? disableTripleClick;
  final String? tzdef;
  final bool? ledHeartbeatDisabled;
  final String? buzzerMode; // enum name

  const DeviceConfigDto({
    this.role,
    this.serialEnabled,
    this.buttonGpio,
    this.buzzerGpio,
    this.rebroadcastMode,
    this.nodeInfoBroadcastSecs,
    this.doubleTapAsButtonPress,
    this.isManaged,
    this.disableTripleClick,
    this.tzdef,
    this.ledHeartbeatDisabled,
    this.buzzerMode,
  });
}

class PositionConfigDto {
  final int? positionBroadcastSecs;
  final bool? positionBroadcastSmartEnabled;
  final bool? fixedPosition;
  final bool? gpsEnabled; // deprecated upstream
  final int? gpsUpdateInterval;
  final int? gpsAttemptTime; // deprecated upstream
  final int? positionFlags;
  final int? rxGpio;
  final int? txGpio;
  final int? broadcastSmartMinimumDistance;
  final int? broadcastSmartMinimumIntervalSecs;
  final int? gpsEnGpio;
  final String? gpsMode; // enum name

  const PositionConfigDto({
    this.positionBroadcastSecs,
    this.positionBroadcastSmartEnabled,
    this.fixedPosition,
    this.gpsEnabled,
    this.gpsUpdateInterval,
    this.gpsAttemptTime,
    this.positionFlags,
    this.rxGpio,
    this.txGpio,
    this.broadcastSmartMinimumDistance,
    this.broadcastSmartMinimumIntervalSecs,
    this.gpsEnGpio,
    this.gpsMode,
  });
}

// Structured ModuleConfig DTO (incremental: starts with MQTT fields)
class ModuleConfigDto {
  final MqttConfigDto? mqtt;
  final TelemetryConfigDto? telemetry;
  final SerialConfigDto? serial;
  final StoreForwardConfigDto? storeForward;
  final RangeTestConfigDto? rangeTest;
  final ExternalNotificationConfigDto? externalNotification;
  final AudioConfigDto? audio;
  final NeighborInfoConfigDto? neighborInfo;
  final RemoteHardwareConfigDto? remoteHardware;
  final PaxcounterConfigDto? paxcounter;
  final CannedMessageConfigDto? cannedMessage;
  final AmbientLightingConfigDto? ambientLighting;
  final DetectionSensorConfigDto? detectionSensor;
  final DtnOverlayConfigDto? dtnOverlay;
  final BroadcastAssistConfigDto? broadcastAssist;
  const ModuleConfigDto({
    this.mqtt,
    this.telemetry,
    this.serial,
    this.storeForward,
    this.rangeTest,
    this.externalNotification,
    this.audio,
    this.neighborInfo,
    this.remoteHardware,
    this.paxcounter,
    this.cannedMessage,
    this.ambientLighting,
    this.detectionSensor,
    this.dtnOverlay,
    this.broadcastAssist,
  });
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

class StoreForwardConfigDto {
  final bool? enabled;
  final bool? heartbeat;
  final int? records;
  final int? historyReturnMax;
  final int? historyReturnWindow;
  final bool? isServer;
  final bool? emitControlSignals;

  const StoreForwardConfigDto({
    this.enabled,
    this.heartbeat,
    this.records,
    this.historyReturnMax,
    this.historyReturnWindow,
    this.isServer,
    this.emitControlSignals,
  });
}

class RangeTestConfigDto {
  final bool? enabled;
  final int? sender;
  final bool? save;
  final bool? clearOnReboot;

  const RangeTestConfigDto({
    this.enabled,
    this.sender,
    this.save,
    this.clearOnReboot,
  });
}

class ExternalNotificationConfigDto {
  final bool? enabled;
  final int? outputMs;
  final int? output;
  final bool? active;
  final bool? alertMessage;
  final bool? alertBell;
  final bool? usePwm;
  final int? outputVibra;
  final int? outputBuzzer;
  final bool? alertMessageVibra;
  final bool? alertMessageBuzzer;
  final bool? alertBellVibra;
  final bool? alertBellBuzzer;
  final int? nagTimeout;
  final bool? useI2sAsBuzzer;

  const ExternalNotificationConfigDto({
    this.enabled,
    this.outputMs,
    this.output,
    this.active,
    this.alertMessage,
    this.alertBell,
    this.usePwm,
    this.outputVibra,
    this.outputBuzzer,
    this.alertMessageVibra,
    this.alertMessageBuzzer,
    this.alertBellVibra,
    this.alertBellBuzzer,
    this.nagTimeout,
    this.useI2sAsBuzzer,
  });
}

class AudioConfigDto {
  final bool? codec2Enabled;
  final int? pttPin;
  final String? bitrate; // enum name
  final int? i2sWs;
  final int? i2sSd;
  final int? i2sDin;
  final int? i2sSck;

  const AudioConfigDto({
    this.codec2Enabled,
    this.pttPin,
    this.bitrate,
    this.i2sWs,
    this.i2sSd,
    this.i2sDin,
    this.i2sSck,
  });
}

class NeighborInfoConfigDto {
  final bool? enabled;
  final int? updateInterval;
  final bool? transmitOverLora;

  const NeighborInfoConfigDto({
    this.enabled,
    this.updateInterval,
    this.transmitOverLora,
  });
}

class RemoteHardwareConfigDto {
  final bool? enabled;
  final bool? allowUndefinedPinAccess;
  final List<RemoteHardwarePinDto>? availablePins;

  const RemoteHardwareConfigDto({
    this.enabled,
    this.allowUndefinedPinAccess,
    this.availablePins,
  });
}

class RemoteHardwarePinDto {
  final int? gpioPin;
  final String? name;
  final String? type; // enum name

  const RemoteHardwarePinDto({this.gpioPin, this.name, this.type});
}

class PaxcounterConfigDto {
  final bool? enabled;
  final int? paxcounterUpdateInterval;
  final int? wifiThreshold;
  final int? bleThreshold;

  const PaxcounterConfigDto({
    this.enabled,
    this.paxcounterUpdateInterval,
    this.wifiThreshold,
    this.bleThreshold,
  });
}

class CannedMessageConfigDto {
  final bool? rotary1Enabled;
  final int? inputbrokerPinA;
  final int? inputbrokerPinB;
  final int? inputbrokerPinPress;
  final String? inputbrokerEventCw; // enum name
  final String? inputbrokerEventCcw; // enum name
  final String? inputbrokerEventPress; // enum name
  final bool? updown1Enabled;
  // Deprecated in proto but included for completeness
  final bool? enabled;
  final String? allowInputSource;
  final bool? sendBell;

  const CannedMessageConfigDto({
    this.rotary1Enabled,
    this.inputbrokerPinA,
    this.inputbrokerPinB,
    this.inputbrokerPinPress,
    this.inputbrokerEventCw,
    this.inputbrokerEventCcw,
    this.inputbrokerEventPress,
    this.updown1Enabled,
    this.enabled,
    this.allowInputSource,
    this.sendBell,
  });
}

class AmbientLightingConfigDto {
  final bool? ledState;
  final int? current;
  final int? red;
  final int? green;
  final int? blue;

  const AmbientLightingConfigDto({
    this.ledState,
    this.current,
    this.red,
    this.green,
    this.blue,
  });
}

class DetectionSensorConfigDto {
  final bool? enabled;
  final int? minimumBroadcastSecs;
  final int? stateBroadcastSecs;
  final bool? sendBell;
  final String? name;
  final int? monitorPin;
  final String? detectionTriggerType; // enum name
  final bool? usePullup;

  const DetectionSensorConfigDto({
    this.enabled,
    this.minimumBroadcastSecs,
    this.stateBroadcastSecs,
    this.sendBell,
    this.name,
    this.monitorPin,
    this.detectionTriggerType,
    this.usePullup,
  });
}

class DtnOverlayConfigDto {
  final bool? enabled;
  final int? ttlMinutes;
  final int? initialDelayBaseMs;
  final int? retryBackoffMs;
  final int? maxTries;
  final bool? lateFallbackEnabled;
  final int? fallbackTailPercent;
  final bool? milestonesEnabled;
  final int? perDestMinSpacingMs;
  final int? maxActiveDm;
  final bool? probeFwplusNearDeadline;

  const DtnOverlayConfigDto({
    this.enabled,
    this.ttlMinutes,
    this.initialDelayBaseMs,
    this.retryBackoffMs,
    this.maxTries,
    this.lateFallbackEnabled,
    this.fallbackTailPercent,
    this.milestonesEnabled,
    this.perDestMinSpacingMs,
    this.maxActiveDm,
    this.probeFwplusNearDeadline,
  });
}

class BroadcastAssistConfigDto {
  final bool? enabled;
  final int? degreeThreshold;
  final int? dupThreshold;
  final int? windowMs;
  final int? maxExtraHops;
  final int? jitterMs;
  final bool? airtimeGuard;
  final List<int>? allowedPorts;

  const BroadcastAssistConfigDto({
    this.enabled,
    this.degreeThreshold,
    this.dupThreshold,
    this.windowMs,
    this.maxExtraHops,
    this.jitterMs,
    this.airtimeGuard,
    this.allowedPorts,
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
  // From meshtastic.DeviceMetadata
  final String? firmwareVersion;
  final int? deviceStateVersion;
  final bool? canShutdown;
  final bool? hasWifi;
  final bool? hasBluetooth;
  final bool? hasEthernet;
  final String? role; // enum name of Config_DeviceConfig_Role
  final int? positionFlags;
  final String? hwModel; // enum name of HardwareModel
  final bool? hasRemoteHardware;
  final bool? hasPKC;
  final int? excludedModules;
  final bool? hasFwPlus;
  final bool? hasNodemod;

  const DeviceMetadataDto({
    this.firmwareVersion,
    this.deviceStateVersion,
    this.canShutdown,
    this.hasWifi,
    this.hasBluetooth,
    this.hasEthernet,
    this.role,
    this.positionFlags,
    this.hwModel,
    this.hasRemoteHardware,
    this.hasPKC,
    this.excludedModules,
    this.hasFwPlus,
    this.hasNodemod,
  });
}

class MqttClientProxyMessageDto {
  // From meshtastic.MqttClientProxyMessage
  final String? topic;
  final Uint8List? data;
  final String? text;
  final bool? retained;

  const MqttClientProxyMessageDto({
    this.topic,
    this.data,
    this.text,
    this.retained,
  });
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
  // From meshtastic.DeviceUIConfig
  final int? version;
  final int? screenBrightness;
  final int? screenTimeout;
  final bool? screenLock;
  final bool? settingsLock;
  final int? pinCode;
  final String? theme; // enum name
  final bool? alertEnabled;
  final bool? bannerEnabled;
  final int? ringToneId;
  final String? language; // enum name
  final DeviceUiNodeFilterDto? nodeFilter;
  final DeviceUiNodeHighlightDto? nodeHighlight;
  final Uint8List? calibrationData;
  final DeviceUiMapDto? mapData;
  final String? compassMode; // enum name
  final int? screenRgbColor;
  final bool? isClockfaceAnalog;
  final String? gpsFormat; // enum name

  const DeviceUiConfigDto({
    this.version,
    this.screenBrightness,
    this.screenTimeout,
    this.screenLock,
    this.settingsLock,
    this.pinCode,
    this.theme,
    this.alertEnabled,
    this.bannerEnabled,
    this.ringToneId,
    this.language,
    this.nodeFilter,
    this.nodeHighlight,
    this.calibrationData,
    this.mapData,
    this.compassMode,
    this.screenRgbColor,
    this.isClockfaceAnalog,
    this.gpsFormat,
  });
}

class DeviceUiNodeFilterDto {
  final bool? filterEnabled;
  final int? minSnr;
  final bool? hideIgnoredNodes;

  const DeviceUiNodeFilterDto({
    this.filterEnabled,
    this.minSnr,
    this.hideIgnoredNodes,
  });
}

class DeviceUiNodeHighlightDto {
  final bool? highlightEnabled;
  final int? minSnr;

  const DeviceUiNodeHighlightDto({
    this.highlightEnabled,
    this.minSnr,
  });
}

class DeviceUiMapDto {
  final int? zoom;
  final int? centerLatI;
  final int? centerLonI;
  final bool? followMe;

  const DeviceUiMapDto({
    this.zoom,
    this.centerLatI,
    this.centerLonI,
    this.followMe,
  });
}

class LogRecordDto {
  final String? level;
  final String? message;
  final String? source;
  const LogRecordDto({this.level, this.message, this.source});
}
