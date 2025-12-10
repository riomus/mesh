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
  final String? variant;
  final String? errorReason;
  final int? requestId;
  const RoutingPayloadDto({this.variant, this.errorReason, this.requestId});
}

class AdminPayloadDto extends DecodedPayloadDto {
  final String? variant;
  final Uint8List? sessionPasskey;
  final ConfigDto? config;
  final ModuleConfigDto? moduleConfig;
  final ChannelDto? channel;
  final UserDto? owner;
  final DeviceUiConfigDto? deviceUiConfig;

  const AdminPayloadDto({
    this.variant,
    this.sessionPasskey,
    this.config,
    this.moduleConfig,
    this.channel,
    this.owner,
    this.deviceUiConfig,
  });
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
  final int? time;
  final DeviceMetricsDto? deviceMetrics;
  final EnvironmentMetricsDto? environmentMetrics;
  final AirQualityMetricsDto? airQualityMetrics;
  final PowerMetricsDto? powerMetrics;
  final LocalStatsDto? localStats;
  final HealthMetricsDto? healthMetrics;
  final HostMetricsDto? hostMetrics;
  final LocalStatsExtendedDto? localStatsExtended;

  const TelemetryPayloadDto({
    this.variant,
    this.time,
    this.deviceMetrics,
    this.environmentMetrics,
    this.airQualityMetrics,
    this.powerMetrics,
    this.localStats,
    this.healthMetrics,
    this.hostMetrics,
    this.localStatsExtended,
  });
}

class EnvironmentMetricsDto {
  final double? temperature;
  final double? relativeHumidity;
  final double? barometricPressure;
  final double? gasResistance;
  final double? voltage;
  final double? current;
  final int? iaq;
  final double? distance;
  final double? lux;
  final double? whiteLux;
  final double? irLux;
  final double? uvLux;
  final double? windDirection;
  final double? windSpeed;
  final double? weight;
  final double? windGust;
  final double? windLull;

  const EnvironmentMetricsDto({
    this.temperature,
    this.relativeHumidity,
    this.barometricPressure,
    this.gasResistance,
    this.voltage,
    this.current,
    this.iaq,
    this.distance,
    this.lux,
    this.whiteLux,
    this.irLux,
    this.uvLux,
    this.windDirection,
    this.windSpeed,
    this.weight,
    this.windGust,
    this.windLull,
  });
}

class AirQualityMetricsDto {
  final int? pm10Standard;
  final int? pm25Standard;
  final int? pm100Standard;
  final int? pm10Environmental;
  final int? pm25Environmental;
  final int? pm100Environmental;
  final int? particles03um;
  final int? particles05um;
  final int? particles10um;
  final int? particles25um;
  final int? particles50um;
  final int? particles100um;
  final int? co2;
  final double? co2Temperature;
  final double? co2Humidity;
  final double? formFormaldehyde;
  final double? formHumidity;
  final double? formTemperature;
  final int? pm40Standard;

  const AirQualityMetricsDto({
    this.pm10Standard,
    this.pm25Standard,
    this.pm100Standard,
    this.pm10Environmental,
    this.pm25Environmental,
    this.pm100Environmental,
    this.particles03um,
    this.particles05um,
    this.particles10um,
    this.particles25um,
    this.particles50um,
    this.particles100um,
    this.co2,
    this.co2Temperature,
    this.co2Humidity,
    this.formFormaldehyde,
    this.formHumidity,
    this.formTemperature,
    this.pm40Standard,
  });
}

class PowerMetricsDto {
  final double? ch1Voltage;
  final double? ch1Current;
  final double? ch2Voltage;
  final double? ch2Current;
  final double? ch3Voltage;
  final double? ch3Current;

  const PowerMetricsDto({
    this.ch1Voltage,
    this.ch1Current,
    this.ch2Voltage,
    this.ch2Current,
    this.ch3Voltage,
    this.ch3Current,
  });
}

class LocalStatsDto {
  final int? uptimeSeconds;
  final double? channelUtilization;
  final double? airUtilTx;
  final int? numPacketsTx;
  final int? numPacketsRx;
  final int? numPacketsRxBad;
  final int? numOnlineNodes;

  const LocalStatsDto({
    this.uptimeSeconds,
    this.channelUtilization,
    this.airUtilTx,
    this.numPacketsTx,
    this.numPacketsRx,
    this.numPacketsRxBad,
    this.numOnlineNodes,
  });
}

class HealthMetricsDto {
  final int? heartBpm;
  final int? spO2;
  final double? temperature;

  const HealthMetricsDto({this.heartBpm, this.spO2, this.temperature});
}

class HostMetricsDto {
  final int? uptimeSeconds;
  final int? freememBytes; // Using int for simplicity, check if BigInt needed
  final int? diskfree1Bytes;
  final int? diskfree2Bytes;
  final int? diskfree3Bytes;
  final int? load1;
  final int? load5;
  final int? load15;
  final String? userString;

  const HostMetricsDto({
    this.uptimeSeconds,
    this.freememBytes,
    this.diskfree1Bytes,
    this.diskfree2Bytes,
    this.diskfree3Bytes,
    this.load1,
    this.load5,
    this.load15,
    this.userString,
  });
}

class LocalStatsExtendedDto {
  // Add fields if needed, currently placeholder based on protobuf
  const LocalStatsExtendedDto();
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
class XModemDto {
  final String? control; // enum name
  final int? seq;
  final int? crc16;
  final Uint8List? buffer;
  const XModemDto({this.control, this.seq, this.crc16, this.buffer});
}

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
  final PowerConfigDto? power;
  final NetworkConfigDto? network;
  final DisplayConfigDto? display;
  final LoRaConfigDto? lora;
  final BluetoothConfigDto? bluetooth;
  final SecurityConfigDto? security;
  final SessionkeyConfigDto? sessionkey;

  const ConfigDto({
    this.device,
    this.position,
    this.power,
    this.network,
    this.display,
    this.lora,
    this.bluetooth,
    this.security,
    this.sessionkey,
  });

