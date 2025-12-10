import 'dart:typed_data';

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
  final DeviceUiConfigDto? deviceUiConfig;
  final Uint8List? sessionPasskey;

  const DeviceState({
    required this.deviceId,
    this.myNodeInfo,
    this.nodes = const [],
    this.channels = const [],
    this.config,
    this.moduleConfig,
    this.metadata,
    this.deviceUiConfig,
    this.sessionPasskey,
  });

  DeviceState copyWith({
    String? deviceId,
    MyInfoDto? myNodeInfo,
    List<NodeInfoDto>? nodes,
    List<ChannelDto>? channels,
    ConfigDto? config,
    ModuleConfigDto? moduleConfig,
    DeviceMetadataDto? metadata,
    DeviceUiConfigDto? deviceUiConfig,
    Uint8List? sessionPasskey,
  }) {
    return DeviceState(
      deviceId: deviceId ?? this.deviceId,
      myNodeInfo: myNodeInfo ?? this.myNodeInfo,
      nodes: nodes ?? this.nodes,
      channels: channels ?? this.channels,
      config: config ?? this.config,
      moduleConfig: moduleConfig ?? this.moduleConfig,
      metadata: metadata ?? this.metadata,
      deviceUiConfig: deviceUiConfig ?? this.deviceUiConfig,
      sessionPasskey: sessionPasskey ?? this.sessionPasskey,
    );
  }
}
