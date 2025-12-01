import 'meshtastic_models.dart';

/// High-level, ergonomic representation of Meshtastic data coming from the radio.
///
/// These events wrap protobuf-generated classes and expose commonly-needed
/// information in a Dart-friendly way for app/UI consumption.
sealed class MeshtasticEvent {
  const MeshtasticEvent();
}

/// Event emitted whenever the radio sends a MeshPacket (application payload).
class MeshPacketEvent extends MeshtasticEvent {
  final MeshPacketDto packet;
  final DecodedPayloadDto? decoded;

  const MeshPacketEvent({required this.packet, required this.decoded});
}

/// Event for MyNodeInfo updates.
class MyInfoEvent extends MeshtasticEvent {
  final MyInfoDto myInfo;
  const MyInfoEvent(this.myInfo);
}

/// Event for NodeInfo announcements.
class NodeInfoEvent extends MeshtasticEvent {
  final NodeInfoDto nodeInfo;
  const NodeInfoEvent(this.nodeInfo);
}

/// Event when full/partial config is received.
class ConfigEvent extends MeshtasticEvent {
  final ConfigDto config;
  const ConfigEvent(this.config);
}

/// Event when the device indicates configuration stream completed for an id.
class ConfigCompleteEvent extends MeshtasticEvent {
  final int configCompleteId;
  const ConfigCompleteEvent(this.configCompleteId);
}

/// Device reboot notification.
class RebootedEvent extends MeshtasticEvent {
  final bool rebooted;
  const RebootedEvent(this.rebooted);
}

/// ModuleConfig update.
class ModuleConfigEvent extends MeshtasticEvent {
  final ModuleConfigDto moduleConfig;
  const ModuleConfigEvent(this.moduleConfig);
}

/// Channel update event.
class ChannelEvent extends MeshtasticEvent {
  final ChannelDto channel;
  const ChannelEvent(this.channel);
}

/// Queue status update.
class QueueStatusEvent extends MeshtasticEvent {
  final QueueStatusDto status;
  const QueueStatusEvent(this.status);
}

/// Device metadata received.
class DeviceMetadataEvent extends MeshtasticEvent {
  final DeviceMetadataDto metadata;
  const DeviceMetadataEvent(this.metadata);
}

/// MQTT client proxy message event (rare in BLE, but included for completeness).
class MqttClientProxyEvent extends MeshtasticEvent {
  final MqttClientProxyMessageDto message;
  const MqttClientProxyEvent(this.message);
}

/// File transfer info.
class FileInfoEvent extends MeshtasticEvent {
  final FileInfoDto fileInfo;
  const FileInfoEvent(this.fileInfo);
}

/// Client notification from device.
class ClientNotificationEvent extends MeshtasticEvent {
  final ClientNotificationDto notification;
  const ClientNotificationEvent(this.notification);
}

/// Device UI config update.
class DeviceUiConfigEvent extends MeshtasticEvent {
  final DeviceUiConfigDto uiConfig;
  const DeviceUiConfigEvent(this.uiConfig);
}

/// Log record emitted by device.
class LogRecordEvent extends MeshtasticEvent {
  final LogRecordDto logRecord;
  const LogRecordEvent(this.logRecord);
}