  ConfigDto copyWith(ConfigDto other) {
    return ConfigDto(
      device: other.device ?? device,
      position: other.position ?? position,
      power: other.power ?? power,
      network: other.network ?? network,
      display: other.display ?? display,
      lora: other.lora ?? lora,
      bluetooth: other.bluetooth ?? bluetooth,
      security: other.security ?? security,
      sessionkey: other.sessionkey ?? sessionkey,
    );
  }
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

  DeviceConfigDto copyWith({
    String? role,
    bool? serialEnabled,
    int? buttonGpio,
    int? buzzerGpio,
    String? rebroadcastMode,
    int? nodeInfoBroadcastSecs,
    bool? doubleTapAsButtonPress,
    bool? isManaged,
    bool? disableTripleClick,
    String? tzdef,
    bool? ledHeartbeatDisabled,
    String? buzzerMode,
  }) {
    return DeviceConfigDto(
      role: role ?? this.role,
      serialEnabled: serialEnabled ?? this.serialEnabled,
      buttonGpio: buttonGpio ?? this.buttonGpio,
      buzzerGpio: buzzerGpio ?? this.buzzerGpio,
      rebroadcastMode: rebroadcastMode ?? this.rebroadcastMode,
      nodeInfoBroadcastSecs:
          nodeInfoBroadcastSecs ?? this.nodeInfoBroadcastSecs,
      doubleTapAsButtonPress:
          doubleTapAsButtonPress ?? this.doubleTapAsButtonPress,
      isManaged: isManaged ?? this.isManaged,
      disableTripleClick: disableTripleClick ?? this.disableTripleClick,
      tzdef: tzdef ?? this.tzdef,
      ledHeartbeatDisabled: ledHeartbeatDisabled ?? this.ledHeartbeatDisabled,
      buzzerMode: buzzerMode ?? this.buzzerMode,
    );
  }
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

  PositionConfigDto copyWith({
    int? positionBroadcastSecs,
    bool? positionBroadcastSmartEnabled,
    bool? fixedPosition,
    bool? gpsEnabled,
    int? gpsUpdateInterval,
    int? gpsAttemptTime,
    int? positionFlags,
    int? rxGpio,
    int? txGpio,
    int? broadcastSmartMinimumDistance,
    int? broadcastSmartMinimumIntervalSecs,
    int? gpsEnGpio,
    String? gpsMode,
  }) {
    return PositionConfigDto(
      positionBroadcastSecs:
          positionBroadcastSecs ?? this.positionBroadcastSecs,
      positionBroadcastSmartEnabled:
          positionBroadcastSmartEnabled ?? this.positionBroadcastSmartEnabled,
      fixedPosition: fixedPosition ?? this.fixedPosition,
      gpsEnabled: gpsEnabled ?? this.gpsEnabled,
      gpsUpdateInterval: gpsUpdateInterval ?? this.gpsUpdateInterval,
      gpsAttemptTime: gpsAttemptTime ?? this.gpsAttemptTime,
      positionFlags: positionFlags ?? this.positionFlags,
      rxGpio: rxGpio ?? this.rxGpio,
      txGpio: txGpio ?? this.txGpio,
      broadcastSmartMinimumDistance:
          broadcastSmartMinimumDistance ?? this.broadcastSmartMinimumDistance,
      broadcastSmartMinimumIntervalSecs:
          broadcastSmartMinimumIntervalSecs ??
          this.broadcastSmartMinimumIntervalSecs,
      gpsEnGpio: gpsEnGpio ?? this.gpsEnGpio,
      gpsMode: gpsMode ?? this.gpsMode,
    );
  }
}

class PowerConfigDto {
  final bool? isPowerSaving;
  final int? onBatteryShutdownAfterSecs;
  final double? adcMultiplierOverride;
  final int? waitBluetoothSecs;
  final int? sdsSecs;
  final int? lsSecs;
  final int? minWakeSecs;
  final int? deviceBatteryInaAddress;
  final int? powermonEnables;

  const PowerConfigDto({
    this.isPowerSaving,
    this.onBatteryShutdownAfterSecs,
    this.adcMultiplierOverride,
    this.waitBluetoothSecs,
    this.sdsSecs,
    this.lsSecs,
    this.minWakeSecs,
    this.deviceBatteryInaAddress,
    this.powermonEnables,
  });

  PowerConfigDto copyWith({
    bool? isPowerSaving,
    int? onBatteryShutdownAfterSecs,
    double? adcMultiplierOverride,
    int? waitBluetoothSecs,
    int? sdsSecs,
    int? lsSecs,
    int? minWakeSecs,
    int? deviceBatteryInaAddress,
    int? powermonEnables,
  }) {
    return PowerConfigDto(
      isPowerSaving: isPowerSaving ?? this.isPowerSaving,
      onBatteryShutdownAfterSecs:
          onBatteryShutdownAfterSecs ?? this.onBatteryShutdownAfterSecs,
      adcMultiplierOverride:
          adcMultiplierOverride ?? this.adcMultiplierOverride,
      waitBluetoothSecs: waitBluetoothSecs ?? this.waitBluetoothSecs,
      sdsSecs: sdsSecs ?? this.sdsSecs,
      lsSecs: lsSecs ?? this.lsSecs,
      minWakeSecs: minWakeSecs ?? this.minWakeSecs,
      deviceBatteryInaAddress:
          deviceBatteryInaAddress ?? this.deviceBatteryInaAddress,
      powermonEnables: powermonEnables ?? this.powermonEnables,
    );
  }
}

class NetworkConfigDto {
  final bool? wifiEnabled;
  final String? wifiSsid;
  final String? wifiPsk;
  final String? ntpServer;
  final bool? ethEnabled;
  final String? addressMode; // enum name
  final IpV4ConfigDto? ipv4Config;
  final String? rsyslogServer;
  final int? enabledProtocols;
  final bool? ipv6Enabled;

