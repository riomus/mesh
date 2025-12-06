import 'package:equatable/equatable.dart';
import '../../models/device_state.dart';

class DevicesState extends Equatable {
  final Map<String, DeviceState> deviceStates;

  const DevicesState({this.deviceStates = const {}});

  DeviceState? getDeviceState(String deviceId) => deviceStates[deviceId];

  DevicesState copyWith({Map<String, DeviceState>? deviceStates}) {
    return DevicesState(deviceStates: deviceStates ?? this.deviceStates);
  }

  @override
  List<Object?> get props => [deviceStates];
}
