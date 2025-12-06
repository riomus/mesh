import 'package:equatable/equatable.dart';
import '../../meshtastic/model/meshtastic_models.dart';
import '../../services/device_communication_event_service.dart'
    as service_event;
import '../../models/device_state.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class DeviceEventReceived extends DeviceEvent {
  final service_event.DeviceEvent event;

  const DeviceEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}

class DeviceConfigUpdated extends DeviceEvent {
  final String deviceId;
  final ConfigDto config;

  const DeviceConfigUpdated(this.deviceId, this.config);

  @override
  List<Object?> get props => [deviceId, config];
}

class DeviceModuleConfigUpdated extends DeviceEvent {
  final String deviceId;
  final ModuleConfigDto moduleConfig;

  const DeviceModuleConfigUpdated(this.deviceId, this.moduleConfig);

  @override
  List<Object?> get props => [deviceId, moduleConfig];
}

class DeviceChannelUpdated extends DeviceEvent {
  final String deviceId;
  final ChannelDto channel;

  const DeviceChannelUpdated(this.deviceId, this.channel);

  @override
  List<Object?> get props => [deviceId, channel];
}

class DeviceNodeInfoUpdated extends DeviceEvent {
  final String deviceId;
  final NodeInfoDto nodeInfo;

  const DeviceNodeInfoUpdated(this.deviceId, this.nodeInfo);

  @override
  List<Object?> get props => [deviceId, nodeInfo];
}

class DeviceMyInfoUpdated extends DeviceEvent {
  final String deviceId;
  final MyInfoDto myInfo;

  const DeviceMyInfoUpdated(this.deviceId, this.myInfo);

  @override
  List<Object?> get props => [deviceId, myInfo];
}

class DeviceMetadataUpdated extends DeviceEvent {
  final String deviceId;
  final DeviceMetadataDto metadata;

  const DeviceMetadataUpdated(this.deviceId, this.metadata);

  @override
  List<Object?> get props => [deviceId, metadata];
}

class DeviceStateUpdated extends DeviceEvent {
  final DeviceState state;

  const DeviceStateUpdated(this.state);

  @override
  List<Object?> get props => [state];
}