  const NetworkConfigDto({
    this.wifiEnabled,
    this.wifiSsid,
    this.wifiPsk,
    this.ntpServer,
    this.ethEnabled,
    this.addressMode,
    this.ipv4Config,
    this.rsyslogServer,
    this.enabledProtocols,
    this.ipv6Enabled,
  });

  NetworkConfigDto copyWith({
    bool? wifiEnabled,
    String? wifiSsid,
    String? wifiPsk,
    String? ntpServer,
    bool? ethEnabled,
    String? addressMode,
    IpV4ConfigDto? ipv4Config,
    String? rsyslogServer,
    int? enabledProtocols,
    bool? ipv6Enabled,
  }) {
    return NetworkConfigDto(
      wifiEnabled: wifiEnabled ?? this.wifiEnabled,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPsk: wifiPsk ?? this.wifiPsk,
      ntpServer: ntpServer ?? this.ntpServer,
      ethEnabled: ethEnabled ?? this.ethEnabled,
      addressMode: addressMode ?? this.addressMode,
      ipv4Config: ipv4Config ?? this.ipv4Config,
      rsyslogServer: rsyslogServer ?? this.rsyslogServer,
      enabledProtocols: enabledProtocols ?? this.enabledProtocols,
      ipv6Enabled: ipv6Enabled ?? this.ipv6Enabled,
    );
  }
}

class IpV4ConfigDto {
  final int? ip;
  final int? gateway;
  final int? subnet;
  final int? dns;

  const IpV4ConfigDto({this.ip, this.gateway, this.subnet, this.dns});
}

class DisplayConfigDto {
  final int? screenOnSecs;
  final int? autoScreenCarouselSecs;
  final bool? compassNorthTop;
  final bool? flipScreen;
  final String? units; // enum name
  final String? oled; // enum name
  final String? displaymode; // enum name
  final bool? headingBold;
  final bool? wakeOnTapOrMotion;
  final String? compassOrientation; // enum name
  final bool? use12hClock;
  final bool? useLongNodeName;

  const DisplayConfigDto({
    this.screenOnSecs,
    this.autoScreenCarouselSecs,
    this.compassNorthTop,
    this.flipScreen,
    this.units,
    this.oled,
    this.displaymode,
    this.headingBold,
    this.wakeOnTapOrMotion,
    this.compassOrientation,
    this.use12hClock,
    this.useLongNodeName,
  });

  DisplayConfigDto copyWith({
    int? screenOnSecs,
    int? autoScreenCarouselSecs,
    bool? compassNorthTop,
    bool? flipScreen,
    String? units,
    String? oled,
    String? displaymode,
    bool? headingBold,
    bool? wakeOnTapOrMotion,
    String? compassOrientation,
    bool? use12hClock,
    bool? useLongNodeName,
  }) {
    return DisplayConfigDto(
      screenOnSecs: screenOnSecs ?? this.screenOnSecs,
      autoScreenCarouselSecs:
          autoScreenCarouselSecs ?? this.autoScreenCarouselSecs,
      compassNorthTop: compassNorthTop ?? this.compassNorthTop,
      flipScreen: flipScreen ?? this.flipScreen,
      units: units ?? this.units,
      oled: oled ?? this.oled,
      displaymode: displaymode ?? this.displaymode,
      headingBold: headingBold ?? this.headingBold,
      wakeOnTapOrMotion: wakeOnTapOrMotion ?? this.wakeOnTapOrMotion,
      compassOrientation: compassOrientation ?? this.compassOrientation,
      use12hClock: use12hClock ?? this.use12hClock,
      useLongNodeName: useLongNodeName ?? this.useLongNodeName,
    );
  }
}

class LoRaConfigDto {
  final bool? usePreset;
  final String? modemPreset; // enum name
  final int? bandwidth;
  final int? spreadFactor;
  final int? codingRate;
  final double? frequencyOffset;
  final String? region; // enum name
  final int? hopLimit;
  final bool? txEnabled;
  final int? txPower;
  final int? channelNum;
  final bool? overrideDutyCycle;
  final bool? sx126xRxBoostedGain;
  final double? overrideFrequency;
  final bool? paFanDisabled;
  final List<int>? ignoreIncoming;
  final bool? ignoreMqtt;
  final bool? configOkToMqtt;

  const LoRaConfigDto({
    this.usePreset,
    this.modemPreset,
    this.bandwidth,
    this.spreadFactor,
    this.codingRate,
    this.frequencyOffset,
    this.region,
    this.hopLimit,
    this.txEnabled,
    this.txPower,
    this.channelNum,
    this.overrideDutyCycle,
    this.sx126xRxBoostedGain,
    this.overrideFrequency,
    this.paFanDisabled,
    this.ignoreIncoming,
    this.ignoreMqtt,
    this.configOkToMqtt,
  });

  LoRaConfigDto copyWith({
    bool? usePreset,
    String? modemPreset,
    int? bandwidth,
    int? spreadFactor,
    int? codingRate,
    double? frequencyOffset,
    String? region,
    int? hopLimit,
    bool? txEnabled,
    int? txPower,
    int? channelNum,
    bool? overrideDutyCycle,
    bool? sx126xRxBoostedGain,
    double? overrideFrequency,
    bool? paFanDisabled,
    List<int>? ignoreIncoming,
    bool? ignoreMqtt,
    bool? configOkToMqtt,
  }) {
    return LoRaConfigDto(
      usePreset: usePreset ?? this.usePreset,
      modemPreset: modemPreset ?? this.modemPreset,
      bandwidth: bandwidth ?? this.bandwidth,
      spreadFactor: spreadFactor ?? this.spreadFactor,
      codingRate: codingRate ?? this.codingRate,
      frequencyOffset: frequencyOffset ?? this.frequencyOffset,
      region: region ?? this.region,
      hopLimit: hopLimit ?? this.hopLimit,
      txEnabled: txEnabled ?? this.txEnabled,
      txPower: txPower ?? this.txPower,
      channelNum: channelNum ?? this.channelNum,
      overrideDutyCycle: overrideDutyCycle ?? this.overrideDutyCycle,
      sx126xRxBoostedGain: sx126xRxBoostedGain ?? this.sx126xRxBoostedGain,
      overrideFrequency: overrideFrequency ?? this.overrideFrequency,
      paFanDisabled: paFanDisabled ?? this.paFanDisabled,
      ignoreIncoming: ignoreIncoming ?? this.ignoreIncoming,
      ignoreMqtt: ignoreMqtt ?? this.ignoreMqtt,
      configOkToMqtt: configOkToMqtt ?? this.configOkToMqtt,
    );
  }
}

