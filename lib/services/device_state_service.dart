import 'dart:async';

import '../models/device_state.dart';
import 'device_communication_event_service.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../meshtastic/model/meshtastic_event.dart';
import 'logging_service.dart';

/// Service that listens to device events and maintains an aggregated [DeviceState] for each device.
class DeviceStateService {
  DeviceStateService._();

  static final DeviceStateService instance = DeviceStateService._();

  final Map<String, DeviceState> _states = {};
  final StreamController<DeviceState> _controller =
      StreamController.broadcast();

  StreamSubscription? _subscription;

  /// Start listening to [DeviceCommunicationEventService].
  void init() {
    _subscription?.cancel();
    _subscription = DeviceCommunicationEventService.instance.listenAll().listen(
      _handleEvent,
    );
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }

  /// Get the current state for a device.
  DeviceState? getState(String deviceId) => _states[deviceId];

  /// Stream of state updates for a specific device.
  Stream<DeviceState> stream(String deviceId) {
    return _controller.stream.where((s) => s.deviceId == deviceId);
  }

  /// Stream of state updates for a specific device, starting with the current state.
  Stream<DeviceState> streamWithCurrent(String deviceId) {
    final current = _states[deviceId];
    final stream = _controller.stream.where((s) => s.deviceId == deviceId);
    if (current != null) {
      // Create a broadcast stream that emits current then follows the broadcast stream
      final controller = StreamController<DeviceState>.broadcast();

      // Emit current state immediately
      controller.add(current);

      // Then forward all future updates
      final subscription = stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );

      // Clean up subscription when all listeners cancel
      controller.onCancel = () {
        subscription.cancel();
      };

      return controller.stream;
    }
    return stream;
  }

  void _handleEvent(DeviceEvent event) {
    if (event.payload is! MeshtasticDeviceEventPayload) return;

    final deviceId = event.tags['deviceId']?.firstOrNull;
    if (deviceId == null) return;

    final meshEvent = (event.payload as MeshtasticDeviceEventPayload).event;

    var state = _states[deviceId] ?? DeviceState(deviceId: deviceId);
    var changed = false;

    if (meshEvent is ConfigEvent) {
      final newConfig = meshEvent.config;
      // Only update if the new config has actual data, or if we don't have a config yet
      if (_hasConfigData(newConfig)) {
        LoggingService.instance.push(
          tags: {'deviceId': deviceId, 'class': 'DeviceStateService'},
          level: 'info',
          message: 'Updating ConfigEvent: $newConfig',
        );
        // If we have existing config, merge with it; otherwise use the new config directly
        final updatedConfig = state.config != null
            ? state.config!.copyWith(newConfig)
            : newConfig;
        state = state.copyWith(config: updatedConfig);
        changed = true;
      } else {
        LoggingService.instance.push(
          tags: {'deviceId': deviceId, 'class': 'DeviceStateService'},
          level: 'debug',
          message: 'Skipping empty ConfigEvent (keeping existing config)',
        );
      }
    } else if (meshEvent is ModuleConfigEvent) {
      final newModuleConfig = meshEvent.moduleConfig;
      // Only update if the new module config has actual data
      if (_hasModuleConfigData(newModuleConfig)) {
        LoggingService.instance.push(
          tags: {'deviceId': deviceId, 'class': 'DeviceStateService'},
          level: 'info',
          message: 'Updating ModuleConfigEvent: $newModuleConfig',
        );
        // If we have existing module config, merge with it; otherwise use the new config directly
        final updatedModuleConfig = state.moduleConfig != null
            ? state.moduleConfig!.copyWith(newModuleConfig)
            : newModuleConfig;
        state = state.copyWith(moduleConfig: updatedModuleConfig);
        changed = true;
      } else {
        LoggingService.instance.push(
          tags: {'deviceId': deviceId, 'class': 'DeviceStateService'},
          level: 'debug',
          message: 'Skipping empty ModuleConfigEvent (keeping existing config)',
        );
      }
    } else if (meshEvent is ChannelEvent) {
      final newChannel = meshEvent.channel;
      final channels = List<ChannelDto>.from(state.channels);
      final index = channels.indexWhere((c) => c.index == newChannel.index);
      if (index >= 0) {
        channels[index] = newChannel;
      } else {
        channels.add(newChannel);
      }
      state = state.copyWith(channels: channels);
      changed = true;
    } else if (meshEvent is NodeInfoEvent) {
      final newNode = meshEvent.nodeInfo;
      final nodes = List<NodeInfoDto>.from(state.nodes);
      final index = nodes.indexWhere((n) => n.num == newNode.num);
      if (index >= 0) {
        nodes[index] = newNode;
      } else {
        nodes.add(newNode);
      }
      state = state.copyWith(nodes: nodes);
      changed = true;
    } else if (meshEvent is MyInfoEvent) {
      state = state.copyWith(myNodeInfo: meshEvent.myInfo);
      changed = true;
    } else if (meshEvent is DeviceMetadataEvent) {
      state = state.copyWith(metadata: meshEvent.metadata);
      changed = true;
    }

    if (changed) {
      _states[deviceId] = state;
      _controller.add(state);
    }
  }

  /// Check if a ConfigDto contains any actual configuration data.
  /// Returns true if any field is non-null, false if all fields are null.
  bool _hasConfigData(ConfigDto config) {
    return config.device != null ||
        config.position != null ||
        config.power != null ||
        config.network != null ||
        config.display != null ||
        config.lora != null ||
        config.bluetooth != null ||
        config.security != null ||
        config.sessionkey != null;
  }

  /// Check if a ModuleConfigDto contains any actual configuration data.
  /// Returns true if any field is non-null, false if all fields are null.
  bool _hasModuleConfigData(ModuleConfigDto config) {
    return config.mqtt != null ||
        config.telemetry != null ||
        config.serial != null ||
        config.storeForward != null ||
        config.rangeTest != null ||
        config.externalNotification != null ||
        config.audio != null ||
        config.neighborInfo != null ||
        config.remoteHardware != null ||
        config.paxcounter != null ||
        config.cannedMessage != null ||
        config.ambientLighting != null ||
        config.detectionSensor != null ||
        config.dtnOverlay != null ||
        config.broadcastAssist != null ||
        config.nodeMod != null ||
        config.nodeModAdmin != null ||
        config.idleGame != null;
  }
}
