import '../meshtastic/model/meshtastic_models.dart';

/// Aggregated state of a Meshtastic device using DTOs.
class DeviceState {
  final String deviceId;
  final ConfigDto? config;
  final ModuleConfigDto? moduleConfig;
  final List<ChannelDto> channels;
  final List<NodeInfoDto> nodes;
  final MyInfoDto? myNodeInfo;
  final DeviceMetadataDto? metadata;

  const DeviceState({
    required this.deviceId,
    this.config,
    this.moduleConfig,
    this.channels = const [],
    this.nodes = const [],
    this.myNodeInfo,
    this.metadata,
  });

  DeviceState copyWith({
    ConfigDto? config,
    ModuleConfigDto? moduleConfig,
    List<ChannelDto>? channels,
    List<NodeInfoDto>? nodes,
    MyInfoDto? myNodeInfo,
    DeviceMetadataDto? metadata,
  }) {
    return DeviceState(
      deviceId: deviceId,
      config: config ?? this.config,
      moduleConfig: moduleConfig ?? this.moduleConfig,
      channels: channels ?? this.channels,
      nodes: nodes ?? this.nodes,
      myNodeInfo: myNodeInfo ?? this.myNodeInfo,
      metadata: metadata ?? this.metadata,
    );
  }
}