class BluetoothConfigDto {
  final bool? enabled;
  final String? mode; // enum name
  final int? fixedPin;

  const BluetoothConfigDto({this.enabled, this.mode, this.fixedPin});

  BluetoothConfigDto copyWith({bool? enabled, String? mode, int? fixedPin}) {
    return BluetoothConfigDto(
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      fixedPin: fixedPin ?? this.fixedPin,
    );
  }
}

class SecurityConfigDto {
  final Uint8List? publicKey;
  final Uint8List? privateKey;
  final List<Uint8List>? adminKey;
  final bool? isManaged;
  final bool? serialEnabled;
  final bool? debugLogApiEnabled;
  final bool? adminChannelEnabled;

  const SecurityConfigDto({
    this.publicKey,
    this.privateKey,
    this.adminKey,
    this.isManaged,
    this.serialEnabled,
    this.debugLogApiEnabled,
    this.adminChannelEnabled,
  });

  SecurityConfigDto copyWith({
    Uint8List? publicKey,
    Uint8List? privateKey,
    List<Uint8List>? adminKey,
    bool? isManaged,
    bool? serialEnabled,
    bool? debugLogApiEnabled,
    bool? adminChannelEnabled,
  }) {
    return SecurityConfigDto(
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      adminKey: adminKey ?? this.adminKey,
      isManaged: isManaged ?? this.isManaged,
      serialEnabled: serialEnabled ?? this.serialEnabled,
      debugLogApiEnabled: debugLogApiEnabled ?? this.debugLogApiEnabled,
      adminChannelEnabled: adminChannelEnabled ?? this.adminChannelEnabled,
    );
  }
}

class SessionkeyConfigDto {
  const SessionkeyConfigDto();
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
  final NodeModConfigDto? nodeMod;
  final NodeModAdminConfigDto? nodeModAdmin;
  final IdleGameConfigDto? idleGame;
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
    this.nodeMod,
    this.nodeModAdmin,
    this.idleGame,
  });

  ModuleConfigDto copyWith(ModuleConfigDto other) {
    return ModuleConfigDto(
      mqtt: other.mqtt ?? mqtt,
      telemetry: other.telemetry ?? telemetry,
      serial: other.serial ?? serial,
      storeForward: other.storeForward ?? storeForward,
      rangeTest: other.rangeTest ?? rangeTest,
      externalNotification: other.externalNotification ?? externalNotification,
      audio: other.audio ?? audio,
      neighborInfo: other.neighborInfo ?? neighborInfo,
      remoteHardware: other.remoteHardware ?? remoteHardware,
      paxcounter: other.paxcounter ?? paxcounter,
      cannedMessage: other.cannedMessage ?? cannedMessage,
      ambientLighting: other.ambientLighting ?? ambientLighting,
      detectionSensor: other.detectionSensor ?? detectionSensor,
      dtnOverlay: other.dtnOverlay ?? dtnOverlay,
      broadcastAssist: other.broadcastAssist ?? broadcastAssist,
      nodeMod: other.nodeMod ?? nodeMod,
      nodeModAdmin: other.nodeModAdmin ?? nodeModAdmin,
      idleGame: other.idleGame ?? idleGame,
    );
  }
}

class NodeModConfigDto {
  final String? textStatus;
  final String? emoji;
  const NodeModConfigDto({this.textStatus, this.emoji});

  NodeModConfigDto copyWith({String? textStatus, String? emoji}) {
    return NodeModConfigDto(
      textStatus: textStatus ?? this.textStatus,
      emoji: emoji ?? this.emoji,
    );
  }
}

class NodeModAdminConfigDto {
  final bool? snifferEnabled;
  final bool? doNotSendPrvOverMqtt;
  final bool? localStatsOverMeshEnabled;
  final bool? localStatsExtendedOverMeshEnabled;
  final bool? idlegameEnabled;
  final int? additionalChutil;
  final double? additionalTxutil;
  final int? additionalPoliteChannelPercent;
  final int? additionalPoliteDutyCyclePercent;
  final double? currentTxUtilLimit;
  final int? currentMaxChannelUtilPercent;
  final int? currentPoliteChannelUtilPercent;
  final int? currentPoliteDutyCyclePercent;
  final bool? autoResponderEnabled;
  final String? autoResponderText;
  final bool? autoRedirectMessages;
  final int? autoRedirectTargetNodeId;
  final bool? telemetryLimiterEnabled;
  final int? telemetryLimiterPacketsPerMinute;
  final bool? telemetryLimiterAutoChanutilEnabled;
  final int? telemetryLimiterAutoChanutilThreshold;
  final bool? positionLimiterEnabled;
  final int? positionLimiterTimeMinutesThreshold;
  final bool? opportunisticFloodingEnabled;
  final int? opportunisticBaseDelayMs;
  final int? opportunisticHopDelayMs;
  final int? opportunisticSnrGainMs;
  final int? opportunisticJitterMs;
  final bool? opportunisticCancelOnFirstHear;
  final bool? opportunisticAuto;

