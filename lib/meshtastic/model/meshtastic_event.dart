import 'meshtastic_models.dart';

/// High-level, ergonomic representation of Meshtastic data coming from the radio.
///
/// These events wrap protobuf-generated classes and expose commonly-needed
/// information in a Dart-friendly way for app/UI consumption.
sealed class MeshtasticEvent {
  /// The packet ID from the FromRadio wrapper.
  final int? id;
  const MeshtasticEvent({this.id});
}

/// Event emitted whenever the radio sends a MeshPacket (application payload).
class MeshPacketEvent extends MeshtasticEvent {
  final MeshPacketDto packet;
  final DecodedPayloadDto? decoded;

  const MeshPacketEvent({
    required this.packet,
    required this.decoded,
    super.id,
  });
}

/// Event for MyNodeInfo updates.
class MyInfoEvent extends MeshtasticEvent {
  final MyInfoDto myInfo;
  const MyInfoEvent(this.myInfo, {super.id});
}

/// Event for NodeInfo announcements.
class NodeInfoEvent extends MeshtasticEvent {
  final NodeInfoDto nodeInfo;
  const NodeInfoEvent(this.nodeInfo, {super.id});
}

/// Event when full/partial config is received.
class ConfigEvent extends MeshtasticEvent {
  final ConfigDto config;
  const ConfigEvent(this.config, {super.id});
}

/// Event when the device indicates configuration stream completed for an id.
class ConfigCompleteEvent extends MeshtasticEvent {
  final int configCompleteId;
  const ConfigCompleteEvent(this.configCompleteId, {super.id});
}

/// Device reboot notification.
class RebootedEvent extends MeshtasticEvent {
  final bool rebooted;
  const RebootedEvent(this.rebooted, {super.id});
}

/// ModuleConfig update.
class ModuleConfigEvent extends MeshtasticEvent {
  final ModuleConfigDto moduleConfig;
  const ModuleConfigEvent(this.moduleConfig, {super.id});
}

/// Channel update event.
class ChannelEvent extends MeshtasticEvent {
  final ChannelDto channel;
  const ChannelEvent(this.channel, {super.id});
}

/// Queue status update.
class QueueStatusEvent extends MeshtasticEvent {
  final QueueStatusDto status;
  const QueueStatusEvent(this.status, {super.id});
}

/// Device metadata received.
class DeviceMetadataEvent extends MeshtasticEvent {
  final DeviceMetadataDto metadata;
  const DeviceMetadataEvent(this.metadata, {super.id});
}

/// MQTT client proxy message event (rare in BLE, but included for completeness).
class MqttClientProxyEvent extends MeshtasticEvent {
  final MqttClientProxyMessageDto message;
  const MqttClientProxyEvent(this.message, {super.id});
}

/// File transfer info.
class FileInfoEvent extends MeshtasticEvent {
  final FileInfoDto fileInfo;
  const FileInfoEvent(this.fileInfo, {super.id});
}

/// Client notification from device.
class ClientNotificationEvent extends MeshtasticEvent {
  final ClientNotificationDto notification;
  const ClientNotificationEvent(this.notification, {super.id});
}

/// Device UI config update.
class DeviceUiConfigEvent extends MeshtasticEvent {
  final DeviceUiConfigDto uiConfig;
  const DeviceUiConfigEvent(this.uiConfig, {super.id});
}

/// Log record emitted by device.
class LogRecordEvent extends MeshtasticEvent {
  final LogRecordDto logRecord;
  const LogRecordEvent(this.logRecord, {super.id});
}

/// XModem packet event.
class XModemEvent extends MeshtasticEvent {
  final XModemDto xmodem;
  const XModemEvent(this.xmodem, {super.id});
}
