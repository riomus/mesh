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
  const ConfigDto();
}

class ModuleConfigDto {
  const ModuleConfigDto();
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
  const DeviceMetadataDto({this.myNodeNum});
}

class MqttClientProxyMessageDto {
  const MqttClientProxyMessageDto();
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
  const DeviceUiConfigDto();
}

class LogRecordDto {
  final String? level;
  final String? message;
  final String? source;
  const LogRecordDto({this.level, this.message, this.source});
}