  const NodeModAdminConfigDto({
    this.snifferEnabled,
    this.doNotSendPrvOverMqtt,
    this.localStatsOverMeshEnabled,
    this.localStatsExtendedOverMeshEnabled,
    this.idlegameEnabled,
    this.additionalChutil,
    this.additionalTxutil,
    this.additionalPoliteChannelPercent,
    this.additionalPoliteDutyCyclePercent,
    this.currentTxUtilLimit,
    this.currentMaxChannelUtilPercent,
    this.currentPoliteChannelUtilPercent,
    this.currentPoliteDutyCyclePercent,
    this.autoResponderEnabled,
    this.autoResponderText,
    this.autoRedirectMessages,
    this.autoRedirectTargetNodeId,
    this.telemetryLimiterEnabled,
    this.telemetryLimiterPacketsPerMinute,
    this.telemetryLimiterAutoChanutilEnabled,
    this.telemetryLimiterAutoChanutilThreshold,
    this.positionLimiterEnabled,
    this.positionLimiterTimeMinutesThreshold,
    this.opportunisticFloodingEnabled,
    this.opportunisticBaseDelayMs,
    this.opportunisticHopDelayMs,
    this.opportunisticSnrGainMs,
    this.opportunisticJitterMs,
    this.opportunisticCancelOnFirstHear,
    this.opportunisticAuto,
  });

  NodeModAdminConfigDto copyWith({
    bool? snifferEnabled,
    bool? doNotSendPrvOverMqtt,
    bool? localStatsOverMeshEnabled,
    bool? localStatsExtendedOverMeshEnabled,
    bool? idlegameEnabled,
    int? additionalChutil,
    double? additionalTxutil,
    int? additionalPoliteChannelPercent,
    int? additionalPoliteDutyCyclePercent,
    double? currentTxUtilLimit,
    int? currentMaxChannelUtilPercent,
    int? currentPoliteChannelUtilPercent,
    int? currentPoliteDutyCyclePercent,
    bool? autoResponderEnabled,
    String? autoResponderText,
    bool? autoRedirectMessages,
    int? autoRedirectTargetNodeId,
    bool? telemetryLimiterEnabled,
    int? telemetryLimiterPacketsPerMinute,
    bool? telemetryLimiterAutoChanutilEnabled,
    int? telemetryLimiterAutoChanutilThreshold,
    bool? positionLimiterEnabled,
    int? positionLimiterTimeMinutesThreshold,
    bool? opportunisticFloodingEnabled,
    int? opportunisticBaseDelayMs,
    int? opportunisticHopDelayMs,
    int? opportunisticSnrGainMs,
    int? opportunisticJitterMs,
    bool? opportunisticCancelOnFirstHear,
    bool? opportunisticAuto,
  }) {
    return NodeModAdminConfigDto(
      snifferEnabled: snifferEnabled ?? this.snifferEnabled,
      doNotSendPrvOverMqtt: doNotSendPrvOverMqtt ?? this.doNotSendPrvOverMqtt,
      localStatsOverMeshEnabled:
          localStatsOverMeshEnabled ?? this.localStatsOverMeshEnabled,
      localStatsExtendedOverMeshEnabled:
          localStatsExtendedOverMeshEnabled ??
          this.localStatsExtendedOverMeshEnabled,
      idlegameEnabled: idlegameEnabled ?? this.idlegameEnabled,
      additionalChutil: additionalChutil ?? this.additionalChutil,
      additionalTxutil: additionalTxutil ?? this.additionalTxutil,
      additionalPoliteChannelPercent:
          additionalPoliteChannelPercent ?? this.additionalPoliteChannelPercent,
      additionalPoliteDutyCyclePercent:
          additionalPoliteDutyCyclePercent ??
          this.additionalPoliteDutyCyclePercent,
      currentTxUtilLimit: currentTxUtilLimit ?? this.currentTxUtilLimit,
      currentMaxChannelUtilPercent:
          currentMaxChannelUtilPercent ?? this.currentMaxChannelUtilPercent,
      currentPoliteChannelUtilPercent:
          currentPoliteChannelUtilPercent ??
          this.currentPoliteChannelUtilPercent,
      currentPoliteDutyCyclePercent:
          currentPoliteDutyCyclePercent ?? this.currentPoliteDutyCyclePercent,
      autoResponderEnabled: autoResponderEnabled ?? this.autoResponderEnabled,
      autoResponderText: autoResponderText ?? this.autoResponderText,
      autoRedirectMessages: autoRedirectMessages ?? this.autoRedirectMessages,
      autoRedirectTargetNodeId:
          autoRedirectTargetNodeId ?? this.autoRedirectTargetNodeId,
      telemetryLimiterEnabled:
          telemetryLimiterEnabled ?? this.telemetryLimiterEnabled,
      telemetryLimiterPacketsPerMinute:
          telemetryLimiterPacketsPerMinute ??
          this.telemetryLimiterPacketsPerMinute,
      telemetryLimiterAutoChanutilEnabled:
          telemetryLimiterAutoChanutilEnabled ??
          this.telemetryLimiterAutoChanutilEnabled,
      telemetryLimiterAutoChanutilThreshold:
          telemetryLimiterAutoChanutilThreshold ??
          this.telemetryLimiterAutoChanutilThreshold,
      positionLimiterEnabled:
          positionLimiterEnabled ?? this.positionLimiterEnabled,
      positionLimiterTimeMinutesThreshold:
          positionLimiterTimeMinutesThreshold ??
          this.positionLimiterTimeMinutesThreshold,
      opportunisticFloodingEnabled:
          opportunisticFloodingEnabled ?? this.opportunisticFloodingEnabled,
      opportunisticBaseDelayMs:
          opportunisticBaseDelayMs ?? this.opportunisticBaseDelayMs,
      opportunisticHopDelayMs:
          opportunisticHopDelayMs ?? this.opportunisticHopDelayMs,
      opportunisticSnrGainMs:
          opportunisticSnrGainMs ?? this.opportunisticSnrGainMs,
      opportunisticJitterMs:
          opportunisticJitterMs ?? this.opportunisticJitterMs,
      opportunisticCancelOnFirstHear:
          opportunisticCancelOnFirstHear ?? this.opportunisticCancelOnFirstHear,
      opportunisticAuto: opportunisticAuto ?? this.opportunisticAuto,
    );
  }
}

