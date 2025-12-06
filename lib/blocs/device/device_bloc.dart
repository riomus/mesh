import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/device_state.dart';
import '../../services/device_state_service.dart';
import '../../services/logging_service.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DevicesState> {
  StreamSubscription? _subscription;

  DeviceBloc() : super(const DevicesState()) {
    on<DeviceStateUpdated>(_onDeviceStateUpdated);

    _init();
  }

  void _init() {
    _subscription = DeviceStateService.instance.streamAll.listen(
      (state) => add(DeviceStateUpdated(state)),
      onError: (e, s) {
        LoggingService.instance.push(
          tags: {'class': 'DeviceBloc'},
          level: 'error',
          message: 'Error in DeviceBloc subscription: $e',
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void _onDeviceStateUpdated(
    DeviceStateUpdated event,
    Emitter<DevicesState> emit,
  ) {
    final newDeviceStates = Map<String, DeviceState>.from(state.deviceStates);
    newDeviceStates[event.state.deviceId] = event.state;
    emit(state.copyWith(deviceStates: newDeviceStates));
  }
}
