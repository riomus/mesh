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

class PositionPayloadDto extends DecodedPayloadDto {
  final int? latitudeI; // 1e-7 degrees
  final int? longitudeI; // 1e-7 degrees
  const PositionPayloadDto({this.latitudeI, this.longitudeI});
}

class UserDto {
  final String? longName;
  final String? shortName;
  const UserDto({this.longName, this.shortName});
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
  const MyInfoDto({this.myNodeNum});
}

class NodeInfoDto {
  final NodeNum? num;
  final UserDto? user;
  const NodeInfoDto({this.num, this.user});
}

class ConfigDto {
  // Raw JSON (proto3) of meshtastic.Config
  final Map<String, dynamic>? rawProto;
  // Raw serialized bytes
  final Uint8List? rawBytes;
  const ConfigDto({this.rawProto, this.rawBytes});
}

class ModuleConfigDto {
  // Raw JSON (proto3) of meshtastic.ModuleConfig, containing all module settings.
  final Map<String, dynamic>? rawProto;
  // Raw serialized bytes
  final Uint8List? rawBytes;
  const ModuleConfigDto({this.rawProto, this.rawBytes});
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