class IdleGameConfigDto {
  final String? variant; // oneof name
  const IdleGameConfigDto({this.variant});

  IdleGameConfigDto copyWith({String? variant}) {
    return IdleGameConfigDto(variant: variant ?? this.variant);
  }
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

  MqttConfigDto copyWith({
    bool? enabled,
    String? address,
    String? username,
    String? password,
    bool? encryptionEnabled,
    bool? jsonEnabled,
    bool? tlsEnabled,
    String? root,
    bool? proxyToClientEnabled,
    bool? mapReportingEnabled,
    MapReportSettingsDto? mapReportSettings,
  }) {
    return MqttConfigDto(
      enabled: enabled ?? this.enabled,
      address: address ?? this.address,
      username: username ?? this.username,
      password: password ?? this.password,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      jsonEnabled: jsonEnabled ?? this.jsonEnabled,
      tlsEnabled: tlsEnabled ?? this.tlsEnabled,
      root: root ?? this.root,
      proxyToClientEnabled: proxyToClientEnabled ?? this.proxyToClientEnabled,
      mapReportingEnabled: mapReportingEnabled ?? this.mapReportingEnabled,
      mapReportSettings: mapReportSettings ?? this.mapReportSettings,
    );
  }
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

  TelemetryConfigDto copyWith({
    int? deviceUpdateInterval,
    int? environmentUpdateInterval,
    bool? environmentMeasurementEnabled,
    bool? environmentScreenEnabled,
    bool? environmentDisplayFahrenheit,
    bool? airQualityEnabled,
    int? airQualityInterval,
    bool? powerMeasurementEnabled,
    int? powerUpdateInterval,
    bool? powerScreenEnabled,
    bool? healthMeasurementEnabled,
    int? healthUpdateInterval,
    bool? healthScreenEnabled,
    bool? deviceTelemetryEnabled,
  }) {
    return TelemetryConfigDto(
      deviceUpdateInterval: deviceUpdateInterval ?? this.deviceUpdateInterval,
      environmentUpdateInterval:
          environmentUpdateInterval ?? this.environmentUpdateInterval,
      environmentMeasurementEnabled:
          environmentMeasurementEnabled ?? this.environmentMeasurementEnabled,
      environmentScreenEnabled:
          environmentScreenEnabled ?? this.environmentScreenEnabled,
      environmentDisplayFahrenheit:
          environmentDisplayFahrenheit ?? this.environmentDisplayFahrenheit,
      airQualityEnabled: airQualityEnabled ?? this.airQualityEnabled,
      airQualityInterval: airQualityInterval ?? this.airQualityInterval,
      powerMeasurementEnabled:
          powerMeasurementEnabled ?? this.powerMeasurementEnabled,
      powerUpdateInterval: powerUpdateInterval ?? this.powerUpdateInterval,
      powerScreenEnabled: powerScreenEnabled ?? this.powerScreenEnabled,
      healthMeasurementEnabled:
          healthMeasurementEnabled ?? this.healthMeasurementEnabled,
      healthUpdateInterval: healthUpdateInterval ?? this.healthUpdateInterval,
      healthScreenEnabled: healthScreenEnabled ?? this.healthScreenEnabled,
      deviceTelemetryEnabled:
          deviceTelemetryEnabled ?? this.deviceTelemetryEnabled,
    );
  }
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

  SerialConfigDto copyWith({
    bool? enabled,
    bool? echo,
    int? rxd,
    int? txd,
    String? baud,
    int? timeout,
    String? mode,
    bool? overrideConsoleSerialPort,
  }) {
    return SerialConfigDto(
      enabled: enabled ?? this.enabled,
      echo: echo ?? this.echo,
      rxd: rxd ?? this.rxd,
      txd: txd ?? this.txd,
      baud: baud ?? this.baud,
      timeout: timeout ?? this.timeout,
      mode: mode ?? this.mode,
      overrideConsoleSerialPort:
          overrideConsoleSerialPort ?? this.overrideConsoleSerialPort,
    );
  }
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

  StoreForwardConfigDto copyWith({
    bool? enabled,
    bool? heartbeat,
    int? records,
    int? historyReturnMax,
    int? historyReturnWindow,
    bool? isServer,
    bool? emitControlSignals,
  }) {
    return StoreForwardConfigDto(
      enabled: enabled ?? this.enabled,
      heartbeat: heartbeat ?? this.heartbeat,
      records: records ?? this.records,
      historyReturnMax: historyReturnMax ?? this.historyReturnMax,
      historyReturnWindow: historyReturnWindow ?? this.historyReturnWindow,
      isServer: isServer ?? this.isServer,
      emitControlSignals: emitControlSignals ?? this.emitControlSignals,
    );
  }
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

  RangeTestConfigDto copyWith({
    bool? enabled,
    int? sender,
    bool? save,
    bool? clearOnReboot,
  }) {
    return RangeTestConfigDto(
      enabled: enabled ?? this.enabled,
      sender: sender ?? this.sender,
      save: save ?? this.save,
      clearOnReboot: clearOnReboot ?? this.clearOnReboot,
    );
  }
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

  ExternalNotificationConfigDto copyWith({
    bool? enabled,
    int? outputMs,
    int? output,
    bool? active,
    bool? alertMessage,
    bool? alertBell,
    bool? usePwm,
    int? outputVibra,
    int? outputBuzzer,
    bool? alertMessageVibra,
    bool? alertMessageBuzzer,
    bool? alertBellVibra,
    bool? alertBellBuzzer,
    int? nagTimeout,
    bool? useI2sAsBuzzer,
  }) {
    return ExternalNotificationConfigDto(
      enabled: enabled ?? this.enabled,
      outputMs: outputMs ?? this.outputMs,
      output: output ?? this.output,
      active: active ?? this.active,
      alertMessage: alertMessage ?? this.alertMessage,
      alertBell: alertBell ?? this.alertBell,
      usePwm: usePwm ?? this.usePwm,
      outputVibra: outputVibra ?? this.outputVibra,
      outputBuzzer: outputBuzzer ?? this.outputBuzzer,
      alertMessageVibra: alertMessageVibra ?? this.alertMessageVibra,
      alertMessageBuzzer: alertMessageBuzzer ?? this.alertMessageBuzzer,
      alertBellVibra: alertBellVibra ?? this.alertBellVibra,
      alertBellBuzzer: alertBellBuzzer ?? this.alertBellBuzzer,
      nagTimeout: nagTimeout ?? this.nagTimeout,
      useI2sAsBuzzer: useI2sAsBuzzer ?? this.useI2sAsBuzzer,
    );
  }
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

