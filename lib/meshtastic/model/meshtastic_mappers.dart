
import 'dart:convert';
import 'dart:typed_data';

import '../../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../../generated/meshtastic/meshtastic/portnums.pbenum.dart' as port;
import '../../generated/meshtastic/meshtastic/admin.pb.dart' as admin;
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
        return MyInfoEvent(MyInfoDto(
          myNodeNum: fr.myInfo.hasMyNodeNum() ? fr.myInfo.myNodeNum : null,
        ));
      case mesh.FromRadio_PayloadVariant.nodeInfo:
        return NodeInfoEvent(NodeInfoDto(
          num: fr.nodeInfo.hasNum() ? fr.nodeInfo.num : null,
          user: fr.nodeInfo.hasUser()
              ? UserDto(
                  longName:
                      fr.nodeInfo.user.hasLongName() ? fr.nodeInfo.user.longName : null,
                  shortName:
                      fr.nodeInfo.user.hasShortName() ? fr.nodeInfo.user.shortName : null,
                )
              : null,
        ));
      case mesh.FromRadio_PayloadVariant.config:
        return ConfigEvent(ConfigDto(
          rawBytes: Uint8List.fromList(fr.config.writeToBuffer()),
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
        return ModuleConfigEvent(ModuleConfigDto(
          rawBytes: Uint8List.fromList(fr.moduleConfig.writeToBuffer()),
        ));
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
        ));
      case mesh.FromRadio_PayloadVariant.mqttClientProxyMessage:
        return MqttClientProxyEvent(MqttClientProxyMessageDto(
          rawBytes: Uint8List.fromList(fr.mqttClientProxyMessage.writeToBuffer()),
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
          return PositionPayloadDto(
            latitudeI: pos.hasLatitudeI() ? pos.latitudeI : null,
            longitudeI: pos.hasLongitudeI() ? pos.longitudeI : null,
          );
        } catch (_) {
          return RawPayloadDto(portInternal, bytes);
        }
      case port.PortNum.NODEINFO_APP:
        try {
          final user = mesh.User.fromBuffer(bytes);
          return UserPayloadDto(UserDto(
            longName: user.hasLongName() ? user.longName : null,
            shortName: user.hasShortName() ? user.shortName : null,
          ));
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