  AudioConfigDto copyWith({
    bool? codec2Enabled,
    int? pttPin,
    String? bitrate,
    int? i2sWs,
    int? i2sSd,
    int? i2sDin,
    int? i2sSck,
  }) {
    return AudioConfigDto(
      codec2Enabled: codec2Enabled ?? this.codec2Enabled,
      pttPin: pttPin ?? this.pttPin,
      bitrate: bitrate ?? this.bitrate,
      i2sWs: i2sWs ?? this.i2sWs,
      i2sSd: i2sSd ?? this.i2sSd,
      i2sDin: i2sDin ?? this.i2sDin,
      i2sSck: i2sSck ?? this.i2sSck,
    );
  }
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

  NeighborInfoConfigDto copyWith({
    bool? enabled,
    int? updateInterval,
    bool? transmitOverLora,
  }) {
    return NeighborInfoConfigDto(
      enabled: enabled ?? this.enabled,
      updateInterval: updateInterval ?? this.updateInterval,
      transmitOverLora: transmitOverLora ?? this.transmitOverLora,
    );
  }
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

  RemoteHardwareConfigDto copyWith({
    bool? enabled,
    bool? allowUndefinedPinAccess,
    List<RemoteHardwarePinDto>? availablePins,
  }) {
    return RemoteHardwareConfigDto(
      enabled: enabled ?? this.enabled,
      allowUndefinedPinAccess:
          allowUndefinedPinAccess ?? this.allowUndefinedPinAccess,
      availablePins: availablePins ?? this.availablePins,
    );
  }
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

  PaxcounterConfigDto copyWith({
    bool? enabled,
    int? paxcounterUpdateInterval,
    int? wifiThreshold,
    int? bleThreshold,
  }) {
    return PaxcounterConfigDto(
      enabled: enabled ?? this.enabled,
      paxcounterUpdateInterval:
          paxcounterUpdateInterval ?? this.paxcounterUpdateInterval,
      wifiThreshold: wifiThreshold ?? this.wifiThreshold,
      bleThreshold: bleThreshold ?? this.bleThreshold,
    );
  }
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

  CannedMessageConfigDto copyWith({
    bool? rotary1Enabled,
    int? inputbrokerPinA,
    int? inputbrokerPinB,
    int? inputbrokerPinPress,
    String? inputbrokerEventCw,
    String? inputbrokerEventCcw,
    String? inputbrokerEventPress,
    bool? updown1Enabled,
    bool? enabled,
    String? allowInputSource,
    bool? sendBell,
  }) {
    return CannedMessageConfigDto(
      rotary1Enabled: rotary1Enabled ?? this.rotary1Enabled,
      inputbrokerPinA: inputbrokerPinA ?? this.inputbrokerPinA,
      inputbrokerPinB: inputbrokerPinB ?? this.inputbrokerPinB,
      inputbrokerPinPress: inputbrokerPinPress ?? this.inputbrokerPinPress,
      inputbrokerEventCw: inputbrokerEventCw ?? this.inputbrokerEventCw,
      inputbrokerEventCcw: inputbrokerEventCcw ?? this.inputbrokerEventCcw,
      inputbrokerEventPress:
          inputbrokerEventPress ?? this.inputbrokerEventPress,
      updown1Enabled: updown1Enabled ?? this.updown1Enabled,
      enabled: enabled ?? this.enabled,
      allowInputSource: allowInputSource ?? this.allowInputSource,
      sendBell: sendBell ?? this.sendBell,
    );
  }
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

  AmbientLightingConfigDto copyWith({
    bool? ledState,
    int? current,
    int? red,
    int? green,
    int? blue,
  }) {
    return AmbientLightingConfigDto(
      ledState: ledState ?? this.ledState,
      current: current ?? this.current,
      red: red ?? this.red,
      green: green ?? this.green,
      blue: blue ?? this.blue,
    );
  }
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

  DetectionSensorConfigDto copyWith({
    bool? enabled,
    int? minimumBroadcastSecs,
    int? stateBroadcastSecs,
    bool? sendBell,
    String? name,
    int? monitorPin,
    String? detectionTriggerType,
    bool? usePullup,
  }) {
    return DetectionSensorConfigDto(
      enabled: enabled ?? this.enabled,
      minimumBroadcastSecs: minimumBroadcastSecs ?? this.minimumBroadcastSecs,
      stateBroadcastSecs: stateBroadcastSecs ?? this.stateBroadcastSecs,
      sendBell: sendBell ?? this.sendBell,
      name: name ?? this.name,
      monitorPin: monitorPin ?? this.monitorPin,
      detectionTriggerType: detectionTriggerType ?? this.detectionTriggerType,
      usePullup: usePullup ?? this.usePullup,
    );
  }
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

  DtnOverlayConfigDto copyWith({
    bool? enabled,
    int? ttlMinutes,
    int? initialDelayBaseMs,
    int? retryBackoffMs,
    int? maxTries,
    bool? lateFallbackEnabled,
    int? fallbackTailPercent,
    bool? milestonesEnabled,
    int? perDestMinSpacingMs,
    int? maxActiveDm,
    bool? probeFwplusNearDeadline,
  }) {
    return DtnOverlayConfigDto(
      enabled: enabled ?? this.enabled,
      ttlMinutes: ttlMinutes ?? this.ttlMinutes,
      initialDelayBaseMs: initialDelayBaseMs ?? this.initialDelayBaseMs,
      retryBackoffMs: retryBackoffMs ?? this.retryBackoffMs,
      maxTries: maxTries ?? this.maxTries,
      lateFallbackEnabled: lateFallbackEnabled ?? this.lateFallbackEnabled,
      fallbackTailPercent: fallbackTailPercent ?? this.fallbackTailPercent,
      milestonesEnabled: milestonesEnabled ?? this.milestonesEnabled,
      perDestMinSpacingMs: perDestMinSpacingMs ?? this.perDestMinSpacingMs,
      maxActiveDm: maxActiveDm ?? this.maxActiveDm,
      probeFwplusNearDeadline:
          probeFwplusNearDeadline ?? this.probeFwplusNearDeadline,
    );
  }
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

  BroadcastAssistConfigDto copyWith({
    bool? enabled,
    int? degreeThreshold,
    int? dupThreshold,
    int? windowMs,
    int? maxExtraHops,
    int? jitterMs,
    bool? airtimeGuard,
    List<int>? allowedPorts,
  }) {
    return BroadcastAssistConfigDto(
      enabled: enabled ?? this.enabled,
      degreeThreshold: degreeThreshold ?? this.degreeThreshold,
      dupThreshold: dupThreshold ?? this.dupThreshold,
      windowMs: windowMs ?? this.windowMs,
      maxExtraHops: maxExtraHops ?? this.maxExtraHops,
      jitterMs: jitterMs ?? this.jitterMs,
      airtimeGuard: airtimeGuard ?? this.airtimeGuard,
      allowedPorts: allowedPorts ?? this.allowedPorts,
    );
  }
}

class ChannelDto {
  final int? index;
  final String? role; // enum name
  final ChannelSettingsDto? settings;

  const ChannelDto({this.index, this.role, this.settings});

  ChannelDto copyWith({
    int? index,
    String? role,
    ChannelSettingsDto? settings,
  }) {
    return ChannelDto(
      index: index ?? this.index,
      role: role ?? this.role,
      settings: settings ?? this.settings,
    );
  }
}

class ChannelSettingsDto {
  final int? channelNum;
  final Uint8List? psk;
  final String? name;
  final int? id;
  final bool? uplinkEnabled;
  final bool? downlinkEnabled;
  final ModuleSettingsDto? moduleSettings;

  const ChannelSettingsDto({
    this.channelNum,
    this.psk,
    this.name,
    this.id,
    this.uplinkEnabled,
    this.downlinkEnabled,
    this.moduleSettings,
  });

  ChannelSettingsDto copyWith({
    int? channelNum,
    Uint8List? psk,
    String? name,
    int? id,
    bool? uplinkEnabled,
    bool? downlinkEnabled,
    ModuleSettingsDto? moduleSettings,
  }) {
    return ChannelSettingsDto(
      channelNum: channelNum ?? this.channelNum,
      psk: psk ?? this.psk,
      name: name ?? this.name,
      id: id ?? this.id,
      uplinkEnabled: uplinkEnabled ?? this.uplinkEnabled,
      downlinkEnabled: downlinkEnabled ?? this.downlinkEnabled,
      moduleSettings: moduleSettings ?? this.moduleSettings,
    );
  }
}

class ModuleSettingsDto {
  final int? positionPrecision;

  const ModuleSettingsDto({this.positionPrecision});

  ModuleSettingsDto copyWith({int? positionPrecision}) {
    return ModuleSettingsDto(
      positionPrecision: positionPrecision ?? this.positionPrecision,
    );
  }
}

class QueueStatusDto {
  final int? res; // ErrorCode
  final int? free;
  final int? maxlen;
  final int? meshPacketId;
  const QueueStatusDto({this.res, this.free, this.maxlen, this.meshPacketId});
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
  final int? replyId;
  final int? time;
  final String? level; // enum name
  final String? message;
  final String? payloadVariant;
  // We can add specific payload fields later if needed (KeyVerification etc.)
  const ClientNotificationDto({
    this.replyId,
    this.time,
    this.level,
    this.message,
    this.payloadVariant,
  });
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

  DeviceUiConfigDto copyWith({
    int? version,
    int? screenBrightness,
    int? screenTimeout,
    bool? screenLock,
    bool? settingsLock,
    int? pinCode,
    String? theme,
    bool? alertEnabled,
    bool? bannerEnabled,
    int? ringToneId,
    String? language,
    DeviceUiNodeFilterDto? nodeFilter,
    DeviceUiNodeHighlightDto? nodeHighlight,
    Uint8List? calibrationData,
    DeviceUiMapDto? mapData,
    String? compassMode,
    int? screenRgbColor,
    bool? isClockfaceAnalog,
    String? gpsFormat,
  }) {
    return DeviceUiConfigDto(
      version: version ?? this.version,
      screenBrightness: screenBrightness ?? this.screenBrightness,
      screenTimeout: screenTimeout ?? this.screenTimeout,
      screenLock: screenLock ?? this.screenLock,
      settingsLock: settingsLock ?? this.settingsLock,
      pinCode: pinCode ?? this.pinCode,
      theme: theme ?? this.theme,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      bannerEnabled: bannerEnabled ?? this.bannerEnabled,
      ringToneId: ringToneId ?? this.ringToneId,
      language: language ?? this.language,
      nodeFilter: nodeFilter ?? this.nodeFilter,
      nodeHighlight: nodeHighlight ?? this.nodeHighlight,
      calibrationData: calibrationData ?? this.calibrationData,
      mapData: mapData ?? this.mapData,
      compassMode: compassMode ?? this.compassMode,
      screenRgbColor: screenRgbColor ?? this.screenRgbColor,
      isClockfaceAnalog: isClockfaceAnalog ?? this.isClockfaceAnalog,
      gpsFormat: gpsFormat ?? this.gpsFormat,
    );
  }
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

  const DeviceUiNodeHighlightDto({this.highlightEnabled, this.minSnr});
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
